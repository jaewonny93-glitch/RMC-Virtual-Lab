import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  static const String adminId = 'rmc2026';
  static const String adminPassword = '!rmc2026!';

  // ── API 서버 주소 (웹 환경에서 현재 호스트의 8080 포트 사용) ──
  static String get _apiBase {
    if (kIsWeb) {
      // 웹: 현재 페이지 호스트의 8080 포트
      // (예: https://5060-xxx.sandbox.novita.ai → https://8080-xxx.sandbox.novita.ai)
      final uri = Uri.base;
      final host = uri.host.replaceFirst('5060-', '8080-');
      return 'https://$host';
    }
    return 'http://localhost:8080';
  }

  List<UserProfile> _pendingUsers = [];
  List<UserProfile> _approvedUsers = [];
  List<UserProfile> _rejectedUsers = [];

  List<UserProfile> get pendingUsers => _pendingUsers;
  List<UserProfile> get approvedUsers => _approvedUsers;
  List<UserProfile> get rejectedUsers => _rejectedUsers;
  List<UserProfile> get allUsers =>
      [..._pendingUsers, ..._approvedUsers, ..._rejectedUsers];

  // ── 서버에서 전체 사용자 목록 로드 ─────────────────────────
  Future<void> loadUsers() async {
    try {
      final res = await http
          .get(Uri.parse('$_apiBase/users'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        final users = list
            .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
            .toList();
        _pendingUsers =
            users.where((u) => u.status == UserStatus.pending).toList();
        _approvedUsers =
            users.where((u) => u.status == UserStatus.approved).toList();
        _rejectedUsers =
            users.where((u) => u.status == UserStatus.rejected).toList();
        notifyListeners();
      }
    } catch (e) {
      // 서버 미연결 시 SharedPreferences 폴백
      await _loadFromLocal();
    }
  }

  // ── 로컬 폴백 (오프라인 상황) ───────────────────────────────
  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('allUsers');
    if (usersJson != null) {
      final list = jsonDecode(usersJson) as List;
      final users = list
          .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
          .toList();
      _pendingUsers =
          users.where((u) => u.status == UserStatus.pending).toList();
      _approvedUsers =
          users.where((u) => u.status == UserStatus.approved).toList();
      _rejectedUsers =
          users.where((u) => u.status == UserStatus.rejected).toList();
      notifyListeners();
    }
  }

  bool checkAdminLogin(String id, String password) {
    return id == adminId && password == adminPassword;
  }

  // ── pendingUserId 로컬 저장 (브라우저별 본인 상태 추적용) ───
  Future<void> savePendingUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pendingUserId', userId);
  }

  Future<String?> loadPendingUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pendingUserId');
  }

  Future<void> clearPendingUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pendingUserId');
  }

  /// 동일 이름+소속 사용자 찾기
  UserProfile? findExistingUser({
    required String name,
    required String affiliation,
  }) {
    try {
      return allUsers.firstWhere(
        (u) =>
            u.name.trim() == name.trim() &&
            u.affiliation.trim() == affiliation.trim(),
      );
    } catch (_) {
      return null;
    }
  }

  /// 사용자 등록 (서버에 POST)
  Future<(String, bool)> registerUser({
    required String name,
    required String affiliation,
    String employeeId = '',
    required UserRole role,
  }) async {
    await loadUsers(); // 최신 상태 확인

    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final user = UserProfile(
      id: id,
      name: name,
      affiliation: affiliation,
      employeeId: employeeId,
      role: role,
      status: UserStatus.pending,
      createdAt: DateTime.now(),
    );

    try {
      final res = await http
          .post(
            Uri.parse('$_apiBase/users'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(user.toJson()),
          )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final returnedId = body['id'] as String;
        final isExisting = body['isExisting'] as bool? ?? false;

        if (!isExisting) {
          _pendingUsers.add(user);
          notifyListeners();
        }
        await savePendingUserId(returnedId);
        return (returnedId, isExisting);
      }
    } catch (_) {
      // 서버 미연결 시 로컬 폴백
    }

    // 폴백: 로컬에만 저장
    final existing = findExistingUser(name: name, affiliation: affiliation);
    if (existing != null) {
      await savePendingUserId(existing.id);
      return (existing.id, true);
    }
    _pendingUsers.add(user);
    await _saveLocalFallback();
    await savePendingUserId(id);
    notifyListeners();
    return (id, false);
  }

  Future<void> _saveLocalFallback() async {
    final prefs = await SharedPreferences.getInstance();
    final all = [..._pendingUsers, ..._approvedUsers, ..._rejectedUsers];
    await prefs.setString(
        'allUsers', jsonEncode(all.map((u) => u.toJson()).toList()));
  }

  /// 단일 사용자 상태 확인 (서버에서 GET)
  Future<UserProfile?> checkApprovalStatus(String userId) async {
    try {
      final res = await http
          .get(Uri.parse('$_apiBase/users/$userId'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200 && res.body != 'null') {
        return UserProfile.fromJson(
            jsonDecode(res.body) as Map<String, dynamic>);
      }
    } catch (_) {
      // 폴백: 로컬
    }
    await loadUsers();
    try {
      return allUsers.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }

  /// 승인 (서버에 PUT)
  Future<void> approveUser(String userId) async {
    await _updateUserStatus(userId, UserStatus.approved);
  }

  /// 거절 (서버에 PUT)
  Future<void> rejectUser(String userId) async {
    await _updateUserStatus(userId, UserStatus.rejected);
  }

  /// 접근 권한 취소 (서버에 PUT)
  Future<void> revokeUser(String userId) async {
    await _updateUserStatus(userId, UserStatus.rejected);
  }

  Future<void> _updateUserStatus(String userId, UserStatus status) async {
    final statusStr = status == UserStatus.approved
        ? 'approved'
        : status == UserStatus.rejected
            ? 'rejected'
            : 'pending';
    try {
      await http
          .put(
            Uri.parse('$_apiBase/users/$userId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'status': statusStr}),
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // 로컬 폴백
    }
    // 로컬 메모리도 즉시 업데이트
    await loadUsers();
  }

  // ─────────────────────────────────────────────
  // 실험자 정보 저장/불러오기 (빠른 입장용, 로컬에 저장)
  // ─────────────────────────────────────────────
  Future<void> saveResearcherInfo({
    required String name,
    required String affiliation,
    String employeeId = '',
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_name', name);
    await prefs.setString('saved_affiliation', affiliation);
    await prefs.setString('saved_employee_id', employeeId);
    await prefs.setString('saved_role', role);
    await prefs.setBool('info_saved', true);
  }

  Future<Map<String, String>?> loadResearcherInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final isSaved = prefs.getBool('info_saved') ?? false;
    if (!isSaved) return null;
    return {
      'name': prefs.getString('saved_name') ?? '',
      'affiliation': prefs.getString('saved_affiliation') ?? '',
      'employeeId': prefs.getString('saved_employee_id') ?? '',
      'role': prefs.getString('saved_role') ?? 'researcher',
    };
  }

  Future<void> clearResearcherInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_name');
    await prefs.remove('saved_affiliation');
    await prefs.remove('saved_employee_id');
    await prefs.remove('saved_role');
    await prefs.setBool('info_saved', false);
  }

  Future<bool> isResearcherInfoSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('info_saved') ?? false;
  }
}
