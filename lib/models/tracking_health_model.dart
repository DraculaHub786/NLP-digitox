// Copyright (c) 2026 NLP digitox

import 'dart:convert';

/// One window in which background tracking was not running.
///
/// Written by the native keep-alive watchdog (`TrackingHealth.kt`) whenever the
/// next heartbeat arrives much later than expected, and read back here so the
/// app can say how much of the day it could not see.
class TrackingGap {
  const TrackingGap({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  Duration get duration => to.difference(from);

  /// Reads one entry of the native gap log — `{"from": <ms>, "to": <ms>}`.
  ///
  /// Returns null for anything malformed or non-positive rather than throwing,
  /// so one bad entry cannot hide the rest of the log.
  static TrackingGap? fromJson(Map<String, dynamic> json) {
    final fromMs = json['from'];
    final toMs = json['to'];
    if (fromMs is! int || toMs is! int) return null;
    if (toMs <= fromMs) return null;
    return TrackingGap(
      from: DateTime.fromMillisecondsSinceEpoch(fromMs),
      to: DateTime.fromMillisecondsSinceEpoch(toMs),
    );
  }
}

/// A read-only snapshot of how healthy background tracking has been.
///
/// Nothing here is a total the app *wants* to show: a gap means the process was
/// dead, so [gapTotalOn] is how much of the day Accessibility-based blocking
/// could not have seen. Usage totals come from `UsageStatsManager`, which
/// Android keeps itself, and are unaffected.
class TrackingHealth {
  const TrackingHealth({
    this.lastHeartbeatAt,
    this.lastExitReason,
    this.gaps = const [],
  });

  /// Used when the native side cannot be reached at all.
  static const TrackingHealth unknown = TrackingHealth();

  /// When the keep-alive watchdog last proved it was alive, or null if it has
  /// never ticked.
  final DateTime? lastHeartbeatAt;

  /// How the OS says this process last ended (`USER_REQUESTED`, `SIGNALED`,
  /// …), or null when the API is unavailable. `USER_REQUESTED` next to a lost
  /// Accessibility grant is the signature of a force-stop.
  final String? lastExitReason;

  /// Recorded downtime, newest first as written by the native side.
  final List<TrackingGap> gaps;

  /// How much of the day that contains [now] was spent with tracking off.
  ///
  /// Each gap is clamped to `[midnight, now]`, so a gap that began yesterday
  /// only contributes from midnight onwards, and one still open at [now]
  /// contributes up to [now] rather than to its (future) recorded end.
  Duration gapTotalOn(DateTime now) {
    if (gaps.isEmpty) return Duration.zero;

    final dayStart = DateTime(now.year, now.month, now.day);
    var total = Duration.zero;
    for (final gap in gaps) {
      final start = gap.from.isAfter(dayStart) ? gap.from : dayStart;
      final end = gap.to.isBefore(now) ? gap.to : now;
      if (end.isAfter(start)) total += end.difference(start);
    }
    return total;
  }

  /// Parses the JSON array string the native side stores.
  ///
  /// Every failure mode returns an empty list: a missing or corrupt log must
  /// read as "no gaps recorded", never as a crash on the settings screen.
  static List<TrackingGap> parseGaps(String rawJson) {
    if (rawJson.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! List) return const [];

      final gaps = <TrackingGap>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        final gap = TrackingGap.fromJson(Map<String, dynamic>.from(entry));
        if (gap != null) gaps.add(gap);
      }
      return List<TrackingGap>.unmodifiable(gaps);
    } catch (_) {
      return const [];
    }
  }
}
