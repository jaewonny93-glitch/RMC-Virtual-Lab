import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/animal_model.dart';
import '../services/auth_service.dart';
import 'splash_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthService>().loadUsers();
    });
    // 10초마다 자동으로 승인 대기 목록 새로고침
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        context.read<AuthService>().loadUsers();
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        title: Consumer<AuthService>(
          builder: (_, auth, __) => Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('관리자 패널',
                      style: TextStyle(
                          color: Color(0xFF00E5FF), fontSize: 18)),
                  Text('분당서울대병원 재생의학센터',
                      style:
                          TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
              if (auth.pendingUsers.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '대기 ${auth.pendingUsers.length}명',
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: () {
              context.read<AppState>().logout();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SplashScreen()));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00E5FF),
          labelColor: const Color(0xFF00E5FF),
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: '승인 대기'),
            Tab(text: '승인 완료'),
            Tab(text: '공지사항'),
            Tab(text: '🐭 동물 현황'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PendingUsersTab(),
          _ApprovedUsersTab(),
          _NoticesTab(),
          _VivoAdminTab(),
        ],
      ),
    );
  }
}

class _PendingUsersTab extends StatefulWidget {
  @override
  State<_PendingUsersTab> createState() => _PendingUsersTabState();
}

class _PendingUsersTabState extends State<_PendingUsersTab> {
  // 현재 처리 중인 userId 집합 (중복 클릭/폴링 충돌 방지)
  final Set<String> _processingIds = {};

  Future<void> _handleApprove(AuthService auth, String userId) async {
    if (_processingIds.contains(userId)) return;
    setState(() => _processingIds.add(userId));
    try {
      await auth.approveUser(userId);
    } finally {
      if (mounted) setState(() => _processingIds.remove(userId));
    }
  }

  Future<void> _handleReject(AuthService auth, String userId) async {
    if (_processingIds.contains(userId)) return;
    setState(() => _processingIds.add(userId));
    try {
      await auth.rejectUser(userId);
    } finally {
      if (mounted) setState(() => _processingIds.remove(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        // 리스트를 로컬 스냅샷으로 복사 → rebuild 중 목록 변경으로 인한 버그 방지
        final pending = List<UserProfile>.from(auth.pendingUsers);

        if (pending.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, color: Colors.white24, size: 64),
                SizedBox(height: 16),
                Text('승인 대기 중인 신청이 없습니다.',
                    style: TextStyle(color: Colors.white38)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pending.length,
          itemBuilder: (context, i) {
            final user = pending[i];
            final isProcessing = _processingIds.contains(user.id);
            return _UserCard(
              user: user,
              showActions: true,
              isProcessing: isProcessing,
              onApprove: isProcessing ? null : () => _handleApprove(auth, user.id),
              onReject: isProcessing ? null : () => _handleReject(auth, user.id),
            );
          },
        );
      },
    );
  }
}

class _ApprovedUsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        final users = auth.approvedUsers;
        if (users.isEmpty) {
          return const Center(
            child: Text('승인된 사용자가 없습니다.',
                style: TextStyle(color: Colors.white38)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, i) => _UserCard(
            user: users[i],
            showActions: false,
            onRevoke: () => _confirmRevoke(context, auth, users[i]),
          ),
        );
      },
    );
  }

  void _confirmRevoke(
      BuildContext context, AuthService auth, UserProfile user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.block, color: Colors.redAccent, size: 22),
            const SizedBox(width: 8),
            const Text('접근 권한 취소',
                style: TextStyle(color: Colors.redAccent, fontSize: 16)),
          ],
        ),
        content: Text(
          '${user.name} (${user.affiliation})의 접근 권한을 취소하시겠습니까?\n\n취소 후 해당 사용자는 앱에 접근할 수 없습니다.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            onPressed: () {
              auth.revokeUser(user.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('${user.name}의 접근 권한이 취소되었습니다.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('권한 취소',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserProfile user;
  final bool showActions;
  final bool isProcessing;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onRevoke;

  const _UserCard({
    required this.user,
    required this.showActions,
    this.isProcessing = false,
    this.onApprove,
    this.onReject,
    this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: showActions
                ? Colors.amber.withValues(alpha: 0.4)
                : const Color(0xFF00E5FF).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: showActions
                      ? Colors.amber.withValues(alpha: 0.2)
                      : const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user.roleDisplay,
                  style: TextStyle(
                      color: showActions
                          ? Colors.amber
                          : const Color(0xFF00E5FF),
                      fontSize: 11),
                ),
              ),
              const Spacer(),
              Text(
                '${user.createdAt.month}/${user.createdAt.day} ${user.createdAt.hour}:${user.createdAt.minute.toString().padLeft(2, '0')}',
                style:
                    const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(user.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text(user.affiliation,
              style:
                  const TextStyle(color: Colors.white54, fontSize: 13)),
          if (showActions) ...[
            if (isProcessing)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF00E5FF),
                    ),
                  ),
                ),
              )
            else ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                    onPressed: onReject,
                    child: const Text('거절'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: Colors.black),
                    onPressed: onApprove,
                    child: const Text('승인',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            ],
          ] else ...[
            // 승인된 사용자 - 접근 권한 취소 버튼
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.6)),
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                icon: const Icon(Icons.block, size: 16),
                label: const Text('접근 권한 취소',
                    style: TextStyle(fontSize: 12)),
                onPressed: onRevoke,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoticesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.add),
                label: const Text('공지사항 작성',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _showWriteDialog(context, appState),
              ),
            ),
            Expanded(
              child: appState.notices.isEmpty
                  ? const Center(
                      child: Text('등록된 공지사항이 없습니다.',
                          style: TextStyle(color: Colors.white38)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: appState.notices.length,
                      itemBuilder: (context, i) {
                        final n = appState.notices[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1B2A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFF00E5FF)
                                    .withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.campaign,
                                      color: Color(0xFF00E5FF), size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      n['title'] as String,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(n['content'] as String,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13)),
                              const SizedBox(height: 8),
                              Text(
                                DateTime.parse(n['date'] as String)
                                    .toString()
                                    .substring(0, 16),
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showWriteDialog(BuildContext context, AppState appState) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('공지사항 작성',
            style: TextStyle(color: Color(0xFF00E5FF))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '제목',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00E5FF))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '내용',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00E5FF))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF)),
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                appState.addNotice(
                    titleCtrl.text.trim(), contentCtrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('등록',
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// In Vivo 동물 모니터링 탭 (관리자)
// ══════════════════════════════════════════════════
class _VivoAdminTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final inVivo = context.watch<InVivoState>();
    final all = inVivo.animals;
    final alive = inVivo.aliveAnimals;
    final dead = inVivo.deadAnimals;
    final pending = inVivo.pendingRequests;

    // 연구자별 폐사 수 집계
    final Map<String, _ResearcherStats> stats = {};
    for (final req in inVivo.requests) {
      if (!stats.containsKey(req.userId)) {
        stats[req.userId] = _ResearcherStats(name: req.userName);
      }
    }
    for (final a in all) {
      // 어느 연구자의 동물인지 신청 기록에서 찾기
      final reqMatch = inVivo.requests.where((r) =>
          r.userId != '' &&
          r.status == AnimalRequestStatus.approved &&
          r.speciesId == a.speciesId).toList();
      if (reqMatch.isNotEmpty) {
        final userId = reqMatch.first.userId;
        stats.putIfAbsent(userId, () => _ResearcherStats(name: reqMatch.first.userName));
        if (a.status == AnimalStatus.dead) {
          stats[userId]!.deadCount++;
        } else {
          stats[userId]!.aliveCount++;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전체 요약
          _AdminSummaryRow(alive: alive.length, dead: dead.length, pending: pending.length),
          const SizedBox(height: 16),

          // 입고 신청 승인 대기
          if (pending.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.pending_actions, color: Colors.amberAccent, size: 16),
                const SizedBox(width: 6),
                Text('입고 승인 대기 (${pending.length}건)',
                    style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            ...pending.map((r) => _AdminPendingCard(request: r)),
            const SizedBox(height: 16),
          ],

          // 연구자별 폐사 현황
          const Row(
            children: [
              Icon(Icons.people, color: Color(0xFF00E5FF), size: 16),
              SizedBox(width: 6),
              Text('연구자별 폐사 현황',
                  style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          if (stats.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('등록된 동물이 없습니다.',
                    style: TextStyle(color: Colors.white38)),
              ),
            )
          else
            ...stats.entries.map((e) => _ResearcherDeathCard(
                  userId: e.key, stats: e.value)),

          const SizedBox(height: 16),

          // 전체 동물 목록
          const Row(
            children: [
              Icon(Icons.pets, color: Colors.greenAccent, size: 16),
              SizedBox(width: 6),
              Text('전체 생존 동물 현황',
                  style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          if (alive.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('생존 중인 동물이 없습니다.',
                    style: TextStyle(color: Colors.white38)),
              ),
            )
          else
            ...alive.map((a) => _AdminAnimalTile(animal: a)),
        ],
      ),
    );
  }
}

class _ResearcherStats {
  final String name;
  int aliveCount = 0;
  int deadCount = 0;
  _ResearcherStats({required this.name});
}

class _AdminSummaryRow extends StatelessWidget {
  final int alive;
  final int dead;
  final int pending;
  const _AdminSummaryRow({required this.alive, required this.dead, required this.pending});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _AdminStatChip('생존', alive, Colors.greenAccent)),
        const SizedBox(width: 8),
        Expanded(child: _AdminStatChip('폐사', dead, Colors.redAccent)),
        const SizedBox(width: 8),
        Expanded(child: _AdminStatChip('입고 대기', pending, Colors.amberAccent)),
      ],
    );
  }
}

class _AdminStatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _AdminStatChip(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text('$count', style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}

class _AdminPendingCard extends StatelessWidget {
  final AnimalAdmissionRequest request;
  const _AdminPendingCard({required this.request});

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
          Text(species?.iconEmoji ?? '🐭', style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${request.userName} → ${species?.name ?? request.speciesId} ${request.count}마리',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                Text(request.purpose, style: const TextStyle(color: Colors.white38, fontSize: 10),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Row(
            children: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent, padding: EdgeInsets.zero),
                onPressed: () => context.read<InVivoState>().rejectRequest(request.id, '관리자 거절'),
                child: const Text('거절', style: TextStyle(fontSize: 11)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => context.read<InVivoState>().approveRequest(request.id, null),
                child: const Text('승인', style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResearcherDeathCard extends StatelessWidget {
  final String userId;
  final _ResearcherStats stats;
  const _ResearcherDeathCard({required this.userId, required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.aliveCount + stats.deadCount;
    final deathRate = total > 0 ? (stats.deadCount / total * 100) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: stats.deadCount > 3
              ? Colors.redAccent.withValues(alpha: 0.3)
              : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white54, size: 16),
              const SizedBox(width: 6),
              Text(stats.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              if (stats.deadCount > 3) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('⚠️ 폐사 주의',
                      style: TextStyle(color: Colors.redAccent, fontSize: 9)),
                ),
              ],
              const Spacer(),
              Text('폐사율 ${deathRate.toStringAsFixed(0)}%',
                  style: TextStyle(
                      color: deathRate > 50 ? Colors.redAccent : Colors.white54,
                      fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('생존',
                            style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
                        Text('${stats.aliveCount}마리',
                            style: const TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('폐사',
                            style: TextStyle(color: Colors.redAccent, fontSize: 10)),
                        Text('${stats.deadCount}마리',
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: total > 0 ? stats.aliveCount / total : 0,
                      strokeWidth: 5,
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
                    ),
                    Center(
                      child: Text(
                        '${stats.aliveCount}/${total}',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 9),
                      ),
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
}

class _AdminAnimalTile extends StatelessWidget {
  final AnimalInstance animal;
  const _AdminAnimalTile({required this.animal});

  @override
  Widget build(BuildContext context) {
    final species = AnimalDatabase.findById(animal.speciesId);
    final statusColor = animal.status == AnimalStatus.healthy
        ? Colors.greenAccent
        : animal.status == AnimalStatus.stressed
            ? Colors.amberAccent
            : animal.status == AnimalStatus.sick
                ? Colors.orangeAccent
                : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(species?.iconEmoji ?? '🐭',
              style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(animal.tag,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          Text('${animal.conditionScore.toStringAsFixed(0)}%',
              style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
