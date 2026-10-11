import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/models/permissions_model.dart';

/// Guards the splash screen's routing gate.
///
/// [PermissionsModel.hasAllEssentialPermissions] is what the splash uses to
/// choose between the app and the permission flow. A native probe that *threw*
/// (a MethodChannel round trip racing an engine teardown, a null activity handle
/// on a cold start) used to be swallowed into `false`, which is indistinguishable
/// from a genuinely revoked permission — so an already-permissioned user was sent
/// back through the permission screen on every cold start. These tests pin the
/// three cases that matter.
void main() {
  /// Every essential permission genuinely granted.
  const allGranted = PermissionsModel();

  /// One essential permission genuinely revoked.
  const accessibilityRevoked = PermissionsModel(
    haveAccessibilityPermission: false,
  );

  group('hasAllEssentialPermissions', () {
    test('is true when every essential permission is granted', () {
      expect(allGranted.hasAllEssentialPermissions, isTrue);
    });

    test('is false when an essential permission is genuinely revoked', () {
      expect(accessibilityRevoked.hasAllEssentialPermissions, isFalse);
    });

    test('is true when the probe failed, because the state is unknown', () {
      // The flags below read as revoked, but the failed probe means we never
      // got a trustworthy answer — enforcing them would be the bug.
      const unknownBecauseProbeFailed = PermissionsModel(
        haveAccessibilityPermission: false,
        haveUsageAccessPermission: false,
        permissionFetchFailed: true,
      );

      expect(unknownBecauseProbeFailed.hasAllEssentialPermissions, isTrue);
    });

    test('does not include accessory permissions', () {
      // Admin / VPN / overlay-liveness are useful but must never gate routing,
      // or a briefly-unbound service would send an onboarded user back to the
      // permission screen.
      const accessoryOnly = PermissionsModel(
        haveAdminPermission: false,
        haveVpnPermission: false,
        haveDndPermission: false,
        haveNotificationAccessPermission: false,
        haveIgnoreOptimizationPermission: false,
        isAccessibilityServiceActive: false,
        isAccessibilityServicePaused: true,
      );

      expect(accessoryOnly.hasAllEssentialPermissions, isTrue);
    });
  });

  group('hasCorePermissions', () {
    test('is true when all four core permissions are granted', () {
      expect(allGranted.hasCorePermissions, isTrue);
    });

    test('is false when any one core permission is revoked', () {
      const revoked = [
        PermissionsModel(haveUsageAccessPermission: false),
        PermissionsModel(haveDisplayOverlayPermission: false),
        PermissionsModel(haveAlarmsPermission: false),
        PermissionsModel(haveNotificationPermission: false),
      ];

      for (final model in revoked) {
        expect(
          model.hasCorePermissions,
          isFalse,
          reason: 'every core permission must be able to close the gate',
        );
      }
    });

    test('ignores Accessibility, which the OS clears on a force-stop', () {
      // This is the whole point of splitting the gate: an onboarded user whose
      // Accessibility grant was wiped by a force-stop must still reach the app.
      expect(accessibilityRevoked.haveAccessibilityPermission, isFalse);
      expect(accessibilityRevoked.hasCorePermissions, isTrue);
      expect(accessibilityRevoked.hasAllEssentialPermissions, isFalse);
    });

    test('is true when the probe failed, because the state is unknown', () {
      expect(
        const PermissionsModel(
          haveUsageAccessPermission: false,
          permissionFetchFailed: true,
        ).hasCorePermissions,
        isTrue,
      );
    });

    test('hasAllEssentialPermissions is core plus Accessibility', () {
      expect(accessibilityRevoked.hasAllEssentialPermissions, isFalse);
      expect(allGranted.hasAllEssentialPermissions, isTrue);
    });
  });

  group('permissionFetchFailed', () {
    test('defaults to false', () {
      expect(allGranted.permissionFetchFailed, isFalse);
    });

    test('survives copyWith and participates in equality', () {
      final failed = allGranted.copyWith(permissionFetchFailed: true);

      expect(failed.permissionFetchFailed, isTrue);
      expect(failed, isNot(equals(allGranted)));

      // A copy that does not name the field must preserve it, since
      // `clearAccessibilityServicePausedFlag` and friends use copyWith.
      final carriedOver = failed.copyWith(haveDndPermission: false);
      expect(carriedOver.permissionFetchFailed, isTrue);

      // And a later clean read must be able to clear it.
      expect(
        failed.copyWith(permissionFetchFailed: false),
        equals(allGranted),
      );
    });
  });
}
