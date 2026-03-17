import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

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
            // 공지사항
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
          const Icon(Icons.history, color: Color(0xFF00E5FF), size: 22),
          const SizedBox(width: 8),
          const Text('실험 히스토리',
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
          Icon(Icons.history_toggle_off, color: Colors.white12, size: 80),
          SizedBox(height: 16),
          Text('실험 기록이 없습니다',
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
          // 보고서 내보내기 버튼
          IconButton(
            tooltip: '보고서 내보내기',
            icon: const Icon(Icons.picture_as_pdf_outlined,
                color: Color(0xFF00E5FF), size: 20),
            onPressed: () => _showReportDialog(context, record),
          ),
          if (record.savedToData)
            const Icon(Icons.save, color: Colors.amber, size: 16),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, ExperimentRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => _ReportDialog(record: record),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  실험 보고서 다이얼로그 (이미지 내보내기)
// ─────────────────────────────────────────────────────────────
class _ReportDialog extends StatefulWidget {
  final ExperimentRecord record;
  const _ReportDialog({required this.record});

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final GlobalKey _reportKey = GlobalKey();
  bool _exporting = false;
  bool _exported = false;

  Future<void> _exportReport() async {
    setState(() {
      _exporting = true;
      _exported = false;
    });

    try {
      // RepaintBoundary에서 이미지 캡처
      final boundary = _reportKey.currentContext?.findRenderObject()
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

      final pngBytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        // 웹: 다운로드
        _downloadImageWeb(pngBytes, widget.record);
      }

      setState(() {
        _exporting = false;
        _exported = true;
      });
    } catch (e) {
      setState(() => _exporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('내보내기 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _downloadImageWeb(
      Uint8List bytes, ExperimentRecord record) {
    // 웹 다운로드 - JavaScript interop 방식
    // 실제 다운로드는 웹 플랫폼에서만 작동
    // 여기서는 보고서 뷰 표시 후 스크린샷 안내로 대체
    if (kDebugMode) {
      debugPrint('Report export: ${bytes.length} bytes');
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final now = DateTime.now();

    return Dialog(
      backgroundColor: const Color(0xFF0A1628),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Row(
              children: [
                const Icon(Icons.description, color: Color(0xFF00E5FF)),
                const SizedBox(width: 8),
                const Text('실험 보고서',
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

            // 보고서 콘텐츠 (캡처 영역)
            RepaintBoundary(
              key: _reportKey,
              child: _ReportContent(
                record: record,
                generatedAt: now,
              ),
            ),

            const SizedBox(height: 16),

            // 내보내기 버튼
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
                    Text('보고서가 캡처되었습니다.',
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
                  onPressed: _exporting ? null : _exportReport,
                ),
              ),
            const SizedBox(height: 4),
            const Text(
              '팁: 웹에서는 스크린샷(PrtScn) 또는 우클릭 → 이미지 저장으로도 저장 가능합니다.',
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
//  보고서 콘텐츠 위젯
// ─────────────────────────────────────────────────────────────
class _ReportContent extends StatelessWidget {
  final ExperimentRecord record;
  final DateTime generatedAt;
  const _ReportContent(
      {required this.record, required this.generatedAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 보고서 헤더
          Row(
            children: [
              const Icon(Icons.biotech, color: Color(0xFF00E5FF), size: 20),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('분당서울대병원 재생의학센터',
                      style: TextStyle(
                          color: Colors.white54, fontSize: 10)),
                  Text('RMC Virtual Lab',
                      style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          const SizedBox(height: 8),
          Divider(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
          const SizedBox(height: 8),

          // 실험 정보
          const Text('실험 정보',
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          _ReportRow(label: '세포주', value: record.cellTypeName),
          _ReportRow(label: 'Dish', value: record.dishTypeName),
          _ReportRow(label: '배양액', value: record.medium),
          _ReportRow(
            label: '배양액 적합성',
            value: record.mediumCorrect ? '적합 ✓' : '부적합 ✗',
            valueColor: record.mediumCorrect
                ? Colors.tealAccent
                : Colors.redAccent,
          ),
          const SizedBox(height: 8),

          // 실험 시간
          const Text('실험 기록',
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          _ReportRow(
            label: '시작 시간',
            value: record.startTime.toString().substring(0, 16),
          ),
          _ReportRow(
            label: '총 세포 수',
            value: _formatCells(record.totalCells),
          ),
          _ReportRow(
            label: '접종 웰 수',
            value: '${record.seededWells}웰',
          ),

          // 구분선
          const SizedBox(height: 8),
          Divider(color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 4),

          // 생성 일시
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '보고서 생성: ${generatedAt.toString().substring(0, 16)}',
                style: const TextStyle(
                    color: Colors.white24, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCells(double n) {
    if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(2)} × 10⁹';
    if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(2)} × 10⁶';
    if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(2)} × 10³';
    return n.toStringAsFixed(0);
  }
}

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
