// Privacy service for NLP-Digitox

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nlp_digitox/models/privacy_settings_model.dart';

/// Service managing privacy settings, data export, and user data deletion.
///
/// DELETION POLICY:
///   - Deletes all data under users/{uid} in Firebase Realtime DB
///   - Deletes all documents in Firestore under users/{uid}
///   - Clears local SharedPreferences data
///   - Does NOT delete the Firebase Auth account (user must use a separate
///     "Delete Account" flow for that)
class PrivacyService {
  PrivacyService._();
  static final PrivacyService instance = PrivacyService._();

  static const String _prefsKey = 'privacy_settings_v1';

  PrivacySettings _settings = const PrivacySettings();
  bool _initialized = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        _settings = PrivacySettings.fromJson(raw);
      }
      _initialized = true;
      debugPrint('PrivacyService: Initialized — $_settings');
    } catch (e) {
      debugPrint('PrivacyService: Init error: $e');
      // Fail-safe: keep defaults
      _initialized = true;
    }
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  PrivacySettings get settings => _settings;

  bool get cloudSyncEnabled => _settings.cloudSyncEnabled;
  bool get crossDeviceEnabled => _settings.effectiveCrossDevice;
  bool get moodTrackingEnabled => _settings.moodTrackingEnabled;

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  Future<PrivacySettings> update(PrivacySettings updated) async {
    _settings = updated;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, updated.toJson());
      debugPrint('PrivacyService: Settings saved — $_settings');
    } catch (e) {
      debugPrint('PrivacyService: Error saving settings: $e');
    }
    return _settings;
  }

  // ---------------------------------------------------------------------------
  // Data Export
  // ---------------------------------------------------------------------------

  /// Collects all identifiable local user data into a JSON-serialisable map.
  /// This does NOT include Firebase data (privacy-first: only local data).
  Future<Map<String, dynamic>> exportLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();

      final exportMap = <String, dynamic>{
        'exportedAt': DateTime.now().toIso8601String(),
        'appVersion': '1.3.0',
        'preferences': {},
      };

      // Export all non-sensitive preference keys
      const sensitiveKeys = {'firebase_app_name', 'google_sign_in_token'};
      for (final key in allKeys) {
        if (sensitiveKeys.contains(key)) continue;
        exportMap['preferences'][key] = prefs.get(key);
      }

      return exportMap;
    } catch (e) {
      debugPrint('PrivacyService: Error exporting data: $e');
      return {'error': e.toString(), 'exportedAt': DateTime.now().toIso8601String()};
    }
  }

  /// Returns the export data as a pretty-printed JSON string.
  Future<String> exportLocalDataAsJson() async {
    final data = await exportLocalData();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // ---------------------------------------------------------------------------
  // Data Deletion
  // ---------------------------------------------------------------------------

  /// Deletes all user data from:
  ///  1. Firebase Realtime Database (users/{uid}/*)
  ///  2. Firestore (users/{uid} document + subcollections)
  ///  3. All SharedPreferences entries
  ///
  /// Does NOT delete the Firebase Auth account.
  Future<DeleteDataResult> deleteAllUserData() async {
    final results = <String, bool>{};
    final errors = <String>[];

    final uid = FirebaseAuth.instance.currentUser?.uid;

    // 1 — Firebase Realtime DB
    if (uid != null) {
      try {
        await FirebaseDatabase.instance.ref('users/$uid').remove();
        // Also remove from sessions membership index
        await FirebaseDatabase.instance
            .ref('users/$uid/sessions')
            .remove();
        results['realtimeDB'] = true;
        debugPrint('PrivacyService: Deleted RTDB data for $uid');
      } catch (e) {
        results['realtimeDB'] = false;
        errors.add('Realtime DB: $e');
        debugPrint('PrivacyService: RTDB deletion error: $e');
      }
    } else {
      results['realtimeDB'] = false;
      errors.add('No authenticated user for RTDB deletion');
    }

    // 2 — Firestore
    if (uid != null) {
      try {
        await _deleteFirestoreUserData(uid);
        results['firestore'] = true;
        debugPrint('PrivacyService: Deleted Firestore data for $uid');
      } catch (e) {
        results['firestore'] = false;
        errors.add('Firestore: $e');
        debugPrint('PrivacyService: Firestore deletion error: $e');
      }
    } else {
      results['firestore'] = false;
      errors.add('No authenticated user for Firestore deletion');
    }

    // 3 — SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      // Re-write privacy settings to safe defaults so app works after deletion
      _settings = const PrivacySettings();
      results['localPrefs'] = true;
      debugPrint('PrivacyService: Cleared SharedPreferences');
    } catch (e) {
      results['localPrefs'] = false;
      errors.add('SharedPreferences: $e');
      debugPrint('PrivacyService: Prefs clear error: $e');
    }

    final allSucceeded = results.values.every((v) => v);
    return DeleteDataResult(
      success: allSucceeded,
      partialResults: results,
      errors: errors,
    );
  }

  /// Deletes the Firestore user document and known subcollections.
  Future<void> _deleteFirestoreUserData(String uid) async {
    final db = FirebaseFirestore.instance;
    final userRef = db.collection('users').doc(uid);

    // Known subcollections — extend as schema grows
    const subcollections = [
      'sessions',
      'notifications',
      'achievements',
      'mood_history',
    ];

    for (final sub in subcollections) {
      try {
        final snap = await userRef.collection(sub).get();
        for (final doc in snap.docs) {
          await doc.reference.delete();
        }
      } catch (_) {
        // Subcollection might not exist — ignore
      }
    }

    // Delete the root user document
    await userRef.delete();
  }
}

/// Result of a data deletion operation
class DeleteDataResult {
  final bool success;
  final Map<String, bool> partialResults;
  final List<String> errors;

  const DeleteDataResult({
    required this.success,
    required this.partialResults,
    required this.errors,
  });

  @override
  String toString() =>
      'DeleteDataResult(success: $success, results: $partialResults)';
}
