/*
 *
 *  * Copyright (c) 2024 NLP digitox
 *  * Author : Pawan Nagar
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nlp_digitox/core/services/productivity_service.dart';
import 'package:nlp_digitox/core/services/productivity_notification_service.dart';

/// Service to handle daily resets of productivity items (habits and tasks)
/// and check for incomplete items to send notifications
class ProductivityResetService {
  static const String _lastResetDateKey = 'productivity_last_reset_date';
  static const String _notificationCheckTimeKey = 'productivity_notification_check_time';
  
  // Singleton pattern
  static ProductivityResetService? _instance;
  static ProductivityResetService get instance {
    _instance ??= ProductivityResetService._();
    return _instance!;
  }

  ProductivityResetService._();

  final _productivityService = ProductivityService.instance;
  final _notificationService = ProductivityNotificationService.instance;
  
  Timer? _resetCheckTimer;

  /// Initialize the reset service
  /// Call this during app startup
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
      final today = DateTime(now.year, now.month, now.day);

      DateTime? lastResetDate;
      if (lastResetTimestamp != null) {
        lastResetDate = DateTime.fromMillisecondsSinceEpoch(lastResetTimestamp);
        final lastResetDay = DateTime(
          lastResetDate.year,
          lastResetDate.month,
          lastResetDate.day,
        );

        // If already reset today, skip
        if (lastResetDay == today) {
          debugPrint('Already reset today, skipping');
          return;
        }
      }

      debugPrint('Performing daily reset for productivity items');

      // Reset habits
      await _resetHabits(today);

      // Reset tasks
      await _resetTasks(today);

      // Update last reset date
      await prefs.setInt(_lastResetDateKey, today.millisecondsSinceEpoch);

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
          
          // If habit was not completed yesterday, break the streak
          if (habit.completedToday == false && habit.streak > 0) {
            final yesterday = today.subtract(const Duration(days: 1));
            final wasCompletedYesterday = habit.completedDates.any((date) =>
                date.year == yesterday.year &&
                date.month == yesterday.month &&
                date.day == yesterday.day);
            
            if (!wasCompletedYesterday) {
              newStreak = 0;
              debugPrint('Habit "${habit.name}" streak reset to 0');
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
        debugPrint('Habits reset completed');
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
