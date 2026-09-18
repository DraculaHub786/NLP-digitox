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
  });

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
    );
  }
}
