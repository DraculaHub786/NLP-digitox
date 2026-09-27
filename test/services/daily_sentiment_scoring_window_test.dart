import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/services/daily_sentiment_scoring_service.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';

/// Builds a Firestore-shaped list of score entries: `List<Map<String, dynamic>>`
/// exactly like the read-modify-write in `_storeScore` produces, so
/// `windowScores`'s `whereType<Map<String, dynamic>>()` accepts them.
List<dynamic> _entriesFrom(DateTime start, int count, {double score = 0.1}) {
  return List<dynamic>.generate(count, (i) {
    final day = start.add(Duration(days: i));
    return <String, dynamic>{
      'date': dayKeyOf(day),
      'score': score,
      'timestamp': Timestamp.fromDate(day),
    };
  });
}

void main() {
  group('DailySentimentScoringService.windowScores', () {
    test('keeps exactly 30 entries, dropping the oldest', () {
      final start = DateTime(2026, 1, 1);
      final existing = _entriesFrom(start, 30); // 2026-01-01 .. 2026-01-30

      final result = DailySentimentScoringService.windowScores(
        existing,
        dayKey: '2026-01-31',
        score: 0.7,
        day: DateTime(2026, 1, 31),
      );

      expect(result.length, 30);
      expect(result.first['date'], '2026-01-02');
      expect(result.last['date'], '2026-01-31');
      expect(result.last['score'], 0.7);
    });

    test('re-scores an existing day by replacing, not appending', () {
      final start = DateTime(2026, 1, 1);
      final existing = _entriesFrom(start, 30);
      final originalLength = existing.length;

      final result = DailySentimentScoringService.windowScores(
        existing,
        dayKey: '2026-01-15',
        score: -0.9,
        day: DateTime(2026, 1, 15),
      );

      // The regression the transactional rewrite fixed was `arrayUnion`
      // growing the list to 31 with a duplicate 2026-01-15 entry.
      expect(result.length, originalLength);
      final matches =
          result.where((entry) => entry['date'] == '2026-01-15').toList();
      expect(matches.length, 1);
      expect(matches.single['score'], -0.9);
      expect(result.first['date'], '2026-01-01');
      expect(result.last['date'], '2026-01-30');
    });

    test('scoring the same day twice never duplicates the entry', () {
      var window = <Map<String, dynamic>>[];
      final day = DateTime(2026, 5, 1);

      window = DailySentimentScoringService.windowScores(
        window,
        dayKey: '2026-05-01',
        score: 0.2,
        day: day,
      );
      window = DailySentimentScoringService.windowScores(
        window,
        dayKey: '2026-05-01',
        score: 0.5,
        day: day,
      );

      expect(window.length, 1);
      expect(window.single['score'], 0.5);
    });

    test('returns entries sorted ascending by date key', () {
      final shuffled = <dynamic>[
        <String, dynamic>{
          'date': '2026-01-10',
          'score': 0.1,
          'timestamp': Timestamp.fromDate(DateTime(2026, 1, 10)),
        },
        <String, dynamic>{
          'date': '2026-01-05',
          'score': 0.2,
          'timestamp': Timestamp.fromDate(DateTime(2026, 1, 5)),
        },
      ];

      final result = DailySentimentScoringService.windowScores(
        shuffled,
        dayKey: '2026-01-07',
        score: 0.3,
        day: DateTime(2026, 1, 7),
      );

      expect(
        result.map((entry) => entry['date']).toList(),
        ['2026-01-05', '2026-01-07', '2026-01-10'],
      );
    });

    test('an empty history yields a single entry', () {
      final result = DailySentimentScoringService.windowScores(
        const <dynamic>[],
        dayKey: '2026-02-01',
        score: 0.0,
        day: DateTime(2026, 2, 1),
      );

      expect(result.length, 1);
      expect(result.single['date'], '2026-02-01');
      expect(result.single['score'], 0.0);
    });

    test('ignores non-map junk in the stored array', () {
      final withJunk = <dynamic>[
        'not a map',
        42,
        <String, dynamic>{
          'date': '2026-01-01',
          'score': 0.1,
          'timestamp': Timestamp.fromDate(DateTime(2026, 1, 1)),
        },
      ];

      final result = DailySentimentScoringService.windowScores(
        withJunk,
        dayKey: '2026-01-02',
        score: 0.2,
        day: DateTime(2026, 1, 2),
      );

      expect(result.length, 2);
      expect(
        result.map((entry) => entry['date']).toList(),
        ['2026-01-01', '2026-01-02'],
      );
    });

    test('honours a custom retention window', () {
      final start = DateTime(2026, 3, 1);
      final existing = _entriesFrom(start, 5);

      final result = DailySentimentScoringService.windowScores(
        existing,
        dayKey: '2026-03-06',
        score: 0.4,
        day: DateTime(2026, 3, 6),
        retentionDays: 3,
      );

      expect(result.length, 3);
      expect(
        result.map((entry) => entry['date']).toList(),
        ['2026-03-04', '2026-03-05', '2026-03-06'],
      );
    });
  });
}
