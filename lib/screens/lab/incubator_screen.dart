import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../models/cell_model.dart';
import '../../models/lab_model.dart';
import '../main_screen.dart';

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
      if (mounted) {
        final session = context.read<ExperimentSession>();
        if (session.incubatorStartTime != null) {
          setState(() {
            _elapsed = DateTime.now().difference(session.incubatorStartTime!);
          });
        }
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

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ExperimentSession>();
    final cell = session.cellTypeId != null
        ? CellDatabase.findById(session.cellTypeId!)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF050D1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/incubator.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.6)),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                // 인큐베이터 시각화
                AnimatedBuilder(
                  animation: _glowAnim,
                  builder: (_, __) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Color.lerp(
                                  const Color(0xFF00E5FF),
                                  Colors.tealAccent,
                                  _glowAnim.value) ??
                              const Color(0xFF00E5FF),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF)
                              .withValues(alpha: 0.1 + _glowAnim.value * 0.2),
                          blurRadius: 20 + _glowAnim.value * 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.thermostat,
                            color: Color(0xFF00E5FF), size: 40),
                        const SizedBox(height: 8),
                        const Text('인큐베이터 배양 중',
                            style: TextStyle(
                                color: Color(0xFF00E5FF),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const Text('37°C  |  5% CO₂  |  95% Humidity',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 16),
                        // 경과 시간
                        _ElapsedTimer(elapsed: _elapsed),
                        if (cell != null) ...[
                          const SizedBox(height: 12),
                          _DoublingProgress(
                              cell: cell, elapsed: _elapsed),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (cell != null) _CellGrowthStatus(cell: cell, elapsed: _elapsed),
                const Spacer(),
                // 세포 파티클
                _CellParticleDisplay(elapsed: _elapsed, mediumCorrect: session.isMediumCorrect),
                const Spacer(),
                _buildActionButtons(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                Text('세포 성장 모니터링',
                    style: TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00E5FF)),
                foregroundColor: const Color(0xFF00E5FF),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.show_chart, size: 18),
              label: const Text('Graph 보기'),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const MainScreen()),
                (route) => false,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.home, size: 18),
              label: const Text('홈으로',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const MainScreen()),
                (route) => false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    final progress = (elapsed.inSeconds % dtSeconds) / dtSeconds;
    final doublings = elapsed.inSeconds / dtSeconds;
    final remainingS = dtSeconds - (elapsed.inSeconds % dtSeconds);
    final rH = (remainingS / 3600).floor();
    final rM = ((remainingS % 3600) / 60).floor();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('다음 분열까지',
                style: const TextStyle(
                    color: Colors.white54, fontSize: 12)),
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
  const _CellGrowthStatus({required this.cell, required this.elapsed});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ExperimentSession>();
    final totalCells =
        session.wells.fold<double>(0, (sum, w) => sum + w.cellCount);
    final doublings = elapsed.inSeconds / (cell.doublingTimeHours * 3600);
    final currentCells = totalCells * pow(2, doublings);

    String formatCells(double n) {
      if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(2)}×10⁹';
      if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(2)}×10⁶';
      if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(2)}×10³';
      return n.toStringAsFixed(0);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: session.isMediumCorrect
                ? Colors.tealAccent.withValues(alpha: 0.3)
                : Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            session.isMediumCorrect
                ? Icons.trending_up
                : Icons.trending_down,
            color: session.isMediumCorrect
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
                  session.isMediumCorrect ? '세포 성장 중' : '⚠ 세포 사멸 중',
                  style: TextStyle(
                    color: session.isMediumCorrect
                        ? Colors.tealAccent
                        : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '현재 세포 수: ${formatCells(session.isMediumCorrect ? currentCells : totalCells * 0.5)}',
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
  State<_CellParticleDisplay> createState() => _CellParticleDisplayState();
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
        height: 80,
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
  static late List<Offset> _positions;
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
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < _positions.length; i++) {
      final offset = (progress + i / _positions.length) % 1.0;
      final x = _positions[i].dx * size.width;
      final y = _positions[i].dy * size.height;
      final radius = mediumCorrect
          ? 4.0 + sin(offset * 2 * pi) * 2
          : 3.0 - offset * 1.5;

      paint.color = mediumCorrect
          ? Color.lerp(
                  Colors.tealAccent, Colors.cyan, sin(offset * pi))!
              .withValues(alpha: 0.6)
          : Colors.red.withValues(alpha: 0.4 - offset * 0.3);

      if (radius > 0) {
        canvas.drawCircle(Offset(x, y), radius, paint);
        if (mediumCorrect && offset > 0.8) {
          // 분열 시각화
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
