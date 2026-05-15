
import 'package:flutter/material.dart' as m;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/core/database/daos/dynamic_records_dao.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';

final datedNotificationsProvider = StateNotifierProvider.family<
    NotificationsNotifier, AsyncValue<List<Notification>>, m.DateTimeRange>(
  (ref, range) => NotificationsNotifier(range),
);

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<Notification>>> {
  late final DynamicRecordsDao _dao;
  final m.DateTimeRange range;

  NotificationsNotifier(this.range) : super(const AsyncLoading()) {
    _dao = DriftDbService.instance.driftDb.dynamicRecordsDao;
    refreshNotifications();
  }

  /// Fetches and updates the state with the latest list of notifications in the provided range.
  Future<bool> refreshNotifications() async {
    var notifications =
        await _dao.fetchAllNotificationsForInterval(range: range);

    /// update state
    state = AsyncData(notifications);
    return true;
  }

  Future<void> markNotificationsAsRead() async {
    if (state.value == null) return;

    /// Update
    final ids = state.value!.map((e) => e.id).toList();
    await _dao.markNotificationsAsRead(ids);
    state = AsyncData(
      state.value!.map((e) => e.copyWith(isRead: true)).toList(),
    );
  }

  Future<void> deleteNotification(Notification notification) async {
    final deleted = await _dao.removeNotificationWithId(notification.id);
    if (deleted > 0) {
      state = AsyncData(
        [...(state.value ?? []).where((e) => e.id != notification.id)],
      );
    }
  }
}
