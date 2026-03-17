import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/user_model.dart';
import 'models/lab_model.dart';
import 'services/auth_service.dart';
import 'services/update_service.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VirtualCellLabApp());
}

class VirtualCellLabApp extends StatelessWidget {
  const VirtualCellLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()..loadData()),
        ChangeNotifierProvider(create: (_) => AuthService()..loadUsers()),
        ChangeNotifierProvider(create: (_) => ExperimentSession()),
        ChangeNotifierProvider(create: (_) => UpdateService()..initialize()),
      ],
      child: MaterialApp(
        title: 'RMC Virtual Lab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E5FF),
            secondary: Colors.tealAccent,
            surface: Color(0xFF0D1B2A),
          ),
          scaffoldBackgroundColor: const Color(0xFF0A1628),
          cardTheme: CardThemeData(
            color: const Color(0xFF0D1B2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.white54),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00E5FF), width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00E5FF), width: 1.5),
            ),
          ),
        ),
        // ★ 앱 시작 시 저장된 로그인 상태 확인 후 분기
        home: const _AppEntry(),
      ),
    );
  }
}

/// 앱 시작 시 SharedPreferences를 확인하여
/// ① 이미 승인된 사용자 → MainScreen 바로 진입
/// ② 그 외 → SplashScreen(로그인/등록)
class _AppEntry extends StatefulWidget {
  const _AppEntry();
  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _checked = false;
  bool _goMain = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    if (userJson != null) {
      try {
        final user = UserProfile.fromJson(
            jsonDecode(userJson) as Map<String, dynamic>);
        // 승인된 사용자만 자동 진입
        if (user.status == UserStatus.approved) {
          // AppState에도 반영
          if (mounted) {
            await context.read<AppState>().setCurrentUser(user);
          }
          setState(() { _checked = true; _goMain = true; });
          return;
        }
      } catch (_) {}
    }
    setState(() { _checked = true; _goMain = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      // 로딩 스플래시
      return Scaffold(
        backgroundColor: const Color(0xFF0A1628),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00E5FF), width: 2),
                  boxShadow: [BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                    blurRadius: 20, spreadRadius: 4,
                  )],
                ),
                child: ClipOval(
                  child: Image.asset('assets/icons/app_icon.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFF00E5FF), strokeWidth: 2,
                ),
              ),
              const SizedBox(height: 12),
              const Text('RMC Virtual Lab',
                  style: TextStyle(color: Colors.white54, fontSize: 14)),
            ],
          ),
        ),
      );
    }
    return _goMain ? MainScreen() : const SplashScreen();
  }
}
