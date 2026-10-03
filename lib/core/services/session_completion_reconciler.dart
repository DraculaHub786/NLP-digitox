// Copyright (c) 2026 NLP digitox

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/enums/session_phase.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/notification_scheduler_service.dart';
import 'package:nlp_digitox/core/services/session_clock.dart';
import 'package:nlp_digitox/core/services/session_focus_bridge.dart';
import 'package:nlp_digitox/core/services/session_service.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';

/// The safety net that reports a finished shared run even when nobody was
/// looking at it.
///
/// A group run can only be reported by a screen that is *observing* it, and the
/// realistic case — the phone face-down for the whole 25 minutes, then the app
/// reclaimed by Android — means no screen ever observed the end. Without this,
/// the member would refocus for the whole run and be paid nothing, and the run
/// would never be recorded as finished at all.
///
/// So this runs on the two triggers that together cover every way back into the
/// app: cold start, and every return to the foreground. Both are cheap — one
/// indexed read of `users/{uid}/sessions` — and both are idempotent: the bridge
/// de-dupes per session per launch and the webhook de-dupes per `sid + uid`, so
/// running it more often than necessary costs a round trip and nothing else.
class SessionCompletionReconciler {
  SessionCompletionReconciler._();

  static final SessionCompletionReconciler instance =
      SessionCompletionReconciler._();

  /// Guards against a cold start and an early resume both firing at once.
  bool _isReconciling = false;

  /// Reports every finished-but-unreported run, and arms a local reminder for
  /// every run still in progress.
  ///
  /// Safe to call on every launch and every resume. Any failure is swallowed
  /// and logged: this is a background repair, and it must never surface as an
  /// error on the screen the user actually opened.
  Future<void> reconcile() async {
    if (_isReconciling) return;
    if (FirebaseAuthService.instance.userId == null) return;
    _isReconciling = true;

    try {
      final sessions = await SessionService.instance.getUserSessions();

      // Rebuild the reminder set from scratch each time, exactly as the group
      // reminders do: a session that has finished or been cancelled must not
      // keep a stale alarm, and re-adding without clearing would accumulate one
      // per session the user ever started.
      await NotificationSchedulerService.instance.cancelSessionEndReminders();

      if (sessions.isEmpty) return;

      final nowMs = SessionClock.instance.nowMs();
      var reported = 0;

      for (final session in sessions) {
        switch (session.phaseAt(nowMs)) {
          case SessionPhase.finished:
            // The member is credited only if they are still on the session;
            // `completeRun` marks them finished and asks the server to verify.
            // Idempotent, so a session already reported is a no-op.
            await SessionFocusBridge.instance.completeRun(session);
            reported++;
            break;
          case SessionPhase.running:
          case SessionPhase.countdown:
            // A run that is still going: leave a reminder at its end so the
            // user comes back and the report actually happens, rather than
            // waiting for the next cold start.
            await _scheduleEndReminder(session);
            break;
          case SessionPhase.lobby:
          case SessionPhase.cancelled:
            break;
        }
      }

      if (reported > 0) {
        debugPrint(
          'SessionCompletionReconciler: reported $reported finished run(s)',
        );
      }
    } catch (e) {
      debugPrint('SessionCompletionReconciler: reconcile failed: $e');
    } finally {
      _isReconciling = false;
    }
  }

  /// Schedules a one-off reminder for the moment [session] ends.
  ///
  /// Best-effort: a missing notification permission (or an end time already in
  /// the past) simply means no reminder, never a failure of the reconcile.
  Future<void> _scheduleEndReminder(SharedSession session) async {
    final endAt = session.endAt;
    if (endAt == null || !endAt.isAfter(DateTime.now())) return;

    try {
      await NotificationSchedulerService.instance.scheduleSessionEndReminder(
        sessionId: session.id,
        title: 'Session finished',
        body: '"${session.name}" has ended — open the app to collect your '
            'points.',
        when: endAt,
      );
    } catch (e) {
      debugPrint(
        'SessionCompletionReconciler: could not schedule reminder: $e',
      );
    }
  }

  /// Forgets the per-launch bookkeeping — for sign-out and tests.
  @visibleForTesting
  void reset() => _isReconciling = false;
}
