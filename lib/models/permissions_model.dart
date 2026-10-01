/// Represents the state of all app permissions and the accessibility service liveness.
class PermissionsModel {
  /// Indicates whether the notification permission is granted.
  final bool haveNotificationPermission;

  /// Indicates whether the usage access permission is granted.
  final bool haveUsageAccessPermission;

  /// Indicates whether the Do Not Disturb (DND) permission is granted.
  final bool haveDndPermission;

  /// Indicates whether the display overlay permission is granted.
  final bool haveDisplayOverlayPermission;

  /// Indicates whether the VPN permission is granted.
  final bool haveVpnPermission;

  /// Indicates whether the accessibility permission is granted.
  final bool haveAccessibilityPermission;

  /// Indicates whether the set exact alarm permission is granted.
  final bool haveAlarmsPermission;

  /// Indicates whether the ignore battery optimization permission is granted.
  final bool haveIgnoreOptimizationPermission;

  /// Indicates whether the Notification Access permission is granted.
  final bool haveNotificationAccessPermission;

  /// Indicates whether the accessibility service *process* is currently alive.
  /// This is separate from [haveAccessibilityPermission] — permission can be
  /// granted but the service process may be killed by the OEM.
  final bool isAccessibilityServiceActive;

  /// Indicates whether the accessibility service is in the "paused" state:
  /// permission is granted but the service process was found dead on the last
  /// keep-alive heartbeat. When true, UI should show a lightweight reconnect
  /// nudge instead of a full re-permission prompt.
  final bool isAccessibilityServicePaused;

  /// Indicates whether the Admin permission is granted.
  final bool haveAdminPermission;

  /// Indicates whether Device Admin permission was previously granted but has
  /// been silently revoked by the OEM. Set by the keep-alive heartbeat on the
  /// native side when it detects admin went from active to inactive.
  /// When true, the UI should show a lightweight one-tap re-enable nudge.
  final bool isDeviceAdminRevoked;

  const PermissionsModel({
    this.haveNotificationPermission = true,
    this.haveUsageAccessPermission = true,
    this.haveDndPermission = true,
    this.haveDisplayOverlayPermission = true,
    this.haveVpnPermission = true,
    this.haveAccessibilityPermission = true,
    this.haveAlarmsPermission = true,
    this.haveIgnoreOptimizationPermission = true,
    this.haveNotificationAccessPermission = true,
    this.isAccessibilityServiceActive = true,
    this.isAccessibilityServicePaused = false,
    this.haveAdminPermission = true,
    this.isDeviceAdminRevoked = false,
  });

  /// Whether every permission the app cannot function without is granted.
  ///
  /// This is the exact gate the splash screen uses to choose between the app
  /// and the permission flow, so it lives here as the single definition rather
  /// than being re-spelled in the splash, the permissions page, the quiz and
  /// the onboarding screen — where those copies had already drifted apart.
  bool get hasAllEssentialPermissions =>
      haveUsageAccessPermission &&
      haveDisplayOverlayPermission &&
      haveAlarmsPermission &&
      haveNotificationPermission &&
      haveAccessibilityPermission;

  /// True when tracking is actually working: permission granted, service
  /// process alive, and not flagged paused by the keep-alive heartbeat.
  ///
  /// Deliberately NOT part of [hasAllEssentialPermissions]: the splash screen
  /// uses that getter to choose between the app and the permission flow, and a
  /// service that is briefly unbound on resume would otherwise send an
  /// onboarded user back to the permission screen. Drive a banner / watchdog
  /// with this; never use it for routing.
  bool get isTrackingHealthy =>
      haveAccessibilityPermission &&
      isAccessibilityServiceActive &&
      !isAccessibilityServicePaused;

  /// Creates a copy of the `PermissionsModel` with potentially modified permissions.
  PermissionsModel copyWith({
    bool? haveNotificationPermission,
    bool? haveUsageAccessPermission,
    bool? haveDndPermission,
    bool? haveDisplayOverlayPermission,
    bool? haveVpnPermission,
    bool? haveAccessibilityPermission,
    bool? haveAlarmsPermission,
    bool? haveIgnoreOptimizationPermission,
    bool? haveNotificationAccessPermission,
    bool? isAccessibilityServiceActive,
    bool? isAccessibilityServicePaused,
    bool? haveAdminPermission,
    bool? isDeviceAdminRevoked,
  }) {
    return PermissionsModel(
      haveNotificationPermission:
          haveNotificationPermission ?? this.haveNotificationPermission,
      haveUsageAccessPermission:
          haveUsageAccessPermission ?? this.haveUsageAccessPermission,
      haveDndPermission: haveDndPermission ?? this.haveDndPermission,
      haveDisplayOverlayPermission:
          haveDisplayOverlayPermission ?? this.haveDisplayOverlayPermission,
      haveVpnPermission: haveVpnPermission ?? this.haveVpnPermission,
      haveAccessibilityPermission:
          haveAccessibilityPermission ?? this.haveAccessibilityPermission,
      haveAlarmsPermission: haveAlarmsPermission ?? this.haveAlarmsPermission,
      haveIgnoreOptimizationPermission: haveIgnoreOptimizationPermission ??
          this.haveIgnoreOptimizationPermission,
      haveNotificationAccessPermission:
          haveNotificationAccessPermission ??
              this.haveNotificationAccessPermission,
      isAccessibilityServiceActive:
          isAccessibilityServiceActive ?? this.isAccessibilityServiceActive,
      isAccessibilityServicePaused:
          isAccessibilityServicePaused ?? this.isAccessibilityServicePaused,
      haveAdminPermission: haveAdminPermission ?? this.haveAdminPermission,
      isDeviceAdminRevoked: isDeviceAdminRevoked ?? this.isDeviceAdminRevoked,
    );
  }

  /// Value equality.
  ///
  /// Without this, assigning a fresh-but-identical [PermissionsModel] in
  /// `PermissionNotifier` always looked like a *change* to Riverpod, so every
  /// listener fired on each permission re-read even when nothing had changed.
  /// That is what let the onboarding screen push a returning user onto the quiz
  /// page as a side effect of a plain refresh.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PermissionsModel &&
        other.haveNotificationPermission == haveNotificationPermission &&
        other.haveUsageAccessPermission == haveUsageAccessPermission &&
        other.haveDndPermission == haveDndPermission &&
        other.haveDisplayOverlayPermission == haveDisplayOverlayPermission &&
        other.haveVpnPermission == haveVpnPermission &&
        other.haveAccessibilityPermission == haveAccessibilityPermission &&
        other.haveAlarmsPermission == haveAlarmsPermission &&
        other.haveIgnoreOptimizationPermission ==
            haveIgnoreOptimizationPermission &&
        other.haveNotificationAccessPermission ==
            haveNotificationAccessPermission &&
        other.isAccessibilityServiceActive == isAccessibilityServiceActive &&
        other.isAccessibilityServicePaused == isAccessibilityServicePaused &&
        other.haveAdminPermission == haveAdminPermission &&
        other.isDeviceAdminRevoked == isDeviceAdminRevoked;
  }

  @override
  int get hashCode => Object.hashAll([
        haveNotificationPermission,
        haveUsageAccessPermission,
        haveDndPermission,
        haveDisplayOverlayPermission,
        haveVpnPermission,
        haveAccessibilityPermission,
        haveAlarmsPermission,
        haveIgnoreOptimizationPermission,
        haveNotificationAccessPermission,
        isAccessibilityServiceActive,
        isAccessibilityServicePaused,
        haveAdminPermission,
        isDeviceAdminRevoked,
      ]);
}
