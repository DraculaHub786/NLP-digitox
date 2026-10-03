
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:nlp_digitox/core/constants/session_limits.dart';
import 'package:nlp_digitox/core/services/device_identity.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/session_focus_bridge.dart';
import 'package:nlp_digitox/core/services/session_presence_service.dart';
import 'package:nlp_digitox/core/utils/invite_code.dart';
import 'package:nlp_digitox/models/session_result.dart';
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

  /// Sessions this instance is currently tracking presence for.
  ///
  /// The 30-second timer that used to live here is gone — see
  /// [startPresenceHeartbeat]. This set survives only so the call stays
  /// idempotent and [debugStatus] can still report a count.
  final Set<String> _presenceSessions = {};

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
    String type = 'study',
    int? durationSec,
    int countdownSec = SessionLimits.defaultCountdownSec,
    SessionVisibility? visibility,
    String? groupId,
    String? hostDisplayName,
    String? hostPhotoUrl,
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

      // The host's own member record. Role and status are set explicitly here
      // rather than left at their defaults, because every later write in this
      // service treats `host` as the authority for Start/Cancel/Kick.
      final ownerMember = SessionMember(
        userId: userId,
        deviceId: deviceId,
        displayName: hostDisplayName?.trim().isNotEmpty == true
            ? hostDisplayName!.trim()
            : 'You',
        photoUrl: hostPhotoUrl,
        role: MemberRole.host,
        status: MemberStatus.joined,
        joinedAt: now,
        isActive: true,
        lastActive: now,
      );

      // A 6-character code drawn from an unambiguous alphabet, so it can be read
      // aloud across a room. Only written when RTDB is reachable — an offline
      // create stays a local-only session with no code rather than a permanent
      // invite pointing at nothing.
      final inviteCode = InviteCode.generate();

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
        visibility: visibility ??
            (isPublic ? SessionVisibility.public : SessionVisibility.invite),
        type: type,
        durationSec: SessionLimits.normalizeDurationSec(durationSec),
        countdownSec: countdownSec.clamp(
          SessionLimits.minCountdownSec,
          SessionLimits.maxCountdownSec,
        ),
        groupId: groupId,
        inviteCode: inviteCode,
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
          // The invite goes in the same atomic write as the session: a code
          // that points at a session which was never created is worse than no
          // code at all, because it fails silently for whoever receives it.
          'invites/$inviteCode': {
            'sid': sessionId,
            // `hostUid` is what `database.rules.json` checks to decide whether
            // this create is allowed. It reads the invite itself rather than
            // the session, because the session does not exist yet in the rule's
            // view of the data — it is being written in this same update.
            'hostUid': userId,
            'title': name,
            'type': type,
            'durationSec': session.durationSec,
            'hostName': ownerMember.displayName,
            'createdAt': now.toIso8601String(),
            'expiresAt': now.add(InviteCode.lifetime).toIso8601String(),
          },
          if (isPublic)
            'publicSessions/$sessionId': _withoutNulls({
              // Same reason as the invite: the public-index write is authorised
              // by `hostUid` on the entry itself, so a stranger cannot create
              // or overwrite a public listing for a session they do not own.
              'hostUid': userId,
              'name': name,
              'theme': theme,
              'memberCount': 1,
              'maxMembers': memberCap,
              'type': type,
              'durationSec': session.durationSec,
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
        } else if (!session.isPublic) {
          // A bare session ID is only a join key for a *public* session. For a
          // private or invite-only room the ID is discoverable (it is the push
          // key in the session's own URL), so accepting it here would let in
          // anyone who ever saw the ID once. The rules enforce the same
          // condition server-side; this is the message the user actually sees.
          throw const SessionException(
            'This session is private. Join it with the invite code or link '
            'the host shared.',
          );
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
  Future<SharedSession> completeSession({required String sessionId}) async {
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

      // Ask the server to verify and pay every member — the owner included.
      // The client writes no points for this: `SessionCompletionService` posts
      // the session id and an ID token, and the workflow decides.
      unawaited(SessionFocusBridge.instance.completeRun(completed));

      debugPrint('SessionService: Completed session $sessionId');
      return completed;
    } catch (e) {
      debugPrint('SessionService: Error completing session: $e');
      rethrow;
    }
  }

  /// Reports [session] to the server for verification if the signed-in member
  /// finished it.
  ///
  /// Safe to call repeatedly — `SessionFocusBridge.completeRun` de-dupes per
  /// session per launch, and the webhook de-dupes per `sid + uid`. This is the
  /// path a non-owner member takes: they cannot write points for themselves in
  /// this design, so they ask the server to check the run and credit them.
  Future<void> _claimCompletionPointsIfFinished(SharedSession session) async {
    try {
      final userId = FirebaseAuthService.instance.userId;
      if (userId == null) return;

      // Only a genuine completion triggers a report, and only for members
      // still on the session. A session also goes inactive when its owner
      // merely leaves it, which must not report anything — see
      // SharedSession.isEligibleForCompletionPayout.
      if (!session.isEligibleForCompletionPayout(userId)) return;

      _stopPresenceHeartbeat(session.id);

      unawaited(SessionFocusBridge.instance.completeRun(session));
    } catch (e) {
      debugPrint('SessionService: Error reporting completion: $e');
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

  /// Starts presence tracking for a session.
  ///
  /// This used to own a 30-second `Timer.periodic`. Presence is now the job of
  /// [SessionPresenceService], which registers an `onDisconnect` handler *with
  /// the server* — the only mechanism that can write a departure when the app is
  /// killed rather than closed. The set here is kept so the call stays
  /// idempotent and [debugStatus] can still report how many sessions are being
  /// tracked.
  void startPresenceHeartbeat(String sessionId) {
    if (!_presenceSessions.add(sessionId)) return;
    unawaited(SessionPresenceService.instance.attach(sessionId: sessionId));
    debugPrint('SessionService: Started presence tracking for $sessionId');
  }

  /// Stops presence tracking for a session.
  void _stopPresenceHeartbeat(String sessionId) {
    if (!_presenceSessions.remove(sessionId)) return;
    unawaited(SessionPresenceService.instance.detach(sessionId));
    debugPrint('SessionService: Stopped presence tracking for $sessionId');
  }

  /// Publishes this member's status to the room.
  ///
  /// Used for `ready` and `focusing`, the two states the rest of the room acts
  /// on. Writes immediately instead of waiting for a heartbeat, because a host
  /// deciding whether to start should see a ready member right away.
  Future<void> setMemberStatus({
    required String sessionId,
    required MemberStatus status,
  }) async {
    await SessionPresenceService.instance.setStatus(
      sessionId: sessionId,
      status: status,
    );
  }

  // ---------------------------------------------------------------------------
  // Lobby lifecycle
  // ---------------------------------------------------------------------------

  /// Resolves an invite code to the session it names.
  ///
  /// Throws a user-readable [SessionException] for every failure — unknown,
  /// expired, or pointing at a session that has since gone — because the caller
  /// is always a screen showing a message, never code that can branch on it.
  Future<String> resolveInviteCode(String rawCode) async {
    await _ensureInitialized();

    final code = InviteCode.normalize(rawCode);
    if (!InviteCode.isValid(code)) {
      throw const SessionException(
        'That does not look like an invite code. Codes are '
        '${InviteCode.length} characters, like AB3K7Q.',
      );
    }

    if (!_isFirebaseAvailable || _database == null) {
      throw const SessionException(
        'Could not reach the server to check that invite. Try again once you '
        'are back online.',
      );
    }

    final snapshot = await _onDatabase(
      () => _database!.ref('invites/$code').get(),
    );
    if (!snapshot.exists || snapshot.value is! Map) {
      throw const SessionException(
        'That invite code is not valid any more. Ask for a fresh one.',
      );
    }

    final invite = Map<String, dynamic>.from(snapshot.value as Map);
    final sessionId = invite['sid'] as String?;
    if (sessionId == null || sessionId.isEmpty) {
      throw const SessionException(
        'That invite is damaged and cannot be used. Ask for a new code.',
      );
    }

    // Expiry is checked here as well as by the cleanup job: a code can be
    // scanned seconds after the cron ran, and the user deserves the real reason
    // rather than "session not found".
    final expiresAt = invite['expiresAt'];
    if (expiresAt is String) {
      final expiry = DateTime.tryParse(expiresAt);
      if (expiry != null && DateTime.now().isAfter(expiry)) {
        throw const SessionException(
          'That invite has expired. Ask the host to share a new one.',
        );
      }
    }

    return sessionId;
  }

  /// Joins the session named by [rawCode].
  ///
  /// Returns the session id so the caller can navigate to its lobby.
  Future<String> joinByCode({
    required String rawCode,
    required String displayName,
    String? photoUrl,
  }) async {
    final sessionId = await resolveInviteCode(rawCode);
    await _joinAsMember(
      sessionId: sessionId,
      displayName: displayName,
      photoUrl: photoUrl,
      // Stamped on the member node so the rules can verify the join came
      // through a code that actually points at this session.
      code: InviteCode.normalize(rawCode),
    );
    return sessionId;
  }

  /// Shared implementation behind [joinSession] and [joinByCode].
  ///
  /// Both paths must enforce exactly the same things — lobby-only, capacity,
  /// idempotent re-entry — so they share one write rather than two that could
  /// drift apart. [code] is null for a plain ID join, which is what the rules
  /// expect for a session the user was handed the ID of directly.
  Future<void> _joinAsMember({
    required String sessionId,
    required String displayName,
    String? photoUrl,
    String? code,
  }) async {
    await _ensureInitialized();

    final userId = FirebaseAuthService.instance.userId;
    if (userId == null) throw StateError('User not authenticated');
    if (displayName.trim().isEmpty) {
      throw ArgumentError('Display name cannot be empty');
    }

    if (!_isFirebaseAvailable || _database == null) {
      throw const SessionException(
        'Could not reach the server to join. Check your connection and try '
        'again.',
      );
    }

    final sessionSnap = await _onDatabase(
      () => _database!.ref('sessions/$sessionId').get(),
    );

    if (!sessionSnap.exists || sessionSnap.value is! Map) {
      throw const SessionException(
        'This session no longer exists. The host may have ended it.',
      );
    }

    final session = SharedSession.fromMap(
      Map<String, dynamic>.from(sessionSnap.value as Map),
    );

    if (session.isCompleted || !session.isActive || session.isCancelled) {
      throw const SessionException(
        'This session has already finished, so you can no longer join it.',
      );
    }

    // Joining mid-run is out of scope for v1: the latecomer would be dropped
    // into a timer whose start they never saw, and the completion rule would
    // reject them anyway. Say so plainly rather than letting them in to fail.
    if (!session.isLobby) {
      throw const SessionException(
        'This session has already started. Ask the host to run another one.',
      );
    }

    if (session.members.any((m) => m.userId == userId)) {
      // Already in — treat it as a re-entry so a reinstall or a cold start
      // lands the user back in the room instead of erroring.
      startPresenceHeartbeat(sessionId);
      return;
    }

    if (session.isFull) {
      throw SessionException(SessionLimits.fullSessionMessage);
    }

    final now = DateTime.now();
    final member = SessionMember(
      userId: userId,
      deviceId: DeviceIdentityService.instance.deviceId,
      displayName: displayName.trim(),
      photoUrl: photoUrl,
      role: MemberRole.member,
      status: MemberStatus.joined,
      joinedAt: now,
      isActive: true,
      lastActive: now,
      code: code,
    );

    try {
      await _onDatabase(
        () => _database!.ref().update({
          'sessions/$sessionId/members/$userId': member.toMap(),
          'users/$userId/sessions/$sessionId': true,
        }),
      );
    } catch (error) {
      throw await _translateJoinFailure(sessionId, error);
    }

    startPresenceHeartbeat(sessionId);
    debugPrint('SessionService: Joined session $sessionId');
  }

  /// Marks the signed-in member ready (or not) in the lobby.
  Future<void> setReady({
    required String sessionId,
    required bool ready,
  }) async {
    await setMemberStatus(
      sessionId: sessionId,
      status: ready ? MemberStatus.ready : MemberStatus.joined,
    );
  }

  /// Starts the synchronised run. Host only.
  ///
  /// This is the single write the whole synchronisation rests on: one server
  /// timestamp, and every device derives the same countdown and the same end
  /// time from it. Nothing else is written at start, so nothing can disagree.
  Future<void> startSession({
    required String sessionId,
    int? durationSec,
  }) async {
    await _ensureInitialized();

    final userId = FirebaseAuthService.instance.userId;
    if (userId == null) throw StateError('User not authenticated');
    if (!_isFirebaseAvailable || _database == null) {
      throw const SessionException(
        'Could not reach the server to start. Check your connection and try '
        'again.',
      );
    }

    final session = await getSession(sessionId);
    if (session == null) {
      throw const SessionException('This session no longer exists.');
    }
    if (!session.isOwnedBy(userId)) {
      throw const SessionException('Only the host can start this session.');
    }
    if (!session.isLobby) {
      // Already running or finished — starting again would move the start time
      // under everyone's feet and desynchronise the room.
      debugPrint('SessionService: $sessionId is not in a lobby; ignoring start');
      return;
    }

    await _onDatabase(
      () => _database!.ref('sessions/$sessionId').update({
        'state': SharedSessionState.running.wireName,
        // Resolved by the server, never by this device's clock.
        'runStartAt': ServerValue.timestamp,
        if (durationSec != null)
          'durationSec': SessionLimits.normalizeDurationSec(durationSec),
      }),
    );

    _stopPresenceHeartbeat(sessionId);
    unawaited(
      SessionPresenceService.instance.setStatus(
        sessionId: sessionId,
        status: MemberStatus.focusing,
      ),
    );

    debugPrint('SessionService: Started session $sessionId');
  }

  /// Cancels a session before it finishes. Host only.
  Future<void> cancelSession({required String sessionId}) async {
    await _ensureInitialized();

    final userId = FirebaseAuthService.instance.userId;
    if (userId == null) throw StateError('User not authenticated');
    if (!_isFirebaseAvailable || _database == null) return;

    final session = await getSession(sessionId);
    if (session == null) return;
    if (!session.isOwnedBy(userId)) {
      throw const SessionException('Only the host can cancel this session.');
    }

    final code = session.inviteCode;
    await _onDatabase(
      () => _database!.ref().update({
        'sessions/$sessionId/state': SharedSessionState.cancelled.wireName,
        'sessions/$sessionId/isActive': false,
        if (session.isPublic) 'publicSessions/$sessionId': null,
        // A cancelled session's code must stop working immediately, or someone
        // who was sent it lands in a room that no longer runs.
        if (code != null) 'invites/$code': null,
      }),
    );

    _stopPresenceHeartbeat(sessionId);
    _sessionCache.remove(sessionId);
    debugPrint('SessionService: Cancelled session $sessionId');
  }

  /// Records that the signed-in member broke focus by stopping early.
  ///
  /// Incremented rather than set, so two breaks in one run add up instead of
  /// overwriting each other. Past [SessionLimits.maxBreaksPerRun] the member is
  /// no longer credited — the completion webhook enforces the same ceiling.
  Future<void> reportBreak({required String sessionId}) async {
    await _ensureInitialized();

    final userId = FirebaseAuthService.instance.userId;
    if (userId == null || !_isFirebaseAvailable || _database == null) return;

    try {
      await _onDatabase(
        () => _database!
            .ref('sessions/$sessionId/members/$userId/breaks')
            .runTransaction((current) {
          final value = current;
          final count = value is int ? value : 0;
          return Transaction.success(count + 1);
        }),
      );
      debugPrint('SessionService: Recorded focus break in $sessionId');
    } catch (e) {
      // A break that fails to record is not worth failing the run over: the
      // completion check also requires the run to have reached its end.
      debugPrint('SessionService: could not record break: $e');
    }
  }

  /// Marks the signed-in member's run complete. Called at `endAt`.
  ///
  /// The timestamp is the server's, and `database.rules.json` rejects it before
  /// the run's own end time — so a member cannot claim completion early by
  /// editing the client.
  Future<void> markCompleted({required String sessionId}) async {
    await _ensureInitialized();

    final userId = FirebaseAuthService.instance.userId;
    if (userId == null || !_isFirebaseAvailable || _database == null) return;

    try {
      await _onDatabase(
        () => _database!.ref('sessions/$sessionId/members/$userId').update({
          'completedAt': ServerValue.timestamp,
          'status': MemberStatus.focusing.wireName,
          'isActive': true,
        }),
      );
      debugPrint('SessionService: Marked completion in $sessionId');
    } catch (e) {
      debugPrint('SessionService: could not mark completion: $e');
    }
  }

  /// Removes another member from the lobby. Host only.
  Future<void> kickMember({
    required String sessionId,
    required String memberId,
  }) async {
    await _ensureInitialized();

    final userId = FirebaseAuthService.instance.userId;
    if (userId == null) throw StateError('User not authenticated');
    if (!_isFirebaseAvailable || _database == null) return;

    final session = await getSession(sessionId);
    if (session == null) return;
    if (!session.isOwnedBy(userId)) {
      throw const SessionException('Only the host can remove a member.');
    }
    if (memberId == userId) {
      throw const SessionException(
        'The host cannot remove themselves — cancel the session instead.',
      );
    }

    await _onDatabase(
      () => _database!.ref().update({
        'sessions/$sessionId/members/$memberId': null,
        'users/$memberId/sessions/$sessionId': null,
      }),
    );
    debugPrint('SessionService: Kicked $memberId from $sessionId');
  }

  /// Deletes the invite code for a session this user owns.
  Future<void> revokeInvite(String rawCode) async {
    await _ensureInitialized();
    if (!_isFirebaseAvailable || _database == null) return;

    final code = InviteCode.normalize(rawCode);
    if (!InviteCode.isValid(code)) return;

    final sid = await getSession(await resolveInviteCode(code));
    final userId = FirebaseAuthService.instance.userId;
    if (sid == null || userId == null || !sid.isOwnedBy(userId)) return;

    await _onDatabase(() => _database!.ref('invites/$code').remove());
  }

  // ---------------------------------------------------------------------------
  // Results
  // ---------------------------------------------------------------------------

  /// Reads the verified result for one member, if the webhook has written it.
  Future<SessionResult?> getResult({
    required String sessionId,
    required String userId,
  }) async {
    await _ensureInitialized();
    if (!_isFirebaseAvailable || _database == null) return null;

    try {
      final snapshot = await _onDatabase(
        () => _database!.ref('sessionResults/$sessionId/$userId').get(),
      );
      if (!snapshot.exists || snapshot.value is! Map) return null;
      return SessionResult.fromMap(
        Map<String, dynamic>.from(snapshot.value as Map),
        sessionId: sessionId,
        userId: userId,
      );
    } catch (e) {
      debugPrint('SessionService: could not read result: $e');
      return null;
    }
  }

  /// Reads every member's verified result for a session.
  Future<List<SessionResult>> getSessionResults(String sessionId) async {
    await _ensureInitialized();
    if (!_isFirebaseAvailable || _database == null) return const [];

    try {
      final snapshot = await _onDatabase(
        () => _database!.ref('sessionResults/$sessionId').get(),
      );
      return SessionResult.listFromSnapshot(
        snapshot.value,
        sessionId: sessionId,
      );
    } catch (e) {
      debugPrint('SessionService: could not read results: $e');
      return const [];
    }
  }

  // ---------------------------------------------------------------------------
  // Real-time listening
  // ---------------------------------------------------------------------------

  /// A live stream of one session, or `null` once it stops existing.
  ///
  /// Preferred over [listenToSession] on every new screen: it owns its own
  /// subscription lifetime, so an `autoDispose` provider cancelling the stream
  /// is all that is needed to release the Realtime Database listener.
  Stream<SharedSession?> watchSession(String sessionId) async* {
    await _ensureInitialized();
    if (!_isFirebaseAvailable || _database == null) {
      yield _sessionCache[sessionId];
      return;
    }

    yield* _database!.ref('sessions/$sessionId').onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value is! Map) {
        _sessionCache.remove(sessionId);
        return null;
      }
      try {
        final session = SharedSession.fromMap(
          Map<String, dynamic>.from(event.snapshot.value as Map),
        );
        _sessionCache[sessionId] = session;
        unawaited(_claimCompletionPointsIfFinished(session));
        return session;
      } catch (e) {
        debugPrint('SessionService: bad session snapshot for $sessionId: $e');
        return null;
      }
    });
  }

  /// A live stream of the member map for one session.
  Stream<List<SessionMember>> watchMembers(String sessionId) async* {
    await _ensureInitialized();
    if (!_isFirebaseAvailable || _database == null) {
      yield const [];
      return;
    }

    yield* _database!.ref('sessions/$sessionId/members').onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value is! Map) {
        return const <SessionMember>[];
      }
      final raw = Map<String, dynamic>.from(event.snapshot.value as Map);
      final members = <SessionMember>[];
      for (final entry in raw.entries) {
        final value = entry.value;
        if (value is! Map) continue;
        try {
          members.add(
            SessionMember.fromMap(
              Map<String, dynamic>.from(value),
              // `raw` is already a `Map<String, dynamic>`, so the key is
              // typed `String` and needs no cast.
              userId: entry.key,
            ),
          );
        } catch (e) {
          debugPrint('SessionService: bad member ${entry.key}: $e');
        }
      }
      return members;
    });
  }

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
      for (final sessionId in _presenceSessions.toList()) {
        unawaited(SessionPresenceService.instance.detach(sessionId));
      }
      _presenceSessions.clear();

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
      'heartbeats: ${_presenceSessions.length})';

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
