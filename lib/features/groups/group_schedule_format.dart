// Copyright (c) 2026 NLP digitox

/// Formatting helpers for a group's schedule.
///
/// Kept out of the widgets so the same wording appears on the schedule row, in
/// the reminder notification and in the "starts soon" banner, and so the maths
/// can be tested without a widget tree.
abstract final class GroupScheduleFormat {
  const GroupScheduleFormat._();

  static const List<String> _weekdayNames = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// A short absolute label: "Today 18:30", "Tomorrow 07:00", "Wed 12 Mar 09:00".
  ///
  /// Relative wording is used only for the two cases where it is unambiguous;
  /// past that a weekday and date are clearer than "in 6 days".
  static String absolute(DateTime when, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    final day = DateTime(when.year, when.month, when.day);
    final difference = day.difference(today).inDays;

    final clock = '${_two(when.hour)}:${_two(when.minute)}';
    if (difference == 0) return 'Today $clock';
    if (difference == 1) return 'Tomorrow $clock';
    if (difference == -1) return 'Yesterday $clock';

    final weekday = _weekdayNames[when.weekday - 1];
    final month = _monthNames[(when.month - 1).clamp(0, 11)];
    return '$weekday ${when.day} $month ${_two(when.hour)}:${_two(when.minute)}';
  }

  /// A short distance label: "in 12 min", "in 3 h", "in 2 days", "now".
  ///
  /// Used for reminders and the live-session banner, where the question is
  /// "how far off is this" rather than "what date is it".
  static String relative(DateTime when, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final delta = when.difference(reference);

    if (delta.isNegative) return 'now';
    if (delta.inMinutes < 1) return 'in under a minute';
    if (delta.inMinutes < 60) return 'in ${delta.inMinutes} min';
    if (delta.inHours < 24) return 'in ${delta.inHours} h';
    if (delta.inDays == 1) return 'in 1 day';
    return 'in ${delta.inDays} days';
  }

  /// Whether [when] is close enough to warrant a "starting soon" treatment.
  static bool isStartingSoon(
    DateTime when, {
    DateTime? now,
    Duration window = const Duration(minutes: 20),
  }) {
    final reference = now ?? DateTime.now();
    final delta = when.difference(reference);
    return !delta.isNegative && delta <= window;
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
