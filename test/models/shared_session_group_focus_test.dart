// Copyright (c) 2026 NLP digitox

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';

/// Tests for the rules that decide whether a group focus run can start.
///
/// These guard a bug that made group focus unreachable in the app: the detail
/// screen only enabled "Start Focusing With This Group" when
/// `session.settings != null`, but the create sheet never supplied settings, so
/// every session created in the app had `settings == null` and the button was
/// permanently disabled.
///
/// The fix keeps the capability on the session itself rather than on whether
/// the owner configured a shared plan:
///   * [SharedSession.groupFocusSettings] is never null, so the focus engine
///     always has a config to apply, and
///   * [SharedSession.canStartGroupFocus] depends only on the session being
///     active and unfinished.
void main() {
  final now = DateTime(2026, 1, 1, 9);

  SharedSession session({
    SessionSettings? settings,
    bool isActive = true,
    DateTime? completedAt,
  }) =>
      SharedSession(
        id: 'session-1',
        name: 'Study Group',
        ownerId: 'owner',
        createdAt: now,
        isActive: isActive,
        completedAt: completedAt,
        settings: settings,
      );

  group('groupFocusSettings', () {
    test('is available on a session that stored no settings', () {
      // The exact shape every session created by the create sheet had before
      // the fix — and it must still be able to focus.
      final stored = SharedSession.fromMap({
        'id': 'session-1',
        'name': 'Study Group',
        'ownerId': 'owner',
        'createdAt': now.toIso8601String(),
      });

      expect(stored.settings, isNull);
      expect(stored.groupFocusSettings, isNotNull);
    });

    test('defaults to each member keeping their own plan', () {
      final settings = session().groupFocusSettings;

      // Null means "leave the member's own duration and blocklist alone".
      expect(settings.sharedDailyLimit, isNull);
      expect(settings.blockedApps, isNull);
      expect(settings.focusApps, isNull);
    });

    test('returns the stored settings when the session has them', () {
      const stored = SessionSettings(
        sharedDailyLimit: 45,
        blockedApps: ['com.example.social'],
      );

      expect(session(settings: stored).groupFocusSettings, same(stored));
    });
  });

  group('canStartGroupFocus', () {
    test('is true for a fresh session from the create sheet', () {
      expect(session().canStartGroupFocus, isTrue);
    });

    test('is true even when no settings were ever stored', () {
      expect(session(settings: null).canStartGroupFocus, isTrue);
    });

    test('is false once the owner completed the session', () {
      expect(
        session(completedAt: now).canStartGroupFocus,
        isFalse,
      );
    });

    test('is false once the owner left and it went inactive', () {
      expect(session(isActive: false).canStartGroupFocus, isFalse);
    });

    test('does not depend on settings being configured', () {
      // The whole point: the same capability with and without a stored plan.
      expect(
        session(settings: const SessionSettings(sharedDailyLimit: 25))
            .canStartGroupFocus,
        session(settings: null).canStartGroupFocus,
      );
    });
  });
}
