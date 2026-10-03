// Copyright (c) 2026 NLP digitox

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/services/shared_session_focus_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tests for the in-progress group-run marker.
///
/// This tracker keeps exactly one thing: the shared session this device is
/// currently focusing in. It is *not* a record of who earned a point — the
/// completion webhook decides that server-side — so these tests cover only the
/// start/read/clear lifecycle the focus notifier relies on to catch up a run
/// that ended while the app was closed.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  final tracker = SharedSessionFocusTracker.instance;

  group('in-progress run marker', () {
    test('is empty before any run starts', () async {
      expect(await tracker.activeFocusRunSessionId(), isNull);
    });

    test('round-trips the session being focused in', () async {
      await tracker.markFocusRunStarted('session-7');

      expect(await tracker.activeFocusRunSessionId(), 'session-7');
    });

    test('starting a second run replaces the first', () async {
      await tracker.markFocusRunStarted('session-7');
      await tracker.markFocusRunStarted('session-8');

      expect(await tracker.activeFocusRunSessionId(), 'session-8');
    });

    test('an empty session id is not recorded', () async {
      await tracker.markFocusRunStarted('');

      expect(await tracker.activeFocusRunSessionId(), isNull);
    });

    test('clearing the marker empties it', () async {
      await tracker.markFocusRunStarted('session-7');
      await tracker.clearActiveFocusRun();

      expect(await tracker.activeFocusRunSessionId(), isNull);
    });

    test('clearing an already-empty marker is harmless', () async {
      await tracker.clearActiveFocusRun();

      expect(await tracker.activeFocusRunSessionId(), isNull);
    });
  });
}
