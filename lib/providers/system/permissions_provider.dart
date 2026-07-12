import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/models/permissions_model.dart';

/// A Riverpod state notifier provider that manages and requests various permissions required by the app.
final permissionProvider =
    StateNotifierProvider<PermissionNotifier, PermissionsModel>(
  (ref) => PermissionNotifier(),
);

/// This class manages the state of app permissions and handles permission requests.
/// Features:
/// - Robust lifecycle handling with WidgetsBindingObserver
/// - Permission re-check on app resume
/// - Comprehensive error handling with fallback values
/// - Concurrent permission fetching support
class PermissionNotifier extends StateNotifier<PermissionsModel>
    with WidgetsBindingObserver {
  PermissionNotifier() : super(const PermissionsModel()) {
    WidgetsBinding.instance.addObserver(this);
    _initializePermissions();
  }

  /// Flag to track if initialization is complete
  bool _isInitialized = false;

  /// Initialize permissions on startup
  Future<void> _initializePermissions() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await fetchPermissionsStatus();
  }

  /// Create [PermissionsModel] and initializes with permission state by fetching initial permission status.
  /// Handles errors gracefully with safe defaults.
  Future<PermissionsModel> fetchPermissionsStatus() async {
    try {
      final cache = PermissionsModel(
        haveNotificationPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskNotificationPermission(),
          'notification',
        ),
        haveUsageAccessPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskUsageAccessPermission(),
          'usage access',
        ),
        haveDisplayOverlayPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskDisplayOverlayPermission(),
          'display overlay',
        ),
        haveDndPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskDndPermission(),
          'DND',
        ),
        haveAccessibilityPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskAccessibilityPermission(),
          'accessibility',
        ),
        haveVpnPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskVpnPermission(),
          'VPN',
        ),
        haveAlarmsPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskExactAlarmPermission(),
          'exact alarm',
        ),
        haveIgnoreOptimizationPermission: await _safeGetPermission(
          () => MethodChannelService.instance
              .getAndAskIgnoreBatteryOptimizationPermission(),
          'ignore optimization',
        ),
        haveAdminPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskAdminPermission(),
          'admin',
        ),
        haveNotificationAccessPermission: await _safeGetPermission(
          () =>
              MethodChannelService.instance.getAndAskNotificationAccessPermission(),
          'notification access',
        ),
        isAccessibilityServiceActive: await _safeGetPermission(
          () => MethodChannelService.instance.isAccessibilityServiceActive(),
          'accessibility service active',
        ),
        isAccessibilityServicePaused: await _safeGetPermission(
          () => MethodChannelService.instance.isAccessibilityServicePaused(),
          'accessibility service paused',
        ),
        isDeviceAdminRevoked: await _safeGetPermission(
          () => MethodChannelService.instance.isDeviceAdminRevoked(),
          'device admin revoked',
        ),
      );

      state = cache;
      return cache;
    } catch (e) {
      debugPrint('PermissionNotifier: Error fetching permissions: $e');
      return state;
    }
  }

  /// Safely execute a permission check with error handling
  Future<bool> _safeGetPermission(
    Future<bool> Function() permissionCall,
    String permissionName,
  ) async {
    try {
      return await permissionCall();
    } catch (e) {
      debugPrint('PermissionNotifier: Error checking $permissionName permission: $e');
      return false;
    }
  }

  /// Removes the lifecycle observer when the widget is disposed.
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Handles permission updates when the app resumes from background and when window focus changes.
  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) async {
    if (appState != AppLifecycleState.resumed) return;
    await recheckAllPermissions();
  }

  /// Re-check ALL permissions when app resumes - not just the last requested one.
  Future<void> recheckAllPermissions() async {
    try {
      state = PermissionsModel(
        haveNotificationPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskNotificationPermission(),
          'notification',
        ),
        haveUsageAccessPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskUsageAccessPermission(),
          'usage access',
        ),
        haveDisplayOverlayPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskDisplayOverlayPermission(),
          'display overlay',
        ),
        haveDndPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskDndPermission(),
          'DND',
        ),
        haveAccessibilityPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskAccessibilityPermission(),
          'accessibility',
        ),
        haveVpnPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskVpnPermission(),
          'VPN',
        ),
        haveAlarmsPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskExactAlarmPermission(),
          'exact alarm',
        ),
        haveIgnoreOptimizationPermission: await _safeGetPermission(
          () => MethodChannelService.instance
              .getAndAskIgnoreBatteryOptimizationPermission(),
          'ignore optimization',
        ),
        haveAdminPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskAdminPermission(),
          'admin',
        ),
        haveNotificationAccessPermission: await _safeGetPermission(
          () =>
              MethodChannelService.instance.getAndAskNotificationAccessPermission(),
          'notification access',
        ),
        isAccessibilityServiceActive: await _safeGetPermission(
          () => MethodChannelService.instance.isAccessibilityServiceActive(),
          'accessibility service active',
        ),
        isAccessibilityServicePaused: await _safeGetPermission(
          () => MethodChannelService.instance.isAccessibilityServicePaused(),
          'accessibility service paused',
        ),
        isDeviceAdminRevoked: await _safeGetPermission(
          () => MethodChannelService.instance.isDeviceAdminRevoked(),
          'device admin revoked',
        ),
      );

      debugPrint('PermissionNotifier: All permissions re-checked on app resume');
    } catch (e) {
      debugPrint('PermissionNotifier: Error rechecking all permissions on resume: $e');
    }
  }

  /// Request all critical permissions at once
  Future<void> requestAllCriticalPermissions() async {
    try {
      await askNotificationPermission();
      await Future.delayed(500.ms);

      await askUsageAccessPermission();
      await Future.delayed(500.ms);

      await askAccessibilityPermission();
      await Future.delayed(500.ms);

      await askDisplayOverlayPermission();
      await Future.delayed(500.ms);

      await askAdminPermission();
      await Future.delayed(500.ms);

      await fetchPermissionsStatus();
      debugPrint('PermissionNotifier: All critical permissions requested');
    } catch (e) {
      debugPrint('PermissionNotifier: Error requesting critical permissions: $e');
    }
  }

  /// Requests the notification permission and updates the internal state.
  Future<void> askNotificationPermission() async {
    await MethodChannelService.instance
        .getAndAskNotificationPermission(askPermissionToo: true);
  }

  /// Requests the usage access permission and updates the internal state.
  Future<void> askUsageAccessPermission() async {
    await MethodChannelService.instance
        .getAndAskUsageAccessPermission(askPermissionToo: true);
  }

  /// Requests the display overlay permission and updates the internal state.
  Future<void> askDisplayOverlayPermission() async {
    await MethodChannelService.instance
        .getAndAskDisplayOverlayPermission(askPermissionToo: true);
  }

  /// Requests the accessibility permission and updates the internal state.
  Future<void> askAccessibilityPermission() async {
    await MethodChannelService.instance
        .getAndAskAccessibilityPermission(askPermissionToo: true);
    // Clear the paused flag since we're re-granting
    await MethodChannelService.instance.clearAccessibilityServicePausedFlag();
  }

  /// Requests the VPN permission and updates the internal state.
  Future<void> askVpnPermission() async {
    await MethodChannelService.instance
        .getAndAskVpnPermission(askPermissionToo: true);
  }

  /// Requests the Do Not Disturb permission and updates the internal state.
  Future<void> askDndPermission() async {
    await MethodChannelService.instance
        .getAndAskDndPermission(askPermissionToo: true);
  }

  /// Requests the Set Exact Alarm permission and updates the internal state.
  Future<void> askExactAlarmPermission() async {
    await MethodChannelService.instance
        .getAndAskExactAlarmPermission(askPermissionToo: true);
  }

  /// Requests the Ignore Battery Optimization permission and updates the internal state.
  Future<void> askIgnoreBatteryOptimizationPermission() async {
    await MethodChannelService.instance
        .getAndAskIgnoreBatteryOptimizationPermission(askPermissionToo: true);
  }

  /// Requests the Admin permission and updates the internal state.
  Future<void> askAdminPermission() async {
    await MethodChannelService.instance
        .getAndAskAdminPermission(askPermissionToo: true);
  }

  /// Request the device to disable admin if already enabled
  Future<void> disableAdminPermission() async {
    try {
      await MethodChannelService.instance.disableDeviceAdmin();
      await Future.delayed(500.ms);
      state = state.copyWith(
        haveAdminPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskAdminPermission(),
          'admin',
        ),
      );
    } catch (e) {
      debugPrint('PermissionNotifier: Error disabling admin permission: $e');
    }
  }

  /// Requests the notification access permission and updates the internal state.
  Future<void> askNotificationAccessPermission() async {
    await MethodChannelService.instance
        .getAndAskNotificationAccessPermission(askPermissionToo: true);
  }

  /// Clears the "paused" flag and updates state to reflect the service is active.
  /// Called from the UI when user taps "resume" or the reconnect nudge.
  Future<void> clearAccessibilityServicePausedFlag() async {
    try {
      await MethodChannelService.instance.clearAccessibilityServicePausedFlag();
      state = state.copyWith(
        isAccessibilityServicePaused: false,
        isAccessibilityServiceActive: await _safeGetPermission(
          () => MethodChannelService.instance.isAccessibilityServiceActive(),
          'accessibility service active',
        ),
      );
    } catch (e) {
      debugPrint('PermissionNotifier: Error clearing paused flag: $e');
    }
  }

  /// Clears the Device Admin revoked flag and updates state.
  /// Called from the UI when user taps the re-enable nudge.
  Future<void> clearDeviceAdminRevokedFlag() async {
    try {
      await MethodChannelService.instance.clearDeviceAdminRevokedFlag();
      state = state.copyWith(
        isDeviceAdminRevoked: false,
        haveAdminPermission: await _safeGetPermission(
          () => MethodChannelService.instance.getAndAskAdminPermission(),
          'admin',
        ),
      );
    } catch (e) {
      debugPrint('PermissionNotifier: Error clearing admin revoked flag: $e');
    }
  }
}
