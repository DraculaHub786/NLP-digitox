// Copyright (c) 2026 NLP digitox

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

/// The one source of "now" for every shared-session timer.
///
/// The whole synchronised-session design rests on this: the host writes a single
/// server timestamp when they tap Start, and every device — including the
/// host's own — works out how much time is left from *that* value rather than
/// from its own wall clock. Two phones whose clocks differ by five minutes would
/// otherwise start and finish the same run minutes apart, and no amount of
/// re-reading the database would fix it, because the disagreement is in the
/// clock rather than in the data.
///
/// The Realtime Database publishes the correction to apply at
/// `.info/serverTimeOffset`, which is exactly the value Firebase's own
/// `ServerValue.timestamp` is built on. Reading it once is enough — it does not
/// drift — but the socket can drop, so this re-subscribes whenever the
/// connection comes back.
///
/// Before any offset has arrived, [nowMs] returns the local clock. That is
/// deliberate: a lobby that has not yet synchronised should still render
/// something sane, and every phase that matters (running, finished) can only be
/// reached after a session read that itself required the connection.
class SessionClock {
  SessionClock({
    FirebaseDatabase? database,
    DateTime Function()? localNow,
    this.tickInterval = const Duration(seconds: 1),
  })  : _database = database,
        _localNow = localNow ?? DateTime.now;

  /// Shared instance used by the app.
  static final SessionClock instance = SessionClock();

  /// Builds a clock with a fixed offset, for tests.
  ///
  /// No database, no timer: the offset is whatever the test says it is, which is
  /// the only way to test "both devices agree" deterministically.
  factory SessionClock.forTest({
    required int offsetMs,
    DateTime Function()? localNow,
  }) =>
      SessionClock(localNow: localNow).._setOffset(offsetMs);

  FirebaseDatabase? _database;
  final DateTime Function() _localNow;

  /// How often [ticks] emits.
  final Duration tickInterval;

  StreamSubscription<DatabaseEvent>? _offsetSubscription;
  Timer? _ticker;

  int _offsetMs = 0;
  bool _isSynchronized = false;
  bool _isStarted = false;

  /// Milliseconds to add to the local clock to get server time.
  int get offsetMs => _offsetMs;

  /// Whether a server offset has actually been received.
  bool get isSynchronized => _isSynchronized;

  /// Server time, in milliseconds since the epoch.
  int nowMs() => _localNow().millisecondsSinceEpoch + _offsetMs;

  /// Server time as a [DateTime].
  DateTime now() => DateTime.fromMillisecondsSinceEpoch(nowMs());

  /// Begins tracking `.info/serverTimeOffset`.
  ///
  /// Safe to call repeatedly; the second call is a no-op.
  void start() {
    if (_isStarted) return;
    _isStarted = true;

    final database = _database ??= _tryDatabase();
    if (database == null) {
      debugPrint('SessionClock: Realtime Database unavailable');
      return;
    }

    _offsetSubscription = database.ref('.info/serverTimeOffset').onValue.listen(
      (event) {
        final value = event.snapshot.value;
        if (value is num) _setOffset(value.toInt());
      },
      onError: (Object error) {
        // Losing the offset does not invalidate a run already in progress: the
        // last known offset stays applied rather than snapping back to the
        // unsynchronised local clock mid-session.
        debugPrint('SessionClock: offset stream error: $error');
      },
    );
  }

  /// Stops tracking. The last known offset is kept.
  Future<void> stop() async {
    _isStarted = false;
    _ticker?.cancel();
    _ticker = null;
    await _offsetSubscription?.cancel();
    _offsetSubscription = null;
  }

  /// A one-second stream of server time, for ticking a countdown.
  ///
  /// Emits immediately so a freshly built screen shows the right value without
  /// waiting a full second for the first frame.
  Stream<int> ticks() async* {
    yield nowMs();
    yield* Stream.periodic(tickInterval, (_) => nowMs());
  }

  void _setOffset(int offsetMs) {
    _offsetMs = offsetMs;
    _isSynchronized = true;
  }

  FirebaseDatabase? _tryDatabase() {
    try {
      return FirebaseDatabase.instance;
    } catch (e) {
      debugPrint('SessionClock: could not reach Firebase: $e');
      return null;
    }
  }

  /// Overrides the offset — for tests and for the settings diagnostics screen.
  @visibleForTesting
  void debugSetOffsetMs(int offsetMs) => _setOffset(offsetMs);

  @override
  String toString() =>
      'SessionClock(offset: ${_offsetMs}ms, synced: $_isSynchronized)';
}
