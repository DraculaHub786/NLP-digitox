// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/core/utils/provider_utils.dart';
import 'package:nlp_digitox/models/usage_model.dart';
import 'package:nlp_digitox/providers/usage/todays_apps_usage_provider.dart';

/// Provides aggregated device usage based on day for current week.
/// This includes screen time, wifi usage, and mobile usage
///
/// For all apps on device
final weeklyDeviceUsageProvider = StateNotifierProvider.family<
    WeeklyDeviceUsageNotifier, Map<DateTime, UsageModel>, DateTimeRange>(
  (ref, dateRange) => WeeklyDeviceUsageNotifier(
    dateRange,
    ref.watch(todaysAppsUsageProvider).value ?? {},
  ),
);

class WeeklyDeviceUsageNotifier
    extends StateNotifier<Map<DateTime, UsageModel>> {
  final DateTimeRange range;
  final Map<String, UsageModel> todaysUsage;

  WeeklyDeviceUsageNotifier(this.range, this.todaysUsage)
      : super(generateEmptyWeekUsage(range.start)) {
    refreshUsage();
  }

  void refreshUsage() async {
    final (haveUsage, cache) = await DriftDbService
        .instance.driftDb.dynamicRecordsDao
        .fetchWeeklyDeviceUsage(weekRange: range);

    debugPrint("WeeklyDeviceUsageProvider.refreshUsage: haveUsage=$haveUsage, cache size=${cache.length}, entries=${cache.length > 0 ? cache.entries.map((e) => '${e.key}: ${e.value.screenTime}s').join(', ') : 'empty'}");

    /// Only reload todays usage if needed
    if (cache.containsKey(dateToday)) {
      /// Update todays usage
      cache[dateToday] = todaysUsage.values.fold(
        const UsageModel(),
        (prev, e) => prev + e,
      );
    }

    if (!mounted) return;

    state = cache;
    
    // Always try to populate if we don't have usage data
    if (!haveUsage) {
      debugPrint("WeeklyDeviceUsageProvider: No usage data found, populating database...");
      _populateAppsUsageHistory();
    } else {
      debugPrint("WeeklyDeviceUsageProvider: Usage data exists, skipping population");
    }
  }

  /// Populates the database with app's usage history for last 10 days
  Future<void> _populateAppsUsageHistory() async {
    debugPrint("WeeklyDeviceUsageProvider: Starting database population with last 10 days usage");

    final db = DriftDbService.instance.driftDb;
    List<AppUsageTableCompanion> weeksUsageCompanions = [];
    final initialDate = dateToday.add(1.days); /// Future today midnight (tomorrow)

    for (var i = 0; i < 10; i++) {
      final currentDay = initialDate.subtract(i.days);

      debugPrint("WeeklyDeviceUsageProvider: Fetching usage for day ${i + 1}/10: ${currentDay.subtract(1.days)}");

      /// Fetch usages for the day
      final usages =
          await MethodChannelService.instance.fetchAppsUsageForInterval(
        start: currentDay.subtract(1.days),
        end: currentDay,
      );

      debugPrint("WeeklyDeviceUsageProvider: Fetched ${usages.length} app usages for ${currentDay.subtract(1.days)}");

      /// Map to companions
      final usageCompanions = usages.entries
          .map(
            (entry) => AppUsageTableCompanion(
              date: Value(currentDay.subtract(1.days)),
              packageName: Value(entry.key),
              screenTime: Value(entry.value.screenTime),
              mobileData: Value(entry.value.mobileData),
              wifiData: Value(entry.value.wifiData),
            ),
          )
          .toList();

      weeksUsageCompanions.addAll(usageCompanions);
    }

    debugPrint("WeeklyDeviceUsageProvider: Total companions to insert: ${weeksUsageCompanions.length}");

    /// Insert all usages to db
    await db.dynamicRecordsDao.insertBatchAppUsages(weeksUsageCompanions);
    debugPrint("WeeklyDeviceUsageProvider: Successfully populated database with last 10 days usage");

    /// Refresh provider state
    refreshUsage();
  }
}
