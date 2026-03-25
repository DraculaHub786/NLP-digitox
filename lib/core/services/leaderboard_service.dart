// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';

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

  LeaderboardUser({
    required this.userId,
    required this.username,
    required this.points,
    required this.streak,
    this.avatarEmoji,
    required this.rank,
    required this.isCurrentUser,
    this.pointsBreakdown,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'points': points,
      'streak': streak,
      'avatarEmoji': avatarEmoji ?? '👤',
      'pointsBreakdown': pointsBreakdown ?? {},
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
      // Return empty list if Firestore fails (graceful degradation)
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

  /// Update user's leaderboard data
  Future<void> updateUserData({
    required String username,
    required int points,
    required int streak,
    String? avatarEmoji,
    Map<String, int>? pointsBreakdown,
  }) async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final leaderboardUser = LeaderboardUser(
        userId: userId,
        username: username,
        points: points,
        streak: streak,
        avatarEmoji: avatarEmoji,
        rank: 0, // Not used when updating
        isCurrentUser: true,
        pointsBreakdown: pointsBreakdown,
      );

      await _firestore
          .collection('leaderboard')
          .doc(userId)
          .set(leaderboardUser.toMap(), SetOptions(merge: true));

      // Invalidate cache after update
      _cachedLeaderboard = null;
      _lastFetchTime = null;

      debugPrint('Updated user leaderboard data: $points points, $streak streak');
    } catch (e) {
      debugPrint('Update leaderboard error: $e');
      throw Exception('Failed to update leaderboard');
    }
  }

  /// Add points to current user
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
            ? Map<String, int>.from(snapshot.data()?['pointsBreakdown'] ?? {})
            : <String, int>{};

        currentBreakdown[category] = (currentBreakdown[category] ?? 0) + points;

        transaction.set(
          docRef,
          {
            'points': currentPoints + points,
            'pointsBreakdown': currentBreakdown,
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

  /// Update streak
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

  /// Clear cache (call when user manually refreshes)
  void clearCache() {
    _cachedLeaderboard = null;
    _lastFetchTime = null;
  }

  /// Stream leaderboard updates (real-time)
  /// Warning: This uses more reads! Only use if needed
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

  /// Check if user was inactive and reset streak if needed
  /// Called on app initialization
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
        final daysSinceLastUpdate = DateTime.now().difference(lastUpdated).inDays;
        
        // Reset streak if user was inactive for more than 1 day
        if (daysSinceLastUpdate > 1) {
          await updateStreak(0);
          debugPrint('Streak reset due to $daysSinceLastUpdate days of inactivity');
        }
      }
    } catch (e) {
      debugPrint('Check and reset streak error: $e');
    }
  }

  /// Check if weekly leaderboard reset is needed and perform reset
  /// Called on app initialization
  /// Resets all users' points to 0 but preserves streaks
  /// Reset happens every Monday at 4 AM
  Future<void> checkAndPerformWeeklyReset() async {
    try {
      final now = DateTime.now();
      
      // Check if it's Monday (DateTime.monday = 1)
      final isMonday = now.weekday == DateTime.monday;
      
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
        await _initializeLeaderboardWeek(now);
        debugPrint('Initialized leaderboard weekly reset system (Resets every Monday at 4 AM)');
        return;
      }

      // Determine if we're in the reset window and haven't reset this week
      final lastResetWeekStart = _getWeekStart(lastResetDate);
      final currentWeekStart = _getWeekStart(now);
      final isNewWeek = currentWeekStart.isAfter(lastResetWeekStart);
      
      // Reset if:
      // 1. It's Monday and past 4 AM, AND
      // 2. We haven't reset yet this week
      if (isMonday && isPastResetTime && isNewWeek) {
        debugPrint('🔄 Weekly leaderboard reset triggered! (Monday 4 AM reset)');
        debugPrint('   Last reset: ${lastResetDate.toString()}');
        debugPrint('   Current time: ${now.toString()}');
        
        await _resetAllUsersPoints();
        await _updateLastResetDate(now);
        debugPrint('✅ Weekly leaderboard reset completed successfully');
        
        // Clear cache to reflect new data
        clearCache();
      } else {
        if (isNewWeek && !isMonday) {
          debugPrint('Leaderboard reset pending: Waiting for Monday at 4 AM');
        } else if (isNewWeek && !isPastResetTime) {
          debugPrint('Leaderboard reset pending: Waiting for 4 AM (Current: ${now.hour}:${now.minute})');
        } else {
          final daysUntilMonday = (DateTime.monday - now.weekday) % 7;
          final nextResetDay = daysUntilMonday == 0 ? 'Today' : 'in $daysUntilMonday days';
          debugPrint('Next leaderboard reset: Monday $nextResetDay at 4 AM');
        }
      }
    } catch (e) {
      debugPrint('Error checking/performing weekly leaderboard reset: $e');
    }
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

  /// Reset all users' points to 0 while preserving streaks
  Future<void> _resetAllUsersPoints() async {
    try {
      // Get all leaderboard documents
      final querySnapshot = await _firestore
          .collection('leaderboard')
          .get();

      // Batch write for efficiency
      final batch = _firestore.batch();
      int userCount = 0;

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final currentStreak = data['streak'] ?? 0;
        
        // Reset points and pointsBreakdown, but keep streak
        batch.update(doc.reference, {
          'points': 0,
          'pointsBreakdown': {},
          'streak': currentStreak, // Keep streak unchanged
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        
        userCount++;
      }

      await batch.commit();
      debugPrint('Reset points for $userCount users (streaks preserved)');
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
          nextReset = DateTime(now.year, now.month, now.day + 7, resetHour);
        }
      } else {
        // Not Monday, calculate next Monday at 4 AM
        nextReset = DateTime(now.year, now.month, now.day + daysUntilMonday, resetHour);
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