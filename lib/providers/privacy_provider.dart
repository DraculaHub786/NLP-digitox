// Privacy provider for NLP-Digitox
// Riverpod StateNotifier that gates ALL cloud operations

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/privacy_service.dart';
import 'package:nlp_digitox/models/privacy_settings_model.dart';

/// The single source of truth for privacy settings.
/// All services that perform cloud ops should watch this provider
/// before making any Firebase calls.
class PrivacyNotifier extends StateNotifier<PrivacySettings> {
  final PrivacyService _service;

  PrivacyNotifier(this._service) : super(const PrivacySettings()) {
    _load();
  }

  Future<void> _load() async {
    await _service.initialize();
    state = _service.settings;
  }

  // ---------------------------------------------------------------------------
  // Granular toggles — each persists independently
  // ---------------------------------------------------------------------------

  Future<void> setCloudSync(bool enabled) async {
    state = await _service.update(state.copyWith(
      cloudSyncEnabled: enabled,
      // When cloud sync is disabled, cross-device must also be disabled
      crossDeviceFeaturesEnabled:
          enabled ? state.crossDeviceFeaturesEnabled : false,
    ));
  }

  Future<void> setCrossDevice(bool enabled) async {
    if (enabled && !state.cloudSyncEnabled) {
      // Cannot enable cross-device without cloud sync
      return;
    }
    state = await _service.update(state.copyWith(
      crossDeviceFeaturesEnabled: enabled,
    ));
  }

  Future<void> setMoodTracking(bool enabled) async {
    state = await _service.update(state.copyWith(moodTrackingEnabled: enabled));
  }

  Future<void> setAnalytics(bool enabled) async {
    state =
        await _service.update(state.copyWith(analyticsEnabled: enabled));
  }

  // ---------------------------------------------------------------------------
  // Data operations (delegated to PrivacyService)
  // ---------------------------------------------------------------------------

  Future<String> exportData() => _service.exportLocalDataAsJson();

  Future<DeleteDataResult> deleteAllData() => _service.deleteAllUserData();
}

/// Global privacy provider — watch this wherever cloud ops are gated.
final privacyProvider =
    StateNotifierProvider<PrivacyNotifier, PrivacySettings>((ref) {
  return PrivacyNotifier(PrivacyService.instance);
});

/// Convenience derived providers — use these for cheaper rebuilds.

/// True if cloud sync is allowed
final cloudSyncEnabledProvider = Provider<bool>((ref) {
  return ref.watch(privacyProvider).cloudSyncEnabled;
});

/// True if cross-device features are allowed (cloud sync AND cross-device both on)
final crossDeviceEnabledProvider = Provider<bool>((ref) {
  return ref.watch(privacyProvider).effectiveCrossDevice;
});

/// True if mood tracking is allowed
final moodTrackingEnabledProvider = Provider<bool>((ref) {
  return ref.watch(privacyProvider).moodTrackingEnabled;
});
