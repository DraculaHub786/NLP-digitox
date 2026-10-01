// Copyright (c) 2026 NLP digitox

import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/services/session_completion_service.dart';
import 'package:nlp_digitox/core/services/session_service.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';
import 'package:nlp_digitox/providers/focus/focus_mode_provider.dart';

/// The single place that connects a *shared session* to the app's *focus
/// engine*.
///
/// Shared sessions and focus runs are two separate machines: the session knows
/// when the run starts and ends (from one server timestamp), and the focus
/// engine knows how to actually block apps on this device. Nothing should
/// re-implement the join between them, because a screen that forgets one of the
/// steps produces a session that looks right and pays nothing — the member
/// focuses for 25 minutes and the server never hears about it.
///
/// So every transition lives here:
///   * [startRun] — the shared phase reached `running`; apply the session's
///     settings and start a focus run.
///   * [reportBreak] — the member left focus early; count it against the run.
///   * [completeRun] — the shared phase reached `finished`; mark the member's
///     `completedAt` and ask the server to verify and pay.
///
/// Every method is idempotent: a phase change can be observed more than once
/// (a reconnect re-delivers the snapshot), and none of these should happen
/// twice for one run.
class SessionFocusBridge {
  SessionFocusBridge._();

  static final SessionFocusBridge instance = SessionFocusBridge._();

  /// Sessions this device has already reported as complete.
  ///
  /// The webhook itself de-dupes per `sid + uid`, but marking `completedAt`
  /// twice would needlessly re-touch the member node, and a reconnect can
  /// re-fire the `finished` phase several times.
  final Set<String> _completedRuns = <String>{};

  /// Starts the device-side focus run for [session].
  ///
  /// [focus] is the live focus notifier — passed in rather than looked up so
  /// this stays a plain object that a test can drive, and so the caller keeps
  /// owning the widget/provider lifetime.
  Future<void> startRun({
    required SharedSession session,
    required FocusModeNotifier focus,
  }) async {
    // Starting a run twice would snapshot the shared profile over itself (see
    // `FocusModeNotifier.startSessionFromSharedSettings`), so guard on the
    // engine's own notion of whether a shared run is already in flight.
    if (focus.isInSharedSessionFocus) return;

    await focus.startSessionFromSharedSettings(
      settings: session.groupFocusSettings,
      sessionId: session.id,
    );
    debugPrint('SessionFocusBridge: started shared focus for ${session.id}');
  }

  /// Counts one focus break against the signed-in member for [sessionId].
  Future<void> reportBreak(String sessionId) =>
      SessionService.instance.reportBreak(sessionId: sessionId);

  /// Records the member's completion for [session] and asks the server to
  /// verify it. Runs at most once per session per app launch.
  Future<void> completeRun(SharedSession session) async {
    if (!_completedRuns.add(session.id)) return;

    await SessionService.instance.markCompleted(sessionId: session.id);
    await SessionCompletionService.instance.reportCompletion(session.id);
    debugPrint('SessionFocusBridge: completed shared run for ${session.id}');
  }

  /// Whether the member's completion has already been reported this launch.
  bool hasCompleted(String sessionId) => _completedRuns.contains(sessionId);

  /// Clears the per-launch bookkeeping — for sign-out and tests.
  @visibleForTesting
  void reset() => _completedRuns.clear();
}
