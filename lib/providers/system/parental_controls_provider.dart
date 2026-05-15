
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/database/adapters/time_of_day_adapter.dart';
import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/utils/default_models_utils.dart';

/// A Riverpod state notifier provider that manages [ParentalControls]
final parentalControlsProvider =
    StateNotifierProvider<ParentalControlsNotifier, ParentalControls>(
  (ref) => ParentalControlsNotifier(),
);

class ParentalControlsNotifier extends StateNotifier<ParentalControls> {
  bool get isBetweenUninstallWindow => DateTime.now().isBetweenTod(
        state.uninstallWindowTime,
        TimeOfDayAdapter.fromMinutes(state.uninstallWindowTime.toMinutes + 10),
      );

  bool get isBetweenInvincibleWindow => DateTime.now().isBetweenTod(
        state.invincibleWindowTime,
        TimeOfDayAdapter.fromMinutes(state.invincibleWindowTime.toMinutes + 10),
      );

  ParentalControlsNotifier() : super(defaultParentalControlsModel) {
    init();
  }

  Future<ParentalControls> init() async {
    final dao = DriftDbService.instance.driftDb.uniqueRecordsDao;
    state = await dao.loadParentalControls();

    addListener(
      fireImmediately: false,
      (state) => dao.saveParentalControls(state),
    );

    return state;
  }

  void switchProtectedAccess() =>
      state = state.copyWith(protectedAccess: !state.protectedAccess);

  void changeUninstallWindowTime(TimeOfDayAdapter time) =>
      state = state.copyWith(uninstallWindowTime: time);

  void changeInvincibleWindowTime(TimeOfDayAdapter time) =>
      state = state.copyWith(invincibleWindowTime: time);

  void switchInvincibleMode() =>
      state = state.copyWith(isInvincibleModeOn: !state.isInvincibleModeOn);

  void toggleIncludeAppsTimer() =>
      state = state.copyWith(includeAppsTimer: !state.includeAppsTimer);

  void toggleIncludeAppsLaunchLimit() => state =
      state.copyWith(includeAppsLaunchLimit: !state.includeAppsLaunchLimit);

  void toggleIncludeAppsActivePeriod() => state =
      state.copyWith(includeAppsActivePeriod: !state.includeAppsActivePeriod);

  void toggleIncludeGroupsTimer() =>
      state = state.copyWith(includeGroupsTimer: !state.includeGroupsTimer);

  void toggleIncludeGroupsActivePeriod() => state = state.copyWith(
      includeGroupsActivePeriod: !state.includeGroupsActivePeriod);

  void toggleIncludeShortsTimer() =>
      state = state.copyWith(includeShortsTimer: !state.includeShortsTimer);

  void toggleIncludeBedtimeSchedule() => state =
      state.copyWith(includeBedtimeSchedule: !state.includeBedtimeSchedule);
}
