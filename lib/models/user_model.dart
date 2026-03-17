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

class AppState extends ChangeNotifier {
  UserProfile? _currentUser;
  bool _isAdmin = false;
  List<ExperimentRecord> _history = [];
  List<ExperimentRecord> _savedData = [];
  List<Map<String, dynamic>> _notices = [];

  UserProfile? get currentUser => _currentUser;
  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _currentUser != null || _isAdmin;
  List<ExperimentRecord> get history => _history;
  List<ExperimentRecord> get savedData => _savedData;
  List<Map<String, dynamic>> get notices => _notices;

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
    notifyListeners();
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
