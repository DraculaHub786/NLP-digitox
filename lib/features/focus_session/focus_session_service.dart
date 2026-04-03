import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models.dart';
import '../../core/services/productivity_points_service.dart';

class FocusSessionService extends ChangeNotifier {
  static final FocusSessionService _instance = FocusSessionService._internal();
  factory FocusSessionService() => _instance;
  FocusSessionService._internal();

  FocusSession? _currentSession;
  Timer? _sessionTimer;
  List<FocusSession> _sessionHistory = [];

  FocusSession? get currentSession => _currentSession;
  List<FocusSession> get sessionHistory => _sessionHistory;
  bool get isSessionActive => _currentSession != null && !_currentSession!.isCompleted;

  Future<void> init() async {
    await _loadSessionHistory();
    await _restoreActiveSession();
  }

  Future<void> startSession(FocusGoal goal) async {
    if (_currentSession != null && !_currentSession!.isCompleted) {
      throw Exception('A session is already active');
    }

    _currentSession = FocusSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      goal: goal,
      startTime: DateTime.now(),
      elapsed: Duration.zero,
      isCompleted: false,
    );

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSession != null) {
        _currentSession = _currentSession!.copyWith(
          elapsed: DateTime.now().difference(_currentSession!.startTime),
        );
        notifyListeners();

        if (_currentSession!.elapsed >= _currentSession!.goal.targetDuration) {
          completeSession();
        }
      }
    });

    await _saveActiveSession();
    notifyListeners();
  }

  Future<void> pauseSession() async {
    _sessionTimer?.cancel();
    await _saveActiveSession();
    notifyListeners();
  }

  Future<void> resumeSession() async {
    if (_currentSession == null || _currentSession!.isCompleted) {
      throw Exception('No active session to resume');
    }

    final pausedDuration = _currentSession!.elapsed;
    _currentSession = FocusSession(
      id: _currentSession!.id,
      goal: _currentSession!.goal,
      startTime: DateTime.now().subtract(pausedDuration),
      elapsed: pausedDuration,
      isCompleted: false,
      distractionCount: _currentSession!.distractionCount,
    );

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSession != null) {
        _currentSession = _currentSession!.copyWith(
          elapsed: DateTime.now().difference(_currentSession!.startTime),
        );
        notifyListeners();

        if (_currentSession!.elapsed >= _currentSession!.goal.targetDuration) {
          completeSession();
        }
      }
    });

    await _saveActiveSession();
    notifyListeners();
  }

  Future<void> completeSession() async {
    if (_currentSession == null) return;

    _sessionTimer?.cancel();
    _currentSession = _currentSession!.copyWith(
      endTime: DateTime.now(),
      isCompleted: true,
    );

    _sessionHistory.insert(0, _currentSession!);
    await _saveSessionHistory();

    // Award points for completing session
    final pointsService = ProductivityPointsService.instance;
    await pointsService.awardPointsForFocusSession(
      _currentSession!.goal.targetDuration.inMinutes,
    );

    await _clearActiveSession();
    _currentSession = null;
    notifyListeners();
  }

  Future<void> cancelSession() async {
    _sessionTimer?.cancel();
    _currentSession = null;
    await _clearActiveSession();
    notifyListeners();
  }

  void recordDistraction() {
    if (_currentSession != null && !_currentSession!.isCompleted) {
      _currentSession = _currentSession!.copyWith(
        distractionCount: _currentSession!.distractionCount + 1,
      );
      _saveActiveSession();
      notifyListeners();
    }
  }

  Future<void> _saveActiveSession() async {
    if (_currentSession == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_focus_session', jsonEncode(_currentSession!.toJson()));
  }

  Future<void> _clearActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_focus_session');
  }

  Future<void> _restoreActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('active_focus_session');
    if (sessionJson != null) {
      try {
        final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
        _currentSession = FocusSession.fromJson(sessionData);
        
        // Resume timer if session was active
        if (!_currentSession!.isCompleted) {
          resumeSession();
        }
      } catch (e) {
        await _clearActiveSession();
      }
    }
  }

  Future<void> _saveSessionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _sessionHistory.map((s) => s.toJson()).toList();
    await prefs.setString('focus_session_history', jsonEncode(historyJson));
  }

  Future<void> _loadSessionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('focus_session_history');
    if (historyJson != null) {
      try {
        final List<dynamic> historyData = jsonDecode(historyJson) as List<dynamic>;
        _sessionHistory = historyData
            .map((s) => FocusSession.fromJson(s as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _sessionHistory = [];
      }
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
