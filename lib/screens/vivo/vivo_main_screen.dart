import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../models/animal_model.dart';
import '../../models/user_model.dart';
import '../mode_select_screen.dart';
import 'animal_admission_screen.dart';
import 'vivarium_screen.dart';
import 'vivo_support_screens.dart';
import 'animal_detail_screen.dart';

class VivoMainScreen extends StatefulWidget {
  const VivoMainScreen({super.key});
  @override
  State<VivoMainScreen> createState() => _VivoMainScreenState();
}

class _VivoMainScreenState extends State<VivoMainScreen> {
  int _currentIndex = 0;
  Timer? _conditionTimer;

  @override
  void initState() {
    super.initState();
    // 30초마다 동물 컨디션 업데이트 (실제 24시간 기반)
    _conditionTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) context.read<InVivoState>().updateAllConditions();
    });
  }

  @override
  void dispose() {
    _conditionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final inVivo = context.watch<InVivoState>();

    final screens = [
      const _VivoHomeScreen(),
      const AnimalAdmissionScreen(),
      const VivariumScreen(),
      const VivoDataScreen(),
      const VivoHistoryScreen(),
      const VivoSettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.swap_horiz, color: Color(0xFF66FF66)),
          tooltip: '실험 유형 변경',
          onPressed: () => Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const ModeSelectScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('분당서울대학교병원 재생의학센터',
                style: TextStyle(
                    color: Color(0xFF66FF66), fontSize: 10, letterSpacing: 1)),
            Row(
              children: [
                const Text('RMC Virtual Lab',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: Colors.greenAccent.withValues(alpha: 0.5)),
                  ),
                  child: const Text('In Vivo',
                      style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // 살아있는 동물 수 표시
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🐭', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${inVivo.aliveAnimals.length}마리',
                      style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(user.name,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12)),
                  Text(user.roleDisplay,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 10)),
                ],
              ),
            ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1F0D),
          boxShadow: [
            BoxShadow(
                color: Colors.greenAccent.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.greenAccent,
          unselectedItemColor: Colors.white38,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 10,
          unselectedFontSize: 9,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 22),
                activeIcon: Icon(Icons.home, size: 22),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline, size: 22),
                activeIcon: Icon(Icons.add_circle, size: 22),
                label: '입고신청'),
            BottomNavigationBarItem(
                icon: Icon(Icons.cabin_outlined, size: 22),
                activeIcon: Icon(Icons.cabin, size: 22),
                label: '사육장'),
            BottomNavigationBarItem(
                icon: Icon(Icons.folder_outlined, size: 22),
                activeIcon: Icon(Icons.folder, size: 22),
                label: 'Data'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined, size: 22),
                activeIcon: Icon(Icons.history, size: 22),
                label: 'History'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined, size: 22),
                activeIcon: Icon(Icons.settings, size: 22),
                label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// In Vivo 홈 화면
// ══════════════════════════════════════════════════
class _VivoHomeScreen extends StatelessWidget {
  const _VivoHomeScreen();

  @override
  Widget build(BuildContext context) {
    final inVivo = context.watch<InVivoState>();
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final alive = inVivo.aliveAnimals;
    final dead = inVivo.deadAnimals;
    final pendingReqs = inVivo.pendingRequests
        .where((r) => r.userId == user?.id)
        .toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1A0A), Color(0xFF050D05)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 요약 카드
            _buildSummaryRow(alive.length, dead.length, pendingReqs.length),
            const SizedBox(height: 16),
            // 사육 중인 동물
            const Text('사육 중인 동물',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (alive.isEmpty)
              _buildEmptyAnimals(context)
            else
              ...alive.map((a) => _AnimalStatusCard(animal: a)),
            const SizedBox(height: 16),
            // 입고 대기
            if (pendingReqs.isNotEmpty) ...[
              const Text('입고 신청 대기 중',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...pendingReqs.map((r) => _PendingRequestCard(request: r)),
              const SizedBox(height: 16),
            ],
            // 교육 자료
            const Text('동물 실험 교육 자료',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildEducationCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(int alive, int dead, int pending) {
    return Row(
      children: [
        Expanded(child: _SummaryChip('사육 중', '$alive마리', Colors.greenAccent, Icons.favorite)),
        const SizedBox(width: 8),
        Expanded(child: _SummaryChip('사망', '$dead마리', Colors.redAccent, Icons.sentiment_very_dissatisfied)),
        const SizedBox(width: 8),
        Expanded(child: _SummaryChip('입고 대기', '$pending건', Colors.amberAccent, Icons.pending)),
      ],
    );
  }

  Widget _buildEmptyAnimals(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          const Text('🐾', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          const Text('사육 중인 동물이 없습니다',
              style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 4),
          Text("'입고신청' 탭에서 실험동물을 신청하세요",
              style: const TextStyle(color: Colors.white24, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildEducationCards() {
    final items = [
      {'icon': '📋', 'title': '동물 실험 윤리', 'sub': '3Rs 원칙: Replacement · Reduction · Refinement'},
      {'icon': '🔬', 'title': '실험 동물 관리법', 'sub': '법적 요건, IACUC 승인 절차'},
      {'icon': '💉', 'title': '투여 경로 및 방법', 'sub': 'IP, IV, SC, PO 투여법'},
      {'icon': '🏥', 'title': '동물 복지 지침', 'sub': 'AAALAC 기준, 통증 관리'},
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: items.map((e) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e['icon']!, style: const TextStyle(fontSize: 22)),
            const Spacer(),
            Text(e['title']!,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(e['sub']!,
                style: const TextStyle(color: Colors.white38, fontSize: 10),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      )).toList(),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _SummaryChip(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label,
                style:
                    const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      );
}

// ── 동물 상태 카드 ──────────────────────────────────
class _AnimalStatusCard extends StatelessWidget {
  final AnimalInstance animal;
  const _AnimalStatusCard({required this.animal});

  Color get _statusColor {
    switch (animal.status) {
      case AnimalStatus.healthy: return Colors.greenAccent;
      case AnimalStatus.stressed: return Colors.yellowAccent;
      case AnimalStatus.sick: return Colors.orangeAccent;
      case AnimalStatus.critical: return Colors.redAccent;
      case AnimalStatus.dead: return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (animal.status) {
      case AnimalStatus.healthy: return '건강';
      case AnimalStatus.stressed: return '스트레스';
      case AnimalStatus.sick: return '이상';
      case AnimalStatus.critical: return '위험';
      case AnimalStatus.dead: return '사망';
    }
  }

  @override
  Widget build(BuildContext context) {
    final species = AnimalDatabase.findById(animal.speciesId);
    final now = DateTime.now();
    final lastWater = animal.lastWaterTime != null
        ? now.difference(animal.lastWaterTime!).inHours
        : 999;
    final lastFeed = animal.lastFeedTime != null
        ? now.difference(animal.lastFeedTime!).inHours
        : 999;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AnimalDetailScreen(animalId: animal.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _statusColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            // 상태 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _statusColor.withValues(alpha: 0.5)),
              ),
              child: Center(
                child: Text(species?.iconEmoji ?? '🐾',
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(animal.tag,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(_statusLabel,
                            style: TextStyle(
                                color: _statusColor, fontSize: 9)),
                      ),
                      if (animal.injectedGeneId != null) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('유전자 주입됨',
                              style: const TextStyle(
                                  color: Colors.purpleAccent, fontSize: 9)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(species?.name ?? animal.speciesId,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 6),
                  // 컨디션 바
                  LinearProgressIndicator(
                    value: animal.conditionScore / 100.0,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(_statusColor),
                    minHeight: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // 급여 상태
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('💧 ${lastWater}h 전',
                    style: TextStyle(
                        color: lastWater > 12 ? Colors.redAccent : Colors.white38,
                        fontSize: 10)),
                const SizedBox(height: 4),
                Text('🌾 ${lastFeed}h 전',
                    style: TextStyle(
                        color: lastFeed > 24 ? Colors.orangeAccent : Colors.white38,
                        fontSize: 10)),
                const SizedBox(height: 4),
                Text('O₂ ${animal.oxygenPercent.toStringAsFixed(1)}%',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── 입고 대기 카드 ──────────────────────────────────
class _PendingRequestCard extends StatelessWidget {
  final AnimalAdmissionRequest request;
  const _PendingRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final species = AnimalDatabase.findById(request.speciesId);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(species?.iconEmoji ?? '🐾',
              style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${species?.name ?? request.speciesId} × ${request.count}마리',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Text('관리자 승인 대기 중',
                    style: const TextStyle(
                        color: Colors.amberAccent, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.hourglass_top,
              color: Colors.amberAccent, size: 18),
        ],
      ),
    );
  }
}
