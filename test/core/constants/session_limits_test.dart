// Copyright (c) 2026 NLP digitox

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/constants/session_limits.dart';

/// Tests for the shared-session member cap.
///
/// The cap is enforced in three places that must agree — the session model,
/// `SessionService`, and `database.rules.json` — so this file pins the one
/// piece of shared logic they all depend on: what a given requested limit
/// becomes. The rules file cannot import Dart and repeats the literal 10, so
/// the last test here is the alarm that fires if the constant is ever changed
/// without the rule being changed with it.
void main() {
  group('SessionLimits.normalizeMaxMembers', () {
    test('caps a request larger than the maximum', () {
      expect(SessionLimits.normalizeMaxMembers(50), 10);
      expect(
        SessionLimits.normalizeMaxMembers(11),
        SessionLimits.maxMembersPerSession,
      );
    });

    test('accepts a request for exactly the maximum', () {
      expect(
        SessionLimits.normalizeMaxMembers(SessionLimits.maxMembersPerSession),
        SessionLimits.maxMembersPerSession,
      );
    });

    test('keeps a smaller positive request', () {
      expect(SessionLimits.normalizeMaxMembers(3), 3);
      expect(SessionLimits.normalizeMaxMembers(1), 1);
    });

    test('treats the legacy "unlimited" zero as the cap', () {
      // `0` is what every session created before the cap existed carries, and
      // what the old API meant by "no limit". It must not stay unbounded.
      expect(
        SessionLimits.normalizeMaxMembers(0),
        SessionLimits.maxMembersPerSession,
      );
    });

    test('treats a negative as the cap', () {
      expect(
        SessionLimits.normalizeMaxMembers(-5),
        SessionLimits.maxMembersPerSession,
      );
    });

    test('treats a missing value as the cap', () {
      expect(
        SessionLimits.normalizeMaxMembers(null),
        SessionLimits.maxMembersPerSession,
      );
    });

    test('never returns a value outside the supported range', () {
      for (final requested in [-100, -1, 0, 1, 9, 10, 11, 1000]) {
        final result = SessionLimits.normalizeMaxMembers(requested);
        expect(
          result,
          greaterThanOrEqualTo(SessionLimits.minMembersPerSession),
          reason: 'normalizeMaxMembers($requested) fell below the minimum',
        );
        expect(
          result,
          lessThanOrEqualTo(SessionLimits.maxMembersPerSession),
          reason: 'normalizeMaxMembers($requested) exceeded the maximum',
        );
      }
    });
  });

  group('SessionLimits.fullSessionMessage', () {
    test('names the number of seats it is quoting', () {
      expect(
        SessionLimits.fullSessionMessage,
        contains('${SessionLimits.maxMembersPerSession}'),
      );
    });

    test('tells the user what to do next, not just that it failed', () {
      expect(SessionLimits.fullSessionMessage, contains('owner'));
    });
  });

  test('the cap is the number the rules file enforces', () {
    // database.rules.json cannot reference this constant, so it hard-codes the
    // same limit on `sessions/$sessionId/members` and
    // `sessions/$sessionId/maxMembers`. Changing the constant without changing
    // the rule would leave the client and the server disagreeing about how many
    // people a room holds; this is the reminder to change both.
    expect(
      SessionLimits.maxMembersPerSession,
      10,
      reason: 'If this changes, update the 10s in database.rules.json too.',
    );
  });
}
