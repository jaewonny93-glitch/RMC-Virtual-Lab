import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../models/cell_model.dart';
import '../../models/lab_model.dart';
import '../main_screen.dart';

// ─────────────────────────────────────────────────────────────
//  IncubatorScreen  (배양 모니터링 + 교체 + 계대배양 전체 흐름)
// ─────────────────────────────────────────────────────────────
class IncubatorScreen extends StatefulWidget {
  const IncubatorScreen({super.key});
  @override
  State<IncubatorScreen> createState() => _IncubatorScreenState();
}

class _IncubatorScreenState extends State<IncubatorScreen>
    with TickerProviderStateMixin {
  late AnimationController _doorController;
  late AnimationController _glowController;
  late Animation<double> _doorAnim;
  late Animation<double> _glowAnim;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  // 배양액 교체 경고
  bool _mediumChangeWarningShown = false;

  // 마지막 배양액 교체 시간
  DateTime? _lastMediumChange;

  // 세포 사멸 여부 (표준 교체 2배 초과 시)
  bool _cellDead = false;

  @override
  void initState() {
    super.initState();
    _doorController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _glowController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _doorAnim =
        CurvedAnimation(parent: _doorController, curve: Curves.easeInOut);
    _glowAnim =
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut);
    _doorController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final session = context.read<ExperimentSession>();
      if (session.incubatorStartTime != null) {
        final newElapsed =
            DateTime.now().difference(session.incubatorStartTime!);
        setState(() {
          _elapsed = newElapsed;
        });
        _checkMediumChangeAlert(session);
      }
    });
  }

  @override
  void dispose() {
    _doorController.dispose();
    _glowController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ── 배양액 교체 알림 & 세포 사멸 로직 ──────────────────────
  void _checkMediumChangeAlert(ExperimentSession session) {
    if (_cellDead) return;

    // 표준 교체 간격: 세포 배양 시 3일(72시간) 기준
    // 시뮬레이션: 실제 시간 1분 = 배양 시간 1시간 (60배 가속)
    final simulatedHours = _elapsed.inSeconds / 60.0;
    final lastChangeHours = _lastMediumChange != null
        ? DateTime.now().difference(_lastMediumChange!).inSeconds / 60.0
        : simulatedHours;

    // 표준 교체 주기: 72시간 (시뮬레이션 72분)
    const standardChangeIntervalH = 72.0; // 시간
    const overdueMultiplier = 2.0; // 2배 초과 시 사멸

    final isOverdue = lastChangeHours >= standardChangeIntervalH;
    final isDead =
        lastChangeHours >= standardChangeIntervalH * overdueMultiplier;

    if (isDead && !_cellDead) {
      setState(() => _cellDead = true);
      _showCellDeathDialog();
      return;
    }

    if (isOverdue && !_mediumChangeWarningShown) {
      setState(() => _mediumChangeWarningShown = true);
      _showMediumChangeAlert();
    }
  }

  void _showMediumChangeAlert() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            const Text('배양액 교체 필요',
                style: TextStyle(color: Colors.amber, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '표준 배양액 교체 주기(72h)가 지났습니다.\n지금 교체하지 않으면 세포가 사멸할 수 있습니다.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: const Text(
                '⚠ 교체 지연 2배(144h) 초과 시 세포 전체 사멸',
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('나중에', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              _showMediumChangeDialog();
            },
            child: const Text('지금 교체',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCellDeathDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A0A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.red, width: 2)),
        title: const Row(
          children: [
            Icon(Icons.dangerous, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('세포 사멸', style: TextStyle(color: Colors.red, fontSize: 16)),
          ],
        ),
        content: const Text(
          '배양액 교체가 너무 늦었습니다.\n영양 고갈 및 독성 노폐물 축적으로 세포가 모두 사멸했습니다.\n\n실험을 처음부터 다시 시작해야 합니다.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              final session = context.read<ExperimentSession>();
              session.reset();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
              );
            },
            child: const Text('확인 (실험 종료)'),
          ),
        ],
      ),
    );
  }

  // ── 배양액 교체 다이얼로그 ──────────────────────────────────
  void _showMediumChangeDialog() {
    if (!mounted) return;
    final session = context.read<ExperimentSession>();
    final cell = session.cellTypeId != null
        ? CellDatabase.findById(session.cellTypeId!)
        : null;
    final dish = session.dishTypeId != null
        ? DishDatabase.findById(session.dishTypeId!)
        : null;

    final standardMedium = cell?.medium ?? '배양액';
    final standardVol = dish?.standardVolumeMl ?? 10.0;

    showDialog(
      context: context,
      builder: (ctx) => _MediumChangeDialog(
        medium: standardMedium,
        standardVolume: standardVol,
        onConfirm: () {
          Navigator.pop(ctx);
          setState(() {
            _lastMediumChange = DateTime.now();
            _mediumChangeWarningShown = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '✅ 배양액 교체 완료 ($standardMedium ${standardVol.toStringAsFixed(0)}mL)'),
              backgroundColor: Colors.teal,
            ),
          );
        },
      ),
    );
  }

  // ── 계대배양 다이얼로그 (90% confluence) ───────────────────
  void _showSubcultureDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => SubcultureDialog(
        onComplete: (result) {
          Navigator.pop(ctx);
          _showCentrifugeDialog(result);
        },
      ),
    );
  }

  // ── 원심분리 다이얼로그 ─────────────────────────────────────
  void _showCentrifugeDialog(SubcultureResult subcultureResult) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => CentrifugeDialog(
        subcultureResult: subcultureResult,
        onComplete: (resuspensionVolume) {
          Navigator.pop(ctx);
          _showCellCountDialog(resuspensionVolume, subcultureResult);
        },
      ),
    );
  }

  // ── 세포 계수 다이얼로그 ────────────────────────────────────
  void _showCellCountDialog(
      double resuspensionVolume, SubcultureResult subcultureResult) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => CellCountDialog(
        resuspensionVolumeUL: resuspensionVolume,
        cellName:
            CellDatabase.findById(context.read<ExperimentSession>().cellTypeId ?? '')
                    ?.name ??
                'Unknown',
        onComplete: (result) {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '✅ 세포계수 완료: ${result.cellsPerML.toStringAsFixed(2)} × 10⁶ cells/mL\n'
                  '잔여액 ${(result.remainingVolumeUL / 1000).toStringAsFixed(3)} mL로 계속 진행'),
              backgroundColor: Colors.teal,
              duration: const Duration(seconds: 4),
            ),
          );
        },
      ),
    );
  }

  // ── 합류도 계산 ────────────────────────────────────────────
  double _getConfluence(ExperimentSession session) {
    if (session.incubatorStartTime == null) return 0;
    final cell = session.cellTypeId != null
        ? CellDatabase.findById(session.cellTypeId!)
        : null;
    if (cell == null) return 0;

    // 시뮬레이션: 1초 = 1시간 배양
    final simulatedHours = _elapsed.inSeconds.toDouble();
    final doublings = simulatedHours / cell.doublingTimeHours;
    // 로지스틱 성장 곡선으로 합류도 계산
    final confluence =
        100.0 / (1 + exp(-0.5 * (doublings - 4)));
    return confluence.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ExperimentSession>();
    final cell = session.cellTypeId != null
        ? CellDatabase.findById(session.cellTypeId!)
        : null;
    final confluence = _getConfluence(session);
    final needsPassage = confluence >= 90 && !_cellDead;

    return Scaffold(
      backgroundColor: const Color(0xFF050D1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/incubator.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.65)),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        // 인큐베이터 상태 패널
                        _buildIncubatorPanel(session, cell),
                        const SizedBox(height: 12),
                        // 합류도 게이지
                        _buildConfluencePanel(confluence, needsPassage),
                        const SizedBox(height: 12),
                        if (cell != null)
                          _CellGrowthStatus(
                              cell: cell,
                              elapsed: _elapsed,
                              cellDead: _cellDead),
                        const SizedBox(height: 12),
                        // 세포 파티클
                        _CellParticleDisplay(
                            elapsed: _elapsed,
                            mediumCorrect: session.isMediumCorrect &&
                                !_cellDead),
                        const SizedBox(height: 16),
                        // 액션 버튼들
                        _buildActionButtons(
                            context, needsPassage, session),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 90% 합류도 경고 배너
          if (needsPassage)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber,
                          color: Colors.amber, size: 16),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          '⚠ 90% 합류도 도달 — 계대배양이 필요합니다!',
                          style:
                              TextStyle(color: Colors.amber, fontSize: 12),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0)),
                        onPressed: _showSubcultureDialog,
                        child: const Text('계대배양',
                            style: TextStyle(
                                color: Colors.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white54),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
            ),
          ),
          const Expanded(
            child: Column(
              children: [
                Text('인큐베이터',
                    style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text('실시간 세포 성장 모니터링',
                    style:
                        TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            tooltip: '배양액 교체',
            icon:
                const Icon(Icons.water_drop, color: Color(0xFF00E5FF)),
            onPressed: _showMediumChangeDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildIncubatorPanel(ExperimentSession session, CellType? cell) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black.withValues(alpha: 0.45),
          border: Border.all(
              color: Color.lerp(const Color(0xFF00E5FF), Colors.tealAccent,
                      _glowAnim.value) ??
                  const Color(0xFF00E5FF),
              width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF)
                  .withValues(alpha: 0.1 + _glowAnim.value * 0.15),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoChip(
                    icon: Icons.thermostat,
                    label: '온도',
                    value: '37.0°C'),
                _InfoChip(
                    icon: Icons.co2,
                    label: 'CO₂',
                    value: '5.0%'),
                _InfoChip(
                    icon: Icons.water,
                    label: '습도',
                    value: '95%'),
                if (cell != null)
                  _InfoChip(
                      icon: Icons.biotech,
                      label: '세포',
                      value: cell.name),
              ],
            ),
            const SizedBox(height: 12),
            _ElapsedTimer(elapsed: _elapsed),
            if (cell != null) ...[
              const SizedBox(height: 10),
              _DoublingProgress(cell: cell, elapsed: _elapsed),
            ],
            if (_lastMediumChange != null) ...[
              const SizedBox(height: 8),
              _MediumChangeTimer(lastChange: _lastMediumChange!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfluencePanel(double confluence, bool needsPassage) {
    final color = confluence < 60
        ? Colors.tealAccent
        : confluence < 90
            ? Colors.amber
            : Colors.redAccent;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('합류도 (Confluence)',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              Text(
                '${confluence.toStringAsFixed(1)}%',
                style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: confluence / 100,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 10,
            ),
          ),
          if (needsPassage)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '계대배양 필요 — 세포가 dish 면적의 90% 이상 도달했습니다.',
                style: TextStyle(
                    color: Colors.amber.withValues(alpha: 0.9),
                    fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, bool needsPassage, ExperimentSession session) {
    return Column(
      children: [
        // 배양액 교체 버튼
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF00E5FF)),
              foregroundColor: const Color(0xFF00E5FF),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            icon: const Icon(Icons.water_drop_outlined, size: 18),
            label: const Text('배양액 교체'),
            onPressed: _showMediumChangeDialog,
          ),
        ),
        const SizedBox(height: 10),
        // 계대배양 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: needsPassage
                  ? Colors.amber
                  : const Color(0xFF1E3A5F),
              foregroundColor: needsPassage ? Colors.black : Colors.white54,
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            icon: const Icon(Icons.science_outlined, size: 18),
            label: Text(
              needsPassage ? '계대배양 시작 ⚠' : '계대배양',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: _showSubcultureDialog,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  foregroundColor: Colors.white54,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                icon: const Icon(Icons.show_chart, size: 18),
                label: const Text('그래프'),
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                  (route) => false,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  foregroundColor: Colors.white54,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                icon: const Icon(Icons.home, size: 18),
                label: const Text('홈'),
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                  (route) => false,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _MediumChangeTimer  (마지막 교체 후 경과 시간 표시)
// ─────────────────────────────────────────────────────────────
class _MediumChangeTimer extends StatelessWidget {
  final DateTime lastChange;
  const _MediumChangeTimer({required this.lastChange});

  @override
  Widget build(BuildContext context) {
    final since = DateTime.now().difference(lastChange);
    // 시뮬레이션에서 초를 시간으로 변환
    final simHours = since.inSeconds.toDouble();
    final h = simHours.floor();
    final m = ((simHours - h) * 60).floor();
    final isWarning = simHours >= 60;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.update, size: 12,
            color: isWarning ? Colors.amber : Colors.white38),
        const SizedBox(width: 4),
        Text(
          '마지막 교체: ${h}h ${m}m 전',
          style: TextStyle(
              color: isWarning ? Colors.amber : Colors.white38,
              fontSize: 11),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _InfoChip
// ─────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00E5FF), size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SubcultureResult
// ─────────────────────────────────────────────────────────────
class SubcultureResult {
  final String reagent;
  final String environment;  // 'incubator' or 'rt'
  final int incubationMinutes;
  final String tubeSize;

  SubcultureResult({
    required this.reagent,
    required this.environment,
    required this.incubationMinutes,
    required this.tubeSize,
  });
}

// ─────────────────────────────────────────────────────────────
//  SubcultureDialog  (계대배양: 시약, 환경, 타이머, 튜브 크기)
// ─────────────────────────────────────────────────────────────
class SubcultureDialog extends StatefulWidget {
  final void Function(SubcultureResult) onComplete;
  const SubcultureDialog({super.key, required this.onComplete});

  @override
  State<SubcultureDialog> createState() => _SubcultureDialogState();
}

class _SubcultureDialogState extends State<SubcultureDialog> {
  int _step = 0;
  String _selectedReagent = 'Trypsin-EDTA (0.25%)';
  String _selectedEnv = 'incubator';
  int _incubationMinutes = 5;
  String _selectedTube = '15mL';
  Timer? _incubationTimer;
  int _remainingSeconds = 0;
  bool _timerRunning = false;
  bool _timerDone = false;

  final List<String> _reagents = [
    'Trypsin-EDTA (0.25%)',
    'Trypsin-EDTA (0.05%)',
    'Accutase',
    'TrypLE Express',
    'Dispase',
    'Collagenase Type I',
    'Collagenase Type IV',
    'EDTA (2mM)',
    'Cell Scraper',
  ];

  final List<String> _tubeSizes = [
    '1.5mL',
    '5mL',
    '15mL',
    '50mL',
  ];

  @override
  void dispose() {
    _incubationTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _remainingSeconds = _incubationMinutes * 60;
      _timerRunning = true;
      _timerDone = false;
    });
    _incubationTimer =
        Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timerRunning = false;
          _timerDone = true;
          t.cancel();
        }
      });
    });
  }

  String get _timerText {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D1B2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: const Text('계대배양',
                      style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                // 단계 표시
                Text('${_step + 1}/4',
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            // 단계별 내용
            if (_step == 0) _buildReagentStep(),
            if (_step == 1) _buildEnvironmentStep(),
            if (_step == 2) _buildTimerStep(),
            if (_step == 3) _buildTubeStep(),
            const SizedBox(height: 16),
            // 버튼
            Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          foregroundColor: Colors.white54),
                      onPressed: () {
                        _incubationTimer?.cancel();
                        setState(() {
                          _step--;
                          _timerRunning = false;
                          _timerDone = false;
                        });
                      },
                      child: const Text('이전'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: Colors.black),
                    onPressed: _canProceed() ? _proceed : null,
                    child: Text(
                      _step < 3 ? '다음' : '완료',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    if (_step == 2) return _timerDone;
    return true;
  }

  void _proceed() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      widget.onComplete(SubcultureResult(
        reagent: _selectedReagent,
        environment: _selectedEnv,
        incubationMinutes: _incubationMinutes,
        tubeSize: _selectedTube,
      ));
    }
  }

  Widget _buildReagentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('1. 탈착 시약 선택',
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            itemCount: _reagents.length,
            itemBuilder: (ctx, i) {
              final r = _reagents[i];
              final selected = r == _selectedReagent;
              return GestureDetector(
                onTap: () => setState(() => _selectedReagent = r),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF00E5FF)
                          : Colors.white12,
                    ),
                  ),
                  child: Text(r,
                      style: TextStyle(
                          color: selected
                              ? const Color(0xFF00E5FF)
                              : Colors.white70,
                          fontSize: 13)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnvironmentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('2. 처리 환경 선택',
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _EnvCard(
          title: '인큐베이터 (37°C)',
          subtitle: '일반 부착성 세포, Trypsin 사용 시 권장',
          icon: Icons.thermostat,
          selected: _selectedEnv == 'incubator',
          onTap: () => setState(() => _selectedEnv = 'incubator'),
        ),
        const SizedBox(height: 10),
        _EnvCard(
          title: '실온 (RT, ~22°C)',
          subtitle: 'Accutase, 민감한 세포 사용 시 권장',
          icon: Icons.device_thermostat,
          selected: _selectedEnv == 'rt',
          onTap: () => setState(() => _selectedEnv = 'rt'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('인큐베이션 시간:',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.white38, size: 20),
              onPressed: _incubationMinutes > 1
                  ? () => setState(() => _incubationMinutes--)
                  : null,
            ),
            Text('$_incubationMinutes min',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: Color(0xFF00E5FF), size: 20),
              onPressed: _incubationMinutes < 60
                  ? () => setState(() => _incubationMinutes++)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimerStep() {
    final progress = _timerRunning || _timerDone
        ? 1.0 -
            (_remainingSeconds /
                (_incubationMinutes * 60).toDouble())
        : 0.0;

    return Column(
      children: [
        Text('3. 인큐베이션 타이머 (${_incubationMinutes}분)',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          _selectedEnv == 'incubator' ? '37°C 인큐베이터' : '실온 (RT)',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 16),
        // 타이머 원형
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: _timerDone ? 1.0 : progress,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(
                      _timerDone ? Colors.tealAccent : const Color(0xFF00E5FF)),
                  strokeWidth: 8,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_timerDone)
                    const Icon(Icons.check_circle,
                        color: Colors.tealAccent, size: 40)
                  else
                    Text(
                      _timerRunning ? _timerText : '${_incubationMinutes}:00',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace'),
                    ),
                  if (_timerDone)
                    const Text('완료!',
                        style: TextStyle(
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (!_timerRunning && !_timerDone)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black),
            icon: const Icon(Icons.play_arrow),
            label: const Text('타이머 시작'),
            onPressed: _startTimer,
          ),
        if (_timerRunning)
          OutlinedButton(
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                foregroundColor: Colors.white54),
            onPressed: () {
              _incubationTimer?.cancel();
              setState(() {
                _timerRunning = false;
                _timerDone = true;
              });
            },
            child: const Text('건너뛰기 (테스트용)'),
          ),
        if (_timerDone)
          const Text(
            '타이머 완료! 다음 단계로 진행하세요.',
            style: TextStyle(color: Colors.tealAccent, fontSize: 13),
          ),
      ],
    );
  }

  Widget _buildTubeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('4. 수집 튜브 크기 선택',
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text(
          '세포 현탁액을 수집할 튜브 크기를 선택하세요.',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 12),
        ..._tubeSizes.map((size) {
          final selected = size == _selectedTube;
          return GestureDetector(
            onTap: () => setState(() => _selectedTube = size),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF00E5FF).withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF00E5FF)
                      : Colors.white12,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.science,
                    color: selected
                        ? const Color(0xFF00E5FF)
                        : Colors.white38,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    size,
                    style: TextStyle(
                        color: selected
                            ? const Color(0xFF00E5FF)
                            : Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (selected)
                    const Icon(Icons.check_circle,
                        color: Color(0xFF00E5FF), size: 20),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _EnvCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _EnvCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF00E5FF).withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected
                  ? const Color(0xFF00E5FF)
                  : Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected
                    ? const Color(0xFF00E5FF)
                    : Colors.white38,
                size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: selected
                              ? const Color(0xFF00E5FF)
                              : Colors.white70,
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: Color(0xFF00E5FF), size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _MediumChangeDialog
// ─────────────────────────────────────────────────────────────
class _MediumChangeDialog extends StatelessWidget {
  final String medium;
  final double standardVolume;
  final VoidCallback onConfirm;
  const _MediumChangeDialog(
      {required this.medium,
      required this.standardVolume,
      required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0D1B2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.water_drop, color: Color(0xFF00E5FF), size: 22),
          SizedBox(width: 8),
          Text('배양액 교체',
              style: TextStyle(color: Color(0xFF00E5FF), fontSize: 16)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('교체 절차:',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _StepRow(
              num: 1, text: '기존 배양액을 aspirate로 완전히 제거'),
          _StepRow(
              num: 2,
              text: 'PBS로 세포 표면을 부드럽게 세척'),
          _StepRow(
              num: 3,
              text:
                  '$medium ${standardVolume.toStringAsFixed(0)} mL 첨가'),
          _StepRow(num: 4, text: '인큐베이터에 복귀'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
            ),
            child: Text(
              '배양액: $medium\n표준 교체량: ${standardVolume.toStringAsFixed(0)} mL',
              style: const TextStyle(
                  color: Color(0xFF00E5FF), fontSize: 12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
              const Text('취소', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black),
          onPressed: onConfirm,
          child: const Text('교체 완료',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final int num;
  final String text;
  const _StepRow({required this.num, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text('$num',
                style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CentrifugeDialog  (원심분리: RPM/xg, 시간, 온도, 재현탁)
// ─────────────────────────────────────────────────────────────
class CentrifugeDialog extends StatefulWidget {
  final SubcultureResult subcultureResult;
  final void Function(double resuspensionVolumeUL) onComplete;
  const CentrifugeDialog(
      {super.key,
      required this.subcultureResult,
      required this.onComplete});

  @override
  State<CentrifugeDialog> createState() => _CentrifugeDialogState();
}

class _CentrifugeDialogState extends State<CentrifugeDialog> {
  // 원심분리 설정
  bool _useRpm = true; // true = RPM, false = xg
  double _rpmValue = 300.0;
  double _xgValue = 100.0;
  int _durationMinutes = 5;
  int _durationSeconds = 0;
  double _temperature = 4.0;

  // 재현탁 볼륨
  final _resuspensionCtrl = TextEditingController(text: '1000');

  // 스핀 상태
  bool _spinning = false;
  bool _spinDone = false;
  Timer? _spinTimer;
  int _spinRemainingSeconds = 0;

  @override
  void dispose() {
    _spinTimer?.cancel();
    _resuspensionCtrl.dispose();
    super.dispose();
  }

  double get _currentXg => _useRpm ? _rpmToXg(_rpmValue) : _xgValue;
  double get _currentRpm => _useRpm ? _rpmValue : _xgToRpm(_xgValue);

  double _rpmToXg(double rpm) => (rpm * rpm * 11.17e-6);
  double _xgToRpm(double xg) => sqrt(xg / 11.17e-6);

  void _startSpin() {
    final totalSeconds = _durationMinutes * 60 + _durationSeconds;
    setState(() {
      _spinning = true;
      _spinDone = false;
      _spinRemainingSeconds = totalSeconds;
    });
    _spinTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_spinRemainingSeconds > 0) {
          _spinRemainingSeconds--;
        } else {
          _spinning = false;
          _spinDone = true;
          t.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D1B2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.purple.withValues(alpha: 0.5)),
                  ),
                  child: const Text('원심분리',
                      style: TextStyle(
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text(
                  '튜브: ${widget.subcultureResult.tubeSize}',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // RPM / xg 토글
            Row(
              children: [
                const Text('단위:',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('RPM'),
                  selected: _useRpm,
                  onSelected: (_) => setState(() => _useRpm = true),
                  selectedColor:
                      const Color(0xFF00E5FF).withValues(alpha: 0.3),
                  labelStyle: TextStyle(
                      color: _useRpm
                          ? const Color(0xFF00E5FF)
                          : Colors.white54),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('× g'),
                  selected: !_useRpm,
                  onSelected: (_) => setState(() => _useRpm = false),
                  selectedColor:
                      const Color(0xFF00E5FF).withValues(alpha: 0.3),
                  labelStyle: TextStyle(
                      color: !_useRpm
                          ? const Color(0xFF00E5FF)
                          : Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // RPM 또는 xg 슬라이더
            if (_useRpm) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('RPM',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  Text(
                    '${_rpmValue.toInt()} RPM  (${_rpmToXg(_rpmValue).toStringAsFixed(0)} × g)',
                    style: const TextStyle(
                        color: Color(0xFF00E5FF),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Slider(
                value: _rpmValue,
                min: 100,
                max: 3000,
                divisions: 58,
                activeColor: const Color(0xFF00E5FF),
                inactiveColor: Colors.white12,
                onChanged: (v) => setState(() => _rpmValue = v),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('× g',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  Text(
                    '${_xgValue.toInt()} × g  (${_xgToRpm(_xgValue).toInt()} RPM)',
                    style: const TextStyle(
                        color: Color(0xFF00E5FF),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Slider(
                value: _xgValue,
                min: 30,
                max: 1000,
                divisions: 97,
                activeColor: const Color(0xFF00E5FF),
                inactiveColor: Colors.white12,
                onChanged: (v) => setState(() => _xgValue = v),
              ),
            ],
            const SizedBox(height: 8),

            // 시간 설정
            const Text('시간',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('분',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 11)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove,
                                color: Colors.white38, size: 18),
                            onPressed: _durationMinutes > 0
                                ? () => setState(
                                    () => _durationMinutes--)
                                : null,
                          ),
                          Text('${_durationMinutes.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace')),
                          IconButton(
                            icon: const Icon(Icons.add,
                                color: Color(0xFF00E5FF), size: 18),
                            onPressed: _durationMinutes < 60
                                ? () => setState(
                                    () => _durationMinutes++)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Text(':',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                Expanded(
                  child: Column(
                    children: [
                      const Text('초',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 11)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove,
                                color: Colors.white38, size: 18),
                            onPressed: _durationSeconds > 0
                                ? () => setState(
                                    () => _durationSeconds -= 5)
                                : null,
                          ),
                          Text(
                              '${_durationSeconds.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace')),
                          IconButton(
                            icon: const Icon(Icons.add,
                                color: Color(0xFF00E5FF), size: 18),
                            onPressed: _durationSeconds < 55
                                ? () => setState(
                                    () => _durationSeconds += 5)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 온도 설정
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('온도',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13)),
                Text('${_temperature.toStringAsFixed(0)}°C',
                    style: const TextStyle(
                        color: Color(0xFF00E5FF),
                        fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _temperature,
              min: 4,
              max: 37,
              divisions: 33,
              activeColor: const Color(0xFF00E5FF),
              inactiveColor: Colors.white12,
              label: '${_temperature.toInt()}°C',
              onChanged:
                  _spinning ? null : (v) => setState(() => _temperature = v),
            ),
            const SizedBox(height: 12),

            // 원심분리 실행 버튼 / 타이머
            if (!_spinning && !_spinDone)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white),
                  icon: const Icon(Icons.rotate_right),
                  label: Text(
                    '원심분리 시작  '
                    '(${_currentRpm.toInt()} RPM, '
                    '${_currentXg.toStringAsFixed(0)} × g, '
                    '${_durationMinutes}:${_durationSeconds.toString().padLeft(2, '0')}, '
                    '${_temperature.toInt()}°C)',
                    style: const TextStyle(fontSize: 11),
                  ),
                  onPressed: _startSpin,
                ),
              ),
            if (_spinning) ...[
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                        color: Colors.purpleAccent),
                    const SizedBox(height: 8),
                    Text(
                      '원심분리 중... ${(_spinRemainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_spinRemainingSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.bold),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          foregroundColor: Colors.white38),
                      onPressed: () {
                        _spinTimer?.cancel();
                        setState(() {
                          _spinning = false;
                          _spinDone = true;
                        });
                      },
                      child: const Text('건너뛰기 (테스트용)',
                          style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ],
            if (_spinDone) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.tealAccent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.tealAccent, size: 20),
                    const SizedBox(width: 8),
                    const Text('원심분리 완료! 상층액을 제거하세요.',
                        style: TextStyle(
                            color: Colors.tealAccent, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('재현탁 볼륨 (µL)',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _resuspensionCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  suffixText: 'µL',
                  suffixStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF00E5FF)),
                  ),
                  hintText: '예: 1000',
                  hintStyle: const TextStyle(color: Colors.white24),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black),
                  onPressed: () {
                    final vol =
                        double.tryParse(_resuspensionCtrl.text) ?? 1000.0;
                    widget.onComplete(vol);
                  },
                  child: const Text('다음: 세포 계수',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CellCountResult
// ─────────────────────────────────────────────────────────────
class CellCountResult {
  final double totalCount;     // 총 세포 수 (4사분면 평균 × 10000 × 희석배수)
  final double viableCount;    // 생존 세포 수
  final double viability;      // 생존율 %
  final double cellsPerML;     // × 10⁶ cells/mL
  final double remainingVolumeUL;
  CellCountResult({
    required this.totalCount,
    required this.viableCount,
    required this.viability,
    required this.cellsPerML,
    required this.remainingVolumeUL,
  });
}

// ─────────────────────────────────────────────────────────────
//  CellCountDialog  (트리판블루 1:1, 혈구계산판)
// ─────────────────────────────────────────────────────────────
class CellCountDialog extends StatefulWidget {
  final double resuspensionVolumeUL;
  final String cellName;
  final void Function(CellCountResult) onComplete;
  const CellCountDialog({
    super.key,
    required this.resuspensionVolumeUL,
    required this.cellName,
    required this.onComplete,
  });

  @override
  State<CellCountDialog> createState() => _CellCountDialogState();
}

class _CellCountDialogState extends State<CellCountDialog> {
  // 혈구계산판 4사분면 입력 (생존 세포)
  final List<TextEditingController> _viableCtrl =
      List.generate(4, (_) => TextEditingController());
  // 사멸 세포 (트리판블루 염색)
  final List<TextEditingController> _deadCtrl =
      List.generate(4, (_) => TextEditingController());

  CellCountResult? _result;

  @override
  void dispose() {
    for (final c in [..._viableCtrl, ..._deadCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _calculate() {
    final viableVals = _viableCtrl
        .map((c) => double.tryParse(c.text) ?? 0.0)
        .toList();
    final deadVals =
        _deadCtrl.map((c) => double.tryParse(c.text) ?? 0.0).toList();

    final avgViable = viableVals.reduce((a, b) => a + b) / 4;
    final avgDead = deadVals.reduce((a, b) => a + b) / 4;
    final avgTotal = avgViable + avgDead;

    // 희석배수 = 2 (1:1 트리판블루)
    // 혈구계산판 환산: 세포수/mL = 평균값 × 10^4 × 희석배수
    const dilutionFactor = 2.0;
    final cellsPerML = avgViable * 10000 * dilutionFactor; // cells/mL
    final viability = avgTotal > 0 ? (avgViable / avgTotal) * 100 : 0.0;

    // 세포계수에 사용한 10µL 차감
    const sampledUL = 10.0;
    final remaining =
        (widget.resuspensionVolumeUL - sampledUL).clamp(0, double.infinity);

    setState(() {
      _result = CellCountResult(
        totalCount: avgTotal * 10000 * dilutionFactor,
        viableCount: cellsPerML,
        viability: viability,
        cellsPerML: cellsPerML / 1e6,
        remainingVolumeUL: remaining.toDouble(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D1B2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.green.withValues(alpha: 0.5)),
                  ),
                  child: const Text('세포 계수',
                      style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text(widget.cellName,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),

            // 트리판블루 안내
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.science,
                          color: Colors.lightBlueAccent, size: 16),
                      SizedBox(width: 6),
                      Text('Trypan Blue 1:1 희석',
                          style: TextStyle(
                              color: Colors.lightBlueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• 세포 현탁액 10 µL + 0.4% Trypan Blue 10 µL\n'
                    '• 재현탁 볼륨: ${widget.resuspensionVolumeUL.toStringAsFixed(0)} µL\n'
                    '• 희석 배수: 2× (1:1)\n'
                    '• 생존 세포: 무색 (Trypan Blue 제외)',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 혈구계산판 입력
            const Text('혈구계산판 (4사분면 입력)',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 8),

            // 4×2 그리드
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.9,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: 8,
              itemBuilder: (ctx, i) {
                final isViable = i < 4;
                final idx = isViable ? i : i - 4;
                final ctrl =
                    isViable ? _viableCtrl[idx] : _deadCtrl[idx];
                final color = isViable ? Colors.tealAccent : Colors.redAccent;
                return Column(
                  children: [
                    Text(
                      isViable ? 'Q${idx + 1} 생존' : 'Q${idx + 1} 사멸',
                      style: TextStyle(
                          color: color.withValues(alpha: 0.8),
                          fontSize: 9),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: TextField(
                        controller: ctrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: color.withValues(alpha: 0.07),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                                color: color.withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                                color: color.withValues(alpha: 0.4)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: color),
                          ),
                          hintText: '0',
                          hintStyle: const TextStyle(
                              color: Colors.white24, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            // 계산 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.black),
                icon: const Icon(Icons.calculate),
                label: const Text('계산',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _calculate,
              ),
            ),

            // 결과 표시
            if (_result != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.tealAccent.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('계산 결과',
                        style: TextStyle(
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const SizedBox(height: 8),
                    _ResultRow(
                      label: '세포 농도',
                      value:
                          '${_result!.cellsPerML.toStringAsFixed(3)} × 10⁶ cells/mL',
                    ),
                    _ResultRow(
                      label: '생존율 (Viability)',
                      value: '${_result!.viability.toStringAsFixed(1)}%',
                      valueColor: _result!.viability >= 90
                          ? Colors.tealAccent
                          : _result!.viability >= 70
                              ? Colors.amber
                              : Colors.redAccent,
                    ),
                    _ResultRow(
                      label: '잔여 현탁액',
                      value:
                          '${_result!.remainingVolumeUL.toStringAsFixed(0)} µL',
                    ),
                    _ResultRow(
                      label: '총 세포 수 (추정)',
                      value:
                          '${(_result!.cellsPerML * _result!.remainingVolumeUL / 1000).toStringAsFixed(2)} × 10⁶',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          foregroundColor: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('닫기 (계속 진행)'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: Colors.black),
                      onPressed: () => widget.onComplete(_result!),
                      child: const Text('저장 & 완료',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _ResultRow(
      {required this.label,
      required this.value,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 12)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  기존 위젯들
// ─────────────────────────────────────────────────────────────
class _ElapsedTimer extends StatelessWidget {
  final Duration elapsed;
  const _ElapsedTimer({required this.elapsed});

  @override
  Widget build(BuildContext context) {
    final h = elapsed.inHours;
    final m = elapsed.inMinutes % 60;
    final s = elapsed.inSeconds % 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, color: Colors.white54, size: 16),
          const SizedBox(width: 8),
          Text(
            '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}

class _DoublingProgress extends StatelessWidget {
  final CellType cell;
  final Duration elapsed;
  const _DoublingProgress({required this.cell, required this.elapsed});

  @override
  Widget build(BuildContext context) {
    final dtSeconds = cell.doublingTimeHours * 3600;
    final progress =
        (elapsed.inSeconds % dtSeconds) / dtSeconds;
    final doublings = elapsed.inSeconds / dtSeconds;
    final remainingS = dtSeconds - (elapsed.inSeconds % dtSeconds);
    final rH = (remainingS / 3600).floor();
    final rM = ((remainingS % 3600) / 60).floor();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('다음 분열까지',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            Text('${rH}h ${rM}m',
                style: const TextStyle(
                    color: Colors.tealAccent, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white12,
            valueColor:
                const AlwaysStoppedAnimation(Colors.tealAccent),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '총 ${doublings.toStringAsFixed(2)} 회 분열 완료',
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }
}

class _CellGrowthStatus extends StatelessWidget {
  final CellType cell;
  final Duration elapsed;
  final bool cellDead;
  const _CellGrowthStatus(
      {required this.cell,
      required this.elapsed,
      required this.cellDead});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ExperimentSession>();
    final totalCells =
        session.wells.fold<double>(0, (sum, w) => sum + w.cellCount);
    final doublings =
        elapsed.inSeconds / (cell.doublingTimeHours * 3600);
    final currentCells = totalCells * pow(2, doublings);

    String formatCells(double n) {
      if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(2)}×10⁹';
      if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(2)}×10⁶';
      if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(2)}×10³';
      return n.toStringAsFixed(0);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: cellDead
                ? Colors.red.withValues(alpha: 0.5)
                : session.isMediumCorrect
                    ? Colors.tealAccent.withValues(alpha: 0.3)
                    : Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            cellDead
                ? Icons.dangerous
                : session.isMediumCorrect
                    ? Icons.trending_up
                    : Icons.trending_down,
            color: cellDead
                ? Colors.red
                : session.isMediumCorrect
                    ? Colors.tealAccent
                    : Colors.redAccent,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cellDead
                      ? '✖ 세포 사멸'
                      : session.isMediumCorrect
                          ? '세포 성장 중'
                          : '⚠ 세포 사멸 위험',
                  style: TextStyle(
                    color: cellDead
                        ? Colors.red
                        : session.isMediumCorrect
                            ? Colors.tealAccent
                            : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '현재 세포 수: ${formatCells(cellDead ? 0 : session.isMediumCorrect ? currentCells : totalCells * 0.5)}',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            cell.name,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _CellParticleDisplay extends StatefulWidget {
  final Duration elapsed;
  final bool mediumCorrect;
  const _CellParticleDisplay(
      {required this.elapsed, required this.mediumCorrect});

  @override
  State<_CellParticleDisplay> createState() =>
      _CellParticleDisplayState();
}

class _CellParticleDisplayState extends State<_CellParticleDisplay>
    with TickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (_, __) => SizedBox(
        height: 60,
        child: CustomPaint(
          painter: _CellPainter(
            progress: _animController.value,
            mediumCorrect: widget.mediumCorrect,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _CellPainter extends CustomPainter {
  final double progress;
  final bool mediumCorrect;
  static final _rng = Random(42);
  static List<Offset> _positions = [];
  static bool _initialized = false;

  _CellPainter({required this.progress, required this.mediumCorrect}) {
    if (!_initialized) {
      _positions = List.generate(
          12, (_) => Offset(_rng.nextDouble(), _rng.nextDouble()));
      _initialized = true;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _positions.length; i++) {
      final offset = (progress + i / _positions.length) % 1.0;
      final x = _positions[i].dx * size.width;
      final y = _positions[i].dy * size.height;
      final radius = mediumCorrect
          ? 4.0 + sin(offset * 2 * pi) * 2
          : 3.0 - offset * 1.5;

      paint.color = mediumCorrect
          ? Color.lerp(Colors.tealAccent, Colors.cyan, sin(offset * pi))!
              .withValues(alpha: 0.6)
          : Colors.red.withValues(alpha: 0.4 - offset * 0.3);

      if (radius > 0) {
        canvas.drawCircle(Offset(x, y), radius, paint);
        if (mediumCorrect && offset > 0.8) {
          canvas.drawCircle(
              Offset(x + 8, y + 3),
              radius * 0.7,
              paint..color = Colors.cyan.withValues(alpha: 0.4));
        }
      }
    }
  }

  @override
  bool shouldRepaint(_CellPainter old) => old.progress != progress;
}
