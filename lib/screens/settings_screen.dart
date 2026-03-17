import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/user_model.dart';
import 'splash_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1628), Color(0xFF050D1A)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileCard(user),
              const SizedBox(height: 20),
              _buildSection('실험실 정보', [
                _SettingTile(
                  icon: Icons.business,
                  title: '분당서울대학교병원',
                  subtitle: '재생의학센터 (RMC)',
                  trailing: const Icon(Icons.chevron_right,
                      color: Colors.white24),
                ),
                _SettingTile(
                  icon: Icons.location_on,
                  title: '경기도 성남시 분당구',
                  subtitle: '구미로 173번길 82',
                ),
              ]),
              const SizedBox(height: 16),
              _buildSection('앱 정보', [
                _SettingTile(
                  icon: Icons.info_outline,
                  title: 'RMC Virtual Lab',
                  subtitle: 'v1.0.0  |  재생의학센터 가상 세포 배양 시뮬레이터',
                ),
                _SettingTile(
                  icon: Icons.biotech,
                  title: '세포주 데이터베이스',
                  subtitle: '100종 세포주 내장 (iPSC, MSC 포함)',
                ),
                _SettingTile(
                  icon: Icons.science,
                  title: '배양액 종류',
                  subtitle: '세포별 맞춤 배지 100종 지원',
                ),
              ]),
              const SizedBox(height: 16),
              // ★ 버전 정보 섹션
              _buildVersionSection(),
              const SizedBox(height: 16),
              _buildSection('홈화면 바로가기 (QR)', [
                _SettingTile(
                  icon: Icons.qr_code,
                  title: 'iOS / Android 홈화면 추가',
                  subtitle: 'QR 코드 스캔 → 브라우저에서 홈화면에 추가',
                  onTap: () => _showQrDialog(context),
                ),
              ]),
              const SizedBox(height: 16),
              _buildSection('도움말', [
                _SettingTile(
                  icon: Icons.help_outline,
                  title: '더블링 타임이란?',
                  subtitle: '세포가 2배로 증식하는 데 걸리는 시간',
                  onTap: () => _showDoublingTimeInfo(context),
                ),
                _SettingTile(
                  icon: Icons.menu_book,
                  title: '배양 가이드',
                  subtitle: '세포 배양 기본 프로토콜 안내',
                  onTap: () => _showCultureGuide(context),
                ),
              ]),
              const SizedBox(height: 24),
              // 로그아웃
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('로그아웃',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    await appState.logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SplashScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── 버전 정보 섹션 (웹앱 = 항상 최신 버전) ─────────────────
  Widget _buildVersionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text('버전 정보',
              style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.greenAccent.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              // ── 항상 최신 버전 안내 ──────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.greenAccent.withValues(alpha: 0.12),
                        border: Border.all(
                            color: Colors.greenAccent.withValues(alpha: 0.6)),
                      ),
                      child: const Icon(Icons.verified,
                          color: Colors.greenAccent, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('항상 최신 버전',
                              style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(
                            '웹앱은 접속할 때마다 서버에서\n최신 버전을 자동으로 불러옵니다.',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── 구분선 ───────────────────────────────────────
              Divider(
                  color: Colors.white.withValues(alpha: 0.06), height: 1),

              // ── 버전 + 업데이트 방식 안내 행 ─────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // 현재 버전 뱃지
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF00E5FF)
                                .withValues(alpha: 0.35)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tag,
                              size: 11, color: Color(0xFF00E5FF)),
                          SizedBox(width: 4),
                          Text('v1.0.0',
                              style: TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        '별도 업데이트 없이 새로고침만으로\n최신 기능을 즉시 사용할 수 있습니다.',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 구분선 ───────────────────────────────────────
              Divider(
                  color: Colors.white.withValues(alpha: 0.06), height: 1),

              // ── 새로고침 안내 ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 13, color: Colors.white24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                              height: 1.4),
                          children: [
                            TextSpan(text: '홈화면 아이콘으로 접속 시 '),
                            TextSpan(
                              text: '브라우저 새로고침(↺)',
                              style: TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: '으로 최신 버전을 확인하세요.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(UserProfile? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
              border: Border.all(color: const Color(0xFF00E5FF)),
            ),
            child: const Icon(Icons.person,
                color: Color(0xFF00E5FF), size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name ?? 'Unknown',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(user?.affiliation ?? '-',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 13)),
                if (user?.employeeId != null && user!.employeeId.isNotEmpty)
                  Text('사번: ${user.employeeId}',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user?.roleDisplay ?? '-',
                    style: const TextStyle(
                        color: Color(0xFF00E5FF), fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('승인됨',
                style: TextStyle(color: Colors.greenAccent, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: const TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  void _showQrDialog(BuildContext context) {
    const appUrl =
        'https://5060-iycj4bjlq9houffzbqtpb-de59bda9.sandbox.novita.ai';
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0A1628),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              Row(
                children: [
                  const Icon(Icons.qr_code_2,
                      color: Color(0xFF00E5FF), size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('홈화면 바로가기 추가',
                            style: TextStyle(
                                color: Color(0xFF00E5FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Text('카메라로 QR 스캔 후 홈화면에 추가하세요',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white38),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(color: Colors.white12),
              const SizedBox(height: 12),

              // QR 코드 박스
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: appUrl,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF0A1628),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF0A1628),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // iOS 안내
              _buildOsGuide(
                icon: Icons.phone_iphone,
                os: 'iPhone (iOS)',
                color: const Color(0xFF007AFF),
                steps: [
                  'Safari 브라우저로 링크 열기',
                  '하단 공유 버튼(□↑) 탭',
                  '"홈 화면에 추가" 선택',
                  '"추가" 탭 → 완료!',
                ],
              ),
              const SizedBox(height: 10),

              // Android 안내
              _buildOsGuide(
                icon: Icons.phone_android,
                os: 'Android',
                color: const Color(0xFF4CAF50),
                steps: [
                  'Chrome 브라우저로 링크 열기',
                  '우측 상단 ⋮ 메뉴 탭',
                  '"홈 화면에 추가" 선택',
                  '"추가" 탭 → 완료!',
                ],
              ),
              const SizedBox(height: 16),

              // URL 텍스트
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link,
                        color: Colors.white24, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        appUrl,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 9),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOsGuide({
    required IconData icon,
    required String os,
    required Color color,
    required List<String> steps,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(os,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const SizedBox(height: 6),
                ...steps.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${e.key + 1}. ',
                                style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(e.value,
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 10)),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDoublingTimeInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('더블링 타임 (Doubling Time)',
            style: TextStyle(color: Color(0xFF00E5FF))),
        content: const Text(
          '더블링 타임(Td)은 세포 집단이 2배로 증가하는 데 걸리는 시간입니다.\n\n'
          '성장 공식:\nN(t) = N₀ × 2^(t / Td)\n\n'
          '예시:\n'
          '• HeLa: 24시간\n'
          '• CHO: 13시간\n'
          '• hMSC: 40시간\n\n'
          '더블링 타임이 짧을수록 증식 속도가 빠릅니다.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF)),
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showCultureGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('세포 배양 기본 가이드',
            style: TextStyle(color: Color(0xFF00E5FF))),
        content: const SingleChildScrollView(
          child: Text(
            '1. 세포주 선택\n   딥프리저에서 원하는 세포주를 선택합니다.\n\n'
            '2. Culture Dish 선택\n   실험 목적에 맞는 dish/plate를 선택합니다.\n\n'
            '3. 파이펫 선택\n   분주량에 맞는 파이펫을 선택합니다.\n\n'
            '4. 배양액 선택 (중요!)\n   세포에 맞는 배지를 반드시 선택하세요.\n   잘못된 배지 → 세포 사멸\n\n'
            '5. 분주\n   배양액 → 세포 순서로 분주합니다.\n\n'
            '6. 인큐베이터\n   37°C, 5% CO₂ 조건에서 배양합니다.\n\n'
            '7. 모니터링\n   Graph 탭에서 성장 곡선을 확인합니다.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF)),
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00E5FF), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
