
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Device Identity Service
/// Generates and manages a stable device identifier for cross-device sync
/// Uses device-specific information and stores a hashed ID locally
class DeviceIdentityService {
  /// Private constructor to enforce singleton pattern
  DeviceIdentityService._();

  /// Singleton instance
  static final DeviceIdentityService instance = DeviceIdentityService._();

  /// Shared preferences key for device ID
  static const String _deviceIdKey = 'device_identity_id';
  static const String _deviceNameKey = 'device_identity_name';

  /// Cached device ID
  String? _cachedDeviceId;
  String? _cachedDeviceName;

  /// Initialize and retrieve device ID
  /// Should be called once during app startup
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if device ID is already stored
      _cachedDeviceId = prefs.getString(_deviceIdKey);
      _cachedDeviceName = prefs.getString(_deviceNameKey);

      // Generate and store if not exists
      if (_cachedDeviceId == null) {
        final deviceInfo = await _generateDeviceInfo();
        _cachedDeviceId = deviceInfo['id'];
        _cachedDeviceName = deviceInfo['name'];

        await prefs.setString(_deviceIdKey, _cachedDeviceId!);
        await prefs.setString(_deviceNameKey, _cachedDeviceName!);

        debugPrint('DeviceIdentity: Generated new device ID');
      } else {
        debugPrint('DeviceIdentity: Loaded existing device ID');
      }
    } catch (e) {
      debugPrint('DeviceIdentity init error: $e');
      // Generate fallback ID
      _cachedDeviceId = _generateFallbackId();
      _cachedDeviceName = 'Unknown Device';
    }
  }

  /// Get the current device ID
  /// Returns null if init() hasn't been called yet
  String? get deviceId => _cachedDeviceId;

  /// Get the current device name
  String? get deviceName => _cachedDeviceName;

  /// Get hashed device ID for privacy
  /// Uses SHA-256 to create a privacy-preserving identifier
  String get hashedDeviceId {
    if (_cachedDeviceId == null) {
      return _generateFallbackId();
    }
    final bytes = utf8.encode(_cachedDeviceId!);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Generate device information based on platform
  Future<Map<String, String>> _generateDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    String id;
    String name;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        // Use Android ID as base (persistent across app reinstalls)
        final androidId = androidInfo.id;
        final model = androidInfo.model;
        final manufacturer = androidInfo.manufacturer;

        // Create stable ID from multiple sources
        id = _hashString('$androidId-${androidInfo.device}-${androidInfo.product}');
        name = '$manufacturer $model';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        // Use identifierForVendor (persistent per app vendor)
        final vendorId = iosInfo.identifierForVendor ?? 'unknown-ios';
        final model = iosInfo.model;

        id = _hashString('$vendorId-${iosInfo.systemVersion}');
        name = 'iOS $model';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfoPlugin.linuxInfo;
        final machineId = linuxInfo.machineId ?? 'unknown-linux';

        id = _hashString('$machineId-${linuxInfo.id}');
        name = '${linuxInfo.name} ${linuxInfo.version}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
        final deviceId = windowsInfo.deviceId;

        id = _hashString('$deviceId-${windowsInfo.computerName}');
        name = windowsInfo.computerName;
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfoPlugin.macOsInfo;
        final uuid = macInfo.systemGUID ?? 'unknown-mac';

        id = _hashString('$uuid-${macInfo.model}');
        name = macInfo.computerName;
      } else {
        // Fallback for unsupported platforms
        id = _generateFallbackId();
        name = 'Unknown Device';
      }

      return {'id': id, 'name': name};
    } catch (e) {
      debugPrint('DeviceIdentity: Error generating device info: $e');
      return {
        'id': _generateFallbackId(),
        'name': 'Unknown Device',
      };
    }
  }

  /// Hash a string using SHA-256
  String _hashString(String input) {
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Generate fallback ID using timestamp and random data
  String _generateFallbackId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    return _hashString('fallback-$timestamp-$random');
  }

  /// Clear stored device ID (useful for testing or reset)
  Future<void> clearDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceIdKey);
      await prefs.remove(_deviceNameKey);
      _cachedDeviceId = null;
      _cachedDeviceName = null;
      debugPrint('DeviceIdentity: Cleared device ID');
    } catch (e) {
      debugPrint('DeviceIdentity: Error clearing device ID: $e');
      rethrow;
    }
  }
}
