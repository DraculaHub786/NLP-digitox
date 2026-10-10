// Copyright (c) 2026 NLP digitox

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
// Material's own `Badge` widget never appears here; the earned-badge model is
// the only `Badge` this file uses.
import 'package:flutter/material.dart' hide Badge;
import 'package:nlp_digitox/config/navigation/navigation_service.dart';
import 'package:nlp_digitox/core/services/badge_celebration_service.dart';
import 'package:nlp_digitox/models/badge_model.dart';
import 'package:nlp_digitox/ui/dialogs/badge_celebration_dialog.dart';

/// The app-lifecycle half of [BadgeCelebrationService].
///
/// The service knows *what* is new; this widget owns *when* it is shown. It
/// starts the watch on sign-in, stops it on sign-out, and shows one celebration
/// at a time so a backlog of badges is a sequence of dialogs rather than a
/// stack of them.
///
/// It sits in `MaterialApp.builder`, which is *above* the Navigator, so
/// `Navigator.of(context)` is unavailable here. Dialogs are therefore shown
/// through [NavigationService.navigatorKey], the same global navigator the
/// deep-link and notification handlers already use.
///
/// This widget paints nothing — it renders [child] unchanged.
class BadgeCelebrationObserver extends StatefulWidget {
  const BadgeCelebrationObserver({
    super.key,
    required this.child,
    this.service,
  });

  final Widget child;

  /// Injected by tests. Production builds create their own.
  final BadgeCelebrationService? service;

  @override
  State<BadgeCelebrationObserver> createState() =>
      _BadgeCelebrationObserverState();
}

class _BadgeCelebrationObserverState extends State<BadgeCelebrationObserver> {
  /// How long to wait for the Navigator to exist before giving up on a
  /// celebration.
  ///
  /// A badge can arrive before the first route is on screen — a cold start that
  /// lands on the splash screen still authenticates, and the Firestore snapshot
  /// can resolve in that window. Twenty tries at 250 ms covers the splash.
  static const int _maxNavigatorWaits = 20;
  static const Duration _navigatorWaitInterval = Duration(milliseconds: 250);

  late final BadgeCelebrationService _service;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<Badge>? _celebrationSubscription;

  /// Badges waiting to be shown, oldest first.
  final List<Badge> _pending = <Badge>[];

  /// True while a celebration dialog is on screen, so [_drain] cannot start a
  /// second one on top of it.
  bool _isShowing = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? BadgeCelebrationService();

    // `authStateChanges` fires `null` first on a signed-out cold start. That is
    // ignored by `_onAuthChanged` — there is no uid to watch yet.
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
          _onAuthChanged,
        );
    _celebrationSubscription = _service.celebrations.listen(_onCelebration);
  }

  void _onAuthChanged(User? user) {
    if (user == null) {
      // Signing out must stop the Firestore query, and any celebration still
      // queued belongs to the account that just left.
      _service.stop();
      _pending.clear();
      return;
    }
    _service.start(user.uid);
  }

  void _onCelebration(Badge badge) {
    _pending.add(badge);
    unawaited(_drain());
  }

  /// Shows queued celebrations one at a time, in order.
  Future<void> _drain() async {
    if (_isShowing) return;
    _isShowing = true;

    try {
      while (_pending.isNotEmpty && mounted) {
        final badge = _pending.first;
        final context = await _awaitNavigator();
        // Re-checked here, in the same function as the use below: the lint (and
        // the real risk) is about the gap between this await and the
        // `showGeneralDialog` call, which a guard inside `_awaitNavigator`
        // cannot cover.
        if (context == null || !context.mounted) {
          // No navigator after the full wait: the app is not in a state where a
          // dialog means anything. Drop the queue rather than holding a stale
          // list that would surface minutes later out of context — the badge is
          // already recorded as seen, so it is never celebrated twice.
          debugPrint(
            'BadgeCelebrationObserver: navigator unavailable, '
            'skipping ${_pending.length} celebration(s)',
          );
          _pending.clear();
          return;
        }

        _pending.removeAt(0);
        await showBadgeCelebrationDialog(context, badge);
      }
    } finally {
      _isShowing = false;
    }
  }

  /// Waits for [NavigationService.navigatorKey] to have a mounted context.
  Future<BuildContext?> _awaitNavigator() async {
    for (var attempt = 0; attempt < _maxNavigatorWaits; attempt++) {
      if (!mounted) return null;

      final context = NavigationService.navigatorKey.currentContext;
      if (context != null && context.mounted) return context;

      await Future<void>.delayed(_navigatorWaitInterval);
    }
    return null;
  }

  @override
  void dispose() {
    _pending.clear();
    _authSubscription?.cancel();
    _celebrationSubscription?.cancel();
    unawaited(_service.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
