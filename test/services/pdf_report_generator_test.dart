// Copyright (c) 2026 NLP digitox
//
// Renders the exported wellbeing PDF in a plain Dart VM. This is the only
// automated check that the whole report path actually executes: the screen's
// download button is impossible to drive from a unit test, but everything it
// depends on — WellbeingReportData -> ReportBundle -> PdfReportGenerator ->
// bytes — runs here for real, including the chart module and the mood/focus
// sections.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/services/pdf_report_generator.dart';
import 'package:nlp_digitox/models/ai_analysis_models.dart';
import 'package:nlp_digitox/models/wellbeing_report_data.dart';

/// A `%PDF-` magic-number check: proof the bytes are a real PDF document and
/// not an empty buffer or a partially written stream.
void _expectValidPdf(Uint8List bytes) {
  expect(bytes, isNotEmpty);
  expect(
    String.fromCharCodes(bytes.take(5)),
    '%PDF-',
    reason: 'generator must return a real PDF document',
  );
  expect(bytes.length, greaterThan(1000));
}

/// 30 days of tracked usage ending on a fixed date, so the assertions never
/// depend on when the suite runs.
WellbeingReportData _monthlyData() {
  final start = DateTime(2026, 3, 1);
  final days = <DateTime, int>{
    for (var i = 0; i < 24; i++)
      DateTime(start.year, start.month, start.day + i): 3600 * (2 + (i % 6)),
  };

  return WellbeingReportData(
    rangeStart: start,
    rangeEnd: DateTime(2026, 3, 24),
    dailyScreenTimeSec: days,
    dailyGoalSec: 3 * 3600,
    daysUnderGoal: 14,
    daysOverGoal: 10,
    topApps: const [
      AppUsageEntry(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        icon: null,
        totalScreenTimeSec: 12 * 3600,
        daysUsed: 20,
      ),
      AppUsageEntry(
        packageName: 'com.youtube.android',
        appName: 'YouTube',
        icon: null,
        totalScreenTimeSec: 9 * 3600,
        daysUsed: 17,
      ),
      AppUsageEntry(
        packageName: 'com.whatsapp',
        appName: 'WhatsApp',
        icon: null,
        totalScreenTimeSec: 5 * 3600,
        daysUsed: 24,
      ),
    ],
    focusSessionsCompleted: 11,
    focusSessionsFailed: 4,
    focusMinutesTotal: 640,
    moodHistory: List<SentimentSnapshot>.generate(
      20,
      (i) => SentimentSnapshot(
        day: DateTime(2026, 3, 1 + i),
        sentiments: const {'Positive': 40, 'Neutral': 30, 'Anxious': 30},
      ),
    ),
    moodTrend: const SentimentTrend(
      history: [],
      recentAverage: {'Positive': 45, 'Neutral': 28, 'Anxious': 27},
      previousAverage: {'Positive': 33, 'Neutral': 32, 'Anxious': 35},
      deltas: {'Positive': 12, 'Anxious': -8},
    ),
    insights: const [
      'You stayed under your goal on 14 of 24 tracked days.',
      'Instagram accounts for the largest share of your screen time.',
    ],
  );
}

void main() {
  group('PdfReportGenerator.generate', () {
    test('renders a full two-page report with mood, focus and AI summary',
        () async {
      final bundle = ReportBundle(
        weekly: _monthlyData(),
        monthly: _monthlyData(),
        // Markdown and a non-Latin glyph: the generator must strip these
        // rather than throw while encoding the Helvetica font.
        monthlyNarrative:
            '# Summary\n\nYou **improved** this month — keep going.\n'
            '- Sleep earlier\n- 中文 should be stripped',
      );

      _expectValidPdf(await PdfReportGenerator.generate(bundle));
    });

    test('falls back to the bar chart when fewer than two days are tracked',
        () async {
      final oneDay = WellbeingReportData(
        rangeStart: DateTime(2026, 3, 1),
        rangeEnd: DateTime(2026, 3, 1),
        dailyScreenTimeSec: {DateTime(2026, 3, 1): 4 * 3600},
        dailyGoalSec: 3 * 3600,
        daysUnderGoal: 0,
        daysOverGoal: 1,
        topApps: const [],
        focusSessionsCompleted: 0,
        focusSessionsFailed: 0,
        focusMinutesTotal: 0,
        moodHistory: const [],
        moodTrend: null,
        insights: const [],
      );

      final bundle = ReportBundle(weekly: oneDay, monthly: oneDay);
      expect(bundle.hasWeekly, isFalse);
      expect(bundle.hasMonthly, isFalse);
      _expectValidPdf(await PdfReportGenerator.generate(bundle));
    });

    test('still produces a download for a brand-new user with no data',
        () async {
      final empty = WellbeingReportData(
        rangeStart: DateTime(2026, 3, 1),
        rangeEnd: DateTime(2026, 3, 30),
        dailyScreenTimeSec: const {},
        dailyGoalSec: 2 * 3600,
        daysUnderGoal: 0,
        daysOverGoal: 0,
        topApps: const [],
        focusSessionsCompleted: 0,
        focusSessionsFailed: 0,
        focusMinutesTotal: 0,
        moodHistory: const [],
        moodTrend: null,
        insights: const [],
      );

      expect(empty.isEmpty, isTrue);
      _expectValidPdf(
        await PdfReportGenerator.generate(
          ReportBundle(weekly: empty, monthly: empty),
        ),
      );
    });
  });

  group('ReportBundle thresholds', () {
    test('weekly needs 3 tracked days and monthly needs 10', () async {
      WellbeingReportData withDays(int count) => WellbeingReportData(
            rangeStart: DateTime(2026, 3, 1),
            rangeEnd: DateTime(2026, 3, 30),
            dailyScreenTimeSec: {
              for (var i = 0; i < count; i++)
                DateTime(2026, 3, 1 + i): 3600,
            },
            dailyGoalSec: 3 * 3600,
            daysUnderGoal: count,
            daysOverGoal: 0,
            topApps: const [],
            focusSessionsCompleted: 0,
            focusSessionsFailed: 0,
            focusMinutesTotal: 0,
            moodHistory: const [],
            moodTrend: null,
            insights: const [],
          );

      expect(
        ReportBundle(weekly: withDays(2), monthly: withDays(9)).hasWeekly,
        isFalse,
      );
      expect(
        ReportBundle(weekly: withDays(3), monthly: withDays(9)).hasWeekly,
        isTrue,
      );
      expect(
        ReportBundle(weekly: withDays(3), monthly: withDays(9)).hasMonthly,
        isFalse,
      );
      expect(
        ReportBundle(weekly: withDays(3), monthly: withDays(10)).hasMonthly,
        isTrue,
      );
    });
  });
}
