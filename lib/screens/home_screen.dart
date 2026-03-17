import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final List<_EducationItem> _eduItems = const [
    _EducationItem(
      icon: Icons.circle_outlined,
      title: '세포(Cell)란?',
      color: Color(0xFF00E5FF),
      content: '세포는 생명의 기본 단위입니다. 모든 생물은 하나 이상의 세포로 이루어져 있으며, '
          '각 세포는 핵, 세포질, 세포막으로 구성됩니다. 세포는 영양소를 에너지로 변환하고, '
          '단백질을 합성하며, 유전 정보를 복제·전달합니다.\n\n'
          '• 원핵세포: 핵막이 없는 단순한 구조 (세균 등)\n'
          '• 진핵세포: 막으로 둘러싸인 핵을 가진 구조 (동식물 세포 등)',
    ),
    _EducationItem(
      icon: Icons.biotech,
      title: '세포 배양(Cell Culture)',
      color: Color(0xFF4CAF50),
      content: '세포 배양이란 생체 외(in vitro) 환경에서 세포를 성장·유지시키는 기술입니다.\n\n'
          '• 2D 배양: 플라스틱 dish나 플라스크 표면에서 단층으로 성장\n'
          '• 3D 배양: 스캐폴드나 하이드로겔을 이용한 입체 구조 형성\n'
          '• 필수 조건: 37°C, 5% CO₂, 95% 습도\n'
          '• 배양액: 영양소, 성장인자, 항생제가 포함된 특수 배지\n'
          '• 계대배양(Passage): 세포가 일정 밀도 이상이 되면 분리하여 새 dish로 옮기는 과정',
    ),
    _EducationItem(
      icon: Icons.star_outline,
      title: '줄기세포(Stem Cells)',
      color: Color(0xFFFF9800),
      content: '줄기세포는 자기 복제 능력과 다양한 세포로 분화할 수 있는 능력을 갖춘 특수 세포입니다.\n\n'
          '• 배아줄기세포(ESC): 전능성(totipotent), 모든 세포로 분화 가능\n'
          '• 성체줄기세포(ASC): 특정 조직 내 다능성(multipotent) 세포\n'
          '• 유도만능줄기세포(iPSC): 체세포를 역분화시켜 만든 줄기세포\n'
          '• 중간엽줄기세포(MSC): 지방, 뼈, 연골, 근육 등으로 분화 가능\n'
          '• 활용 분야: 재생의학, 신약 개발, 질병 모델링',
    ),
    _EducationItem(
      icon: Icons.warning_amber_outlined,
      title: '암세포(Cancer Cells)',
      color: Color(0xFFE91E63),
      content: '암세포는 정상적인 세포 주기 조절에 이상이 생겨 무한히 증식하는 세포입니다.\n\n'
          '• 특징: 접촉 억제 없음, 무한 증식, 혈관신생 유도, 전이(metastasis)\n'
          '• 대표 세포주:\n'
          '  - HeLa: 최초의 불멸화 인간 세포주 (자궁경부암)\n'
          '  - MCF-7: 유방암 연구용\n'
          '  - HCT116: 대장암 연구용\n'
          '• 연구 의의: 항암제 스크리닝, 암 기전 연구, 신약 개발 플랫폼',
    ),
    _EducationItem(
      icon: Icons.favorite_border,
      title: '정상세포(Normal Cells)',
      color: Color(0xFF00BCD4),
      content: '정상 체세포는 정해진 횟수만큼만 분열하며(Hayflick limit), 정상적인 형태와 기능을 유지합니다.\n\n'
          '• 특징: 접촉 억제, 유한한 수명, 분화 상태 유지\n'
          '• 대표 세포:\n'
          '  - HUVEC: 인간 제대 정맥 내피세포\n'
          '  - NHDF: 정상 인간 피부 섬유아세포\n'
          '  - NHEK: 정상 인간 표피각질세포\n'
          '• 활용: 독성 시험, 기초 생물학 연구, 상처 치유 모델링',
    ),
    _EducationItem(
      icon: Icons.science_outlined,
      title: '배양 방법(Culture Methods)',
      color: Color(0xFF9C27B0),
      content: '세포 배양은 목적에 따라 다양한 방법으로 수행됩니다.\n\n'
          '• 부착 배양(Adherent): 세포가 표면에 붙어 성장 (대부분의 체세포)\n'
          '• 부유 배양(Suspension): 배지에 떠서 성장 (혈액세포, 림프구 등)\n'
          '• 단층 배양(Monolayer): 하나의 층으로 성장\n'
          '• Feeder layer: 지지세포층 위에서 줄기세포 배양\n'
          '• Serum-free 배양: 무혈청 배지를 이용한 정의된 배양 조건\n'
          '• GMP 배양: 임상 적용을 위한 엄격한 품질관리 조건',
    ),
    _EducationItem(
      icon: Icons.view_in_ar_outlined,
      title: '3D 세포 배양(3D Culture)',
      color: Color(0xFF8BC34A),
      content: '3D 배양은 생체 내 환경을 보다 유사하게 재현하여 세포 간 상호작용을 모방합니다.\n\n'
          '• 장점: 세포-세포, 세포-기질 상호작용 재현, 약물 반응 예측력 향상\n'
          '• 방법:\n'
          '  - 매트리겔(Matrigel) 임베딩\n'
          '  - 하이드로겔(Hydrogel) 기반 배양\n'
          '  - 비접착 표면에서 자유 부유 배양\n'
          '  - 바이오프린팅을 이용한 구조체 형성',
    ),
    _EducationItem(
      icon: Icons.bubble_chart_outlined,
      title: '스페로이드(Spheroid)',
      color: Color(0xFF607D8B),
      content: '스페로이드는 세포들이 자발적으로 모여 형성하는 3D 구형 집합체입니다.\n\n'
          '• 형성 방법: 행잉드롭, 초저접착 플레이트, 원심력 응집\n'
          '• 특징: 산소·영양소 농도 구배 존재 → 괴사 중심부 형성\n'
          '• 활용:\n'
          '  - 항암제 침투 및 효능 평가\n'
          '  - 종양 미세환경(TME) 모델링\n'
          '  - 조직 공학 빌딩 블록\n'
          '• 크기: 보통 직경 100~500 μm',
    ),
    _EducationItem(
      icon: Icons.account_tree_outlined,
      title: '오가노이드(Organoid)',
      color: Color(0xFFFF5722),
      content: '오가노이드는 줄기세포로부터 자기 조직화된 3D 미니 장기 유사 구조체입니다.\n\n'
          '• 종류: 뇌 오가노이드, 장 오가노이드, 간 오가노이드, 폐 오가노이드 등\n'
          '• 특징: 실제 장기의 구조와 기능을 부분적으로 재현\n'
          '• 활용:\n'
          '  - 발생생물학 연구\n'
          '  - 희귀질환 모델링\n'
          '  - 개인 맞춤형 치료 테스트 (Patient-derived organoid)\n'
          '• 한계: 신경계·혈관계 등 복잡한 구조 재현에 한계',
    ),
    _EducationItem(
      icon: Icons.groups_outlined,
      title: '공동 배양(Co-culture)',
      color: Color(0xFF795548),
      content: '공동 배양은 둘 이상의 세포 종류를 동시에 배양하여 세포 간 상호작용을 연구하는 방법입니다.\n\n'
          '• 방식:\n'
          '  - 직접 접촉(Direct): 두 세포가 같은 공간에서 물리적 접촉\n'
          '  - 간접 접촉(Indirect): 트랜스웰(Transwell) 막으로 분리, 분비물만 공유\n'
          '• 활용:\n'
          '  - 면역세포와 암세포 상호작용 연구\n'
          '  - 신경세포-별아교세포 신호 전달\n'
          '  - 줄기세포 분화 유도를 위한 feeder 세포 공동 배양',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── 이전 달 이동 ──────────────────────────────────────────
  void _prevMonth() =>
      setState(() => _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1));

  void _nextMonth() =>
      setState(() => _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1));

  // ── 해당 날짜에 배양 세션이 있는지 확인 ─────────────────────
  List<CultureSession> _sessionsForDay(
      List<CultureSession> all, DateTime day) {
    return all.where((s) {
      final d = s.startTime;
      return d.year == day.year &&
          d.month == day.month &&
          d.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final sessions = appState.cultureSessions;
    final activeSessions =
        sessions.where((s) => s.isActive).toList();

    return FadeTransition(
      opacity: _fadeAnim,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildCalendarSection(sessions),
          ),
          SliverToBoxAdapter(
            child: _buildActiveSessionsSection(activeSessions),
          ),
          SliverToBoxAdapter(
            child: const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                '세포 배양 교육 자료',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _EducationCard(item: _eduItems[i]),
              childCount: _eduItems.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ── 달력 섹션 ────────────────────────────────────────────
  Widget _buildCalendarSection(List<CultureSession> all) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // 월 네비게이션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left,
                      color: Color(0xFF00E5FF)),
                  onPressed: _prevMonth,
                ),
                Expanded(
                  child: Text(
                    '${_focusedMonth.year}년 ${_focusedMonth.month}월',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right,
                      color: Color(0xFF00E5FF)),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          // 요일 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: ['일', '월', '화', '수', '목', '금', '토']
                  .asMap()
                  .entries
                  .map((e) => Expanded(
                        child: Text(
                          e.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: e.key == 0
                                  ? Colors.redAccent
                                  : e.key == 6
                                      ? Colors.blueAccent
                                      : Colors.white38,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 6),
          // 날짜 그리드
          _buildCalendarGrid(all),
          const SizedBox(height: 8),
          // 선택된 날짜 배양 목록
          _buildSelectedDaySessions(all),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(List<CultureSession> all) {
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7; // 0=Sunday
    final today = DateTime.now();

    final cells = <Widget>[];
    // 앞 빈칸
    for (var i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, d);
      final daySessions = _sessionsForDay(all, date);
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isSelected = date.year == _selectedDay.year &&
          date.month == _selectedDay.month &&
          date.day == _selectedDay.day;
      final weekday = date.weekday % 7;

      cells.add(GestureDetector(
        onTap: () => setState(() => _selectedDay = date),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00E5FF).withValues(alpha: 0.25)
                : isToday
                    ? const Color(0xFF00E5FF).withValues(alpha: 0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: const Color(0xFF00E5FF), width: 1.5)
                : isToday
                    ? Border.all(
                        color: const Color(0xFF00E5FF)
                            .withValues(alpha: 0.4))
                    : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$d',
                style: TextStyle(
                    color: weekday == 0
                        ? Colors.redAccent
                        : weekday == 6
                            ? Colors.blueAccent
                            : Colors.white70,
                    fontSize: 12,
                    fontWeight: isToday || isSelected
                        ? FontWeight.bold
                        : FontWeight.normal),
              ),
              if (daySessions.isNotEmpty)
                Container(
                  width: 16,
                  height: 4,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: daySessions.any((s) => s.isActive)
                        ? Colors.tealAccent
                        : Colors.white38,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.9,
        children: cells,
      ),
    );
  }

  Widget _buildSelectedDaySessions(List<CultureSession> all) {
    final daySessions = _sessionsForDay(all, _selectedDay);
    if (daySessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Text(
          '${_selectedDay.month}/${_selectedDay.day} 배양 기록 없음',
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
          child: Text(
            '${_selectedDay.month}/${_selectedDay.day} 배양 기록',
            style: const TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
        ),
        ...daySessions.map((s) => _CalendarSessionTile(session: s)),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── 진행 중 배양 섹션 ─────────────────────────────────────
  Widget _buildActiveSessionsSection(
      List<CultureSession> activeSessions) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '진행 중 배양',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: activeSessions.isEmpty
                      ? Colors.white12
                      : Colors.tealAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${activeSessions.length}/10',
                  style: TextStyle(
                      color: activeSessions.isEmpty
                          ? Colors.white38
                          : Colors.tealAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (activeSessions.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: const Center(
                child: Text(
                  '진행 중인 배양이 없습니다.\nLab → 딥프리저에서 세포를 선택하여 배양을 시작하세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            )
          else
            ...activeSessions
                .map((s) => _ActiveSessionCard(session: s)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  달력용 세션 타일
// ─────────────────────────────────────────────────────────────
class _CalendarSessionTile extends StatelessWidget {
  final CultureSession session;
  const _CalendarSessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final elapsed = session.elapsed;
    final h = elapsed.inHours;
    final m = elapsed.inMinutes.remainder(60);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: session.isActive
            ? Colors.teal.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: session.isActive
                ? Colors.tealAccent.withValues(alpha: 0.4)
                : Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  session.isActive ? Colors.tealAccent : Colors.white38,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              session.cellTypeName,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 12),
            ),
          ),
          Text(
            session.isActive ? '${h}h ${m}m 경과' : '완료',
            style: TextStyle(
                color: session.isActive
                    ? Colors.tealAccent
                    : Colors.white38,
                fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  진행 중 배양 카드 (클릭 시 상세 조건 바텀시트)
// ─────────────────────────────────────────────────────────────
class _ActiveSessionCard extends StatelessWidget {
  final CultureSession session;
  const _ActiveSessionCard({required this.session});

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _SessionDetailSheet(session: session),
    );
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = session.elapsed;
    final h = elapsed.inHours;
    final m = elapsed.inMinutes.remainder(60);
    final s = elapsed.inSeconds.remainder(60);

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.teal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.tealAccent.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '인큐베이터 배양 중',
                    style: TextStyle(
                        color: Colors.tealAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right,
                    color: Colors.white38, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.science,
                    color: Colors.tealAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    session.cellTypeName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _MiniChip(
                    label: session.dishTypeName,
                    color: Colors.white38),
                const SizedBox(width: 8),
                _MiniChip(
                    label: session.medium,
                    color: Colors.white38),
                const Spacer(),
                Text(
                  '${h}h ${m}m ${s}s',
                  style: const TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  세션 상세 조건 바텀시트
// ─────────────────────────────────────────────────────────────
class _SessionDetailSheet extends StatelessWidget {
  final CultureSession session;
  const _SessionDetailSheet({required this.session});

  @override
  Widget build(BuildContext context) {
    final elapsed = session.elapsed;
    final h = elapsed.inHours;
    final m = elapsed.inMinutes.remainder(60);
    final s = elapsed.inSeconds.remainder(60);
    final startStr =
        '${session.startTime.year}/${session.startTime.month.toString().padLeft(2, '0')}/'
        '${session.startTime.day.toString().padLeft(2, '0')} '
        '${session.startTime.hour.toString().padLeft(2, '0')}:'
        '${session.startTime.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '인큐베이터 배양 조건',
                  style: TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            session.cellTypeName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          Text(
            session.dishTypeName,
            style: const TextStyle(
                color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          _DetailRow('배양 시작', startStr),
          _DetailRow('경과 시간', '${h}h ${m}m ${s}s'),
          _DetailRow('배양액', session.medium),
          _DetailRow('배지 적합성',
              session.mediumCorrect ? '✅ 적합' : '❌ 부적합'),
          _DetailRow('온도', '${session.temp}°C'),
          _DetailRow('CO₂ 농도', '${session.co2}%'),
          _DetailRow('습도', '${session.humidity}%'),
          _DetailRow('파종 Well 수', '${session.seededWellCount}개'),
          _DetailRow(
              '초기 세포 수',
              '${(session.totalCellCount / 1000000).toStringAsFixed(2)}'
                  ' × 10⁶ cells'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 10),
          overflow: TextOverflow.ellipsis),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  교육 카드
// ─────────────────────────────────────────────────────────────
class _EducationItem {
  final IconData icon;
  final String title;
  final Color color;
  final String content;
  const _EducationItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.content,
  });
}

class _EducationCard extends StatefulWidget {
  final _EducationItem item;
  const _EducationCard({required this.item, super.key});

  @override
  State<_EducationCard> createState() => _EducationCardState();
}

class _EducationCardState extends State<_EducationCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: widget.item.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.item.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.item.icon,
                        color: widget.item.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white38,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                      color:
                          widget.item.color.withValues(alpha: 0.2)),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.content,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.6),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
