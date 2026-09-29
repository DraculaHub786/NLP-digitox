import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';

void main() {
  group('dayKeyOf / monthKeyOf zero padding', () {
    // Zero-padding is load-bearing, not cosmetic: scores are pruned and read
    // with lexicographic range queries on the document id, and those only order
    // correctly when every key has the same width.
    test('pads single-digit months and days to width 2', () {
      expect(dayKeyOf(DateTime(2026, 1, 5)), '2026-01-05');
      expect(dayKeyOf(DateTime(2026, 3, 7)), '2026-03-07');
      expect(monthKeyOf(DateTime(2026, 1, 5)), '2026-01');
    });

    test('leaves two-digit months and days unchanged', () {
      expect(dayKeyOf(DateTime(2026, 12, 31)), '2026-12-31');
      expect(dayKeyOf(DateTime(2026, 11, 30)), '2026-11-30');
      expect(monthKeyOf(DateTime(2026, 9, 27)), '2026-09');
      expect(monthKeyOf(DateTime(2026, 12, 1)), '2026-12');
    });

    test('pads the year to four digits', () {
      expect(dayKeyOf(DateTime(3, 4, 5)), '0003-04-05');
      expect(monthKeyOf(DateTime(3, 4, 5)), '0003-04');
    });

    test('keeps lexicographic order identical to chronological order', () {
      final earlier = dayKeyOf(DateTime(2026, 1, 9));
      final later = dayKeyOf(DateTime(2026, 1, 10));
      expect(earlier.compareTo(later), lessThan(0));
    });
  });

  group('dateFromDayKey', () {
    test('parses a padded day key back to local midnight', () {
      expect(dateFromDayKey('2026-09-27'), DateTime(2026, 9, 27));
      expect(dateFromDayKey('2026-01-05'), DateTime(2026, 1, 5));
    });

    test('rejects an impossible month/day pair', () {
      expect(dateFromDayKey('2026-13-40'), isNull);
      expect(dateFromDayKey('2026-00-10'), isNull);
      expect(dateFromDayKey('2026-06-00'), isNull);
    });

    test('rejects a key with the wrong number of parts', () {
      expect(dateFromDayKey('garbage'), isNull);
      expect(dateFromDayKey('2026-09'), isNull);
      expect(dateFromDayKey('2026-09-27-01'), isNull);
    });

    test('rejects non-numeric parts', () {
      expect(dateFromDayKey('abcd-ef-gh'), isNull);
    });

    test('round-trips with dayKeyOf', () {
      final day = DateTime(2026, 4, 9);
      expect(dateFromDayKey(dayKeyOf(day)), day);
    });
  });

  group('monthKeyLabel', () {
    test('turns a month key into a human label', () {
      expect(monthKeyLabel('2026-09'), 'September 2026');
      expect(monthKeyLabel('2026-01'), 'January 2026');
      expect(monthKeyLabel('2026-12'), 'December 2026');
    });

    test('round-trips through monthKeyOf', () {
      expect(
        monthKeyLabel(monthKeyOf(DateTime(2026, 9, 27))),
        'September 2026',
      );
    });

    test('returns malformed input unchanged', () {
      expect(monthKeyLabel('garbage'), 'garbage');
      expect(monthKeyLabel('2026'), '2026');
      expect(monthKeyLabel('2026-99'), '2026-99');
      expect(monthKeyLabel('2026-00'), '2026-00');
      expect(monthKeyLabel('yyyy-mm'), 'yyyy-mm');
    });
  });
}
