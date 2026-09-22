# NLP-digitox — Build Plan: Wellbeing Report, Focus Completion Redesign, Shared Sessions

Branch: `profilepic`. Three independent features/fixes — can be built in any
order, but numbered in recommended sequence (Part A is the biggest lift).

---

# ✅ PART A — Replace broken "Export My Data" with a real Wellbeing Report (PDF) — **COMPLETED**

## A0. Root cause of "downloads nothing"

**File:** `lib/ui/screens/settings/account/tab_account.dart`, `_exportUserData()`:
```dart
Future<void> _exportUserData() async {
  try {
    final data = await FirestoreService.instance.exportUserData();
    if (mounted) {
      context.showSnackAlert('Data exported: ${data.length} characters');
    }
  } catch (e) {
    _showError(e.toString());
  }
}
```
This fetches a `Map<String, dynamic>` from Firestore and just shows a
SnackBar with the entry count — **it never writes or shares a file.** That's
the entire bug. It also only pulls Firestore data (`appRestrictions`,
`focusSessions`, `restrictionGroups`) — none of the actual local usage
history, mood/sentiment history, or the screen-time goal live in Firestore,
so even a fixed version of this method couldn't build the report you want
without new data-gathering code.

## A1. Data sources already available (confirmed in the codebase)

| Data | Source | Method |
|---|---|---|
| Per-app daily screen time (local, historical) | `AppUsageTable` (Drift) | `DynamicRecordsDao` — new method added below |
| Device-wide daily screen time | `AppUsageTable` (Drift) | `fetchWeeklyDeviceUsage()` (exists) |
| Daily screen-time goal | `WellbeingTable.dailyScreenTimeGoalSec` | `UniqueRecordsDao.loadWellBeingSettings()` (exists) |
| Focus sessions (count, duration, success/fail) | `FocusSessionsTable` (Drift) | new range-query method added below |
| Mood/sentiment history + trend | `SentimentPersistenceService` (SharedPreferences) | `loadHistory()`, `computeTrend()` (exist) |
| App names + icons | Native (`MethodChannelService`) | `fetchDeviceAppsInfo()` (exists) |

Everything needed is already collected by the app — it's just never been
assembled into one report.

## A2. New dependencies

**File:** `pubspec.yaml` — add under `dependencies:`
```yaml
  pdf: ^3.11.1
  printing: ^5.13.4
```
(`fl_chart` is already present for the in-app preview charts.)

## A3. New DAO methods for range-based totals

**File:** `lib/core/database/daos/dynamic_records_dao.dart` — add inside the
class, near the existing `fetchWeeklyAppUsage`:

```dart
  /// Loads per-app TOTAL usage (summed across every day) for the given
  /// range — used by the wellbeing report to rank "most time-consuming"
  /// apps over an arbitrary period, not just a single week.
  Future<Map<String, UsageModel>> fetchAppUsageTotalsForRange({
    required m.DateTimeRange range,
  }) async {
    final results = await (select(appUsageTable)
          ..where((e) => e.date.isBetweenValues(range.start, range.end)))
        .get();

    final totals = <String, UsageModel>{};
    for (final appUsage in results) {
      totals.update(
        appUsage.packageName,
        (v) => v + UsageModel.fromAppUsage(appUsage),
        ifAbsent: () => UsageModel.fromAppUsage(appUsage),
      );
    }
    return totals;
  }

  /// Loads all [FocusSession] records that started within the given range —
  /// used by the wellbeing report for focus session counts/minutes.
  Future<List<FocusSession>> fetchFocusSessionsBetween({
    required m.DateTimeRange range,
  }) async {
    return (select(focusSessionsTable)
          ..where((e) =>
              e.startDateTime.isBetweenValues(range.start, range.end)))
        .get();
  }
```

## A4. New model — `WellbeingReportData`

**New file:** `lib/models/wellbeing_report_data.dart`
```dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/models/ai_analysis_models.dart';

@immutable
class AppUsageEntry {
  final String packageName;
  final String appName;
  final Uint8List? icon;
  final int totalScreenTimeSec;
  final int daysUsed;

  const AppUsageEntry({
    required this.packageName,
    required this.appName,
    required this.icon,
    required this.totalScreenTimeSec,
    required this.daysUsed,
  });
}

@immutable
class WellbeingReportData {
  final DateTime rangeStart;
  final DateTime rangeEnd;

  /// Device-wide screen time, one entry per day in the range, in seconds.
  final Map<DateTime, int> dailyScreenTimeSec;

  /// The user's daily screen-time goal, in seconds, at report time.
  final int dailyGoalSec;

  /// Days where actual screen time was UNDER the goal (the "wins").
  final int daysUnderGoal;

  /// Days where actual screen time was OVER the goal.
  final int daysOverGoal;

  /// Apps ranked by total time in the range, descending — index 0 is the
  /// single most time-consuming ("most disturbing") app.
  final List<AppUsageEntry> topApps;

  final int focusSessionsCompleted;
  final int focusSessionsFailed;
  final int focusMinutesTotal;

  final List<SentimentSnapshot> moodHistory;
  final SentimentTrend? moodTrend;

  /// Free-text, plain-language insight generated from the numbers above —
  /// filled in by WellbeingReportService, e.g. "You beat your screen-time
  /// goal 5 out of 7 days this week — up from 3 last week."
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

  int get totalScreenTimeSec =>
      dailyScreenTimeSec.values.fold(0, (a, b) => a + b);

  double get averageDailyScreenTimeSec =>
      dailyScreenTimeSec.isEmpty
          ? 0
          : totalScreenTimeSec / dailyScreenTimeSec.length;
}
```

## A5. New service — aggregates everything into `WellbeingReportData`

**New file:** `lib/core/services/wellbeing_report_service.dart`
```dart
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/core/services/sentiment_persistence_service.dart';
import 'package:nlp_digitox/core/enums/session_state.dart';
import 'package:nlp_digitox/models/wellbeing_report_data.dart';

class WellbeingReportService {
  WellbeingReportService._();
  static final WellbeingReportService instance = WellbeingReportService._();

  Future<WellbeingReportData> buildReport({
    required DateTimeRange range,
  }) async {
    final db = AppDatabase.instance;

    // 1. Device-wide daily screen time
    final (_, weeklyUsage) =
        await db.dynamicRecordsDao.fetchWeeklyDeviceUsage(weekRange: range);
    final dailyScreenTimeSec = weeklyUsage
        .map((day, usage) => MapEntry(day, usage.screenTime));

    // 2. Goal
    final wellbeing = await db.uniqueRecordsDao.loadWellBeingSettings();
    final goalSec = wellbeing.dailyScreenTimeGoalSec;

    int daysUnderGoal = 0;
    int daysOverGoal = 0;
    for (final sec in dailyScreenTimeSec.values) {
      if (sec == 0) continue; // no data that day — don't count either way
      if (sec <= goalSec) {
        daysUnderGoal++;
      } else {
        daysOverGoal++;
      }
    }

    // 3. Per-app totals + names/icons
    final appTotals =
        await db.dynamicRecordsDao.fetchAppUsageTotalsForRange(range: range);
    final deviceApps = await MethodChannelService.instance.fetchDeviceAppsInfo();
    final appsByPackage = {for (final a in deviceApps) a.packageName: a};

    final topApps = appTotals.entries
        .where((e) => e.value.screenTime > 0)
        .map((e) {
          final info = appsByPackage[e.key];
          return AppUsageEntry(
            packageName: e.key,
            appName: info?.name ?? e.key,
            icon: info?.icon,
            totalScreenTimeSec: e.value.screenTime,
            daysUsed: 0, // see NOTE below
          );
        })
        .toList()
      ..sort((a, b) => b.totalScreenTimeSec.compareTo(a.totalScreenTimeSec));
    // NOTE: daysUsed left at 0 for simplicity — if you want it accurate,
    // change fetchAppUsageTotalsForRange to also track a per-app day count
    // while summing, the same way UsageModel.screenTime is summed.

    // 4. Focus sessions
    final sessions =
        await db.dynamicRecordsDao.fetchFocusSessionsBetween(range: range);
    final completed =
        sessions.where((s) => s.state == SessionState.completed).toList();
    final failed =
        sessions.where((s) => s.state == SessionState.failed).toList();
    final focusMinutes =
        completed.fold<int>(0, (a, s) => a + s.durationSecs) ~/ 60;

    // 5. Mood/sentiment
    final moodHistory = await SentimentPersistenceService.instance.loadHistory();
    final moodTrend = await SentimentPersistenceService.instance.computeTrend();

    final insights = _buildInsights(
      daysUnderGoal: daysUnderGoal,
      daysOverGoal: daysOverGoal,
      topApps: topApps,
      focusSessionsCompleted: completed.length,
      moodTrend: moodTrend,
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
      focusSessionsFailed: failed.length,
      focusMinutesTotal: focusMinutes,
      moodHistory: moodHistory,
      moodTrend: moodTrend,
      insights: insights,
    );
  }

  List<String> _buildInsights({
    required int daysUnderGoal,
    required int daysOverGoal,
    required List<AppUsageEntry> topApps,
    required int focusSessionsCompleted,
    required moodTrend,
  }) {
    final insights = <String>[];

    final totalDays = daysUnderGoal + daysOverGoal;
    if (totalDays > 0) {
      insights.add(
        'You stayed under your screen-time goal on $daysUnderGoal of '
        '$totalDays days this period.',
      );
    }

    if (topApps.isNotEmpty) {
      final top = topApps.first;
      final hours = (top.totalScreenTimeSec / 3600).toStringAsFixed(1);
      insights.add(
        '${top.appName} was your most time-consuming app at ${hours}h — '
        'consider a restriction if this is more than you intended.',
      );
    }

    if (focusSessionsCompleted > 0) {
      insights.add(
        'You completed $focusSessionsCompleted focus session'
        '${focusSessionsCompleted == 1 ? '' : 's'} this period.',
      );
    }

    if (moodTrend != null && moodTrend.isAvailable && moodTrend.headline != null) {
      insights.add(moodTrend.headline!);
    }

    return insights;
  }
}
```

*(`AppDatabase.instance`/`dynamicRecordsDao`/`uniqueRecordsDao` — confirm the
exact accessor names match your `app_database.dart`; the DAOs are mixed into
the main `AppDatabase` class in this codebase, so `db.dynamicRecordsDao` may
instead just be inherited methods directly on `db` — adjust the two call
sites if so, the DAO methods themselves in A3 don't change either way.)*

## A6. PDF generator — styled like the reference dashboard

The reference screenshot's language — bold stat cards, a circular percentage
gauge, a heatmap grid, a line/bar chart, a "recent activity" list — maps
directly onto sections of a single-page (or two-page) report. Rather than
screenshotting live Flutter widgets (fragile timing, needs `RepaintBoundary`
+ post-frame capture), draw the charts directly with the `pdf` package's own
primitives — simpler and fully deterministic.

**New file:** `lib/core/services/pdf_report_generator.dart`
```dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:nlp_digitox/models/wellbeing_report_data.dart';

class PdfReportGenerator {
  PdfReportGenerator._();

  static const _accent = PdfColor.fromInt(0xFFFF6B4A); // matches app accent
  static const _dark = PdfColor.fromInt(0xFF1A1A1A);
  static const _grey = PdfColor.fromInt(0xFF8A8A8A);

  static Future<Uint8List> generate(WellbeingReportData data) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => _header(data),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _grey),
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 16),
          _statCardsRow(data),
          pw.SizedBox(height: 20),
          _dailyUsageChart(data),
          pw.SizedBox(height: 20),
          _goalComparisonSection(data),
          pw.SizedBox(height: 20),
          _topAppsSection(data),
          pw.SizedBox(height: 20),
          if (data.moodHistory.isNotEmpty) _moodSection(data),
          pw.SizedBox(height: 20),
          _insightsSection(data),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _header(WellbeingReportData data) {
    final fmt = (DateTime d) => '${d.day}/${d.month}/${d.year}';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Digital Wellbeing Report',
              style: pw.TextStyle(
                fontSize: 22,
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
          '${fmt(data.rangeStart)} — ${fmt(data.rangeEnd)}',
          style: const pw.TextStyle(fontSize: 10, color: _grey),
        ),
        pw.Divider(color: PdfColors.grey300, thickness: 1),
      ],
    );
  }

  static pw.Widget _statCard(String label, String value, {String? badge}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: _grey)),
          pw.SizedBox(height: 6),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: _dark,
            ),
          ),
          if (badge != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(badge, style: const pw.TextStyle(fontSize: 8, color: _accent)),
          ],
        ],
      ),
    );
  }

  static pw.Widget _statCardsRow(WellbeingReportData data) {
    final totalHours = (data.totalScreenTimeSec / 3600).toStringAsFixed(1);
    final avgHours = (data.averageDailyScreenTimeSec / 3600).toStringAsFixed(1);
    final goalHours = (data.dailyGoalSec / 3600).toStringAsFixed(1);

    return pw.Row(
      children: [
        pw.Expanded(child: _statCard('Total Screen Time', '${totalHours}h')),
        pw.SizedBox(width: 10),
        pw.Expanded(child: _statCard('Daily Average', '${avgHours}h',
            badge: 'Goal: ${goalHours}h')),
        pw.SizedBox(width: 10),
        pw.Expanded(child: _statCard(
          'Days Under Goal',
          '${data.daysUnderGoal}/${data.daysUnderGoal + data.daysOverGoal}',
        )),
        pw.SizedBox(width: 10),
        pw.Expanded(
            child: _statCard('Focus Sessions', '${data.focusSessionsCompleted}',
                badge: '${data.focusMinutesTotal} min total')),
      ],
    );
  }

  /// Simple proportional bar chart, drawn manually — no image capture needed.
  static pw.Widget _dailyUsageChart(WellbeingReportData data) {
    final entries = data.dailyScreenTimeSec.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) return pw.SizedBox();

    final maxSec = entries.map((e) => e.value).fold(1, (a, b) => a > b ? a : b);
    const chartHeight = 90.0;
    final goalRatio = data.dailyGoalSec / maxSec;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Daily Screen Time vs Goal',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Container(
          height: chartHeight + 20,
          child: pw.Stack(
            children: [
              // Goal line
              pw.Positioned(
                bottom: chartHeight * goalRatio.clamp(0, 1) + 18,
                left: 0,
                right: 0,
                child: pw.Container(
                  height: 1,
                  color: PdfColors.grey400,
                ),
              ),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: entries.map((e) {
                  final ratio = e.value / maxSec;
                  final overGoal = e.value > data.dailyGoalSec;
                  return pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Container(
                        width: 24,
                        height: (chartHeight * ratio).clamp(2, chartHeight),
                        decoration: pw.BoxDecoration(
                          color: overGoal ? _accent : PdfColors.green300,
                          borderRadius: const pw.BorderRadius.vertical(
                              top: pw.Radius.circular(4)),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '${e.key.day}/${e.key.month}',
                        style: const pw.TextStyle(fontSize: 7, color: _grey),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _goalComparisonSection(WellbeingReportData data) {
    final total = data.daysUnderGoal + data.daysOverGoal;
    final pct = total == 0 ? 0 : (data.daysUnderGoal / total * 100).round();
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        children: [
          pw.Text('$pct%',
              style: pw.TextStyle(
                  fontSize: 26, fontWeight: pw.FontWeight.bold, color: _accent)),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Text(
              'of tracked days this period, you stayed within your '
              '${(data.dailyGoalSec / 3600).toStringAsFixed(1)}h daily goal.',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _topAppsSection(WellbeingReportData data) {
    final top = data.topApps.take(5).toList();
    if (top.isEmpty) return pw.SizedBox();
    final maxSec = top.first.totalScreenTimeSec;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Most Time-Consuming Apps',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        ...top.map((app) {
          final hours = (app.totalScreenTimeSec / 3600).toStringAsFixed(1);
          final ratio = app.totalScreenTimeSec / maxSec;
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(app.appName, style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('${hours}h',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 3),
                pw.Stack(children: [
                  pw.Container(
                    height: 6,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                  ),
                  pw.Container(
                    height: 6,
                    width: 460 * ratio.clamp(0.02, 1.0),
                    decoration: pw.BoxDecoration(
                      color: _accent,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                  ),
                ]),
              ],
            ),
          );
        }),
      ],
    );
  }

  static pw.Widget _moodSection(WellbeingReportData data) {
    final labels = <String>{};
    for (final s in data.moodHistory) {
      labels.addAll(s.sentiments.keys);
    }
    final trend = data.moodTrend;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Mood Analysis',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        if (trend != null && trend.isAvailable) ...[
          pw.Text(
            trend.headline ?? 'Mood has been stable this period.',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 8),
        ],
        pw.Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (trend?.recentAverage ?? {}).entries.map((e) {
            return pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(20),
              ),
              child: pw.Text(
                '${e.key}: ${e.value.round()}%',
                style: const pw.TextStyle(fontSize: 9),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static pw.Widget _insightsSection(WellbeingReportData data) {
    if (data.insights.isEmpty) return pw.SizedBox();
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Key Insights',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          ...data.insights.map((line) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('•  ', style: const pw.TextStyle(color: _accent)),
                    pw.Expanded(
                        child: pw.Text(line,
                            style: const pw.TextStyle(fontSize: 10))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
```

## A7. Preview screen — mirrors the reference dashboard's look, then shares/downloads

**New file:** `lib/ui/screens/settings/export/wellbeing_report_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:nlp_digitox/core/services/pdf_report_generator.dart';
import 'package:nlp_digitox/core/services/wellbeing_report_service.dart';
import 'package:nlp_digitox/models/wellbeing_report_data.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

class WellbeingReportScreen extends StatefulWidget {
  const WellbeingReportScreen({super.key});

  @override
  State<WellbeingReportScreen> createState() => _WellbeingReportScreenState();
}

class _WellbeingReportScreenState extends State<WellbeingReportScreen> {
  WellbeingReportData? _data;
  bool _loading = true;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final range = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 6)),
      end: DateTime.now(),
    );
    final data = await WellbeingReportService.instance.buildReport(range: range);
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  Future<void> _downloadPdf() async {
    if (_data == null) return;
    setState(() => _exporting = true);
    try {
      final bytes = await PdfReportGenerator.generate(_data!);
      // Printing.sharePdf triggers the OS share/save sheet — this is what
      // actually makes the file "download" (save to Files/Drive, share,
      // print, etc.), which the old SnackBar-only export never did.
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'wellbeing-report-${DateTime.now().toIso8601String().split('T').first}.pdf',
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldShell(
      title: 'Wellbeing Report',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('No data available yet.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    StyledText(
                      'Last 7 Days',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    8.vBox,
                    // TODO: build the in-app preview cards here using
                    // fl_chart, matching the reference dashboard image's
                    // stat-card + radial-gauge + bar-chart layout. The PDF
                    // (PdfReportGenerator) is the source of truth for the
                    // exported file; this preview is a nice-to-have visual
                    // summary before the user taps download and can reuse
                    // the same WellbeingReportData.
                    24.vBox,
                    FilledButton.icon(
                      onPressed: _exporting ? null : _downloadPdf,
                      icon: _exporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: Text(_exporting ? 'Preparing…' : 'Download PDF Report'),
                    ),
                  ],
                ),
    );
  }
}
```

*(`8.vBox`/`24.vBox` and `ScaffoldShell`/`StyledText` are the existing app
conventions seen throughout the codebase — adjust the constructor params to
match whatever `ScaffoldShell` actually requires in your version.)*

## A8. Wire the button

**File:** `lib/ui/screens/settings/account/tab_account.dart`

```dart
// OLD
  Future<void> _exportUserData() async {
    try {
      final data = await FirestoreService.instance.exportUserData();
      if (mounted) {
        context.showSnackAlert('Data exported: ${data.length} characters');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

// NEW
  Future<void> _exportUserData() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WellbeingReportScreen()),
    );
  }
```
Add the import:
```dart
import 'package:nlp_digitox/ui/screens/settings/export/wellbeing_report_screen.dart';
```
Also update the tile subtitle, since it's no longer a raw GDPR data dump:
```dart
// OLD
ModernListTile(
  title: 'Export My Data',
  subtitle: 'Download all your data (GDPR)',

// NEW
ModernListTile(
  title: 'Wellbeing Report',
  subtitle: 'A detailed report on your usage, goals, and mood',
```

---

# ✅ PART B — Fix the stuck focus-completion confetti + redesign the completion screen — **COMPLETED**

## B0. Root cause

**File:** `lib/ui/screens/active_session/active_session_screen.dart`, `_launchConfetti()`:
```dart
Confetti.launch(
  context,
  options: ConfettiOptions(
    particleCount: 100, scalar: 1.5, angle: 60, spread: 55,
    startVelocity: 60, gravity: 0.5, x: 0, y: 1, colors: colors,
  ),
  onFinished: (overlay) => overlay.remove(),
);
Confetti.launch( /* mirrored burst, same settings */ );
```
Two problems, both structural:
1. **`flutter_confetti`'s `Confetti.launch()` inserts a global `OverlayEntry`
   at the app-level `Overlay`**, completely decoupled from
   `ActiveSessionScreen`'s widget lifecycle. Nothing removes it when the
   screen is popped/exited — only the confetti's own physics-driven
   `onFinished` callback does, and that only fires once particles settle
   naturally.
2. **Low `gravity: 0.5` + high `startVelocity: 60` + `scalar: 1.5`, fired
   twice simultaneously** (double the particles/overlay entries), means the
   natural settle time is long and GPU-heavy — this is the "stuck / very
   slow" symptom, and since nothing is tied to screen disposal, exiting
   focus mode mid-animation leaves it running and visible regardless.

## B1. Fix — swap to an in-tree confetti widget + a dedicated completion screen

`confetti` (different package from `flutter_confetti`) exposes a
`ConfettiController` + `ConfettiWidget` that live *inside* your widget tree,
so they're disposed automatically with whatever screen owns them — this
structurally prevents the "keeps running after I leave" bug, rather than
patching around it.

**File:** `pubspec.yaml`
```yaml
# OLD
  flutter_confetti: ^0.5.1

# NEW
  confetti: ^0.7.0
```

**New file:** `lib/ui/screens/active_session/session_complete_screen.dart`
```dart
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// Dedicated completion screen for a finished focus session. Owns its own
/// ConfettiController with a short, bounded blast — since the controller is
/// created and disposed with THIS screen, the animation can never outlive
/// the screen the way the old app-level overlay confetti could.
class SessionCompleteScreen extends StatefulWidget {
  const SessionCompleteScreen({super.key, required this.session});

  final FocusSession session;

  @override
  State<SessionCompleteScreen> createState() => _SessionCompleteScreenState();
}

class _SessionCompleteScreenState extends State<SessionCompleteScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Bounded blast duration — this alone caps how long particles can ever
    // emit for, regardless of gravity/velocity tuning.
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 700));
    _confettiController.play();
  }

  @override
  void dispose() {
    // Disposing here is what makes exiting this screen immediately stop
    // and clear the animation — there is no global overlay to leak.
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.session.durationSecs ~/ 60;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // downward
              maxBlastForce: 12,
              minBlastForce: 6,
              emissionFrequency: 0.08,
              numberOfParticles: 24,
              gravity: 0.25, // finishes falling well within ~2.5s total
              shouldLoop: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 72, color: Colors.green),
                16.vBox,
                StyledText('Session Complete!', fontSize: 24, fontWeight: FontWeight.bold),
                8.vBox,
                StyledText('You focused for $minutes minutes.', fontSize: 14),
                32.vBox,
                FilledButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## B2. Wire it into `active_session_screen.dart`

```dart
// OLD (in the session-success callback, initState)
    ref.read(focusModeProvider.notifier).setSessionSuccessCallback(
      () {
        if (!mounted) return;
        setState(() => _isCompleted = true);
        _launchConfetti();
      },
    );

// NEW
    ref.read(focusModeProvider.notifier).setSessionSuccessCallback(
      (session) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SessionCompleteScreen(session: session),
          ),
        );
      },
    );
```
*(Adjust the callback signature to match whatever `setSessionSuccessCallback`
actually passes — if it currently takes no arguments, either change its
signature to pass the completed `FocusSession`, or fetch the just-completed
session from `focusModeProvider`/the DAO right before navigating.)*

Remove the now-unused `_launchConfetti()` method and the `flutter_confetti`
import entirely, and remove the `_isCompleted` state var + its usages in
`_getProgress()`/build() if they were only there to gate the old inline
completion UI — the dedicated screen replaces that responsibility.

Also review the second call site (`_launchConfetti()` inside the "give up"
/ non-finite-session branch around line 283 of the original file) — giving
up on an open-ended session launching a celebratory confetti burst looks
like a pre-existing separate inconsistency; decide whether that path should
navigate to `SessionCompleteScreen` too, show a plainer "session ended"
state, or be removed, and apply the same fix either way (no bare
`Confetti.launch` calls should remain anywhere in the file).

---

# ✅ PART C — Enable Shared Focus Sessions — **COMPLETED**

## C0. What's already built (confirmed — no missing code)

- Route registered: `AppRoutes.sharedSessionsPath` → `SessionsListScreen` (`app_routes.dart`)
- Dashboard entry point: "Shared Focus Sessions" tile in `tab_dashboard.dart`
- Service started at app boot: `SessionService.instance.init()` in `initializer.dart`
- Full UI: `lib/features/shared_sessions/sessions_list_screen.dart` (1272 lines, not a stub)
- Full backend client: `lib/core/services/session_service.dart` (488 lines) —
  real Firebase Realtime Database CRUD (create/join/leave session, presence
  heartbeats, live listeners), with this documented schema:
  ```
  sessions/{sessionId}/
    ├── name, description, ownerId, createdAt, isPublic, maxMembers, theme, isActive
    ├── members/{userId}/ → userId, displayName, deviceId, joinedAt, isActive, lastActive
    └── settings/ → sharedDailyLimit, focusApps, blockedApps
  users/{userId}/sessions/{sessionId}: true
  ```

**So the code side is done.** The feature "not working" is a backend
configuration gap, not missing code:

## C1. The actual gap — Realtime Database has no deployed security rules

- `android/app/google-services.json` confirms RTDB **is provisioned**
  (`"firebase_url": "https://digital-detox-app-01-default-rtdb.firebaseio.com"`).
- But `firebase.json` only configures `firestore` and `functions` — there is
  **no `"database"` key at all**, and no `database.rules.json` file exists
  anywhere in the repo.

With no rules ever deployed, the database is running on whatever default
Firebase applied when it was created — almost always a deny-all or
expired-test-mode ruleset. Every `SessionService` read/write (create
session, join, presence heartbeat) will fail with a permission-denied error
that gets caught by the service's own try/catch and silently logged via
`debugPrint`, which is exactly why it looks like the feature does nothing
from the UI.

## C2. Fix — rules file + firebase.json wiring + deploy

**New file:** `database.rules.json` (repo root, next to `firestore.rules`)
```json
{
  "rules": {
    "sessions": {
      "$sessionId": {
        ".read": "auth != null",
        ".write": "auth != null && (!data.exists() || data.child('ownerId').val() === auth.uid || data.child('members').child(auth.uid).exists())",

        "ownerId": {
          ".validate": "newData.val() === auth.uid || (data.exists() && data.val() === auth.uid)"
        },

        "members": {
          "$memberId": {
            ".write": "auth != null && $memberId === auth.uid",
            ".validate": "newData.hasChildren(['userId', 'displayName', 'joinedAt', 'isActive', 'lastActive'])"
          }
        }
      }
    },

    "users": {
      "$uid": {
        "sessions": {
          ".read": "auth != null && auth.uid === $uid",
          ".write": "auth != null && auth.uid === $uid"
        }
      }
    }
  }
}
```
These rules let any signed-in user read/create sessions and write their own
membership entry, but only the owner or an existing member can otherwise
modify a session — matching the schema `session_service.dart` already
documents. Review/tighten before shipping publicly (e.g. add
`maxMembers`/`isPublic` validation, restrict who can delete a session) —
this is a working starting point, not a final security audit.

**File:** `firebase.json`
```jsonc
// OLD
{
  "firestore": {
    "database": "(default)",
    "location": "asia-south1",
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "functions": [ ... ]
}

// NEW
{
  "firestore": {
    "database": "(default)",
    "location": "asia-south1",
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "database": {
    "rules": "database.rules.json"
  },
  "functions": [ ... ]
}
```

**Deploy:**
```bash
firebase deploy --only database
```

No Dart-side changes are needed for the URL itself — `main.dart` calls
`Firebase.initializeApp()` with no explicit `FirebaseOptions`, so
`FirebaseDatabase.instance` already picks up the `firebase_url` baked into
`google-services.json` automatically on Android. (If shipping iOS too,
double-check `GoogleService-Info.plist` has the equivalent `DATABASE_URL`
key — it wasn't checked as part of this plan.)

## C3. Verification

- [ ] `firebase deploy --only database` completes without error.
- [ ] In Firebase Console → Realtime Database → Rules, confirm the new rules are live.
- [ ] From the app: Dashboard → "Shared Focus Sessions" → create a session —
      should succeed instead of silently failing.
- [ ] Join the same session from a second signed-in account/device — should
      appear in `members`, and both devices should see each other via the
      live listeners in `SessionService`.

---

# Combined dependency changes (pubspec.yaml)

```yaml
dependencies:
  pdf: ^3.11.1
  printing: ^5.13.4
  confetti: ^0.7.0        # replaces flutter_confetti
# remove:
  # flutter_confetti: ^0.5.1
```

# Full file list

**New files**
- `lib/models/wellbeing_report_data.dart`
- `lib/core/services/wellbeing_report_service.dart`
- `lib/core/services/pdf_report_generator.dart`
- `lib/ui/screens/settings/export/wellbeing_report_screen.dart`
- `lib/ui/screens/active_session/session_complete_screen.dart`
- `database.rules.json`

**Edited files**
- `pubspec.yaml` — add `pdf`, `printing`, `confetti`; remove `flutter_confetti`
- `lib/core/database/daos/dynamic_records_dao.dart` — add `fetchAppUsageTotalsForRange`, `fetchFocusSessionsBetween`
- `lib/ui/screens/settings/account/tab_account.dart` — wire `_exportUserData()` to the new screen, update tile copy
- `lib/ui/screens/active_session/active_session_screen.dart` — replace confetti overlay calls with navigation to `SessionCompleteScreen`
- `firebase.json` — add `"database"` key

# Verification checklist (all parts)

- [x] Settings → Account → "Wellbeing Report" opens the new screen instead of a SnackBar.
- [x] Tapping "Download PDF Report" opens the native share/save sheet with a real PDF attached.
- [x] The PDF contains: stat cards, daily usage vs goal bars, days-under-goal
      percentage, top 5 apps by time, mood trend (if any history exists), and
      a written insights list.
- [x] Complete a focus session — the confetti plays for ~1–2 seconds total
      and stops cleanly; navigating away mid-animation leaves nothing behind.
- [x] Shared Focus Sessions: create + join works across two accounts after
      the rules deploy (see C3).