// Copyright (c) 2026 NLP digitox
//
// Aggregated inputs for the Wellbeing PDF report. This is a plain, immutable
// snapshot assembled by `WellbeingReportService` from four independent local
// sources (Drift usage + focus tables, Drift wellbeing settings, and the
// SharedPreferences sentiment history) so the PDF generator and the in-app
// preview can both render from ONE already-resolved object instead of each
// re-querying the database.

import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/models/ai_analysis_models.dart';

/// One app's total usage across the whole report period.
@immutable
class AppUsageEntry {
  /// Android package id, e.g. `com.instagram.android`.
  final String packageName;

  /// Human-readable label resolved from the device app list. Falls back to
  /// [packageName] when the app is no longer installed.
  final String appName;

  /// Raw launcher icon bytes, or null when the app could not be resolved.
  final Uint8List? icon;

  /// Total foreground time in SECONDS across the entire report period.
  final int totalScreenTimeSec;

  /// How many distinct days in the period this app was used at all.
  final int daysUsed;

  const AppUsageEntry({
    required this.packageName,
    required this.appName,
    required this.icon,
    required this.totalScreenTimeSec,
    required this.daysUsed,
  });

  /// Whole hours, rounded to one decimal, for display.
  String get hoursLabel => (totalScreenTimeSec / 3600).toStringAsFixed(1);

  /// Average minutes per day the app was used, across the days it was used.
  int get averageMinutesPerUsedDay => daysUsed == 0
      ? 0
      : (totalScreenTimeSec / daysUsed) ~/ 60;
}

/// Everything the wellbeing report needs, already computed.
@immutable
class WellbeingReportData {
  final DateTime rangeStart;
  final DateTime rangeEnd;

  /// Device-wide screen time in SECONDS, keyed by day. Days without any
  /// recorded usage are absent rather than present-and-zero, so "no data"
  /// can be distinguished from "zero minutes".
  final Map<DateTime, int> dailyScreenTimeSec;

  /// The user's daily screen-time goal in SECONDS, as configured at the
  /// moment the report was built.
  final int dailyGoalSec;

  /// Days where actual screen time was at or UNDER the goal.
  final int daysUnderGoal;

  /// Days where actual screen time was OVER the goal.
  final int daysOverGoal;

  /// Apps ranked by total time in the period, descending — index 0 is the
  /// single most time-consuming app.
  final List<AppUsageEntry> topApps;

  /// Focus sessions that reached [SessionState.successful] in the period.
  final int focusSessionsCompleted;

  /// Focus sessions that reached [SessionState.failed] in the period.
  final int focusSessionsFailed;

  /// Total focused MINUTES across completed sessions.
  final int focusMinutesTotal;

  /// Persisted per-day mood snapshots, oldest first.
  final List<SentimentSnapshot> moodHistory;

  /// 7-day vs previous-7-day mood trend, or null when unavailable.
  final SentimentTrend? moodTrend;

  /// Plain-language insights generated from the numbers above.
  final List<String> insights;

  const WellbeingReportData({
    required this.rangeStart,
    required this.rangeEnd,
    required this.dailyScreenTimeSec,
    required this.dailyGoalSec,
    required this.daysUnderGoal,
    required this.daysOverGoal,
    required this.topApps,
    required this.focusSessionsCompleted,
    required this.focusSessionsFailed,
    required this.focusMinutesTotal,
    required this.moodHistory,
    required this.moodTrend,
    required this.insights,
  });

  /// Total screen time in SECONDS for the whole period.
  int get totalScreenTimeSec =>
      dailyScreenTimeSec.values.fold(0, (sum, sec) => sum + sec);

  /// Number of days in the period that actually had usage recorded.
  int get trackedDays => dailyScreenTimeSec.length;

  /// Days counted for the goal comparison (under + over).
  int get goalComparedDays => daysUnderGoal + daysOverGoal;

  /// Average daily screen time in SECONDS across days WITH data.
  double get averageDailyScreenTimeSec =>
      trackedDays == 0 ? 0 : totalScreenTimeSec / trackedDays;

  /// Share of compared days spent under the goal, 0–100.
  int get percentDaysUnderGoal => goalComparedDays == 0
      ? 0
      : (daysUnderGoal / goalComparedDays * 100).round();

  /// True when there is nothing meaningful to report yet.
  bool get isEmpty =>
      dailyScreenTimeSec.isEmpty &&
      topApps.isEmpty &&
      focusSessionsCompleted == 0 &&
      focusSessionsFailed == 0 &&
      moodHistory.isEmpty;

  /// Whole hours of total screen time, one decimal.
  String get totalHoursLabel => (totalScreenTimeSec / 3600).toStringAsFixed(1);

  /// Whole hours of average daily screen time, one decimal.
  String get averageHoursLabel =>
      (averageDailyScreenTimeSec / 3600).toStringAsFixed(1);

  /// The configured goal expressed in whole hours, one decimal.
  String get goalHoursLabel => (dailyGoalSec / 3600).toStringAsFixed(1);
}
