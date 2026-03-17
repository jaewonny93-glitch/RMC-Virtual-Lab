import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';

class DataScreen extends StatelessWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final data = appState.savedData;

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
            _buildHeader(data.length),
            Expanded(
              child: data.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: data.length,
                      itemBuilder: (context, i) =>
                          _DataCard(record: data[i]),
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
          const Icon(Icons.folder, color: Color(0xFF00E5FF), size: 22),
          const SizedBox(width: 8),
          const Text('저장된 데이터',
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

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, color: Colors.white12, size: 80),
          SizedBox(height: 16),
          Text('저장된 데이터가 없습니다',
              style: TextStyle(color: Colors.white38, fontSize: 16)),
          SizedBox(height: 8),
          Text('Graph 탭에서 Save 버튼을 누르면 저장됩니다',
              style: TextStyle(color: Colors.white24, fontSize: 13)),
        ],
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  final ExperimentRecord record;
  const _DataCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final duration = record.endTime != null
        ? record.endTime!.difference(record.startTime)
        : Duration.zero;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: record.mediumCorrect
              ? Colors.tealAccent.withValues(alpha: 0.3)
              : Colors.redAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                record.mediumCorrect ? Icons.trending_up : Icons.trending_down,
                color: record.mediumCorrect ? Colors.tealAccent : Colors.redAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(record.cellTypeName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: record.mediumCorrect
                      ? Colors.teal.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record.mediumCorrect ? '성장' : '사멸',
                  style: TextStyle(
                      color: record.mediumCorrect
                          ? Colors.tealAccent
                          : Colors.redAccent,
                      fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow('배양 Dish', record.dishTypeName),
          _InfoRow('배양액', record.medium),
          _InfoRow('배양 시간',
              '${duration.inHours}h ${duration.inMinutes % 60}m'),
          _InfoRow('Wells', '${record.wells.length}개'),
          _InfoRow('저장 시간',
              record.endTime?.toString().substring(0, 16) ?? '-'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
                width: 80,
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12))),
            Expanded(
                child: Text(value,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12))),
          ],
        ),
      );
}
