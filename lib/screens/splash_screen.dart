import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'mode_select_screen.dart';
import 'admin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/lab_background.jpg', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 화면 높이에 따라 크기 동적 조절
                    final sh = constraints.maxHeight;
                    final logoSize = sh < 650 ? 56.0 : sh < 750 ? 68.0 : 80.0;
                    final topPad = sh < 650 ? 12.0 : sh < 750 ? 20.0 : 28.0;
                    final titleFs = sh < 650 ? 14.0 : sh < 750 ? 16.0 : 18.0;
                    final subFs = sh < 650 ? 17.0 : sh < 750 ? 19.0 : 22.0;
                    final rmcFs = sh < 650 ? 20.0 : sh < 750 ? 23.0 : 26.0;
                    final divH = sh < 650 ? 16.0 : sh < 750 ? 20.0 : 26.0;
                    final gap1 = sh < 650 ? 8.0 : sh < 750 ? 12.0 : 16.0;
                    final gap2 = sh < 650 ? 14.0 : sh < 750 ? 20.0 : 28.0;
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            SizedBox(height: topPad),
                            // 로고
                            Container(
                              width: logoSize,
                              height: logoSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF00E5FF), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00E5FF)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    spreadRadius: 3,
                                  )
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset('assets/icons/app_icon.png',
                                    fit: BoxFit.cover),
                              ),
                            ),
                            SizedBox(height: gap1),
                            Text(
                              '분당서울대학교병원',
                              style: TextStyle(
                                color: const Color(0xFF00E5FF),
                                fontSize: titleFs,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              '재생의학센터',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: subFs,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Regenerative Medicine Center',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Divider(
                                color: const Color(0xFF00E5FF),
                                thickness: 0.5,
                                height: divH),
                            Text(
                              'RMC Virtual Lab',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: rmcFs,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const Text(
                              'Cell Lab Simulator',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(height: gap2),
                            // 입력 폼
                            _RegisterForm(),
                            const SizedBox(height: 8),
                            // 관리자 버튼
                            TextButton(
                              onPressed: () => _showAdminLogin(context),
                              child: const Text(
                                '관리자 로그인',
                                style: TextStyle(
                                    color: Color(0xFF00E5FF), fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdminLogin(BuildContext context) {
    final idCtrl = TextEditingController();
    final pwCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('관리자 로그인',
            style: TextStyle(color: Color(0xFF00E5FF))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '아이디',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00E5FF))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pwCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '비밀번호',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
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
              final auth = context.read<AuthService>();
              if (auth.checkAdminLogin(idCtrl.text, pwCtrl.text)) {
                Navigator.pop(ctx);
                context.read<AppState>().loginAsAdmin();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('아이디 또는 비밀번호가 올바르지 않습니다.')),
                );
              }
            },
            child: const Text('로그인',
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _nameCtrl = TextEditingController();
  final _affCtrl = TextEditingController();
  final _empIdCtrl = TextEditingController();   // 사번
  UserRole _selectedRole = UserRole.researcher;
  bool _isLoading = false;
  String? _pendingUserId;
  bool _isCheckingStatus = false;
  bool _initialized = false;
  Timer? _pollTimer; // 자동 승인 상태 폴링 타이머

  // ★ 실험실 정보 저장 체크박스 상태
  bool _saveInfo = false;

  final List<(UserRole, String)> _roles = [
    (UserRole.researcher, '연구원'),
    (UserRole.seniorResearcher, '선임연구원'),
    (UserRole.professor, '교수'),
    (UserRole.other, '기타'),
  ];

  // 직위 문자열 ↔ UserRole 변환
  static const Map<String, UserRole> _roleMap = {
    'researcher': UserRole.researcher,
    'seniorResearcher': UserRole.seniorResearcher,
    'professor': UserRole.professor,
    'other': UserRole.other,
  };
  static const Map<UserRole, String> _roleToStr = {
    UserRole.researcher: 'researcher',
    UserRole.seniorResearcher: 'seniorResearcher',
    UserRole.professor: 'professor',
    UserRole.other: 'other',
  };

  @override
  void initState() {
    super.initState();
    _restorePendingState();
    // 10초마다 자동으로 승인 상태 확인
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_pendingUserId != null && mounted) {
        _autoCheckStatus();
      }
    });
  }

  /// 앱 시작 시:
  /// 1) 이미 승인된 계정이면 바로 메인 진입
  /// 2) 대기 중 ID가 있으면 대기 화면 표시
  /// 3) 저장된 실험자 정보가 있으면 폼에 자동 입력 + 체크박스 ON
  Future<void> _restorePendingState() async {
    final auth = context.read<AuthService>();
    await auth.loadUsers();

    // ─── 승인 상태 복원 ───
    final savedId = await auth.loadPendingUserId();
    if (savedId != null && mounted) {
      final user = await auth.checkApprovalStatus(savedId);
      if (user != null) {
        if (user.status == UserStatus.approved) {
          if (!mounted) return;
          await context.read<AppState>().setCurrentUser(user);
          await auth.clearPendingUserId();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ModeSelectScreen()),
            );
          }
          return;
        } else if (user.status == UserStatus.rejected) {
          await auth.clearPendingUserId();
        } else {
          setState(() => _pendingUserId = savedId);
        }
      } else {
        await auth.clearPendingUserId();
      }
    }

    // ─── 저장된 실험자 정보 복원 ───
    final saved = await auth.loadResearcherInfo();
    if (saved != null && mounted) {
      setState(() {
        _affCtrl.text = saved['affiliation'] ?? '';
        _nameCtrl.text = saved['name'] ?? '';
        _empIdCtrl.text = saved['employeeId'] ?? '';
        _selectedRole =
            _roleMap[saved['role']] ?? UserRole.researcher;
        _saveInfo = true; // 이미 저장된 상태 → 체크 ON
      });
    }

    if (mounted) setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _nameCtrl.dispose();
    _affCtrl.dispose();
    _empIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _affCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('소속과 성함을 모두 입력해 주세요.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final auth = context.read<AuthService>();

    // ─── 실험실 정보 저장 처리 ───
    if (_saveInfo) {
      await auth.saveResearcherInfo(
        name: _nameCtrl.text.trim(),
        affiliation: _affCtrl.text.trim(),
        employeeId: _empIdCtrl.text.trim(),
        role: _roleToStr[_selectedRole] ?? 'researcher',
      );
    } else {
      await auth.clearResearcherInfo();
    }

    final (userId, isExisting) = await auth.registerUser(
      name: _nameCtrl.text.trim(),
      affiliation: _affCtrl.text.trim(),
      employeeId: _empIdCtrl.text.trim(),
      role: _selectedRole,
    );

    // 이미 승인된 계정이면 바로 진입
    final user = await auth.checkApprovalStatus(userId);
    if (user != null && user.status == UserStatus.approved) {
      if (!mounted) return;
      await context.read<AppState>().setCurrentUser(user);
      await auth.clearPendingUserId();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ModeSelectScreen()),
        );
      }
      return;
    }

    setState(() {
      _isLoading = false;
      _pendingUserId = userId;
      _initialized = true;
    });

    if (isExisting && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미 신청된 계정입니다. 관리자 승인을 기다려 주세요.'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  /// 자동 폴링용 (UI 변화 없이 조용히 확인)
  Future<void> _autoCheckStatus() async {
    if (_pendingUserId == null || !mounted) return;
    final auth = context.read<AuthService>();
    final user = await auth.checkApprovalStatus(_pendingUserId!);
    if (user == null || !mounted) return;
    if (user.status == UserStatus.approved) {
      _pollTimer?.cancel();
      await context.read<AppState>().setCurrentUser(user);
      await auth.clearPendingUserId();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 관리자 승인이 완료되었습니다! 입장합니다.'),
            backgroundColor: Colors.teal,
            duration: Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ModeSelectScreen()),
          );
        }
      }
    } else if (user.status == UserStatus.rejected) {
      _pollTimer?.cancel();
      if (mounted) {
        await auth.clearPendingUserId();
        setState(() => _pendingUserId = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('신청이 거절되었습니다. 다시 신청해 주세요.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  Future<void> _checkStatus() async {
    if (_pendingUserId == null) return;
    setState(() => _isCheckingStatus = true);
    final auth = context.read<AuthService>();
    final user = await auth.checkApprovalStatus(_pendingUserId!);
    setState(() => _isCheckingStatus = false);

    if (user == null) return;

    if (user.status == UserStatus.approved) {
      if (!mounted) return;
      _pollTimer?.cancel();
      await context.read<AppState>().setCurrentUser(user);
      await auth.clearPendingUserId();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ModeSelectScreen()),
        );
      }
    } else if (user.status == UserStatus.rejected) {
      await auth.clearPendingUserId();
      setState(() => _pendingUserId = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('승인이 거절되었습니다. 관리자에게 문의하세요.'),
              backgroundColor: Colors.red),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('아직 승인 대기 중입니다. 잠시 후 다시 확인해 주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized && _pendingUserId == null) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00E5FF), strokeWidth: 2,
          ),
        ),
      );
    }
    if (_pendingUserId != null) return _buildPendingView();
    return _buildFormView();
  }

  Widget _buildFormView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 헤더 ───
          Row(
            children: [
              const Icon(Icons.science, color: Color(0xFF00E5FF), size: 18),
              const SizedBox(width: 8),
              const Text(
                '실험자 정보 입력',
                style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // ★ 저장된 정보 빠른 입장 뱃지
              if (_saveInfo)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flash_on,
                          color: Color(0xFF00E5FF), size: 12),
                      SizedBox(width: 2),
                      Text('빠른 입장',
                          style: TextStyle(
                              color: Color(0xFF00E5FF), fontSize: 10)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ─── 소속 / 성함 입력 ───
          _buildTextField(_affCtrl, '소속', Icons.business),
          const SizedBox(height: 8),
          _buildTextField(_nameCtrl, '성함', Icons.person),
          const SizedBox(height: 8),
          _buildTextField(_empIdCtrl, '사번 (선택)', Icons.badge_outlined),
          const SizedBox(height: 8),

          // ─── 직위 선택 ───
          const Text('직위',
              style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _roles.map((r) {
              final selected = _selectedRole == r.$1;
              return ChoiceChip(
                label: Text(r.$2,
                    style: TextStyle(
                        color: selected ? Colors.black : Colors.white70,
                        fontSize: 12)),
                selected: selected,
                selectedColor: const Color(0xFF00E5FF),
                backgroundColor: Colors.white12,
                onSelected: (_) => setState(() => _selectedRole = r.$1),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // ─── ★ 실험실 정보 저장 체크박스 ───
          GestureDetector(
            onTap: () async {
              setState(() => _saveInfo = !_saveInfo);
              // 체크 해제 시 저장 정보 삭제
              if (!_saveInfo) {
                final auth = context.read<AuthService>();
                await auth.clearResearcherInfo();
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _saveInfo
                    ? const Color(0xFF00E5FF).withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _saveInfo
                      ? const Color(0xFF00E5FF).withValues(alpha: 0.6)
                      : Colors.white24,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _saveInfo
                          ? const Color(0xFF00E5FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: _saveInfo
                            ? const Color(0xFF00E5FF)
                            : Colors.white38,
                        width: 1.5,
                      ),
                    ),
                    child: _saveInfo
                        ? const Icon(Icons.check,
                            color: Colors.black, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '실험실 정보 저장',
                          style: TextStyle(
                            color: _saveInfo
                                ? const Color(0xFF00E5FF)
                                : Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _saveInfo
                              ? '다음 방문 시 정보를 자동으로 입력합니다'
                              : '체크하면 다음 방문 시 빠른 입장이 가능합니다',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _saveInfo ? Icons.flash_on : Icons.flash_off,
                    color: _saveInfo
                        ? const Color(0xFF00E5FF)
                        : Colors.white24,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ─── 입장 신청 버튼 ───
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _saveInfo ? Icons.flash_on : Icons.login,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _saveInfo ? '빠른 입장 신청' : '실험실 입장 신청',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdminLoginFromPending(BuildContext context) {
    final idCtrl = TextEditingController();
    final pwCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('관리자 로그인',
            style: TextStyle(color: Color(0xFF00E5FF))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '아이디',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00E5FF))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pwCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '비밀번호',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
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
              final auth = context.read<AuthService>();
              if (auth.checkAdminLogin(idCtrl.text, pwCtrl.text)) {
                Navigator.pop(ctx);
                context.read<AppState>().loginAsAdmin();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('아이디 또는 비밀번호가 올바르지 않습니다.')),
                );
              }
            },
            child: const Text('로그인',
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.hourglass_top, color: Colors.amber, size: 48),
          const SizedBox(height: 12),
          const Text(
            '승인 대기 중',
            style: TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '관리자 승인 후 실험실 입장이 가능합니다.\n승인되면 자동으로 입장됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          // 자동 폴링 안내
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sync, color: Colors.white38, size: 13),
              const SizedBox(width: 4),
              Text(
                '10초마다 자동 확인 중...',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isCheckingStatus ? null : _checkStatus,
              child: _isCheckingStatus
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('지금 바로 확인',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          // 관리자인 경우 바로 로그인할 수 있도록
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: Color(0xFF00E5FF), width: 1),
                foregroundColor: const Color(0xFF00E5FF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.admin_panel_settings, size: 16),
              label: const Text('관리자로 승인하기',
                  style: TextStyle(fontSize: 13)),
              onPressed: () => _showAdminLoginFromPending(context),
            ),
          ),
          TextButton(
            onPressed: () async {
              _pollTimer?.cancel();
              final auth = context.read<AuthService>();
              await auth.clearPendingUserId();
              setState(() => _pendingUserId = null);
              // 새로 시작하면 폴링 재시작
              _pollTimer = Timer.periodic(
                  const Duration(seconds: 10), (_) {
                if (_pendingUserId != null && mounted) {
                  _autoCheckStatus();
                }
              });
            },
            child: const Text('다시 입력',
                style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: const Color(0xFF00E5FF), size: 20),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00E5FF), width: 0.5),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00E5FF), width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }
}
