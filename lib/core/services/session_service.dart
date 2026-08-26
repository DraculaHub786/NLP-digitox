
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:nlp_digitox/core/services/device_identity.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';

/// Service for managing shared sessions and group presence
/// Backed by Firebase Realtime Database; presence is coordinated per-session
///
/// Firebase Schema:
/// sessions/{sessionId}/
///   ├── name: string
///   ├── description: string
///   ├── ownerId: string
///   ├── createdAt: timestamp (ISO string)
///   ├── isPublic: bool
///   ├── maxMembers: int
///   ├── theme: string
///   ├── isActive: bool
///   ├── members/{userId}/          ← Map keyed by userId, NOT a list
///   │   ├── userId: string
///   │   ├── displayName: string
///   │   ├── deviceId: string
///   │   ├── joinedAt: ISO string
///   │   ├── isActive: bool
///   │   └── lastActive: ISO string
///   └── settings/
///       ├── sharedDailyLimit: int
///       ├── focusApps: list
///       └── blockedApps: list
///
/// users/{userId}/sessions/{sessionId}: true (for quick lookup)
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

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Session CRUD
  // ---------------------------------------------------------------------------

  /// Create a new shared session.
  /// Uses Firebase push().key for collision-safe IDs.
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

      final deviceId = DeviceIdentityService.instance.deviceId;

      // Generate a collision-safe ID from Firebase push
      String sessionId;
      if (_isFirebaseAvailable && _database != null) {
        sessionId = _database!.ref('sessions').push().key ??
            'session_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        sessionId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      }

      final now = DateTime.now();
      final ownerMember = SessionMember(
        userId: userId,
        deviceId: deviceId,
        displayName: 'You',
        joinedAt: now,
        isActive: true,
        lastActive: now,
      );

      final session = SharedSession(
        id: sessionId,
        name: name,
        description: description,
        ownerId: userId,
        maxMembers: maxMembers,
        isPublic: isPublic,
        createdAt: now,
        theme: theme,
        isActive: true,
        settings: settings,
        members: [ownerMember],
      );

      if (_isFirebaseAvailable && _database != null) {
        await _database!.ref('sessions/$sessionId').set(session.toMap());
        // Index for this user's session list
        await _database!.ref('users/$userId/sessions/$sessionId').set(true);
        // Index in public listing if applicable
        if (isPublic) {
          await _database!.ref('publicSessions/$sessionId').set({
            'name': name,
            'theme': theme,
            'memberCount': 1,
            'createdAt': now.toIso8601String(),
          });
        }
      }

      _sessionCache[sessionId] = session;
      debugPrint('SessionService: Created session $sessionId');

      // Auto-start presence heartbeat for owner
      startPresenceHeartbeat(sessionId);

      return session;
    } catch (e) {
      debugPrint('SessionService: Error creating session: $e');
      rethrow;
    }
  }

  /// Join an existing session by ID.
  Future<void> joinSession({
    required String sessionId,
    required String displayName,
  }) async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) throw StateError('User not authenticated');
      if (!_isInitialized) throw StateError('SessionService not initialized');
      if (displayName.isEmpty) throw ArgumentError('Display name cannot be empty');

      final deviceId = DeviceIdentityService.instance.deviceId;

      if (_isFirebaseAvailable && _database != null) {
        final sessionRef = _database!.ref('sessions/$sessionId');
        final sessionSnap = await sessionRef.get();

        if (!sessionSnap.exists) throw StateError('Session not found');

        final session = SharedSession.fromMap(
          Map<String, dynamic>.from(sessionSnap.value as Map));

        // Check max members
        if (session.maxMembers > 0 && session.memberCount >= session.maxMembers) {
          throw StateError('Session is full');
        }

        // Check if already a member
        if (session.members.any((m) => m.userId == userId)) {
          debugPrint('SessionService: User already in session');
          return;
        }

        final now = DateTime.now();
        final newMember = SessionMember(
          userId: userId,
          deviceId: deviceId,
          displayName: displayName,
          joinedAt: now,
          isActive: true,
          lastActive: now,
        );

        // Write into members/{userId} — the nested-map structure
        await _database!
            .ref('sessions/$sessionId/members/$userId')
            .set(newMember.toMap());
        await _database!
            .ref('users/$userId/sessions/$sessionId')
            .set(true);
        // Update public index member count
        if (session.isPublic) {
          await _database!
              .ref('publicSessions/$sessionId/memberCount')
              .set(session.memberCount + 1);
        }
      }

      // Auto-start presence heartbeat
      startPresenceHeartbeat(sessionId);

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
      if (userId == null) throw StateError('User not authenticated');
      if (!_isInitialized) throw StateError('SessionService not initialized');

      // Stop presence heartbeat
      _stopPresenceHeartbeat(sessionId);

      if (_isFirebaseAvailable && _database != null) {
        await _database!
            .ref('sessions/$sessionId/members/$userId')
            .remove();
        await _database!
            .ref('users/$userId/sessions/$sessionId')
            .remove();

        // If owner left, mark session as inactive and remove from public index
        final sessionSnap =
            await _database!.ref('sessions/$sessionId').get();
        if (sessionSnap.exists) {
          final session = SharedSession.fromMap(
              Map<String, dynamic>.from(sessionSnap.value as Map));
          if (session.ownerId == userId) {
            await _database!
                .ref('sessions/$sessionId/isActive')
                .set(false);
            await _database!.ref('publicSessions/$sessionId').remove();
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

  // ---------------------------------------------------------------------------
  // Fetching
  // ---------------------------------------------------------------------------

  /// Get a session by ID (cache-first)
  Future<SharedSession?> getSession(String sessionId) async {
    try {
      if (_sessionCache.containsKey(sessionId)) {
        return _sessionCache[sessionId];
      }

      if (!_isFirebaseAvailable || _database == null) return null;

      final snapshot =
          await _database!.ref('sessions/$sessionId').get();
      if (!snapshot.exists) return null;

      final session = SharedSession.fromMap(
          Map<String, dynamic>.from(snapshot.value as Map));
      _sessionCache[sessionId] = session;
      return session;
    } catch (e) {
      debugPrint('SessionService: Error getting session: $e');
      return null;
    }
  }

  /// Get sessions the current user belongs to
  Future<List<SharedSession>> getUserSessions() async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) return [];
      if (!_isFirebaseAvailable || _database == null) return [];

      final snapshot =
          await _database!.ref('users/$userId/sessions').get();
      if (!snapshot.exists) return [];

      final sessionIds =
          (snapshot.value as Map?)?.keys.cast<String>() ?? [];
      final sessions = <SharedSession>[];

      for (final sessionId in sessionIds) {
        final session = await getSession(sessionId);
        if (session != null && session.isActive) {
          sessions.add(session);
        }
      }

      return sessions;
    } catch (e) {
      debugPrint('SessionService: Error getting user sessions: $e');
      return [];
    }
  }

  /// Get public sessions (for join-by-browse)
  Future<List<Map<String, dynamic>>> getPublicSessions({int limit = 30}) async {
    try {
      if (!_isFirebaseAvailable || _database == null) return [];

      final snapshot = await _database!
          .ref('publicSessions')
          .limitToFirst(limit)
          .get();
      if (!snapshot.exists) return [];

      final raw = Map<String, dynamic>.from(snapshot.value as Map);
      return raw.entries.map((e) {
        final data = Map<String, dynamic>.from(e.value as Map);
        data['id'] = e.key;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('SessionService: Error getting public sessions: $e');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Presence
  // ---------------------------------------------------------------------------

  /// Start presence heartbeat for a session (every 30 s)
  void startPresenceHeartbeat(String sessionId) {
    try {
      if (_presenceHeartbeatTimers[sessionId]?.isActive == true) return;

      _presenceHeartbeatTimers[sessionId] = Timer.periodic(
        const Duration(seconds: 30),
        (_) async => _updatePresence(sessionId),
      );

      debugPrint(
          'SessionService: Started presence heartbeat for $sessionId');
    } catch (e) {
      debugPrint('SessionService: Error starting heartbeat: $e');
    }
  }

  /// Stop presence heartbeat for a session
  void _stopPresenceHeartbeat(String sessionId) {
    _presenceHeartbeatTimers[sessionId]?.cancel();
    _presenceHeartbeatTimers.remove(sessionId);
    debugPrint(
        'SessionService: Stopped presence heartbeat for $sessionId');
  }

  /// Update member presence timestamp
  Future<void> _updatePresence(String sessionId) async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null || !_isFirebaseAvailable || _database == null) return;

      await _database!
          .ref('sessions/$sessionId/members/$userId')
          .update({
        'lastActive': DateTime.now().toIso8601String(),
        'isActive': true,
      });
    } catch (e) {
      debugPrint('SessionService: Error updating presence: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Real-time listening
  // ---------------------------------------------------------------------------

  /// Listen to live session updates
  StreamSubscription<DatabaseEvent> listenToSession(
    String sessionId,
    Function(SharedSession) onUpdate,
  ) {
    if (!_isFirebaseAvailable || _database == null) {
      return Stream<DatabaseEvent>.empty().listen((_) {});
    }

    final subscription =
        _database!.ref('sessions/$sessionId').onValue.listen(
      (event) {
        try {
          if (event.snapshot.exists) {
            final session = SharedSession.fromMap(
                Map<String, dynamic>.from(event.snapshot.value as Map));
            _sessionCache[sessionId] = session;
            onUpdate(session);
          }
        } catch (e) {
          debugPrint(
              'SessionService: Error processing session update: $e');
        }
      },
    );

    _activeListeners[sessionId] = subscription;
    return subscription;
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  /// Release all resources
  Future<void> release() async {
    try {
      for (final timer in _presenceHeartbeatTimers.values) {
        timer?.cancel();
      }
      _presenceHeartbeatTimers.clear();

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

  // ---------------------------------------------------------------------------
  // Debug helpers
  // ---------------------------------------------------------------------------

  String get debugStatus =>
      'SessionService(ready: $_isInitialized, '
      'cache: ${_sessionCache.length}, '
      'heartbeats: ${_presenceHeartbeatTimers.length})';

  bool get isReady => _isInitialized;
}
