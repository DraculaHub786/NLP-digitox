// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/services/device_identity.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'dart:async';

/// Sync Service for cross-device coordination
/// Manages shared usage quotas, device locks, and real-time sync using Firebase Realtime Database
///
/// Firebase Schema:
/// users/{userId}/
///   ├── usage/{appPackage}/
///   │   ├── dailyMinutes: int
///   │   ├── lastReset: timestamp
///   │   └── dailyLimit: int
///   ├── devices/{deviceId}/
///   │   ├── name: string
///   │   ├── lastSeen: timestamp
///   │   ├── isPrimary: bool
///   │   └── isActive: bool
///   └── locks/{appPackage}/
///       ├── lockedBy: deviceId
///       ├── expiresAt: timestamp
///       └── acquiredAt: timestamp
class SyncService {
  /// Private constructor to enforce singleton pattern
  SyncService._();

  /// Singleton instance
  static final SyncService instance = SyncService._();

  /// Firebase Realtime Database instance (lazy-loaded)
  FirebaseDatabase? _database;

  /// Active listeners for cleanup
  final Map<String, StreamSubscription> _activeListeners = {};

  /// Local cache for offline support
  final Map<String, dynamic> _localCache = {};

  /// Initialization flag
  bool _isInitialized = false;

  /// Whether Firebase is available (for stub mode)
  bool _isFirebaseAvailable = true;

  /// Initialize the sync service
  /// Should be called once during app startup
  Future<void> init() async {
    try {
      if (_isInitialized) {
        debugPrint('SyncService: Already initialized');
        return;
      }

      // Ensure device identity is initialized
      if (DeviceIdentityService.instance.deviceId == null) {
        await DeviceIdentityService.instance.init();
      }

      // Initialize Firebase Database
      try {
        _database = FirebaseDatabase.instance;

        // Enable offline persistence
        _database!.setPersistenceEnabled(true);
        _database!.setPersistenceCacheSizeBytes(10000000); // 10MB
      } catch (e) {
        debugPrint('SyncService: Firebase initialization error: $e');
        _isFirebaseAvailable = false;
        _database = null;
      }

      // Register this device if Firebase is available
      if (_isFirebaseAvailable) {
        await _registerDevice();
      }

      _isInitialized = true;
      debugPrint('SyncService: Initialized successfully');
    } catch (e) {
      debugPrint('SyncService init error: $e');
      _isFirebaseAvailable = false;
      debugPrint('SyncService: Running in stub mode (Firebase unavailable)');
      // TODO: firebase - Configure Firebase Realtime Database
    }
  }

  /// Get database reference for current user
  DatabaseReference? get _userRef {
    final userId = FirebaseAuthService.instance.userId;
    if (userId == null || !_isFirebaseAvailable || _database == null) return null;
    return _database!.ref('users/$userId');
  }

  /// Register or update this device in Firebase
  Future<void> _registerDevice() async {
    try {
      final deviceId = DeviceIdentityService.instance.deviceId;
      final deviceName = DeviceIdentityService.instance.deviceName ?? 'Unknown Device';
      final userRef = _userRef;

      if (userRef == null || deviceId == null) {
        debugPrint('SyncService: Cannot register device - user not authenticated or device ID missing');
        return;
      }

      final deviceRef = userRef.child('devices/$deviceId');

      await deviceRef.update({
        'name': deviceName,
        'lastSeen': ServerValue.timestamp,
        'isActive': true,
      });

      debugPrint('SyncService: Device registered: $deviceName');
    } catch (e) {
      debugPrint('SyncService: Error registering device: $e');
      // TODO: firebase - Check Firebase Realtime Database configuration
    }
  }

  /// Update device last seen timestamp (call periodically or on app resume)
  Future<void> updateDevicePresence() async {
    try {
      final deviceId = DeviceIdentityService.instance.deviceId;
      final userRef = _userRef;

      if (userRef == null || deviceId == null) return;

      final deviceRef = userRef.child('devices/$deviceId');
      await deviceRef.update({
        'lastSeen': ServerValue.timestamp,
        'isActive': true,
      });
    } catch (e) {
      debugPrint('SyncService: Error updating presence: $e');
    }
  }

  /// Mark device as inactive (call on app pause or exit)
  Future<void> markDeviceInactive() async {
    try {
      final deviceId = DeviceIdentityService.instance.deviceId;
      final userRef = _userRef;

      if (userRef == null || deviceId == null) return;

      final deviceRef = userRef.child('devices/$deviceId');
      await deviceRef.update({
        'lastSeen': ServerValue.timestamp,
        'isActive': false,
      });
    } catch (e) {
      debugPrint('SyncService: Error marking device inactive: $e');
    }
  }

  /// Listen to shared usage quota for an app
  /// Returns a stream of current usage minutes
  Stream<int> listenQuota(String appPackage) {
    try {
      if (_userRef == null) {
        debugPrint('SyncService: Cannot listen to quota - user not authenticated');
        return Stream.value(_localCache['usage_$appPackage'] ?? 0);
      }

      final usageRef = _userRef!.child('usage/$appPackage/dailyMinutes');

      return usageRef.onValue.map((event) {
        final value = event.snapshot.value as int? ?? 0;
        _localCache['usage_$appPackage'] = value;
        return value;
      });
    } catch (e) {
      debugPrint('SyncService: Error listening to quota: $e');
      return Stream.value(0);
    }
  }

  /// Get current usage for an app
  Future<Map<String, dynamic>> getUsage(String appPackage) async {
    try {
      if (_userRef == null) {
        return {
          'dailyMinutes': _localCache['usage_$appPackage'] ?? 0,
          'dailyLimit': _localCache['limit_$appPackage'] ?? 0,
          'lastReset': DateTime.now().millisecondsSinceEpoch,
        };
      }

      final usageRef = _userRef!.child('usage/$appPackage');
      final snapshot = await usageRef.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data;
      } else {
        return {'dailyMinutes': 0, 'dailyLimit': 0, 'lastReset': 0};
      }
    } catch (e) {
      debugPrint('SyncService: Error getting usage: $e');
      return {'dailyMinutes': 0, 'dailyLimit': 0, 'lastReset': 0};
    }
  }

  /// Increment usage for an app (atomic operation)
  /// Returns true if increment succeeded, false if daily limit exceeded
  Future<bool> incrementUsage(String appPackage, int minutes) async {
    try {
      if (_userRef == null) {
        debugPrint('SyncService: Cannot increment usage - running in stub mode');
        // Update local cache only
        final current = _localCache['usage_$appPackage'] ?? 0;
        _localCache['usage_$appPackage'] = current + minutes;
        return true; // TODO: firebase
      }

      final usageRef = _userRef!.child('usage/$appPackage');

      // Use transaction to ensure atomic update
      final result = await usageRef.runTransaction((currentData) {
        Map<String, dynamic> data;

        if (currentData == null) {
          // First time usage
          data = {
            'dailyMinutes': minutes,
            'dailyLimit': 0, // 0 means no limit
            'lastReset': ServerValue.timestamp,
          };
        } else {
          data = Map<String, dynamic>.from(currentData as Map);
          final currentMinutes = data['dailyMinutes'] as int? ?? 0;
          final dailyLimit = data['dailyLimit'] as int? ?? 0;

          // Check if limit would be exceeded
          if (dailyLimit > 0 && currentMinutes + minutes > dailyLimit) {
            // Abort transaction - limit exceeded
            return Transaction.abort();
          }

          data['dailyMinutes'] = currentMinutes + minutes;
        }

        return Transaction.success(data);
      });

      if (result.committed) {
        debugPrint('SyncService: Incremented usage for $appPackage by $minutes minutes');
        return true;
      } else {
        debugPrint('SyncService: Usage increment aborted - daily limit exceeded');
        return false;
      }
    } catch (e) {
      debugPrint('SyncService: Error incrementing usage: $e');
      return false;
    }
  }

  /// Set daily limit for an app
  Future<void> setDailyLimit(String appPackage, int limitMinutes) async {
    try {
      if (_userRef == null) {
        _localCache['limit_$appPackage'] = limitMinutes;
        return;
      }

      final usageRef = _userRef!.child('usage/$appPackage');
      await usageRef.update({'dailyLimit': limitMinutes});

      debugPrint('SyncService: Set daily limit for $appPackage to $limitMinutes minutes');
    } catch (e) {
      debugPrint('SyncService: Error setting daily limit: $e');
    }
  }

  /// Acquire lock for an app (returns true if successful)
  /// Lock has a TTL and must be refreshed periodically
  Future<bool> acquireLock(String appPackage, {int ttlMinutes = 5}) async {
    try {
      final deviceId = DeviceIdentityService.instance.deviceId;
      if (_userRef == null || deviceId == null) {
        debugPrint('SyncService: Cannot acquire lock - running in stub mode');
        return true; // TODO: firebase - In stub mode, always allow
      }

      final lockRef = _userRef!.child('locks/$appPackage');
      final expiresAt = DateTime.now().add(Duration(minutes: ttlMinutes)).millisecondsSinceEpoch;

      // Use transaction to ensure atomic lock acquisition
      final result = await lockRef.runTransaction((currentData) {
        if (currentData == null) {
          // No lock exists, acquire it
          return Transaction.success({
            'lockedBy': deviceId,
            'expiresAt': expiresAt,
            'acquiredAt': ServerValue.timestamp,
          });
        }

        final data = Map<String, dynamic>.from(currentData as Map);
        final lockedBy = data['lockedBy'] as String?;
        final lockExpiresAt = data['expiresAt'] as int? ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;

        // Check if lock is expired or owned by this device
        if (lockedBy == deviceId || lockExpiresAt < now) {
          // Acquire or refresh lock
          data['lockedBy'] = deviceId;
          data['expiresAt'] = expiresAt;
          data['acquiredAt'] = ServerValue.timestamp;
          return Transaction.success(data);
        }

        // Lock is held by another device
        return Transaction.abort();
      });

      if (result.committed) {
        debugPrint('SyncService: Acquired lock for $appPackage');
        return true;
      } else {
        debugPrint('SyncService: Failed to acquire lock - held by another device');
        return false;
      }
    } catch (e) {
      debugPrint('SyncService: Error acquiring lock: $e');
      return false;
    }
  }

  /// Release lock for an app
  Future<void> releaseLock(String appPackage) async {
    try {
      final deviceId = DeviceIdentityService.instance.deviceId;
      if (_userRef == null || deviceId == null) return;

      final lockRef = _userRef!.child('locks/$appPackage');

      // Only release if this device owns the lock
      final snapshot = await lockRef.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final lockedBy = data['lockedBy'] as String?;

        if (lockedBy == deviceId) {
          await lockRef.remove();
          debugPrint('SyncService: Released lock for $appPackage');
        }
      }
    } catch (e) {
      debugPrint('SyncService: Error releasing lock: $e');
    }
  }

  /// Check if an app is locked by another device
  Future<bool> isLockedByOtherDevice(String appPackage) async {
    try {
      final deviceId = DeviceIdentityService.instance.deviceId;
      if (_userRef == null || deviceId == null) return false;

      final lockRef = _userRef!.child('locks/$appPackage');
      final snapshot = await lockRef.get();

      if (!snapshot.exists) return false;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final lockedBy = data['lockedBy'] as String?;
      final expiresAt = data['expiresAt'] as int? ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Check if locked by another device and not expired
      return lockedBy != deviceId && expiresAt > now;
    } catch (e) {
      debugPrint('SyncService: Error checking lock: $e');
      return false;
    }
  }

  /// Reset daily usage for all apps (typically called at midnight)
  Future<void> resetDailyUsage() async {
    try {
      if (_userRef == null) {
        _localCache.clear();
        return;
      }

      final usageRef = _userRef!.child('usage');
      final snapshot = await usageRef.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        for (final appPackage in data.keys) {
          await usageRef.child('$appPackage/dailyMinutes').set(0);
          await usageRef.child('$appPackage/lastReset').set(ServerValue.timestamp);
        }
      }

      debugPrint('SyncService: Daily usage reset completed');
    } catch (e) {
      debugPrint('SyncService: Error resetting daily usage: $e');
    }
  }

  /// Dispose and cleanup
  Future<void> dispose() async {
    try {
      await markDeviceInactive();

      // Cancel all active listeners
      for (final subscription in _activeListeners.values) {
        await subscription.cancel();
      }
      _activeListeners.clear();

      debugPrint('SyncService: Disposed successfully');
    } catch (e) {
      debugPrint('SyncService: Error during dispose: $e');
    }
  }
}
