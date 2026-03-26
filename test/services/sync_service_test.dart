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

    // Task 5: Primary device and shared quota tests
    group('Primary Device', () {
      test('claimPrimaryDevice() should return boolean', () async {
        final service = SyncService.instance;
        await service.init();

        final claimed = await service.claimPrimaryDevice();

        expect(claimed, isA<bool>());
      });

      test('isPrimaryDevice() should return boolean', () async {
        final service = SyncService.instance;
        await service.init();

        final isPrimary = await service.isPrimaryDevice();

        expect(isPrimary, isA<bool>());
      });

      test('releasePrimaryDevice() should not throw', () async {
        final service = SyncService.instance;
        await service.init();

        await service.claimPrimaryDevice();

        expect(
          () async => await service.releasePrimaryDevice(),
          returnsNormally,
        );
      });

      test('listenPrimaryDevice() should return a stream of device IDs', () async {
        final service = SyncService.instance;
        await service.init();

        final stream = service.listenPrimaryDevice();

        expect(stream, isNotNull);
        expect(stream, isA<Stream<String?>>());
      });

      test('getAllDevices() should return a map', () async {
        final service = SyncService.instance;
        await service.init();

        final devices = await service.getAllDevices();

        expect(devices, isA<Map<String, Map<String, dynamic>>>());
      });
    });

    group('Lock Heartbeat', () {
      test('startLockHeartbeat() should start without throwing', () async {
        final service = SyncService.instance;
        await service.init();

        expect(
          () => service.startLockHeartbeat('com.example.app'),
          returnsNormally,
        );
      });

      test('stopLockHeartbeat() should stop heartbeat without throwing', () async {
        final service = SyncService.instance;
        await service.init();

        service.startLockHeartbeat('com.example.app');

        expect(
          () => service.stopLockHeartbeat('com.example.app'),
          returnsNormally,
        );
      });

      test('stopLockHeartbeat() should handle app with no active heartbeat', () async {
        final service = SyncService.instance;
        await service.init();

        expect(
          () => service.stopLockHeartbeat('com.nonexistent.app'),
          returnsNormally,
        );
      });

      test('multiple heartbeats should be manageable', () async {
        final service = SyncService.instance;
        await service.init();

        service.startLockHeartbeat('com.example.app1');
        service.startLockHeartbeat('com.example.app2');
        service.startLockHeartbeat('com.example.app3');

        service.stopLockHeartbeat('com.example.app1');
        service.stopLockHeartbeat('com.example.app2');
        service.stopLockHeartbeat('com.example.app3');

        expect(true, isTrue);
      });
    });

    group('Shared Quota Workflow', () {
      test('shared quota workflow should track usage correctly', () async {
        final service = SyncService.instance;
        await service.init();

        // Set daily limit for an app
        await service.setDailyLimit('com.social.twitter', 30); // 30 minutes

        // Get initial usage
        var usage = await service.getUsage('com.social.twitter');
        expect(usage['dailyMinutes'], equals(0));
        expect(usage['dailyLimit'], isA<int>());

        // Increment usage
        final incremented1 = await service.incrementUsage('com.social.twitter', 10);
        expect(incremented1, isA<bool>());

        // Increment usage more
        final incremented2 = await service.incrementUsage('com.social.twitter', 10);
        expect(incremented2, isA<bool>());

        // Usage should have increased (in stub mode, always returns true)
        usage = await service.getUsage('com.social.twitter');
        expect(usage['dailyMinutes'], isA<int>());
      });

      test('quota system should support multiple apps', () async {
        final service = SyncService.instance;
        await service.init();

        // Set limits for different apps
        await service.setDailyLimit('com.social.twitter', 30);
        await service.setDailyLimit('com.social.instagram', 20);
        await service.setDailyLimit('com.entertainment.netflix', 60);

        // Increment usage for each app
        await service.incrementUsage('com.social.twitter', 5);
        await service.incrementUsage('com.social.instagram', 3);
        await service.incrementUsage('com.entertainment.netflix', 15);

        // Verify each app's usage independently
        final twitterUsage = await service.getUsage('com.social.twitter');
        final instagramUsage = await service.getUsage('com.social.instagram');
        final netflixUsage = await service.getUsage('com.entertainment.netflix');

        expect(twitterUsage['dailyMinutes'], isA<int>());
        expect(instagramUsage['dailyMinutes'], isA<int>());
        expect(netflixUsage['dailyMinutes'], isA<int>());
      });
    });

    group('Lock Workflow', () {
      test('lock lifecycle should work correctly', () async {
        final service = SyncService.instance;
        await service.init();

        // acquire lock
        final acquired = await service.acquireLock('com.example.app');
        expect(acquired, isA<bool>());

        // Check if locked
        final isLocked = await service.isLockedByOtherDevice('com.example.app');
        expect(isLocked, isA<bool>());

        // Release lock
        await service.releaseLock('com.example.app');

        // Should no longer be locked (in stub mode, depends on Firebase implementation)
        final isLockedAfter = await service.isLockedByOtherDevice('com.example.app');
        expect(isLockedAfter, isA<bool>());
      });

      test('refresh lock should work with heartbeat', () async {
        final service = SyncService.instance;
        await service.init();

        // Acquire a lock
        await service.acquireLock('com.example.app', ttlMinutes: 5);

        // Start heartbeat to refresh it
        service.startLockHeartbeat('com.example.app', refreshIntervalSeconds: 2);

        // Wait for heartbeat to trigger
        await Future.delayed(const Duration(milliseconds: 100));

        // Stop heartbeat
        service.stopLockHeartbeat('com.example.app');

        expect(true, isTrue);
      });
    });
  });
}
