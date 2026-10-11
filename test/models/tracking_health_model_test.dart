// Copyright (c) 2026 NLP digitox

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/models/tracking_health_model.dart';

int _ms(DateTime at) => at.millisecondsSinceEpoch;

void main() {
  group('TrackingGap.fromJson', () {
    test('reads a well-formed entry', () {
      final gap = TrackingGap.fromJson({
        'from': _ms(DateTime(2026, 9, 14, 10)),
        'to': _ms(DateTime(2026, 9, 14, 12, 31)),
        'durationMs': 9060000,
      });

      expect(gap, isNotNull);
      expect(gap!.duration, const Duration(hours: 2, minutes: 31));
    });

    test('rejects a non-positive window', () {
      final same = _ms(DateTime(2026, 9, 14, 10));
      expect(TrackingGap.fromJson({'from': same, 'to': same}), isNull);
      expect(
        TrackingGap.fromJson({
          'from': _ms(DateTime(2026, 9, 14, 12)),
          'to': _ms(DateTime(2026, 9, 14, 10)),
        }),
        isNull,
      );
    });

    test('rejects missing or wrongly-typed bounds', () {
      expect(TrackingGap.fromJson({'to': 1}), isNull);
      expect(TrackingGap.fromJson({'from': 1}), isNull);
      expect(TrackingGap.fromJson({'from': '1', 'to': '2'}), isNull);
    });
  });

  group('TrackingHealth.parseGaps', () {
    test('an empty or blank log has no gaps', () {
      expect(TrackingHealth.parseGaps(''), isEmpty);
      expect(TrackingHealth.parseGaps('   '), isEmpty);
      expect(TrackingHealth.parseGaps('[]'), isEmpty);
    });

    test('corrupt JSON reads as "no gaps", never as a crash', () {
      expect(TrackingHealth.parseGaps('{not json'), isEmpty);
      expect(TrackingHealth.parseGaps('{"from":1}'), isEmpty);
      expect(TrackingHealth.parseGaps('null'), isEmpty);
    });

    test('keeps the valid entries and drops the malformed ones', () {
      final raw = jsonEncode([
        {'from': _ms(DateTime(2026, 9, 14, 1)), 'to': _ms(DateTime(2026, 9, 14, 2))},
        'not an object',
        {'from': _ms(DateTime(2026, 9, 14, 5)), 'to': _ms(DateTime(2026, 9, 14, 4))},
        {'from': _ms(DateTime(2026, 9, 14, 6)), 'to': _ms(DateTime(2026, 9, 14, 8))},
      ]);

      final gaps = TrackingHealth.parseGaps(raw);

      expect(gaps, hasLength(2));
      expect(gaps.first.duration, const Duration(hours: 1));
      expect(gaps.last.duration, const Duration(hours: 2));
    });
  });

  group('TrackingHealth.gapTotalOn', () {
    final now = DateTime(2026, 9, 14, 15);

    test('no gaps means no outage', () {
      expect(TrackingHealth.unknown.gapTotalOn(now), Duration.zero);
    });

    test('sums gaps that fall inside today', () {
      final health = TrackingHealth(
        gaps: [
          TrackingGap(
            from: DateTime(2026, 9, 14, 1),
            to: DateTime(2026, 9, 14, 2, 30),
          ),
          TrackingGap(
            from: DateTime(2026, 9, 14, 13),
            to: DateTime(2026, 9, 14, 13, 45),
          ),
        ],
      );

      // 01:00–02:30 is 1 h 30 m; 13:00–13:45 is 45 m.
      expect(health.gapTotalOn(now), const Duration(hours: 2, minutes: 15));
    });

    test('a gap that began yesterday only counts from midnight', () {
      final health = TrackingHealth(
        gaps: [
          TrackingGap(
            from: DateTime(2026, 9, 13, 22),
            to: DateTime(2026, 9, 14, 3),
          ),
        ],
      );

      expect(health.gapTotalOn(now), const Duration(hours: 3));
    });

    test('a gap still open at `now` stops at `now`', () {
      final health = TrackingHealth(
        gaps: [
          TrackingGap(
            // The native side stamps the end when the next heartbeat lands, so
            // a window reaching past `now` must not be counted in full.
            from: DateTime(2026, 9, 14, 14),
            to: DateTime(2026, 9, 14, 18),
          ),
        ],
      );

      expect(health.gapTotalOn(now), const Duration(hours: 1));
    });

    test('ignores a gap entirely outside today', () {
      final health = TrackingHealth(
        gaps: [
          TrackingGap(
            from: DateTime(2026, 9, 12, 9),
            to: DateTime(2026, 9, 12, 11),
          ),
        ],
      );

      expect(health.gapTotalOn(now), Duration.zero);
    });

    test('a gap ending exactly at midnight contributes nothing', () {
      final health = TrackingHealth(
        gaps: [
          TrackingGap(
            from: DateTime(2026, 9, 13, 23),
            to: DateTime(2026, 9, 14),
          ),
        ],
      );

      expect(health.gapTotalOn(now), Duration.zero);
    });
  });
}
