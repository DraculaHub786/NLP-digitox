// Copyright (c) 2026 NLP digitox
//
// WellbeingReportService — assembles the WellbeingReportData snapshot that
// both the in-app preview and the exported PDF render from.
//
// This is the piece the old "Export My Data" button was missing entirely: it
// combined four local sources that until now were never read together —
//
//   1. AppUsageTable (Drift)          -> per-day + per-app screen time
//   2. WellbeingTable (Drift)         -> the user's daily screen-time goal
//   3. FocusSessionsTable (Drift)     -> completed / failed focus sessions
//   4. SentimentPersistenceService    -> persisted mood history + 7-day trend
//
// Nothing here talks to the network or to Firestore, so the report works
// fully offline and reflects on-device behaviour only.

import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/enums/session_state.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/core/services/sentiment_persistence_service.dart';
import 'package:nlp_digitox/models/ai_analysis_models.dart';
import 'package:nlp_digitox/models/wellbeing_report_data.dart';

class WellbeingReportService {
  WellbeingReportService._();

  static final WellbeingReportService instance = WellbeingReportService._();

  /// How many apps the report shows in its ranked list.
  static const int topAppCount = 5;

  /// Default reporting window.
  static const int defaultWindowDays = 7;

  /// Convenience wrapper: a window ending today that covers the last [days]
  /// calendar days (inclusive of today).
  DateTimeRange lastDaysRange([int days = defaultWindowDays]) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    return DateTimeRange(start: start, end: now);
  }

  /// Builds the full report for [range].
  ///
  /// Every step degrades gracefully: a failure in one source (e.g. the native
  /// app list being unavailable) must not prevent the rest of the report from
  /// being produced, so each stage is isolated.
  Future<WellbeingReportData> buildReport({
    required DateTimeRange range,
  }) async {
    final dao = DriftDbService.instance.driftDb.dynamicRecordsDao;
    final uniqueDao = DriftDbService.instance.driftDb.uniqueRecordsDao;

    // 1 — Device-wide daily screen time.
    final dailyScreenTimeSec =
        await dao.fetchDailyDeviceScreenTimeForRange(range: range);

    // 2 — The user's daily goal.
    final wellbeing = await uniqueDao.loadWellBeingSettings();
    final goalSec = wellbeing.dailyScreenTimeGoalSec;

    final (daysUnderGoal, daysOverGoal) =
        _compareAgainstGoal(dailyScreenTimeSec, goalSec);

    // 3 — Per-app totals, resolved to names + icons.
    final topApps = await _buildTopApps(range);

    // 4 — Focus sessions.
    final sessions = await dao.fetchFocusSessionsBetween(range: range);
    final completed = sessions
        .where((session) => session.state == SessionState.successful)
        .toList();
    final failed =
        sessions.where((session) => session.state == SessionState.failed).length;
    final focusMinutes = completed.fold<int>(
          0,
          (total, session) => total + session.durationSecs,
        ) ~/
        60;

    // 5 — Mood history + trend.
    final moodHistory =
        await SentimentPersistenceService.instance.loadHistory();
    final moodTrend =
        await SentimentPersistenceService.instance.computeTrend();

    final insights = _buildInsights(
      daysUnderGoal: daysUnderGoal,
      daysOverGoal: daysOverGoal,
      topApps: topApps,
      focusSessionsCompleted: completed.length,
      focusSessionsFailed: failed,
      focusMinutesTotal: focusMinutes,
      dailyGoalSec: goalSec,
      moodTrend: moodTrend,
      trackedDays: dailyScreenTimeSec.length,
    );

    return WellbeingReportData(
      rangeStart: range.start,
      rangeEnd: range.end,
      dailyScreenTimeSec: dailyScreenTimeSec,
      dailyGoalSec: goalSec,
      daysUnderGoal: daysUnderGoal,
      daysOverGoal: daysOverGoal,
      topApps: topApps,
      focusSessionsCompleted: completed.length,
      focusSessionsFailed: failed,
      focusMinutesTotal: focusMinutes,
      moodHistory: moodHistory,
      moodTrend: moodTrend,
      insights: insights,
    );
  }

  /// Splits days WITH data into under-goal vs over-goal counts.
  ///
  /// A day with no recorded usage is skipped entirely — counting it as "under
  /// goal" would inflate the win rate on days the tracker simply had no data.
  (int under, int over) _compareAgainstGoal(
    Map<DateTime, int> dailyScreenTimeSec,
    int goalSec,
  ) {
    var under = 0;
    var over = 0;

    for (final seconds in dailyScreenTimeSec.values) {
      if (seconds <= 0) continue;
      if (seconds <= goalSec) {
        under++;
      } else {
        over++;
      }
    }

    return (under, over);
  }

  /// Ranks apps by total screen time across [range] and attaches the
  /// human-readable name + icon from the device's installed-app list.
  Future<List<AppUsageEntry>> _buildTopApps(DateTimeRange range) async {
    final dao = DriftDbService.instance.driftDb.dynamicRecordsDao;
    final totals = await dao.fetchAppUsageTotalsForRange(range: range);

    final deviceApps = await MethodChannelService.instance.fetchDeviceAppsInfo();
    final appsByPackage = {
      for (final app in deviceApps) app.packageName: app,
    };

    final entries = totals.entries
        .where((entry) => entry.value.usage.screenTime > 0)
        .map((entry) {
      final info = appsByPackage[entry.key];
      return AppUsageEntry(
        packageName: entry.key,
        appName: (info?.name.isNotEmpty ?? false) ? info!.name : entry.key,
        icon: info?.icon,
        totalScreenTimeSec: entry.value.usage.screenTime,
        daysUsed: entry.value.daysUsed,
      );
    }).toList()
      ..sort(
        (a, b) => b.totalScreenTimeSec.compareTo(a.totalScreenTimeSec),
      );

    return entries.take(topAppCount).toList();
  }

  /// Turns the numbers into short, plain-language sentences.
  List<String> _buildInsights({
    required int daysUnderGoal,
    required int daysOverGoal,
    required List<AppUsageEntry> topApps,
    required int focusSessionsCompleted,
    required int focusSessionsFailed,
    required int focusMinutesTotal,
    required int dailyGoalSec,
    required SentimentTrend? moodTrend,
    required int trackedDays,
  }) {
    final insights = <String>[];

    if (trackedDays == 0) {
      insights.add(
        'No usage was recorded in this period, so trends cannot be compared '
        'yet.',
      );
      return insights;
    }

    final comparedDays = daysUnderGoal + daysOverGoal;
    if (comparedDays > 0) {
      final pct = (daysUnderGoal / comparedDays * 100).round();
      insights.add(
        'You stayed within your ${(dailyGoalSec / 3600).toStringAsFixed(1)}h '
        'daily screen-time goal on $daysUnderGoal of $comparedDays tracked '
        'days ($pct%).',
      );
    }

    if (daysOverGoal > 0 && daysUnderGoal >= daysOverGoal) {
      insights.add(
        'You beat your goal more often than you missed it — keep the '
        'momentum going.',
      );
    } else if (daysOverGoal > daysUnderGoal) {
      insights.add(
        'You went over your goal on $daysOverGoal day'
        '${daysOverGoal == 1 ? '' : 's'} this period — the biggest lever is '
        'usually your top app.',
      );
    }

    if (topApps.isNotEmpty) {
      final top = topApps.first;
      insights.add(
        '${top.appName} was your most time-consuming app at '
        '${top.hoursLabel}h across ${top.daysUsed} day'
        '${top.daysUsed == 1 ? '' : 's'} — that averages about '
        '${top.averageMinutesPerUsedDay} min per day it was used.',
      );
    }

    if (focusSessionsCompleted > 0) {
      insights.add(
        'You completed $focusSessionsCompleted focus session'
        '${focusSessionsCompleted == 1 ? '' : 's'} for a total of '
        '$focusMinutesTotal focused minute'
        '${focusMinutesTotal == 1 ? '' : 's'}.',
      );
    }

    if (focusSessionsFailed > 0) {
      insights.add(
        '$focusSessionsFailed focus session'
        '${focusSessionsFailed == 1 ? '' : 's'} ended early this period. '
        'Shorter sessions are usually easier to finish.',
      );
    }

    if (moodTrend != null &&
        moodTrend.isAvailable &&
        moodTrend.headline != null) {
      insights.add(moodTrend.headline!);
    }

    return insights;
  }
}
