// Copyright (c) 2026 NLP digitox

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/services/badge_seen_store.dart';
import 'package:nlp_digitox/models/badge_model.dart';

/// Reads the signed-in user's badges as they change.
///
/// Injected so the service can be driven from a test stream instead of
/// Firestore. The default is [firestoreBadgeSource].
typedef BadgeSource = Stream<List<Badge>> Function(String userId);

/// The production [BadgeSource]: the `badges` collection filtered by `userId`.
///
/// This is the same query the Achievements screen runs, and the only shape
/// `firestore.rules` allows — `list` is gated on
/// `resource.data.userId == request.auth.uid`, so asking for another user's
/// badges is denied rather than merely empty. Sorting happens in Dart because a
/// `where` on `userId` plus an `orderBy` on a different field would need a
/// composite index.
Stream<List<Badge>> firestoreBadgeSource(String userId) {
  return FirebaseFirestore.instance
      .collection('badges')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => Badge.fromFirestore(doc.data(), doc.id))
            .toList(),
      );
}

/// What one snapshot of the badge list should do.
class BadgeCelebrationPlan {
  const BadgeCelebrationPlan({
    required this.toCelebrate,
    required this.nextSeen,
  });

  /// Badges worth interrupting the user for, newest first.
  final List<Badge> toCelebrate;

  /// The celebrated set to persist. It always contains every id in
  /// [toCelebrate] — a badge is marked seen at the moment it is detected, so a
  /// crash between detection and display can lose a celebration but can never
  /// repeat one.
  final Set<String> nextSeen;
}

/// Works out which of [badges] have not been celebrated yet, given [seen].
///
/// [seen] is `null` on the first sighting of an account, and that case
/// celebrates nothing on purpose: n8n writes badges in arrears, so "everything
/// on the server" would mean a burst of celebrations for wins from weeks ago
/// the moment the app is opened on a fresh install. The baseline records them
/// silently instead.
///
/// Pure, so the rule above can be tested without Firestore or prefs.
BadgeCelebrationPlan planBadgeCelebration({
  required Set<String>? seen,
  required List<Badge> badges,
}) {
  final currentIds = badges.map((badge) => badge.id).toSet();

  if (seen == null) {
    return BadgeCelebrationPlan(toCelebrate: const [], nextSeen: currentIds);
  }

  final fresh = badges.where((badge) => !seen.contains(badge.id)).toList()
    ..sort((a, b) => b.earnedAt.compareTo(a.earnedAt));

  return BadgeCelebrationPlan(
    toCelebrate: fresh,
    // Union rather than replacement: a badge that vanishes from the server (an
    // n8n re-run, a manual delete) has to stay "seen", or it would be
    // celebrated a second time if it ever came back.
    nextSeen: {...seen, ...currentIds},
  );
}

/// Watches for newly earned badges and announces each one exactly once.
///
/// This is the app-wide half of "celebrate a new badge". The Achievements
/// screen only renders badges while it is open, so a badge earned while the
/// user was elsewhere was previously invisible until they happened to look at
/// that screen. This service watches for the whole session instead.
class BadgeCelebrationService {
  BadgeCelebrationService({
    BadgeSeenStore? seenStore,
    BadgeSource? badgeSource,
  })  : _seenStore = seenStore ?? const SharedPrefsBadgeSeenStore(),
        _badgeSource = badgeSource ?? firestoreBadgeSource;

  final BadgeSeenStore _seenStore;
  final BadgeSource _badgeSource;

  final StreamController<Badge> _celebrations =
      StreamController<Badge>.broadcast();

  /// Newly earned badges, one event each, oldest first so a backlog is shown in
  /// the order it was won.
  Stream<Badge> get celebrations => _celebrations.stream;

  StreamSubscription<List<Badge>>? _subscription;

  /// Serialises snapshot handling.
  ///
  /// Two Firestore snapshots can arrive back to back, and `readSeen`/`writeSeen`
  /// are async: without this chain both would read the same seen set and both
  /// would celebrate the same badge.
  Future<void> _queue = Future<void>.value();

  String? _activeUserId;

  /// Starts watching [userId].
  ///
  /// Calling it again for the same user is a no-op, so an auth listener can
  /// fire repeatedly without restarting the Firestore query. A different user
  /// replaces the previous watch.
  void start(String userId) {
    if (_activeUserId == userId && _subscription != null) return;
    stop();
    _activeUserId = userId;

    _subscription = _badgeSource(userId).listen(
      (badges) {
        _queue = _queue.then((_) => _handleSnapshot(userId, badges));
      },
      onError: (Object error) {
        // A denied, offline or index-missing read must not take the app down.
        // The Achievements screen reports read failures in its own right.
        debugPrint('BadgeCelebrationService: badge stream error: $error');
      },
    );
  }

  /// Stops watching. Safe to call when nothing is running.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _activeUserId = null;
  }

  Future<void> _handleSnapshot(String userId, List<Badge> badges) async {
    // The user may have signed out while this snapshot was in flight.
    if (_activeUserId != userId) return;

    try {
      final seen = await _seenStore.readSeen(userId);
      final plan = planBadgeCelebration(seen: seen, badges: badges);

      // Persist before announcing: an id that is displayed but not stored would
      // be celebrated again on every subsequent snapshot.
      await _seenStore.writeSeen(userId, plan.nextSeen);

      for (final badge in plan.toCelebrate.reversed) {
        if (!_celebrations.isClosed) _celebrations.add(badge);
      }
    } catch (e) {
      debugPrint('BadgeCelebrationService: failed to process badges: $e');
    }
  }

  /// Releases the Firestore subscription and closes [celebrations].
  Future<void> dispose() async {
    stop();
    await _celebrations.close();
  }
}
