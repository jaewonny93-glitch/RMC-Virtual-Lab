import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../models/cell_model.dart';
import '../../models/lab_model.dart';
import '../../models/user_model.dart';
import '../main_screen.dart';
import 'clean_bench_screen.dart';

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
    final session = context.read<ExperimentSession>();
    final confluence = _getConfluence(session);
    final cell = session.cellTypeId != null
        ? CellDatabase.findById(session.cellTypeId!)
        : null;

    // 성장곡선 기반 현재 총 세포 수 추정
    final simulatedHours = _elapsed.inSeconds.toDouble();
    final doublings = cell != null
        ? simulatedHours / cell.doublingTimeHours
        : 0.0;
    final seededCells =
        session.wells.fold(0.0, (sum, w) => sum + w.cellCount);
    final initialCells = seededCells > 0 ? seededCells : 500000.0;
    final estimatedTotalCells =
        initialCells * pow(2, doublings.clamp(0, 20));

    showDialog(
      context: context,
      builder: (ctx) => SubcultureDialog(
        onComplete: (result) {
          Navigator.pop(ctx);
          _showCentrifugeDialog(result, confluence, estimatedTotalCells);
        },
      ),
    );
  }

  // ── 원심분리 다이얼로그 ─────────────────────────────────────
  void _showCentrifugeDialog(SubcultureResult subcultureResult,
      double confluence, double estimatedTotalCells) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => CentrifugeDialog(
        subcultureResult: subcultureResult,
        onComplete: (resuspensionVolume, rpm, xg, duration, temp) {
          Navigator.pop(ctx);
          _showCellCountDialog(resuspensionVolume, subcultureResult,
              confluence, estimatedTotalCells, rpm, xg, duration, temp);
        },
      ),
    );
  }

  // ── 세포 계수 다이얼로그 ────────────────────────────────────
  void _showCellCountDialog(
      double resuspensionVolume,
      SubcultureResult subcultureResult,
      double confluence,
      double estimatedTotalCells,
      String rpm,
      String xg,
      String duration,
      String temp) {
    if (!mounted) return;
    final session = context.read<ExperimentSession>();
    final cell = session.cellTypeId != null
        ? CellDatabase.findById(session.cellTypeId!)
        : null;

    // 성장곡선 기반 예측 세포 농도 계산
    // 총 세포를 재현탁 볼륨으로 나눔
    final predictedCellsPerML =
        estimatedTotalCells / (resuspensionVolume / 1000.0);
    final predictedViability =
        session.isMediumCorrect ? 92.0 + (Random().nextDouble() * 5) : 55.0;

    showDialog(
      context: context,
      builder: (ctx) => CellCountDialog(
        resuspensionVolumeUL: resuspensionVolume,
        cellName: cell?.name ?? 'Unknown',
        predictedCellsPerML: predictedCellsPerML,
        predictedViability: predictedViability,
        onComplete: (result) {
          Navigator.pop(ctx);
          // 세션에 모든 결과 저장
          session.lastPassageConfluence = confluence;
          session.lastPassageTotalCells = estimatedTotalCells;
          session.lastPassageReagent = subcultureResult.reagent;
          session.lastCentrifugeRpm = rpm;
          session.lastCentrifugeXg = xg;
          session.lastCentrifugeDuration = duration;
          session.lastCentrifugeTemp = temp;
          session.lastCellCountCellsPerML = result.cellsPerML;
          session.lastCellCountViability = result.viability;
          session.lastCellCountRemainingUL = result.remainingVolumeUL;

          // 히스토리 업데이트 (마지막 레코드에 계대배양 정보 추가)
          final appState = context.read<AppState>();
          if (appState.history.isNotEmpty) {
            final old = appState.history.first;
            final updated = ExperimentRecord(
              id: old.id,
              cellTypeId: old.cellTypeId,
              cellTypeName: old.cellTypeName,
              dishTypeId: old.dishTypeId,
              dishTypeName: old.dishTypeName,
              medium: old.medium,
              mediumCorrect: old.mediumCorrect,
              startTime: old.startTime,
              endTime: DateTime.now(),
              wells: old.wells,
              savedToData: old.savedToData,
              deepFreezerTime: session.deepFreezerTime,
              subcultureConfluence: confluence,
              subcultureTotalCells: estimatedTotalCells,
              subcultureReagent: subcultureResult.reagent,
              centrifugeRpm: rpm,
              centrifugeXg: xg,
              centrifugeDuration: duration,
              centrifugeTemp: temp,
              cellCountCellsPerML: result.cellsPerML,
              cellCountViability: result.viability,
              cellCountRemainingUL: result.remainingVolumeUL,
            );
            appState.updateHistoryRecord(updated);
          }

          // CleanBench로 이동 (잔여볼륨 + 예측 세포 농도 전달)
          session.vialRemainingUL = result.remainingVolumeUL;
          session.vialInitialCells =
              result.cellsPerML * 1e6 * (result.remainingVolumeUL / 1000);
          session.isInIncubator = false;
          session.incubatorStartTime = null;

          Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const _PassageCleanBenchScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 800),
            ),
            (route) => false,
          );
        },
      ),
    );
  }

  // ── 합류도 계산 ────────────────────────────────────────────
  // dish 면적과 세포 크기(doublingTime)를 기반으로 최대 수용 세포 수를 계산하고,
  // logistic curve 로 90%/95%+ 합류도를 판별합니다.
  double _getConfluence(ExperimentSession session) {
    if (session.incubatorStartTime == null) return 0;
    final cell = session.cellTypeId != null
        ? CellDatabase.findById(session.cellTypeId!)
        : null;
    if (cell == null) return 0;

    // 시뮬레이션: 1초 real time = 1시간 배양
    final simulatedHours = _elapsed.inSeconds.toDouble();
    final doublings = simulatedHours / cell.doublingTimeHours;

    // dish 면적 파싱: "25 cm²" → 25.0 (well-plate: "3.8 cm²/well" → per well)
    final dish = session.dishTypeId != null
        ? DishDatabase.findById(session.dishTypeId!)
        : null;
    final surfaceArea = _parseSurfaceAreaCm2(
        dish?.surfaceAreaCm2 ?? '25 cm²', dish?.wellCount ?? 1);

    // 세포 크기 기반 최대 수용 세포 수
    // 표준 부착세포: 직경 15 µm → 단면적 ≈ 177 µm²
    // packing efficiency 0.85 (육각밀집 이론값)
    const cellAreaUM2 = 177.0;
    const packingEff = 0.85;
    final maxCells = (surfaceArea * 1e8 * packingEff) / cellAreaUM2;

    // 초기 파종 세포 수 (모든 well 합산)
    final seededCells =
        session.wells.fold(0.0, (sum, w) => sum + w.cellCount);
    final initialCells = seededCells > 0 ? seededCells : 500000.0;

    // 90% 도달에 필요한 doubling 횟수
    final ratio90 = maxCells * 0.90 / initialCells;
    final doublings90 =
        ratio90 > 1 ? (log(ratio90) / log(2)) : 2.0;

    // Logistic sigmoid: 90% 기준 중심, 기울기 k
    const k = 1.2;
    final raw = 100.0 / (1 + exp(-k * (doublings - doublings90)));
    return raw.clamp(0.0, 100.0);
  }

  /// "25 cm²" / "3.8 cm²/well" → double (per well 적용)
  double _parseSurfaceAreaCm2(String s, int wellCount) {
    // "3.8 cm²/well" → per well
    final perWell = s.contains('/well');
    final numStr = s.replaceAll(RegExp(r'[^0-9.]'), '');
    final val = double.tryParse(numStr) ?? 25.0;
    if (perWell) return val; // 이미 well 당 값
    // 전체 면적이면 well 수로 나눔 (well-plate 아닌 경우 1)
    return wellCount > 1 ? val / wellCount : val;
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ExperimentSession>();
    final cell = session.cellTypeId != null
        ? CellDatabase.findById(session.cellTypeId!)
        : null;
    final confluence = _getConfluence(session);
    final needsPassage = confluence >= 90 && !_cellDead;
    final isOvergrowth = confluence >= 95 && !_cellDead;

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
                                !_cellDead,
                            confluence: confluence,
                            isOvergrowth: isOvergrowth),
                        const SizedBox(height: 16),
                        // 액션 버튼들
                        _buildActionButtons(
                            context, needsPassage, isOvergrowth, session),
                        const SizedBox(height: 12),
                        // 진행 중 배양 세션 목록
                        _buildAllSessionsList(context),
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
    final isOvergrowth = confluence >= 95;
    final color = confluence < 60
        ? Colors.tealAccent
        : confluence < 90
            ? Colors.amber
            : isOvergrowth
                ? Colors.redAccent
                : Colors.orange;
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
              value: (confluence / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 10,
            ),
          ),
          // 단계 마커
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _confluenceMarker('0%', Colors.white24),
              _confluenceMarker('50%', Colors.tealAccent),
              _confluenceMarker('90%', Colors.amber),
              _confluenceMarker('95%+', Colors.redAccent),
            ],
          ),
          if (isOvergrowth) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border:
                    Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.dangerous, color: Colors.redAccent, size: 14),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Overgrowth 감지 — 세포 형태 이상 · 사멸 트렌드 전환',
                      style:
                          TextStyle(color: Colors.redAccent, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (needsPassage) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '계대배양 필요 — 세포가 dish 면적의 90% 이상 도달했습니다.',
                style: TextStyle(
                    color: Colors.amber.withValues(alpha: 0.9),
                    fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _confluenceMarker(String label, Color color) {
    return Text(label, style: TextStyle(color: color, fontSize: 9));
  }

  Widget _buildActionButtons(
      BuildContext context, bool needsPassage, bool isOvergrowth, ExperimentSession session) {
    return Column(
      children: [
        // Overgrowth 경고
        if (isOvergrowth) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6)),
            ),
            child: const Row(
              children: [
                Icon(Icons.dangerous, color: Colors.redAccent, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠ Overgrowth (95%+) — 세포 형태 이상 발생, 즉시 계대배양 필요!',
                    style: TextStyle(color: Colors.redAccent, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
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

  // ── 진행 중 배양 세션 목록 ──────────────────────────────────
  Widget _buildAllSessionsList(BuildContext context) {
    final appState = context.watch<AppState>();
    final sessions = appState.activeSessions;
    if (sessions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '인큐베이터 배양 진행 중',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.tealAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${sessions.length}',
                style: const TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...sessions.map((s) => _IncubatorSessionTile(session: s)),
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
  final void Function(double resuspensionVolumeUL, String rpm, String xg,
      String duration, String temp) onComplete;
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
                    widget.onComplete(
                      vol,
                      '${_currentRpm.toInt()} RPM',
                      '${_currentXg.toStringAsFixed(0)} ×g',
                      '${_durationMinutes}m ${_durationSeconds}s',
                      '${_temperature.toInt()}°C',
                    );
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
  final double totalCount;
  final double viableCount;
  final double viability;
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
//  CellCountDialog  (성장곡선 기반 예측 세포 계수 + Hemocytometer 시각화)
// ─────────────────────────────────────────────────────────────
class CellCountDialog extends StatefulWidget {
  final double resuspensionVolumeUL;
  final String cellName;
  final double predictedCellsPerML;    // 성장곡선 기반 예측값 (cells/mL)
  final double predictedViability;     // 예측 생존율 (%)
  final void Function(CellCountResult) onComplete;
  const CellCountDialog({
    super.key,
    required this.resuspensionVolumeUL,
    required this.cellName,
    required this.predictedCellsPerML,
    required this.predictedViability,
    required this.onComplete,
  });

  @override
  State<CellCountDialog> createState() => _CellCountDialogState();
}

class _CellCountDialogState extends State<CellCountDialog> {
  // 세포계수에 사용한 10µL 차감
  static const double _sampledUL = 10.0;
  bool _confirmed = false;

  late CellCountResult _result;

  @override
  void initState() {
    super.initState();
    _calcResult();
  }

  void _calcResult() {
    // 성장곡선 기반 예측값을 그대로 사용
    final cellsPerML = widget.predictedCellsPerML; // cells/mL
    final viability = widget.predictedViability.clamp(0.0, 100.0);
    final remaining =
        (widget.resuspensionVolumeUL - _sampledUL).clamp(0.0, double.infinity);
    final totalCells = cellsPerML * (widget.resuspensionVolumeUL / 1000.0);
    final viableCells = totalCells * (viability / 100);

    _result = CellCountResult(
      totalCount: totalCells,
      viableCount: viableCells,
      viability: viability,
      cellsPerML: cellsPerML / 1e6,
      remainingVolumeUL: remaining,
    );
  }

  // Hemocytometer 그리드에 표시할 예측 세포 수 (Q당)
  int get _predictedPerQuadrant {
    // hemocytometer 한 사분면 부피 = 0.1 µL
    // cells per quadrant = (cells/mL) × 0.0001 mL
    final val = (widget.predictedCellsPerML * 0.0001).round();
    return val.clamp(1, 999);
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _result.remainingVolumeUL;
    final totalCellsInRemaining =
        _result.cellsPerML * (remaining / 1000);

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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.green.withValues(alpha: 0.5)),
                  ),
                  child: const Text('세포 계수 (Hemocytometer)',
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
            const SizedBox(height: 14),

            // Trypan Blue 안내
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
                      Text('Trypan Blue 1:1 희석 완료',
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
                    '• 생존 세포: 무색, 사멸 세포: 파란색',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hemocytometer 시각화
            const Text('Hemocytometer 계산 결과',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              '성장 곡선 기반 예측값 (시작 세포 수 × 2^doublings)',
              style: TextStyle(
                  color: Colors.white38.withValues(alpha: 0.8),
                  fontSize: 10),
            ),
            const SizedBox(height: 10),

            // Hemocytometer 그리드
            _buildHemocytometerGrid(),
            const SizedBox(height: 14),

            // 결과 표시
            Container(
              padding: const EdgeInsets.all(14),
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
                  const SizedBox(height: 10),
                  _ResultRow(
                    label: '세포 농도',
                    value:
                        '${_result.cellsPerML.toStringAsFixed(3)} × 10⁶ cells/mL',
                  ),
                  _ResultRow(
                    label: '생존율 (Viability)',
                    value:
                        '${_result.viability.toStringAsFixed(1)}%',
                    valueColor: _result.viability >= 90
                        ? Colors.tealAccent
                        : _result.viability >= 70
                            ? Colors.amber
                            : Colors.redAccent,
                  ),
                  _ResultRow(
                    label: '잔여 현탁액',
                    value:
                        '${remaining.toStringAsFixed(0)} µL (−${_sampledUL.toInt()} µL)',
                  ),
                  _ResultRow(
                    label: '잔여액 총 세포',
                    value:
                        '${(totalCellsInRemaining / 1e6).toStringAsFixed(3)} × 10⁶',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 확인 후 CleanBench로 이동
            if (!_confirmed) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  '계산이 완료되었습니다.\n"계대배양 진행" 을 누르면 잔여 세포 현탁액으로 CleanBench에서 새 배양을 시작합니다.',
                  style: TextStyle(
                      color: Colors.amber, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  icon: const Icon(Icons.science),
                  label: const Text('계대배양 진행 → CleanBench',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    setState(() => _confirmed = true);
                    widget.onComplete(_result);
                  },
                ),
              ),
            ] else ...[
              const Center(
                child: CircularProgressIndicator(
                    color: Colors.tealAccent),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHemocytometerGrid() {
    final viable = _predictedPerQuadrant;
    final dead = (viable * (1 - widget.predictedViability / 100) /
            (widget.predictedViability / 100))
        .round()
        .clamp(0, 999);

    final quadrantData = List.generate(
        4,
        (i) => {
              'viable': viable + (i == 1 ? 1 : i == 3 ? -1 : 0),
              'dead': dead + (i == 2 ? 1 : 0),
            });

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // 레이블
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              'Hemocytometer — 4사분면 예측 세포 수',
              style: TextStyle(
                  color: Colors.white54, fontSize: 11),
            ),
          ),
          // 2×2 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: 4,
            itemBuilder: (ctx, i) {
              final v = quadrantData[i]['viable']!;
              final d = quadrantData[i]['dead']!;
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      Colors.tealAccent.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.tealAccent
                          .withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Q${i + 1}',
                        style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10)),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text('$v',
                            style: const TextStyle(
                                color: Colors.tealAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const Text(' / ',
                            style: TextStyle(
                                color: Colors.white24,
                                fontSize: 12)),
                        Text('$d',
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14)),
                      ],
                    ),
                    const Text('생존 / 사멸',
                        style: TextStyle(
                            color: Colors.white24,
                            fontSize: 9)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            '평균 생존 세포: $viable cells/quadrant  ×  10⁴  ×  2 (희석) = '
            '${(viable * 10000 * 2 / 1e6).toStringAsFixed(3)} × 10⁶ cells/mL',
            style: const TextStyle(
                color: Colors.white54, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
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

    // Overgrowth 여부 판단 (대략 doublings 대비 95% confluence 추정)
    // 간단히: doublings > doublings90 + 1 이면 overgrowth
    final isOvergrowth = doublings > 5.5; // 근사값

    double currentCells;
    if (cellDead) {
      currentCells = 0;
    } else if (isOvergrowth && session.isMediumCorrect) {
      // Overgrowth: 최대 세포 수에서 감소 시작 (사멸 트렌드)
      final overgrowthFactor = doublings - 5.5;
      final maxCells = totalCells * pow(2, 5.5);
      currentCells = maxCells * exp(-0.3 * overgrowthFactor);
    } else if (!session.isMediumCorrect) {
      currentCells = totalCells * 0.5;
    } else {
      currentCells = totalCells * pow(2, doublings);
    }

    String formatCells(double n) {
      if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(2)}×10⁹';
      if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(2)}×10⁶';
      if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(2)}×10³';
      return n.toStringAsFixed(0);
    }

    final statusLabel = cellDead
        ? '✖ 세포 사멸'
        : isOvergrowth && session.isMediumCorrect
            ? '⚠ Overgrowth — 사멸 트렌드'
            : session.isMediumCorrect
                ? '세포 성장 중'
                : '⚠ 세포 사멸 위험';

    final statusColor = cellDead
        ? Colors.red
        : isOvergrowth && session.isMediumCorrect
            ? Colors.redAccent
            : session.isMediumCorrect
                ? Colors.tealAccent
                : Colors.redAccent;

    final statusIcon = cellDead
        ? Icons.dangerous
        : isOvergrowth && session.isMediumCorrect
            ? Icons.trending_down
            : session.isMediumCorrect
                ? Icons.trending_up
                : Icons.trending_down;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '현재 세포 수: ${formatCells(currentCells)}',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
                if (isOvergrowth && session.isMediumCorrect && !cellDead)
                  const Text(
                    '밀집 → 접촉억제 → 세포 수 감소 중',
                    style: TextStyle(
                        color: Colors.redAccent, fontSize: 10),
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
  final double confluence;
  final bool isOvergrowth;
  const _CellParticleDisplay({
    required this.elapsed,
    required this.mediumCorrect,
    this.confluence = 0,
    this.isOvergrowth = false,
  });

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
    // Overgrowth 시 라벨 표시
    final label = widget.isOvergrowth
        ? 'Overgrowth — 세포 형태 이상'
        : widget.confluence >= 90
            ? '90%+ Confluence'
            : null;

    return Column(
      children: [
        AnimatedBuilder(
          animation: _animController,
          builder: (_, __) => Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.isOvergrowth
                    ? Colors.redAccent.withValues(alpha: 0.5)
                    : widget.mediumCorrect
                        ? Colors.tealAccent.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomPaint(
                painter: _CellPainter(
                  progress: _animController.value,
                  mediumCorrect: widget.mediumCorrect,
                  confluence: widget.confluence,
                  isOvergrowth: widget.isOvergrowth,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: widget.isOvergrowth
                  ? Colors.redAccent
                  : Colors.amber,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

class _CellPainter extends CustomPainter {
  final double progress;
  final bool mediumCorrect;
  final double confluence;
  final bool isOvergrowth;
  static final _rng = Random(42);
  static List<Offset> _positions = [];
  static bool _initialized = false;

  _CellPainter({
    required this.progress,
    required this.mediumCorrect,
    this.confluence = 0,
    this.isOvergrowth = false,
  }) {
    if (!_initialized) {
      _positions = List.generate(
          30, (_) => Offset(_rng.nextDouble(), _rng.nextDouble()));
      _initialized = true;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 합류도에 따라 표시할 세포 수 결정
    final activeCells = ((confluence / 100) * _positions.length)
        .round()
        .clamp(1, _positions.length);

    for (int i = 0; i < activeCells; i++) {
      final offset = (progress + i / _positions.length) % 1.0;
      final x = _positions[i].dx * size.width;
      final y = _positions[i].dy * size.height;

      double radius;
      Color color;

      if (isOvergrowth) {
        // Overgrowth: 세포가 비정상적으로 커지고 일부는 죽어가는 형태
        radius = 6.0 + sin(offset * pi) * 4 - (i % 3 == 0 ? 3 : 0);
        // 일부는 노란/빨간 불규칙 형태
        color = i % 4 == 0
            ? Colors.yellow.withValues(alpha: 0.6)
            : i % 3 == 0
                ? Colors.redAccent.withValues(alpha: 0.5)
                : Colors.orange.withValues(alpha: 0.4);
      } else if (!mediumCorrect) {
        // 사멸: 세포가 쪼그라듦
        radius = (3.0 - offset * 1.5).clamp(0.5, 3.0);
        color = Colors.red.withValues(alpha: 0.4 - offset * 0.3);
      } else {
        // 정상 성장
        radius = 3.0 + sin(offset * 2 * pi) * 1.5;
        color = Color.lerp(Colors.tealAccent, Colors.cyan,
                sin(offset * pi))!
            .withValues(alpha: 0.7);
      }

      paint.color = color;
      if (radius > 0) {
        canvas.drawCircle(Offset(x, y), radius, paint);
        // 분열 중인 세포 (합류도 < 90%일 때 정상 성장)
        if (mediumCorrect && !isOvergrowth && offset > 0.8) {
          canvas.drawCircle(
            Offset(x + radius * 1.5, y),
            radius * 0.6,
            paint
              ..color =
                  Colors.cyan.withValues(alpha: 0.4),
          );
        }
        // Overgrowth: 파편 표시
        if (isOvergrowth && i % 5 == 0) {
          paint.color =
              Colors.yellow.withValues(alpha: 0.3);
          canvas.drawCircle(
              Offset(x + 8, y + 4), radius * 0.3, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_CellPainter old) =>
      old.progress != progress ||
      old.confluence != confluence ||
      old.isOvergrowth != isOvergrowth;
}

// ─────────────────────────────────────────────────────────────
//  _IncubatorSessionTile  (인큐베이터 화면 배양 세션 항목)
// ─────────────────────────────────────────────────────────────
class _IncubatorSessionTile extends StatelessWidget {
  final CultureSession session;
  const _IncubatorSessionTile({required this.session});

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _IncubatorSessionDetailSheet(session: session),
    );
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = session.elapsed;
    final h = elapsed.inHours;
    final m = elapsed.inMinutes.remainder(60);
    final s = elapsed.inSeconds.remainder(60);

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.teal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.tealAccent.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.thermostat,
                color: Colors.tealAccent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.cellTypeName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                  Text(
                    '${session.dishTypeName}  |  ${session.medium}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${h}h ${m}m ${s}s',
                  style: const TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  '탭하여 상세 보기',
                  style: TextStyle(
                      color: Colors.white24, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _IncubatorSessionDetailSheet  (배양 조건 상세 바텀시트)
// ─────────────────────────────────────────────────────────────
class _IncubatorSessionDetailSheet extends StatefulWidget {
  final CultureSession session;
  const _IncubatorSessionDetailSheet({required this.session});

  @override
  State<_IncubatorSessionDetailSheet> createState() =>
      _IncubatorSessionDetailSheetState();
}

class _IncubatorSessionDetailSheetState
    extends State<_IncubatorSessionDetailSheet> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _elapsed = widget.session.elapsed;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsed = widget.session.elapsed);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes.remainder(60);
    final s = _elapsed.inSeconds.remainder(60);
    final startStr =
        '${widget.session.startTime.year}/'
        '${widget.session.startTime.month.toString().padLeft(2, '0')}/'
        '${widget.session.startTime.day.toString().padLeft(2, '0')} '
        '${widget.session.startTime.hour.toString().padLeft(2, '0')}:'
        '${widget.session.startTime.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 뱃지
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.tealAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '인큐베이터 배양 조건',
              style: TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.session.cellTypeName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          Text(
            widget.session.dishTypeName,
            style: const TextStyle(
                color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white12),
          const SizedBox(height: 10),
          // 실시간 경과 시간
          _DetailRow('경과 시간', '${h}h ${m}m ${s}s'),
          _DetailRow('배양 시작', startStr),
          _DetailRow('배양액', widget.session.medium),
          _DetailRow('배지 적합성',
              widget.session.mediumCorrect ? '✅ 적합' : '❌ 부적합'),
          const Divider(color: Colors.white12, height: 20),
          // 환경 조건
          _DetailRow('온도', '${widget.session.temp}°C'),
          _DetailRow('CO₂ 농도', '${widget.session.co2}%'),
          _DetailRow('습도', '${widget.session.humidity}%'),
          const Divider(color: Colors.white12, height: 20),
          // 세포 정보
          _DetailRow('파종 Well 수',
              '${widget.session.seededWellCount}개'),
          _DetailRow(
            '초기 세포 수',
            '${(widget.session.totalCellCount / 1000000).toStringAsFixed(2)} × 10⁶ cells',
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          // 세포 폐기 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                foregroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.delete_forever, size: 18),
              label: const Text('세포 폐기 (배양 종료)'),
              onPressed: () => _confirmDelete(context),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A0A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.red, width: 1.5)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.redAccent, size: 24),
            SizedBox(width: 8),
            Text('세포 폐기 확인',
                style: TextStyle(color: Colors.redAccent, fontSize: 15)),
          ],
        ),
        content: Text(
          '${widget.session.cellTypeName} 배양을 종료하고 세포를 폐기합니까?\n이 작업은 되돌릴 수 없습니다.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            onPressed: () async {
              final appState = context.read<AppState>();
              await appState.removeCultureSession(widget.session.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('폐기 확인',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _PassageCleanBenchScreen  (계대배양 후 CleanBench 복귀 래퍼)
//  - 잔여 볼륨 / 예측 세포 수가 ExperimentSession에 이미 저장됨
//  - CleanBenchScreen의 step 을 4(세포 분주)로 직접 열기
// ─────────────────────────────────────────────────────────────
class _PassageCleanBenchScreen extends StatelessWidget {
  const _PassageCleanBenchScreen();

  @override
  Widget build(BuildContext context) {
    return const CleanBenchScreen();
  }
}
