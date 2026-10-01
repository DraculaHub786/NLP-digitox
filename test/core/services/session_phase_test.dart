// Copyright (c) 2026 NLP digitox
//
// Tests for phase derivation (plan Section 8: "phase derivation"). The phase is
// never stored — it is computed from the persisted `state` plus a server clock
// reading, which is what lets two phones with different wall clocks agree on
// whether a run is counting down, running, or over. These tests drive that
// function directly rather than through the UI, so the boundary conditions
// (exactly at start, exactly at end, open-ended runs) are pinned down.

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/enums/session_phase.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';

/// A fixed instant, in ms, so every expectation is exact.
const int baseMs = 1700000000000;

/// A session whose run starts [countdownSec] after the host tapped Start and
/// lasts [durationSec], with the host having tapped Start at [baseMs].
SharedSession sessionStarting({
  int countdownSec = 10,
  int durationSec = 60,
  DateTime? runStartAt,
  DateTime? completedAt,
  SharedSessionState state = SharedSessionState.lobby,
}) =>
    SharedSession(
      id: 'session-1',
      name: 'Deep work',
      ownerId: 'owner-1',
      createdAt: DateTime.fromMillisecondsSinceEpoch(baseMs - 60000),
      countdownSec: countdownSec,
      durationSec: durationSec,
      state: state,
      runStartAt: runStartAt ?? DateTime.fromMillisecondsSinceEpoch(baseMs),
      completedAt: completedAt,
    );

void main() {
  group('phaseAt — lobby', () {
    test('a session that never started is in the lobby', () {
      final session = SharedSession(
        id: 's',
        name: 'n',
        ownerId: 'o',
        createdAt: DateTime.fromMillisecondsSinceEpoch(baseMs),
      );
      expect(session.runStartAt, isNull);
      expect(session.phaseAt(baseMs), equals(SessionPhase.lobby));
      expect(session.phaseAt(baseMs + 999999), equals(SessionPhase.lobby));
    });
  });

  group('phaseAt — countdown', () {
    test('before the effective start the session is counting down', () {
      final session = sessionStarting();
      expect(session.phaseAt(baseMs), equals(SessionPhase.countdown));
      expect(session.phaseAt(baseMs + 9999), equals(SessionPhase.countdown));
    });

    test('exactly at the effective start the run has begun', () {
      // startEffective = runStartAt + countdown; the boundary is inclusive on
      // the running side, because `serverNowMs < startMs` is false here.
      final session = sessionStarting();
      expect(session.phaseAt(baseMs + 10000), equals(SessionPhase.running));
    });

    test('countdownRemainingSecAt counts down and is null once started', () {
      final session = sessionStarting(countdownSec: 10);
      expect(session.countdownRemainingSecAt(baseMs), equals(10));
      expect(session.countdownRemainingSecAt(baseMs + 1000), equals(9));
      expect(session.countdownRemainingSecAt(baseMs + 10000), isNull);
      expect(session.countdownRemainingSecAt(baseMs + 20000), isNull);
    });
  });

  group('phaseAt — running', () {
    test('between start and end the session is running', () {
      final session = sessionStarting();
      expect(session.phaseAt(baseMs + 10000), equals(SessionPhase.running));
      expect(session.phaseAt(baseMs + 40000), equals(SessionPhase.running));
    });

    test('remainingSecAt reports seconds left, and zero at the end', () {
      final session = sessionStarting();
      // endAt = base + 10s countdown + 60s duration = base + 70000ms
      expect(session.remainingSecAt(baseMs + 50000), equals(20));
      expect(session.remainingSecAt(baseMs + 70000), equals(0));
      expect(session.remainingSecAt(baseMs + 90000), equals(0));
    });
  });

  group('phaseAt — finished', () {
    test('exactly at endAt the run is finished', () {
      final session = sessionStarting();
      expect(session.phaseAt(baseMs + 70000), equals(SessionPhase.finished));
    });

    test('after endAt the run stays finished', () {
      final session = sessionStarting();
      expect(session.phaseAt(baseMs + 1000000), equals(SessionPhase.finished));
    });
  });

  group('phaseAt — open-ended runs', () {
    test('a zero duration never reaches finished by time alone', () {
      // durationSec == 0 means open-ended, so endAt is null and the run keeps
      // going until something else ends it.
      final session = sessionStarting(durationSec: 0);
      expect(session.endAt, isNull);
      expect(session.phaseAt(baseMs + 10000), equals(SessionPhase.running));
      expect(session.phaseAt(baseMs + 99999999), equals(SessionPhase.running));
    });
  });

  group('phaseAt — terminal states win', () {
    test('cancelled beats every clock reading', () {
      final session = sessionStarting(state: SharedSessionState.cancelled);
      expect(session.phaseAt(baseMs), equals(SessionPhase.cancelled));
      expect(session.phaseAt(baseMs + 40000), equals(SessionPhase.cancelled));
      expect(session.phaseAt(baseMs + 1000000), equals(SessionPhase.cancelled));
    });

    test('a hand-completed session is finished even if it never ran', () {
      final session = SharedSession(
        id: 's',
        name: 'n',
        ownerId: 'o',
        createdAt: DateTime.fromMillisecondsSinceEpoch(baseMs),
        completedAt: DateTime.fromMillisecondsSinceEpoch(baseMs + 5000),
      );
      expect(session.runStartAt, isNull);
      expect(session.phaseAt(baseMs), equals(SessionPhase.finished));
    });
  });

  group('SessionPhase derived getters', () {
    test('hasStarted covers countdown, running and finished only', () {
      expect(SessionPhase.lobby.hasStarted, isFalse);
      expect(SessionPhase.cancelled.hasStarted, isFalse);
      expect(SessionPhase.countdown.hasStarted, isTrue);
      expect(SessionPhase.running.hasStarted, isTrue);
      expect(SessionPhase.finished.hasStarted, isTrue);
    });

    test('shouldBlockApps is true only while running', () {
      for (final phase in SessionPhase.values) {
        expect(phase.shouldBlockApps, equals(phase == SessionPhase.running));
      }
    });

    test('isOver covers finished and cancelled only', () {
      expect(SessionPhase.finished.isOver, isTrue);
      expect(SessionPhase.cancelled.isOver, isTrue);
      expect(SessionPhase.lobby.isOver, isFalse);
      expect(SessionPhase.countdown.isOver, isFalse);
      expect(SessionPhase.running.isOver, isFalse);
    });

    test('every phase has a non-empty label', () {
      for (final phase in SessionPhase.values) {
        expect(phase.label, isNotEmpty);
      }
    });
  });

  group('startEffective / endAt', () {
    test('startEffective is runStartAt plus the countdown', () {
      final session = sessionStarting(countdownSec: 10);
      expect(
        session.startEffective?.millisecondsSinceEpoch,
        equals(baseMs + 10000),
      );
    });

    test('endAt is startEffective plus the duration', () {
      final session = sessionStarting(countdownSec: 10, durationSec: 60);
      expect(session.endAt?.millisecondsSinceEpoch, equals(baseMs + 70000));
    });

    test('both are null without a run start', () {
      final session = SharedSession(
        id: 's',
        name: 'n',
        ownerId: 'o',
        createdAt: DateTime.fromMillisecondsSinceEpoch(baseMs),
      );
      expect(session.startEffective, isNull);
      expect(session.startEffectiveMs, isNull);
      expect(session.endAt, isNull);
      expect(session.endAtMs, isNull);
    });

    test('totalSpanMs is countdown plus duration', () {
      final session = sessionStarting(countdownSec: 10, durationSec: 60);
      expect(session.totalSpanMs, equals(70000));
    });
  });
}
