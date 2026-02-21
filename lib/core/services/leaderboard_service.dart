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
  
  // Cache to reduce Firestore reads
  List<LeaderboardUser>? _cachedLeaderboard;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  /// Get top leaderboard users (default: 100)
  Future<List<LeaderboardUser>> getTopUsers({int limit = 100}) async {
    try {
      // Return cached data if valid
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

      // Update cache
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
}
