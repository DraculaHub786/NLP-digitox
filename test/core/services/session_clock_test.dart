// Copyright (c) 2026 NLP digitox
//
// Tests for the synchronised clock (plan Section 8: "SessionClock math with
// fake offsets"). The property under test is the one the whole shared-session
// design depends on: every device derives the same server time from the same
// offset, no matter what its own wall clock says. `SessionClock.forTest` takes
// a fixed offset and a fake local clock precisely so this can be asserted
// deterministically.

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/services/session_clock.dart';

/// A local clock frozen at [ms], as the local device believes it.
DateTime Function() localClockAt(int ms) =>
    () => DateTime.fromMillisecondsSinceEpoch(ms);

void main() {
  group('offset arithmetic', () {
    test('nowMs adds the offset to the local clock', () {
      final clock = SessionClock.forTest(
        offsetMs: 5000,
        localNow: localClockAt(1000000),
      );
      expect(clock.nowMs(), equals(1005000));
    });

    test('a negative offset is applied (local clock running ahead)', () {
      final clock = SessionClock.forTest(
        offsetMs: -3000,
        localNow: localClockAt(1000000),
      );
      expect(clock.nowMs(), equals(997000));
    });

    test('a zero offset leaves the local clock alone', () {
      final clock = SessionClock.forTest(
        offsetMs: 0,
        localNow: localClockAt(1000000),
      );
      expect(clock.nowMs(), equals(1000000));
    });

    test('two devices with different local clocks agree on server time', () {
      // The single failure mode the design exists to prevent: one phone five
      // minutes fast, the other five minutes slow, both reading the same
      // server offset. They must land on the same instant.
      const serverNow = 1700000000000;
      const skewMs = 5 * 60 * 1000;

      final fastPhone = SessionClock.forTest(
        offsetMs: -skewMs,
        localNow: localClockAt(serverNow + skewMs),
      );
      final slowPhone = SessionClock.forTest(
        offsetMs: skewMs,
        localNow: localClockAt(serverNow - skewMs),
      );

      expect(fastPhone.nowMs(), equals(serverNow));
      expect(slowPhone.nowMs(), equals(serverNow));
      expect(fastPhone.nowMs(), equals(slowPhone.nowMs()));
    });

    test('now() is nowMs() as a DateTime', () {
      final clock = SessionClock.forTest(
        offsetMs: 5000,
        localNow: localClockAt(1000000),
      );
      expect(clock.now().millisecondsSinceEpoch, equals(clock.nowMs()));
    });

    test('offsetMs exposes the applied offset', () {
      final clock = SessionClock.forTest(offsetMs: 1234);
      expect(clock.offsetMs, equals(1234));
    });

    test('the test factory reports itself as synchronised', () {
      // forTest seeds the offset through the same setter the stream uses, so a
      // test clock is by definition synchronised.
      expect(SessionClock.forTest(offsetMs: 0).isSynchronized, isTrue);
    });

    test('a fresh clock with no offset is not synchronised', () {
      final clock = SessionClock(localNow: localClockAt(1000000));
      expect(clock.isSynchronized, isFalse);
      expect(clock.offsetMs, equals(0));
      // Before any offset arrives the local clock is the best available answer.
      expect(clock.nowMs(), equals(1000000));
    });
  });

  group('debugSetOffsetMs', () {
    test('replaces the offset and marks the clock synchronised', () {
      final clock = SessionClock(localNow: localClockAt(1000000));
      expect(clock.isSynchronized, isFalse);

      clock.debugSetOffsetMs(2500);

      expect(clock.isSynchronized, isTrue);
      expect(clock.offsetMs, equals(2500));
      expect(clock.nowMs(), equals(1002500));
    });
  });

  group('ticks', () {
    test('emits the current server time immediately', () async {
      final clock = SessionClock(
        localNow: localClockAt(1000000),
        tickInterval: const Duration(milliseconds: 5),
      )..debugSetOffsetMs(5000);

      final first = await clock.ticks().first;
      expect(first, equals(1005000));
    });

    test('keeps emitting on the tick interval', () async {
      final clock = SessionClock(
        localNow: localClockAt(1000000),
        tickInterval: const Duration(milliseconds: 5),
      )..debugSetOffsetMs(0);

      final emitted = await clock.ticks().take(3).toList();
      expect(emitted.length, equals(3));
      expect(emitted.every((value) => value == 1000000), isTrue);
    });
  });

  group('lifecycle', () {
    test('stop is safe on a clock that was never started', () async {
      final clock = SessionClock(localNow: localClockAt(1000000));
      await expectLater(clock.stop(), completes);
    });

    test('start and stop are safe without a Firebase app', () async {
      // No Firebase app is initialised in unit tests, which is exactly the
      // degraded path: the clock must stay usable and fall back to local time
      // rather than throwing.
      final clock = SessionClock(localNow: localClockAt(1000000));

      clock.start();
      clock.start(); // idempotent
      expect(clock.nowMs(), equals(1000000));

      await clock.stop();
      // The last known offset survives a stop.
      expect(clock.nowMs(), equals(1000000));
    });
  });

  test('toString reports the offset and sync state', () {
    final clock = SessionClock.forTest(offsetMs: 42);
    expect(clock.toString(), contains('42'));
    expect(clock.toString(), contains('true'));
  });
}
