import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/services/device_identity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceIdentityService', () {
    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('singleton instance should be the same', () {
      final instance1 = DeviceIdentityService.instance;
      final instance2 = DeviceIdentityService.instance;

      expect(instance1, equals(instance2));
    });

    test('init() should generate and store device ID', () async {
      final service = DeviceIdentityService.instance;

      await service.init();

      expect(service.deviceId, isNotNull);
      expect(service.deviceName, isNotNull);
      expect(service.deviceId, isNotEmpty);
    });

    test('init() should load existing device ID', () async {
      final service = DeviceIdentityService.instance;

      // First init
      await service.init();
      final firstId = service.deviceId;
      final firstName = service.deviceName;

      // Clear cache but not storage
      await service.clearDeviceId();

      // Re-initialize with stored values
      SharedPreferences.setMockInitialValues({
        'device_identity_id': firstId!,
        'device_identity_name': firstName!,
      });

      final newService = DeviceIdentityService.instance;
      await newService.init();

      expect(newService.deviceId, equals(firstId));
      expect(newService.deviceName, equals(firstName));
    });

    test('hashedDeviceId should return a valid hash', () async {
      final service = DeviceIdentityService.instance;

      await service.init();

      final hashedId = service.hashedDeviceId;

      expect(hashedId, isNotNull);
      expect(hashedId, isNotEmpty);
      // SHA-256 hash should be 64 characters
      expect(hashedId.length, equals(64));
    });

    test('clearDeviceId() should remove stored ID', () async {
      final service = DeviceIdentityService.instance;

      await service.init();
      expect(service.deviceId, isNotNull);

      await service.clearDeviceId();

      expect(service.deviceId, isNull);
      expect(service.deviceName, isNull);
    });

    test('hashedDeviceId should generate fallback if deviceId is null', () {
      final service = DeviceIdentityService.instance;

      final hashedId = service.hashedDeviceId;

      expect(hashedId, isNotNull);
      expect(hashedId, isNotEmpty);
    });
  });
}
