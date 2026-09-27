// Copyright (c) 2026 NLP digitox

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/services/wellbeing_report_scheduler_service.dart';

/// Owns the app-lifecycle half of [WellbeingReportSchedulerService].
///
/// The scheduler cannot be started from `Initializer.initializeServicesAndSchedules()`
/// because that entry point is also called from the background isolate (see
/// `BgExecutorService`), which has no widget tree, no `WidgetsBindingObserver`
/// and must not be kept alive by a pending timer. Starting it here instead
/// guarantees there is exactly one in-process timer, owned by the main isolate.
///
/// Responsibilities:
///  * arm the end-of-day timer once, on first mount;
///  * re-arm it and re-check the monthly request marker whenever the app
///    returns to the foreground, since the OS suspends timers while backgrounded
///    and the marker may have been written while the app was closed;
///  * re-run the same checks after a fresh sign-in, because the catch-up scorer
///    and the report generator both require an authenticated Firebase user and
///    would otherwise no-op on a cold start that landed on the login screen.
///
/// This widget paints nothing — it renders [child] unchanged.
class WellbeingReportLifecycleObserver extends StatefulWidget {
  const WellbeingReportLifecycleObserver({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<WellbeingReportLifecycleObserver> createState() =>
      _WellbeingReportLifecycleObserverState();
}

class _WellbeingReportLifecycleObserverState
    extends State<WellbeingReportLifecycleObserver>
    with WidgetsBindingObserver {
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Marks the current user as needing the scheduled work. Fires `null` first
    // for a signed-out cold start, which is intentionally ignored — there is
    // no uid to score or report against yet.
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) return;
      unawaited(WellbeingReportSchedulerService.instance.onAppResumed());
    });

    unawaited(WellbeingReportSchedulerService.instance.initialize());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(WellbeingReportSchedulerService.instance.onAppResumed());
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    if (kDebugMode) {
      debugPrint('WellbeingReportLifecycleObserver: disposed');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
