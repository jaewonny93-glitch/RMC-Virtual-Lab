import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/user_model.dart';
import 'main_screen.dart';
import 'vivo/vivo_main_screen.dart';

class ModeSelectScreen extends StatefulWidget {
  const ModeSelectScreen({super.key});

  @override
  State<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends State<ModeSelectScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryCtr;
  late AnimationController _pulseCtr;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _entryCtr = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _pulseCtr = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _fadeAnim = CurvedAnimation(parent: _entryCtr, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 40.0, end: 0.0)
        .animate(CurvedAnimation(parent: _entryCtr, curve: Curves.easeOut));
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtr, curve: Curves.easeInOut));
    _entryCtr.forward();
  }

  @override
  void dispose() {
    _entryCtr.dispose();
    _pulseCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 배경 그라디언트
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.4,
                colors: [Color(0xFF0D2137), Color(0xFF020B18)],
              ),
            ),
          ),
          // 별빛 파티클 (커스텀 페인터)
          CustomPaint(painter: _StarsPainter()),
          SafeArea(
            child: AnimatedBuilder(
              animation: _entryCtr,
              builder: (_, __) => Opacity(
                opacity: _fadeAnim.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnim.value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // 로고
                        _buildLogo(),
                        const SizedBox(height: 12),
                        Text(
                          user != null ? '환영합니다, ${user.name}님' : 'RMC Virtual Lab',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '실험 유형을 선택하세요',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '선택한 유형에 맞는 실험 환경이 열립니다',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        // In vitro 카드
                        _ModeCard(
                          icon: '🔬',
                          title: 'In Vitro',
                          subtitle: '세포 배양 실험',
                          description: '세포주 배양 · 계대배양 · 성장 분석\n클린벤치 · 인큐베이터 · 딥프리저',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF003D5C), Color(0xFF006080)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderColor: const Color(0xFF00E5FF),
                          onTap: () => _goVitro(context),
                          pulseAnim: _pulseAnim,
                        ),
                        const SizedBox(height: 20),
                        // In vivo 카드
                        _ModeCard(
                          icon: '🐭',
                          title: 'In Vivo',
                          subtitle: '동물 실험',
                          description: '실험동물 사육 · 유전자 주입 · 부검\n마우스 · 랫트 · 토끼 · 제브라피시',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A3A1A), Color(0xFF2D5A2D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderColor: Colors.greenAccent,
                          onTap: () => _goVivo(context),
                          pulseAnim: _pulseAnim,
                        ),
                        const Spacer(),
                        // 기관 안내
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.white24, size: 14),
                              SizedBox(width: 6),
                              Text(
                                '분당서울대학교병원 재생의학센터 · RMC Virtual Lab',
                                style: TextStyle(
                                    color: Colors.white24, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Transform.scale(
        scale: _pulseAnim.value,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset('assets/icons/app_icon.png',
                fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  void _goVitro(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MainScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _goVivo(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const VivoMainScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }
}

// ── 모드 카드 ──────────────────────────────────────
class _ModeCard extends StatefulWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String description;
  final LinearGradient gradient;
  final Color borderColor;
  final VoidCallback onTap;
  final Animation<double> pulseAnim;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradient,
    required this.borderColor,
    required this.onTap,
    required this.pulseAnim,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: widget.borderColor.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.borderColor.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              // 이모지 아이콘
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: widget.borderColor.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(widget.icon,
                      style: const TextStyle(fontSize: 38)),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                              color: widget.borderColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.borderColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.subtitle,
                            style: TextStyle(
                                color: widget.borderColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12,
                          height: 1.6),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: widget.borderColor.withValues(alpha: 0.6), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 별빛 배경 ──────────────────────────────────────
class _StarsPainter extends CustomPainter {
  final _rng = math.Random(42);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (int i = 0; i < 80; i++) {
      final x = _rng.nextDouble() * size.width;
      final y = _rng.nextDouble() * size.height;
      final r = _rng.nextDouble() * 1.2;
      paint.color = Colors.white.withValues(alpha: _rng.nextDouble() * 0.4 + 0.1);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
