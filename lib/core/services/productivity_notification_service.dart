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

/// Service to handle productivity-related notifications
class ProductivityNotificationService {
  // Singleton pattern
  static ProductivityNotificationService? _instance;
  static ProductivityNotificationService get instance {
    _instance ??= ProductivityNotificationService._();
    return _instance!;
  }

  ProductivityNotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
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

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;
      debugPrint('ProductivityNotificationService initialized');
    } catch (e) {
      debugPrint('Error initializing productivity notifications: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to productivity section
  }

  /// Send notification for incomplete items
  Future<void> sendIncompleteItemsNotification({
    required int incompleteHabitsCount,
    required int incompleteTasksCount,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final totalIncomplete = incompleteHabitsCount + incompleteTasksCount;
      if (totalIncomplete == 0) return;

      String title = '⏰ Don\'t forget your daily goals!';
      String body = '';

      if (incompleteHabitsCount > 0 && incompleteTasksCount > 0) {
        body =
            'You have $incompleteHabitsCount habit${incompleteHabitsCount > 1 ? 's' : ''} and $incompleteTasksCount task${incompleteTasksCount > 1 ? 's' : ''} to complete today.';
      } else if (incompleteHabitsCount > 0) {
        body =
            'You have $incompleteHabitsCount habit${incompleteHabitsCount > 1 ? 's' : ''} to complete today.';
      } else {
        body =
            'You have $incompleteTasksCount task${incompleteTasksCount > 1 ? 's' : ''} to complete today.';
      }

      const androidDetails = AndroidNotificationDetails(
        'productivity_channel',
        'Productivity Reminders',
        channelDescription:
            'Notifications to remind you about incomplete habits and tasks',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
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

      await _notificationsPlugin.show(
        1, // Notification ID
        title,
        body,
        notificationDetails,
        payload: 'productivity',
      );

      debugPrint('Sent productivity notification: $title - $body');
    } catch (e) {
      debugPrint('Error sending productivity notification: $e');
    }
  }

  /// Send notification for streak milestone
  Future<void> sendStreakMilestoneNotification({
    required String habitName,
    required int streak,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      String title = '🔥 Streak Milestone!';
      String body = 'You\'ve completed "$habitName" for $streak days in a row! Keep it up!';

      const androidDetails = AndroidNotificationDetails(
        'productivity_channel',
        'Productivity Reminders',
        channelDescription: 'Notifications for productivity achievements',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
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

      await _notificationsPlugin.show(
        2, // Notification ID
        title,
        body,
        notificationDetails,
        payload: 'streak_milestone',
      );

      debugPrint('Sent streak milestone notification');
    } catch (e) {
      debugPrint('Error sending streak milestone notification: $e');
    }
  }

  /// Send notification for points earned
  Future<void> sendPointsEarnedNotification({
    required int points,
    required String category,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      String title = '⭐ Points Earned!';
      String body = 'You earned $points points for $category!';

      const androidDetails = AndroidNotificationDetails(
        'productivity_channel',
        'Productivity Reminders',
        channelDescription: 'Notifications for productivity achievements',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
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

      await _notificationsPlugin.show(
        3, // Notification ID
        title,
        body,
        notificationDetails,
        payload: 'points_earned',
      );

      debugPrint('Sent points earned notification');
    } catch (e) {
      debugPrint('Error sending points earned notification: $e');
    }
  }

  /// Cancel all productivity notifications
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('Cancelled all productivity notifications');
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }
}
