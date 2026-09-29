// Copyright (c) 2026 NLP digitox

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nlp_digitox/core/services/daily_sentiment_scoring_service.dart';
import 'package:nlp_digitox/core/services/monthly_wellbeing_report_service.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';

/// Drives the two AI reporting jobs that must run on the device.
///
/// Neither job can live entirely in a Cloud Function: the chat transcripts are
/// in SharedPreferences and the usage data is in the Drift database, both
/// local-only. So the trigger is remote and the work is local:
///
///  * **Daily scoring** — a native alarm already calls `BgExecutorService`'s
///    midnight handler every night, which scores the day that just ended. This
///    service adds an in-process 23:59 timer for when the app is open, and
///    back-fills any day that was missed entirely through
///    [DailySentimentScoringService.runCatchUpScoring].
///  * **Monthly report** — a scheduled Cloud Function writes a request marker
///    document (see [MonthlyWellbeingReportService.requestDocId]). This service
///    reads that marker on launch and resume and runs the generation locally,
///    which needs device-local data anyway.
class WellbeingReportSchedulerService {
  WellbeingReportSchedulerService._();
  static final WellbeingReportSchedulerService instance =
      WellbeingReportSchedulerService._();

  /// Time of day (local) at which the running app scores the day that is ending.
  static const int scoringHour = 23;
  static const int scoringMinute = 59;

  /// SharedPreferences key remembering the last day catch-up scoring ran, so a
  /// user who opens the app ten times a day does not walk the retention window
  /// ten times.
  static const String _lastCatchUpDayKey = 'wellbeing_last_catch_up_day';

  Timer? _endOfDayTimer;
  bool _initialized = false;

  /// Called from `Initializer` on every cold start. Returns as soon as the
  /// timer is armed; the catch-up and monthly work continues in the background
  /// so app startup is never blocked on network calls.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _scheduleEndOfDayScoring();
    unawaited(_runScheduledWork());
  }

  /// Called when the app returns to the foreground.
  ///
  /// The OS can suspend the end-of-day timer while the app is backgrounded, and
  /// a monthly request may have arrived while the app was closed, so both are
  /// re-armed/re-checked here.
  Future<void> onAppResumed() async {
    _scheduleEndOfDayScoring();
    await _runScheduledWork();
  }

  void dispose() {
    _endOfDayTimer?.cancel();
    _endOfDayTimer = null;
    _initialized = false;
  }

  /// Scores today's messages immediately, without waiting for end of day.
  ///
  /// Pass [force] to overwrite a score that was already taken for today.
  Future<double?> scoreTodayNow({bool force = false}) =>
      DailySentimentScoringService.instance
          .scoreDay(DateTime.now(), force: force);

  /// Whether the Cloud Function has asked for a report this month and the
  /// device has not produced one yet.
  Future<bool> hasPendingMonthlyRequest() async {
    if (FirebaseAuth.instance.currentUser == null) return false;
    try {
      final doc = await FirebaseFirestore.instance
          .collection(MonthlyWellbeingReportService.requestCollection)
          .doc(MonthlyWellbeingReportService.requestDocId)
          .get();
      if (!doc.exists) return false;

      final requestedMonth = doc.data()?['month'] as String?;
      // A marker written without a month (older deploy) is still honoured.
      if (requestedMonth == null) return true;
      if (requestedMonth != monthKeyOf(DateTime.now())) return false;

      return !await MonthlyWellbeingReportService.instance
          .hasReportForMonth(requestedMonth);
    } catch (e) {
      debugPrint(
        'WellbeingReportSchedulerService.hasPendingMonthlyRequest: Error - $e',
      );
      return false;
    }
  }

  Future<void> _runScheduledWork() async {
    await _catchUpMissedDays();
    await _generateReportIfRequested();
  }

  /// Scores every past day in the retention window that has messages but no
  /// stored score. Runs at most once per calendar day.
  Future<void> _catchUpMissedDays() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = dayKeyOf(DateTime.now());
      if (prefs.getString(_lastCatchUpDayKey) == todayKey) return;

      final scoredDays =
          await DailySentimentScoringService.instance.runCatchUpScoring();
      await prefs.setString(_lastCatchUpDayKey, todayKey);
      if (scoredDays > 0) {
        debugPrint(
          'WellbeingReportSchedulerService: back-filled $scoredDays day(s)',
        );
      }
    } catch (e) {
      debugPrint('WellbeingReportSchedulerService: catch-up failed - $e');
    }
  }

  Future<void> _generateReportIfRequested() async {
    try {
      if (!await hasPendingMonthlyRequest()) return;
      debugPrint(
        'WellbeingReportSchedulerService: monthly report requested, generating',
      );
      await MonthlyWellbeingReportService.instance.ensureMonthlyReport();
    } catch (e) {
      debugPrint(
        'WellbeingReportSchedulerService: monthly report generation failed - $e',
      );
    }
  }

  void _scheduleEndOfDayScoring() {
    _endOfDayTimer?.cancel();

    final now = DateTime.now();
    var fireAt =
        DateTime(now.year, now.month, now.day, scoringHour, scoringMinute);
    if (!fireAt.isAfter(now)) {
      fireAt = fireAt.add(const Duration(days: 1));
    }

    _endOfDayTimer = Timer(fireAt.difference(now), () async {
      try {
        final score = await scoreTodayNow();
        debugPrint(
          'WellbeingReportSchedulerService: end-of-day score for '
          '${dayKeyOf(DateTime.now())} = $score',
        );
      } catch (e) {
        debugPrint(
          'WellbeingReportSchedulerService: end-of-day scoring failed - $e',
        );
      } finally {
        // Always re-arm for the following day; a failed run must not silently
        // stop the schedule.
        _scheduleEndOfDayScoring();
      }
    });

    debugPrint(
      'WellbeingReportSchedulerService: end-of-day scoring armed in '
      '${fireAt.difference(now).inMinutes} minute(s)',
    );
  }
}
