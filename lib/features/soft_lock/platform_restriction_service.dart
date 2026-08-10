import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class PlatformRestrictionService {
  static const MethodChannel _channel = MethodChannel('com.nlp.digitox/restrictions');

  static Future<bool> showRestrictionForApp({
    required String packageName,
    required String appName,
    required String reason,
    Duration? remainingTime,
  }) async {
    if (Platform.isAndroid) {
      // Android uses AccessibilityService overlay
      return await _showAndroidOverlay(packageName, reason);
    } else if (Platform.isIOS) {
      // iOS uses soft-lock overlay within the app
      return await _showIOSSoftLock(packageName, appName, reason, remainingTime);
    }
    return false;
  }

  static Future<bool> _showAndroidOverlay(String packageName, String reason) async {
    try {
      final result = await _channel.invokeMethod('showRestrictionOverlay', {
        'packageName': packageName,
        'reason': reason,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to show Android overlay: ${e.message}');
      return false;
    }
  }

  static Future<bool> _showIOSSoftLock(
    String packageName,
    String appName,
    String reason,
    Duration? remainingTime,
  ) async {
    try {
      final result = await _channel.invokeMethod('showSoftLock', {
        'packageName': packageName,
        'appName': appName,
        'reason': reason,
        'remainingSeconds': remainingTime?.inSeconds,
      });
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to show iOS soft lock: ${e.message}');
      return false;
    }
  }

  static Future<bool> isAccessibilityServiceEnabled() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _channel.invokeMethod('isAccessibilityEnabled');
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to check accessibility: ${e.message}');
      return false;
    }
  }

  static Future<void> openAccessibilitySettings() async {
    if (!Platform.isAndroid) return;
    
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } on PlatformException catch (e) {
      debugPrint('Failed to open settings: ${e.message}');
    }
  }

  static Future<void> requestScreenTimePermission() async {
    if (!Platform.isIOS) return;
    
    try {
      await _channel.invokeMethod('requestScreenTimePermission');
    } on PlatformException catch (e) {
      debugPrint('Failed to request Screen Time: ${e.message}');
    }
  }
}
