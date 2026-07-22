import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/core/services/productivity_reset_service.dart';
import 'package:nlp_digitox/core/services/productivity_notification_service.dart';
import 'package:nlp_digitox/core/services/notification_scheduler_service.dart';
import 'package:nlp_digitox/core/services/leaderboard_service.dart';

/// Initializer to initialize necessary things.
class Initializer {
  /// Initializes all the required services and schedules.
  ///
  /// This method must be called after initializing `DATABASE` and `METHOD CHANNEL`.
  static Future<void> initializeServicesAndSchedules() async {
    final startTimeStamp = DateTime.now();

    final dynamicDao = DriftDbService.instance.driftDb.dynamicRecordsDao;
    final uniqueDao = DriftDbService.instance.driftDb.uniqueRecordsDao;

    /// fetch app restrictions
    var appRestrictions = await dynamicDao.fetchAppsRestrictions();
    final internetBlockedApps = appRestrictions
        .where((e) => !e.canAccessInternet)
        .map((e) => e.appPackage)
        .toList();

    /// filter out restrictions
    appRestrictions.removeWhere(
      (e) =>
          e.timerSec <= 0 &&
          e.periodDurationInMins <= 0 &&
          e.launchLimit <= 0 &&
          e.associatedGroupId == null,
    );

    /// update tracker service
    await MethodChannelService.instance.updateAppRestrictions(appRestrictions);

    /// update vpn service
    await MethodChannelService.instance
        .updateInternetBlockedApps(internetBlockedApps);

    /// Update restriction groups
    final restrictionGroups = await dynamicDao.fetchRestrictionGroups();
    await MethodChannelService.instance
        .updateRestrictionsGroups(restrictionGroups);

    /// Fetch and update bedtime routine
    final bedtime = await uniqueDao.loadBedtimeSchedule();
    await MethodChannelService.instance.updateBedtimeSchedule(bedtime);

    /// Fetch and update wellbeing
    final wellbeing = await uniqueDao.loadWellBeingSettings();
    await MethodChannelService.instance.updateWellBeingSettings(wellbeing);

    /// Fetch and update notification settings
    final notificationSettings = await uniqueDao.loadNotificationSettings();
    await MethodChannelService.instance
        .updateNotificationSettings(notificationSettings);

    /// Initialize productivity notification service
    await ProductivityNotificationService.instance.initialize();

    /// Initialize notification scheduler service
    await NotificationSchedulerService.instance.initialize();
    await NotificationSchedulerService.instance.updateAllSchedules(notificationSettings.schedules);

    /// Initialize productivity reset service for daily resets and notifications
    await ProductivityResetService.instance.initialize();

    /// Check and reset leaderboard streak if user was inactive
    await LeaderboardService.instance.checkAndResetStreakIfNeeded();

    /// Evaluate streak based on today's screen time (< 8hrs = +1, > 8hrs = reset)
    await LeaderboardService.instance.evaluateAndUpdateStreak();

    /// Stamp lastActiveAt so streak inactivity detection has a real user-activity signal
    await LeaderboardService.instance.markActive();

    /// Check if weekly leaderboard reset is needed (Monday 4 AM)
    await LeaderboardService.instance.checkAndPerformWeeklyReset();

    /// Start periodic monitor for daily streak evaluation (runs every 6 hours)
    LeaderboardService.instance.startDailyStreakEvaluation();

    /// Start periodic monitor for weekly leaderboard points reset (every 15 min, triggers Monday 4 AM)
    LeaderboardService.instance.startWeeklyResetMonitor();

    debugPrint(
      "All necessary services and schedules are initialized and it took ${DateTime.now().difference(startTimeStamp).inMilliseconds}ms.",
    );
  }
}
