import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

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
  });

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
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}

/// Leaderboard Service
/// Handles fetching and updating leaderboard data from Firestore
class LeaderboardService {
  LeaderboardService._();
  static final LeaderboardService instance = LeaderboardService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<LeaderboardUser>? _cachedLeaderboard;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  // Weekly reset configuration
  static const String _leaderboardConfigCollection = 'leaderboard_config';
  static const String _leaderboardConfigDoc = 'weekly_reset';
  Timer? _weeklyResetTimer;
  Timer? _streakEvaluationTimer;

  // Streak evaluation tracking
  static const String _lastStreakEvalDateKey =
      'leaderboard_last_streak_eval_date';
  static const int _screenTimeStreakThresholdSec = 8 * 60 * 60; // 8 hours in seconds

  // =========================================================================
  // FETCH / READ
  // =========================================================================

  Future<List<LeaderboardUser>> getTopUsers({int limit = 100}) async {
    try {
      if (_cachedLeaderboard != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        debugPrint('Returning cached leaderboard data');
        return _cachedLeaderboard!;
      }

      final currentUserId = FirebaseAuthService.instance.userId ?? '';

      final querySnapshot = await _firestore
          .collection('leaderboard')
          .orderBy('points', descending: true)
          .limit(limit)
          .get();

      final users = querySnapshot.docs.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final doc = entry.value;
        return LeaderboardUser.fromFirestore(doc, rank, currentUserId);
      }).toList();

      _cachedLeaderboard = users;
      _lastFetchTime = DateTime.now();

      debugPrint('Fetched ${users.length} users from leaderboard');
      return users;
    } catch (e) {
      debugPrint('Get leaderboard error: $e');
      return [];
    }
  }

  /// Get current user's leaderboard data
  Future<LeaderboardUser?> getCurrentUserData() async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) return null;

      final doc = await _firestore.collection('leaderboard').doc(userId).get();

      if (!doc.exists) return null;

      // Get rank by counting users with higher points
      final userPoints = (doc.data()?['points'] ?? 0) as int;
      final higherRankedCount = await _firestore
          .collection('leaderboard')
          .where('points', isGreaterThan: userPoints)
          .count()
          .get();

      final rank = higherRankedCount.count! + 1;

      return LeaderboardUser.fromFirestore(doc, rank, userId);
    } catch (e) {
      debugPrint('Get current user data error: $e');
      return null;
    }
  }

  // =========================================================================
  // WRITE / UPDATE
  // =========================================================================

  /// Update user's leaderboard data.
  /// Preserves existing points and lifetimePoints from Firestore if they exist.
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

      // Fetch existing data to preserve current values
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
      );

      await _firestore
          .collection('leaderboard')
          .doc(userId)
          .set(leaderboardUser.toMap(), SetOptions(merge: true));

      // Invalidate cache after update
      _cachedLeaderboard = null;
      _lastFetchTime = null;

      debugPrint(
        'Updated user leaderboard data: ${leaderboardUser.points} points, '
        '${leaderboardUser.streak} streak, '
        '${leaderboardUser.lifetimePoints} lifetime',
      );
    } catch (e) {
      debugPrint('Update leaderboard error: $e');
      throw Exception('Failed to update leaderboard');
    }
  }

  /// Add points to current user.
  /// `points` field tracks weekly points (reset every Monday 4am).
  /// `lifetimePoints` tracks all-time total (never reset).
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
        final currentBreakdown = snapshot.exists
            ? Map<String, int>.from(
                snapshot.data()?['pointsBreakdown'] ?? {})
            : <String, int>{};
        final currentLifetimePoints = snapshot.exists
            ? (snapshot.data()?['lifetimePoints'] ?? 0) as int
            : 0;

        currentBreakdown[category] =
            (currentBreakdown[category] ?? 0) + points;

        transaction.set(
          docRef,
          {
            'points': currentPoints + points,
            'pointsBreakdown': currentBreakdown,
            'lifetimePoints': currentLifetimePoints + points,
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });

      // Invalidate cache
      _cachedLeaderboard = null;
      _lastFetchTime = null;

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

      // Invalidate cache
      _cachedLeaderboard = null;
      _lastFetchTime = null;

      debugPrint('Updated streak to $newStreak');
    } catch (e) {
      debugPrint('Update streak error: $e');
    }
  }

  // =========================================================================
  // CACHE
  // =========================================================================

  /// Clear cache (call when user manually refreshes)
  void clearCache() {
    _cachedLeaderboard = null;
    _lastFetchTime = null;
  }

  /// Stream leaderboard updates (real-time)
  Stream<List<LeaderboardUser>> streamTopUsers({int limit = 100}) {
    final currentUserId = FirebaseAuthService.instance.userId ?? '';

    return _firestore
        .collection('leaderboard')
        .orderBy('points', descending: true)
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
  // STREAK — Screen-time-based streak evaluation
  // =========================================================================

  /// Check if user was inactive (app not opened for >1 day) and reset streak.
  /// Called on app initialization to handle long absences.
  Future<void> checkAndResetStreakIfNeeded() async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) return;

      final docRef = _firestore.collection('leaderboard').doc(userId);
      final snapshot = await docRef.get();

      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      final lastUpdated = (data['lastUpdated'] as Timestamp?)?.toDate();
      final currentStreak = (data['streak'] ?? 0) as int;

      if (lastUpdated != null && currentStreak > 0) {
        final daysSinceLastUpdate =
            DateTime.now().difference(lastUpdated).inDays;

        // Reset streak if user was inactive for more than 1 day
        if (daysSinceLastUpdate > 1) {
          await updateStreak(0);
          debugPrint(
              'Streak reset due to $daysSinceLastUpdate days of inactivity');
        }
      }
    } catch (e) {
      debugPrint('Check and reset streak error: $e');
    }
  }

  /// Evaluate today's total screen time and update streak accordingly.
  /// If total screen time < 8 hours → streak increments by 1
  /// If total screen time >= 8 hours → streak resets to 0
  /// Uses SharedPrefs to ensure at most one evaluation per day (after 4am reset).
  Future<void> evaluateAndUpdateStreak() async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) {
        debugPrint('Streak eval: no authenticated user, skipping');
        return;
      }

      // Apply the 4am reset rule: before 4am, the "effective day" is yesterday
      final now = DateTime.now();
      final effectiveDay = now.hour < 4
          ? DateTime(now.year, now.month, now.day - 1)
          : DateTime(now.year, now.month, now.day);

      // Check if already evaluated today (after 4am)
      final prefs = await SharedPreferences.getInstance();
      final lastEvalTimestamp = prefs.getInt(_lastStreakEvalDateKey);
      if (lastEvalTimestamp != null) {
        final lastEvalDate =
            DateTime.fromMillisecondsSinceEpoch(lastEvalTimestamp);
        final lastEvalDay = lastEvalDate.hour < 4
            ? DateTime(lastEvalDate.year, lastEvalDate.month,
                lastEvalDate.day - 1)
            : DateTime(lastEvalDate.year, lastEvalDate.month,
                lastEvalDate.day);
        if (lastEvalDay == effectiveDay) {
          debugPrint(
              'Streak already evaluated for effective day $effectiveDay, skipping');
          return;
        }
      }

      // Get total screen time for today from the method channel
      final todayStart = DateTime(now.year, now.month, now.day);
      final usageMap = await MethodChannelService.instance
          .fetchAppsUsageForInterval(start: todayStart, end: now);

      // Sum all screen time across all apps
      int totalScreenTimeSec = 0;
      for (final usage in usageMap.values) {
        totalScreenTimeSec += usage.screenTime;
      }

      debugPrint(
        'Total screen time today: ${totalScreenTimeSec}s '
        '(${totalScreenTimeSec ~/ 60}min) — '
        'Threshold: ${_screenTimeStreakThresholdSec}s (8 hours)',
      );

      // Get current streak from leaderboard
      final docRef = _firestore.collection('leaderboard').doc(userId);
      final snapshot = await docRef.get();
      final currentStreak = snapshot.exists
          ? (snapshot.data()?['streak'] ?? 0) as int
          : 0;

      int newStreak;
      if (totalScreenTimeSec < _screenTimeStreakThresholdSec) {
        // User maintained < 8 hours — increment streak
        newStreak = currentStreak + 1;
        debugPrint('Screen time under 8hrs ✓ — streak +1 → $newStreak');
      } else {
        // User exceeded 8 hours — reset streak
        newStreak = 0;
        debugPrint('Screen time exceeded 8hrs ✗ — streak reset to 0');
      }

      // Update streak in Firestore
      await updateStreak(newStreak);

      // Save last evaluation date
      await prefs.setInt(_lastStreakEvalDateKey, now.millisecondsSinceEpoch);

      debugPrint(
          '✅ Streak evaluation complete: $newStreak '
          '(total screen time: ${totalScreenTimeSec}s)');
    } catch (e) {
      debugPrint('Error evaluating streak: $e');
    }
  }

  /// Start periodic monitor for daily streak evaluation.
  /// Runs every 6 hours so it catches the user's screen time at various points.
  void startDailyStreakEvaluation() {
    _streakEvaluationTimer?.cancel();
    _streakEvaluationTimer = Timer.periodic(
      const Duration(hours: 6),
      (_) => evaluateAndUpdateStreak(),
    );
    debugPrint('Daily streak evaluation monitor started (6 hour interval)');
  }

  /// Stop periodic streak evaluation
  void stopDailyStreakEvaluation() {
    _streakEvaluationTimer?.cancel();
    _streakEvaluationTimer = null;
  }

  // =========================================================================
  // WEEKLY RESET — Every Monday at 4AM
  // =========================================================================

  /// Check if weekly leaderboard reset is needed and perform reset.
  /// Resets all users' weekly points to 0 but preserves lifetime points.
  /// Reset happens every Monday at 4 AM or the first time the app opens
  /// after Monday 4 AM in a new week.
  Future<void> checkAndPerformWeeklyReset() async {
    try {
      final now = DateTime.now();

      // Check if it's past 4 AM (reset hour)
      final resetHour = 4;
      final isPastResetTime = now.hour >= resetHour;

      final configDoc = await _firestore
          .collection(_leaderboardConfigCollection)
          .doc(_leaderboardConfigDoc)
          .get();

      DateTime? lastResetDate;

      if (configDoc.exists) {
        final data = configDoc.data();
        final lastResetTimestamp = data?['lastResetDate'] as Timestamp?;
        if (lastResetTimestamp != null) {
          lastResetDate = lastResetTimestamp.toDate();
        }
      }

      // If no last reset date, initialize it
      if (lastResetDate == null) {
        final previousWeek = now.subtract(const Duration(days: 7));
        await _initializeLeaderboardWeek(previousWeek);
        debugPrint(
            'Initialized leaderboard weekly reset system (Resets every Monday at 4 AM)');
        return;
      }

      // Determine if we're in a new weekly cycle since last reset
      final lastResetWeekStart = _getWeekStart(lastResetDate);
      final currentWeekStart = _getWeekStart(now);
      final isNewWeek = currentWeekStart.isAfter(lastResetWeekStart);

      // Reset if:
      // 1. We're in a new week (current Monday > last reset Monday), AND
      // 2. It's past 4 AM today
      if (isNewWeek && isPastResetTime) {
        debugPrint('🔄 Weekly leaderboard reset triggered! (Reset at 4 AM)');
        debugPrint('   Last reset: ${lastResetDate.toString()}');
        debugPrint('   Current time: ${now.toString()}');

        await _resetAllUsersPoints();
        await _updateLastResetDate(now);
        debugPrint('✅ Weekly leaderboard reset completed successfully');

        // Clear cache to reflect new data
        clearCache();
      } else {
        if (isNewWeek && !isPastResetTime) {
          debugPrint(
              'Leaderboard reset pending: Waiting for 4 AM (Current: ${now.hour}:${now.minute})');
        } else {
          final daysUntilMonday = (DateTime.monday - now.weekday) % 7;
          final nextResetDay =
              daysUntilMonday == 0 ? 'Today' : 'in $daysUntilMonday days';
          debugPrint('Next leaderboard reset: Monday $nextResetDay at 4 AM');
        }
      }
    } catch (e) {
      debugPrint('Error checking/performing weekly leaderboard reset: $e');
    }
  }

  /// Start periodic monitor for Monday 4 AM weekly resets
  void startWeeklyResetMonitor() {
    _weeklyResetTimer?.cancel();
    _weeklyResetTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => checkAndPerformWeeklyReset(),
    );
    debugPrint('Weekly leaderboard reset monitor started (15 min interval)');
  }

  /// Stop periodic monitor
  void stopWeeklyResetMonitor() {
    _weeklyResetTimer?.cancel();
    _weeklyResetTimer = null;
  }

  /// Get the start of the week (Monday at 00:00:00) for a given date
  DateTime _getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday;
    final daysToSubtract = dayOfWeek - DateTime.monday;
    return DateTime(
      date.year,
      date.month,
      date.day - daysToSubtract,
    );
  }

  /// Initialize the leaderboard week tracking
  Future<void> _initializeLeaderboardWeek(DateTime startDate) async {
    try {
      await _firestore
          .collection(_leaderboardConfigCollection)
          .doc(_leaderboardConfigDoc)
          .set({
        'lastResetDate': Timestamp.fromDate(startDate),
        'weekNumber': 1,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error initializing leaderboard week: $e');
    }
  }

  /// Update the last reset date in Firestore
  Future<void> _updateLastResetDate(DateTime resetDate) async {
    try {
      final configDoc = await _firestore
          .collection(_leaderboardConfigCollection)
          .doc(_leaderboardConfigDoc)
          .get();

      final currentWeekNumber = configDoc.exists
          ? (configDoc.data()?['weekNumber'] ?? 0) as int
          : 0;

      await _firestore
          .collection(_leaderboardConfigCollection)
          .doc(_leaderboardConfigDoc)
          .set({
        'lastResetDate': Timestamp.fromDate(resetDate),
        'weekNumber': currentWeekNumber + 1,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating last reset date: $e');
    }
  }

  /// Reset all users' points to 0 while preserving streaks and lifetimePoints.
  /// Handles >500 users by chunking batches (Firestore batch limit).
  Future<void> _resetAllUsersPoints() async {
    try {
      // Get all leaderboard documents
      final querySnapshot = await _firestore
          .collection('leaderboard')
          .get();

      final totalUsers = querySnapshot.docs.length;
      debugPrint('Resetting points for $totalUsers users...');

      // Process in chunks of 500 (Firestore batch limit)
      const int batchLimit = 500;
      int processed = 0;

      while (processed < totalUsers) {
        final batch = _firestore.batch();
        final chunkEnd = (processed + batchLimit < totalUsers)
            ? processed + batchLimit
            : totalUsers;

        for (int i = processed; i < chunkEnd; i++) {
          final doc = querySnapshot.docs[i];
          final data = doc.data();
          final currentStreak = data['streak'] ?? 0;

          // Reset points and pointsBreakdown, but keep streak and lifetimePoints
          batch.update(doc.reference, {
            'points': 0,
            'pointsBreakdown': {},
            'lifetimePoints': data['lifetimePoints'] ?? 0,
            'streak': currentStreak, // Keep streak unchanged
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }

        await batch.commit();
        processed = chunkEnd;
        debugPrint('  Batch committed: $processed / $totalUsers users');
      }

      debugPrint(
          '✅ Reset points for $totalUsers users (streaks and lifetime points preserved)');
    } catch (e) {
      debugPrint('Error resetting all users points: $e');
      throw Exception('Failed to reset leaderboard');
    }
  }

  /// Get the current leaderboard week information
  Future<Map<String, dynamic>?> getLeaderboardWeekInfo() async {
    try {
      final configDoc = await _firestore
          .collection(_leaderboardConfigCollection)
          .doc(_leaderboardConfigDoc)
          .get();

      if (!configDoc.exists) return null;

      final data = configDoc.data();
      final lastResetDate = (data?['lastResetDate'] as Timestamp?)?.toDate();
      final weekNumber = data?['weekNumber'] ?? 0;

      if (lastResetDate == null) return null;

      final now = DateTime.now();
      final resetHour = 4;

      // Calculate next Monday at 4 AM
      final daysUntilMonday = (DateTime.monday - now.weekday) % 7;
      DateTime nextReset;

      if (daysUntilMonday == 0) {
        // Today is Monday
        if (now.hour < resetHour) {
          // Reset hasn't happened yet today
          nextReset = DateTime(now.year, now.month, now.day, resetHour);
        } else {
          // Reset already happened, next one is in 7 days
          nextReset =
              DateTime(now.year, now.month, now.day + 7, resetHour);
        }
      } else {
        // Not Monday, calculate next Monday at 4 AM
        nextReset = DateTime(
            now.year, now.month, now.day + daysUntilMonday, resetHour);
      }

      final hoursUntilReset = nextReset.difference(now).inHours;
      final daysUntilReset = (hoursUntilReset / 24).ceil();
      final daysSinceReset = now.difference(lastResetDate).inDays;

      return {
        'lastResetDate': lastResetDate,
        'nextResetDate': nextReset,
        'weekNumber': weekNumber,
        'daysSinceReset': daysSinceReset,
        'daysUntilReset': daysUntilReset > 0 ? daysUntilReset : 0,
        'hoursUntilReset': hoursUntilReset > 0 ? hoursUntilReset : 0,
      };
    } catch (e) {
      debugPrint('Error getting leaderboard week info: $e');
      return null;
    }
  }

  /// Manual reset for testing purposes
  /// Forces a weekly reset regardless of time
  /// WARNING: This should only be used for testing!
  Future<void> forceWeeklyReset() async {
    try {
      debugPrint('🔴 FORCING WEEKLY RESET (TESTING ONLY)');
      await _resetAllUsersPoints();
      await _updateLastResetDate(DateTime.now());
      clearCache();
      debugPrint('✅ Forced reset completed');
    } catch (e) {
      debugPrint('Error forcing weekly reset: $e');
      throw Exception('Failed to force reset leaderboard');
    }
  }
}
