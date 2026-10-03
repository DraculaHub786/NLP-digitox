

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/config/navigation/navigation_service.dart';
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
  AndroidScheduleMode _androidScheduleMode =
      AndroidScheduleMode.exactAllowWhileIdle;

  bool _initialized = false;

  /// Re-checks the Android exact-alarm permission and, if the schedule mode
  /// would change, re-registers every active schedule under the new mode.
  ///
  /// Needed because `initialize()` only computes `_androidScheduleMode` once
  /// at cold start. If the user hadn't granted "Schedule exact alarms" yet
  /// at that point, every schedule silently falls back to
  /// `inexactAllowWhileIdle` for the rest of the app session — even after
  /// the user grants the permission from Settings — because nothing else
  /// ever re-evaluates it. That produces notifications that fire late (or
  /// get deferred by the OS entirely under Doze), which reads as "the
  /// schedule doesn't trigger when the time arrives."
  Future<void> refreshScheduleMode(List<NotificationSchedule> schedules) async {
    if (!_initialized) return;

    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    final exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();
    final newMode = (exactAlarmGranted ?? false)
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    if (newMode == _androidScheduleMode) return;

    debugPrint(
        'Exact alarm permission changed — schedule mode: $_androidScheduleMode -> $newMode. Re-registering schedules.');
    _androidScheduleMode = newMode;
    await updateAllSchedules(schedules);
  }

  /// Initialize the notification scheduler service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.Location location;
      try {
        location = tz.getLocation(timeZoneName);
      } catch (_) {
        debugPrint(
            'Unknown timezone "$timeZoneName", falling back to UTC for scheduling');
        location = tz.getLocation('UTC');
      }
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
        _androidScheduleMode = (exactAlarmGranted ?? false)
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle;
      } else {
        _androidScheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
      }
      debugPrint('Notification schedule mode: $_androidScheduleMode');

      _initialized = true;
      debugPrint('NotificationSchedulerService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notification scheduler: $e');
      rethrow;
    }
  }

  /// Handle notification tap
  ///
  /// Two distinct tap sources:
  /// - The "Complete" action button → marks the schedule done + awards points.
  ///   `cancelNotification: true` means the OS already dismissed it; do NOT
  ///   navigate, the user just wanted to check off a reminder.
  /// - A plain tap on the notification body → opens the Notifications screen,
  ///   which hosts both the timeline and the schedules management UI.
  void _onNotificationTapped(NotificationResponse response) async {
    debugPrint('Scheduled notification tapped: ${response.payload}');

    // Check if the notification was marked as complete (via action)
    if (response.actionId == 'COMPLETE') {
      await _markScheduleCompleted(response.payload ?? '');
      return;
    }

    // A group session reminder opens the group it belongs to, not the
    // schedules list: the user tapped "your group session starts soon", and
    // landing anywhere but that group is a dead end.
    final payload = response.payload;
    final route =
        payload != null && payload.startsWith(groupReminderPayloadPrefix)
            ? AppRoutes.groupsPath
            : AppRoutes.notificationsPath;

    // Uses the global navigator key so this works even when the tap
    // cold-starts the app (no widget context). Guarded against double-pushes
    // via NavigationService's current-route check.
    try {
      await NavigationService.instance.goToRoute(route);
    } catch (e) {
      debugPrint('Could not navigate after notification tap: $e');
    }
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

      // Channel ID bumped from 'scheduled_reminders_v2' to 'scheduled_reminders_v3'
      // to 'scheduled_reminders_v4': Android notification channels are
      // immutable after first creation, so existing installs would keep the
      // old channel's (possibly silent, or default-sound) behavior no matter
      // what we change here. A new ID forces the OS to create a fresh
      // channel that inherits these explicit sound/vibration settings,
      // including the custom reminder sound below. Bump this again any time
      // sound/importance/vibration changes — code-only changes never take
      // effect on a device that already created the previous channel id.
      const androidDetails = AndroidNotificationDetails(
        'scheduled_reminders_v4',
        'Scheduled Reminders',
        channelDescription:
            'Daily scheduled reminder notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        // Custom sound for user-set schedules only. File lives at
        // android/app/src/main/res/raw/schedule_reminder_sound.wav — resource
        // name passed WITHOUT the file extension.
        sound: RawResourceAndroidNotificationSound('schedule_reminder_sound'),
        enableVibration: true,
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
        // Custom sound for user-set schedules only. File lives at
        // ios/Runner/Resources/schedule_reminder_sound.wav — iOS bundles a
        // resource by filename (WITH extension), unlike Android's raw res.
        sound: 'schedule_reminder_sound.wav',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        1000 + index, // Notification ID (offset by 1000 to avoid conflicts)
        '⏰ ${schedule.label}',
        'Time for "${schedule.label}" — tap Complete when done, or open '
            'Notifications to review your schedules.',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: _androidScheduleMode,
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

  // ---------------------------------------------------------------------------
  // Group session reminders
  //
  // Scheduled through this same service rather than a second one: the app has
  // exactly one FlutterLocalNotificationsPlugin, and calling `initialize()` on a
  // second instance would replace the tap handler above — silently breaking the
  // "Complete" action on the daily schedules. A separate id range and channel
  // keeps the two families of notifications apart instead.
  // ---------------------------------------------------------------------------

  /// Payload prefix identifying a group session reminder.
  static const String groupReminderPayloadPrefix = 'group_session_';

  /// First notification id reserved for group session reminders.
  ///
  /// `1000-1099` belongs to the daily schedules, so reminders start at 2000 and
  /// the two can never cancel each other.
  static const int groupReminderBaseId = 2000;

  /// How many ids the reminder range reserves.
  static const int groupReminderIdRange = 100;

  /// Cancels every pending group session reminder.
  Future<void> cancelGroupReminders() async {
    if (!_initialized) return;
    try {
      for (var i = 0; i < groupReminderIdRange; i++) {
        await _notificationsPlugin.cancel(groupReminderBaseId + i);
      }
      debugPrint('Cancelled all group session reminders');
    } catch (e) {
      debugPrint('Error cancelling group session reminders: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Shared-session end reminders
  //
  // A one-off "the run has ended" heads-up, scheduled for the moment a shared
  // session's run reaches `endAt`. It exists so a member whose phone was
  // face-down for the whole run is nudged to reopen the app, which is the only
  // way the completion report actually gets sent (see
  // `SessionCompletionReconciler`). Same reasoning as the group reminders above
  // for reusing this service: one plugin, one tap handler, a distinct id range
  // and channel.
  // ---------------------------------------------------------------------------

  /// First notification id reserved for shared-session end reminders.
  ///
  /// `1000-1099` belongs to the daily schedules and `2000-2099` to the group
  /// reminders, so this family starts at 3000 and can never cancel either.
  static const int sessionEndBaseId = 3000;

  /// How many ids the session-end range reserves.
  static const int sessionEndIdRange = 100;

  /// Cancels every pending shared-session end reminder.
  ///
  /// Called before re-scheduling on each reconcile, so the pending set is
  /// always derived from the sessions that are actually still running rather
  /// than accumulating an alarm per session the user ever started.
  Future<void> cancelSessionEndReminders() async {
    if (!_initialized) return;
    try {
      for (var i = 0; i < sessionEndIdRange; i++) {
        await _notificationsPlugin.cancel(sessionEndBaseId + i);
      }
      debugPrint('Cancelled all session end reminders');
    } catch (e) {
      debugPrint('Error cancelling session end reminders: $e');
    }
  }

  /// Schedules one "session ended" reminder for [sessionId] at [when].
  ///
  /// The id is derived from the session id rather than a caller-assigned slot:
  /// a reconcile may run before the previous one has finished, and a collision
  /// there would silently drop one session's reminder.
  Future<void> scheduleSessionEndReminder({
    required String sessionId,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final scheduledDate = tz.TZDateTime.from(when, tz.local);
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        // The run already ended. Nothing to schedule, and asking the OS for a
        // past time either fires immediately or is dropped.
        return;
      }

      const androidDetails = AndroidNotificationDetails(
        'session_end_reminders_v1',
        'Session Finished',
        channelDescription: 'Tells you when a shared focus run has ended',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
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
        sessionEndBaseId + (sessionId.hashCode.abs() % sessionEndIdRange),
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: _androidScheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: '$groupReminderPayloadPrefix$sessionId',
      );

      debugPrint('✅ Scheduled session end reminder for $sessionId at '
          '$scheduledDate');
    } catch (e) {
      debugPrint('❌ Error scheduling session end reminder: $e');
      rethrow;
    }
  }

  /// Schedules one group session reminder at [when].
  ///
  /// [slot] is the position in the reminder range, assigned by the caller from
  /// a freshly sorted list, so no two reminders fight over the same id.
  Future<void> scheduleGroupReminder({
    required int slot,
    required String title,
    required String body,
    required DateTime when,
    required String groupId,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final scheduledDate = tz.TZDateTime.from(when, tz.local);
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        // The plan passed while the app was closed. Nothing to schedule, and
        // asking the OS for a past time either fires immediately or is dropped.
        return;
      }

      // A separate channel from the daily schedules: this is a one-off
      // "it starts soon" heads-up, not a repeating reminder, and a user who
      // silences schedules should not thereby silence their group.
      const androidDetails = AndroidNotificationDetails(
        'group_session_reminders_v1',
        'Group Session Reminders',
        channelDescription: 'Heads-up before a scheduled group focus session',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
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
        groupReminderBaseId + slot,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: _androidScheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: '$groupReminderPayloadPrefix$groupId',
      );

      debugPrint(
          '✅ Scheduled group reminder $slot for $scheduledDate ($groupId)');
    } catch (e) {
      debugPrint('❌ Error scheduling group reminder: $e');
      rethrow;
    }
  }
}
