
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:nlp_digitox/core/constants/session_limits.dart';
import 'package:nlp_digitox/core/services/device_identity.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/productivity_points_service.dart';
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

  /// The in-flight [init] call, so simultaneous first uses share one attempt.
  Future<void>? _initFuture;

  /// Guarantees the service is ready, initialising it on demand.
  ///
  /// Nothing at startup initialises this reliably: `initializeServicesAndSchedules()`
  /// is fired from a `Future.delayed(10.seconds)` inside `NavigationService` and
  /// is never run again, and [release] — called on every sign-out — clears the
  /// initialised flag. Relying on that left Create throwing
  /// "SessionService not initialized" during the first ten seconds of a cold
  /// start and for the entire rest of the process after any sign-out.
  /// [init] is already idempotent, and `_initFuture` de-dupes concurrent calls.
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    await (_initFuture ??= init());
  }

  /// How long a Realtime Database round trip may take before the caller is
  /// told the server is unreachable.
  ///
  /// A Realtime Database `set()`/`update()` future only completes once the
  /// server acknowledges the write, so without a bound a dropped connection
  /// left the UI spinning with no error and no feedback at all.
  static const Duration _networkTimeout = Duration(seconds: 15);

  /// Runs [work] against the database, turning a timeout into a
  /// [SessionException] the UI can actually show. Every network call in this
  /// service goes through here so no code path can hang forever.
  Future<T> _onDatabase<T>(Future<T> Function() work) async {
    try {
      return await work().timeout(_networkTimeout);
    } on TimeoutException {
      // Firebase may still commit a write that timed out locally, so tell the
      // user to look before retrying rather than silently duplicating.
      throw const SessionException(
        'Could not reach the server. Check your connection, then reopen your '
        'session list before trying again.',
      );
    }
  }

  /// Drops null values before handing a map to `update()`.
  ///
  /// A Realtime Database `update()` treats an explicit null as a *delete*
  /// instruction, so passing a session whose `description`/`theme`/`settings`
  /// are unset would remove those keys instead of simply leaving them out.
  static Map<String, Object?> _withoutNulls(Map<String, dynamic> source) =>
      Map<String, Object?>.fromEntries(
        source.entries.where((entry) => entry.value != null),
      );

  /// Reads an integer from a value that may be an `int`, a `double` (JSON
  /// round-tripping turns whole numbers into doubles) or nothing at all.
  static int? _asIntOrNull(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  /// Turns a failed member write into the most accurate error available.
  ///
  /// A rejected join almost always means the session filled up between the
  /// capacity check and the write: that check reads the member map and the
  /// write lands afterwards, and only the server rules can see the gap. So the
  /// session is re-read to tell the two cases apart — if there is genuinely no
  /// room the user gets the full-session message, and if there is still room
  /// the original error is returned untouched rather than replaced by a guess.
  Future<Object> _translateJoinFailure(String sessionId, Object error) async {
    try {
      final database = _database;
      if (database != null) {
        final snapshot = await database
            .ref('sessions/$sessionId')
            .get()
            .timeout(_networkTimeout);
        final value = snapshot.value;
        if (value is Map) {
          final latest =
              SharedSession.fromMap(Map<String, dynamic>.from(value));
          if (latest.isFull) {
            return SessionException(SessionLimits.fullSessionMessage);
          }
        }
      }
    } catch (e) {
      debugPrint('SessionService: join failure re-check failed: $e');
    }
    return error;
  }

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
    int? maxMembers,
    SessionSettings? settings,
  }) async {
    try {
      await _ensureInitialized();

      if (name.isEmpty) {
        throw ArgumentError('Session name cannot be empty');
      }

      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) {
        throw StateError('User not authenticated');
      }

      final deviceId = DeviceIdentityService.instance.deviceId;

      // The cap is a product limit, not a caller preference: whatever was asked
      // for is forced into range here, so no code path can create a session
      // without a bound. `database.rules.json` enforces the same number.
      final memberCap = SessionLimits.normalizeMaxMembers(maxMembers);

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
        maxMembers: memberCap,
        isPublic: isPublic,
        createdAt: now,
        theme: theme,
        isActive: true,
        // A session always carries a settings block, even when the caller
        // supplied none: that is what makes the group-focus action available
        // to every member. An empty [SessionSettings] means "each member keeps
        // their own duration and blocklist", which is the sensible default for
        // a group created in one tap.
        settings: settings ?? const SessionSettings(),
        members: [ownerMember],
      );

      if (_isFirebaseAvailable && _database != null) {
        // One atomic multi-path write rather than three sequential `set()`s:
        // it is a single round trip, and either every index lands or none
        // does. The old sequence could leave `users/{uid}/sessions` pointing
        // at a session that was never created, and it gave the UI no way to
        // tell a slow connection from a failed one.
        final updates = <String, Object?>{
          'sessions/$sessionId': _withoutNulls(session.toMap()),
          'users/$userId/sessions/$sessionId': true,
          if (isPublic)
            'publicSessions/$sessionId': _withoutNulls({
              'name': name,
              'theme': theme,
              'memberCount': 1,
              'maxMembers': memberCap,
              'createdAt': now.toIso8601String(),
            }),
        };

        await _onDatabase(() => _database!.ref().update(updates));
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
      await _ensureInitialized();

      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) throw StateError('User not authenticated');
      if (displayName.isEmpty) throw ArgumentError('Display name cannot be empty');

      final deviceId = DeviceIdentityService.instance.deviceId;

      if (_isFirebaseAvailable && _database != null) {
        final sessionSnap = await _onDatabase(
          () => _database!.ref('sessions/$sessionId').get(),
        );

        if (!sessionSnap.exists) {
          throw const SessionException(
            'This session no longer exists. The owner may have ended it.',
          );
        }

        final session = SharedSession.fromMap(
            Map<String, dynamic>.from(sessionSnap.value as Map));

        if (session.isCompleted || !session.isActive) {
          throw const SessionException(
            'This session has already finished, so you can no longer join it.',
          );
        }

        // Membership is tested before capacity on purpose: someone already in
        // a full session is *returning*, not joining, and must not be turned
        // away by the cap they help fill.
        if (session.members.any((m) => m.userId == userId)) {
          // Already in: nothing to write, but the heartbeat must still run.
          debugPrint('SessionService: User already in session');
        } else if (session.isFull) {
          throw SessionException(SessionLimits.fullSessionMessage);
        } else {
          final now = DateTime.now();
          final newMember = SessionMember(
            userId: userId,
            deviceId: deviceId,
            displayName: displayName,
            joinedAt: now,
            isActive: true,
            lastActive: now,
          );

          // Membership and the user's own session index land together or not
          // at all, so a dropped connection can never leave one without the
          // other. `memberCount` on the public index is deliberately no longer
          // written here: only the owner may write that node, and the live
          // count is derived from this member map when the Discover list is
          // read — see `getPublicSessions`.
          // The capacity read above cannot be atomic with this write, so two
          // people tapping Join in the same instant can both pass the check.
          // The rules close that race; turn their rejection into the same
          // message the pre-check would have produced rather than letting a
          // bare permission-denied reach the user as "sign out and back in".
          try {
            await _onDatabase(
              () => _database!.ref().update({
                'sessions/$sessionId/members/$userId': newMember.toMap(),
                'users/$userId/sessions/$sessionId': true,
              }),
            );
          } catch (error) {
            throw await _translateJoinFailure(sessionId, error);
          }
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
      await _ensureInitialized();

      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) throw StateError('User not authenticated');

      // Stop presence heartbeat
      _stopPresenceHeartbeat(sessionId);

      if (_isFirebaseAvailable && _database != null) {
        // Read first: once our own member node is gone there is no way left
        // to tell whether we were the owner.
        final sessionSnap = await _onDatabase(
          () => _database!.ref('sessions/$sessionId').get(),
        );

        final updates = <String, Object?>{
          'sessions/$sessionId/members/$userId': null,
          'users/$userId/sessions/$sessionId': null,
        };

        if (sessionSnap.exists) {
          final session = SharedSession.fromMap(
              Map<String, dynamic>.from(sessionSnap.value as Map));

          if (session.ownerId == userId) {
            // The owner leaving ends the session and delists it from Discover.
            updates['sessions/$sessionId/isActive'] = false;
            updates['publicSessions/$sessionId'] = null;
          }
        }

        // A single atomic write. The previous version deleted our member node
        // twice, and it no longer touches the public `memberCount`: only the
        // owner may write that node, and the live count is derived from the
        // member map when the Discover list is read — see `getPublicSessions`.
        await _onDatabase(() => _database!.ref().update(updates));
      }

      _sessionCache.remove(sessionId);
      debugPrint('SessionService: Left session $sessionId');
    } catch (e) {
      debugPrint('SessionService: Error leaving session: $e');
      rethrow;
    }
  }

  /// Marks a shared session finished and pays the owner their completion
  /// points. Owner-only.
  ///
  /// Only the owner can call this, but the owner's device can only credit the
  /// *owner*. `LeaderboardService.addPoints` always writes to the signed-in
  /// uid, and firestore.rules allow a client to write its own board doc only,
  /// so crediting another member from here is impossible client-side. Every
  /// other member therefore claims their own points from their own device
  /// when they observe [SharedSession.completedAt] — see
  /// [_claimCompletionPointsIfFinished], which both `getSession` and
  /// `listenToSession` trigger.
  Future<SharedSession> completeSession({
    required String sessionId,
    int pointsPerMember =
        ProductivityPointsService.sharedSessionCompletionPoints,
  }) async {
    try {
      await _ensureInitialized();

      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) throw StateError('User not authenticated');

      final session = await getSession(sessionId);
      if (session == null) throw StateError('Session not found');
      if (session.ownerId != userId) {
        throw StateError('Only the session owner can complete it');
      }
      if (session.isCompleted) {
        debugPrint('SessionService: Session $sessionId already completed');
        return session;
      }

      final completedAt = DateTime.now();
      final completed = session.copyWith(
        isActive: false,
        completedAt: completedAt,
      );

      if (_isFirebaseAvailable && _database != null) {
        // Written before the points award so a failure in the award path
        // still leaves the session correctly marked finished rather than
        // hanging open. Marking it finished and delisting it from Discover
        // are one write, so a public session can never linger in
        // `publicSessions` after it has been completed.
        await _onDatabase(
          () => _database!.ref().update({
            'sessions/$sessionId/isActive': false,
            'sessions/$sessionId/completedAt': completedAt.toIso8601String(),
            if (session.isPublic) 'publicSessions/$sessionId': null,
          }),
        );
      }

      _stopPresenceHeartbeat(sessionId);
      _sessionCache[sessionId] = completed;

      await ProductivityPointsService.instance.awardSharedSessionCompletionPoints(
        sessionId: sessionId,
        points: pointsPerMember,
      );

      debugPrint('SessionService: Completed session $sessionId');
      return completed;
    } catch (e) {
      debugPrint('SessionService: Error completing session: $e');
      rethrow;
    }
  }

  /// Pays the signed-in user for [session] if it has been completed.
  ///
  /// Safe to call repeatedly: `ProductivityPointsService` de-dupes by session
  /// id, so the worst case is one cheap SharedPreferences read. This is the
  /// only way a non-owner member can be credited, because a client may not
  /// write another user's leaderboard doc.
  Future<void> _claimCompletionPointsIfFinished(SharedSession session) async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) return;

      // Only a genuine completion pays out, and only to members still on the
      // session. A session also goes inactive when its owner merely leaves it,
      // which must not pay anyone — see
      // SharedSession.isEligibleForCompletionPayout.
      if (!session.isEligibleForCompletionPayout(userId)) return;

      _stopPresenceHeartbeat(session.id);

      await ProductivityPointsService.instance
          .awardSharedSessionCompletionPoints(sessionId: session.id);
    } catch (e) {
      debugPrint('SessionService: Error claiming completion points: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Fetching
  // ---------------------------------------------------------------------------

  /// Get a session by ID.
  ///
  /// Network-first on purpose. This used to short-circuit on `_sessionCache`,
  /// but nothing ever refreshed that cache: `listenToSession` has no callers,
  /// so a session fetched once stayed frozen for the life of the process. The
  /// visible symptoms were a joined member never appearing in the member list,
  /// a departed member never disappearing (their RTDB node *was* removed
  /// correctly — the UI just never re-read it), and a completed session never
  /// showing as completed.
  ///
  /// The cache is now only a fallback for when RTDB is unavailable.
  Future<SharedSession?> getSession(String sessionId) async {
    try {
      await _ensureInitialized();

      if (!_isFirebaseAvailable || _database == null) {
        return _sessionCache[sessionId];
      }

      final snapshot = await _onDatabase(
        () => _database!.ref('sessions/$sessionId').get(),
      );
      if (!snapshot.exists) {
        _sessionCache.remove(sessionId);
        return null;
      }

      final session = SharedSession.fromMap(
          Map<String, dynamic>.from(snapshot.value as Map));
      _sessionCache[sessionId] = session;

      // A member observes completion here (their own device is the only place
      // that can credit them — see completeSession).
      unawaited(_claimCompletionPointsIfFinished(session));

      return session;
    } catch (e) {
      debugPrint('SessionService: Error getting session: $e');
      return _sessionCache[sessionId];
    }
  }

  /// Get sessions the current user belongs to
  Future<List<SharedSession>> getUserSessions() async {
    try {
      await _ensureInitialized();

      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) return [];
      if (!_isFirebaseAvailable || _database == null) return [];

      final snapshot = await _onDatabase(
        () => _database!.ref('users/$userId/sessions').get(),
      );
      if (!snapshot.exists) return [];

      final sessionIds =
          (snapshot.value as Map?)?.keys.cast<String>() ?? [];

      // Fetch every session concurrently instead of awaiting them one by one
      // (the previous N+1 sequential loop). `getSession` already swallows its
      // own errors and returns null, so `whereType` is enough to drop misses.
      final fetched = await Future.wait(
        sessionIds.map((id) => getSession(id)),
      );

      return fetched
          .whereType<SharedSession>()
          .where((session) => session.isActive)
          .toList();
    } catch (e) {
      debugPrint('SessionService: Error getting user sessions: $e');
      return [];
    }
  }

  /// Get public sessions (for join-by-browse)
  Future<List<Map<String, dynamic>>> getPublicSessions({int limit = 30}) async {
    try {
      await _ensureInitialized();

      if (!_isFirebaseAvailable || _database == null) return [];

      final snapshot = await _onDatabase(
        () => _database!.ref('publicSessions').limitToFirst(limit).get(),
      );
      if (!snapshot.exists) return [];

      final raw = Map<String, dynamic>.from(snapshot.value as Map);
      final sessions = raw.entries.map((e) {
        final data = Map<String, dynamic>.from(e.value as Map);
        data['id'] = e.key;
        return data;
      }).toList();

      // `publicSessions/{id}` only holds what was written when the session was
      // created — the rules let nobody but the owner write that node, so it
      // cannot track members joining and leaving, and a session created before
      // the member cap existed carries no usable `maxMembers` at all. Normalize
      // the cap first so every card has a denominator, then overwrite both
      // fields from the session itself.
      for (final entry in sessions) {
        entry['maxMembers'] = SessionLimits.normalizeMaxMembers(
          _asIntOrNull(entry['maxMembers']),
        );
      }
      await Future.wait(sessions.map(_attachLiveCapacity));
      return sessions;
    } catch (e) {
      debugPrint('SessionService: Error getting public sessions: $e');
      return [];
    }
  }

  /// Overwrites an entry's `memberCount` and `maxMembers` with the values read
  /// from `sessions/{id}`.
  ///
  /// One read of the session supplies both, so this costs the same round trip
  /// the member-count lookup used to. If it fails the entry keeps the
  /// normalized cap it was given and its last known count — exactly what the
  /// card rendered before this read existed.
  Future<void> _attachLiveCapacity(Map<String, dynamic> entry) async {
    final sessionId = entry['id'] as String?;
    if (sessionId == null || _database == null) return;

    try {
      final snapshot = await _database!
          .ref('sessions/$sessionId')
          .get()
          .timeout(_networkTimeout);
      final value = snapshot.value;
      if (value is! Map) return;

      final session = SharedSession.fromMap(Map<String, dynamic>.from(value));
      entry['memberCount'] = session.memberCount;
      entry['maxMembers'] = session.maxMembers;
    } catch (e) {
      debugPrint('SessionService: capacity lookup failed for $sessionId: $e');
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

      await _onDatabase(
        () => _database!
            .ref('sessions/$sessionId/members/$userId')
            .update({
          'lastActive': DateTime.now().toIso8601String(),
          'isActive': true,
        }),
      );
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

            // Same completion handling as `getSession`: stop the now-pointless
            // heartbeat and let the member claim their own points.
            unawaited(_claimCompletionPointsIfFinished(session));

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

/// A shared-session failure whose message is already written for the user.
///
/// Thrown for the cases this service can describe precisely (unreachable
/// server, session not found, session full). Anything else — most importantly
/// Firebase's own `permission-denied` — propagates as-is so the UI layer can
/// recognise it and decide what to say.
class SessionException implements Exception {
  final String message;

  const SessionException(this.message);

  @override
  String toString() => message;
}
