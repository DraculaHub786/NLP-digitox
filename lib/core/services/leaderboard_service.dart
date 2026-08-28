import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Which scoring window a leaderboard view is showing.
///
/// Points are now stored across three Firestore collections:
///   - `leaderboard/{uid}`            → the **lifetime** record. Never resets.
///   - `weekly_leaderboard/{uid}`     → this week's score only. Resets weekly.
///   - `monthly_leaderboard/{uid}`    → this month's score only. Resets monthly.
///
/// Resets are performed exclusively by the external n8n workflows (see the
/// `N8N_LEADERBOARD_WORKFLOWS_GUIDE.md` / the human-installed
/// `[Digitox] Weekly/Monthly Leaderboard Winner` workflows) using the
/// Firebase Admin SDK, which bypasses firestore.rules. The client never
/// writes a reset — firestore.rules intentionally forbids that, so nothing
/// below attempts to write points to 0 from the app.
enum LeaderboardPeriod { weekly, monthly }

extension LeaderboardPeriodX on LeaderboardPeriod {
  /// Firestore field on the period-collection doc that holds this period's score.
  /// Both `weekly_leaderboard` and `monthly_leaderboard` use a `points` field.
  String get field => 'points';

  /// Doc id under `leaderboard_config` that the reset workflow updates.
  String get configDocId =>
      this == LeaderboardPeriod.weekly ? 'weekly_reset' : 'monthly_reset';

  String get label => this == LeaderboardPeriod.weekly ? 'Weekly' : 'Monthly';
}

/// The Firestore collection that holds this period's leaderboard docs.
extension LeaderboardPeriodCollectionX on LeaderboardPeriod {
  String get collectionName =>
      this == LeaderboardPeriod.weekly ? 'weekly_leaderboard' : 'monthly_leaderboard';
}

/// Read-only info about the last/next server-side reset for a period.
/// Populated entirely from `leaderboard_config/{weekly_reset|monthly_reset}`,
/// which only the reset workflows may write.
class LeaderboardResetInfo {
  final LeaderboardPeriod period;
  final DateTime lastResetDate;
  final DateTime? nextResetDate;
  final int cycleNumber;
  final String? cycleLabel;

  const LeaderboardResetInfo({
    required this.period,
    required this.lastResetDate,
    required this.nextResetDate,
    required this.cycleNumber,
    this.cycleLabel,
  });

  Duration? get timeUntilReset =>
      nextResetDate?.difference(DateTime.now());

  /// Short display string e.g. "Resets in 3d 4h" / "Resets in 6h" / "Resetting soon".
  String get resetCountdownLabel {
    final remaining = timeUntilReset;
    if (remaining == null) return 'Reset schedule unavailable';
    if (remaining.isNegative) return 'Resetting soon';

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;

    if (days > 0) return 'Resets in ${days}d ${hours}h';
    if (remaining.inHours > 0) return 'Resets in ${remaining.inHours}h';
    return 'Resets in ${remaining.inMinutes}m';
  }
}

/// Model for leaderboard user data
class LeaderboardUser {
  final String userId;
  final String username;
  final int points;
  final int streak;
  final String? avatarEmoji;
  final int rank;
  final bool isCurrentUser;
  final Map<String, int>? pointsBreakdown;
  final int lifetimePoints;
  final int monthlyPoints;
  final DateTime? lastActiveAt;
  final String? email;

  LeaderboardUser({
    required this.userId,
    required this.username,
    required this.points,
    required this.streak,
    this.avatarEmoji,
    required this.rank,
    required this.isCurrentUser,
    this.pointsBreakdown,
    required this.lifetimePoints,
    this.monthlyPoints = 0,
    this.lastActiveAt,
    this.email,
  });

  /// The score relevant to a given leaderboard view.
  ///
  /// Weekly/monthly docs carry their period score in `points`. Lifetime docs
  /// carry the all-time total in `lifetimePoints`. When the current user is
  /// merged from a period doc + lifetime doc (see `getCurrentUserData` and
  /// `streamTopUsers`), `points` holds the period score and `monthlyPoints`
  /// mirrors it so either tab reads correctly.
  int scoreFor(LeaderboardPeriod period) =>
      period == LeaderboardPeriod.weekly ? points : monthlyPoints;

  /// Build a user from a `weekly_leaderboard` or `monthly_leaderboard` doc.
  ///
  /// Period docs only carry `points`, `username`, `avatarEmoji`,
  /// `lastActiveAt` — lifetime/streak/breakdown live on the lifetime doc and
  /// are merged in by the service when needed.
  factory LeaderboardUser.fromPeriodDoc(
    DocumentSnapshot doc,
    int rank,
    String currentUserId,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    final points = data['points'] ?? 0;
    return LeaderboardUser(
      userId: doc.id,
      username: data['username'] ?? 'Anonymous',
      points: points,
      streak: data['streak'] ?? 0,
      avatarEmoji: data['avatarEmoji'] ?? '👤',
      rank: rank,
      isCurrentUser: doc.id == currentUserId,
      pointsBreakdown: data['pointsBreakdown'] != null
          ? Map<String, int>.from(data['pointsBreakdown'])
          : null,
      lifetimePoints: data['lifetimePoints'] ?? 0,
      // Mirror the period score so `scoreFor(monthly)` works on a doc that
      // was read from the monthly collection (which also uses `points`).
      monthlyPoints: points,
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate(),
      email: data['email'] as String?,
    );
  }

  /// Build a user from the lifetime `leaderboard/{uid}` doc.
  ///
  /// The lifetime doc carries `lifetimePoints`, `streak`, `pointsBreakdown`,
  /// `username`, `lastActiveAt`. Period scores are NOT stored here anymore —
  /// they live in the period collections.
  factory LeaderboardUser.fromLifetimeDoc(
    DocumentSnapshot doc,
    int rank,
    String currentUserId,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardUser(
      userId: doc.id,
      username: data['username'] ?? 'Anonymous',
      points: data['points'] ?? 0,
      streak: data['streak'] ?? 0,
      avatarEmoji: data['avatarEmoji'] ?? '👤',
      rank: rank,
      isCurrentUser: doc.id == currentUserId,
      pointsBreakdown: data['pointsBreakdown'] != null
          ? Map<String, int>.from(data['pointsBreakdown'])
          : null,
      lifetimePoints: data['lifetimePoints'] ?? 0,
      monthlyPoints: data['monthlyPoints'] ?? 0,
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate(),
      email: data['email'] as String?,
    );
  }

  factory LeaderboardUser.fromFirestore(
    DocumentSnapshot doc,
    int rank,
    String currentUserId,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardUser(
      userId: doc.id,
      username: data['username'] ?? 'Anonymous',
      points: data['points'] ?? 0,
      streak: data['streak'] ?? 0,
      avatarEmoji: data['avatarEmoji'] ?? '👤',
      rank: rank,
      isCurrentUser: doc.id == currentUserId,
      pointsBreakdown: data['pointsBreakdown'] != null
          ? Map<String, int>.from(data['pointsBreakdown'])
          : null,
      lifetimePoints: data['lifetimePoints'] ?? 0,
      monthlyPoints: data['monthlyPoints'] ?? 0,
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate(),
      email: data['email'] as String?,
    );
  }

  /// Create a copy of this user with lifetime fields overlaid from a lifetime
  /// doc. Used to enrich a period-board row so the signed-in user still shows
  /// streak / lifetime / breakdown on screens that use `streamTopUsers`.
  LeaderboardUser mergeLifetime({
    required int lifetimePoints,
    required int streak,
    Map<String, int>? pointsBreakdown,
    String? email,
  }) {
    return LeaderboardUser(
      userId: userId,
      username: username,
      points: points,
      streak: streak,
      avatarEmoji: avatarEmoji,
      rank: rank,
      isCurrentUser: isCurrentUser,
      pointsBreakdown: pointsBreakdown ?? this.pointsBreakdown,
      lifetimePoints: lifetimePoints,
      monthlyPoints: monthlyPoints,
      lastActiveAt: lastActiveAt,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'points': points,
      'streak': streak,
      'avatarEmoji': avatarEmoji ?? '👤',
      'pointsBreakdown': pointsBreakdown ?? {},
      'lifetimePoints': lifetimePoints,
      'monthlyPoints': monthlyPoints,
      if (email != null) 'email': email,
      'lastUpdated': FieldValue.serverTimestamp(),
      'lastActiveAt': lastActiveAt != null
          ? Timestamp.fromDate(lastActiveAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}

/// Leaderboard Service
/// Handles fetching and updating leaderboard data from Firestore.
///
/// IMPORTANT: this service never resets anyone's points. Weekly/monthly
/// resets are performed externally via the n8n workflows (see
/// `N8N_LEADERBOARD_WORKFLOWS_GUIDE.md`) using the Admin SDK, which is
/// required because firestore.rules deliberately blocks the client from
/// writing other users' docs or the `leaderboard_config` collection.
class LeaderboardService {
  LeaderboardService._();
  static final LeaderboardService instance = LeaderboardService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<LeaderboardPeriod, List<LeaderboardUser>> _cachedLeaderboard = {};
  final Map<LeaderboardPeriod, DateTime> _lastFetchTime = {};
  static const _cacheDuration = Duration(minutes: 5);

  static const String _leaderboardConfigCollection = 'leaderboard_config';

  // Streak evaluation tracking (unrelated to points reset — unchanged)
  Timer? _streakEvaluationTimer;
  static const String _lastStreakEvalDateKey =
      'leaderboard_last_streak_eval_date';
  static const int _screenTimeStreakThresholdSec = 8 * 60 * 60; // 8 hours

  // =========================================================================
  // FETCH / READ
  // =========================================================================

  /// Sorts a fetched list deterministically and assigns 1-based ranks.
  ///
  /// Firestore's `orderBy(field, descending: true)` returns an unspecified
  /// order for equal scores. After a weekly/monthly reset the entire board
  /// ties on 0, so without this tie-break the visible order (and the
  /// "current user" position) would be arbitrary and could change between
  /// snapshots. Ties are broken by most-recent activity first, then by
  /// username for full determinism.
  static List<LeaderboardUser> _sortAndRank(
    List<LeaderboardUser> users,
    LeaderboardPeriod period,
  ) {
    final sorted = [...users]..sort((a, b) {
        final scoreDiff = b.scoreFor(period).compareTo(a.scoreFor(period));
        if (scoreDiff != 0) return scoreDiff;

        // More recently active ranks higher among tied scores.
        final aActive = a.lastActiveAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bActive = b.lastActiveAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final activeDiff = bActive.compareTo(aActive);
        if (activeDiff != 0) return activeDiff;

        return a.username.toLowerCase().compareTo(b.username.toLowerCase());
      });

    for (var i = 0; i < sorted.length; i++) {
      sorted[i] = LeaderboardUser(
        userId: sorted[i].userId,
        username: sorted[i].username,
        points: sorted[i].points,
        streak: sorted[i].streak,
        avatarEmoji: sorted[i].avatarEmoji,
        rank: i + 1,
        isCurrentUser: sorted[i].isCurrentUser,
        pointsBreakdown: sorted[i].pointsBreakdown,
        lifetimePoints: sorted[i].lifetimePoints,
        monthlyPoints: sorted[i].monthlyPoints,
        lastActiveAt: sorted[i].lastActiveAt,
        email: sorted[i].email,
      );
    }
    return sorted;
  }

  Future<List<LeaderboardUser>> getTopUsers({
    LeaderboardPeriod period = LeaderboardPeriod.weekly,
    int limit = 100,
  }) async {
    try {
      final cached = _cachedLeaderboard[period];
      final fetchedAt = _lastFetchTime[period];
      if (cached != null &&
          fetchedAt != null &&
          DateTime.now().difference(fetchedAt) < _cacheDuration) {
        debugPrint('Returning cached ${period.label} leaderboard data');
        return cached;
      }

      final currentUserId = FirebaseAuthService.instance.userId ?? '';

      // Query the period-specific collection directly, ordered by score.
      // Every period doc has a `points` field, so `orderBy('points')` only
      // returns users who have earned points this period — exactly the set
      // the board should show.
      final querySnapshot = await _firestore
          .collection(period.collectionName)
          .orderBy('points', descending: true)
          .limit(limit)
          .get();

      final users = querySnapshot.docs.map((doc) {
        return LeaderboardUser.fromPeriodDoc(doc, 0, currentUserId);
      }).toList();

      var ranked = _sortAndRank(users, period);

      // Enrich the signed-in user with lifetime/streak/breakdown from the
      // lifetime doc so profile/achievements/leaderboard cards that read
      // `.lifetimePoints` / `.streak` stay correct.
      final currentUserIndex = ranked.indexWhere(
        (u) => u.userId == currentUserId,
      );
      if (currentUserId.isNotEmpty && currentUserIndex != -1) {
        ranked[currentUserIndex] = await _mergeCurrentUserLifetime(
          ranked[currentUserIndex],
        );
      }

      final trimmed = limit > 0 && ranked.length > limit
          ? ranked.sublist(0, limit)
          : ranked;

      _cachedLeaderboard[period] = trimmed;
      _lastFetchTime[period] = DateTime.now();

      debugPrint('Fetched ${trimmed.length} users (${period.label})');
      return trimmed;
    } catch (e) {
      debugPrint('Get leaderboard error (${period.label}): $e');
      return [];
    }
  }

  /// Get current user's leaderboard data + rank for a given period.
  Future<LeaderboardUser?> getCurrentUserData({
    LeaderboardPeriod period = LeaderboardPeriod.weekly,
  }) async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) return null;

      final periodRef = _firestore.collection(period.collectionName).doc(userId);
      final lifetimeRef = _firestore.collection('leaderboard').doc(userId);

      // Fetch the two independent reads in parallel.
      final results = await Future.wait([
        periodRef.get(),
        lifetimeRef.get(),
      ]);
      final periodDoc = results[0] as DocumentSnapshot;
      final lifetimeDoc = results[1] as DocumentSnapshot;

      if (!periodDoc.exists && !lifetimeDoc.exists) return null;

      final periodData =
          periodDoc.exists ? periodDoc.data() as Map<String, dynamic> : null;
      final lifetimeData = lifetimeDoc.exists
          ? lifetimeDoc.data() as Map<String, dynamic>
          : null;

      final userScore = (periodData?['points'] ?? 0) as int;
      final higherRankedCount = await _firestore
          .collection(period.collectionName)
          .where('points', isGreaterThan: userScore)
          .count()
          .get();

      final rank = higherRankedCount.count! + 1;

      final username =
          (periodData?['username'] ?? lifetimeData?['username']) as String? ??
              'Anonymous';
      final avatarEmoji =
          (periodData?['avatarEmoji'] ?? lifetimeData?['avatarEmoji']) as String? ??
              '👤';
      final lifetimePoints = (lifetimeData?['lifetimePoints'] ?? 0) as int;
      final streak = (lifetimeData?['streak'] ?? 0) as int;
      final breakdown = lifetimeData?['pointsBreakdown'] != null
          ? Map<String, int>.from(lifetimeData!['pointsBreakdown'])
          : null;
      final lastActiveAt =
          (periodData?['lastActiveAt'] ?? lifetimeData?['lastActiveAt'] as Timestamp?)
              ?.toDate();

      return LeaderboardUser(
        userId: userId,
        username: username,
        points: userScore,
        streak: streak,
        avatarEmoji: avatarEmoji,
        rank: rank,
        isCurrentUser: true,
        pointsBreakdown: breakdown,
        lifetimePoints: lifetimePoints,
        monthlyPoints: userScore,
        lastActiveAt: lastActiveAt,
        email: lifetimeData?['email'] as String?,
      );
    } catch (e) {
      debugPrint('Get current user data error (${period.label}): $e');
      return null;
    }
  }

  /// Merge lifetime fields (lifetimePoints, streak, breakdown) onto a
  /// period-board user row by reading the lifetime doc once.
  Future<LeaderboardUser> _mergeCurrentUserLifetime(
    LeaderboardUser periodUser,
  ) async {
    try {
      final lifetimeDoc =
          await _firestore.collection('leaderboard').doc(periodUser.userId).get();
      if (!lifetimeDoc.exists) return periodUser;

      final data = lifetimeDoc.data() as Map<String, dynamic>;
      return periodUser.mergeLifetime(
        lifetimePoints: (data['lifetimePoints'] ?? 0) as int,
        streak: (data['streak'] ?? 0) as int,
        pointsBreakdown: data['pointsBreakdown'] != null
            ? Map<String, int>.from(data['pointsBreakdown'])
            : null,
        email: data['email'] as String?,
      );
    } catch (e) {
      debugPrint('Merge current user lifetime error: $e');
      return periodUser;
    }
  }

  /// Read-only reset schedule info for a period. Returns null until the
  /// corresponding reset workflow has run at least once (i.e. the
  /// `leaderboard_config/{weekly_reset|monthly_reset}` doc exists).
  Future<LeaderboardResetInfo?> getResetInfo(LeaderboardPeriod period) async {
    try {
      final doc = await _firestore
          .collection(_leaderboardConfigCollection)
          .doc(period.configDocId)
          .get();

      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;

      final lastReset = (data['lastResetDate'] as Timestamp?)?.toDate();
      final nextReset = (data['nextResetDate'] as Timestamp?)?.toDate();
      if (lastReset == null) return null;

      return LeaderboardResetInfo(
        period: period,
        lastResetDate: lastReset,
        nextResetDate: nextReset,
        cycleNumber: (data['cycleNumber'] ?? 0) as int,
        cycleLabel: data['cycleLabel'] as String?,
      );
    } catch (e) {
      debugPrint('Get reset info error (${period.label}): $e');
      return null;
    }
  }

  // =========================================================================
  // WRITE / UPDATE
  // =========================================================================

  /// Update user's leaderboard data.
  /// Preserves existing points and lifetimePoints from Firestore if they exist.
  /// If this is the first write (new user), seeds email from Firebase Auth.
  Future<void> updateUserData({
    required String username,
    int? points,
    int? streak,
    String? avatarEmoji,
    Map<String, int>? pointsBreakdown,
  }) async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final existingDoc =
          await _firestore.collection('leaderboard').doc(userId).get();

      final existingPoints = existingDoc.exists
          ? (existingDoc.data()?['points'] ?? 0) as int
          : 0;
      final existingStreak = existingDoc.exists
          ? (existingDoc.data()?['streak'] ?? 0) as int
          : 0;
      final existingLifetimePoints = existingDoc.exists
          ? (existingDoc.data()?['lifetimePoints'] ?? 0) as int
          : 0;
      final existingMonthlyPoints = existingDoc.exists
          ? (existingDoc.data()?['monthlyPoints'] ?? 0) as int
          : 0;
      final existingBreakdown = existingDoc.exists
          ? Map<String, int>.from(
              existingDoc.data()?['pointsBreakdown'] ?? {})
          : <String, int>{};

      final leaderboardUser = LeaderboardUser(
        userId: userId,
        username: username,
        points: points ?? existingPoints,
        streak: streak ?? existingStreak,
        avatarEmoji: avatarEmoji,
        rank: 0,
        isCurrentUser: true,
        pointsBreakdown: pointsBreakdown ?? existingBreakdown,
        lifetimePoints: existingLifetimePoints,
        monthlyPoints: existingMonthlyPoints,
        lastActiveAt: DateTime.now(),
        email: FirebaseAuthService.instance.userEmail,
      );

      await _firestore
          .collection('leaderboard')
          .doc(userId)
          .set(leaderboardUser.toMap(), SetOptions(merge: true));

      clearCache();

      debugPrint(
        'Updated user leaderboard data: ${leaderboardUser.points} weekly, '
        '${leaderboardUser.monthlyPoints} monthly, '
        '${leaderboardUser.lifetimePoints} lifetime',
      );
    } catch (e) {
      debugPrint('Update leaderboard error: $e');
      throw Exception('Failed to update leaderboard');
    }
  }

  /// Add points to current user.
  ///
  /// Fanned out to all three collections in a single transaction:
  ///   - `leaderboard/{uid}`          → lifetimePoints + pointsBreakdown
  ///   - `weekly_leaderboard/{uid}`   → points (weekly score)
  ///   - `monthly_leaderboard/{uid}`  → points (monthly score)
  ///
  /// If any doc does not exist yet, seeds username/email/avatarEmoji so the
  /// user shows correctly on the board before `updateUserData` runs.
  Future<void> addPoints(int points, String category) async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) return;

      final lifetimeRef = _firestore.collection('leaderboard').doc(userId);
      final weeklyRef = _firestore.collection('weekly_leaderboard').doc(userId);
      final monthlyRef = _firestore.collection('monthly_leaderboard').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final lifetimeSnap = await transaction.get(lifetimeRef);
        final weeklySnap = await transaction.get(weeklyRef);
        final monthlySnap = await transaction.get(monthlyRef);

        final currentLifetime = lifetimeSnap.exists
            ? (lifetimeSnap.data()?['lifetimePoints'] ?? 0) as int
            : 0;
        final currentBreakdown = lifetimeSnap.exists
            ? Map<String, int>.from(lifetimeSnap.data()?['pointsBreakdown'] ?? {})
            : <String, int>{};
        final currentWeekly = weeklySnap.exists
            ? (weeklySnap.data()?['points'] ?? 0) as int
            : 0;
        final currentMonthly = monthlySnap.exists
            ? (monthlySnap.data()?['points'] ?? 0) as int
            : 0;

        currentBreakdown[category] = (currentBreakdown[category] ?? 0) + points;

        final auth = FirebaseAuthService.instance;
        final baseIdentity = <String, dynamic>{
          'username': auth.userDisplayName ?? 'User',
          'avatarEmoji': '👤',
        };

        transaction.set(lifetimeRef, {
          if (!lifetimeSnap.exists) ...baseIdentity,
          if (!lifetimeSnap.exists) 'email': auth.userEmail,
          'lifetimePoints': currentLifetime + points,
          'pointsBreakdown': currentBreakdown,
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastActiveAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        transaction.set(weeklyRef, {
          if (!weeklySnap.exists) ...baseIdentity,
          'points': currentWeekly + points,
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastActiveAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        transaction.set(monthlyRef, {
          if (!monthlySnap.exists) ...baseIdentity,
          'points': currentMonthly + points,
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastActiveAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      clearCache();
      debugPrint('Added $points points to $category (fanned out to 3 collections)');
    } catch (e) {
      debugPrint('Add points error: $e');
    }
  }

  /// Update streak value in Firestore.
  Future<void> updateStreak(int newStreak) async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) return;

      await _firestore.collection('leaderboard').doc(userId).set({
        'streak': newStreak,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      clearCache();
      debugPrint('Updated streak to $newStreak');
    } catch (e) {
      debugPrint('Update streak error: $e');
    }
  }

  // =========================================================================
  // CACHE
  // =========================================================================

  /// Clear cache for all periods (call when user manually refreshes).
  void clearCache() {
    _cachedLeaderboard.clear();
    _lastFetchTime.clear();
  }

  /// Stream leaderboard updates (real-time) for a given period.
  Stream<List<LeaderboardUser>> streamTopUsers({
    LeaderboardPeriod period = LeaderboardPeriod.weekly,
    int limit = 100,
  }) {
    final currentUserId = FirebaseAuthService.instance.userId ?? '';

    return _firestore
        .collection(period.collectionName)
        .orderBy('points', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
      var ranked = snapshot.docs.map((doc) {
        return LeaderboardUser.fromPeriodDoc(doc, 0, currentUserId);
      }).toList();

      ranked = _sortAndRank(ranked, period);

      // Always surface the signed-in user: if their doc fell outside the
      // fetch cap (or doesn't exist in the collection yet), merge a fresh
      // read so their rank + stats never silently disappear from the board.
      final currentUserIndex = ranked.indexWhere(
        (u) => u.userId == currentUserId,
      );
      if (currentUserId.isNotEmpty && currentUserIndex == -1) {
        final currentDoc = await _firestore
            .collection(period.collectionName)
            .doc(currentUserId)
            .get();
        if (currentDoc.exists) {
          ranked.add(
            LeaderboardUser.fromPeriodDoc(currentDoc, 0, currentUserId),
          );
          ranked = _sortAndRank(ranked, period);
        }
      }

      // Enrich the signed-in user with lifetime/streak/breakdown from the
      // lifetime doc so profile/achievements/leaderboard cards that read
      // `.lifetimePoints` / `.streak` stay correct.
      final enrichedIndex = ranked.indexWhere(
        (u) => u.userId == currentUserId,
      );
      if (currentUserId.isNotEmpty && enrichedIndex != -1) {
        ranked[enrichedIndex] = await _mergeCurrentUserLifetime(
          ranked[enrichedIndex],
        );
      }

      if (limit > 0 && ranked.length > limit) {
        ranked = ranked.sublist(0, limit);
      }
      return ranked;
    });
  }

  // =========================================================================
  // STREAK — Screen-time-based streak evaluation (unchanged — not part of
  // the weekly/monthly points reset system above)
  // =========================================================================
  //
  // TIMEZONE POLICY: all streak day-boundary logic uses the device's local
  // clock (DateTime.now()). See prior inline documentation for rationale.
  // =========================================================================

  Future<void> checkAndResetStreakIfNeeded() async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) return;

      final docRef = _firestore.collection('leaderboard').doc(userId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      final lastActiveAt = (data['lastActiveAt'] as Timestamp?)?.toDate();
      final currentStreak = (data['streak'] ?? 0) as int;

      if (lastActiveAt != null && currentStreak > 0) {
        final daysSinceLastActive =
            DateTime.now().difference(lastActiveAt).inDays;
        if (daysSinceLastActive > 1) {
          await updateStreak(0);
          debugPrint(
              'Streak reset due to $daysSinceLastActive days of inactivity');
        }
      }
    } catch (e) {
      debugPrint('Check and reset streak error: $e');
    }
  }

  Future<void> evaluateAndUpdateStreak() async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) {
        debugPrint('Streak eval: no authenticated user, skipping');
        return;
      }

      final now = DateTime.now();
      final effectiveDay = now.hour < 4
          ? DateTime(now.year, now.month, now.day - 1)
          : DateTime(now.year, now.month, now.day);
      final effectiveDayTs = effectiveDay.millisecondsSinceEpoch;

      final prefs = await SharedPreferences.getInstance();
      final localEvalTs = prefs.getInt(_lastStreakEvalDateKey);
      if (localEvalTs != null && localEvalTs >= effectiveDayTs) {
        debugPrint('Streak already evaluated today (local), skipping');
        return;
      }

      final docRef = _firestore.collection('leaderboard').doc(userId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final firestoreEvalDate =
            (docSnapshot.data()?['lastStreakEvalDate'] as Timestamp?)
                ?.toDate();
        if (firestoreEvalDate != null) {
          final firestoreEvalDay = firestoreEvalDate.hour < 4
              ? DateTime(firestoreEvalDate.year, firestoreEvalDate.month,
                  firestoreEvalDate.day - 1)
              : DateTime(firestoreEvalDate.year, firestoreEvalDate.month,
                  firestoreEvalDate.day);
          if (firestoreEvalDay == effectiveDay) {
            debugPrint('Streak already evaluated today (Firestore), skipping');
            await prefs.setInt(
                _lastStreakEvalDateKey, firestoreEvalDate.millisecondsSinceEpoch);
            return;
          }
        }
      }

      final todayStart = DateTime(now.year, now.month, now.day);
      final usageMap = await MethodChannelService.instance
          .fetchAppsUsageForInterval(start: todayStart, end: now);

      int totalScreenTimeSec = 0;
      for (final usage in usageMap.values) {
        totalScreenTimeSec += usage.screenTime;
      }

      debugPrint(
        'Total screen time today: ${totalScreenTimeSec}s '
        '(${totalScreenTimeSec ~/ 60}min) — '
        'Threshold: ${_screenTimeStreakThresholdSec}s (8 hours)',
      );

      final currentStreak = docSnapshot.exists
          ? (docSnapshot.data()?['streak'] ?? 0) as int
          : 0;

      int newStreak;
      if (totalScreenTimeSec < _screenTimeStreakThresholdSec) {
        newStreak = currentStreak + 1;
        debugPrint('Screen time under 8hrs ✓ — streak +1 → $newStreak');
      } else {
        newStreak = 0;
        debugPrint('Screen time exceeded 8hrs ✗ — streak reset to 0');
      }

      await docRef.set({
        'streak': newStreak,
        'lastStreakEvalDate': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      clearCache();
      await prefs.setInt(_lastStreakEvalDateKey, now.millisecondsSinceEpoch);

      debugPrint(
          '✅ Streak evaluation complete: $newStreak '
          '(total screen time: ${totalScreenTimeSec}s)');
    } catch (e) {
      debugPrint('Error evaluating streak: $e');
    }
  }

  void startDailyStreakEvaluation() {
    _streakEvaluationTimer?.cancel();
    _streakEvaluationTimer = Timer.periodic(
      const Duration(hours: 6),
      (_) => evaluateAndUpdateStreak(),
    );
    debugPrint('Daily streak evaluation monitor started (6 hour interval)');
  }

  Future<void> markActive() async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) return;

      await _firestore.collection('leaderboard').doc(userId).set({
        'lastActiveAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('📱 lastActiveAt heartbeat written');
    } catch (e) {
      debugPrint('Error marking active: $e');
    }
  }

  void stopDailyStreakEvaluation() {
    _streakEvaluationTimer?.cancel();
    _streakEvaluationTimer = null;
  }
}
