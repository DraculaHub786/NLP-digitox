// Copyright (c) 2026 NLP digitox

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/services/shared_session_focus_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tests for the evidence behind the 50-point group-session bonus.
///
/// The bug this guards: a user could create a shared session and immediately
/// end it, without ever starting — let alone finishing — a group focus run,
/// and still be paid. Payout now requires
/// [SharedSessionFocusTracker.hasCompletedFocusRun] to answer true for that
/// session on that device.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  final tracker = SharedSessionFocusTracker.instance;

  group('completed focus runs', () {
    test('a session with no finished focus run is not eligible', () async {
      expect(await tracker.hasCompletedFocusRun('session-1'), isFalse);
    });

    test('recording a finished run makes that session eligible', () async {
      await tracker.markFocusRunCompleted('session-1');

      expect(await tracker.hasCompletedFocusRun('session-1'), isTrue);
    });

    test('only the session that was focused in becomes eligible', () async {
      await tracker.markFocusRunCompleted('session-1');

      expect(await tracker.hasCompletedFocusRun('session-1'), isTrue);
      expect(await tracker.hasCompletedFocusRun('session-2'), isFalse);
    });

    test('recording the same run twice stays eligible and does not throw',
        () async {
      await tracker.markFocusRunCompleted('session-1');
      await tracker.markFocusRunCompleted('session-1');

      expect(await tracker.hasCompletedFocusRun('session-1'), isTrue);
    });

    test('an empty session id is never eligible', () async {
      await tracker.markFocusRunCompleted('');

      expect(await tracker.hasCompletedFocusRun(''), isFalse);
    });

    test('clear() wipes the record', () async {
      await tracker.markFocusRunCompleted('session-1');
      await tracker.clear();

      expect(await tracker.hasCompletedFocusRun('session-1'), isFalse);
    });

    test('older entries roll off once the memory cap is reached', () async {
      // The cap exists so the pref entry cannot grow without bound; 50 is the
      // documented limit (SharedSessionFocusTracker._maxRemembered).
      for (var i = 0; i < 55; i++) {
        await tracker.markFocusRunCompleted('session-$i');
      }

      expect(await tracker.hasCompletedFocusRun('session-0'), isFalse);
      expect(await tracker.hasCompletedFocusRun('session-54'), isTrue);
    });
  });

  group('in-progress run marker', () {
    test('is empty before any run starts', () async {
      expect(await tracker.activeFocusRunSessionId(), isNull);
    });

    test('round-trips the session being focused in', () async {
      await tracker.markFocusRunStarted('session-7');

      expect(await tracker.activeFocusRunSessionId(), 'session-7');
    });

    test('clearing the marker does not record a completion', () async {
      await tracker.markFocusRunStarted('session-7');
      await tracker.clearActiveFocusRun();

      expect(await tracker.activeFocusRunSessionId(), isNull);
      expect(await tracker.hasCompletedFocusRun('session-7'), isFalse);
    });

    test('a started run is not a completed run', () async {
      await tracker.markFocusRunStarted('session-7');

      expect(await tracker.hasCompletedFocusRun('session-7'), isFalse);
    });
  });
}
