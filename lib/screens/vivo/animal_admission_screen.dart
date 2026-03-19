import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/animal_model.dart';
import '../../models/user_model.dart';

class AnimalAdmissionScreen extends StatefulWidget {
  const AnimalAdmissionScreen({super.key});
  @override
  State<AnimalAdmissionScreen> createState() => _AnimalAdmissionScreenState();
}

class _AnimalAdmissionScreenState extends State<AnimalAdmissionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;
    final isAdmin = context.watch<AppState>().isAdmin;

    return Column(
      children: [
        Container(
          color: const Color(0xFF0D1F0D),
          child: TabBar(
            controller: _tab,
            indicatorColor: Colors.greenAccent,
            labelColor: Colors.greenAccent,
            unselectedLabelColor: Colors.white38,
            tabs: [
              Tab(text: isAdmin ? '신청 목록 (관리자)' : '신청하기'),
              const Tab(text: '내 신청 현황'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              isAdmin
                  ? const _AdminApprovalTab()
                  : const _RequestFormTab(),
              const _MyRequestsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 신청 폼 탭 ────────────────────────────────────────
class _RequestFormTab extends StatefulWidget {
  const _RequestFormTab();
  @override
  State<_RequestFormTab> createState() => _RequestFormTabState();
}

class _RequestFormTabState extends State<_RequestFormTab> {
  AnimalSpecies? _selectedSpecies;
  int _count = 1;
  final _purposeCtrl = TextEditingController();

  @override
  void dispose() {
    _purposeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _SectionHeader(icon: Icons.pets, title: '실험동물 입고 신청'),
          const SizedBox(height: 16),

          // 동물 종류 선택
          const Text('동물 종류 선택',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.1,
            ),
            itemCount: AnimalDatabase.species.length,
            itemBuilder: (_, i) {
              final sp = AnimalDatabase.species[i];
              final selected = _selectedSpecies?.id == sp.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedSpecies = sp),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.green.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? Colors.greenAccent
                          : Colors.white24,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(sp.iconEmoji,
                          style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 4),
                      Text(
                        sp.name.split(' ').first,
                        style: TextStyle(
                          color: selected ? Colors.greenAccent : Colors.white70,
                          fontSize: 10,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 선택된 동물 정보
          if (_selectedSpecies != null) ...[
            const SizedBox(height: 16),
            _SpeciesInfoCard(species: _selectedSpecies!),
          ],

          const SizedBox(height: 20),

          // 수량 선택
          _SectionHeader(icon: Icons.numbers, title: '신청 수량'),
          const SizedBox(height: 10),
          Row(
            children: [
              _CountButton(
                icon: Icons.remove,
                onTap: () {
                  if (_count > 1) setState(() => _count--);
                },
              ),
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        '$_count',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('마리',
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              _CountButton(
                icon: Icons.add,
                onTap: () {
                  if (_count < 50) setState(() => _count++);
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 연구 목적
          _SectionHeader(icon: Icons.description, title: '연구 목적'),
          const SizedBox(height: 10),
          TextField(
            controller: _purposeCtrl,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '연구 목적 및 실험 내용을 간략히 기술해주세요',
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.green, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Colors.green, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Colors.greenAccent, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 제출 버튼
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                disabledBackgroundColor: Colors.white12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.send, color: Colors.white),
              label: const Text('입고 신청 제출',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '관리자 승인 후 동물이 사육장에 배정됩니다',
            style: TextStyle(color: Colors.white30, fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  bool get _canSubmit =>
      _selectedSpecies != null && _purposeCtrl.text.trim().isNotEmpty;

  void _submit() {
    final user = context.read<AppState>().currentUser;
    if (user == null) return;

    final req = AnimalAdmissionRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.id,
      userName: user.name,
      speciesId: _selectedSpecies!.id,
      count: _count,
      purpose: _purposeCtrl.text.trim(),
      requestDate: DateTime.now(),
    );

    context.read<InVivoState>().submitAdmissionRequest(req);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('✅ 입고 신청이 제출되었습니다. 관리자 승인을 기다려주세요.'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
      ),
    );

    // 폼 초기화
    setState(() {
      _selectedSpecies = null;
      _count = 1;
      _purposeCtrl.clear();
    });
  }
}

// ── 관리자 승인 탭 ────────────────────────────────────
class _AdminApprovalTab extends StatelessWidget {
  const _AdminApprovalTab();

  @override
  Widget build(BuildContext context) {
    final inVivo = context.watch<InVivoState>();
    final pending = inVivo.pendingRequests;
    final all = inVivo.requests;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(icon: Icons.pending_actions, title: '승인 대기 (${pending.length}건)'),
        const SizedBox(height: 10),
        if (pending.isEmpty)
          const _EmptyCard(msg: '승인 대기 중인 신청이 없습니다')
        else
          ...pending.map((r) => _AdminRequestCard(request: r, isAction: true)),

        const SizedBox(height: 20),
        _SectionHeader(icon: Icons.history, title: '처리 완료 (${all.length - pending.length}건)'),
        const SizedBox(height: 10),
        ...all
            .where((r) => r.status != AnimalRequestStatus.pending)
            .map((r) => _AdminRequestCard(request: r, isAction: false)),
      ],
    );
  }
}

class _AdminRequestCard extends StatelessWidget {
  final AnimalAdmissionRequest request;
  final bool isAction;

  const _AdminRequestCard({required this.request, required this.isAction});

  @override
  Widget build(BuildContext context) {
    final species = AnimalDatabase.findById(request.speciesId);
    final statusColor = request.status == AnimalRequestStatus.pending
        ? Colors.amber
        : request.status == AnimalRequestStatus.approved
            ? Colors.greenAccent
            : Colors.redAccent;
    final statusLabel = request.status == AnimalRequestStatus.pending
        ? '대기'
        : request.status == AnimalRequestStatus.approved
            ? '승인됨'
            : '거절됨';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(species?.iconEmoji ?? '🐭',
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${request.userName} (${species?.name ?? request.speciesId})',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    Text(
                      '${request.count}마리 · ${_formatDate(request.requestDate)}',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '연구 목적: ${request.purpose}',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          if (request.adminNote != null) ...[
            const SizedBox(height: 4),
            Text(
              '관리자 메모: ${request.adminNote}',
              style: const TextStyle(color: Colors.amber, fontSize: 11),
            ),
          ],
          if (isAction) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reject(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('거절', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approve(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.check, size: 16, color: Colors.white),
                    label: const Text('승인',
                        style: TextStyle(
                            color: Colors.white, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _approve(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final noteCtrl = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1F0D),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('입고 승인',
              style: TextStyle(color: Colors.greenAccent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${AnimalDatabase.findById(request.speciesId)?.name} ${request.count}마리를 승인하시겠습니까?',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: '관리자 메모 (선택)',
                  labelStyle: TextStyle(color: Colors.white38),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('취소',
                    style: TextStyle(color: Colors.white38))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700),
              onPressed: () {
                Navigator.pop(ctx);
                context
                    .read<InVivoState>()
                    .approveRequest(request.id, noteCtrl.text.trim().isEmpty
                        ? null
                        : noteCtrl.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '✅ ${request.userName}의 신청이 승인되었습니다. 동물이 사육장에 배정되었습니다.'),
                    backgroundColor: Colors.green.shade700,
                  ),
                );
              },
              child: const Text('승인',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _reject(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final noteCtrl = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF1A0A0A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('입고 거절',
              style: TextStyle(color: Colors.redAccent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '이 신청을 거절하시겠습니까?',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: '거절 사유',
                  labelStyle: TextStyle(color: Colors.white38),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('취소',
                    style: TextStyle(color: Colors.white38))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.pop(ctx);
                context
                    .read<InVivoState>()
                    .rejectRequest(request.id, noteCtrl.text.trim().isEmpty
                        ? '거절됨'
                        : noteCtrl.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('신청이 거절되었습니다.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              child: const Text('거절',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── 내 신청 현황 탭 ────────────────────────────────────
class _MyRequestsTab extends StatelessWidget {
  const _MyRequestsTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;
    final inVivo = context.watch<InVivoState>();

    if (user == null) {
      return const Center(
          child: Text('로그인이 필요합니다.',
              style: TextStyle(color: Colors.white54)));
    }

    final myReqs = inVivo.requests
        .where((r) => r.userId == user.id)
        .toList()
      ..sort((a, b) => b.requestDate.compareTo(a.requestDate));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(icon: Icons.list_alt, title: '내 신청 내역 (${myReqs.length}건)'),
        const SizedBox(height: 10),
        if (myReqs.isEmpty)
          const _EmptyCard(msg: '신청 내역이 없습니다.\n동물 입고를 신청해보세요.')
        else
          ...myReqs.map((r) => _MyRequestCard(request: r)),
      ],
    );
  }
}

class _MyRequestCard extends StatelessWidget {
  final AnimalAdmissionRequest request;
  const _MyRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final species = AnimalDatabase.findById(request.speciesId);
    final statusColor = request.status == AnimalRequestStatus.pending
        ? Colors.amber
        : request.status == AnimalRequestStatus.approved
            ? Colors.greenAccent
            : Colors.redAccent;
    final statusLabel = request.status == AnimalRequestStatus.pending
        ? '⏳ 승인 대기'
        : request.status == AnimalRequestStatus.approved
            ? '✅ 승인됨'
            : '❌ 거절됨';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(species?.iconEmoji ?? '🐭',
              style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  species?.name ?? request.speciesId,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text('${request.count}마리',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 2),
                Text(request.purpose,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (request.adminNote != null) ...[
                  const SizedBox(height: 4),
                  Text('관리자: ${request.adminNote}',
                      style: const TextStyle(
                          color: Colors.amber, fontSize: 11)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(request.requestDate),
                style: const TextStyle(
                    color: Colors.white24, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── 동물 종 정보 카드 ────────────────────────────────────
class _SpeciesInfoCard extends StatelessWidget {
  final AnimalSpecies species;
  const _SpeciesInfoCard({required this.species});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(species.iconEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(species.name,
                        style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    Text(species.scientificName,
                        style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(species.category,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(species.description,
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoChip(
                  label: '수명',
                  value: '${(species.lifespanDays / 30).toStringAsFixed(0)}개월'),
              _InfoChip(label: '케이지', value: species.cageSize),
              _InfoChip(
                  label: '최대수용', value: '${species.maxPerCage}마리/케이지'),
              _InfoChip(
                  label: '사료(일)', value: '${species.stdFeedGPerDay}g'),
              _InfoChip(
                  label: '음수(일)', value: '${species.stdWaterMlPerDay}mL'),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 공용 위젯 ─────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.greenAccent, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(
                    color: Colors.white38, fontSize: 10)),
            TextSpan(
                text: value,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _CountButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CountButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: Colors.greenAccent, size: 22),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String msg;
  const _EmptyCard({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Center(
        child: Text(msg,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
            textAlign: TextAlign.center),
      ),
    );
  }
}
