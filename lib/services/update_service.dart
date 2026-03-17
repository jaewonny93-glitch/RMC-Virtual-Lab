import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// GitHub 기반 자동 업데이트 서비스
/// - GitHub Releases API를 통해 최신 버전 확인
/// - 웹 플랫폼: 자동 새로고침으로 최신 빌드 반영
/// - 앱 플랫폼: GitHub Releases 다운로드 링크 제공
class UpdateService extends ChangeNotifier {
  // ★ 이 값들을 GitHub 저장소에 맞게 설정하세요
  static const String githubOwner = 'jaewonny93-glitch';
  static const String githubRepo = 'RMC-Virtual-Lab';
  static const String githubPagesUrl = 'https://jaewonny93-glitch.github.io/RMC-Virtual-Lab/';

  String? _latestVersion;
  String? _currentVersion;
  bool _updateAvailable = false;
  bool _isChecking = false;
  String? _releaseNotes;
  String? _downloadUrl;
  DateTime? _lastChecked;

  String? get latestVersion => _latestVersion;
  String? get currentVersion => _currentVersion;
  bool get updateAvailable => _updateAvailable;
  bool get isChecking => _isChecking;
  String? get releaseNotes => _releaseNotes;
  DateTime? get lastChecked => _lastChecked;

  /// 앱 시작 시 버전 초기화 및 업데이트 확인
  Future<void> initialize() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _currentVersion = info.version;
      notifyListeners();

      // 마지막 확인 시간 로드
      final prefs = await SharedPreferences.getInstance();
      final lastCheckedStr = prefs.getString('last_update_check');
      if (lastCheckedStr != null) {
        _lastChecked = DateTime.tryParse(lastCheckedStr);
      }

      // 앱 시작마다 확인 (단, 마지막 확인이 1시간 이내면 스킵)
      if (_lastChecked == null ||
          DateTime.now().difference(_lastChecked!).inHours >= 1) {
        await checkForUpdates();
      }
    } catch (e) {
      debugPrint('UpdateService init error: $e');
    }
  }

  /// GitHub Releases API로 최신 버전 확인
  Future<bool> checkForUpdates() async {
    _isChecking = true;
    notifyListeners();

    try {
      final url =
          'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';
      final response = await http
          .get(Uri.parse(url), headers: {'Accept': 'application/vnd.github.v3+json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _latestVersion = (data['tag_name'] as String?)?.replaceAll('v', '');
        _releaseNotes = data['body'] as String?;

        // APK 다운로드 링크 찾기
        final assets = data['assets'] as List<dynamic>? ?? [];
        for (final asset in assets) {
          final name = asset['name'] as String? ?? '';
          if (name.endsWith('.apk')) {
            _downloadUrl = asset['browser_download_url'] as String?;
            break;
          }
        }

        _updateAvailable = _isNewerVersion(_latestVersion, _currentVersion);

        // 마지막 확인 시간 저장
        _lastChecked = DateTime.now();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'last_update_check', _lastChecked!.toIso8601String());
      }

      // 웹 플랫폼에서는 앱이 항상 최신 상태 (서버에서 최신 빌드 제공)
      if (kIsWeb) {
        _updateAvailable = false;
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    } finally {
      _isChecking = false;
      notifyListeners();
    }

    return _updateAvailable;
  }

  /// 버전 비교 (1.2.3 형식)
  bool _isNewerVersion(String? latest, String? current) {
    if (latest == null || current == null) return false;
    try {
      final latestParts = latest.split('.').map(int.parse).toList();
      final currentParts = current.split('.').map(int.parse).toList();
      for (int i = 0; i < 3; i++) {
        final l = i < latestParts.length ? latestParts[i] : 0;
        final c = i < currentParts.length ? currentParts[i] : 0;
        if (l > c) return true;
        if (l < c) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 웹: 현재 페이지 새로고침 (캐시 무효화)
  /// 앱: GitHub Releases 페이지 열기
  Future<void> performUpdate() async {
    if (kIsWeb) {
      // 웹에서는 현재 URL을 강제 새로고침 → 최신 빌드 로드
      await launchUrl(
        Uri.parse(Uri.base.toString()),
        mode: LaunchMode.externalApplication,
      );
    } else if (_downloadUrl != null) {
      await launchUrl(Uri.parse(_downloadUrl!),
          mode: LaunchMode.externalApplication);
    } else {
      // APK 없으면 Releases 페이지로
      await launchUrl(
        Uri.parse('https://github.com/$githubOwner/$githubRepo/releases/latest'),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  /// GitHub Pages URL 열기
  Future<void> openGitHubPages() async {
    await launchUrl(Uri.parse(githubPagesUrl),
        mode: LaunchMode.externalApplication);
  }
}
