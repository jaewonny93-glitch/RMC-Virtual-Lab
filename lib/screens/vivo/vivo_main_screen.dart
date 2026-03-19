import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/animal_model.dart';
import '../../models/user_model.dart';
import '../mode_select_screen.dart';
import '../main_screen.dart';
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
    // 진입 시 필수 안내 다이얼로그 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGuideDialogIfNeeded();
    });
  }

  @override
  void dispose() {
    _conditionTimer?.cancel();
    super.dispose();
  }

  Future<void> _showGuideDialogIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = 'vivo_guide_dismissed_${today.year}_${today.month}_${today.day}';
    final dismissed = prefs.getBool(todayKey) ?? false;
    if (!dismissed && mounted) {
      _showVivoGuideDialog(todayKey);
    }
  }

  void _showVivoGuideDialog(String todayKey) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _VivoGuideDialog(todayKey: todayKey),
    );
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
          // In Vitro 모드 전환 버튼
          Tooltip(
            message: 'In Vitro 세포 실험 모드로 전환',
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => MainScreen(),
                    transitionsBuilder: (_, anim, __, child) =>
                        FadeTransition(opacity: anim, child: child),
                    transitionDuration: const Duration(milliseconds: 600),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('🔬', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 3),
                    Text('In Vitro',
                        style: TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
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
      {
        'icon': '📋',
        'title': '동물 실험 윤리 (3Rs)',
        'sub': '3Rs 원칙: Replacement · Reduction · Refinement',
        'detail': '• Replacement: 가능한 경우 동물 대신 세포·컴퓨터 모델 활용\n'
            '• Reduction: 최소한의 동물만 사용, 통계적 최적화\n'
            '• Refinement: 고통·스트레스 최소화, 마취·진통제 사용\n'
            '• 모든 실험은 IACUC(동물실험윤리위원회) 승인 필수',
      },
      {
        'icon': '🔬',
        'title': '실험동물 관리법',
        'sub': '법적 요건, IACUC 승인 절차',
        'detail': '• 실험동물에 관한 법률에 따른 동물실험시설 신고\n'
            '• IACUC 심의·승인 후 실험 시작 가능\n'
            '• 동물 입고 기록, 사용 기록, 폐기 기록 3년 보존\n'
            '• 연 1회 IACUC 자체 점검 실시',
      },
      {
        'icon': '💉',
        'title': '투여 경로 및 방법',
        'sub': 'IP, IV, SC, PO 투여법',
        'detail': '• IP(복강내): 마우스 0.5mL, 랫트 2mL 이내\n'
            '• IV(정맥내): 꼬리 정맥, 필요 시 가온처리\n'
            '• SC(피하): 목덜미 피부 후 투여, 쉽고 저자극\n'
            '• PO(경구): 존데 사용, 과도한 force 주의\n'
            '• 투여량 계산: mg/kg 체중 기준',
      },
      {
        'icon': '🏥',
        'title': '동물 복지 지침',
        'sub': 'AAALAC 기준, 통증 관리',
        'detail': '• 온도 20~26°C, 습도 40~70%, 12h 명암주기\n'
            '• 마우스/랫트: 최소 케이지 면적 준수\n'
            '• 통증 4단계 평가(NRS): 즉시 처치 원칙\n'
            '• 환경 강화(Enrichment): 터널·둥지 재료 제공\n'
            '• 수술 후 진통제 투여 필수',
      },
      {
        'icon': '🧬',
        'title': '유전자 변형 동물 관리',
        'sub': 'GMO 실험동물 특별 관리 지침',
        'detail': '• LMO 법률에 따른 별도 신고·관리 필요\n'
            '• CRISPR/AAV 처리 동물은 격리 사육 권장\n'
            '• 유전자형 확인(genotyping) 실시 의무\n'
            '• 폐기 시 고압증기멸균 처리 필수',
      },
      {
        'icon': '🐣',
        'title': '번식 및 군관리',
        'sub': '교배·임신·산자 관리 기준',
        'detail': '• 교배 전 건강 상태 확인 (체중·컨디션 점수)\n'
            '• 임신 후 단독 사육 또는 소그룹 전환\n'
            '• 분만 전·후 스트레스 최소화 (조용한 환경)\n'
            '• 이유(weaning): 마우스 21~28일령, 랫트 21~28일령\n'
            '• 성성숙 전 성별 분리 필수',
      },
    ];
    return Column(
      children: items.map((e) => _ExpandableEducCard(
        icon: e['icon']!,
        title: e['title']!,
        sub: e['sub']!,
        detail: e['detail']!,
      )).toList(),
    );
  }
}

// ── 확장 가능한 교육 카드 ────────────────────────────────
class _ExpandableEducCard extends StatefulWidget {
  final String icon;
  final String title;
  final String sub;
  final String detail;
  const _ExpandableEducCard({required this.icon, required this.title, required this.sub, required this.detail});
  @override
  State<_ExpandableEducCard> createState() => _ExpandableEducCardState();
}

class _ExpandableEducCardState extends State<_ExpandableEducCard> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _expanded
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _expanded ? Colors.greenAccent.withValues(alpha: 0.4) : Colors.green.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(widget.icon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(widget.sub,
                            style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: _expanded ? Colors.greenAccent : Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(color: Colors.white12, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Text(
                widget.detail,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12, height: 1.7),
              ),
            ),
          ],
        ],
      ),
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

// ── In Vivo 필수 안내 다이얼로그 ──────────────────────────
class _VivoGuideDialog extends StatefulWidget {
  final String todayKey;
  const _VivoGuideDialog({required this.todayKey});
  @override
  State<_VivoGuideDialog> createState() => _VivoGuideDialogState();
}

class _VivoGuideDialogState extends State<_VivoGuideDialog> {
  bool _dontShowToday = false;
  int _currentPage = 0;

  static const List<Map<String, dynamic>> _guides = [
    {
      'icon': '⚖️',
      'title': '동물실험 윤리 원칙 (3Rs)',
      'color': Color(0xFF1A3A2A),
      'borderColor': Colors.greenAccent,
      'items': [
        '🔬 Replacement(대체): 가능한 경우 동물 대신 세포·컴퓨터 모델로 대체',
        '📉 Reduction(감소): 필요 최소한의 동물 수만 사용',
        '❤️ Refinement(개선): 고통·스트레스를 최소화하는 방법 사용',
        '📋 모든 동물실험은 IACUC 승인을 받아야 합니다',
      ],
    },
    {
      'icon': '🏥',
      'title': '동물 복지 및 관리 기준',
      'color': Color(0xFF1A2A3A),
      'borderColor': Color(0xFF00E5FF),
      'items': [
        '🌡️ 온도: 20~26°C, 습도: 40~70% 유지',
        '💡 명암주기: 12시간 명/12시간 암 사이클 유지',
        '🍽️ 사료·음수: 자유 섭취 원칙 (ad libitum)',
        '🐾 케이지: 동물 복지법에 따른 최소 공간 보장',
        '🏥 매일 동물 상태 관찰 및 기록 의무',
      ],
    },
    {
      'icon': '⚕️',
      'title': '안락사 및 부검 지침',
      'color': Color(0xFF2A1A1A),
      'borderColor': Colors.redAccent,
      'items': [
        '💉 안락사: 승인된 방법 사용 (CO₂, 경추탈골 등)',
        '📊 부검 전 실험 종료 보고서 작성 필수',
        '🧪 조직 샘플: 적절한 고정·보관 방법 준수',
        '🗑️ 사체 처리: 의료폐기물 규정에 따라 처리',
        '⚠️ 고통이 명백한 동물은 즉시 안락사 실시',
      ],
    },
    {
      'icon': '📋',
      'title': '기록 및 보고 의무',
      'color': Color(0xFF1A1A2A),
      'borderColor': Colors.purpleAccent,
      'items': [
        '📝 동물 입고부터 폐기까지 전 과정 기록 필수',
        '🔢 개체 식별 시스템 (태그/마킹) 사용',
        '📊 실험 데이터는 원본 그대로 보존',
        '🏛️ 관련 기관 감사 시 모든 기록 제출 의무',
        '📅 실험 종료 후 6개월 이상 기록 보존',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final guide = _guides[_currentPage];
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 520),
        decoration: BoxDecoration(
          color: guide['color'] as Color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: (guide['borderColor'] as Color).withValues(alpha: 0.5),
              width: 1.5),
          boxShadow: [
            BoxShadow(
              color: (guide['borderColor'] as Color).withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_currentPage + 1} / ${_guides.length}',
                          style: TextStyle(
                              color: (guide['borderColor'] as Color).withValues(alpha: 0.7),
                              fontSize: 12)),
                      const Text('⚠️ 필수 안내사항',
                          style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(guide['icon'] as String,
                      style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  Text(guide['title'] as String,
                      style: TextStyle(
                          color: guide['borderColor'] as Color,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            // 내용
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: (guide['items'] as List<String>).map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(item,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.5)),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ),
            // 페이지 인디케이터
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_guides.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? (guide['borderColor'] as Color)
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
              ),
            ),
            // 오늘 하루 읽지 않기 + 버튼
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _dontShowToday,
                        onChanged: (v) => setState(() => _dontShowToday = v ?? false),
                        activeColor: Colors.greenAccent,
                        checkColor: Colors.black,
                        side: const BorderSide(color: Colors.white38),
                      ),
                      const Text('오늘 하루 읽지 않기',
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (_currentPage > 0) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _currentPage--),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white54,
                              side: const BorderSide(color: Colors.white24),
                            ),
                            child: const Text('이전'),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_dontShowToday) {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool(widget.todayKey, true);
                            }
                            if (mounted) Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentPage < _guides.length - 1
                                ? Colors.white12
                                : Colors.green.shade700,
                          ),
                          child: Text(
                            _currentPage < _guides.length - 1 ? '다음 →' : '확인 및 시작',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
