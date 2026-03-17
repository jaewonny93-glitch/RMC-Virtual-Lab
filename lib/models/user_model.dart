import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum UserStatus { pending, approved, rejected }
enum UserRole { researcher, seniorResearcher, professor, other }

class UserProfile {
  final String id;
  final String name;
  final String affiliation;
  final UserRole role;
  final UserStatus status;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.affiliation,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  String get roleDisplay {
    switch (role) {
      case UserRole.researcher:
        return '연구원';
      case UserRole.seniorResearcher:
        return '선임연구원';
      case UserRole.professor:
        return '교수';
      case UserRole.other:
        return '기타';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'affiliation': affiliation,
        'role': role.index,
        'status': status.index,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        affiliation: json['affiliation'] as String,
        role: UserRole.values[json['role'] as int],
        status: UserStatus.values[json['status'] as int],
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class ExperimentRecord {
  final String id;
  final String cellTypeId;
  final String cellTypeName;
  final String dishTypeId;
  final String dishTypeName;
  final String medium;
  final bool mediumCorrect;
  final DateTime startTime;
  final DateTime? endTime;
  final List<WellRecord> wells;
  final bool savedToData;

  // 실험노트 추가 필드
  final DateTime? deepFreezerTime;       // 딥프리저에서 꺼낸 시각
  final double? subcultureConfluence;    // 계대배양 시점 합류도 (%)
  final double? subcultureTotalCells;    // 계대배양 시점 총 세포 수
  final String? subcultureReagent;       // 탈착 시약
  final String? centrifugeRpm;           // RPM 조건
  final String? centrifugeXg;            // ×g 조건
  final String? centrifugeDuration;      // 시간 조건
  final String? centrifugeTemp;          // 원심분리 온도
  final double? cellCountCellsPerML;     // 세포 농도 (×10⁶/mL)
  final double? cellCountViability;      // 생존율 (%)
  final double? cellCountRemainingUL;    // 잔여 현탁액 (µL)
  final String? passageDishTypeName;     // 계대배양 후 dish

  const ExperimentRecord({
    required this.id,
    required this.cellTypeId,
    required this.cellTypeName,
    required this.dishTypeId,
    required this.dishTypeName,
    required this.medium,
    required this.mediumCorrect,
    required this.startTime,
    this.endTime,
    required this.wells,
    this.savedToData = false,
    this.deepFreezerTime,
    this.subcultureConfluence,
    this.subcultureTotalCells,
    this.subcultureReagent,
    this.centrifugeRpm,
    this.centrifugeXg,
    this.centrifugeDuration,
    this.centrifugeTemp,
    this.cellCountCellsPerML,
    this.cellCountViability,
    this.cellCountRemainingUL,
    this.passageDishTypeName,
  });

  double get totalCells =>
      wells.fold(0, (sum, w) => sum + w.cellCount);

  int get seededWells => wells.where((w) => w.cellCount > 0).length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'cellTypeId': cellTypeId,
        'cellTypeName': cellTypeName,
        'dishTypeId': dishTypeId,
        'dishTypeName': dishTypeName,
        'medium': medium,
        'mediumCorrect': mediumCorrect,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'wells': wells.map((w) => w.toJson()).toList(),
        'savedToData': savedToData,
        'deepFreezerTime': deepFreezerTime?.toIso8601String(),
        'subcultureConfluence': subcultureConfluence,
        'subcultureTotalCells': subcultureTotalCells,
        'subcultureReagent': subcultureReagent,
        'centrifugeRpm': centrifugeRpm,
        'centrifugeXg': centrifugeXg,
        'centrifugeDuration': centrifugeDuration,
        'centrifugeTemp': centrifugeTemp,
        'cellCountCellsPerML': cellCountCellsPerML,
        'cellCountViability': cellCountViability,
        'cellCountRemainingUL': cellCountRemainingUL,
        'passageDishTypeName': passageDishTypeName,
      };

  factory ExperimentRecord.fromJson(Map<String, dynamic> json) =>
      ExperimentRecord(
        id: json['id'] as String,
        cellTypeId: json['cellTypeId'] as String,
        cellTypeName: json['cellTypeName'] as String,
        dishTypeId: json['dishTypeId'] as String,
        dishTypeName: json['dishTypeName'] as String,
        medium: json['medium'] as String,
        mediumCorrect: json['mediumCorrect'] as bool,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        wells: (json['wells'] as List)
            .map((w) => WellRecord.fromJson(w as Map<String, dynamic>))
            .toList(),
        savedToData: json['savedToData'] as bool? ?? false,
        deepFreezerTime: json['deepFreezerTime'] != null
            ? DateTime.parse(json['deepFreezerTime'] as String)
            : null,
        subcultureConfluence:
            (json['subcultureConfluence'] as num?)?.toDouble(),
        subcultureTotalCells:
            (json['subcultureTotalCells'] as num?)?.toDouble(),
        subcultureReagent: json['subcultureReagent'] as String?,
        centrifugeRpm: json['centrifugeRpm'] as String?,
        centrifugeXg: json['centrifugeXg'] as String?,
        centrifugeDuration: json['centrifugeDuration'] as String?,
        centrifugeTemp: json['centrifugeTemp'] as String?,
        cellCountCellsPerML:
            (json['cellCountCellsPerML'] as num?)?.toDouble(),
        cellCountViability:
            (json['cellCountViability'] as num?)?.toDouble(),
        cellCountRemainingUL:
            (json['cellCountRemainingUL'] as num?)?.toDouble(),
        passageDishTypeName: json['passageDishTypeName'] as String?,
      );
}

class WellRecord {
  final int index;
  final double cellCount;
  final double mediumVolume;
  final double cellVolume;
  final String? mediumName;

  const WellRecord({
    required this.index,
    required this.cellCount,
    required this.mediumVolume,
    required this.cellVolume,
    this.mediumName,
  });

  Map<String, dynamic> toJson() => {
        'index': index,
        'cellCount': cellCount,
        'mediumVolume': mediumVolume,
        'cellVolume': cellVolume,
        'mediumName': mediumName,
      };

  factory WellRecord.fromJson(Map<String, dynamic> json) => WellRecord(
        index: json['index'] as int,
        cellCount: (json['cellCount'] as num).toDouble(),
        mediumVolume: (json['mediumVolume'] as num).toDouble(),
        cellVolume: (json['cellVolume'] as num).toDouble(),
        mediumName: json['mediumName'] as String?,
      );
}

// ─────────────────────────────────────────────────────────────
//  CultureSession  (사용자별 누적 배양 세션 모델)
// ─────────────────────────────────────────────────────────────
class CultureSession {
  final String id;
  final String userId;
  final String cellTypeId;
  final String cellTypeName;
  final String dishTypeId;
  final String dishTypeName;
  final String medium;
  final bool mediumCorrect;
  final DateTime startTime;
  final double totalCellCount;
  final int seededWellCount;
  final double temp;
  final double co2;
  final double humidity;
  bool isActive;

  CultureSession({
    required this.id,
    required this.userId,
    required this.cellTypeId,
    required this.cellTypeName,
    required this.dishTypeId,
    required this.dishTypeName,
    required this.medium,
    required this.mediumCorrect,
    required this.startTime,
    required this.totalCellCount,
    required this.seededWellCount,
    this.temp = 37.0,
    this.co2 = 5.0,
    this.humidity = 95.0,
    this.isActive = true,
  });

  Duration get elapsed => DateTime.now().difference(startTime);

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'cellTypeId': cellTypeId,
        'cellTypeName': cellTypeName,
        'dishTypeId': dishTypeId,
        'dishTypeName': dishTypeName,
        'medium': medium,
        'mediumCorrect': mediumCorrect,
        'startTime': startTime.toIso8601String(),
        'totalCellCount': totalCellCount,
        'seededWellCount': seededWellCount,
        'temp': temp,
        'co2': co2,
        'humidity': humidity,
        'isActive': isActive,
      };

  factory CultureSession.fromJson(Map<String, dynamic> json) => CultureSession(
        id: json['id'] as String,
        userId: json['userId'] as String? ?? '',
        cellTypeId: json['cellTypeId'] as String,
        cellTypeName: json['cellTypeName'] as String,
        dishTypeId: json['dishTypeId'] as String,
        dishTypeName: json['dishTypeName'] as String,
        medium: json['medium'] as String,
        mediumCorrect: json['mediumCorrect'] as bool,
        startTime: DateTime.parse(json['startTime'] as String),
        totalCellCount: (json['totalCellCount'] as num).toDouble(),
        seededWellCount: json['seededWellCount'] as int? ?? 1,
        temp: (json['temp'] as num?)?.toDouble() ?? 37.0,
        co2: (json['co2'] as num?)?.toDouble() ?? 5.0,
        humidity: (json['humidity'] as num?)?.toDouble() ?? 95.0,
        isActive: json['isActive'] as bool? ?? true,
      );
}

class AppState extends ChangeNotifier {
  UserProfile? _currentUser;
  bool _isAdmin = false;
  List<ExperimentRecord> _history = [];
  List<ExperimentRecord> _savedData = [];
  List<Map<String, dynamic>> _notices = [];
  List<CultureSession> _cultureSessions = [];

  UserProfile? get currentUser => _currentUser;
  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _currentUser != null || _isAdmin;
  List<ExperimentRecord> get history => _history;
  List<ExperimentRecord> get savedData => _savedData;
  List<Map<String, dynamic>> get notices => _notices;
  List<CultureSession> get cultureSessions => _cultureSessions;

  /// 현재 사용자 활성 세션 (최대 10개)
  List<CultureSession> get activeSessions =>
      _cultureSessions.where((s) => s.isActive).toList();

  /// 특정 날짜의 배양 세션
  List<CultureSession> sessionsForDate(DateTime date) =>
      _cultureSessions.where((s) {
        final d = s.startTime;
        return d.year == date.year &&
            d.month == date.month &&
            d.day == date.day;
      }).toList();

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    if (userJson != null) {
      _currentUser = UserProfile.fromJson(
          jsonDecode(userJson) as Map<String, dynamic>);
    }
    final historyJson = prefs.getString('history');
    if (historyJson != null) {
      final list = jsonDecode(historyJson) as List;
      _history = list
          .map((e) => ExperimentRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final dataJson = prefs.getString('savedData');
    if (dataJson != null) {
      final list = jsonDecode(dataJson) as List;
      _savedData = list
          .map((e) => ExperimentRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final noticesJson = prefs.getString('notices');
    if (noticesJson != null) {
      _notices = (jsonDecode(noticesJson) as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    final sessionsJson = prefs.getString('cultureSessions');
    if (sessionsJson != null) {
      _cultureSessions = (jsonDecode(sessionsJson) as List)
          .map((e) => CultureSession.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _saveCultureSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cultureSessions',
        jsonEncode(_cultureSessions.map((s) => s.toJson()).toList()));
  }

  /// 새 배양 세션 추가 (사용자별 최대 10개)
  Future<void> addCultureSession(CultureSession session) async {
    final userId = session.userId;
    final userSessions =
        _cultureSessions.where((s) => s.userId == userId && s.isActive).toList();
    if (userSessions.length >= 10) {
      // 가장 오래된 세션 비활성화
      final oldest = userSessions.reduce(
          (a, b) => a.startTime.isBefore(b.startTime) ? a : b);
      oldest.isActive = false;
    }
    _cultureSessions.insert(0, session);
    await _saveCultureSessions();
    notifyListeners();
  }

  /// 배양 세션 종료
  Future<void> endCultureSession(String sessionId) async {
    final idx = _cultureSessions.indexWhere((s) => s.id == sessionId);
    if (idx != -1) {
      _cultureSessions[idx].isActive = false;
      await _saveCultureSessions();
      notifyListeners();
    }
  }

  Future<void> loginAsAdmin() async {
    _isAdmin = true;
    _currentUser = null;
    notifyListeners();
  }

  Future<void> setCurrentUser(UserProfile user) async {
    _currentUser = user;
    _isAdmin = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', jsonEncode(user.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _isAdmin = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    notifyListeners();
  }

  Future<void> addHistory(ExperimentRecord record) async {
    _history.insert(0, record);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'history', jsonEncode(_history.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> updateHistoryRecord(ExperimentRecord updated) async {
    final idx = _history.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      _history[idx] = updated;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'history', jsonEncode(_history.map((e) => e.toJson()).toList()));
      notifyListeners();
    }
  }

  Future<void> removeCultureSession(String sessionId) async {
    _cultureSessions.removeWhere((s) => s.id == sessionId);
    await _saveCultureSessions();
    notifyListeners();
  }

  Future<void> saveToData(ExperimentRecord record) async {
    _savedData.insert(0, record);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'savedData', jsonEncode(_savedData.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> addNotice(String title, String content) async {
    _notices.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'content': content,
      'date': DateTime.now().toIso8601String(),
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notices', jsonEncode(_notices));
    notifyListeners();
  }
}
