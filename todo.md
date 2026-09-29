## PHASE 1

Checking the Realtime Database rules next, since session creation writes there. After that I'll look at the report export code.Still going: shared sessions is narrowed to how errors get swallowed and hidden. Now I'm reading the report export code (`wellbeing_report_screen.dart`) to see why the download does nothing.I couldn't run the app here, so I can't confirm the failure at runtime. For shared sessions I found what makes the Create button fail without telling you why, and the two most likely causes. For the report I found the exact defects. The code below is written from reading your repo and hasn't been compiled, so run `flutter analyze` after pasting it.

## 1. Shared session: Create does nothing

The flow itself is correct on paper. It goes from `_CreateSessionSheet._submit()` to `CreateSessionNotifier` to `SessionService.createSession()`, which writes to Realtime Database. Your last commit already fixed the old bug where the button was disabled from the start. The problems are in how it fails:

1. **Errors are invisible.** `_submit()` reports failures with a `SnackBar`. The bottom sheet is drawn on top of the screen's Scaffold, so the snackbar renders underneath the sheet. Any error, such as a permission failure, not signed in, or no network, looks like "the button does nothing".
2. **The writes have no timeout.** `createSession` does three sequential `await set(...)` calls. A Realtime Database `set()` only completes when the server acknowledges it. If the connection is bad, or the write is stuck, the button just spins with nothing shown.
3. **The rules must be live on the project.** The Realtime Database rules are in `database.rules.json`. `firebase.json` points at that file, but `firebase.rules.json` is an older leftover that isn't used, so ignore it. If `database.rules.json` was never deployed, every write to `sessions/...` is rejected with `PERMISSION_DENIED`, and problem 1 hides it. I think this is the most likely trigger.

**To confirm in 30 seconds:** run the app with `flutter run`, tap Create, and look for `SessionService: Error creating session:` in the console.
- `permission-denied`: run `firebase deploy --only database:rules`.
- `User not authenticated`: sign in again.
- Nothing printed and the spinner never stops: it's a connection or timeout problem, and the fix below handles it.

### Fix A: `lib/core/services/session_service.dart`

In `createSession`, replace the whole `if (_isFirebaseAvailable && _database != null) { ... }` write block with one atomic multi-path write. That is one round trip, and either everything is written or nothing is.

```dart
if (_isFirebaseAvailable && _database != null) {
  Map<String, Object?> clean(Map<String, dynamic> m) =>
      Map.fromEntries(m.entries.where((e) => e.value != null))
          .cast<String, Object?>();

  final updates = <String, Object?>{
    'sessions/$sessionId': clean(session.toMap()),
    'users/$userId/sessions/$sessionId': true,
    if (isPublic)
      'publicSessions/$sessionId': clean({
        'name': name,
        'theme': theme,
        'memberCount': 1,
        'createdAt': now.toIso8601String(),
      }),
  };

  try {
    await _database!
        .ref()
        .update(updates)
        .timeout(const Duration(seconds: 15));
  } on TimeoutException {
    throw Exception(
        'Could not reach the server. Check your connection and try again.');
  }
}
```

The `dart:async` import is already at the top of the file.

### Fix B: `_CreateSessionSheetState` in `sessions_list_screen.dart`

This shows the error inside the sheet, where the user can see it.

```dart
String? _error;

String _friendly(Object e) {
  final s = e.toString();
  debugPrint('Create session failed: $s');
  if (s.contains('permission-denied') || s.contains('PERMISSION_DENIED')) {
    return 'The server rejected this request (permission denied).';
  }
  if (s.contains('not authenticated')) {
    return 'Please sign in again to create a session.';
  }
  if (s.contains('Could not reach the server')) {
    return 'Could not reach the server. Check your connection and try again.';
  }
  return 'Could not create the session. Please try again.';
}

Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  FocusScope.of(context).unfocus();
  setState(() => _error = null);

  await ref.read(createSessionProvider.notifier).createSession(
        name: _nameCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        isPublic: _isPublic,
      );
  if (!mounted) return;

  final result = ref.read(createSessionProvider);
  if (result.hasError) {
    setState(() => _error = _friendly(result.error!));
    return;
  }

  ref.invalidate(userSessionsProvider);
  ref.invalidate(publicSessionsProvider);
  Navigator.pop(context);
}
```

Then add this right after the `FilledButton`'s `SizedBox` in `build`:

```dart
if (_error != null)
  Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Text(
      _error!,
      style: TextStyle(color: theme.colorScheme.error),
    ),
  ),
```

I would also wrap the sheet's `Column` in a `SingleChildScrollView`, so the button stays reachable when the keyboard is open.

---

## 2. Report download

Here is what's wrong in `lib/ui/screens/settings/export/wellbeing_report_screen.dart` and `pdf_report_generator.dart`:

1. **No error handling.** `_downloadPdf` is a `try/finally` with no `catch`, and `_load` has none either. If anything throws, the user sees nothing, or the loading spinner never ends.
2. **It doesn't save a file.** `Printing.sharePdf` only opens the system share sheet. Your project already saves files properly in the database export (`FilePicker.platform.saveFile(fileName, bytes)`), so I reuse that pattern.
3. **The PDF layout doesn't match what you want.** It's one long flowing document with mood, focus and insights mixed in, and there is no weekly or monthly page.
4. **The date range is off.** The screen builds its 7-day range with `DateTime.now().subtract(6 days)`, which keeps the time of day and clips the first day. `lastDaysRange()` already does this correctly.

### The new report

- **Page 1:** stat cards, a screen-time trend line chart against the goal (like the analysis screen), the goal comparison, and the most-used apps.
- **Page 2:** a Weekly Report (last 7 days) and a Monthly Report (last 30 days, plus the AI narrative if one exists). If there isn't enough data, that section shows an empty-state box, and the file still downloads. The thresholds are 3 tracked days for weekly and 10 for monthly, and you can change them.

### Step 1: add to `lib/models/wellbeing_report_data.dart`

```dart
/// Everything the exported PDF needs: page 1 uses [overview], page 2 uses
/// [weekly] and [monthly].
@immutable
class ReportBundle {
  static const int minWeeklyDays = 3;
  static const int minMonthlyDays = 10;

  final WellbeingReportData weekly;   // last 7 days
  final WellbeingReportData monthly;  // last 30 days
  final String? monthlyNarrative;     // stored AI report (markdown), if any

  const ReportBundle({
    required this.weekly,
    required this.monthly,
    this.monthlyNarrative,
  });

  /// Page 1 shows whatever exists in the last 30 days.
  WellbeingReportData get overview => monthly;

  bool get hasWeekly => weekly.trackedDays >= minWeeklyDays;
  bool get hasMonthly => monthly.trackedDays >= minMonthlyDays;
}
```

### Step 2: replace `wellbeing_report_screen.dart`

```dart
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:nlp_digitox/core/services/monthly_wellbeing_report_service.dart';
import 'package:nlp_digitox/core/services/pdf_report_generator.dart';
import 'package:nlp_digitox/core/services/wellbeing_report_service.dart';
import 'package:nlp_digitox/models/wellbeing_report_data.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/ui/screens/settings/export/monthly_report_section.dart';

class WellbeingReportScreen extends StatefulWidget {
  const WellbeingReportScreen({super.key});

  @override
  State<WellbeingReportScreen> createState() => _WellbeingReportScreenState();
}

class _WellbeingReportScreenState extends State<WellbeingReportScreen> {
  ReportBundle? _bundle;
  bool _loading = true;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<ReportBundle> _collect() async {
    final svc = WellbeingReportService.instance;
    final weekly = await svc.buildReport(range: svc.lastDaysRange(7));
    final monthly = await svc.buildReport(range: svc.lastDaysRange(30));

    String? narrative;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      narrative =
          await MonthlyWellbeingReportService.instance.getLatestReport(uid);
    }
    return ReportBundle(
        weekly: weekly, monthly: monthly, monthlyNarrative: narrative);
  }

  Future<void> _load() async {
    try {
      final bundle = await _collect();
      if (!mounted) return;
      setState(() => _bundle = bundle);
    } catch (e, st) {
      debugPrint('WellbeingReportScreen load failed: $e\n$st');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _downloadPdf() async {
    if (_exporting) return;
    setState(() => _exporting = true);

    Uint8List? bytes;
    final fileName =
        'wellbeing-report-${DateTime.now().toIso8601String().split('T').first}.pdf';

    try {
      // Re-collect so the file always reflects the latest data, and so a
      // failed first load can be retried by simply tapping the button.
      final bundle = await _collect();
      if (mounted) setState(() => _bundle = bundle);

      bytes = await PdfReportGenerator.generate(bundle);

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save wellbeing report',
        fileName: fileName,
        bytes: bytes,
      );

      if (path == null) return; // user cancelled - not an error

      // On desktop, file_picker returns a path but does not write the bytes.
      if (!(Platform.isAndroid || Platform.isIOS)) {
        await File(path).writeAsBytes(bytes);
      }
      _snack('Report saved');
    } catch (e, st) {
      debugPrint('Report export failed: $e\n$st');
      if (bytes != null) {
        // The PDF was built but saving failed: fall back to the share sheet.
        try {
          await Printing.sharePdf(bytes: bytes, filename: fileName);
          return;
        } catch (_) {}
      }
      _snack('Could not create the report. Please try again.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = _bundle;
    return ScaffoldShell(
      items: [
        NavbarItem(
          icon: Icons.analytics_rounded,
          filledIcon: Icons.analytics_rounded,
          titleText: 'Wellbeing Report',
          sliverBody: _loading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StyledText('Your report',
                                fontSize: 20, fontWeight: FontWeight.bold),
                            8.vBox,
                            StyledText(
                              'Page 1: overall stats, most-used apps and screen-time '
                              'trend.\nPage 2: weekly and monthly reports.',
                              fontSize: 12,
                              isSubtitle: true,
                            ),
                            12.vBox,
                            if (b != null) ...[
                              _StatusRow('Weekly report', b.hasWeekly),
                              _StatusRow('Monthly report', b.hasMonthly),
                              4.vBox,
                              StyledText(
                                'Sections without enough data stay empty in the PDF.',
                                fontSize: 11,
                                isSubtitle: true,
                              ),
                            ],
                            20.vBox,
                            // Always enabled: an empty report is still a valid download.
                            FilledButton.icon(
                              onPressed: _exporting ? null : _downloadPdf,
                              icon: _exporting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.download),
                              label: Text(_exporting
                                  ? 'Preparing…'
                                  : 'Download PDF Report'),
                            ),
                            32.vBox,
                            const MonthlyReportSection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool ready;
  const _StatusRow(this.label, this.ready);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Icon(ready ? Icons.check_circle : Icons.remove_circle_outline,
            size: 16, color: ready ? Colors.green : Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ${ready ? 'ready' : 'not enough data yet'}',
            style: const TextStyle(fontSize: 12)),
      ]),
    );
  }
}
```

### Step 3: `pdf_report_generator.dart`

Change the import block at the top to:

```dart
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:nlp_digitox/models/ai_analysis_models.dart';
import 'package:nlp_digitox/models/wellbeing_report_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
```

Replace `generate(...)` with this. All your existing helpers (`_header`, `_statCardsRow`, `_goalComparisonSection`, `_topAppsSection`, `_insightsSection`, `_dailyUsageChart`, `_sectionTitle`, `_legendDot`, `_dayLabel`) stay as they are.

```dart
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
        // ── PAGE 1: overall picture ──
        pw.SizedBox(height: 14),
        _statCardsRow(overview),
        pw.SizedBox(height: 22),
        _performanceChart(overview),
        pw.SizedBox(height: 18),
        _goalComparisonSection(overview),
        pw.SizedBox(height: 22),
        _topAppsSection(overview),

        // ── PAGE 2: weekly + monthly ──
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
        ),
      ],
    ),
  );

  return document.save();
}

// ── Weekly / monthly section (page 2) ────────────────────────────────

static pw.Widget _periodSection({
  required String title,
  required String subtitle,
  required WellbeingReportData data,
  required bool enoughData,
  required int minDays,
  String? narrative,
}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _sectionTitle(title),
      pw.SizedBox(height: 2),
      pw.Text(subtitle,
          style: const pw.TextStyle(fontSize: 9, color: _grey)),
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
        pw.SizedBox(height: 12),
        _insightsSection(data),
        if (narrative != null && narrative.trim().isNotEmpty) ...[
          pw.SizedBox(height: 12),
          _sectionTitle('AI Summary'),
          pw.SizedBox(height: 6),
          pw.Text(
            _plainText(narrative, maxChars: 1400),
            style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 2),
          ),
        ],
      ],
    ],
  );
}

/// The stored AI report is markdown; the PDF font can't render its markup.
static String _plainText(String markdown, {int maxChars = 1400}) {
  var s = markdown
      .replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '')
      .replaceAll(RegExp(r'[*_`>]'), '')
      .replaceAll(RegExp(r'^\s*[-•]\s+', multiLine: true), '- ')
      .replaceAll(RegExp(r'[^\x00-\xFF]'), '') // glyphs Helvetica lacks
      .trim();
  if (s.length > maxChars) s = '${s.substring(0, maxChars).trimRight()}...';
  return s;
}

// ── Line chart like the analysis screen ──────────────────────────────

static pw.Widget _performanceChart(WellbeingReportData data) {
  final entries = data.dailyScreenTimeSec.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  // 0-1 days: a line needs two points, so reuse the existing bar chart,
  // which already has its own empty state.
  if (entries.length < 2) return _dailyUsageChart(data);

  final n = entries.length;
  final hours = [for (final e in entries) e.value / 3600.0];
  final goalH = data.dailyGoalSec / 3600.0;
  final yMax = math.max(1, math.max(hours.reduce(math.max), goalH).ceil());
  final yStep = math.max(1, (yMax / 5).ceil());
  final xStep = math.max(1, (n / 7).ceil());

  final xLabels = <int>{
    for (var i = 0; i < n; i += xStep) i,
    n - 1,
  }.toList()
    ..sort();

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _sectionTitle('Screen Time Trend'),
      pw.SizedBox(height: 5),
      pw.Row(children: [
        _legendDot(_accent, 'Daily screen time'),
        pw.SizedBox(width: 12),
        _legendDot(_win, 'Goal'),
      ]),
      pw.SizedBox(height: 10),
      pw.SizedBox(
        height: 170,
        child: pw.Chart(
          grid: pw.CartesianGrid(
            xAxis: pw.FixedAxis<num>(
              xLabels,
              format: (v) => _dayLabel(entries[v.toInt()].key),
              textStyle: const pw.TextStyle(fontSize: 7, color: _grey),
            ),
            yAxis: pw.FixedAxis<num>(
              [for (var v = 0; v <= yMax; v += yStep) v],
              format: (v) => '${v.toInt()}h',
              divisions: true,
              divisionsColor: _track,
              textStyle: const pw.TextStyle(fontSize: 7, color: _grey),
            ),
          ),
          datasets: [
            pw.LineDataSet(
              color: _accent,
              isCurved: true,
              drawSurface: true,
              surfaceOpacity: 0.12,
              drawPoints: true,
              pointSize: 2.5,
              data: [
                for (var i = 0; i < n; i++)
                  pw.PointChartValue(i.toDouble(), hours[i]),
              ],
            ),
            pw.LineDataSet(
              color: _win,
              drawPoints: false,
              lineWidth: 1,
              data: [
                pw.PointChartValue(0, goalH),
                pw.PointChartValue((n - 1).toDouble(), goalH),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
```

### Things to check

- **`pw.Chart` API.** The `pdf` package's chart classes (`FixedAxis`, `LineDataSet`, `PointChartValue`) have changed slightly between versions. If `flutter analyze` complains about a named parameter, check your `pdf` version in `pubspec.lock`. Deleting the chart's optional parameters, such as `divisionsColor` or `textStyle`, is the safe way to get it compiling.
- **Non-Latin app names.** `Font.helvetica()` can't draw characters outside Latin-1, so app names in Hindi or other scripts will show blanks in the PDF. If that matters, bundle a Noto font as an asset and load it with `pw.Font.ttf(...)`.
- **Page-1 fit.** The stat cards, chart, goal comparison and top-5 apps should fit on one A4 page. If your icons make the top-apps list tall, drop `_goalComparisonSection` from page 1, or your `topAppCount` from 5 to 4.
- **Flaky connections.** If the atomic write times out while offline, Firebase may still complete it later. The user could then find a session they thought failed, so a "refresh and check My Sessions before retrying" hint is worth adding to the timeout message.

### PHASE 2

# NLP-Digitox — Re-Audit of `main` + Safety Review of Proposed Fixes

**Checked against:** `github.com/DraculaHub786/NLP-digitox`, branch `main`,
commit `2274619933ce698975142a30360c12ff86a5eb0c` (confirmed as the current
remote `HEAD` via `git ls-remote` at the time of this review — not a stale
copy).

## First: none of the 21 findings are fixed on `main` yet

I re-cloned `main` fresh and checked every one of the 21 items directly
against the file contents. **Every single one is still in its original,
unfixed state** — `android/app/build.gradle.kts` still has the hardcoded
`"android"`/`"android"` keystore passwords, `.env` is still listed under
`pubspec.yaml`'s `assets:`, `lib/config/api_keys.dart` is still missing
while five files still import it, `database.rules.json` and
`firestore.rules` are byte-for-byte what they were before. The
`profilepic` branch you merged did not touch any of these files — that PR
was the profile-picture/session/report work from earlier in this
conversation, unrelated to this list.

I also checked every branch and open PR on the remote
(`UI-enhancement`, `atharva`, `glitches`, `rebrand/digitox`,
`review/sections-c-j`, `split`, and PRs #1–#7) — none of them contain
these fixes either.

**So: nothing here is currently applied or merged.** Before doing anything
else, please check:
- Did the commit with these changes actually get pushed? (`git log
  --oneline -5` and `git status` locally, then `git push`.)
- Did you commit to a branch that was never opened as a PR / never merged?
- Was the merge itself perhaps reverted?

Everything below is written as if starting from the current `main` —
i.e. these are the fixes still waiting to be applied, reviewed for
safety, and then actually pushed.

---

## Second: your proposed fixes, reviewed for safety

You asked me to check whether the proposed solutions (from the earlier
remediation plan) are safe to apply as-is. I checked each one against
how the surrounding app code actually calls these paths. **Two of them
have real bugs that would break working features if applied exactly as
written** — flagged below with corrected versions. Everything else in the
original plan checks out and is safe to apply as proposed.

### Bug found #1 — the Firestore Phase‑1 leaderboard lockdown breaks brand‑new users

The proposed rule:
```
allow write: if request.auth != null && request.auth.uid == userId
  && request.resource.data.diff(resource.data).affectedKeys().hasOnly([...])
```
`resource.data.diff(...)` reads `resource.data` — but `resource` is
`null` on a **create** (the document doesn't exist yet), so this throws
and the whole write is denied. This would break exactly the case our
earlier leaderboard-photo fix relies on: creating a brand-new
`leaderboard/{uid}` / `weekly_leaderboard/{uid}` doc for a user's first
points or first profile photo. The corrected version below guards for
that.

### Bug found #2 — the memberCount rule breaks `leaveSession()`

The proposed rule only allows a `publicSessions/{id}/memberCount` write
from someone who is the owner **or currently listed in
`sessions/{id}/members`**. But `SessionService.leaveSession()` removes
the user from `members` *first*, then writes the new `memberCount` —
so by the time that write happens, the leaving user no longer passes
either check, and the write is silently rejected. The count would only
ever go up, never down. Fixed by reordering the app code (compute and
write the new count *before* removing the member) — included below.

Everything else — the ID-token webhook auth, the session-ownership
lockdown, the `users` read restriction, the nested badge rule deletion,
the accessibility-permission fix, the badge-month clamp, the Google
photo regex, the keystore externalization, and the API-key migration to
`String.fromEnvironment` — is correct as originally proposed. I've
reproduced all of it below with the two corrections folded in, so this
file is the single complete, safe version to apply.

---

## HIGH SEVERITY

### 1. `.env` bundled into the release build

**Confirmed still present:** `pubspec.yaml` line 102, `- .env` under `assets:`.

This is a real bug, but not quite what the title suggests — the app
already has the *right* runtime design and just has one contradicting
line. `lib/main.dart` loads `.env` via `flutter_dotenv` with a comment
saying release builds use `--dart-define-from-file` instead and won't
bundle `.env` — but Flutter's asset bundler doesn't know the difference
between debug and release; anything listed under `assets:` in
`pubspec.yaml` ships in **every** build, release included. `.gitignore`
also already has a comment confirming your editor run configs pass
`--dart-define-from-file=.env` — so removing it from assets doesn't
break your normal dev flow, only a bare terminal `flutter run` with no
dart-define flag (which should always be added anyway).

**Fix — `pubspec.yaml`:**
```yaml
flutter:
  assets:
    # - .env          # REMOVED — was shipping real secrets into release builds.
                       # Local runs must use --dart-define-from-file=.env
                       # (already the default in the IDE run configs per
                       # .gitignore's own comment).
```

**Also add to `README.md`** (so terminal-only contributors don't hit a
silent empty-key failure):
```md
## Running locally
Copy `.env.example` to `.env`, fill in your keys, then run with:
    flutter run --dart-define-from-file=.env
```

**Verify:**
```bash
flutter build apk --release
unzip -l build/app/outputs/flutter-apk/app-release.apk | grep -i '\.env'
# must print nothing
```

---

### 2. Flutter define file / invalid dotenv syntax

Not a code bug — a process check, since `.env.example` itself is valid.
**Do this once, locally:**
```bash
# 1. No quoted values in your real .env:
grep -n '="' .env && echo "FIX THESE — remove the quotes" || echo "OK"

# 2. Confirm your actual build command includes the flag:
grep -rn "dart-define-from-file" deploy_firebase.sh deploy_firebase.ps1 android/ ios/ .vscode/ 2>/dev/null
```
If your `flutter build`/`flutter run` invocations (CI included) don't
show `--dart-define-from-file=.env`, add it — otherwise every
`String.fromEnvironment(...)` key silently resolves to `''`.

---

### 3. Missing `lib/config/api_keys.dart` breaks clean builds

**Confirmed still present** — `lib/config/api_keys.dart` doesn't exist;
`ai_chatbot_service.dart`, `ai_sentiment_service.dart`,
`daily_sentiment_scoring_service.dart`, and
`monthly_wellbeing_report_service.dart` all still
`import 'package:nlp_digitox/config/api_keys.dart';`. A fresh clone or
CI machine fails to compile.

**Fix — migrate these four files to the same pattern
`profile_service.dart` already uses for Cloudinary** (no hardcoded
values, no committed file with real keys):

```dart
// Add this once per file (or better, factor into a tiny shared helper —
// see note below), replacing:
//   import 'package:nlp_digitox/config/api_keys.dart';
//   static final String _apiKey = ApiKeys.groqApiKey;

static String _apiKey = () {
  const compileTime = String.fromEnvironment('GROQ_API_KEY');
  return compileTime; // empty string when not provided — existing
                       // `.isEmpty` checks in these files already handle this
}();
```

Better: since four files need the exact same lookup,
**extract the `_cfg()` helper `profile_service.dart` already has** into
a small shared file instead of duplicating it four times:

```dart
// lib/config/env.dart — new file, no secrets in it, safe to commit
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads a config value from the compile-time constant first (what
/// `--dart-define-from-file` provides in every build), falling back to
/// the runtime-loaded `.env` map for local `flutter run` convenience.
String readEnv(String key, {String defaultValue = ''}) {
  const empty = '';
  final compileTimeValues = <String, String>{
    'GROQ_API_KEY': String.fromEnvironment('GROQ_API_KEY'),
    'GEMINI_API_KEY': String.fromEnvironment('GEMINI_API_KEY'),
    'CLOUDINARY_CLOUD_NAME': String.fromEnvironment('CLOUDINARY_CLOUD_NAME'),
    'CLOUDINARY_UPLOAD_PRESET': String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET'),
    'CLOUDINARY_CLEANUP_WEBHOOK_URL': String.fromEnvironment('CLOUDINARY_CLEANUP_WEBHOOK_URL'),
  };
  final compileTime = compileTimeValues[key] ?? empty;
  if (compileTime.isNotEmpty) return compileTime;
  final runtime = dotenv.env[key];
  return (runtime != null && runtime.isNotEmpty) ? runtime : defaultValue;
}
```
> `String.fromEnvironment` must be called with a **literal** key at each
> call site — that's a Dart compile-time-constant requirement, which is
> why the map above lists each key explicitly rather than taking `key`
> as a variable into `String.fromEnvironment(key)`. Add a line here
> whenever a new dart-define key is introduced.

Then in each of the four files:
```dart
import 'package:nlp_digitox/config/env.dart';
// DELETE: import 'package:nlp_digitox/config/api_keys.dart';

final String _apiKey = readEnv('GROQ_API_KEY');
```

And update `profile_service.dart`'s own `_cfg()` to just call `readEnv`,
so there is exactly one implementation:
```dart
String _cfg(String key) => readEnv(key);
```

- [ ] Delete `lib/config/api_keys_template.dart` and the `ApiKeys` class —
      nothing imports it once the four files above are migrated.
- [ ] `.env.example` already has `GROQ_API_KEY=` / `GEMINI_API_KEY=` — no change needed.
- [ ] `flutter analyze` should show zero "target of URI doesn't exist" errors after this.

---

### 4. Hardcoded release keystore credentials

**Confirmed still present** — `android/app/build.gradle.kts` lines 33–44:
absolute Windows path (`C:/Users/afjal/...`), `storePassword = "android"`,
`keyPassword = "android"`.

**Fix — externalize to a gitignored `key.properties`:**

`android/key.properties` (create this file locally, **do not commit it**):
```properties
storePassword=<GENERATE_A_REAL_RANDOM_PASSWORD>
keyPassword=<GENERATE_A_REAL_RANDOM_PASSWORD>
keyAlias=upload
storeFile=upload-keystore.jks
```
Put the actual `.jks` at `android/app/upload-keystore.jks` (also
gitignored) — `storeFile` above is resolved relative to `android/app/`.

`android/app/build.gradle.kts` — replace the whole block:
```kotlin
// Release signing — credentials come from android/key.properties,
// which is gitignored and must exist locally / in CI secrets.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = java.util.Properties()
val hasKeystoreProperties = keystorePropertiesFile.exists()
if (hasKeystoreProperties) {
    keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
}

signingConfigs {
    create("release") {
        if (hasKeystoreProperties) {
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }
}

buildTypes {
    release {
        ndk { debugSymbolLevel = "full" }
        resValue("string", "app_name", "NLP digitox")
        // Fail loudly and early instead of silently producing an
        // unsigned/misconfigured release build when key.properties is missing.
        signingConfig = if (hasKeystoreProperties) {
            signingConfigs.getByName("release")
        } else {
            throw GradleException(
                "android/key.properties not found — required for a release build. " +
                "See README for setup, or run a debug build instead."
            )
        }
        isMinifyEnabled = true
        // ...rest of your existing release block unchanged
    }
    // ...other build types unchanged
}
```

`.gitignore` — add:
```gitignore
android/key.properties
android/app/*.jks
```

- [ ] **If this app is already on the Play Store**, do not swap the
      keystore *file* — only externalize the credentials for the
      existing file. Changing the actual keystore breaks update
      compatibility for every existing install. Only generate a brand
      new keystore if this is still pre-launch.
- [ ] If the current `"android"`-password keystore was ever pushed to
      git history or shared outside your machine, treat that keystore as
      compromised — for a pre-launch app, generate a new one; for a
      published app, this is a harder problem (talk to Play Console
      support about key rotation/App Signing by Google Play) rather than
      something to patch silently.

---

### 5. Client-shipped webhook secret (no real authorization)

**Confirmed still present** — `profile_service.dart` still reads
`CLOUDINARY_CLEANUP_WEBHOOK_SECRET` and sends it as a static header.

**Fix — swap the static secret for a short-lived Firebase ID token,
verified server-side by n8n.**

`lib/core/services/profile_service.dart` — replace the header/secret
logic in `_deleteOldCloudinaryAsset` (`firebase_auth` is already
imported in this file):
```dart
Future<void> _deleteOldCloudinaryAsset(String publicId) async {
  final webhookUrl = readEnv('CLOUDINARY_CLEANUP_WEBHOOK_URL');
  if (webhookUrl.isEmpty) return;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    final idToken = await user.getIdToken(); // short-lived, ~1hr
    unawaited(http.post(
      Uri.parse(webhookUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({'publicId': publicId, 'uid': user.uid}),
    ).catchError((e) {
      debugPrint('ProfileService: Cloudinary cleanup webhook failed: $e');
    }));
  } catch (e) {
    debugPrint('ProfileService: Failed to get ID token for cleanup: $e');
  }
}
```
(Add `import 'dart:async';` for `unawaited` if not already present.)

**n8n workflow — verify the token instead of comparing a static string:**
1. Webhook trigger node (unchanged).
2. New **HTTP Request** node right after it:
   - `POST https://identitytoolkit.googleapis.com/v1/accounts:lookup`
   - Auth: your existing Google Service Account credential (needs the
     `Firebase Authentication Admin` / Identity Toolkit API scope).
   - Body: `{ "idToken": "{{ $json.headers['authorization'].replace('Bearer ', '') }}" }`
3. **IF** node: `{{ $json.users[0].localId }} === {{ $json.body.uid }}`
   — a valid token whose owner matches the claimed `uid` continues;
   anything else (expired/invalid token → the lookup call itself
   returns 400, or a mismatched uid) falls through to your existing
   "unauthorized" branch.
4. **Extra hardening now possible that a static secret never allowed:**
   before the delete step, also check
   `{{ $json.body.publicId.startsWith('profile_pics/' + $json.body.uid + '_') }}`
   so one user's request can never be used to delete a *different*
   user's asset even if the body were tampered with.
- [ ] Remove `CLOUDINARY_CLEANUP_WEBHOOK_SECRET` from `.env` / `.env.example` once this ships.

---

### 6 & 7. Session rules allow any member to write anything, and to steal ownership

**Confirmed still present** — `database.rules.json`'s `sessions/$sessionId`
rule is unchanged: any member can write the whole node, and
`"newData.val() === auth.uid || ..."` lets anyone set `ownerId` to
themselves.

**Fix — replace the `sessions` block in `database.rules.json`:**
```json
"sessions": {
  "$sessionId": {
    ".read": "auth != null && (!data.exists() || data.child('ownerId').val() === auth.uid || data.child('members').child(auth.uid).exists())",

    ".write": "auth != null && (!data.exists() || data.child('ownerId').val() === auth.uid)",

    "ownerId": {
      ".validate": "(!data.exists() && newData.val() === auth.uid) || (data.exists() && data.val() === auth.uid && newData.val() === data.val())"
    },

    "members": {
      "$memberId": {
        ".write": "auth != null && $memberId === auth.uid",
        ".validate": "newData.hasChildren(['userId', 'displayName', 'joinedAt', 'isActive', 'lastActive'])"
      }
    }
  }
}
```
- Anyone authenticated can still **create** a session (`!data.exists()`
  branch) — the `ownerId` validate rule is what actually enforces
  "you can only create yourself as owner".
- After creation, only the owner can write anything at the session
  root (`title`, `isPublic`, `isActive`, `completedAt`, `settings`, …).
- `ownerId` can never change after creation, by anyone, including the
  owner — no accidental or malicious transfer.
- Member heartbeat writes (`sessions/$id/members/$uid` → `lastActive`,
  `isActive`) are unaffected: RTDB uses the **most specific** rule for
  the exact path being written, so `members/$memberId`'s own rule keeps
  governing those, regardless of the now-tightened root rule.

**I checked this against every existing call site** — `joinSession`,
`leaveSession`, and `completeSession` in `session_service.dart` — and
confirmed they're all compatible with this rule as written. One related
piece (`memberCount`, in `publicSessions`) is **not** compatible as
originally proposed — see item 12 below for the corrected version.

- [ ] Redeploy after editing: `firebase deploy --only database`, then
      confirm the new rules show up in the Firebase Console's Rules tab
      (this exact file was reportedly edited before without being
      redeployed — double check this time).

---

### 8. `===` in RTDB rules

**False positive, no action needed.** Firebase's own docs use this exact
syntax (`"$uid === auth.uid"`) for Realtime Database rules — it's fully
supported there (unlike Firestore's rules language, which uses `==`).
If you have the scanner's exact line reference, paste it and I'll
re-check that specific expression, but every `===` currently in
`database.rules.json` is a valid string comparison.

---

### 9. `users/{userId}` readable by anyone authenticated

**Confirmed still present** — `firestore.rules` line 9:
`allow read: if request.auth != null;` with a comment saying it's for
leaderboard display.

**Fix:**
```
match /users/{userId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow write: if request.auth != null && request.auth.uid == userId
    && (!('profileImageUrl' in request.resource.data)
        || request.resource.data.profileImageUrl == null
        || request.resource.data.profileImageUrl.matches('https://res\\.cloudinary\\.com/ucarrdxh/.*')
        || request.resource.data.profileImageUrl.matches('https://lh3\\.googleusercontent\\.com/.*'));
  // subcollections unchanged
}
```
**I checked whether anything reads another user's `users/{uid}` doc
directly** (grepped every `.collection('users').doc(` call site in
`lib/`) — the leaderboard and session member displays all read from the
already-public `leaderboard` / `weekly_leaderboard` / `monthly_leaderboard`
collections or from the RTDB `sessions/{id}/members` map, never from
another user's `users/{uid}` Firestore doc. This tightening is safe to
apply as-is.

---

### 10. Nested `leaderboard/{uid}/badges/{badgeId}` rule (dead + insecure)

**Confirmed still present.**

**Fix — delete the nested block** from inside `match /leaderboard/{userId} { ... }`:
```diff
     match /leaderboard/{userId} {
       allow read: if request.auth != null;
       allow write: if request.auth != null && request.auth.uid == userId && (...);

-      // Badges subcollection - only n8n (service account) can write
-      match /badges/{badgeId} {
-        allow read: if request.auth != null;
-        allow write: if false;
-      }
     }
```
Leave the correctly-scoped top-level `match /badges/{badgeId}` rule
(owner-only, `badgeId.matches(request.auth.uid + '_.*')`) exactly as-is.

---

### 11. Clients can award themselves unlimited leaderboard points

**Confirmed still present** — `firestore.rules` lines 77–128:
`leaderboard`/`weekly_leaderboard`/`monthly_leaderboard` all allow the
doc owner to write any field, including `lifetimePoints`.

This is the big one, and it's a genuine two-phase migration — closing it
completely means moving point-awarding server-side. You don't have
Cloud Functions (no Blaze plan), but n8n with its Google Service Account
credential already writes with Admin privileges elsewhere in this app,
so it's the right tool here too.

**Phase 1 — lock the rules down now (with the null-`resource` bug
fixed):**
```
match /leaderboard/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && request.auth.uid == userId
    && (
         !exists(/databases/$(database)/documents/leaderboard/$(userId))
         || request.resource.data.diff(resource.data).affectedKeys()
              .hasOnly(['profileImageUrl', 'profileImagePublicId', 'username'])
       )
    && (!('profileImageUrl' in request.resource.data)
        || request.resource.data.profileImageUrl == null
        || request.resource.data.profileImageUrl.matches('https://res\\.cloudinary\\.com/ucarrdxh/.*')
        || request.resource.data.profileImageUrl.matches('https://lh3\\.googleusercontent\\.com/.*'));

  match /badges/{badgeId} {
    allow read: if request.auth != null;
    allow write: if false;
  }
}
```
The `!exists(...) || diff(...).hasOnly(...)` guard is the fix for the
bug described at the top of this document: `resource.data` cannot be
read when the document doesn't exist yet, so the rule must allow
**creation** unconditionally (an attacker can't "cheat" via creation —
an empty/new doc has no points in it yet) and only restrict which
**fields can change on an existing doc** to the profile-display fields.

Apply the identical `!exists(...) || diff(...).hasOnly([...])` pattern
to `weekly_leaderboard` and `monthly_leaderboard`.

⚠️ **This will break your current client-side `LeaderboardService.addPoints()`
calls** — that's expected and intentional. Don't ship Phase 1 until
Phase 2's webhook exists and every call site has been switched over, or
real point-earning breaks for everyone, not just cheaters.

**Phase 2 — route point awards through a new n8n webhook:**
- [ ] New n8n workflow: Webhook trigger accepting `{ uid, reason,
      idToken }`; verify `idToken` the same way as item #5 (Identity
      Toolkit `accounts:lookup`, check `localId === uid`).
- [ ] **Never trust a client-supplied point amount.** Store the
      reason→points mapping as *data* in the existing
      `leaderboard_config` Firestore doc, e.g.:
      ```json
      { "pointValues": { "habit_completed": 10, "task_completed": 5, "shared_session_completed": 50 } }
      ```
      Have the workflow read that doc and look up `reason`; reject any
      `reason` not present in the map. Adding a new point-earning action
      later becomes a Firestore config edit, not a code or workflow change.
- [ ] The webhook writes the point delta via the Firestore REST API
      (Admin-privileged, bypasses rules) to all three leaderboard
      collections in one workflow run.
- [ ] **App side:** replace every call to
      `LeaderboardService.instance.addPoints(...)` with a call to this
      webhook instead.
- [ ] Treat this as its own tracked piece of work, separate from the
      rest of this list — it touches every point-awarding call site in
      the app and needs its own testing pass.

---

## MEDIUM SEVERITY

### 12. Public session member counts — corrected for `leaveSession()` compatibility

**Confirmed still present** — `database.rules.json`'s
`publicSessions/$sessionId/memberCount` allows any authenticated user.

**The rule fix, as originally proposed, would break `leaveSession()`.**
`SessionService.leaveSession()` currently removes the user from
`sessions/{id}/members` *before* recomputing and writing the new
`memberCount` — so at write time, a leaving member no longer appears in
`members`, and a rule that only allows owners-or-current-members would
reject their own "I'm leaving, decrement the count" write. The fix has
two parts:

**a) `database.rules.json`:**
```json
"memberCount": {
  ".write": "auth != null && (root.child('sessions').child($sessionId).child('ownerId').val() === auth.uid || root.child('sessions').child($sessionId).child('members').child(auth.uid).exists())",
  ".validate": "newData.isNumber() && newData.val() >= 0"
}
```

**b) `lib/core/services/session_service.dart` — reorder `leaveSession`
so the member is still listed at the moment the count is written:**
```dart
Future<void> leaveSession({required String sessionId}) async {
  try {
    final userId = FirebaseAuthService.instance.userId;
    if (userId == null) throw StateError('User not authenticated');
    if (!_isInitialized) throw StateError('SessionService not initialized');

    _stopPresenceHeartbeat(sessionId);

    if (_isFirebaseAvailable && _database != null) {
      // Read the session and write the decremented public count
      // BEFORE removing ourselves from `members` — the security rule
      // requires the caller to still be a listed member at write time.
      final sessionSnap = await _database!.ref('sessions/$sessionId').get();
      if (sessionSnap.exists) {
        final session = SharedSession.fromMap(
            Map<String, dynamic>.from(sessionSnap.value as Map));
        if (session.isPublic) {
          final newCount = (session.memberCount - 1).clamp(0, 1 << 30);
          await _database!
              .ref('publicSessions/$sessionId/memberCount')
              .set(newCount);
        }
      }

      await _database!.ref('sessions/$sessionId/members/$userId').remove();
      await _database!.ref('users/$userId/sessions/$sessionId').remove();
    }
    // ...rest of the method unchanged
  } catch (e) {
    debugPrint('SessionService: Error leaving session: $e');
    rethrow;
  }
}
```
`joinSession()` needs no change — it already writes `members/{uid}`
*before* writing `memberCount`, so the joining user already passes the
tightened rule at write time.

---

### 13. Google profile photos rejected by Firestore rules

**Confirmed still present** — no `googleusercontent.com` allowance
anywhere in `firestore.rules`. Already folded into the corrected rules
for items #9 and #11 above (both now include the
`lh3.googleusercontent.com` alternative alongside the Cloudinary one) —
no separate change needed beyond applying those two fixes.

---

### 14. Badge month `RangeError`

**Confirmed still present** — `lib/models/badge_model.dart`, no bounds
check on `month`.

**Fix:**
```dart
final month = int.tryParse(parts[1]) ?? 1;
final safeMonth = (month >= 1 && month <= 12) ? month : 1;
return '${monthNames[safeMonth]} $year';
```

---

### 15. Accessibility permission missing from every "all granted" check

**Confirmed still present at all five locations** — `haveAccessibilityPermission`
is displayed as a tile but never included in the AND-chain that decides
setup is "complete":
- `lib/ui/onboarding/permission_page.dart` (~line 128)
- `lib/ui/splash_screen.dart` (~line 81, `_haveAllEssentialPermissions`)
- `lib/ui/onboarding/onboarding_screen.dart` (~line 88 and again ~line 163)
- `lib/features/onboarding/quiz.dart` (~line 49)

**Fix — identical one-line addition at all five sites:**
```dart
final allGranted = permissions.haveUsageAccessPermission &&
    permissions.haveDisplayOverlayPermission &&
    permissions.haveAlarmsPermission &&
    permissions.haveNotificationPermission &&
    permissions.haveAccessibilityPermission; // ← add this line
```
(Variable name and object (`permissions`/`perms`) differ slightly per
file — keep whatever each file already uses, just add the
`haveAccessibilityPermission` clause.)

---

## Not independently confirmed — same as before, need a repro from you

I re-checked these against the current `main` and still can't locate a
concrete bug without more specifics:

- **"Invalid calendar dates are silently normalized"** — I didn't find
  a `DateTime(year, month, day)` construction using unvalidated day
  input. Tell me which screen (date picker? streak calendar?) and I'll
  find and fix the exact spot.
- **"Consumer does not rebuild when shared focus state changes"** — the
  `ref.watch`/`ref.read` split in `focus_session_screen.dart` and
  `sessions_list_screen.dart` looks correct on a read-through. Tell me
  what specifically doesn't update (presence indicator? points? member
  list?) so I can trace it live rather than guess.
- **"Navigation races shared session initialization"** — need a repro:
  does tapping "Join" too fast crash, show stale data, or something else?
- **The 21st, unnamed finding** — only 20 titles were listed above the
  "And 1 more" line. Paste its title and I'll cover it here too.

---

## Deployment & verification checklist, in order

1. **Rules first, app code second, for #11 specifically** — do NOT
   deploy the Phase 1 Firestore leaderboard lockdown until the app's
   `addPoints()` call sites have already been migrated to the n8n
   webhook (Phase 2), or you'll break real point-earning immediately.
   Every other fix here is safe to deploy in any order.
2. `firebase deploy --only firestore:rules` — then check the Firebase
   Console's Rules tab timestamp updates (this exact step was reportedly
   skipped before on `database.rules.json`).
3. `firebase deploy --only database:rules` (Realtime Database — separate
   from Firestore, separate command).
4. `flutter analyze` — should be clean after the `api_keys.dart` migration.
5. `flutter build apk --release` then
   `unzip -l build/app/outputs/flutter-apk/app-release.apk | grep -i env`
   — must return nothing.
6. Manual pass: create a session, join it from a second account, leave
   it, and confirm `publicSessions/{id}/memberCount` still ends at the
   correct number in the RTDB console.
7. Manual pass: try (from a second, non-owner test account) to directly
   edit another user's `sessions/{id}` title via the Firebase console's
   Rules Playground, simulating that user — should now be denied.
8. Onboarding pass: deny only Accessibility, grant everything else —
   setup should no longer report "complete."