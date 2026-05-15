
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/config/app_constants.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';

/// Firestore Database Service
/// Handles all database operations using Cloud Firestore
/// Replaces the local SQLite database with cloud storage
class FirestoreService {
  /// Private constructor to enforce singleton pattern
  FirestoreService._();

  /// Singleton instance
  static final FirestoreService instance = FirestoreService._();

  /// Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user document reference
  DocumentReference? get _userDoc {
    final userId = FirebaseAuthService.instance.userId;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId);
  }

  /// Initialize user document (call after signup/signin)
  Future<void> initializeUserData({
    required String username,
    Map<String, dynamic>? initialSettings,
  }) async {
    try {
      if (_userDoc == null) {
        throw Exception('User not authenticated');
      }

      final docSnapshot = await _userDoc!.get();
      
      // Only create if doesn't exist
      if (!docSnapshot.exists) {
        await _userDoc!.set({
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
          'settings': initialSettings ?? {
            'themeMode': 'system',
            'accentColor': 'Indigo',
            'locale': 'en',
            'protectedAccess': false,
            'isOnboardingDone': false,
          },
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        debugPrint('User data initialized');
      }
    } catch (e) {
      debugPrint('Initialize user data error: $e');
      throw Exception('Failed to initialize user data');
    }
  }

  /// Get user settings
  Future<Map<String, dynamic>> getUserSettings() async {
    try {
      if (_userDoc == null) {
        throw Exception('User not authenticated');
      }

      final docSnapshot = await _userDoc!.get();
      if (!docSnapshot.exists) {
        await initializeUserData(username: AppConstants.defaultUsername);
        return getUserSettings();
      }

      final data = docSnapshot.data() as Map<String, dynamic>?;
      return data?['settings'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      debugPrint('Get user settings error: $e');
      throw Exception('Failed to load settings');
    }
  }

  /// Update user settings
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      if (_userDoc == null) {
        throw Exception('User not authenticated');
      }

      await _userDoc!.update({
        'settings': settings,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      debugPrint('Settings updated');
    } catch (e) {
      debugPrint('Update settings error: $e');
      throw Exception('Failed to update settings');
    }
  }

  /// Check if username is available (for uniqueness)
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final usersRef = FirebaseFirestore.instance.collection('users');
      final query = await usersRef
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      // Username is available if no documents found
      return query.docs.isEmpty;
    } catch (e) {
      debugPrint('Check username availability error: $e');
      return false; // Assume taken on error for safety
    }
  }

  /// Update username with uniqueness check
  Future<void> updateUsername(String username) async {
    try {
      if (_userDoc == null) {
        throw Exception('User not authenticated');
      }

      // Check if username is already taken
      final isAvailable = await isUsernameAvailable(username);
      if (!isAvailable) {
        throw Exception('Username already taken. Please choose another.');
      }

      await _userDoc!.update({
        'username': username,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      debugPrint('Username updated to: $username');
    } catch (e) {
      debugPrint('Update username error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Save app restriction for a specific app
  Future<void> saveAppRestriction({
    required String packageName,
    required Map<String, dynamic> restriction,
  }) async {
    try {
      if (_userDoc == null) {
        throw Exception('User not authenticated');
      }

      await _userDoc!.collection('appRestrictions').doc(packageName).set({
        ...restriction,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      debugPrint('App restriction saved for: $packageName');
    } catch (e) {
      debugPrint('Save app restriction error: $e');
      throw Exception('Failed to save app restriction');
    }
  }

  /// Get app restriction
  Future<Map<String, dynamic>?> getAppRestriction(String packageName) async {
    try {
      if (_userDoc == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _userDoc!.collection('appRestrictions').doc(packageName).get();
      return doc.data();
    } catch (e) {
      debugPrint('Get app restriction error: $e');
      return null;
    }
  }

  /// Get all app restrictions
  Stream<QuerySnapshot> getAppRestrictionsStream() {
    if (_userDoc == null) {
      return const Stream.empty();
    }
    return _userDoc!.collection('appRestrictions').snapshots();
  }

  /// Save app usage data for a specific day
  Future<void> saveAppUsage({
    required String packageName,
    required DateTime date,
    required Map<String, dynamic> usage,
  }) async {
    try {
      if (_userDoc == null) {
        throw Exception('User not authenticated');
      }

      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      await _userDoc!
          .collection('appUsage')
          .doc(dateStr)
          .collection('apps')
          .doc(packageName)
          .set({
        ...usage,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      debugPrint('App usage saved for: $packageName on $dateStr');
    } catch (e) {
      debugPrint('Save app usage error: $e');
      throw Exception('Failed to save app usage');
    }
  }

  /// Get app usage for a specific date
  Stream<QuerySnapshot> getAppUsageStream(DateTime date) {
    if (_userDoc == null) {
      return const Stream.empty();
    }

    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _userDoc!
        .collection('appUsage')
        .doc(dateStr)
        .collection('apps')
        .snapshots();
  }

  /// Save focus session
  Future<void> saveFocusSession(Map<String, dynamic> session) async {
    try {
      if (_userDoc == null) {
        throw Exception('User not authenticated');
      }

      await _userDoc!.collection('focusSessions').add({
        ...session,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('Focus session saved');
    } catch (e) {
      debugPrint('Save focus session error: $e');
      throw Exception('Failed to save focus session');
    }
  }

  /// Get focus sessions stream
  Stream<QuerySnapshot> getFocusSessionsStream({int? limit}) {
    if (_userDoc == null) {
      return const Stream.empty();
    }

    var query = _userDoc!
        .collection('focusSessions')
        .orderBy('createdAt', descending: true);
    
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  /// Save crash log
  Future<void> saveCrashLog(Map<String, dynamic> crashLog) async {
    try {
      if (_userDoc == null) {
        throw Exception('User not authenticated');
      }

      await _userDoc!.collection('crashLogs').add({
        ...crashLog,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      debugPrint('Crash log saved');
    } catch (e) {
      debugPrint('Save crash log error: $e');
      // Don't throw exception for crash logs
    }
  }

  /// Delete user data (call before account deletion)
  Future<void> deleteUserData() async {
    try {
      if (_userDoc == null) {
        throw Exception('User not authenticated');
      }

      // Delete all subcollections
      final collections = [
        'appRestrictions',
        'appUsage',
        'focusSessions',
        'crashLogs',
        'restrictionGroups',
        'notifications',
      ];

      for (final collection in collections) {
        final snapshot = await _userDoc!.collection(collection).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      // Delete user document
      await _userDoc!.delete();
      debugPrint('User data deleted');
    } catch (e) {
      debugPrint('Delete user data error: $e');
      throw Exception('Failed to delete user data');
    }
  }

  /// Export user data (for GDPR compliance)
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      if (_userDoc == null) {
        throw Exception('User not authenticated');
      }

      final userDoc = await _userDoc!.get();
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};

      // Get all subcollections
      final collections = {
        'appRestrictions': await _userDoc!.collection('appRestrictions').get(),
        'focusSessions': await _userDoc!.collection('focusSessions').get(),
        'restrictionGroups': await _userDoc!.collection('restrictionGroups').get(),
      };

      final exportData = {
        'user': userData,
        'collections': collections.map((key, snapshot) {
          return MapEntry(
            key,
            snapshot.docs.map((doc) => doc.data()).toList(),
          );
        }),
        'exportedAt': DateTime.now().toIso8601String(),
      };

      debugPrint('User data exported');
      return exportData;
    } catch (e) {
      debugPrint('Export user data error: $e');
      throw Exception('Failed to export user data');
    }
  }
}
