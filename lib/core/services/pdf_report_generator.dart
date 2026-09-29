// Copyright (c) 2026 NLP digitox
//
// PdfReportGenerator — renders a WellbeingReportData snapshot into a styled,
// multi-page A4 PDF. Charts are drawn with the `pdf` package's own primitives
// (containers, stacks, positioned bars) instead of screenshotting live Flutter
// widgets: that keeps rendering deterministic and avoids the timing fragility
// of RepaintBoundary + post-frame capture.
//
// This is the piece that makes "download" actually produce a file — the old
// Export My Data button only ever showed a SnackBar.

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:nlp_digitox/models/ai_analysis_models.dart';
import 'package:nlp_digitox/models/wellbeing_report_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfReportGenerator {
  PdfReportGenerator._();

  // ── Palette ────────────────────────────────────────────────────────

  /// Brand accent — matches the app's warm orange primary.
  static const PdfColor _accent = PdfColor.fromInt(0xFFB8481F);
  static const PdfColor _accentSoft = PdfColor.fromInt(0xFFFCEFE7);
  static const PdfColor _dark = PdfColor.fromInt(0xFF1F1B16);
  static const PdfColor _grey = PdfColor.fromInt(0xFF8A8A8A);
  static const PdfColor _track = PdfColor.fromInt(0xFFE6E2DA);
  static const PdfColor _card = PdfColor.fromInt(0xFFF3F1EC);
  static const PdfColor _win = PdfColor.fromInt(0xFF2F6E4F);

  /// Height of the tallest possible bar in the daily chart.
  static const double _barChartHeight = 96;

  /// Fixed height for a row of stat cards.
  ///
  /// The stat rows use [pw.CrossAxisAlignment.stretch] so every card in a row
  /// ends up the same height. Inside a [pw.MultiPage] the incoming vertical
  /// constraint is unbounded, and `stretch` therefore hands each card
  /// `maxHeight: Infinity` — which fails the entire document with "Widget won't
  /// fit into the page as its height (Infinity) exceed a page height". Bounding
  /// the row first is what makes `stretch` safe here.
  static const double _statCardHeight = 72;

  /// Vertical space under the bars reserved for the day labels.
  static const double _axisHeight = 14;

  /// Fallback plot width used when a [pw.LayoutBuilder] reports null
  /// constraints — A4 width (595.28) minus the 28pt side margins.
  static const double _fallbackPlotWidth = 539;

  // ── Entry point ────────────────────────────────────────────────────

  /// Builds the full report and returns the raw PDF bytes.
  ///
  /// Page 1 shows the overall picture for the widest collected window; page 2
  /// holds the weekly and monthly breakdowns. Each period section prints an
  /// explicit "not enough data yet" box rather than being skipped, so the
  /// downloaded file always matches what the screen promised.
  static Future<Uint8List> generate(ReportBundle bundle) async {
    final overview = bundle.overview;
    final document = pw.Document(
      title: 'Digital Wellbeing Report',
      author: 'NLP digitox',
      creator: 'NLP digitox',
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 24, 28, 28),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        header: (context) =>
            context.pageNumber == 1 ? _header(overview) : pw.SizedBox(),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _grey),
          ),
        ),
        build: (context) => [
          // ── Page 1: overall picture ──
          pw.SizedBox(height: 14),
          _statCardsRow(overview),
          pw.SizedBox(height: 22),
          _performanceChart(overview),
          pw.SizedBox(height: 18),
          _goalComparisonSection(overview),
          pw.SizedBox(height: 22),
          _topAppsSection(overview),

          // ── Page 2: weekly + monthly ──
          pw.NewPage(),
          _periodSection(
            title: 'Weekly Report',
            subtitle: 'Last 7 days',
            data: bundle.weekly,
            enoughData: bundle.hasWeekly,
            minDays: ReportBundle.minWeeklyDays,
          ),
          pw.SizedBox(height: 26),
          _periodSection(
            title: 'Monthly Report',
            subtitle: 'Last 30 days',
            data: bundle.monthly,
            enoughData: bundle.hasMonthly,
            minDays: ReportBundle.minMonthlyDays,
            narrative: bundle.monthlyNarrative,
            // Mood and focus data are only meaningful over a full month, and
            // printing them twice would push the weekly report onto its own
            // page for no benefit.
            showMoodAndFocus: true,
          ),
        ],
      ),
    );

    return document.save();
  }

  // ── Weekly / monthly section (page 2) ───────────────────────────────

  static pw.Widget _periodSection({
    required String title,
    required String subtitle,
    required WellbeingReportData data,
    required bool enoughData,
    required int minDays,
    String? narrative,
    bool showMoodAndFocus = false,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        pw.SizedBox(height: 2),
        pw.Text(subtitle, style: const pw.TextStyle(fontSize: 9, color: _grey)),
        pw.SizedBox(height: 10),
        if (!enoughData)
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _card,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Text(
              'Not enough data yet - this report needs at least $minDays '
              'days of tracked usage.',
              style: const pw.TextStyle(fontSize: 10, color: _grey),
            ),
          )
        else ...[
          _statCardsRow(data),
          if (showMoodAndFocus) ...[
            pw.SizedBox(height: 18),
            _focusSection(data),
            pw.SizedBox(height: 18),
            _moodSection(data),
          ],
          pw.SizedBox(height: 18),
          _insightsSection(data),
          if (narrative != null && narrative.trim().isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _sectionTitle('AI Summary'),
            pw.SizedBox(height: 6),
            pw.Text(
              _plainText(narrative),
              style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 2),
            ),
          ],
        ],
      ],
    );
  }

  /// Flattens the stored AI report, which is markdown, into text the PDF font
  /// can actually draw.
  ///
  /// The built-in Helvetica base font has no glyphs for markdown punctuation or
  /// for characters outside Latin-1, which would otherwise render as blanks or
  /// throw during content encoding.
  static String _plainText(String markdown, {int maxChars = 1400}) {
    var text = markdown
        .replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '')
        .replaceAll(RegExp(r'[*_`>]'), '')
        .replaceAll(RegExp(r'^\s*[-•]\s+', multiLine: true), '- ')
        .replaceAll(RegExp(r'[^\x00-\xFF]'), '')
        .trim();
    if (text.length > maxChars) {
      text = '${text.substring(0, maxChars).trimRight()}...';
    }
    return text;
  }

  // ── Screen-time trend line chart ────────────────────────────────────

  /// A line chart of daily screen time against the goal, matching the trend
  /// shown on the in-app analysis screen.
  ///
  /// A line needs two points, so a single tracked day (or none) falls back to
  /// [_dailyUsageChart], which already has its own empty state.
  static pw.Widget _performanceChart(WellbeingReportData data) {
    final entries = data.dailyScreenTimeSec.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (entries.length < 2) return _dailyUsageChart(data);

    final dayCount = entries.length;
    final hours = [for (final entry in entries) entry.value / 3600.0];
    final goalHours = data.dailyGoalSec / 3600.0;
    final yMax = math.max(
      1,
      math.max(hours.reduce(math.max), goalHours).ceil(),
    );
    final yStep = math.max(1, (yMax / 5).ceil());
    final xStep = math.max(1, (dayCount / 7).ceil());

    final xLabels = <int>{
      for (var i = 0; i < dayCount; i += xStep) i,
      dayCount - 1,
    }.toList()
      ..sort();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Screen Time Trend'),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            _legendDot(_accent, 'Daily screen time'),
            pw.SizedBox(width: 12),
            _legendDot(_win, 'Goal'),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.SizedBox(
          height: 170,
          child: pw.Chart(
            grid: pw.CartesianGrid(
              xAxis: pw.FixedAxis<num>(
                xLabels,
                format: (value) => _dayLabel(entries[value.toInt()].key),
                textStyle: const pw.TextStyle(fontSize: 7, color: _grey),
              ),
              yAxis: pw.FixedAxis<num>(
                [for (var v = 0; v <= yMax; v += yStep) v],
                format: (value) => '${value.toInt()}h',
                divisions: true,
                divisionsColor: _track,
                textStyle: const pw.TextStyle(fontSize: 7, color: _grey),
              ),
            ),
            datasets: [
              pw.LineDataSet<pw.PointChartValue>(
                color: _accent,
                isCurved: true,
                drawSurface: true,
                surfaceOpacity: 0.12,
                drawPoints: true,
                pointSize: 2.5,
                data: [
                  for (var i = 0; i < dayCount; i++)
                    pw.PointChartValue(i.toDouble(), hours[i]),
                ],
              ),
              pw.LineDataSet<pw.PointChartValue>(
                color: _win,
                drawPoints: false,
                lineWidth: 1,
                data: [
                  pw.PointChartValue(0, goalHours),
                  pw.PointChartValue((dayCount - 1).toDouble(), goalHours),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Header ─────────────────────────────────────────────────────────

  static pw.Widget _header(WellbeingReportData data) {
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Digital Wellbeing Report',
              style: pw.TextStyle(
                fontSize: 21,
                fontWeight: pw.FontWeight.bold,
                color: _dark,
              ),
            ),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: pw.BoxDecoration(
                color: _accent,
                borderRadius: pw.BorderRadius.circular(20),
              ),
              child: pw.Text(
                'NLP digitox',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.white),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '${_formatDate(data.rangeStart)} - ${_formatDate(data.rangeEnd)}'
          '   ·   ${data.trackedDays} day'
          '${data.trackedDays == 1 ? '' : 's'} tracked',
          style: const pw.TextStyle(fontSize: 9.5, color: _grey),
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: _track, thickness: 1, height: 1),
      ],
    );
  }

  // ── Stat cards ─────────────────────────────────────────────────────

  static pw.Widget _statCard(String label, String value, {String? badge}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(11),
      decoration: pw.BoxDecoration(
        color: _card,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: _grey)),
          pw.SizedBox(height: 6),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 17,
              fontWeight: pw.FontWeight.bold,
              color: _dark,
            ),
          ),
          if (badge != null) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              badge,
              style: const pw.TextStyle(fontSize: 7.5, color: _accent),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _statCardsRow(WellbeingReportData data) => pw.SizedBox(
        height: _statCardHeight,
        child: _statCardRow(data),
      );

  /// The card row itself. Kept separate from [_statCardsRow] so the latter can
  /// bound its height — see [_statCardHeight].
  static pw.Widget _statCardRow(WellbeingReportData data) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Expanded(
          child: _statCard('Total Screen Time', '${data.totalHoursLabel}h'),
        ),
        pw.SizedBox(width: 9),
        pw.Expanded(
          child: _statCard(
            'Daily Average',
            '${data.averageHoursLabel}h',
            badge: 'Goal ${data.goalHoursLabel}h',
          ),
        ),
        pw.SizedBox(width: 9),
        pw.Expanded(
          child: _statCard(
            'Days Under Goal',
            '${data.daysUnderGoal}/${data.goalComparedDays}',
            badge: '${data.percentDaysUnderGoal}% of tracked days',
          ),
        ),
        pw.SizedBox(width: 9),
        pw.Expanded(
          child: _statCard(
            'Focus Sessions',
            '${data.focusSessionsCompleted}',
            badge: '${data.focusMinutesTotal} min focused',
          ),
        ),
      ],
    );
  }

  // ── Shared formatting helpers ──────────────────────────────────────

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  static String _hoursFromMinutes(int minutes) =>
      (minutes / 60).toStringAsFixed(1);

  static String _dayLabel(DateTime day) => '${day.day}/${day.month}';

  // ── Daily usage vs goal chart ──────────────────────────────────────

  /// Proportional bar chart drawn from primitives — one bar per tracked day,
  /// in the accent colour when the day exceeded the goal and in green when it
  /// stayed under, with the goal threshold drawn across the plot area.
  static pw.Widget _dailyUsageChart(WellbeingReportData data) {
    final entries = data.dailyScreenTimeSec.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) {
      return pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle('Daily Screen Time vs Goal'),
          pw.SizedBox(height: 6),
          pw.Text(
            'No screen-time records were found in this period.',
            style: const pw.TextStyle(fontSize: 10, color: _grey),
          ),
        ],
      );
    }

    final maxSeconds =
        entries.map((entry) => entry.value).fold<int>(1, (a, b) => a > b ? a : b);
    final goalRatio = (data.dailyGoalSec / maxSeconds).clamp(0.0, 1.0);

    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Daily Screen Time vs Goal'),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            _legendDot(_win, 'Under goal'),
            pw.SizedBox(width: 12),
            _legendDot(_accent, 'Over goal'),
            pw.SizedBox(width: 12),
            _legendDot(_track, 'Goal line'),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.LayoutBuilder(
          builder: (context, constraints) {
            final plotWidth = constraints?.maxWidth ?? _fallbackPlotWidth;
            final plotHeight = _barChartHeight + _axisHeight;
            return pw.Stack(
              children: [
                pw.SizedBox(width: plotWidth, height: plotHeight),
                pw.Positioned(
                  left: 0,
                  right: 0,
                  bottom: _axisHeight + (_barChartHeight * goalRatio),
                  child: pw.Container(height: 1.2, color: _track),
                ),
                pw.Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: pw.SizedBox(
                    width: plotWidth,
                    height: _barChartHeight + 12,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                      children: entries
                          .map((entry) => _dayBar(entry, maxSeconds, data.dailyGoalSec, entries.length))
                          .toList(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  static pw.Widget _dayBar(
    MapEntry<DateTime, int> entry,
    int maxSeconds,
    int goalSec,
    int dayCount,
  ) {
    final ratio = entry.value / maxSeconds;
    final isOverGoal = entry.value > goalSec;
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: _barWidth(dayCount),
          height: (_barChartHeight * ratio).clamp(2.0, _barChartHeight),
          decoration: pw.BoxDecoration(
            color: isOverGoal ? _accent : _win,
            borderRadius: const pw.BorderRadius.vertical(
              top: pw.Radius.circular(3),
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          _dayLabel(entry.key),
          style: const pw.TextStyle(fontSize: 6.5, color: _grey),
        ),
      ],
    );
  }

  /// Keeps bars readable on a 7-day window and thin on a 31-day one.
  static double _barWidth(int dayCount) {
    if (dayCount <= 7) return 26;
    if (dayCount <= 14) return 15;
    if (dayCount <= 31) return 8;
    return 5;
  }

  // ── Goal comparison ────────────────────────────────────────────────

  static pw.Widget _goalComparisonSection(WellbeingReportData data) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _accentSoft,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            '${data.percentDaysUnderGoal}%',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: _accent,
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'of tracked days this period, you stayed within your '
                  '${data.goalHoursLabel}h daily goal.',
                  style: const pw.TextStyle(fontSize: 10, color: _dark),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${data.daysUnderGoal} day'
                  '${data.daysUnderGoal == 1 ? '' : 's'} under   ·   '
                  '${data.daysOverGoal} day'
                  '${data.daysOverGoal == 1 ? '' : 's'} over   ·   '
                  '${data.trackedDays} tracked',
                  style: const pw.TextStyle(fontSize: 8.5, color: _grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Most time-consuming apps ───────────────────────────────────────

  static pw.Widget _topAppsSection(WellbeingReportData data) {
    final topApps = data.topApps.take(5).toList();
    if (topApps.isEmpty) {
      return pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle('Most Time-Consuming Apps'),
          pw.SizedBox(height: 6),
          pw.Text(
            'No per-app usage was recorded in this period.',
            style: const pw.TextStyle(fontSize: 10, color: _grey),
          ),
        ],
      );
    }

    final maxSeconds = topApps.first.totalScreenTimeSec;

    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Most Time-Consuming Apps'),
        pw.SizedBox(height: 10),
        pw.LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints?.maxWidth ?? _fallbackPlotWidth;
            return pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: topApps
                  .map((app) => _appUsageRow(app, maxSeconds, trackWidth))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  static pw.Widget _appUsageRow(
    AppUsageEntry app,
    int maxSeconds,
    double trackWidth,
  ) {
    final ratio = maxSeconds <= 0
        ? 0.0
        : (app.totalScreenTimeSec / maxSeconds).clamp(0.0, 1.0);
    final fillWidth = trackWidth * ratio.clamp(0.02, 1.0);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 9),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  app.appName,
                  maxLines: 1,
                  style: const pw.TextStyle(fontSize: 10, color: _dark),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                '${app.hoursLabel}h  ·  ${app.daysUsed} day'
                '${app.daysUsed == 1 ? '' : 's'}',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _dark,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 3),
          pw.Stack(
            children: [
              pw.SizedBox(width: trackWidth, height: 6),
              pw.Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: pw.SizedBox(
                  width: trackWidth,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      color: _track,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              pw.Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: pw.SizedBox(
                  width: fillWidth,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      color: _accent,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Mood analysis ──────────────────────────────────────────────────

  static pw.Widget _moodSection(WellbeingReportData data) {
    final averages = _moodAverages(data);
    final headline = data.moodTrend?.headline;
    if (averages.isEmpty && headline == null) return pw.SizedBox();

    final sortedLabels = averages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Mood Analysis'),
        pw.SizedBox(height: 6),
        if (headline != null) ...[
          pw.Text(
            headline,
            style: const pw.TextStyle(fontSize: 10, color: _dark),
          ),
          pw.SizedBox(height: 4),
        ],
        pw.Text(
          '${data.moodHistory.length} day'
          '${data.moodHistory.length == 1 ? '' : 's'} of mood data recorded.',
          style: const pw.TextStyle(fontSize: 8.5, color: _grey),
        ),
        pw.SizedBox(height: 8),
        pw.Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sortedLabels
              .map(
                (entry) => _moodChip(entry.key, entry.value),
              )
              .toList(),
        ),
      ],
    );
  }

  static pw.Widget _moodChip(String label, double percent) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: pw.BoxDecoration(
          color: _card,
          borderRadius: pw.BorderRadius.circular(20),
        ),
        child: pw.Text(
          '$label  ${percent.round()}%',
          style: const pw.TextStyle(fontSize: 9, color: _dark),
        ),
      );

  /// Averages each sentiment label across the report window. Prefers the
  /// trend's own recent window when present, and otherwise averages the raw
  /// history so the section still renders without a computable trend.
  static Map<String, double> _moodAverages(WellbeingReportData data) {
    final recent = data.moodTrend?.recentAverage;
    if (recent != null && recent.isNotEmpty) {
      return Map<String, double>.from(recent);
    }

    final history = data.moodHistory;
    if (history.isEmpty) return const <String, double>{};

    final totals = <String, double>{};
    var counted = 0;
    for (final SentimentSnapshot snapshot in history) {
      if (snapshot.sentiments.isEmpty) continue;
      counted++;
      snapshot.sentiments.forEach((label, value) {
        totals[label] = (totals[label] ?? 0) + value;
      });
    }
    if (counted == 0) return const <String, double>{};

    return totals.map(
      (label, total) => MapEntry(label, total / counted),
    );
  }

  // ── Focus sessions ─────────────────────────────────────────────────

  static pw.Widget _focusSection(WellbeingReportData data) {
    final totalSessions =
        data.focusSessionsCompleted + data.focusSessionsFailed;

    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Focus Sessions'),
        pw.SizedBox(height: 10),
        if (totalSessions == 0)
          pw.Text(
            'No focus sessions were recorded in this period.',
            style: const pw.TextStyle(fontSize: 10, color: _grey),
          )
        else
          // Height is bounded before stretching — see [_statCardHeight].
          pw.SizedBox(
            height: _statCardHeight,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Expanded(
                  child:
                      _statCard('Completed', '${data.focusSessionsCompleted}'),
                ),
                pw.SizedBox(width: 9),
                pw.Expanded(
                  child:
                      _statCard('Ended Early', '${data.focusSessionsFailed}'),
                ),
                pw.SizedBox(width: 9),
                pw.Expanded(
                  child: _statCard(
                    'Focused Time',
                    '${_hoursFromMinutes(data.focusMinutesTotal)}h',
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Insights ───────────────────────────────────────────────────────

  static pw.Widget _insightsSection(WellbeingReportData data) {
    if (data.insights.isEmpty) return pw.SizedBox();

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _track),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle('Key Insights'),
          pw.SizedBox(height: 8),
          ...data.insights.map(_insightRow),
        ],
      ),
    );
  }

  static pw.Widget _insightRow(String insight) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 5),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 5,
              height: 5,
              margin: const pw.EdgeInsets.only(top: 4, right: 7),
              decoration: const pw.BoxDecoration(
                color: _accent,
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                insight,
                style: const pw.TextStyle(
                  fontSize: 9.5,
                  color: _dark,
                  lineSpacing: 1.4,
                ),
              ),
            ),
          ],
        ),
      );

  // ── Small shared widgets ───────────────────────────────────────────

  static pw.Widget _sectionTitle(String title) => pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
          color: _dark,
        ),
      );

  static pw.Widget _legendDot(PdfColor color, String label) => pw.Row(
        children: [
          pw.Container(
            width: 7,
            height: 7,
            decoration: pw.BoxDecoration(
              color: color,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.SizedBox(width: 4),
          pw.Text(label, style: const pw.TextStyle(fontSize: 7.5, color: _grey)),
        ],
      );
}
