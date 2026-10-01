// Copyright (c) 2026 NLP digitox

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers which shared sessions this device has actually focused in.
///
/// The 50-point group-session bonus used to be paid purely because a session
/// had been marked complete, so a user could create a session and immediately
/// end it without ever starting — let alone finishing — a group focus run and
/// still collect the points. The bonus is meant to reward finishing a group
/// focus session, so payout now requires evidence that one actually happened
/// on this device.
///
/// The evidence has to be local rather than server-side: `LeaderboardService`
/// writes only the signed-in user's board doc, so each member claims their own
/// points from their own device (see `SessionService.completeSession`). The
/// device that finishes the focus run is the same device that claims the
/// reward, which makes a local record the correct place to keep this.
///
/// Only the fact of completion is stored — never durations or app lists — and
/// the id list is capped so the entry cannot grow without bound.
class SharedSessionFocusTracker {
  SharedSessionFocusTracker._();

  static final SharedSessionFocusTracker instance =
      SharedSessionFocusTracker._();

  static const String _completedFocusRunsKey =
      'shared_session_completed_focus_runs';

  /// The shared session whose group focus run is currently in progress, if
  /// any. Persisted so that a run which finishes while the app is closed (the
  /// timer catches up on next launch and completes it) is still credited as a
  /// completed group focus run rather than being silently lost.
  static const String _activeFocusRunKey = 'shared_session_active_focus_run';

  /// How many completed group focus runs to remember. The list exists only to
  /// answer "did this device finish a focus run for session X?", and sessions
  /// are short-lived, so a short rolling window is plenty.
  static const int _maxRemembered = 50;

  /// Records that this device successfully completed a group focus run for
  /// [sessionId]. Safe to call repeatedly — the id is stored once.
  Future<void> markFocusRunCompleted(String sessionId) async {
    if (sessionId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = <String>[
        ...(prefs.getStringList(_completedFocusRunsKey) ?? const <String>[]),
      ];
      if (!completed.contains(sessionId)) completed.add(sessionId);

      final trimmed = completed.length > _maxRemembered
          ? completed.sublist(completed.length - _maxRemembered)
          : completed;

      await prefs.setStringList(_completedFocusRunsKey, trimmed);
      debugPrint(
        'SharedSessionFocusTracker: recorded completed focus run for $sessionId',
      );
    } catch (e) {
      debugPrint('SharedSessionFocusTracker: error recording $sessionId - $e');
    }
  }

  /// Marks [sessionId] as the group focus run currently in progress.
  Future<void> markFocusRunStarted(String sessionId) async {
    if (sessionId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeFocusRunKey, sessionId);
    } catch (e) {
      debugPrint('SharedSessionFocusTracker: error marking start - $e');
    }
  }

  /// The shared session currently being focused in, if a run is in progress.
  Future<String?> activeFocusRunSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_activeFocusRunKey);
    } catch (e) {
      debugPrint('SharedSessionFocusTracker: error reading active run - $e');
      return null;
    }
  }

  /// Clears the in-progress marker without recording a completion. Called when
  /// a run ends without reaching its goal, and after a completion is recorded.
  Future<void> clearActiveFocusRun() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeFocusRunKey);
    } catch (e) {
      debugPrint('SharedSessionFocusTracker: error clearing active run - $e');
    }
  }

  /// Whether this device has finished a group focus run for [sessionId].
  ///
  /// Fails closed: if the stored value cannot be read, the caller is told
  /// there is no evidence rather than being allowed to pay out on a guess.
  Future<bool> hasCompletedFocusRun(String sessionId) async {
    if (sessionId.isEmpty) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed =
          prefs.getStringList(_completedFocusRunsKey) ?? const <String>[];
      return completed.contains(sessionId);
    } catch (e) {
      debugPrint('SharedSessionFocusTracker: error reading $sessionId - $e');
      return false;
    }
  }

  /// Clears the record — used for sign-out and by tests.
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_completedFocusRunsKey);
    } catch (e) {
      debugPrint('SharedSessionFocusTracker: error clearing - $e');
    }
  }
}
