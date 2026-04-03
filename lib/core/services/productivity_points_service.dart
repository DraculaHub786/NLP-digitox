// Copyright (c) 2024 NLP digitox

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nlp_digitox/core/services/leaderboard_service.dart';
import 'package:nlp_digitox/core/services/productivity_notification_service.dart';

/// Service to handle points earning for productivity activities
/// Following the "How to Earn Points" rules from the leaderboard
class ProductivityPointsService {
  static ProductivityPointsService? _instance;
  static ProductivityPointsService get instance {
    _instance ??= ProductivityPointsService._();
    return _instance!;
  }

  ProductivityPointsService._();

  final _leaderboardService = LeaderboardService.instance;
  final _notificationService = ProductivityNotificationService.instance;

  static const int habitCompletionPoints = 30; // Complete wellbeing activities
  static const int taskCompletionPoints = 20; // Complete tasks
  static const int dailyStreakPoints = 15; // Maintain daily streaks
  static const int screenTimeGoalPoints = 50; // Stay within screen time goals
  static const int bedtimeSchedulePoints = 25; // Follow bedtime schedule
  static const int appRestrictionPoints = 10;

  static const String _lastScreenTimePointsDateKey = 'last_screen_time_points_date';
  static const String _lastBedtimePointsDateKey = 'last_bedtime_points_date';
  static const String _lastAppRestrictionPointsDateKey = 'last_app_restriction_points_date';
  static const String _lastStreakPointsDateKey = 'last_streak_points_date';
  static const String _screenTimeStreakKey = 'screen_time_streak';
  static const String _habitPointsAwardedTodayKey = 'habit_points_awarded_today';
  static const String _taskPointsAwardedTodayKey = 'task_points_awarded_today';
  
  /// Get effective date considering 4am reset
  DateTime _getEffectiveDate(DateTime now) {
    final resetHour = 4;
    if (now.hour < resetHour) {
      return DateTime(now.year, now.month, now.day - 1);
    }
    return DateTime(now.year, now.month, now.day);
  }
  
  /// Check if points were already awarded for this habit today
  Future<bool> _wereHabitPointsAwardedToday(String habitId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final awardedJson = prefs.getString(_habitPointsAwardedTodayKey);
      if (awardedJson == null) return false;
      
      final awardedMap = Map<String, int>.from(jsonDecode(awardedJson));
      final now = DateTime.now();
      final effectiveToday = _getEffectiveDate(now);
      final effectiveTodayTimestamp = effectiveToday.millisecondsSinceEpoch;
      
      final lastAwardedTimestamp = awardedMap[habitId];
      if (lastAwardedTimestamp == null) return false;
      
      final lastAwardedDate = _getEffectiveDate(
        DateTime.fromMillisecondsSinceEpoch(lastAwardedTimestamp)
      );
      
      return lastAwardedDate.millisecondsSinceEpoch >= effectiveTodayTimestamp;
    } catch (e) {
      debugPrint('Error checking habit points: $e');
      return false;
    }
  }
  
  /// Mark habit points as awarded today
  Future<void> _markHabitPointsAwarded(String habitId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final awardedJson = prefs.getString(_habitPointsAwardedTodayKey);
      final awardedMap = awardedJson != null 
          ? Map<String, int>.from(jsonDecode(awardedJson))
          : <String, int>{};
      
      awardedMap[habitId] = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString(_habitPointsAwardedTodayKey, jsonEncode(awardedMap));
    } catch (e) {
      debugPrint('Error marking habit points: $e');
    }
  }
  
  /// Check if points were already awarded for this task today
  Future<bool> _wereTaskPointsAwardedToday(String taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final awardedJson = prefs.getString(_taskPointsAwardedTodayKey);
      if (awardedJson == null) return false;
      
      final awardedMap = Map<String, int>.from(jsonDecode(awardedJson));
      final now = DateTime.now();
      final effectiveToday = _getEffectiveDate(now);
      final effectiveTodayTimestamp = effectiveToday.millisecondsSinceEpoch;
      
      final lastAwardedTimestamp = awardedMap[taskId];
      if (lastAwardedTimestamp == null) return false;
      
      final lastAwardedDate = _getEffectiveDate(
        DateTime.fromMillisecondsSinceEpoch(lastAwardedTimestamp)
      );
      
      return lastAwardedDate.millisecondsSinceEpoch >= effectiveTodayTimestamp;
    } catch (e) {
      debugPrint('Error checking task points: $e');
      return false;
    }
  }
  
  /// Mark task points as awarded today
  Future<void> _markTaskPointsAwarded(String taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final awardedJson = prefs.getString(_taskPointsAwardedTodayKey);
      final awardedMap = awardedJson != null 
          ? Map<String, int>.from(jsonDecode(awardedJson))
          : <String, int>{};
      
      awardedMap[taskId] = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString(_taskPointsAwardedTodayKey, jsonEncode(awardedMap));
    } catch (e) {
      debugPrint('Error marking task points: $e');
    }
  }

  /// Award points for completing a habit (only once per day after 4am)
  Future<void> awardHabitCompletionPoints({
    required String habitId,
    required String habitName,
    bool showNotification = true,
  }) async {
    try {
      // Check if points already awarded today
      final alreadyAwarded = await _wereHabitPointsAwardedToday(habitId);
      if (alreadyAwarded) {
        debugPrint('⚠️ Points already awarded for habit "$habitName" today');
        return;
      }
      
      await _leaderboardService.addPoints(
        habitCompletionPoints,
        'Wellbeing Activities',
      );
      
      // Mark as awarded
      await _markHabitPointsAwarded(habitId);

      if (showNotification) {
        await _notificationService.sendPointsEarnedNotification(
          points: habitCompletionPoints,
          category: 'completing habit "$habitName"',
        );
      }

      debugPrint('✅ Awarded $habitCompletionPoints points for completing habit: $habitName');
    } catch (e) {
      debugPrint('Error awarding habit completion points: $e');
    }
  }

  /// Award points for completing a task (only once per day after 4am)
  Future<void> awardTaskCompletionPoints({
    required String taskId,
    required String taskTitle,
    bool showNotification = true,
  }) async {
    try {
      // Check if points already awarded today
      final alreadyAwarded = await _wereTaskPointsAwardedToday(taskId);
      if (alreadyAwarded) {
        debugPrint('⚠️ Points already awarded for task "$taskTitle" today');
        return;
      }
      
      await _leaderboardService.addPoints(
        taskCompletionPoints,
        'Task Completion',
      );
      
      // Mark as awarded
      await _markTaskPointsAwarded(taskId);

      if (showNotification) {
        await _notificationService.sendPointsEarnedNotification(
          points: taskCompletionPoints,
          category: 'completing task "$taskTitle"',
        );
      }

      debugPrint('✅ Awarded $taskCompletionPoints points for completing task: $taskTitle');
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
      // First check if streak should be reset due to inactivity
      await _leaderboardService.checkAndResetStreakIfNeeded();
      
      // Check if already awarded today
      final prefs = await SharedPreferences.getInstance();
      final lastAwardedTimestamp = prefs.getInt(_lastStreakPointsDateKey);
      final now = DateTime.now();
      
      // Using 4 AM as the reset time for consistency
      final resetHour = 4;
      final effectiveToday = now.hour < resetHour 
          ? DateTime(now.year, now.month, now.day - 1)
          : DateTime(now.year, now.month, now.day);

      if (lastAwardedTimestamp != null) {
        final lastAwarded = DateTime.fromMillisecondsSinceEpoch(lastAwardedTimestamp);
        final lastAwardedDay = now.hour < resetHour 
            ? DateTime(lastAwarded.year, lastAwarded.month, lastAwarded.day - 1)
            : DateTime(lastAwarded.year, lastAwarded.month, lastAwarded.day);

        if (lastAwardedDay == effectiveToday) {
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
      await prefs.setInt(_lastStreakPointsDateKey, now.millisecondsSinceEpoch);

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
      
      // Using 4 AM as the reset time for consistency
      final resetHour = 4;
      final effectiveToday = now.hour < resetHour 
          ? DateTime(now.year, now.month, now.day - 1)
          : DateTime(now.year, now.month, now.day);

      if (lastAwardedTimestamp != null) {
        final lastAwarded = DateTime.fromMillisecondsSinceEpoch(lastAwardedTimestamp);
        final lastAwardedDay = now.hour < resetHour 
            ? DateTime(lastAwarded.year, lastAwarded.month, lastAwarded.day - 1)
            : DateTime(lastAwarded.year, lastAwarded.month, lastAwarded.day);

        if (lastAwardedDay == effectiveToday) {
          debugPrint('Screen time points already awarded today, skipping');
          return;
        }
      }

      await _leaderboardService.addPoints(
        screenTimeGoalPoints,
        'Screen Time Goals',
      );

      // Increment screen time streak
      final currentStreak = prefs.getInt(_screenTimeStreakKey) ?? 0;
      final newStreak = currentStreak + 1;
      await prefs.setInt(_screenTimeStreakKey, newStreak);
      
      // Update leaderboard with screen time streak
      await _leaderboardService.updateStreak(newStreak);
      debugPrint('Screen time streak updated to $newStreak days');

      // Save last awarded date
      await prefs.setInt(_lastScreenTimePointsDateKey, now.millisecondsSinceEpoch);

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
      
      // Using 4 AM as the reset time for consistency
      final resetHour = 4;
      final effectiveToday = now.hour < resetHour 
          ? DateTime(now.year, now.month, now.day - 1)
          : DateTime(now.year, now.month, now.day);

      if (lastAwardedTimestamp != null) {
        final lastAwarded = DateTime.fromMillisecondsSinceEpoch(lastAwardedTimestamp);
        final lastAwardedDay = now.hour < resetHour 
            ? DateTime(lastAwarded.year, lastAwarded.month, lastAwarded.day - 1)
            : DateTime(lastAwarded.year, lastAwarded.month, lastAwarded.day);

        if (lastAwardedDay == effectiveToday) {
          debugPrint('Bedtime points already awarded today, skipping');
          return;
        }
      }

      await _leaderboardService.addPoints(
        bedtimeSchedulePoints,
        'Bedtime Adherence',
      );

      // Save last awarded date
      await prefs.setInt(_lastBedtimePointsDateKey, now.millisecondsSinceEpoch);

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
      
      // Using 4 AM as the reset time for consistency
      final resetHour = 4;
      final effectiveToday = now.hour < resetHour 
          ? DateTime(now.year, now.month, now.day - 1)
          : DateTime(now.year, now.month, now.day);

      if (lastAwardedTimestamp != null) {
        final lastAwarded = DateTime.fromMillisecondsSinceEpoch(lastAwardedTimestamp);
        final lastAwardedDay = now.hour < resetHour 
            ? DateTime(lastAwarded.year, lastAwarded.month, lastAwarded.day - 1)
            : DateTime(lastAwarded.year, lastAwarded.month, lastAwarded.day);

        if (lastAwardedDay == effectiveToday) {
          debugPrint('App restriction points already awarded today, skipping');
          return;
        }
      }

      await _leaderboardService.addPoints(
        appRestrictionPoints,
        'App Restrictions',
      );

      // Save last awarded date
      await prefs.setInt(_lastAppRestrictionPointsDateKey, now.millisecondsSinceEpoch);

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

  /// Reset screen time streak (call when goal is not met)
  Future<void> resetScreenTimeStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentStreak = prefs.getInt(_screenTimeStreakKey) ?? 0;
      
      if (currentStreak > 0) {
        await prefs.setInt(_screenTimeStreakKey, 0);
        await _leaderboardService.updateStreak(0);
        debugPrint('Screen time streak reset to 0 (goal not met)');
      }
    } catch (e) {
      debugPrint('Error resetting screen time streak: $e');
    }
  }

  /// Get current screen time streak
  Future<int> getScreenTimeStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_screenTimeStreakKey) ?? 0;
    } catch (e) {
      debugPrint('Error getting screen time streak: $e');
      return 0;
    }
  }

  /// Get total points that can be earned today
  int getMaxDailyPoints() {
    return screenTimeGoalPoints +
        bedtimeSchedulePoints +
        appRestrictionPoints +
        dailyStreakPoints;
  }

  /// Award points for completing a focus session
  Future<void> awardPointsForFocusSession(int durationMinutes) async {
    try {
      final points = (durationMinutes * 0.5).round().clamp(10, 100);
      await _leaderboardService.addPoints(
        points,
        'Focus Session',
      );
      debugPrint('Awarded $points points for $durationMinutes-minute focus session');
    } catch (e) {
      debugPrint('Error awarding focus session points: $e');
    }
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
