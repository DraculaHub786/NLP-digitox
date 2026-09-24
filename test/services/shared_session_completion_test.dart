import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';

/// Tests for the shared-session *completion* logic added alongside the
/// "award points when a group focus session finishes" feature.
///
/// Scope is deliberately the pure model layer. The payout acceptance rule is
/// `SharedSession.isEligibleForCompletionPayout` — `SessionService` only
/// decides *when* to ask, this predicate decides *whether* a given user may
/// be paid. Anything that needs a live Firebase connection is covered by the
/// manual two-device check documented in todo.md instead.
void main() {
  SessionMember member(String userId, {bool isActive = true}) {
    final now = DateTime(2026, 1, 1, 10);
    return SessionMember(
      userId: userId,
      deviceId: 'device-$userId',
      displayName: userId,
      joinedAt: now,
      isActive: isActive,
      lastActive: now,
    );
  }

  SharedSession sessionWith({
    required List<SessionMember> members,
    DateTime? completedAt,
    bool isActive = true,
  }) {
    return SharedSession(
      id: 'session-1',
      name: 'Study Group',
      ownerId: 'owner',
      createdAt: DateTime(2026, 1, 1, 9),
      members: members,
      isActive: isActive,
      completedAt: completedAt,
    );
  }

  group('SharedSession completion state', () {
    test('a running session is not completed', () {
      final session = sessionWith(members: [member('owner')]);

      expect(session.completedAt, isNull);
      expect(session.isCompleted, isFalse);
    });

    test('a session with completedAt set is completed', () {
      final finishedAt = DateTime(2026, 1, 1, 11, 30);
      final session = sessionWith(
        members: [member('owner')],
        completedAt: finishedAt,
        isActive: false,
      );

      expect(session.isCompleted, isTrue);
      expect(session.completedAt, equals(finishedAt));
    });

    test('copyWith can mark a running session complete', () {
      final running = sessionWith(members: [member('owner')]);
      final finishedAt = DateTime(2026, 1, 2, 8);

      final completed = running.copyWith(
        isActive: false,
        completedAt: finishedAt,
      );

      expect(completed.isActive, isFalse);
      expect(completed.isCompleted, isTrue);
      expect(completed.completedAt, equals(finishedAt));
      // The original is untouched — SharedSession is immutable.
      expect(running.isCompleted, isFalse);
    });
  });

  group('SharedSession completedAt serialization', () {
    test('toMap omits completedAt entirely while the session is running', () {
      final map = sessionWith(members: [member('owner')]).toMap();

      // Must be absent, not null: writing an explicit null through set()
      // would create/delete the key spuriously in RTDB.
      expect(map.containsKey('completedAt'), isFalse);
    });

    test('toMap includes completedAt as an ISO string once completed', () {
      final finishedAt = DateTime(2026, 3, 4, 15, 45);
      final map = sessionWith(
        members: [member('owner')],
        completedAt: finishedAt,
        isActive: false,
      ).toMap();

      expect(map.containsKey('completedAt'), isTrue);
      expect(map['completedAt'], finishedAt.toIso8601String());
    });

    test('toMap/fromMap round-trips the completion timestamp', () {
      final finishedAt = DateTime(2026, 3, 4, 15, 45);
      final original = sessionWith(
        members: [member('owner'), member('friend')],
        completedAt: finishedAt,
        isActive: false,
      );

      final restored = SharedSession.fromMap(original.toMap());

      expect(restored.isCompleted, isTrue);
      expect(restored.completedAt, equals(finishedAt));
      expect(restored.isActive, isFalse);
      expect(restored.memberCount, equals(2));
    });

    test('fromMap treats a missing completedAt as a running session', () {
      // Mirrors exactly what RTDB hands back for a session that was never
      // completed.
      final restored = SharedSession.fromMap({
        'id': 'session-1',
        'name': 'Study Group',
        'ownerId': 'owner',
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        'isActive': true,
      });

      expect(restored.isCompleted, isFalse);
      expect(restored.completedAt, isNull);
    });
  });

  group('SharedSession.isEligibleForCompletionPayout', () {
    test('pays a member of a completed session', () {
      final session = sessionWith(
        members: [member('owner'), member('friend')],
        completedAt: DateTime(2026, 1, 1, 12),
        isActive: false,
      );

      expect(session.isEligibleForCompletionPayout('friend'), isTrue);
    });

    test('pays the owner of a completed session', () {
      final session = sessionWith(
        members: [member('owner'), member('friend')],
        completedAt: DateTime(2026, 1, 1, 12),
        isActive: false,
      );

      expect(session.isEligibleForCompletionPayout('owner'), isTrue);
    });

    test('never pays while the session is still running', () {
      final session = sessionWith(members: [member('owner')]);

      expect(session.isEligibleForCompletionPayout('owner'), isFalse);
    });

    test('does not pay when the session went inactive without completing', () {
      // The owner leaving marks the session inactive but leaves completedAt
      // unset. That must not be mistaken for a completion, or leaving a
      // session would pay everyone still in it.
      final session = sessionWith(
        members: [member('owner'), member('friend')],
        isActive: false,
        completedAt: null,
      );

      expect(session.isCompleted, isFalse);
      expect(session.isEligibleForCompletionPayout('owner'), isFalse);
      expect(session.isEligibleForCompletionPayout('friend'), isFalse);
    });

    test('does not pay someone who is not a member of the session', () {
      final session = sessionWith(
        members: [member('owner')],
        completedAt: DateTime(2026, 1, 1, 12),
        isActive: false,
      );

      expect(session.isEligibleForCompletionPayout('stranger'), isFalse);
    });

    test('does not pay a member who left before completion', () {
      // A member who leaves is removed from the members map, so they are no
      // longer eligible even though the session later completes.
      final session = sessionWith(
        members: [member('owner')],
        completedAt: DateTime(2026, 1, 1, 12),
        isActive: false,
      );

      expect(session.isEligibleForCompletionPayout('left-early'), isFalse);
    });
  });

  group('SharedSession member parsing (payout membership check)', () {
    test('parses the RTDB nested-map members format', () {
      // The real RTDB shape is members keyed by uid, with the uid absent from
      // the value — the parser has to reinstate it from the key, otherwise
      // the membership test above would silently never match.
      final restored = SharedSession.fromMap({
        'id': 'session-1',
        'name': 'Study Group',
        'ownerId': 'owner',
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        'completedAt': DateTime(2026, 1, 1, 12).toIso8601String(),
        'isActive': false,
        'members': {
          'owner': {
            'displayName': 'You',
            'joinedAt': DateTime(2026, 1, 1).toIso8601String(),
            'isActive': true,
            'lastActive': DateTime(2026, 1, 1).toIso8601String(),
          },
          'friend': {
            'displayName': 'Friend',
            'joinedAt': DateTime(2026, 1, 1).toIso8601String(),
            'isActive': false,
            'lastActive': DateTime(2026, 1, 1).toIso8601String(),
          },
        },
      });

      expect(restored.memberCount, equals(2));
      expect(restored.activeMembers, equals(1));
      expect(restored.members.map((m) => m.userId), contains('friend'));
      expect(restored.isEligibleForCompletionPayout('friend'), isTrue);
    });

    test('still parses the legacy list members format', () {
      final restored = SharedSession.fromMap({
        'id': 'session-1',
        'name': 'Study Group',
        'ownerId': 'owner',
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        'members': [
          {
            'userId': 'owner',
            'displayName': 'You',
            'joinedAt': DateTime(2026, 1, 1).toIso8601String(),
            'isActive': true,
            'lastActive': DateTime(2026, 1, 1).toIso8601String(),
          },
        ],
      });

      expect(restored.memberCount, equals(1));
      expect(restored.members.first.userId, equals('owner'));
    });

    test('treats missing members as an empty list, not a crash', () {
      final restored = SharedSession.fromMap({
        'id': 'session-1',
        'name': 'Study Group',
        'ownerId': 'owner',
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      });

      expect(restored.members, isEmpty);
      expect(restored.isEligibleForCompletionPayout('owner'), isFalse);
    });
  });
}
