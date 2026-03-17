import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'lab/lab_screen.dart';
import 'library_screen.dart';
import 'data_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

// 어디서든 MainScreen 탭을 전환할 수 있는 GlobalKey
final mainScreenKey = GlobalKey<_MainScreenState>();

class MainScreen extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  MainScreen({Key? key}) : super(key: key ?? mainScreenKey);

  static void switchTab(int index) {
    mainScreenKey.currentState?._switchTab(index);
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    if (mounted) setState(() => _currentIndex = index);
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const LabScreen(),
    const LibraryScreen(),
    const DataScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '분당서울대학교병원 재생의학센터',
              style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 11,
                  letterSpacing: 1),
            ),
            const Text(
              'RMC Virtual Lab',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(user.name,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13)),
                  Text(user.roleDisplay,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF00E5FF),
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
                icon: Icon(Icons.science_outlined, size: 22),
                activeIcon: Icon(Icons.science, size: 22),
                label: 'Lab'),
            BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined, size: 22),
                activeIcon: Icon(Icons.menu_book, size: 22),
                label: 'Library'),
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
