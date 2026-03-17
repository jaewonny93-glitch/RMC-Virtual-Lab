import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthService>().loadUsers();
    });
  }

  @override
  void dispose() {
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('관리자 패널',
                style:
                    TextStyle(color: Color(0xFF00E5FF), fontSize: 18)),
            Text('분당서울대병원 재생의학센터',
                style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PendingUsersTab(),
          _ApprovedUsersTab(),
          _NoticesTab(),
        ],
      ),
    );
  }
}

class _PendingUsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (auth.pendingUsers.isEmpty) {
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
          itemCount: auth.pendingUsers.length,
          itemBuilder: (context, i) {
            final user = auth.pendingUsers[i];
            return _UserCard(
              user: user,
              showActions: true,
              onApprove: () => auth.approveUser(user.id),
              onReject: () => auth.rejectUser(user.id),
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
          itemBuilder: (context, i) =>
              _UserCard(user: users[i], showActions: false),
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserProfile user;
  final bool showActions;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _UserCard({
    required this.user,
    required this.showActions,
    this.onApprove,
    this.onReject,
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
