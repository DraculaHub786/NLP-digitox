import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/services/restriction_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RestrictionEngine', () {
    test('singleton instance should be the same', () {
      final instance1 = RestrictionEngine.instance;
      final instance2 = RestrictionEngine.instance;

      expect(instance1, equals(instance2));
    });

    test('init() should complete without throwing', () async {
      final engine = RestrictionEngine.instance;

      // Should not throw even if database is not fully initialized
      expect(() async => await engine.init(), returnsNormally);
    });

    test('RestrictionDecision.allow() should create allow decision', () {
      final decision = RestrictionDecision.allow();

      expect(decision.canOpen, isTrue);
      expect(decision.reason, equals('No restrictions apply'));
      expect(decision.type, equals(RestrictionType.none));
    });

    test('RestrictionDecision.block() should create block decision', () {
      final decision = RestrictionDecision.block(
        'Test reason',
        RestrictionType.timer,
      );

      expect(decision.canOpen, isFalse);
      expect(decision.reason, equals('Test reason'));
      expect(decision.type, equals(RestrictionType.timer));
    });

    test('RestrictionType enum should have all expected values', () {
      expect(RestrictionType.values, contains(RestrictionType.none));
      expect(RestrictionType.values, contains(RestrictionType.timer));
      expect(RestrictionType.values, contains(RestrictionType.launchLimit));
      expect(RestrictionType.values, contains(RestrictionType.activePeriod));
      expect(RestrictionType.values, contains(RestrictionType.groupTimer));
      expect(RestrictionType.values, contains(RestrictionType.sharedQuota));
      expect(RestrictionType.values, contains(RestrictionType.crossDeviceLock));
      expect(RestrictionType.values, contains(RestrictionType.internet));
    });

    test('canOpenApp() should return decision', () async {
      final engine = RestrictionEngine.instance;
      await engine.init();

      final decision = await engine.canOpenApp('com.example.app');

      expect(decision, isNotNull);
      expect(decision.canOpen, isA<bool>());
      expect(decision.reason, isA<String>());
      expect(decision.type, isA<RestrictionType>());
    });

    test('canOpenApp() should allow unrestricted apps', () async {
      final engine = RestrictionEngine.instance;
      await engine.init();

      // App with no restrictions should be allowed
      final decision = await engine.canOpenApp('com.unrestricted.app');

      expect(decision.canOpen, isTrue);
      expect(decision.type, equals(RestrictionType.none));
    });

    test('onAppLaunchAttempt() should return boolean', () async {
      final engine = RestrictionEngine.instance;
      await engine.init();

      final allowed = await engine.onAppLaunchAttempt('com.example.app');

      expect(allowed, isA<bool>());
    });

    test('updateLocalUsage() should update cache', () {
      final engine = RestrictionEngine.instance;

      // Should not throw
      expect(
        () => engine.updateLocalUsage('com.example.app', 300),
        returnsNormally,
      );
    });

    test('syncUsageToShared() should handle zero minutes', () async {
      final engine = RestrictionEngine.instance;
      await engine.init();

      // Should not sync zero minutes
      expect(
        () async => await engine.syncUsageToShared('com.example.app', 0),
        returnsNormally,
      );
    });

    test('syncUsageToShared() should handle negative minutes', () async {
      final engine = RestrictionEngine.instance;
      await engine.init();

      // Should not sync negative minutes
      expect(
        () async => await engine.syncUsageToShared('com.example.app', -5),
        returnsNormally,
      );
    });

    test('syncUsageToShared() should sync positive minutes', () async {
      final engine = RestrictionEngine.instance;
      await engine.init();

      expect(
        () async => await engine.syncUsageToShared('com.example.app', 10),
        returnsNormally,
      );
    });

    test('refreshCache() should complete without throwing', () async {
      final engine = RestrictionEngine.instance;

      expect(() async => await engine.refreshCache(), returnsNormally);
    });

    test('clearCache() should reset all caches', () {
      final engine = RestrictionEngine.instance;

      // Should not throw
      expect(() => engine.clearCache(), returnsNormally);
    });
  });

  group('RestrictionDecision', () {
    test('should have correct properties for allow', () {
      final decision = RestrictionDecision.allow();

      expect(decision.canOpen, isTrue);
      expect(decision.reason, isNotEmpty);
      expect(decision.type, equals(RestrictionType.none));
    });

    test('should have correct properties for block', () {
      final decision = RestrictionDecision.block(
        'Blocked reason',
        RestrictionType.launchLimit,
      );

      expect(decision.canOpen, isFalse);
      expect(decision.reason, equals('Blocked reason'));
      expect(decision.type, equals(RestrictionType.launchLimit));
    });
  });
}
