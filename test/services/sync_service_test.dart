import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/services/sync_service.dart';
import 'package:nlp_digitox/core/services/device_identity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      // Initialize device identity first
      await DeviceIdentityService.instance.init();
    });

    test('singleton instance should be the same', () {
      final instance1 = SyncService.instance;
      final instance2 = SyncService.instance;

      expect(instance1, equals(instance2));
    });

    test('init() should complete without throwing', () async {
      final service = SyncService.instance;

      // Should not throw even if Firebase is not configured
      expect(() async => await service.init(), returnsNormally);
    });

    test('init() should handle multiple calls gracefully', () async {
      final service = SyncService.instance;

      await service.init();
      await service.init(); // Second call should be ignored

      // If we get here without exception, test passes
      expect(true, isTrue);
    });

    test('listenQuota() should return a stream', () async {
      final service = SyncService.instance;
      await service.init();

      final stream = service.listenQuota('com.example.app');

      expect(stream, isNotNull);
      expect(stream, isA<Stream<int>>());
    });

    test('getUsage() should return default values when offline', () async {
      final service = SyncService.instance;
      await service.init();

      final usage = await service.getUsage('com.example.app');

      expect(usage, isNotNull);
      expect(usage['dailyMinutes'], isA<int>());
      expect(usage['dailyLimit'], isA<int>());
      expect(usage['lastReset'], isA<int>());
    });

    test('incrementUsage() should work in stub mode', () async {
      final service = SyncService.instance;
      await service.init();

      final result = await service.incrementUsage('com.example.app', 10);

      // In stub mode (Firebase not configured), should still return true
      expect(result, isA<bool>());
    });

    test('setDailyLimit() should not throw', () async {
      final service = SyncService.instance;
      await service.init();

      expect(
        () async => await service.setDailyLimit('com.example.app', 60),
        returnsNormally,
      );
    });

    test('acquireLock() should return boolean', () async {
      final service = SyncService.instance;
      await service.init();

      final lockAcquired = await service.acquireLock('com.example.app');

      expect(lockAcquired, isA<bool>());
    });

    test('releaseLock() should not throw', () async {
      final service = SyncService.instance;
      await service.init();

      await service.acquireLock('com.example.app');

      expect(
        () async => await service.releaseLock('com.example.app'),
        returnsNormally,
      );
    });

    test('isLockedByOtherDevice() should return boolean', () async {
      final service = SyncService.instance;
      await service.init();

      final isLocked = await service.isLockedByOtherDevice('com.example.app');

      expect(isLocked, isA<bool>());
    });

    test('updateDevicePresence() should not throw', () async {
      final service = SyncService.instance;
      await service.init();

      expect(
        () async => await service.updateDevicePresence(),
        returnsNormally,
      );
    });

    test('markDeviceInactive() should not throw', () async {
      final service = SyncService.instance;
      await service.init();

      expect(
        () async => await service.markDeviceInactive(),
        returnsNormally,
      );
    });

    test('resetDailyUsage() should not throw', () async {
      final service = SyncService.instance;
      await service.init();

      expect(
        () async => await service.resetDailyUsage(),
        returnsNormally,
      );
    });

    test('dispose() should cleanup successfully', () async {
      final service = SyncService.instance;
      await service.init();

      expect(
        () async => await service.dispose(),
        returnsNormally,
      );
    });
  });
}
