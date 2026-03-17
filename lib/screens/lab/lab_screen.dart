import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lab_model.dart';
import 'deep_freezer_screen.dart';

class LabScreen extends StatefulWidget {
  const LabScreen({super.key});
  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _doorController;
  late Animation<double> _doorAnim;
  bool _doorOpening = false;

  @override
  void initState() {
    super.initState();
    _doorController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _doorAnim = CurvedAnimation(
        parent: _doorController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _doorController.dispose();
    super.dispose();
  }

  void _openFreezer() async {
    if (_doorOpening) return;
    setState(() => _doorOpening = true);
    await _doorController.forward();
    if (!mounted) return;
    final session = context.read<ExperimentSession>();
    session.reset();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const DeepFreezerScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    ).then((_) {
      _doorController.reverse();
      setState(() => _doorOpening = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/lab_background.jpg',
            fit: BoxFit.cover),
        Container(color: Colors.black.withValues(alpha: 0.4)),
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                '실험실',
                style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
              const SizedBox(height: 4),
              const Text(
                '딥프리저를 열어 세포를 선택하세요',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const Spacer(),
              // 딥프리저 시각화
              GestureDetector(
                onTap: _openFreezer,
                child: AnimatedBuilder(
                  animation: _doorAnim,
                  builder: (_, __) {
                    return Column(
                      children: [
                        Container(
                          width: 220,
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF)
                                    .withValues(alpha: 0.3 + _doorAnim.value * 0.3),
                                blurRadius: 20 + _doorAnim.value * 20,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                    'assets/images/deep_freezer.jpg',
                                    fit: BoxFit.cover),
                                // 문 열림 오버레이 효과
                                if (_doorAnim.value > 0)
                                  Container(
                                    color: Colors.cyan
                                        .withValues(alpha: _doorAnim.value * 0.25),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: _doorOpening
                                ? const Color(0xFF00E5FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: const Color(0xFF00E5FF)),
                          ),
                          child: Text(
                            _doorOpening ? '딥프리저 열리는 중...' : '딥프리저 열기',
                            style: TextStyle(
                              color: _doorOpening
                                  ? Colors.black
                                  : const Color(0xFF00E5FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Spacer(),
              // 현재 인큐베이터 상태
              _IncubatorStatusBar(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _IncubatorStatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = context.watch<ExperimentSession>();
    if (!session.isInIncubator) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.thermostat, color: Color(0xFF00E5FF), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('인큐베이터 배양 중',
                    style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                if (session.incubatorStartTime != null)
                  Text(
                    '시작: ${_formatTime(session.incubatorStartTime!)}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11),
                  ),
              ],
            ),
          ),
          const Icon(Icons.circle, color: Colors.green, size: 10),
          const SizedBox(width: 4),
          const Text('진행중',
              style: TextStyle(color: Colors.green, fontSize: 11)),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
