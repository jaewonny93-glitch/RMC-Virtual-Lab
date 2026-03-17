import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/cell_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final history = appState.history;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1628), Color(0xFF050D1A)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(history.length),
            if (appState.notices.isNotEmpty) _buildNoticesBanner(appState),
            Expanded(
              child: history.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: history.length,
                      itemBuilder: (context, i) =>
                          _HistoryCard(record: history[i], index: i),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.note_alt_outlined, color: Color(0xFF00E5FF), size: 22),
          const SizedBox(width: 8),
          const Text('실험 노트',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count건',
                style: const TextStyle(
                    color: Color(0xFF00E5FF), fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticesBanner(AppState appState) {
    final latest = appState.notices.first;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[공지] ${latest['title']}',
                  style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                Text(
                  latest['content'] as String,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, color: Colors.white12, size: 80),
          SizedBox(height: 16),
          Text('실험 노트가 없습니다',
              style: TextStyle(color: Colors.white38, fontSize: 16)),
          SizedBox(height: 8),
          Text('Lab 탭에서 실험을 진행하면 자동 저장됩니다',
              style: TextStyle(color: Colors.white24, fontSize: 13)),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ExperimentRecord record;
  final int index;
  const _HistoryCard({required this.record, required this.index});

  @override
  Widget build(BuildContext context) {
    final hasSubculture = record.subcultureConfluence != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: record.mediumCorrect
                  ? Colors.teal.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                    color: record.mediumCorrect
                        ? Colors.tealAccent
                        : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(record.cellTypeName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: record.mediumCorrect
                            ? Colors.teal.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        record.mediumCorrect ? '성장' : '사멸',
                        style: TextStyle(
                            color: record.mediumCorrect
                                ? Colors.tealAccent
                                : Colors.redAccent,
                            fontSize: 10),
                      ),
                    ),
                    if (hasSubculture) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('계대',
                            style: TextStyle(
                                color: Colors.amber, fontSize: 10)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${record.dishTypeName}  •  ${record.medium}',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  record.startTime.toString().substring(0, 16),
                  style: const TextStyle(
                      color: Colors.white24, fontSize: 10),
                ),
              ],
            ),
          ),
          // 실험노트 보기 버튼
          IconButton(
            tooltip: '실험 노트 보기',
            icon: const Icon(Icons.note_alt_outlined,
                color: Color(0xFF00E5FF), size: 20),
            onPressed: () => _showNoteDialog(context, record),
          ),
          if (record.savedToData)
            const Icon(Icons.save, color: Colors.amber, size: 16),
        ],
      ),
    );
  }

  void _showNoteDialog(BuildContext context, ExperimentRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => _ExperimentNoteDialog(record: record),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  실험 노트 다이얼로그 (이미지 내보내기)
// ─────────────────────────────────────────────────────────────
class _ExperimentNoteDialog extends StatefulWidget {
  final ExperimentRecord record;
  const _ExperimentNoteDialog({required this.record});

  @override
  State<_ExperimentNoteDialog> createState() => _ExperimentNoteDialogState();
}

class _ExperimentNoteDialogState extends State<_ExperimentNoteDialog> {
  final GlobalKey _noteKey = GlobalKey();
  bool _exporting = false;
  bool _exported = false;

  Future<void> _exportNote() async {
    setState(() {
      _exporting = true;
      _exported = false;
    });
    try {
      final boundary = _noteKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _exporting = false);
        return;
      }
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        setState(() => _exporting = false);
        return;
      }
      if (kDebugMode) {
        debugPrint('Note export: ${byteData.lengthInBytes} bytes');
      }
      setState(() {
        _exporting = false;
        _exported = true;
      });
    } catch (e) {
      setState(() => _exporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('내보내기 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0A1628),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.note_alt_outlined, color: Color(0xFF00E5FF)),
                const SizedBox(width: 8),
                const Text('실험 노트',
                    style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white38),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: Colors.white12),
            const SizedBox(height: 8),
            RepaintBoundary(
              key: _noteKey,
              child: _ExperimentNoteContent(
                record: widget.record,
                generatedAt: DateTime.now(),
              ),
            ),
            const SizedBox(height: 16),
            if (_exported)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.tealAccent.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.tealAccent, size: 16),
                    SizedBox(width: 6),
                    Text('실험 노트가 캡처되었습니다.',
                        style: TextStyle(
                            color: Colors.tealAccent, fontSize: 12)),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black),
                  icon: _exporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.black, strokeWidth: 2))
                      : const Icon(Icons.download),
                  label: Text(_exporting ? '처리 중...' : '이미지로 내보내기'),
                  onPressed: _exporting ? null : _exportNote,
                ),
              ),
            const SizedBox(height: 4),
            const Text(
              '팁: 웹에서는 스크린샷 또는 우클릭 → 이미지 저장으로도 저장 가능합니다.',
              style: TextStyle(color: Colors.white24, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  실험 노트 콘텐츠 (모든 섹션 포함)
// ─────────────────────────────────────────────────────────────
class _ExperimentNoteContent extends StatelessWidget {
  final ExperimentRecord record;
  final DateTime generatedAt;
  const _ExperimentNoteContent(
      {required this.record, required this.generatedAt});

  @override
  Widget build(BuildContext context) {
    final cell = CellDatabase.findById(record.cellTypeId);
    final hasFreezerTime = record.deepFreezerTime != null;
    final hasSubculture = record.subcultureConfluence != null;
    final hasCentrifuge = record.centrifugeRpm != null;
    final hasCellCount = record.cellCountCellsPerML != null;

    // 배양 기간 계산
    String cultureDuration = '-';
    if (record.endTime != null) {
      final dur = record.endTime!.difference(record.startTime);
      final simH = dur.inSeconds; // 1s real = 1h simulated
      cultureDuration = '약 ${simH}h (시뮬레이션)';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 헤더 ──────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.biotech,
                  color: Color(0xFF00E5FF), size: 20),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('분당서울대병원 재생의학센터',
                      style: TextStyle(
                          color: Colors.white54, fontSize: 10)),
                  Text('RMC Virtual Lab — 실험 노트',
                      style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: record.mediumCorrect
                      ? Colors.teal.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record.mediumCorrect ? '✓ 성공' : '✗ 실패',
                  style: TextStyle(
                      color: record.mediumCorrect
                          ? Colors.tealAccent
                          : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
          const SizedBox(height: 10),

          // ── 1. 기본 실험 정보 ──────────────────────────────
          _SectionTitle('1. 기본 실험 정보'),
          _NoteRow(label: '세포주', value: record.cellTypeName),
          if (cell != null)
            _NoteRow(label: 'Doubling Time', value: '${cell.doublingTimeHours}h'),
          _NoteRow(label: 'Dish', value: record.dishTypeName),
          _NoteRow(label: '배양액', value: record.medium),
          _NoteRow(
            label: '배양액 적합성',
            value: record.mediumCorrect ? '적합 ✓' : '부적합 ✗',
            valueColor: record.mediumCorrect
                ? Colors.tealAccent
                : Colors.redAccent,
          ),

          const SizedBox(height: 10),

          // ── 2. 딥프리저 해동 ───────────────────────────────
          _SectionTitle('2. 딥프리저 해동'),
          if (hasFreezerTime) ...[
            _NoteRow(
              label: '해동 일시',
              value: _fmtDt(record.deepFreezerTime!),
            ),
            _NoteRow(label: '배양 시작', value: _fmtDt(record.startTime)),
            _NoteRow(label: '배양 기간', value: cultureDuration),
          ] else ...[
            _NoteRow(label: '해동 일시', value: '기록 없음'),
            _NoteRow(label: '배양 시작', value: _fmtDt(record.startTime)),
            _NoteRow(label: '배양 기간', value: cultureDuration),
          ],

          const SizedBox(height: 10),

          // ── 3. 계대배양 성장곡선 스냅샷 ────────────────────
          if (hasSubculture) ...[
            _SectionTitle('3. 계대배양 성장곡선 스냅샷'),
            _NoteRow(
              label: '계대시 합류도',
              value:
                  '${record.subcultureConfluence!.toStringAsFixed(1)}%',
              valueColor: record.subcultureConfluence! >= 95
                  ? Colors.redAccent
                  : Colors.amber,
            ),
            if (record.subcultureTotalCells != null)
              _NoteRow(
                label: '계대시 총 세포수',
                value: _fmtCells(record.subcultureTotalCells!),
              ),
            if (record.subcultureReagent != null)
              _NoteRow(
                label: '탈착 시약',
                value: record.subcultureReagent!,
              ),
            // 간이 성장곡선 시각화
            const SizedBox(height: 8),
            _GrowthCurveBar(
              confluence: record.subcultureConfluence!,
              isOvergrowth: record.subcultureConfluence! >= 95,
            ),
            const SizedBox(height: 10),
          ] else ...[
            _SectionTitle('3. 계대배양 성장곡선 스냅샷'),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('계대배양 없음',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),
          ],

          // ── 4. 원심분리 조건 ───────────────────────────────
          if (hasCentrifuge) ...[
            _SectionTitle('4. 원심분리 조건'),
            _NoteRow(label: 'RPM', value: record.centrifugeRpm ?? '-'),
            _NoteRow(label: '× g', value: record.centrifugeXg ?? '-'),
            _NoteRow(
                label: '시간', value: record.centrifugeDuration ?? '-'),
            _NoteRow(
                label: '온도', value: record.centrifugeTemp ?? '-'),
            const SizedBox(height: 10),
          ] else ...[
            _SectionTitle('4. 원심분리 조건'),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('원심분리 없음',
                  style:
                      TextStyle(color: Colors.white38, fontSize: 12)),
            ),
          ],

          // ── 5. 세포 계수 데이터 ────────────────────────────
          if (hasCellCount) ...[
            _SectionTitle('5. 세포 계수 (Hemocytometer)'),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.lightBlueAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.science,
                          color: Colors.lightBlueAccent, size: 14),
                      SizedBox(width: 6),
                      Text('Trypan Blue 1:1 희석 (2×)',
                          style: TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _NoteRow(
                    label: '세포 농도',
                    value:
                        '${record.cellCountCellsPerML!.toStringAsFixed(3)} × 10⁶ cells/mL',
                    valueColor: Colors.tealAccent,
                  ),
                  if (record.cellCountViability != null)
                    _NoteRow(
                      label: '생존율 (Viability)',
                      value:
                          '${record.cellCountViability!.toStringAsFixed(1)}%',
                      valueColor: record.cellCountViability! >= 90
                          ? Colors.tealAccent
                          : record.cellCountViability! >= 70
                              ? Colors.amber
                              : Colors.redAccent,
                    ),
                  if (record.cellCountRemainingUL != null)
                    _NoteRow(
                      label: '잔여 현탁액',
                      value:
                          '${record.cellCountRemainingUL!.toStringAsFixed(0)} µL',
                    ),
                  if (record.cellCountRemainingUL != null &&
                      record.cellCountCellsPerML != null)
                    _NoteRow(
                      label: '잔여액 총 세포',
                      value: _fmtCells(record.cellCountCellsPerML! *
                          1e6 *
                          (record.cellCountRemainingUL! / 1000)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ] else ...[
            _SectionTitle('5. 세포 계수'),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('세포 계수 없음',
                  style:
                      TextStyle(color: Colors.white38, fontSize: 12)),
            ),
          ],

          // ── 6. 재배양 Dish ────────────────────────────────
          _SectionTitle('6. 재배양 Dish'),
          _NoteRow(
            label: '사용 Dish',
            value: record.passageDishTypeName ?? record.dishTypeName,
          ),
          _NoteRow(
            label: '접종 Well 수',
            value: '${record.seededWells}개',
          ),
          _NoteRow(
            label: '총 세포 수 (초기)',
            value: _fmtCells(record.totalCells),
          ),

          const SizedBox(height: 10),
          Divider(color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '노트 생성: ${_fmtDt(generatedAt)}',
                style: const TextStyle(
                    color: Colors.white24, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtDt(DateTime dt) => dt.toString().substring(0, 16);

  String _fmtCells(double n) {
    if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(2)} × 10⁹';
    if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(2)} × 10⁶';
    if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(2)} × 10³';
    return n.toStringAsFixed(0);
  }
}

// ── 성장곡선 바 시각화 ──────────────────────────────────────
class _GrowthCurveBar extends StatelessWidget {
  final double confluence;
  final bool isOvergrowth;
  const _GrowthCurveBar(
      {required this.confluence, required this.isOvergrowth});

  @override
  Widget build(BuildContext context) {
    final color = isOvergrowth
        ? Colors.redAccent
        : confluence >= 90
            ? Colors.amber
            : Colors.tealAccent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isOvergrowth ? 'Overgrowth (>95%)' : '합류도 게이지',
              style: TextStyle(color: color, fontSize: 10),
            ),
            Text(
              '${confluence.toStringAsFixed(1)}%',
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (confluence / 100).clamp(0.0, 1.0),
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        // 성장 단계 마커
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _marker('0%', Colors.white24),
            _marker('25%', Colors.white24),
            _marker('50%', Colors.white24),
            _marker('75%', Colors.white24),
            _marker('90%', Colors.amber),
            _marker('100%', Colors.redAccent),
          ],
        ),
      ],
    );
  }

  Widget _marker(String label, Color color) {
    return Text(label,
        style: TextStyle(color: color, fontSize: 8));
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            color: const Color(0xFF00E5FF),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _NoteRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white38, fontSize: 11)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// 하위 호환: 기존 _ReportRow 유지
class _ReportRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _ReportRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white38, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
