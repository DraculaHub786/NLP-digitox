// Copyright (c) 2026 NLP digitox

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/models/session_member.dart';

/// Keeps "who is actually here" honest for a live session.
///
/// The previous approach — a 30-second heartbeat timer and nothing else — could
/// only ever *add* presence. A member whose phone died, whose app was killed, or
/// who simply walked out of signal stayed "Focused" on everyone else's screen
/// until something else happened to rewrite the node, because nothing was left
/// running to write the departure.
///
/// The Realtime Database solves this properly: `onDisconnect()` is registered
/// *with the server*, so the server writes the update itself when the socket
/// drops, no matter how the client dies. The heartbeat stays, but only as a
/// lower-frequency `lastSeen` refresh — the disconnect handler is what makes
/// "away" trustworthy.
class SessionPresenceService {
  SessionPresenceService._();

  static final SessionPresenceService instance = SessionPresenceService._();

  /// How often `lastSeen` is refreshed while connected.
  ///
  /// Deliberately slow. It no longer carries the "am I here?" signal — the
  /// server's disconnect handler does — so it only needs to keep the timestamp
  /// from looking stale, and a 45-second write per member is a fraction of the
  /// old 30-second one.
  static const Duration heartbeatInterval = Duration(seconds: 45);

  final Map<String, _PresenceBinding> _bindings = {};

  FirebaseDatabase? _database;

  /// Session ids currently being tracked.
  Iterable<String> get trackedSessions => _bindings.keys;

  /// Number of live presence bindings — surfaced in `SessionService.debugStatus`.
  int get activeCount => _bindings.length;

  /// Begins tracking presence for [sessionId].
  ///
  /// [status] is the state to publish immediately (and re-publish on every
  /// reconnect), so a member who reconnects mid-run comes back as "focusing"
  /// rather than silently dropping to "joined".
  ///
  /// Safe to call twice for the same session: the second call only updates the
  /// desired status, leaving the single registered disconnect handler intact.
  Future<void> attach({
    required String sessionId,
    MemberStatus status = MemberStatus.joined,
  }) async {
    final existing = _bindings[sessionId];
    if (existing != null) {
      existing.desiredStatus = status;
      return;
    }

    final database = _database ??= _tryDatabase();
    if (database == null) return;

    final userId = FirebaseAuthService.instance.userId;
    if (userId == null) return;

    final binding = _PresenceBinding(sessionId: sessionId, status: status);
    _bindings[sessionId] = binding;

    final memberRef = database.ref('sessions/$sessionId/members/$userId');

    binding.connectionSubscription =
        database.ref('.info/connected').onValue.listen((event) async {
      // `.info/connected` is a local value, so this fires once per connection
      // change: on the first connect, and again after any drop/reconnect.
      if (event.snapshot.value != true) return;

      try {
        // Register the departure *before* announcing the arrival. If the socket
        // dies between the two writes, the server already has an instruction
        // for it; the other order can lose the member silently.
        await memberRef.onDisconnect().update({
          'status': MemberStatus.away.wireName,
          'isActive': false,
          // The server stamps this itself — no client clock involved.
          'lastActive': ServerValue.timestamp,
        });

        await memberRef.update({
          'status': binding.desiredStatus.wireName,
          'isActive': binding.desiredStatus.isPresent,
          'lastActive': ServerValue.timestamp,
        });
      } catch (e) {
        debugPrint('SessionPresenceService: connect handler failed: $e');
      }
    });

    binding.heartbeat = Timer.periodic(heartbeatInterval, (_) {
      if (binding.desiredStatus == MemberStatus.left) return;
      memberRef.update({
        'lastActive': ServerValue.timestamp,
        'status': binding.desiredStatus.wireName,
        'isActive': binding.desiredStatus.isPresent,
      }).catchError((Object e) {
        debugPrint('SessionPresenceService: heartbeat failed: $e');
        return null;
      });
    });
  }

  /// Publishes a new status for a tracked session.
  ///
  /// Writes immediately rather than waiting for the next heartbeat: marking
  /// yourself ready has to be visible to the host on their next tap, and going
  /// "focusing" is the signal the rest of the room reads.
  Future<void> setStatus({
    required String sessionId,
    required MemberStatus status,
  }) async {
    final binding = _bindings[sessionId];
    if (binding != null) binding.desiredStatus = status;

    final database = _database;
    final userId = FirebaseAuthService.instance.userId;
    if (database == null || userId == null) return;

    try {
      await database.ref('sessions/$sessionId/members/$userId').update({
        'status': status.wireName,
        'isActive': status.isPresent,
        'lastActive': ServerValue.timestamp,
        // A member who has come back is no longer "having left".
        if (status != MemberStatus.left) 'leftAt': null,
      });
    } catch (e) {
      debugPrint('SessionPresenceService: setStatus failed: $e');
    }
  }

  /// Stops tracking [sessionId], cancelling the disconnect handler.
  ///
  /// Cancelling matters: leaving it registered would make the server mark the
  /// member "away" the moment they closed the app, overwriting a deliberate
  /// `left`/`completed` write.
  Future<void> detach(String sessionId) async {
    final binding = _bindings.remove(sessionId);
    if (binding == null) return;

    await binding.connectionSubscription?.cancel();
    binding.heartbeat?.cancel();

    final database = _database;
    final userId = FirebaseAuthService.instance.userId;
    if (database == null || userId == null) return;

    try {
      await database
          .ref('sessions/$sessionId/members/$userId')
          .onDisconnect()
          .cancel();
    } catch (e) {
      debugPrint('SessionPresenceService: could not cancel onDisconnect: $e');
    }
  }

  /// Stops tracking everything — used on sign-out and by tests.
  Future<void> detachAll() async {
    for (final sessionId in _bindings.keys.toList()) {
      await detach(sessionId);
    }
  }

  FirebaseDatabase? _tryDatabase() {
    try {
      return FirebaseDatabase.instance;
    } catch (e) {
      debugPrint('SessionPresenceService: Firebase unavailable: $e');
      return null;
    }
  }
}

/// One session's live presence bookkeeping.
class _PresenceBinding {
  _PresenceBinding({required this.sessionId, required this.status});

  final String sessionId;
  MemberStatus status;

  StreamSubscription<DatabaseEvent>? connectionSubscription;
  Timer? heartbeat;

  MemberStatus get desiredStatus => status;

  set desiredStatus(MemberStatus value) => status = value;
}
