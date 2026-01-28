/*
 *
 *  * Copyright (c) 2024 NLP digitox
 *  * Author : Pawan Nagar
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nlp_digitox/core/services/leaderboard_service.dart';
import 'package:nlp_digitox/core/services/productivity_notification_service.dart';

/// Service to handle points earning for productivity activities
/// Following the "How to Earn Points" rules from the leaderboard
class ProductivityPointsService {
  // Singleton pattern
  static ProductivityPointsService? _instance;
  static ProductivityPointsService get instance {
    _instance ??= ProductivityPointsService._();
    return _instance!;
  }

  ProductivityPointsService._();

  final _leaderboardService = LeaderboardService.instance;
  final _notificationService = ProductivityNotificationService.instance;

  // Points categories and values based on the leaderboard screen
  static const int habitCompletionPoints = 30; // Complete wellbeing activities
  static const int taskCompletionPoints = 20; // Complete tasks
  static const int dailyStreakPoints = 15; // Maintain daily streaks
  static const int screenTimeGoalPoints = 50; // Stay within screen time goals
  static const int bedtimeSchedulePoints = 25; // Follow bedtime schedule
  static const int appRestrictionPoints = 10; // Respect app restrictions

  // Shared preferences keys for tracking daily points
  static const String _lastScreenTimePointsDateKey = 'last_screen_time_points_date';
  static const String _lastBedtimePointsDateKey = 'last_bedtime_points_date';
  static const String _lastAppRestrictionPointsDateKey = 'last_app_restriction_points_date';
  static const String _lastStreakPointsDateKey = 'last_streak_points_date';

  /// Award points for completing a habit
  Future<void> awardHabitCompletionPoints({
    required String habitName,
    bool showNotification = true,
  }) async {
    try {
      await _leaderboardService.addPoints(
        habitCompletionPoints,
        'Wellbeing Activities',
      );

      if (showNotification) {
        await _notificationService.sendPointsEarnedNotification(
          points: habitCompletionPoints,
          category: 'completing habit "$habitName"',
        );
      }

      debugPrint('Awarded $habitCompletionPoints points for completing habit: $habitName');
    } catch (e) {
      debugPrint('Error awarding habit completion points: $e');
    }
  }

  /// Award points for completing a task
  Future<void> awardTaskCompletionPoints({
    required String taskTitle,
    bool showNotification = true,
  }) async {
    try {
      await _leaderboardService.addPoints(
        taskCompletionPoints,
        'Task Completion',
      );

      if (showNotification) {
        await _notificationService.sendPointsEarnedNotification(
          points: taskCompletionPoints,
          category: 'completing task "$taskTitle"',
        );
      }

      debugPrint('Awarded $taskCompletionPoints points for completing task: $taskTitle');
    } catch (e) {
      debugPrint('Error awarding task completion points: $e');
    }
  }

  /// Award points for maintaining daily streak
  /// Call this once per day when user completes their first habit/task
  Future<void> awardDailyStreakPoints({
    required int streak,
    bool showNotification = true,
  }) async {
    try {
      // Check if already awarded today
      final prefs = await SharedPreferences.getInstance();
      final lastAwardedTimestamp = prefs.getInt(_lastStreakPointsDateKey);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (lastAwardedTimestamp != null) {
        final lastAwarded = DateTime.fromMillisecondsSinceEpoch(lastAwardedTimestamp);
        final lastAwardedDay = DateTime(
          lastAwarded.year,
          lastAwarded.month,
          lastAwarded.day,
        );

        if (lastAwardedDay == today) {
          debugPrint('Streak points already awarded today, skipping');
          return;
        }
      }

      await _leaderboardService.addPoints(
        dailyStreakPoints,
        'Daily Streaks',
      );

      // Update streak in leaderboard
      await _leaderboardService.updateStreak(streak);

      // Save last awarded date
      await prefs.setInt(_lastStreakPointsDateKey, today.millisecondsSinceEpoch);

      if (showNotification) {
        await _notificationService.sendPointsEarnedNotification(
          points: dailyStreakPoints,
          category: 'maintaining your $streak-day streak',
        );
      }

      debugPrint('Awarded $dailyStreakPoints points for daily streak: $streak days');
    } catch (e) {
      debugPrint('Error awarding daily streak points: $e');
    }
  }

  /// Award points for staying within screen time goals
  /// Call this once per day when screen time goal is met
  Future<void> awardScreenTimeGoalPoints({
    bool showNotification = true,
  }) async {
    try {
      // Check if already awarded today
      final prefs = await SharedPreferences.getInstance();
      final lastAwardedTimestamp = prefs.getInt(_lastScreenTimePointsDateKey);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (lastAwardedTimestamp != null) {
        final lastAwarded = DateTime.fromMillisecondsSinceEpoch(lastAwardedTimestamp);
        final lastAwardedDay = DateTime(
          lastAwarded.year,
          lastAwarded.month,
          lastAwarded.day,
        );

        if (lastAwardedDay == today) {
          debugPrint('Screen time points already awarded today, skipping');
          return;
        }
      }

      await _leaderboardService.addPoints(
        screenTimeGoalPoints,
        'Screen Time Goals',
      );

      // Save last awarded date
      await prefs.setInt(_lastScreenTimePointsDateKey, today.millisecondsSinceEpoch);

      if (showNotification) {
        await _notificationService.sendPointsEarnedNotification(
          points: screenTimeGoalPoints,
          category: 'staying within screen time goals',
        );
      }

      debugPrint('Awarded $screenTimeGoalPoints points for screen time goal');
    } catch (e) {
      debugPrint('Error awarding screen time goal points: $e');
    }
  }

  /// Award points for following bedtime schedule
  /// Call this once per day when bedtime schedule is followed
  Future<void> awardBedtimeSchedulePoints({
    bool showNotification = true,
  }) async {
    try {
      // Check if already awarded today
      final prefs = await SharedPreferences.getInstance();
      final lastAwardedTimestamp = prefs.getInt(_lastBedtimePointsDateKey);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (lastAwardedTimestamp != null) {
        final lastAwarded = DateTime.fromMillisecondsSinceEpoch(lastAwardedTimestamp);
        final lastAwardedDay = DateTime(
          lastAwarded.year,
          lastAwarded.month,
          lastAwarded.day,
        );

        if (lastAwardedDay == today) {
          debugPrint('Bedtime points already awarded today, skipping');
          return;
        }
      }

      await _leaderboardService.addPoints(
        bedtimeSchedulePoints,
        'Bedtime Adherence',
      );

      // Save last awarded date
      await prefs.setInt(_lastBedtimePointsDateKey, today.millisecondsSinceEpoch);

      if (showNotification) {
        await _notificationService.sendPointsEarnedNotification(
          points: bedtimeSchedulePoints,
          category: 'following bedtime schedule',
        );
      }

      debugPrint('Awarded $bedtimeSchedulePoints points for bedtime schedule');
    } catch (e) {
      debugPrint('Error awarding bedtime schedule points: $e');
    }
  }

  /// Award points for respecting app restrictions
  /// Call this once per day when no restricted apps were accessed
  Future<void> awardAppRestrictionPoints({
    bool showNotification = true,
  }) async {
    try {
      // Check if already awarded today
      final prefs = await SharedPreferences.getInstance();
      final lastAwardedTimestamp = prefs.getInt(_lastAppRestrictionPointsDateKey);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (lastAwardedTimestamp != null) {
        final lastAwarded = DateTime.fromMillisecondsSinceEpoch(lastAwardedTimestamp);
        final lastAwardedDay = DateTime(
          lastAwarded.year,
          lastAwarded.month,
          lastAwarded.day,
        );

        if (lastAwardedDay == today) {
          debugPrint('App restriction points already awarded today, skipping');
          return;
        }
      }

      await _leaderboardService.addPoints(
        appRestrictionPoints,
        'App Restrictions',
      );

      // Save last awarded date
      await prefs.setInt(_lastAppRestrictionPointsDateKey, today.millisecondsSinceEpoch);

      if (showNotification) {
        await _notificationService.sendPointsEarnedNotification(
          points: appRestrictionPoints,
          category: 'respecting app restrictions',
        );
      }

      debugPrint('Awarded $appRestrictionPoints points for app restrictions');
    } catch (e) {
      debugPrint('Error awarding app restriction points: $e');
    }
  }

  /// Get total points that can be earned today
  int getMaxDailyPoints() {
    return screenTimeGoalPoints +
        bedtimeSchedulePoints +
        appRestrictionPoints +
        dailyStreakPoints;
  }

  /// Reset daily points tracking (for testing)
  Future<void> resetDailyPointsTracking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastScreenTimePointsDateKey);
      await prefs.remove(_lastBedtimePointsDateKey);
      await prefs.remove(_lastAppRestrictionPointsDateKey);
      await prefs.remove(_lastStreakPointsDateKey);
      debugPrint('Reset daily points tracking');
    } catch (e) {
      debugPrint('Error resetting daily points tracking: $e');
    }
  }
}
