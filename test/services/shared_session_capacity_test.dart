// Copyright (c) 2026 NLP digitox

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/constants/session_limits.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';

/// Tests for the member cap as it reaches the UI.
///
/// `SessionLimitsTest` covers the arithmetic; this file covers the model the
/// screens actually read. Two things matter here:
///
///   * a session loaded from the database can never report more seats than the
///     cap, even if the stored `maxMembers` is a legacy `0` ("unlimited") or a
///     value an edited client invented, and
///   * `isFull` / `remainingSlots` agree with each other and with the cap, so
///     the "Full" chip, the disabled Join button and the service's own refusal
///     all trigger at the same member count.
void main() {
  final now = DateTime(2026, 1, 1, 9);

  SessionMember member(String userId) => SessionMember(
        userId: userId,
        displayName: userId,
        joinedAt: now,
        isActive: true,
        lastActive: now,
      );

  SharedSession session({
    List<SessionMember>? members,
    int? maxMembers,
  }) =>
      SharedSession(
        id: 'session-1',
        name: 'Study Group',
        ownerId: 'owner',
        createdAt: now,
        maxMembers: maxMembers ?? SessionLimits.maxMembersPerSession,
        members: members ?? [member('owner')],
      );

  group('capacity defaults', () {
    test('a session built without an explicit cap gets the maximum', () {
      final result = SharedSession(
        id: 'session-1',
        name: 'Study Group',
        ownerId: 'owner',
        createdAt: now,
      );

      expect(result.maxMembers, SessionLimits.maxMembersPerSession);
    });

    test('a fresh session holding only its owner is not full', () {
      final result = session();

      expect(result.memberCount, 1);
      expect(result.remainingSlots, SessionLimits.maxMembersPerSession - 1);
      expect(result.isFull, isFalse);
    });
  });

  group('isFull and remainingSlots', () {
    test('report one seat left when one seat remains', () {
      final almostFull = session(
        members: List.generate(9, (i) => member('user$i')),
      );

      expect(almostFull.isFull, isFalse);
      expect(almostFull.remainingSlots, 1);
    });

    test('agree at exactly the cap', () {
      final full = session(
        members: List.generate(10, (i) => member('user$i')),
      );

      expect(full.isFull, isTrue);
      expect(full.remainingSlots, 0);
    });

    test('a room over its cap still reports no free seats, never negative', () {
      // Can only happen if the cap was lowered after people had already joined,
      // but the UI must not render a negative count if it ever does.
      final overfull = session(
        members: List.generate(12, (i) => member('user$i')),
      );

      expect(overfull.isFull, isTrue);
      expect(overfull.remainingSlots, 0);
    });
  });

  group('maxMembers read from the database', () {
    Map<String, dynamic> raw({Object? maxMembers}) => {
          'id': 'session-1',
          'name': 'Study Group',
          'ownerId': 'owner',
          'createdAt': now.toIso8601String(),
          if (maxMembers != null) 'maxMembers': maxMembers,
        };

    test('a legacy "unlimited" zero becomes the cap', () {
      final restored = SharedSession.fromMap(raw(maxMembers: 0));

      expect(restored.maxMembers, SessionLimits.maxMembersPerSession);
    });

    test('a missing value becomes the cap', () {
      final restored = SharedSession.fromMap(raw());

      expect(restored.maxMembers, SessionLimits.maxMembersPerSession);
    });

    test('a value above the cap is clamped down', () {
      final restored = SharedSession.fromMap(raw(maxMembers: 500));

      expect(restored.maxMembers, SessionLimits.maxMembersPerSession);
    });

    test('a double from JSON round-tripping is accepted and clamped', () {
      final restored = SharedSession.fromMap(raw(maxMembers: 10.0));

      expect(restored.maxMembers, SessionLimits.maxMembersPerSession);
    });

    test('a smaller stored limit is preserved', () {
      final restored = SharedSession.fromMap(raw(maxMembers: 4));

      expect(restored.maxMembers, 4);
    });

    test('a nonsense value becomes the cap rather than crashing', () {
      final restored = SharedSession.fromMap(raw(maxMembers: 'lots'));

      expect(restored.maxMembers, SessionLimits.maxMembersPerSession);
    });
  });

  group('copyWith', () {
    test('cannot widen a session past the cap', () {
      final widened = session().copyWith(maxMembers: 999);

      expect(widened.maxMembers, SessionLimits.maxMembersPerSession);
    });

    test('cannot opt out of the cap with a zero', () {
      final unbounded = session().copyWith(maxMembers: 0);

      expect(unbounded.maxMembers, SessionLimits.maxMembersPerSession);
    });

    test('can narrow a session below the cap', () {
      final narrowed = session().copyWith(maxMembers: 2);

      expect(narrowed.maxMembers, 2);
    });

    test('leaves the cap untouched when not supplied', () {
      final renamed = session(maxMembers: 5).copyWith(name: 'Renamed');

      expect(renamed.maxMembers, 5);
    });
  });
}
