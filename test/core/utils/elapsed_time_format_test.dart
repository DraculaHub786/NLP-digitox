// Copyright (c) 2026 NLP digitox

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/utils/elapsed_time_format.dart';

void main() {
  group('formatDurationShort', () {
    test('reports hours and minutes', () {
      expect(
        formatDurationShort(const Duration(hours: 2, minutes: 31)),
        '2 h 31 m',
      );
    });

    test('drops a zero hour', () {
      expect(formatDurationShort(const Duration(minutes: 45)), '45 m');
    });

    test('falls back to seconds under a minute', () {
      expect(formatDurationShort(const Duration(seconds: 30)), '30 s');
    });

    test('treats exactly one hour as hours, with zero minutes', () {
      expect(formatDurationShort(const Duration(hours: 1)), '1 h 0 m');
    });

    test('a negative duration reads as zero, never as negative time', () {
      expect(formatDurationShort(const Duration(minutes: -5)), '0 s');
    });

    test('zero reads as zero seconds', () {
      expect(formatDurationShort(Duration.zero), '0 s');
    });
  });

  group('describeElapsed', () {
    final now = DateTime(2026, 9, 14, 12);

    test('anything under a minute is "just now"', () {
      expect(describeElapsed(now.subtract(const Duration(seconds: 5)), now),
          'just now');
    });

    test('minutes', () {
      expect(describeElapsed(now.subtract(const Duration(minutes: 12)), now),
          '12 min ago');
    });

    test('hours', () {
      expect(describeElapsed(now.subtract(const Duration(hours: 3)), now),
          '3 h ago');
    });

    test('days', () {
      expect(describeElapsed(now.subtract(const Duration(days: 2)), now),
          '2 d ago');
    });

    test('exactly one hour is hours, not minutes', () {
      expect(describeElapsed(now.subtract(const Duration(hours: 1)), now),
          '1 h ago');
    });

    test('exactly 24 hours is days, not hours', () {
      expect(describeElapsed(now.subtract(const Duration(hours: 24)), now),
          '1 d ago');
    });

    test('a future timestamp reads as "just now", not a negative age', () {
      expect(describeElapsed(now.add(const Duration(minutes: 5)), now),
          'just now');
    });
  });
}
