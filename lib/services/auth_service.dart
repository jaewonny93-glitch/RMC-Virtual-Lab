import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  static const String adminId = 'rmc2026';
  static const String adminPassword = '!rmc2026!';

  List<UserProfile> _pendingUsers = [];
  List<UserProfile> _approvedUsers = [];
  List<UserProfile> _rejectedUsers = [];

  List<UserProfile> get pendingUsers => _pendingUsers;
  List<UserProfile> get approvedUsers => _approvedUsers;
  List<UserProfile> get rejectedUsers => _rejectedUsers;
  List<UserProfile> get allUsers =>
      [..._pendingUsers, ..._approvedUsers, ..._rejectedUsers];

  Future<void> loadUsers() async {
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

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final all = [..._pendingUsers, ..._approvedUsers, ..._rejectedUsers];
    await prefs.setString(
        'allUsers', jsonEncode(all.map((u) => u.toJson()).toList()));
  }

  bool checkAdminLogin(String id, String password) {
    return id == adminId && password == adminPassword;
  }

  /// pendingUserId를 SharedPreferences에 저장 (새로고침 후에도 유지)
  Future<void> savePendingUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pendingUserId', userId);
  }

  /// 저장된 pendingUserId 불러오기
  Future<String?> loadPendingUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pendingUserId');
  }

  /// pendingUserId 삭제 (승인/거절/재신청 시)
  Future<void> clearPendingUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pendingUserId');
  }

  /// 동일 이름+소속 사용자 찾기 (중복 신청 방지)
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

  /// 사용자 등록 (중복 체크 포함)
  /// 반환값: (userId, isExisting)
  Future<(String, bool)> registerUser({
    required String name,
    required String affiliation,
    required UserRole role,
  }) async {
    await loadUsers(); // 최신 상태 로드

    // ① 이미 동일 이름+소속으로 등록된 사용자 확인
    final existing = findExistingUser(name: name, affiliation: affiliation);
    if (existing != null) {
      // 기존 신청 ID 저장 후 반환 (isExisting = true)
      await savePendingUserId(existing.id);
      return (existing.id, true);
    }

    // ② 신규 등록
    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final user = UserProfile(
      id: id,
      name: name,
      affiliation: affiliation,
      role: role,
      status: UserStatus.pending,
      createdAt: DateTime.now(),
    );
    _pendingUsers.add(user);
    await _saveUsers();
    await savePendingUserId(id);
    notifyListeners();
    return (id, false);
  }

  Future<UserProfile?> checkApprovalStatus(String userId) async {
    await loadUsers();
    try {
      return allUsers.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }

  Future<void> approveUser(String userId) async {
    final idx = _pendingUsers.indexWhere((u) => u.id == userId);
    if (idx == -1) return;
    final user = _pendingUsers.removeAt(idx);
    final approved = UserProfile(
      id: user.id,
      name: user.name,
      affiliation: user.affiliation,
      role: user.role,
      status: UserStatus.approved,
      createdAt: user.createdAt,
    );
    _approvedUsers.add(approved);
    await _saveUsers();
    notifyListeners();
  }

  /// 승인된 사용자의 접근 권한 취소 (Revoke)
  Future<void> revokeUser(String userId) async {
    final idx = _approvedUsers.indexWhere((u) => u.id == userId);
    if (idx == -1) return;
    final user = _approvedUsers.removeAt(idx);
    final revoked = UserProfile(
      id: user.id,
      name: user.name,
      affiliation: user.affiliation,
      role: user.role,
      status: UserStatus.rejected,
      createdAt: user.createdAt,
    );
    _rejectedUsers.add(revoked);
    await _saveUsers();
    notifyListeners();
  }

  Future<void> rejectUser(String userId) async {
    final idx = _pendingUsers.indexWhere((u) => u.id == userId);
    if (idx == -1) return;
    final user = _pendingUsers.removeAt(idx);
    final rejected = UserProfile(
      id: user.id,
      name: user.name,
      affiliation: user.affiliation,
      role: user.role,
      status: UserStatus.rejected,
      createdAt: user.createdAt,
    );
    _rejectedUsers.add(rejected);
    await _saveUsers();
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // 실험자 정보 저장/불러오기 (빠른 입장용)
  // ─────────────────────────────────────────────

  /// 실험자 정보 저장 (이름, 소속, 직위, 저장 여부 플래그)
  Future<void> saveResearcherInfo({
    required String name,
    required String affiliation,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_name', name);
    await prefs.setString('saved_affiliation', affiliation);
    await prefs.setString('saved_role', role);
    await prefs.setBool('info_saved', true);
  }

  /// 저장된 실험자 정보 불러오기
  Future<Map<String, String>?> loadResearcherInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final isSaved = prefs.getBool('info_saved') ?? false;
    if (!isSaved) return null;
    return {
      'name': prefs.getString('saved_name') ?? '',
      'affiliation': prefs.getString('saved_affiliation') ?? '',
      'role': prefs.getString('saved_role') ?? 'researcher',
    };
  }

  /// 저장된 실험자 정보 삭제
  Future<void> clearResearcherInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_name');
    await prefs.remove('saved_affiliation');
    await prefs.remove('saved_role');
    await prefs.setBool('info_saved', false);
  }

  /// 실험자 정보 저장 여부 확인
  Future<bool> isResearcherInfoSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('info_saved') ?? false;
  }
}
