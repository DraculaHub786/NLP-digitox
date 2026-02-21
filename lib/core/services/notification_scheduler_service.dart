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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:nlp_digitox/models/notification_schedule.dart';
import 'package:nlp_digitox/core/services/leaderboard_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle scheduled notification reminders
class NotificationSchedulerService {
  // Singleton pattern
  static NotificationSchedulerService? _instance;
  static NotificationSchedulerService get instance {
    _instance ??= NotificationSchedulerService._();
    return _instance!;
  }

  NotificationSchedulerService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _leaderboardService = LeaderboardService.instance;

  bool _initialized = false;

  /// Initialize the notification scheduler service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      final location = tz.getLocation('UTC');
      tz.setLocalLocation(location);
      debugPrint('Timezone initialized: ${tz.local.name}');
      
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      debugPrint('NotificationSchedulerService initialization result: $initialized');

      // Request notification permissions for Android 13+
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('Notification permission granted: $granted');
        
        final exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();
        debugPrint('Exact alarm permission granted: $exactAlarmGranted');
      }

      _initialized = true;
      debugPrint('NotificationSchedulerService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notification scheduler: $e');
      rethrow;
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) async {
    debugPrint('Scheduled notification tapped: ${response.payload}');
    
    // Check if the notification was marked as complete (via action)
    if (response.actionId == 'COMPLETE') {
      await _markScheduleCompleted(response.payload ?? '');
    }
    
    // TODO: Navigate to notifications section
  }

  /// Mark a schedule as completed and award points
  Future<void> _markScheduleCompleted(String payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final completedKey = 'schedule_completed_$today';
      
      // Get list of completed schedules today
      final completedToday = prefs.getStringList(completedKey) ?? [];
      
      // Check if this schedule was already completed today
      if (!completedToday.contains(payload)) {
        completedToday.add(payload);
        await prefs.setStringList(completedKey, completedToday);
        
        // Award 20 points for completing notification schedule
        await _leaderboardService.addPoints(20, 'Notification Schedules');
        debugPrint('Awarded 20 points for completing notification schedule: $payload');
      }
    } catch (e) {
      debugPrint('Error marking schedule completed: $e');
    }
  }

  /// Schedule a daily notification at the specified time
  Future<void> scheduleNotification(NotificationSchedule schedule, int index) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Cancel existing notification for this schedule
      await _notificationsPlugin.cancel(1000 + index);

      if (!schedule.isActive) {
        debugPrint('Schedule "${schedule.label}" is inactive, skipping scheduling');
        return;
      }

      // Calculate next notification time
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        schedule.time.hour,
        schedule.time.minute,
      );

      // If the scheduled time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'scheduled_reminders',
        'Scheduled Reminders',
        channelDescription:
            'Daily scheduled reminder notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'COMPLETE',
            'Complete',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        1000 + index, // Notification ID (offset by 1000 to avoid conflicts)
        '⏰ ${schedule.label}',
        'This is your scheduled reminder',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at this time
        payload: 'schedule_${schedule.label}',
      );

      debugPrint(
          '✅ Successfully scheduled notification ID ${1000 + index}: "${schedule.label}" for ${scheduledDate.toString()}');
      debugPrint('   Next occurrence: ${schedule.time.hour}:${schedule.time.minute.toString().padLeft(2, '0')}');
    } catch (e) {
      debugPrint('❌ Error scheduling notification "${schedule.label}": $e');
      rethrow;
    }
  }

  /// Cancel a scheduled notification
  Future<void> cancelScheduleNotification(int index) async {
    try {
      await _notificationsPlugin.cancel(1000 + index);
      debugPrint('Cancelled schedule notification at index $index');
    } catch (e) {
      debugPrint('Error cancelling schedule notification: $e');
    }
  }

  /// Update all scheduled notifications based on the list
  Future<void> updateAllSchedules(List<NotificationSchedule> schedules) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      debugPrint('🔄 Updating all notification schedules...');
      
      // Cancel all existing schedule notifications (1000-1099)
      for (int i = 0; i < 100; i++) {
        await _notificationsPlugin.cancel(1000 + i);
      }
      debugPrint('   Cancelled all existing schedule notifications');

      // Schedule active notifications
      int scheduledCount = 0;
      for (int i = 0; i < schedules.length; i++) {
        if (schedules[i].isActive) {
          await scheduleNotification(schedules[i], i);
          scheduledCount++;
        } else {
          debugPrint('   Skipping inactive schedule: ${schedules[i].label}');
        }
      }

      debugPrint('✅ Updated all schedules: $scheduledCount active out of ${schedules.length} total');
      
      // Verify scheduled notifications
      final pending = await getPendingNotifications();
      debugPrint('   Current pending notifications: ${pending.length}');
      for (final notification in pending) {
        if (notification.id >= 1000 && notification.id < 1100) {
          debugPrint('   - ID ${notification.id}: ${notification.title}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error updating all schedules: $e');
      rethrow;
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllSchedules() async {
    try {
      // Cancel all schedule notifications (1000-1999)
      for (int i = 0; i < 100; i++) {
        await _notificationsPlugin.cancel(1000 + i);
      }
      debugPrint('Cancelled all schedule notifications');
    } catch (e) {
      debugPrint('Error cancelling all schedules: $e');
    }
  }

  /// Get list of pending scheduled notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }
}
