
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';

final searchedNotificationsProvider =
    FutureProvider.family<List<Notification>, String>(
  (ref, query) async => query.isEmpty
      ? Future.value([])
      : DriftDbService.instance.driftDb.dynamicRecordsDao
          .searchNotificationsWithQuery(query: query),
);
