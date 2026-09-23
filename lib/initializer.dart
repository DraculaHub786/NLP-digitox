import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/database/daos/dynamic_records_dao.dart';
import 'package:nlp_digitox/core/database/daos/unique_records_dao.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/core/services/productivity_reset_service.dart';
import 'package:nlp_digitox/core/services/productivity_notification_service.dart';
import 'package:nlp_digitox/core/services/notification_scheduler_service.dart';
import 'package:nlp_digitox/core/services/leaderboard_service.dart';
import 'package:nlp_digitox/core/services/session_service.dart';

/// Initializer to initialize necessary things.
class Initializer {
  /// Initializes all the required services and schedules.
  ///
  /// This method must be called after initializing `DATABASE` and `METHOD CHANNEL`.
  ///
  /// The original implementation awaited sixteen independent operations one
  /// after another, which made every cold start pay their sum. The four
  /// "fetch settings, then push them to native" pairs each have an internal
  /// ordering dependency, but nothing depends on another pair's result — so
  /// they (and the three service `.initialize()` calls, plus
  /// `SessionService.init()`) now run concurrently. The leaderboard chain is
  /// kept sequential because it genuinely has an internal ordering
  /// dependency.
  static Future<void> initializeServicesAndSchedules() async {
    final startTimeStamp = DateTime.now();

    final dynamicDao = DriftDbService.instance.driftDb.dynamicRecordsDao;
    final uniqueDao = DriftDbService.instance.driftDb.uniqueRecordsDao;

    await Future.wait([
      _syncAppRestrictions(dynamicDao),
      _syncRestrictionGroups(dynamicDao),
      _syncBedtimeSchedule(uniqueDao),
      _syncWellbeingSettings(uniqueDao),
      _syncNotificationSettings(uniqueDao),
      SessionService.instance.init(),
      ProductivityNotificationService.instance.initialize(),
      ProductivityResetService.instance.initialize(),
    ]);

    /// Leaderboard chain has a real internal ordering dependency (reset must
    /// happen before evaluate, which must happen before mark-active), so it
    /// stays sequential. It is placed after the batch only so
    /// `startDailyStreakEvaluation()` starts from a freshly-evaluated state.
    await LeaderboardService.instance.checkAndResetStreakIfNeeded();
    await LeaderboardService.instance.evaluateAndUpdateStreak();
    await LeaderboardService.instance.markActive();
    LeaderboardService.instance.startDailyStreakEvaluation();

    debugPrint(
      "All necessary services and schedules are initialized and it took ${DateTime.now().difference(startTimeStamp).inMilliseconds}ms.",
    );
  }

  /// Fetches app restrictions, splits the internet-blocked subset out, and
  /// pushes both lists to the native tracker/VPN services concurrently.
  static Future<void> _syncAppRestrictions(DynamicRecordsDao dynamicDao) async {
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

    await Future.wait([
      MethodChannelService.instance.updateAppRestrictions(appRestrictions),
      MethodChannelService.instance
          .updateInternetBlockedApps(internetBlockedApps),
    ]);
  }

  /// Fetches restriction groups and pushes them to the native tracker service.
  static Future<void> _syncRestrictionGroups(
    DynamicRecordsDao dynamicDao,
  ) async {
    final restrictionGroups = await dynamicDao.fetchRestrictionGroups();
    await MethodChannelService.instance
        .updateRestrictionsGroups(restrictionGroups);
  }

  /// Fetches the bedtime schedule and pushes it to the native side.
  static Future<void> _syncBedtimeSchedule(UniqueRecordsDao uniqueDao) async {
    final bedtime = await uniqueDao.loadBedtimeSchedule();
    await MethodChannelService.instance.updateBedtimeSchedule(bedtime);
  }

  /// Fetches the well-being settings and pushes them to the native side.
  static Future<void> _syncWellbeingSettings(UniqueRecordsDao uniqueDao) async {
    final wellbeing = await uniqueDao.loadWellBeingSettings();
    await MethodChannelService.instance.updateWellBeingSettings(wellbeing);
  }

  /// Fetches notification settings once — they are needed by two different
  /// consumers (the native listener service and the scheduler) — and fans the
  /// push out concurrently.
  static Future<void> _syncNotificationSettings(
    UniqueRecordsDao uniqueDao,
  ) async {
    final notificationSettings = await uniqueDao.loadNotificationSettings();
    await Future.wait([
      MethodChannelService.instance
          .updateNotificationSettings(notificationSettings),
      NotificationSchedulerService.instance.initialize().then(
            (_) => NotificationSchedulerService.instance
                .updateAllSchedules(notificationSettings.schedules),
          ),
    ]);
  }
}
