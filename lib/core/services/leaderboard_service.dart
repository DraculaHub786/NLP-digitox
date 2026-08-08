import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Which scoring window a leaderboard view is showing.
///
/// Both fields already exist on every `leaderboard/{uid}` doc:
///   - `points`        → resets every Monday 4 AM (Asia/Kolkata), server-side
///   - `monthlyPoints` → resets on the 1st of each month 4 AM, server-side
///   - `lifetimePoints` → never resets
///
/// Resets are performed exclusively by the `resetWeeklyLeaderboard` /
/// `resetMonthlyLeaderboard` Cloud Functions (see /functions/index.js) using
/// the Firebase Admin SDK, which bypasses firestore.rules. The client never
/// writes a reset — firestore.rules intentionally forbids that (see the
/// `leaderboard` and `leaderboard_config` rules), so nothing below attempts
/// to write points to 0 from the app.
enum LeaderboardPeriod { weekly, monthly }

extension LeaderboardPeriodX on LeaderboardPeriod {
  /// Firestore field on the `leaderboard/{uid}` doc that holds this period's score.
  String get field =>
      this == LeaderboardPeriod.weekly ? 'points' : 'monthlyPoints';

  /// Doc id under `leaderboard_config` that the reset Cloud Function updates.
  String get configDocId =>
      this == LeaderboardPeriod.weekly ? 'weekly_reset' : 'monthly_reset';

  String get label => this == LeaderboardPeriod.weekly ? 'Weekly' : 'Monthly';
}

/// Read-only info about the last/next server-side reset for a period.
/// Populated entirely from `leaderboard_config/{weekly_reset|monthly_reset}`,
/// which only the Cloud Functions may write.
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

  /// The score relevant to a given leaderboard view — weekly `points` or
  /// `monthlyPoints`. Use this instead of `.points` directly anywhere the
  /// UI needs to respect the active tab.
  int scoreFor(LeaderboardPeriod period) =>
      period == LeaderboardPeriod.weekly ? points : monthlyPoints;

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
/// resets are performed server-side by Cloud Functions (see
/// /functions/index.js) using the Admin SDK, which is required because
/// firestore.rules deliberately blocks the client from writing other
/// users' docs or the `leaderboard_config` collection.
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

      final querySnapshot = await _firestore
          .collection('leaderboard')
          .orderBy(period.field, descending: true)
          .limit(limit)
          .get();

      final users = querySnapshot.docs.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final doc = entry.value;
        return LeaderboardUser.fromFirestore(doc, rank, currentUserId);
      }).toList();

      _cachedLeaderboard[period] = users;
      _lastFetchTime[period] = DateTime.now();

      debugPrint('Fetched ${users.length} users (${period.label})');
      return users;
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

      final doc = await _firestore.collection('leaderboard').doc(userId).get();
      if (!doc.exists) return null;

      final userScore = (doc.data()?[period.field] ?? 0) as int;
      final higherRankedCount = await _firestore
          .collection('leaderboard')
          .where(period.field, isGreaterThan: userScore)
          .count()
          .get();

      final rank = higherRankedCount.count! + 1;

      return LeaderboardUser.fromFirestore(doc, rank, userId);
    } catch (e) {
      debugPrint('Get current user data error (${period.label}): $e');
      return null;
    }
  }

  /// Read-only reset schedule info for a period. Returns null until the
  /// corresponding Cloud Function has run at least once (i.e. the
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
  /// `points` tracks weekly points (reset every Monday 4 AM by Cloud Function).
  /// `monthlyPoints` tracks monthly points (reset 1st of month 4 AM by Cloud Function).
  /// `lifetimePoints` tracks all-time total (never reset).
  /// If the doc does not exist yet, seeds username/email/avatarEmoji to
  /// prevent "Anonymous" showing on the leaderboard before updateUserData runs.
  Future<void> addPoints(int points, String category) async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) return;

      final docRef = _firestore.collection('leaderboard').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        final currentPoints = snapshot.exists
            ? (snapshot.data()?['points'] ?? 0) as int
            : 0;
        final currentMonthlyPoints = snapshot.exists
            ? (snapshot.data()?['monthlyPoints'] ?? 0) as int
            : 0;
        final currentBreakdown = snapshot.exists
            ? Map<String, int>.from(
                snapshot.data()?['pointsBreakdown'] ?? {})
            : <String, int>{};
        final currentLifetimePoints = snapshot.exists
            ? (snapshot.data()?['lifetimePoints'] ?? 0) as int
            : 0;

        currentBreakdown[category] =
            (currentBreakdown[category] ?? 0) + points;

        final auth = FirebaseAuthService.instance;
        final data = <String, dynamic>{
          'points': currentPoints + points,
          'monthlyPoints': currentMonthlyPoints + points,
          'pointsBreakdown': currentBreakdown,
          'lifetimePoints': currentLifetimePoints + points,
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastActiveAt': FieldValue.serverTimestamp(),
        };

        if (!snapshot.exists) {
          data['username'] = auth.userDisplayName ?? 'User';
          data['email'] = auth.userEmail;
          data['avatarEmoji'] = '👤';
        }

        transaction.set(docRef, data, SetOptions(merge: true));
      });

      clearCache();
      debugPrint('Added $points points to $category');
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
        .collection('leaderboard')
        .orderBy(period.field, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final doc = entry.value;
        return LeaderboardUser.fromFirestore(doc, rank, currentUserId);
      }).toList();
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
