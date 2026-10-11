// Copyright (c) 2026 NLP digitox
//
// Compact, human-readable time formatting for the background-health readout.
// Kept out of the widget so both rules can be unit-tested without pumping a
// widget tree — they are the only non-trivial logic on that card.

/// "2 h 31 m", "45 m", "30 s".
///
/// A negative duration is reported as "0 s" rather than "-1 m": the caller is
/// describing elapsed time, and a clock that moved backwards is not something
/// the user can act on.
String formatDurationShort(Duration duration) {
  final safe = duration.isNegative ? Duration.zero : duration;
  final hours = safe.inHours;
  final minutes = safe.inMinutes.remainder(60);
  if (hours > 0) return '$hours h $minutes m';
  if (minutes > 0) return '$minutes m';
  return '${safe.inSeconds} s';
}

/// "just now", "12 min ago", "3 h ago", "2 d ago".
///
/// [now] is passed in rather than read from `DateTime.now()` so the caller can
/// pin it, and a timestamp in the future reads as "just now" instead of
/// producing a negative age.
String describeElapsed(DateTime then, DateTime now) {
  final elapsed = now.difference(then);
  if (elapsed.inMinutes < 1) return 'just now';
  if (elapsed.inMinutes < 60) return '${elapsed.inMinutes} min ago';
  if (elapsed.inHours < 24) return '${elapsed.inHours} h ago';
  return '${elapsed.inDays} d ago';
}
