
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/providers/focus/dated_focus_provider.dart';

final lifetimeFocusProvider = FutureProvider<Duration>(
  (ref) {
    /// Listen to todays focus changes
    ref.watch(datedFocusProvider(dateToday));

    return DriftDbService.instance.driftDb.dynamicRecordsDao
        .fetchLifetimeSessionsDuration();
  },
);
