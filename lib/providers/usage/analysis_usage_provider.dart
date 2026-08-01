import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/models/usage_model.dart';

/// Aggregates per-day screen time over the last [days] (7, 30 or 90)
/// ordered chronologically, oldest -> newest.
final analysisUsageProvider =
    FutureProvider.autoDispose.family<Map<DateTime, UsageModel>, int>(
        (ref, days) async {
  final end = dateToday;
  final start = end.subtract(Duration(days: days - 1));
  final (_, usageMap) = await DriftDbService.instance.driftDb.dynamicRecordsDao
      .fetchWeeklyDeviceUsage(weekRange: DateTimeRange(start: start, end: end));

  // Fill any missing days with zero usage so the chart is a continuous series.
  final result = <DateTime, UsageModel>{};
  for (var i = 0; i < days; i++) {
    final day = start.add(Duration(days: i));
    result[day] = usageMap[day] ?? const UsageModel();
  }
  return result;
});
