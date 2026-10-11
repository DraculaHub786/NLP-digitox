// Copyright (c) 2026 NLP digitox

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/services/badge_celebration_service.dart';
import 'package:nlp_digitox/core/services/badge_seen_store.dart';
import 'package:nlp_digitox/models/badge_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Badge _badge(
  String id, {
  DateTime? earnedAt,
  String title = 'Weekly Winner',
  String period = 'weekly',
  String cycleLabel = '2026-W37',
}) {
  return Badge(
    id: id,
    title: title,
    imageUrl: '',
    period: period,
    cycleLabel: cycleLabel,
    verificationId: 'v-$id',
    earnedAt: earnedAt ?? DateTime(2026, 9, 14),
  );
}

/// In-memory [BadgeSeenStore]. A `null` read mirrors "never synced", which the
/// real store signals with an absent key.
class _FakeSeenStore implements BadgeSeenStore {
  final Map<String, Set<String>> _seen = {};

  @override
  Future<Set<String>?> readSeen(String userId) async => _seen[userId];

  @override
  Future<void> writeSeen(String userId, Set<String> badgeIds) async {
    _seen[userId] = {...badgeIds};
  }
}

void main() {
  group('planBadgeCelebration', () {
    test('first sighting is a silent baseline', () {
      final plan = planBadgeCelebration(
        seen: null,
        badges: [_badge('a'), _badge('b')],
      );

      expect(plan.toCelebrate, isEmpty);
      expect(plan.nextSeen, {'a', 'b'});
    });

    test('first sighting with no badges stores an empty baseline', () {
      final plan = planBadgeCelebration(seen: null, badges: const []);

      expect(plan.toCelebrate, isEmpty);
      expect(plan.nextSeen, isEmpty);
    });

    test('celebrates only ids not already seen', () {
      final plan = planBadgeCelebration(
        seen: {'a'},
        badges: [_badge('a'), _badge('b')],
      );

      expect(plan.toCelebrate.map((b) => b.id), ['b']);
      expect(plan.nextSeen, {'a', 'b'});
    });

    test('keeps known ids after the badge disappears from the server', () {
      final plan =
          planBadgeCelebration(seen: {'a', 'b'}, badges: [_badge('a')]);

      expect(plan.toCelebrate, isEmpty);
      // "b" stays seen, so a later re-appearance is not celebrated twice.
      expect(plan.nextSeen, {'a', 'b'});
    });

    test('orders several new badges newest first', () {
      final plan = planBadgeCelebration(
        seen: const {},
        badges: [
          _badge('old', earnedAt: DateTime(2026, 1, 1)),
          _badge('newest', earnedAt: DateTime(2026, 3, 1)),
          _badge('middle', earnedAt: DateTime(2026, 2, 1)),
        ],
      );

      expect(plan.toCelebrate.map((b) => b.id), ['newest', 'middle', 'old']);
    });

    test('an unchanged list after the baseline celebrates nothing', () {
      final badges = [_badge('a'), _badge('b')];
      final first = planBadgeCelebration(seen: null, badges: badges);
      final second = planBadgeCelebration(seen: first.nextSeen, badges: badges);

      expect(second.toCelebrate, isEmpty);
    });
  });

  group('BadgeCelebrationService', () {
    test('baselines an existing account without celebrating anything',
        () async {
      final badges = StreamController<List<Badge>>.broadcast();
      final store = _FakeSeenStore();
      final service = BadgeCelebrationService(
        seenStore: store,
        badgeSource: (_) => badges.stream,
      );
      addTearDown(() async {
        await service.dispose();
        await badges.close();
      });

      final celebrated = <String>[];
      service.celebrations.listen((badge) => celebrated.add(badge.id));

      service.start('u1');
      badges.add([_badge('historical-1'), _badge('historical-2')]);
      await Future<void>.delayed(Duration.zero);

      expect(celebrated, isEmpty);
      expect(await store.readSeen('u1'), {'historical-1', 'historical-2'});
    });

    test('celebrates a badge that arrives after the baseline', () async {
      final badges = StreamController<List<Badge>>.broadcast();
      final store = _FakeSeenStore();
      await store.writeSeen('u1', {'a'});

      final service = BadgeCelebrationService(
        seenStore: store,
        badgeSource: (_) => badges.stream,
      );
      addTearDown(() async {
        await service.dispose();
        await badges.close();
      });

      final celebrated = <String>[];
      final done = Completer<void>();
      service.celebrations.listen((badge) {
        celebrated.add(badge.id);
        if (!done.isCompleted) done.complete();
      });

      service.start('u1');
      badges.add([_badge('a'), _badge('b')]);
      await done.future;

      expect(celebrated, ['b']);
      expect(await store.readSeen('u1'), {'a', 'b'});
    });

    test('does not re-celebrate when the same snapshot repeats', () async {
      final badges = StreamController<List<Badge>>.broadcast();
      final store = _FakeSeenStore();
      await store.writeSeen('u1', {'a'});

      final service = BadgeCelebrationService(
        seenStore: store,
        badgeSource: (_) => badges.stream,
      );
      addTearDown(() async {
        await service.dispose();
        await badges.close();
      });

      final celebrated = <String>[];
      service.celebrations.listen((badge) => celebrated.add(badge.id));

      service.start('u1');
      badges.add([_badge('a'), _badge('b')]);
      await Future<void>.delayed(Duration.zero);
      badges.add([_badge('a'), _badge('b')]);
      await Future<void>.delayed(Duration.zero);

      expect(celebrated, ['b']);
    });

    test('keeps accounts apart', () async {
      final badges = StreamController<String>.broadcast();
      final store = _FakeSeenStore();
      final service = BadgeCelebrationService(
        seenStore: store,
        badgeSource: (userId) => badges.stream.map(
          (uid) => uid == userId ? [_badge('shared')] : <Badge>[],
        ),
      );
      addTearDown(() async {
        await service.dispose();
        await badges.close();
      });

      final celebrated = <String>[];
      service.celebrations.listen((badge) => celebrated.add(badge.id));

      // u1 sees the badge first and baselines it silently.
      service.start('u1');
      badges.add('u1');
      await Future<void>.delayed(Duration.zero);
      expect(celebrated, isEmpty);

      // u2 has never synced either, so its first sighting is also a baseline.
      service.start('u2');
      badges.add('u2');
      await Future<void>.delayed(Duration.zero);
      expect(celebrated, isEmpty);

      expect(await store.readSeen('u1'), {'shared'});
      expect(await store.readSeen('u2'), {'shared'});
    });
  });

  group('SharedPrefsBadgeSeenStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('reports null before the account has ever synced', () async {
      const store = SharedPrefsBadgeSeenStore();
      expect(await store.readSeen('u1'), isNull);
    });

    test('round-trips ids under a per-user key', () async {
      const store = SharedPrefsBadgeSeenStore();
      await store.writeSeen('u1', {'a', 'b'});

      expect(await store.readSeen('u1'), {'a', 'b'});
      // A different account on the same device must not inherit them.
      expect(await store.readSeen('u2'), isNull);
      expect(SharedPrefsBadgeSeenStore.keyFor('u1'), 'seen_badge_ids_u1');
    });

    test('an empty write is distinct from never having synced', () async {
      const store = SharedPrefsBadgeSeenStore();
      await store.writeSeen('u1', const {});

      expect(await store.readSeen('u1'), isEmpty);
      expect(await store.readSeen('u2'), isNull);
    });
  });
}
