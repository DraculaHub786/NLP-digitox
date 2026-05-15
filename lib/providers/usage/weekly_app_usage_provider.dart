
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/core/utils/provider_utils.dart';
import 'package:nlp_digitox/models/usage_model.dart';
import 'package:nlp_digitox/providers/usage/todays_apps_usage_provider.dart';

/// Provides aggregated device usage based on day for current week.
/// This includes screen time, wifi usage, and mobile usage
///
/// Only for the given app
final weeklyAppUsageProvider = StateNotifierProvider.family<
    WeeklyAppUsageNotifier,
    Map<DateTime, UsageModel>,
    (String packageName, DateTimeRange range)>(
  (ref, params) => WeeklyAppUsageNotifier(
    params.$1,
    params.$2,
    ref.watch(todaysAppsUsageProvider).value ?? {},
  ),
);

class WeeklyAppUsageNotifier extends StateNotifier<Map<DateTime, UsageModel>> {
  final String packageName;
  final DateTimeRange range;
  final Map<String, UsageModel> todaysUsage;

  WeeklyAppUsageNotifier(this.packageName, this.range, this.todaysUsage)
      : super(generateEmptyWeekUsage(range.start)) {
    init();
  }

  void init() async {
    final cache = await DriftDbService.instance.driftDb.dynamicRecordsDao
        .fetchWeeklyAppUsage(packageName: packageName, weekRange: range);

    /// Only reload todays usage if needed
    if (cache.containsKey(dateToday) && todaysUsage.containsKey(packageName)) {
      cache[dateToday] = todaysUsage[packageName]!;
    }

    state = cache;
  }
}
