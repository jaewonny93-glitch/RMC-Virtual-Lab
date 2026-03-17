import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/cell_model.dart';
import '../models/lab_model.dart';
import '../models/user_model.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});
  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  @override
  Widget build(BuildContext context) {
    final session = context.watch<ExperimentSession>();
    final appState = context.watch<AppState>();

    if (!session.isInIncubator || session.cellTypeId == null) {
      return _buildEmptyState();
    }

    final cell = CellDatabase.findById(session.cellTypeId!);
    if (cell == null) return _buildEmptyState();

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A1628), Color(0xFF050D1A)],
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(cell, session),
                const SizedBox(height: 16),
                _buildGrowthCurveCard(cell, session),
                const SizedBox(height: 16),
                _buildCellMorphologyCard(cell, session),
                const SizedBox(height: 16),
                _buildStatsCard(cell, session),
                const SizedBox(height: 16),
                _buildSaveButton(context, session, cell, appState),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1628), Color(0xFF050D1A)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, color: Colors.white12, size: 80),
            SizedBox(height: 16),
            Text('배양 중인 세포가 없습니다',
                style: TextStyle(color: Colors.white38, fontSize: 16)),
            SizedBox(height: 8),
            Text('Lab 탭에서 세포 배양을 시작하세요',
                style: TextStyle(color: Colors.white24, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CellType cell, ExperimentSession session) {
    final elapsed = session.incubatorStartTime != null
        ? DateTime.now().difference(session.incubatorStartTime!)
        : Duration.zero;
    final h = elapsed.inHours;
    final m = elapsed.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
              border: Border.all(color: const Color(0xFF00E5FF)),
            ),
            child: const Icon(Icons.biotech,
                color: Color(0xFF00E5FF), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cell.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(cell.scientificName,
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('배양 경과',
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
              Text('${h}h ${m}m',
                  style: const TextStyle(
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCurveCard(CellType cell, ExperimentSession session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart, color: Color(0xFF00E5FF), size: 18),
              SizedBox(width: 8),
              Text('성장 곡선',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: GrowthCurvePainter(
                cell: cell,
                session: session,
                mediumCorrect: session.isMediumCorrect,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(
                  color: session.isMediumCorrect
                      ? Colors.tealAccent
                      : Colors.redAccent,
                  label: session.isMediumCorrect ? '성장 곡선' : '사멸 곡선'),
              const SizedBox(width: 16),
              const _LegendDot(
                  color: Color(0xFF00E5FF), label: '현재 위치'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCellMorphologyCard(
      CellType cell, ExperimentSession session) {
    final elapsed = session.incubatorStartTime != null
        ? DateTime.now().difference(session.incubatorStartTime!)
        : Duration.zero;
    final doublings = elapsed.inSeconds / (cell.doublingTimeHours * 3600);
    final confluency =
        session.isMediumCorrect ? min(95.0, doublings * 15) : max(5.0, 50 - doublings * 10);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.visibility, color: Color(0xFF00E5FF), size: 18),
              SizedBox(width: 8),
              Text('세포 형태 (현미경 시뮬레이션)',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // 현미경 뷰
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  border: Border.all(
                      color: Colors.white38, width: 3),
                ),
                child: ClipOval(
                  child: CustomPaint(
                    painter: MicroscopePainter(
                      confluency: confluency / 100,
                      mediumCorrect: session.isMediumCorrect,
                      cellCategory: cell.category,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MorphologyInfo('세포 상태',
                        session.isMediumCorrect ? '건강' : '사멸'),
                    _MorphologyInfo('Confluency',
                        '${confluency.toStringAsFixed(1)}%'),
                    _MorphologyInfo(
                        '형태',
                        _getCellMorphology(cell.category)),
                    _MorphologyInfo('분열 횟수',
                        '${doublings.toStringAsFixed(2)}회'),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: confluency / 100,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation(
                          session.isMediumCorrect
                              ? Colors.tealAccent
                              : Colors.redAccent,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Confluency ${confluency.toStringAsFixed(0)}%',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(CellType cell, ExperimentSession session) {
    final elapsed = session.incubatorStartTime != null
        ? DateTime.now().difference(session.incubatorStartTime!)
        : Duration.zero;
    final doublings = elapsed.inSeconds / (cell.doublingTimeHours * 3600);
    final totalSeed =
        session.wells.fold<double>(0, (s, w) => s + w.cellCount);
    final current = session.isMediumCorrect
        ? totalSeed * pow(2, doublings)
        : totalSeed * pow(0.7, doublings);

    String fmt(double n) {
      if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(2)}×10⁹';
      if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(2)}×10⁶';
      if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(1)}×10³';
      return n.toStringAsFixed(0);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Color(0xFF00E5FF), size: 18),
              SizedBox(width: 8),
              Text('배양 통계',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatCard('초기 세포 수', fmt(totalSeed), Colors.white54),
              const SizedBox(width: 8),
              _StatCard('현재 세포 수', fmt(current),
                  session.isMediumCorrect ? Colors.tealAccent : Colors.redAccent),
              const SizedBox(width: 8),
              _StatCard('더블링 타임', '${cell.doublingTimeHours}h', const Color(0xFF00E5FF)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatCard('분열 횟수', '${doublings.toStringAsFixed(2)}회',
                  Colors.orangeAccent),
              const SizedBox(width: 8),
              _StatCard('배지 적합성',
                  session.isMediumCorrect ? '✅ 적합' : '❌ 부적합',
                  session.isMediumCorrect ? Colors.greenAccent : Colors.redAccent),
              const SizedBox(width: 8),
              _StatCard('Wells', '${session.wells.where((w) => w.hasCell).length}개', Colors.purpleAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, ExperimentSession session,
      CellType cell, AppState appState) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.save),
      label: const Text('현재 데이터 저장 (Data 탭에 저장)',
          style: TextStyle(fontWeight: FontWeight.bold)),
      onPressed: () {
        final elapsed = session.incubatorStartTime != null
            ? DateTime.now().difference(session.incubatorStartTime!)
            : Duration.zero;
        final record = ExperimentRecord(
          id: 'data_${DateTime.now().millisecondsSinceEpoch}',
          cellTypeId: cell.id,
          cellTypeName: cell.name,
          dishTypeId: session.dishTypeId ?? '-',
          dishTypeName: session.dishTypeId ?? '-',
          medium: session.selectedMedium ?? '-',
          mediumCorrect: session.isMediumCorrect,
          startTime: session.incubatorStartTime ?? DateTime.now(),
          endTime: DateTime.now(),
          wells: session.wells
              .where((w) => w.hasCell)
              .map((w) => WellRecord(
                    index: w.wellIndex,
                    cellCount: w.cellCount,
                    mediumVolume: w.mediumVolume,
                    cellVolume: w.cellVolume,
                    mediumName: w.mediumName,
                  ))
              .toList(),
          savedToData: true,
        );
        appState.saveToData(record);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data 탭에 저장되었습니다!'),
            backgroundColor: Colors.teal,
          ),
        );
      },
    );
  }

  String _getCellMorphology(String category) {
    switch (category) {
      case '암세포주':
        return '상피형 / 방추형';
      case '줄기세포':
        return '다각형 / 군집형';
      case '신경세포주':
        return '신경돌기 방사형';
      case '동물세포주':
        return '섬유아세포형';
      default:
        return '방추형';
    }
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      );
}

class _MorphologyInfo extends StatelessWidget {
  final String label;
  final String value;
  const _MorphologyInfo(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
                width: 70,
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11))),
            Text(value,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 11)),
          ],
        ),
      );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 9),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

// ── 성장 곡선 Custom Painter ──────────────────────────
class GrowthCurvePainter extends CustomPainter {
  final CellType cell;
  final ExperimentSession session;
  final bool mediumCorrect;

  GrowthCurvePainter(
      {required this.cell,
      required this.session,
      required this.mediumCorrect});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;
    final axisPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    final curvePaint = Paint()
      ..color = mediumCorrect ? Colors.tealAccent : Colors.redAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;

    final elapsed = session.incubatorStartTime != null
        ? DateTime.now().difference(session.incubatorStartTime!)
        : Duration.zero;

    // 그리드
    for (int i = 1; i < 5; i++) {
      final x = size.width * i / 5;
      final y = size.height * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 축
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), axisPaint);
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), axisPaint);

    // 곡선: 현재 경과 시간까지만 실시간으로 그림
    final maxHours = max(cell.doublingTimeHours * 3, 48.0);
    // 현재 경과 시간 (실시간 1:1)
    final elapsedHours = elapsed.inSeconds / 3600.0;
    // 예측 배경선: 전체 범위를 희미하게 표시
    final bgPath = Path();
    bool bgFirst = true;
    for (int i = 0; i <= 100; i++) {
      final t = i / 100.0;
      final hours = t * maxHours;
      final doublings = hours / cell.doublingTimeHours;
      final cellCount = mediumCorrect
          ? pow(2, doublings).toDouble()
          : pow(0.7, doublings).toDouble();
      final logVal = mediumCorrect
          ? log(cellCount) / log(pow(2, maxHours / cell.doublingTimeHours))
          : 1 - (1 - log(cellCount.clamp(0.001, 1)) / log(0.001)) * 0.8;
      final x = t * size.width;
      final y = size.height - logVal.clamp(0, 1) * size.height * 0.85;
      if (bgFirst) { bgPath.moveTo(x, y); bgFirst = false; }
      else { bgPath.lineTo(x, y); }
    }
    final bgPaint = Paint()
      ..color = (mediumCorrect ? Colors.tealAccent : Colors.redAccent)
          .withValues(alpha: 0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawPath(bgPath, bgPaint);

    // 실시간 곡선: 현재 시간까지만
    final path = Path();
    bool first = true;
    final steps = 200;
    for (int i = 0; i <= steps; i++) {
      final t = i / steps.toDouble();
      final hours = t * maxHours;
      // 현재 경과 시간 초과 시 중단
      if (hours > elapsedHours) break;
      final doublings = hours / cell.doublingTimeHours;
      final cellCount = mediumCorrect
          ? pow(2, doublings).toDouble()
          : pow(0.7, doublings).toDouble();
      final logVal = mediumCorrect
          ? log(cellCount) / log(pow(2, maxHours / cell.doublingTimeHours))
          : 1 - (1 - log(cellCount.clamp(0.001, 1)) / log(0.001)) * 0.8;

      final x = t * size.width;
      final y = size.height - logVal.clamp(0, 1) * size.height * 0.85;

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, curvePaint);

    // 현재 위치
    final curT = elapsed.inSeconds / (maxHours * 3600);
    final curX = curT.clamp(0, 1) * size.width;
    final curDoublings =
        elapsed.inSeconds / (cell.doublingTimeHours * 3600);
    final curCells = mediumCorrect
        ? pow(2, curDoublings).toDouble()
        : pow(0.7, curDoublings).toDouble();
    final curLogVal = mediumCorrect
        ? log(curCells.clamp(1, double.infinity)) /
            log(pow(2, maxHours / cell.doublingTimeHours))
        : 1 - (1 - log(curCells.clamp(0.001, 1)) / log(0.001)) * 0.8;
    final curY =
        size.height - curLogVal.clamp(0, 1) * size.height * 0.85;

    canvas.drawCircle(Offset(curX, curY), 5, dotPaint);

    // 축 레이블
    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
        text: '시간 (h)',
        style: TextStyle(color: Colors.white38, fontSize: 10));
    tp.layout();
    tp.paint(canvas, Offset(size.width - 36, size.height - 14));

    tp.text = TextSpan(
        text: '세포 수 (log)',
        style: TextStyle(color: Colors.white38, fontSize: 10));
    tp.layout();
    tp.paint(canvas, const Offset(4, 4));
  }

  @override
  bool shouldRepaint(GrowthCurvePainter old) => true;
}

// ── 현미경 시뮬레이션 Painter ──────────────────────────
class MicroscopePainter extends CustomPainter {
  final double confluency;
  final bool mediumCorrect;
  final String cellCategory;
  static final _rng = Random(42);
  static List<Offset>? _cellPositions;

  MicroscopePainter(
      {required this.confluency,
      required this.mediumCorrect,
      required this.cellCategory}) {
    _cellPositions ??= List.generate(
        60, (_) => Offset(_rng.nextDouble(), _rng.nextDouble()));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF1A2A1A);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final cellPaint = Paint()..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final cellCount = (confluency * 60).round();
    final positions = _cellPositions!;

    for (int i = 0; i < min(cellCount, positions.length); i++) {
      final x = positions[i].dx * size.width;
      final y = positions[i].dy * size.height;

      if (mediumCorrect) {
        cellPaint.color =
            Colors.tealAccent.withValues(alpha: 0.25);
        outlinePaint.color =
            Colors.tealAccent.withValues(alpha: 0.6);
      } else {
        cellPaint.color = Colors.red.withValues(alpha: 0.15);
        outlinePaint.color = Colors.red.withValues(alpha: 0.4);
      }

      // 세포 모양
      if (cellCategory.contains('신경')) {
        _drawNeuronCell(canvas, x, y, cellPaint, outlinePaint);
      } else if (cellCategory.contains('줄기')) {
        _drawRoundCell(canvas, x, y, cellPaint, outlinePaint);
      } else {
        _drawSpindleCell(canvas, x, y, cellPaint, outlinePaint);
      }
    }
  }

  void _drawSpindleCell(Canvas canvas, double x, double y,
      Paint fill, Paint outline) {
    final rect = Rect.fromCenter(
        center: Offset(x, y), width: 14, height: 7);
    canvas.drawOval(rect, fill);
    canvas.drawOval(rect, outline);
    // 핵
    canvas.drawCircle(Offset(x, y), 2,
        Paint()..color = Colors.tealAccent.withValues(alpha: 0.5));
  }

  void _drawRoundCell(Canvas canvas, double x, double y,
      Paint fill, Paint outline) {
    canvas.drawCircle(Offset(x, y), 6, fill);
    canvas.drawCircle(Offset(x, y), 6, outline);
    canvas.drawCircle(Offset(x, y), 2.5,
        Paint()..color = Colors.tealAccent.withValues(alpha: 0.4));
  }

  void _drawNeuronCell(Canvas canvas, double x, double y,
      Paint fill, Paint outline) {
    canvas.drawCircle(Offset(x, y), 4, fill);
    canvas.drawCircle(Offset(x, y), 4, outline);
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + cos(angle) * 8, y + sin(angle) * 8),
        outline,
      );
    }
  }

  @override
  bool shouldRepaint(MicroscopePainter old) =>
      old.confluency != confluency;
}
