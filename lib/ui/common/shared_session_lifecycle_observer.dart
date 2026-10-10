// Copyright (c) 2026 NLP digitox

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/session_completion_reconciler.dart';
import 'package:nlp_digitox/providers/focus/focus_mode_provider.dart';

/// Owns the app-lifecycle half of [SessionCompletionReconciler].
///
/// The reconciler is what reports a shared run that finished while no screen
/// was watching it — the normal case when the phone is face-down for the whole
/// run. It has to run from somewhere that survives the whole app and is told
/// about every way back in, so it is driven here rather than from a session
/// screen that is only mounted while the user is looking at it.
///
/// It runs on three triggers, which together cover every path:
///   * first mount — a cold start with a run already finished;
///   * every return to the foreground — the phone being unlocked after the run
///     ended in the background;
///   * a fresh sign-in — a cold start that landed on the login screen has no
///     uid to read, and the sessions only become readable afterwards.
///
/// It is a `ConsumerStatefulWidget` rather than a plain one so it can hand the
/// reconciler the live focus engine: that is what lets a session the host
/// *cancelled* stop the member's own in-flight group focus run, even when the
/// lobby screen that would otherwise do it was never on screen.
///
/// This widget paints nothing — it renders [child] unchanged.
class SharedSessionLifecycleObserver extends ConsumerStatefulWidget {
  const SharedSessionLifecycleObserver({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SharedSessionLifecycleObserver> createState() =>
      _SharedSessionLifecycleObserverState();
}

class _SharedSessionLifecycleObserverState
    extends ConsumerState<SharedSessionLifecycleObserver>
    with WidgetsBindingObserver {
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      // Fires `null` first for a signed-out cold start, which is deliberately
      // ignored — there is no session to reconcile against yet.
      if (user == null) return;
      _reconcile();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _reconcile();
  }

  /// Runs the reconciler with the live focus engine.
  ///
  /// The notifier is read here, at call time, rather than held as a field: the
  /// reconciler only needs it to end a run whose session was cancelled, and
  /// reading it lazily keeps the focus engine's own initialisation where it
  /// already was.
  void _reconcile() {
    unawaited(
      SessionCompletionReconciler.instance.reconcile(
        focus: ref.read(focusModeProvider.notifier),
      ),
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
