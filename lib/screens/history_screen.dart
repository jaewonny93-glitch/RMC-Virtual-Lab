import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          if (record.savedToData)
            const Icon(Icons.save, color: Colors.amber, size: 16),
        ],
      ),
    );
  }
}
