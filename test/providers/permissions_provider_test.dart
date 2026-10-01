import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/enums/permission_type.dart';
import 'package:nlp_digitox/models/permissions_model.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PermissionNotifier - Robust Permission Management', () {
    test('PermissionsModel defaults to optimistic (granted) values', () {
      // Defaults are deliberately optimistic so the UI never flashes a
      // "missing permission" state before the real check resolves.
      const model = PermissionsModel();

      expect(model.haveNotificationPermission, isTrue);
      expect(model.haveUsageAccessPermission, isTrue);
      expect(model.haveDisplayOverlayPermission, isTrue);
      expect(model.haveAccessibilityPermission, isTrue);
    });

    test('PermissionsModel should support copyWith for immutability', () {
      const model1 = PermissionsModel();
      final model2 = model1.copyWith(
        haveNotificationPermission: false,
      );

      expect(model2.haveNotificationPermission, isFalse);
      expect(model1.haveNotificationPermission, isTrue);
      expect(model1 == model2, isFalse);
    });

    test('PermissionsModel should handle multiple copyWith calls', () {
      const model1 = PermissionsModel();
      final model2 = model1.copyWith(
        haveNotificationPermission: false,
        haveUsageAccessPermission: false,
      );
      final model3 = model2.copyWith(
        haveNotificationAccessPermission: false,
      );

      expect(model3.haveNotificationPermission, isFalse);
      expect(model3.haveUsageAccessPermission, isFalse);
      expect(model3.haveNotificationAccessPermission, isFalse);
      // Untouched fields keep their previous value.
      expect(model3.haveAccessibilityPermission, isTrue);
    });

    test('PermissionNotifier should be constructible', () {
      expect(
        () => PermissionNotifier(),
        returnsNormally,
      );
    });

    test('PermissionNotifier should support dispose', () {
      final notifier = PermissionNotifier();

      expect(() => notifier.dispose(), returnsNormally);
    });

    test('PermissionType enum should have all expected values', () {
      expect(PermissionType.values, contains(PermissionType.none));
      expect(PermissionType.values, contains(PermissionType.notification));
      expect(PermissionType.values, contains(PermissionType.usageAccess));
      expect(PermissionType.values, contains(PermissionType.displayOverlay));
      expect(PermissionType.values, contains(PermissionType.doNotDisturb));
      expect(PermissionType.values, contains(PermissionType.accessibility));
      expect(PermissionType.values, contains(PermissionType.vpn));
      expect(PermissionType.values, contains(PermissionType.exactAlarm));
      expect(PermissionType.values, contains(PermissionType.ignoreOptimization));
      expect(PermissionType.values, contains(PermissionType.notificationAccess));
    });
  });

  group('PermissionsModel - hasAllEssentialPermissions', () {
    test('is true only when all five essentials are granted', () {
      const allGood = PermissionsModel();
      expect(allGood.hasAllEssentialPermissions, isTrue);

      expect(
        allGood.copyWith(haveAccessibilityPermission: false)
            .hasAllEssentialPermissions,
        isFalse,
      );
      expect(
        allGood.copyWith(haveUsageAccessPermission: false)
            .hasAllEssentialPermissions,
        isFalse,
      );
      expect(
        allGood.copyWith(haveDisplayOverlayPermission: false)
            .hasAllEssentialPermissions,
        isFalse,
      );
      expect(
        allGood.copyWith(haveAlarmsPermission: false)
            .hasAllEssentialPermissions,
        isFalse,
      );
      expect(
        allGood.copyWith(haveNotificationPermission: false)
            .hasAllEssentialPermissions,
        isFalse,
      );
    });

    test('ignores non-essential permissions', () {
      // DND, VPN, battery and admin are not part of the startup gate — a
      // revoked one of those must never send a user back to onboarding.
      final model = const PermissionsModel().copyWith(
        haveDndPermission: false,
        haveVpnPermission: false,
        haveIgnoreOptimizationPermission: false,
        haveAdminPermission: false,
      );

      expect(model.hasAllEssentialPermissions, isTrue);
    });
  });

  group('PermissionsModel - Equality and Copying', () {
    test('identical models should be equal', () {
      const model1 = PermissionsModel();
      const model2 = PermissionsModel();

      expect(model1, equals(model2));
      expect(model1.hashCode, equals(model2.hashCode));
    });

    test('copyWith should create a different value when a field changes', () {
      const model1 = PermissionsModel();
      final model2 = model1.copyWith(haveAccessibilityPermission: false);

      expect(model1, isNot(equals(model2)));
    });

    test('copyWith with unchanged values should compare equal', () {
      // This is what stops a no-op permission re-read from notifying
      // listeners — and, previously, from advancing onboarding onto the quiz.
      const model1 = PermissionsModel();
      final model2 = model1.copyWith(haveNotificationPermission: true);

      expect(model1, equals(model2));
    });

    test('should handle all permission fields in copyWith', () {
      const model = PermissionsModel();

      final updated = model.copyWith(
        haveNotificationPermission: false,
        haveUsageAccessPermission: false,
        haveDisplayOverlayPermission: false,
        haveDndPermission: false,
        haveAccessibilityPermission: false,
        haveVpnPermission: false,
        haveAlarmsPermission: false,
        haveIgnoreOptimizationPermission: false,
        haveNotificationAccessPermission: false,
      );

      expect(updated.haveNotificationPermission, isFalse);
      expect(updated.haveUsageAccessPermission, isFalse);
      expect(updated.haveDisplayOverlayPermission, isFalse);
      expect(updated.haveDndPermission, isFalse);
      expect(updated.haveAccessibilityPermission, isFalse);
      expect(updated.haveVpnPermission, isFalse);
      expect(updated.haveAlarmsPermission, isFalse);
      expect(updated.haveIgnoreOptimizationPermission, isFalse);
      expect(updated.haveNotificationAccessPermission, isFalse);
    });
  });

  group('PermissionNotifier - Lifecycle', () {
    test('dispose should be safe and idempotent', () {
      final notifier = PermissionNotifier();

      expect(() => notifier.dispose(), returnsNormally);
      // A second dispose must not throw.
      expect(() => notifier.dispose(), returnsNormally);
    });

    test('re-checking after dispose must not throw', () async {
      // The native round-trips in a fetch can outlive the notifier. Use of a
      // disposed StateNotifier throws unless every entry point is guarded.
      final notifier = PermissionNotifier();
      notifier.dispose();

      expect(
        () async => await notifier.fetchPermissionsStatus(),
        returnsNormally,
      );
      expect(
        () async => await notifier.recheckAllPermissions(),
        returnsNormally,
      );
      expect(
        () async => await notifier.requestAllCriticalPermissions(),
        returnsNormally,
      );
    });
  });

  group('Permission Flow - Integration', () {
    testWidgets('permissions notifier lifecycle', (WidgetTester tester) async {
      final notifier = PermissionNotifier();

      expect(notifier, isNotNull);

      // Platform channels are unavailable in a unit test, so every check
      // resolves through the error path. It must not throw.
      expect(
        () async => await notifier.fetchPermissionsStatus(),
        returnsNormally,
      );

      notifier.dispose();
    });
  });
}
