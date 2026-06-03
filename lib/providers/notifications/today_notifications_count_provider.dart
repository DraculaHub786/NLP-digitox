import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/database/daos/dynamic_records_dao.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';

final todayNotificationsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final DynamicRecordsDao dao = DriftDbService.instance.driftDb.dynamicRecordsDao;
  final notifications = await dao.fetchAllNotificationsForInterval(
    range: DateTime.now().last24Hours,
  );
  return notifications.length;
});