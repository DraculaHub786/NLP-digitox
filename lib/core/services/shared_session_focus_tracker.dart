// Copyright (c) 2026 NLP digitox

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers which shared session this device is currently focusing in.
///
/// This is *not* a record of who earned points. Points for a shared run are
/// decided by the completion webhook, which re-reads the session with a service
/// account and verifies the run against the stored server timestamp — the
/// client is never trusted with the payout. The only thing this tracker holds is
/// a single marker: the session whose group focus run is in progress on this
/// device.
///
/// That marker exists for one reason. A run can be started and then have the app
/// closed — killed, or backgrounded until Android reclaims it — while the timer
/// is still going. On the next launch the focus notifier reads this marker,
/// catches the run up, completes it, and reports it. Without it a run that
/// finished while the app was away would be silently lost, because nothing else
/// on the device remembers that the run was ever started.
class SharedSessionFocusTracker {
  SharedSessionFocusTracker._();

  static final SharedSessionFocusTracker instance =
      SharedSessionFocusTracker._();

  /// The shared session whose group focus run is currently in progress, if
  /// any. Persisted so that a run which finishes while the app is closed (the
  /// timer catches up on next launch and completes it) is still reported rather
  /// than being silently lost.
  static const String _activeFocusRunKey = 'shared_session_active_focus_run';

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

  /// Clears the in-progress marker. Called when a run ends, is given up, or
  /// crashes out — the marker only ever describes a run that is still going.
  Future<void> clearActiveFocusRun() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeFocusRunKey);
    } catch (e) {
      debugPrint('SharedSessionFocusTracker: error clearing active run - $e');
    }
  }
}
