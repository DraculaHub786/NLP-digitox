import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/core/enums/app_theme_mode.dart';
import 'package:nlp_digitox/core/enums/default_home_tab.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/services/firestore_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/core/utils/default_models_utils.dart';
import 'package:nlp_digitox/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';

/// A Riverpod state notifier provider that manages [DigitoxSettings].
final digitoxSettingsProvider =
    StateNotifierProvider<DigitoxSettingsNotifier, DigitoxSettings>(
  (ref) => DigitoxSettingsNotifier(),
);

/// This class manages the state of digitox settings.
class DigitoxSettingsNotifier extends StateNotifier<DigitoxSettings> {
  DigitoxSettingsNotifier() : super(defaultDigitoxSettingsModel) {
    init(addListenerToo: true);
  }

  /// Initializes the settings state by loading from the database and setting up a listener for saving changes.
  Future<DigitoxSettings> init({bool addListenerToo = false}) async {
    final dao = DriftDbService.instance.driftDb.uniqueRecordsDao;
    state = await dao.loadDigitoxSettings();
    await MethodChannelService.instance
        .updateLocale(languageCode: state.localeCode);

    if (addListenerToo) {
      /// Run after a delay to avoid database deadlock
      /// Listen to provider and save changes to Isar database
      Future.delayed(
        1.seconds,
        () => addListener(
          fireImmediately: false,
          (state) => dao.saveDigitoxSettings(state),
        ),
      );
    }

    return state;
  }

  /// Changes the username for dashboard.
  void changeUsername(String username) =>
      state = state.copyWith(username: username);

  /// Changes the application's theme mode.
  void changeThemeMode(AppThemeMode mode) =>
      state = state.copyWith(themeMode: mode);

  /// Changes the application's color theme.
  void changeColor(String color) => state = state.copyWith(accentColor: color);

  /// Switch AMOLED dark mode
  void switchAmoledDark() =>
      state = state.copyWith(useAmoledDark: !state.useAmoledDark);

  /// Switch dynamic color
  void switchDynamicColor() =>
      state = state.copyWith(useDynamicColors: !state.useDynamicColors);

  /// Changes app locale if it is supported.
  void changeLocale(String localeCode) async {
    if (AppLocalizations.supportedLocales.any(
      (e) => e.languageCode == localeCode,
    )) {
      /// Update state
      state = state.copyWith(localeCode: localeCode);

      /// Update native side
      await MethodChannelService.instance
          .updateLocale(languageCode: localeCode);
    }
  }

  /// Changes the default initial home tab.
  void changeHomeTab(DefaultHomeTab tab) =>
      state = state.copyWith(defaultHomeTab: tab);

  /// Changes the default usage history weeks.
  void changeUsageHistoryWeeks(int weeks) =>
      state = state.copyWith(usageHistoryWeeks: weeks);

  /// Update the emergency pass count if last used timestamp is before today midnight
  /// and returns it
  int getUpdatedEmergencyPassCount() {
    final todayMidnight = DateTime.now().dateOnly;

    /// Reset emergency passes if the last timestamp is from yesterday
    if (state.lastEmergencyUsed.isBefore(todayMidnight)) {
      state = state.copyWith(leftEmergencyPasses: 3);
    }

    return state.leftEmergencyPasses;
  }

  /// Use emergency pause pass and pause the tracking service
  void useEmergencyPausePass() => state = state.copyWith(
        lastEmergencyUsed: DateTime.now(),
        leftEmergencyPasses: state.leftEmergencyPasses - 1,
      );

  /// Mark onboarding as completed
  void markOnboardingDone() {
    state = state.copyWith(isOnboardingDone: true);

    // Sync to Firestore
    _syncOnboardingStatusToFirestore();
  }

  /// Sync onboarding status to Firestore
  Future<void> _syncOnboardingStatusToFirestore() async {
    try {
      final settings = await FirestoreService.instance.getUserSettings();
      settings['isOnboardingDone'] = true;
      await FirestoreService.instance.updateSettings(settings);
      debugPrint('✅ Onboarding status synced to Firestore');
    } catch (e) {
      debugPrint('❌ Failed to sync onboarding status to Firestore: $e');
      // Don't throw - local state is already updated
    }
  }

  /// Update app version
  void updateAppVersion() => state = state.copyWith(
        appVersion: MethodChannelService.instance.deviceInfo.digitoxVersion,
      );
}
