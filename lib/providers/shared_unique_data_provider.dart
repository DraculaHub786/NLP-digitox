
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/core/utils/default_models_utils.dart';

/// A Riverpod state notifier provider that manages [SharedUniqueData].
final sharedUniqueDataProvider =
    StateNotifierProvider<SharedDataNotifier, SharedUniqueData>(
  (ref) => SharedDataNotifier(),
);

class SharedDataNotifier extends StateNotifier<SharedUniqueData> {
  SharedDataNotifier() : super(defaultSharedUniqueDataModel) {
    init();
  }

  void init() async {
    final dao = DriftDbService.instance.driftDb.uniqueRecordsDao;
    state = await dao.loadSharedData();

    await MethodChannelService.instance.updateExcludedApps(state.excludedApps);

    /// Run after a delay to avoid database deadlock
    /// Listen to provider and save changes to database
    Future.delayed(
      1.seconds,
      () => addListener(
        fireImmediately: false,
        (state) => dao.saveSharedData(state),
      ),
    );
  }

  /// Include or Exclude an app from total usage statistics
  void includeExcludeApp(String appPackage, bool shouldInclude) async {
    state = state.copyWith(
      excludedApps: shouldInclude
          ? [...state.excludedApps, appPackage]
          : [...state.excludedApps.where((e) => e != appPackage)],
    );

    await MethodChannelService.instance.updateExcludedApps(state.excludedApps);
  }
}
