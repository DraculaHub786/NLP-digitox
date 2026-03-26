// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:nlp_digitox/core/services/device_identity.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';

/// Service for managing shared sessions and group presence
/// Integrates with SyncService for cross-device coordination
///
/// Firebase Schema:
/// sessions/{sessionId}/
///   ├── name: string
///   ├── description: string
///   ├── ownerId: string
///   ├── createdAt: timestamp
///   ├── isPublic: bool
///   ├── maxMembers: int
///   ├── theme: string
///   ├── isActive: bool
///   ├── members/{userId}/
///   │   ├── displayName: string
///   │   ├── deviceId: string
///   │   ├── joinedAt: timestamp
///   │   ├── isActive: bool
///   │   └── lastActive: timestamp
///   └── settings/
///       ├── sharedDailyLimit: int
///       ├── focusApps: list
///       └── blockedApps: list
///
/// users/{userId}/sessions/{sessionId}: sessionId (for quick lookup)
class SessionService {
  /// Private constructor for singleton
  SessionService._();

  /// Singleton instance
  static final SessionService instance = SessionService._();

  /// Firebase Realtime Database instance
  FirebaseDatabase? _database;

  /// Active listeners for cleanup
  final Map<String, StreamSubscription> _activeListeners = {};

  /// Presence heartbeat timers
  final Map<String, Timer?> _presenceHeartbeatTimers = {};

  /// Local session cache
  final Map<String, SharedSession> _sessionCache = {};

  /// Is initialized
  bool _isInitialized = false;

  /// Whether Firebase is available
  bool _isFirebaseAvailable = true;

  /// Initialize the session service
  Future<void> init() async {
    try {
      if (_isInitialized) {
        debugPrint('SessionService: Already initialized');
        return;
      }

      // Ensure device identity is initialized
      if (DeviceIdentityService.instance.deviceId == null) {
        await DeviceIdentityService.instance.init();
      }

      // Get database instance
      try {
        _database = FirebaseDatabase.instance;
      } catch (e) {
        debugPrint('SessionService: Firebase initialization error: $e');
        _isFirebaseAvailable = false;
      }

      _isInitialized = true;
      debugPrint('SessionService: Initialized successfully');
    } catch (e) {
      debugPrint('SessionService init error: $e');
      _isFirebaseAvailable = false;
      debugPrint('SessionService: Running in stub mode');
    }
  }

  /// Create a new shared session
  Future<SharedSession> createSession({
    required String name,
    String? description,
    String? theme,
    bool isPublic = false,
    int maxMembers = 0,
    SessionSettings? settings,
  }) async {
    try {
      if (!_isInitialized) {
        throw StateError('SessionService not initialized. Call init() first.');
      }

      if (name.isEmpty) {
        throw ArgumentError('Session name cannot be empty');
      }

      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) {
        throw StateError('User not authenticated');
      }

      final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
      final deviceId = DeviceIdentityService.instance.deviceId;

      final session = SharedSession(
        id: sessionId,
        name: name,
        description: description,
        ownerId: userId,
        maxMembers: maxMembers,
        isPublic: isPublic,
        createdAt: DateTime.now(),
        theme: theme,
        isActive: true,
        settings: settings,
        members: [
          SessionMember(
            userId: userId,
            deviceId: deviceId,
            displayName: 'You',
            joinedAt: DateTime.now(),
            isActive: true,
            lastActive: DateTime.now(),
          ),
        ],
      );

      if (_isFirebaseAvailable && _database != null) {
        await _database!.ref('sessions/$sessionId').set(session.toMap());
        await _database!.ref('users/$userId/sessions/$sessionId').set(true);
      }

      _sessionCache[sessionId] = session;
      debugPrint('SessionService: Created session $sessionId');
      return session;
    } catch (e) {
      debugPrint('SessionService: Error creating session: $e');
      rethrow;
    }
  }

  /// Join an existing session
  Future<void> joinSession({
    required String sessionId,
    required String displayName,
  }) async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) {
        throw StateError('User not authenticated');
      }

      if (!_isInitialized) {
        throw StateError('SessionService not initialized');
      }

      if (displayName.isEmpty) {
        throw ArgumentError('Display name cannot be empty');
      }

      final deviceId = DeviceIdentityService.instance.deviceId;

      if (_isFirebaseAvailable && _database != null) {
        final sessionRef = _database!.ref('sessions/$sessionId');
        final sessionSnap = await sessionRef.get();

        if (!sessionSnap.exists) {
          throw StateError('Session not found');
        }

        final sessionMap = Map<String, dynamic>.from(sessionSnap.value as Map);
        final session = SharedSession.fromMap(sessionMap);

        // Check max members
        if (session.maxMembers > 0 && session.memberCount >= session.maxMembers) {
          throw StateError('Session is full');
        }

        // Check if already a member
        final isMember = session.members.any((m) => m.userId == userId);
        if (isMember) {
          debugPrint('SessionService: User already in session');
          return;
        }

        // Add member
        final newMember = SessionMember(
          userId: userId,
          deviceId: deviceId,
          displayName: displayName,
          joinedAt: DateTime.now(),
          isActive: true,
          lastActive: DateTime.now(),
        );

        await _database!.ref('sessions/$sessionId/members/$userId').set(newMember.toMap());
        await _database!.ref('users/$userId/sessions/$sessionId').set(true);

        // Update local cache
        if (_sessionCache.containsKey(sessionId)) {
          final updatedSession = _sessionCache[sessionId]!.copyWith(
            members: [..._sessionCache[sessionId]!.members, newMember],
          );
          _sessionCache[sessionId] = updatedSession;
        }
      }

      debugPrint('SessionService: Joined session $sessionId');
    } catch (e) {
      debugPrint('SessionService: Error joining session: $e');
      rethrow;
    }
  }

  /// Leave a session
  Future<void> leaveSession({required String sessionId}) async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) {
        throw StateError('User not authenticated');
      }

      if (!_isInitialized) {
        throw StateError('SessionService not initialized');
      }

      // Stop presence heartbeat
      _stopPresenceHeartbeat(sessionId);

      if (_isFirebaseAvailable && _database != null) {
        await _database!.ref('sessions/$sessionId/members/$userId').remove();
        await _database!.ref('users/$userId/sessions/$sessionId').remove();

        // If owner left, delete session
        final sessionRef = _database!.ref('sessions/$sessionId');
        final sessionSnap = await sessionRef.get();
        if (sessionSnap.exists) {
          final sessionMap = Map<String, dynamic>.from(sessionSnap.value as Map);
          final session = SharedSession.fromMap(sessionMap);
          if (session.ownerId == userId) {
            await sessionRef.remove();
          }
        }
      }

      _sessionCache.remove(sessionId);
      debugPrint('SessionService: Left session $sessionId');
    } catch (e) {
      debugPrint('SessionService: Error leaving session: $e');
      rethrow;
    }
  }

  /// Get a session by ID
  Future<SharedSession?> getSession(String sessionId) async {
    try {
      if (_sessionCache.containsKey(sessionId)) {
        return _sessionCache[sessionId];
      }

      if (!_isFirebaseAvailable || _database == null) {
        return null;
      }

      final snapshot = await _database!.ref('sessions/$sessionId').get();
      if (!snapshot.exists) return null;

      final session = SharedSession.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
      _sessionCache[sessionId] = session;
      return session;
    } catch (e) {
      debugPrint('SessionService: Error getting session: $e');
      return null;
    }
  }

  /// Get user's sessions
  Future<List<SharedSession>> getUserSessions() async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) {
        return [];
      }

      if (!_isFirebaseAvailable || _database == null) {
        return [];
      }

      final snapshot = await _database!.ref('users/$userId/sessions').get();
      if (!snapshot.exists) return [];

      final sessionIds = (snapshot.value as Map?)?.keys.cast<String>() ?? [];
      final sessions = <SharedSession>[];

      for (final sessionId in sessionIds) {
        final session = await getSession(sessionId);
        if (session != null) {
          sessions.add(session);
        }
      }

      return sessions;
    } catch (e) {
      debugPrint('SessionService: Error getting user sessions: $e');
      return [];
    }
  }

  /// Start presence heartbeat for a session
  void startPresenceHeartbeat(String sessionId) {
    try {
      if (_presenceHeartbeatTimers.containsKey(sessionId) && _presenceHeartbeatTimers[sessionId]?.isActive == true) {
        return; // Already running
      }

      _presenceHeartbeatTimers[sessionId] = Timer.periodic(Duration(seconds: 30), (_) async {
        await _updatePresence(sessionId);
      });

      debugPrint('SessionService: Started presence heartbeat for $sessionId');
    } catch (e) {
      debugPrint('SessionService: Error starting heartbeat: $e');
    }
  }

  /// Stop presence heartbeat for a session
  void _stopPresenceHeartbeat(String sessionId) {
    _presenceHeartbeatTimers[sessionId]?.cancel();
    _presenceHeartbeatTimers.remove(sessionId);
    debugPrint('SessionService: Stopped presence heartbeat for $sessionId');
  }

  /// Update member presence
  Future<void> _updatePresence(String sessionId) async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null || !_isFirebaseAvailable || _database == null) {
        return;
      }

      await _database!.ref('sessions/$sessionId/members/$userId/lastActive').set(DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('SessionService: Error updating presence: $e');
    }
  }

  /// Listen to session updates
  StreamSubscription<DatabaseEvent> listenToSession(
    String sessionId,
    Function(SharedSession) onUpdate,
  ) {
    if (!_isFirebaseAvailable || _database == null) {
      // Return dummy subscription for stub mode
      return Stream<DatabaseEvent>.empty().listen((_) {});
    }

    final subscription = _database!.ref('sessions/$sessionId').onValue.listen((event) {
      try {
        if (event.snapshot.exists) {
          final session = SharedSession.fromMap(Map<String, dynamic>.from(event.snapshot.value as Map));
          _sessionCache[sessionId] = session;
          onUpdate(session);
        }
      } catch (e) {
        debugPrint('SessionService: Error processing session update: $e');
      }
    });

    _activeListeners[sessionId] = subscription;
    return subscription;
  }

  /// Release resources
  Future<void> release() async {
    try {
      // Cancel all heartbeats
      for (final timer in _presenceHeartbeatTimers.values) {
        timer?.cancel();
      }
      _presenceHeartbeatTimers.clear();

      // Cancel all listeners
      for (final listener in _activeListeners.values) {
        await listener.cancel();
      }
      _activeListeners.clear();

      _sessionCache.clear();
      _isInitialized = false;
      debugPrint('SessionService: Released');
    } catch (e) {
      debugPrint('SessionService: Error during release: $e');
    }
  }

  /// Get debug status
  String get debugStatus =>
      'SessionService(ready: $_isInitialized, cache_size: ${_sessionCache.length}, heartbeats: ${_presenceHeartbeatTimers.length})';

  /// Check if ready
  bool get isReady => _isInitialized;
}
