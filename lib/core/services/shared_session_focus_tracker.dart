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

  // ---------------------------------------------------------------------------
  // Pre-run profile snapshot
  // ---------------------------------------------------------------------------

  /// Keys for the two profile fields a group run overwrites.
  ///
  /// Only these two are snapshotted, not the whole profile: they are the ones
  /// [FocusModeNotifier.startSessionFromSharedSettings] mutates, so restoring
  /// exactly them is complete and cannot resurrect an unrelated stale field.
  static const String _snapshotDurationKey =
      'shared_session_snapshot_duration_sec';
  static const String _snapshotBlockedAppsKey =
      'shared_session_snapshot_blocked_apps';

  /// Saves the profile fields a group run is about to overwrite.
  ///
  /// Held on disk, not just in memory: the app can be killed mid-run, and the
  /// in-memory snapshot dies with it — which left the member's own focus
  /// duration and blocklist permanently replaced by the group's.
  Future<void> saveProfileSnapshot({
    required int sessionDurationSec,
    required List<String> distractingApps,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_snapshotDurationKey, sessionDurationSec);
      await prefs.setStringList(_snapshotBlockedAppsKey, distractingApps);
    } catch (e) {
      debugPrint('SharedSessionFocusTracker: error saving snapshot - $e');
    }
  }

  /// The snapshot written by [saveProfileSnapshot], or null when there is none.
  Future<SharedFocusProfileSnapshot?> loadProfileSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final duration = prefs.getInt(_snapshotDurationKey);
      final blocked = prefs.getStringList(_snapshotBlockedAppsKey);
      if (duration == null && blocked == null) return null;
      return SharedFocusProfileSnapshot(
        sessionDurationSec: duration,
        distractingApps: blocked,
      );
    } catch (e) {
      debugPrint('SharedSessionFocusTracker: error reading snapshot - $e');
      return null;
    }
  }

  /// Drops the snapshot once the profile has been restored.
  Future<void> clearProfileSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_snapshotDurationKey);
      await prefs.remove(_snapshotBlockedAppsKey);
    } catch (e) {
      debugPrint('SharedSessionFocusTracker: error clearing snapshot - $e');
    }
  }
}

/// The profile fields a group run overwrites, captured before it starts.
///
/// Both nullable so a snapshot written by an older build — which stored only
/// one of them — can still be read without inventing a value for the other.
@immutable
class SharedFocusProfileSnapshot {
  const SharedFocusProfileSnapshot({
    this.sessionDurationSec,
    this.distractingApps,
  });

  /// The member's own focus duration before the group run replaced it.
  final int? sessionDurationSec;

  /// The member's own blocklist before the group run replaced it.
  final List<String>? distractingApps;

  /// Whether nothing was captured, so restoring would be a no-op.
  bool get isEmpty =>
      sessionDurationSec == null && (distractingApps?.isEmpty ?? true);
}
