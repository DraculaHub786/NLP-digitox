// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/enums/permission_type.dart';
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

  /// Tracks the last requested permission type for handling lifecycle changes.
  PermissionType _askedPermission = PermissionType.none;

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
      );

      state = cache;
      return cache;
    } catch (e) {
      debugPrint('PermissionNotifier: Error fetching permissions: $e');
      // Return current state with safe defaults
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
      return false; // Safe default: assume permission denied if error
    }
  }

  /// Removes the lifecycle observer when the widget is disposed.
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Handles permission updates when the app resumes from background and when window focus changes.
  /// This ensures permissions are re-checked whenever the app returns to foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) async {
    if (appState != AppLifecycleState.resumed) return;

    // Re-check specific permission if one was just requested
    await _recheckPermissionAfterResume();
  }

  /// Re-check the specific permission that was last requested when app resumes
  Future<void> _recheckPermissionAfterResume() async {
    try {
      state = switch (_askedPermission) {
        PermissionType.none => state,
        PermissionType.notification => state.copyWith(
            haveNotificationPermission: await _safeGetPermission(
              () => MethodChannelService.instance
                  .getAndAskNotificationPermission(),
              'notification',
            ),
          ),
        PermissionType.usageAccess => state.copyWith(
            haveUsageAccessPermission: await _safeGetPermission(
              () => MethodChannelService.instance
                  .getAndAskUsageAccessPermission(),
              'usage access',
            ),
          ),
        PermissionType.displayOverlay => state.copyWith(
            haveDisplayOverlayPermission: await _safeGetPermission(
              () => MethodChannelService.instance
                  .getAndAskDisplayOverlayPermission(),
              'display overlay',
            ),
          ),
        PermissionType.doNotDisturb => state.copyWith(
            haveDndPermission: await _safeGetPermission(
              () => MethodChannelService.instance.getAndAskDndPermission(),
              'DND',
            ),
          ),
        PermissionType.accessibility => state.copyWith(
            haveAccessibilityPermission: await _safeGetPermission(
              () => MethodChannelService.instance
                  .getAndAskAccessibilityPermission(),
              'accessibility',
            ),
          ),
        PermissionType.vpn => state.copyWith(
            haveVpnPermission: await _safeGetPermission(
              () => MethodChannelService.instance.getAndAskVpnPermission(),
              'VPN',
            ),
          ),
        PermissionType.exactAlarm => state.copyWith(
            haveAlarmsPermission: await _safeGetPermission(
              () => MethodChannelService.instance
                  .getAndAskExactAlarmPermission(),
              'exact alarm',
            ),
          ),
        PermissionType.ignoreOptimization => state.copyWith(
            haveIgnoreOptimizationPermission: await _safeGetPermission(
              () => MethodChannelService.instance
                  .getAndAskIgnoreBatteryOptimizationPermission(),
              'ignore optimization',
            ),
            haveAlarmsPermission: await _safeGetPermission(
              () => MethodChannelService.instance
                  .getAndAskExactAlarmPermission(),
              'exact alarm',
            ),
          ),
        PermissionType.admin => state.copyWith(
            haveAdminPermission: await _safeGetPermission(
              () => MethodChannelService.instance.getAndAskAdminPermission(),
              'admin',
            ),
          ),
        PermissionType.notificationAccess => state.copyWith(
            haveNotificationAccessPermission: await _safeGetPermission(
              () => MethodChannelService.instance
                  .getAndAskNotificationAccessPermission(),
              'notification access',
            ),
          ),
      };

      _askedPermission = PermissionType.none;
    } catch (e) {
      debugPrint('PermissionNotifier: Error rechecking permissions on resume: $e');
      _askedPermission = PermissionType.none;
    }
  }

  /// Request all critical permissions at once
  /// This should be called during onboarding to ensure all necessary permissions are granted
  Future<void> requestAllCriticalPermissions() async {
    try {
      // Request critical permissions in sequence for better UX
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

      // Re-fetch all permissions after requests
      await fetchPermissionsStatus();
      debugPrint('PermissionNotifier: All critical permissions requested');
    } catch (e) {
      debugPrint('PermissionNotifier: Error requesting critical permissions: $e');
    }
  }

  /// Internal helper to request permission and track state
  Future<void> _requestPermissionInternal(
    PermissionType permissionType,
    Future<void> Function() requestFunc,
  ) async {
    try {
      _askedPermission = permissionType;
      await requestFunc();
    } catch (e) {
      debugPrint('PermissionNotifier: Error requesting permission: $e');
      _askedPermission = PermissionType.none;
    }
  }

  /// Requests the notification permission and updates the internal state.
  Future<void> askNotificationPermission() async {
    await _requestPermissionInternal(
      PermissionType.notification,
      () async => await MethodChannelService.instance
          .getAndAskNotificationPermission(askPermissionToo: true),
    );
  }

  /// Requests the usage access permission and updates the internal state.
  Future<void> askUsageAccessPermission() async {
    await _requestPermissionInternal(
      PermissionType.usageAccess,
      () async => await MethodChannelService.instance
          .getAndAskUsageAccessPermission(askPermissionToo: true),
    );
  }

  /// Requests the display overlay permission and updates the internal state.
  Future<void> askDisplayOverlayPermission() async {
    await _requestPermissionInternal(
      PermissionType.displayOverlay,
      () async => await MethodChannelService.instance
          .getAndAskDisplayOverlayPermission(askPermissionToo: true),
    );
  }

  /// Requests the accessibility permission and updates the internal state.
  /// This permission is required for app overlay blocking features.
  Future<void> askAccessibilityPermission() async {
    await _requestPermissionInternal(
      PermissionType.accessibility,
      () async => await MethodChannelService.instance
          .getAndAskAccessibilityPermission(askPermissionToo: true),
    );
  }

  /// Requests the VPN permission and updates the internal state.
  Future<void> askVpnPermission() async {
    await _requestPermissionInternal(
      PermissionType.vpn,
      () async => await MethodChannelService.instance
          .getAndAskVpnPermission(askPermissionToo: true),
    );
  }

  /// Requests the Do Not Disturb permission and updates the internal state.
  Future<void> askDndPermission() async {
    await _requestPermissionInternal(
      PermissionType.doNotDisturb,
      () async => await MethodChannelService.instance
          .getAndAskDndPermission(askPermissionToo: true),
    );
  }

  /// Requests the Set Exact Alarm permission and updates the internal state.
  Future<void> askExactAlarmPermission() async {
    await _requestPermissionInternal(
      PermissionType.exactAlarm,
      () async => await MethodChannelService.instance
          .getAndAskExactAlarmPermission(askPermissionToo: true),
    );
  }

  /// Requests the Ignore Battery Optimization permission and updates the internal state.
  Future<void> askIgnoreBatteryOptimizationPermission() async {
    await _requestPermissionInternal(
      PermissionType.ignoreOptimization,
      () async => await MethodChannelService.instance
          .getAndAskIgnoreBatteryOptimizationPermission(askPermissionToo: true),
    );
  }

  /// Requests the Admin permission and updates the internal state.
  /// This permission is required for Device Policy Manager features.
  Future<void> askAdminPermission() async {
    await _requestPermissionInternal(
      PermissionType.admin,
      () async => await MethodChannelService.instance
          .getAndAskAdminPermission(askPermissionToo: true),
    );
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
    await _requestPermissionInternal(
      PermissionType.notificationAccess,
      () async => await MethodChannelService.instance
          .getAndAskNotificationAccessPermission(askPermissionToo: true),
    );
  }
}
