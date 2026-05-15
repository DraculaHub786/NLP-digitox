
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/database/daos/dynamic_records_dao.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';

final monthlyNotificationsCountProvider = StateNotifierProvider.family<
        MonthlyNotificationsNotifier, Map<DateTime, int>, DateTimeRange>(
    (ref, monthRange) => MonthlyNotificationsNotifier(monthRange));

class MonthlyNotificationsNotifier extends StateNotifier<Map<DateTime, int>> {
  late DynamicRecordsDao _dao;
  final DateTimeRange monthRange;

  MonthlyNotificationsNotifier(this.monthRange) : super({}) {
    _dao = DriftDbService.instance.driftDb.dynamicRecordsDao;
    refreshTimeline();
  }

  /// Refresh the state
  Future<void> refreshTimeline() async {
    final countsMap = await _dao.fetchNotificationsCountForInterval(
      monthRange.start,
      monthRange.end.add(1.days).subtract(1.seconds),
    );

    if (mounted) {
      state = countsMap;
    }
  }
}
