// Privacy settings model for NLP-Digitox

import 'dart:convert';

/// Holds all user privacy preferences.
/// Stored in SharedPreferences as a JSON blob.
class PrivacySettings {
  /// Whether Firebase/cloud sync is enabled for usage quotas and locks.
  /// When false, SyncService operates fully locally.
  final bool cloudSyncEnabled;

  /// Whether cross-device features (primary device, device locks) are active.
  /// Automatically false when [cloudSyncEnabled] is false.
  final bool crossDeviceFeaturesEnabled;

  /// Whether mood/sentiment tracking is enabled (SentimentFilter).
  final bool moodTrackingEnabled;

  /// Whether anonymous analytics are sent (future use).
  final bool analyticsEnabled;

  const PrivacySettings({
    this.cloudSyncEnabled = true,
    this.crossDeviceFeaturesEnabled = true,
    this.moodTrackingEnabled = true,
    this.analyticsEnabled = false,
  });

  /// Effective cross-device: only possible when cloud sync is on.
  bool get effectiveCrossDevice =>
      cloudSyncEnabled && crossDeviceFeaturesEnabled;

  factory PrivacySettings.fromJson(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return PrivacySettings(
        cloudSyncEnabled: map['cloudSyncEnabled'] as bool? ?? true,
        crossDeviceFeaturesEnabled:
            map['crossDeviceFeaturesEnabled'] as bool? ?? true,
        moodTrackingEnabled: map['moodTrackingEnabled'] as bool? ?? true,
        analyticsEnabled: map['analyticsEnabled'] as bool? ?? false,
      );
    } catch (_) {
      return const PrivacySettings();
    }
  }

  String toJson() => jsonEncode({
        'cloudSyncEnabled': cloudSyncEnabled,
        'crossDeviceFeaturesEnabled': crossDeviceFeaturesEnabled,
        'moodTrackingEnabled': moodTrackingEnabled,
        'analyticsEnabled': analyticsEnabled,
      });

  PrivacySettings copyWith({
    bool? cloudSyncEnabled,
    bool? crossDeviceFeaturesEnabled,
    bool? moodTrackingEnabled,
    bool? analyticsEnabled,
  }) {
    return PrivacySettings(
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      crossDeviceFeaturesEnabled:
          crossDeviceFeaturesEnabled ?? this.crossDeviceFeaturesEnabled,
      moodTrackingEnabled: moodTrackingEnabled ?? this.moodTrackingEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivacySettings &&
          runtimeType == other.runtimeType &&
          cloudSyncEnabled == other.cloudSyncEnabled &&
          crossDeviceFeaturesEnabled == other.crossDeviceFeaturesEnabled &&
          moodTrackingEnabled == other.moodTrackingEnabled &&
          analyticsEnabled == other.analyticsEnabled;

  @override
  int get hashCode =>
      cloudSyncEnabled.hashCode ^
      crossDeviceFeaturesEnabled.hashCode ^
      moodTrackingEnabled.hashCode ^
      analyticsEnabled.hashCode;

  @override
  String toString() => 'PrivacySettings('
      'cloudSync: $cloudSyncEnabled, '
      'crossDevice: $effectiveCrossDevice, '
      'mood: $moodTrackingEnabled, '
      'analytics: $analyticsEnabled)';
}
