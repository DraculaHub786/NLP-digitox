import 'package:nlp_digitox/core/extensions/ext_date_time.dart';

/// Get the date for today (Midnight 12).
/// The returned date will not have any time set.
///
/// Ex- 2025-01-01 00:00:00:000
DateTime get dateToday => DateTime.now().dateOnly;

/// Formats [date] as the `yyyy-MM-dd` document key used by
/// `users/{uid}/daily_sentiment_scores/{day}`.
///
/// Zero-padding matters: the scorer prunes and reads these documents with
/// lexicographic range queries (`isLessThan` / `isGreaterThanOrEqualTo`) on the
/// document id, which only orders correctly when every key has the same width.
String dayKeyOf(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// Formats [date] as the `yyyy-MM` document key used by
/// `users/{uid}/monthly_wellbeing_reports/{month}`.
String monthKeyOf(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}';

/// Month names indexed by `month - 1`, used by [monthKeyLabel].
const List<String> _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Turns a `yyyy-MM` [monthKey] into a human label such as `September 2026`.
///
/// Returns [monthKey] unchanged when it is not a valid month key, so a
/// malformed document id can never break the screen that lists reports.
String monthKeyLabel(String monthKey) {
  final parts = monthKey.split('-');
  if (parts.length != 2) return monthKey;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  if (year == null || month == null || month < 1 || month > 12) return monthKey;
  return '${_monthNames[month - 1]} $year';
}

/// Parses a `yyyy-MM-dd` [key] back into a local midnight [DateTime],
/// returning null when [key] is not a valid day key.
DateTime? dateFromDayKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return null;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return null;
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  final date = DateTime(year, month, day);
  // DateTime silently rolls Feb 31 into March; reject that so an impossible
  // key is reported as invalid instead of resolving to a different day.
  if (date.year != year || date.month != month || date.day != day) return null;
  return date;
}
