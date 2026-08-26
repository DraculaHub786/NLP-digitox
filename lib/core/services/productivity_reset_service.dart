// Copyright (c) 2026 NLP digitox

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nlp_digitox/core/services/productivity_service.dart';
import 'package:nlp_digitox/core/services/productivity_notification_service.dart';
import 'package:nlp_digitox/core/services/productivity_points_service.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';

/// Service to handle daily resets of productivity items (habits and tasks)
/// and check for incomplete items to send notifications
class ProductivityResetService {
  static const String _lastResetDateKey = 'productivity_last_reset_date';
  static const String _notificationCheckTimeKey = 'productivity_notification_check_time';
  
  static ProductivityResetService? _instance;
  static ProductivityResetService get instance {
    _instance ??= ProductivityResetService._();
    return _instance!;
  }

  ProductivityResetService._();

  final _productivityService = ProductivityService.instance;
  final _notificationService = ProductivityNotificationService.instance;
  final _pointsService = ProductivityPointsService.instance;
  
  Timer? _resetCheckTimer;

  /// Initialize the reset service
  Future<void> initialize() async {
    debugPrint('Initializing ProductivityResetService');
    
    // Check for resets immediately
    await checkAndResetDaily();
    
    // Schedule notification check
    await scheduleNotificationCheck();
    
    // Start periodic check (every hour)
    _resetCheckTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) async {
        await checkAndResetDaily();
        await scheduleNotificationCheck();
      },
    );
  }

  /// Dispose the service
  void dispose() {
    _resetCheckTimer?.cancel();
    _resetCheckTimer = null;
  }

  /// Check if we need to reset daily and do it
  Future<void> checkAndResetDaily() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastResetTimestamp = prefs.getInt(_lastResetDateKey);
      final now = DateTime.now();
      
      // Reset happens at 4 AM instead of midnight
      // If current time is before 4 AM, consider it as yesterday's day
      final resetHour = 4;
      final effectiveDay = now.hour < resetHour 
          ? DateTime(now.year, now.month, now.day - 1)
          : DateTime(now.year, now.month, now.day);

      DateTime? lastResetDate;
      if (lastResetTimestamp != null) {
        lastResetDate = DateTime.fromMillisecondsSinceEpoch(lastResetTimestamp);
        final lastResetDay = now.hour < resetHour 
            ? DateTime(lastResetDate.year, lastResetDate.month, lastResetDate.day - 1)
            : DateTime(lastResetDate.year, lastResetDate.month, lastResetDate.day);

        // If already reset today (after 4 AM), skip
        if (lastResetDay == effectiveDay) {
          debugPrint('Already reset today (after 4 AM), skipping');
          return;
        }
      }

      debugPrint('Performing daily reset for productivity items (4 AM reset)');

      // Reset habits
      await _resetHabits(effectiveDay);

      // Reset tasks
      await _resetTasks(effectiveDay);

      // Update last reset date
      await prefs.setInt(_lastResetDateKey, now.millisecondsSinceEpoch);

      debugPrint('Daily reset completed successfully');
    } catch (e) {
      debugPrint('Error in checkAndResetDaily: $e');
    }
  }

  /// Reset all habits for the new day
  Future<void> _resetHabits(DateTime today) async {
    try {
      final habits = await _productivityService.getHabits();
      bool hasChanges = false;

      final updatedHabits = habits.map((habit) {
        final lastReset = habit.lastResetDate;
        
        // If never reset or last reset was before today
        if (lastReset == null || 
            DateTime(lastReset.year, lastReset.month, lastReset.day)
                .isBefore(today)) {
          
          // Calculate new streak
          int newStreak = habit.streak;
          
          // If habit was not completed today (before reset), check yesterday
          if (!habit.completedToday && habit.streak > 0) {
            final yesterday = today.subtract(const Duration(days: 1));
            final wasCompletedYesterday = habit.completedDates.any((date) =>
                date.year == yesterday.year &&
                date.month == yesterday.month &&
                date.day == yesterday.day);
            
            if (!wasCompletedYesterday) {
              newStreak = 0;
              debugPrint('Habit "${habit.name}" streak reset to 0 (skipped yesterday)');
            }
          }

          hasChanges = true;
          return habit.copyWith(
            completedToday: false,
            streak: newStreak,
            lastResetDate: today,
          );
        }
        
        return habit;
      }).toList();

      if (hasChanges) {
        await _productivityService.saveHabits(updatedHabits);
        debugPrint('Habits reset completed (4 AM reset)');
      }
    } catch (e) {
      debugPrint('Error resetting habits: $e');
    }
  }

  /// Reset all tasks for the new day
  Future<void> _resetTasks(DateTime today) async {
    try {
      final tasks = await _productivityService.getTasks();
      bool hasChanges = false;

      final updatedTasks = tasks.map((task) {
        final lastReset = task.lastResetDate;
        
        // If task is completed and was reset before today, reset it
        if (task.completed &&
            (lastReset == null ||
                DateTime(lastReset.year, lastReset.month, lastReset.day)
                    .isBefore(today))) {
          hasChanges = true;
          return task.copyWith(
            completed: false,
            completedAt: null,
            lastResetDate: today,
          );
        }
        
        return task;
      }).toList();

      if (hasChanges) {
        await _productivityService.saveTasks(updatedTasks);
        debugPrint('Tasks reset completed');
      }
    } catch (e) {
      debugPrint('Error resetting tasks: $e');
    }
  }

  /// Schedule notification check for incomplete items
  Future<void> scheduleNotificationCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckTimestamp = prefs.getInt(_notificationCheckTimeKey);
      final now = DateTime.now();

      // Check if we should send notifications (e.g., at 8 PM)
      final notificationTime = DateTime(now.year, now.month, now.day, 20, 0);
      
      // If already checked today or it's not yet notification time, skip
      if (lastCheckTimestamp != null) {
        final lastCheck = DateTime.fromMillisecondsSinceEpoch(lastCheckTimestamp);
        final lastCheckDay = DateTime(
          lastCheck.year,
          lastCheck.month,
          lastCheck.day,
        );
        final today = DateTime(now.year, now.month, now.day);

        if (lastCheckDay == today) {
          return;
        }
      }

      // If current time is past notification time, send notifications
      if (now.isAfter(notificationTime)) {
        await _sendIncompleteNotifications();
        await _checkAndAwardDailyPoints();
        await prefs.setInt(_notificationCheckTimeKey, now.millisecondsSinceEpoch);
      }
    } catch (e) {
      debugPrint('Error in scheduleNotificationCheck: $e');
    }
  }

  /// Send notifications for incomplete habits and tasks
  Future<void> _sendIncompleteNotifications() async {
    try {
      // Get incomplete habits
      final habits = await _productivityService.getHabits();
      final incompleteHabits = habits.where((h) => !h.completedToday).toList();

      // Get incomplete tasks
      final tasks = await _productivityService.getTasks();
      final incompleteTasks = tasks.where((t) => !t.completed).toList();

      if (incompleteHabits.isNotEmpty || incompleteTasks.isNotEmpty) {
        await _notificationService.sendIncompleteItemsNotification(
          incompleteHabitsCount: incompleteHabits.length,
          incompleteTasksCount: incompleteTasks.length,
        );
        debugPrint(
            'Sent notification for ${incompleteHabits.length} habits and ${incompleteTasks.length} tasks');
      }
    } catch (e) {
      debugPrint('Error sending incomplete notifications: $e');
    }
  }

  /// Check and award daily points for screen time, bedtime, and app restrictions
  Future<void> _checkAndAwardDailyPoints() async {
    try {
      debugPrint('Checking daily points eligibility...');
      
      // Get database instance
      final dao = DriftDbService.instance.driftDb.uniqueRecordsDao;
      
      // Check screen time goal
      await _checkScreenTimeGoal(dao);
      
      // Check bedtime schedule
      await _checkBedtimeSchedule(dao);
      
      // Check app restrictions
      await _checkAppRestrictions(dao);
      
    } catch (e) {
      debugPrint('Error checking daily points: $e');
    }
  }

  /// Check if user stayed within screen time goals
  Future<void> _checkScreenTimeGoal(dynamic dao) async {
    try {
      // Get wellbeing settings to check if screen time goal is set
      final wellbeingSettings = await dao.loadWellBeingSettings();
      
      if (wellbeingSettings.allowedShortsTimeSec > 0) {
        // Get today's short content usage from method channel
        final todayUsage = await MethodChannelService.instance.getShortsScreenTimeSec();
        
        if (todayUsage <= wellbeingSettings.allowedShortsTimeSec) {
          await _pointsService.awardScreenTimeGoalPoints(showNotification: true);
          debugPrint('User met screen time goal: $todayUsage <= ${wellbeingSettings.allowedShortsTimeSec} seconds');
        } else {
          await _pointsService.resetScreenTimeStreak();
          debugPrint('User exceeded screen time goal: $todayUsage > ${wellbeingSettings.allowedShortsTimeSec} seconds');
        }
      }
    } catch (e) {
      debugPrint('Error checking screen time goal: $e');
    }
  }

  /// Check if user followed bedtime schedule
  Future<void> _checkBedtimeSchedule(dynamic dao) async {
    try {
      // Get bedtime settings
      final settings = await dao.loadBedtimeSettings();
      
      if (settings.isScheduleOn) {
        // Check if user went to bed on time yesterday night
        // This is a simplified check - proper implementation would track actual bedtime
        final prefs = await SharedPreferences.getInstance();
        final bedtimeCompliance = prefs.getBool('bedtime_complied_yesterday') ?? false;
        
        if (bedtimeCompliance) {
          await _pointsService.awardBedtimeSchedulePoints(showNotification: true);
          debugPrint('User followed bedtime schedule');
        }
        
        // Reset for next day
        await prefs.remove('bedtime_complied_yesterday');
      }
    } catch (e) {
      debugPrint('Error checking bedtime schedule: $e');
    }
  }

  /// Check if user respected app restrictions
  Future<void> _checkAppRestrictions(dynamic dao) async {
    try {
      // Get app restrictions
      final dynamicDao = DriftDbService.instance.driftDb.dynamicRecordsDao;
      final restrictions = await dynamicDao.fetchAppsRestrictions();
      
      if (restrictions.isNotEmpty) {
        // Check if user violated any restrictions today
        // This is a simplified check - proper implementation would track violations
        final prefs = await SharedPreferences.getInstance();
        final violationCount = prefs.getInt('restrictions_violations_today') ?? 0;
        
        if (violationCount == 0) {
          await _pointsService.awardAppRestrictionPoints(showNotification: true);
          debugPrint('User respected all app restrictions');
        } else {
          debugPrint('User violated app restrictions $violationCount times');
        }
        
        // Reset for next day
        await prefs.remove('restrictions_violations_today');
      }
    } catch (e) {
      debugPrint('Error checking app restrictions: $e');
    }
  }

  /// Manually trigger reset (for testing or manual refresh)
  Future<void> forceReset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastResetDateKey);
    await checkAndResetDaily();
  }

  /// Get last reset date
  Future<DateTime?> getLastResetDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastResetDateKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting last reset date: $e');
      return null;
    }
  }
}
