// Copyright (c) 2026 NLP digitox

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/services/monthly_wellbeing_report_service.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/ui/common/rounded_container.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/screens/settings/export/archived_report_tile.dart';
import 'package:nlp_digitox/ui/screens/settings/export/monthly_report_card.dart';

/// Loads, shows, regenerates and copies the Monthly AI wellbeing report.
///
/// This is the presentation half of the monthly pipeline: the Cloud Function
/// drops a request marker, [WellbeingReportLifecycleObserver] triggers
/// generation, and this section is the only place the user ever sees the
/// result. It reads the already-generated documents
/// (`users/{uid}/monthly_wellbeing_reports/{yyyy-MM}`) and never builds a
/// prompt itself — that stays in [MonthlyWellbeingReportService].
///
/// Rendered inside `ScaffoldShell`'s `Scaffold`, so `ScaffoldMessenger.of`
/// resolves for the copy confirmation [SnackBar].
class MonthlyReportSection extends StatefulWidget {
  const MonthlyReportSection({super.key});

  @override
  State<MonthlyReportSection> createState() => _MonthlyReportSectionState();
}

class _MonthlyReportSectionState extends State<MonthlyReportSection> {
  bool _loading = true;
  bool _busy = false;
  bool _signedOut = false;

  /// Inline message shown by the card instead of the report.
  String? _error;

  String? _currentReport;
  double? _currentAverage;
  List<MonthlyReport> _archived = const [];

  String get _currentMonthKey => monthKeyOf(DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Reads every stored report and splits it into the current month and the
  /// archive. [showSpinner] is false when refreshing after generation so the
  /// card does not flash back to its loading state.
  Future<void> _load({bool showSpinner = true}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      setState(() {
        _signedOut = true;
        _loading = false;
        _error = null;
      });
      return;
    }

    if (mounted && showSpinner) {
      setState(() {
        _loading = true;
        _signedOut = false;
        _error = null;
      });
    }

    try {
      final reports =
          await MonthlyWellbeingReportService.instance.getAllReports(uid);
      final currentKey = _currentMonthKey;
      MonthlyReport? current;
      final archived = <MonthlyReport>[];
      for (final report in reports) {
        if (report.monthKey == currentKey) {
          current = report;
        } else {
          archived.add(report);
        }
      }

      if (!mounted) return;
      setState(() {
        _currentReport = current?.report;
        _currentAverage = current?.averageScore;
        _archived = archived;
        _loading = false;
        _signedOut = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load your monthly reports.\n$e';
      });
    }
  }

  /// Runs generation and refreshes from Firestore. [force] rewrites a month
  /// that already has a report; otherwise an existing one is left untouched.
  Future<void> _generate({bool force = false}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    final service = MonthlyWellbeingReportService.instance;
    String? result;
    try {
      result = force
          ? await service.generateMonthlyReport()
          : await service.ensureMonthlyReport();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Report generation failed.\n$e';
      });
      return;
    }

    if (!mounted) return;
    if (result == null) {
      // Never a silent no-op: the service returns null when there is nothing
      // to report on (no scores yet) or the model call failed.
      setState(() {
        _busy = false;
        _error = 'No report was produced. This usually means there are not yet '
            'enough scored days of chat history, or the AI service was '
            'unreachable. Keep using the app and try again.';
      });
      return;
    }

    setState(() {
      _busy = false;
      _currentReport = result;
      _error = null;
    });
    await _load(showSpinner: false);
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Report copied to clipboard')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final hasCurrentReport = _currentReport?.trim().isNotEmpty ?? false;
    final isWorking = _loading || _busy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StyledText(
          'Monthly AI Report',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        8.vBox,
        if (_signedOut)
          const _SignedOutNotice()
        else
          MonthlyReportCard(
            monthKey: _currentMonthKey,
            report: _currentReport,
            isCurrentMonth: true,
            isBusy: isWorking,
            error: _error,
            averageScore: _currentAverage,
            onGenerate: isWorking ? null : () => _generate(),
            onRegenerate: isWorking ? null : () => _generate(force: true),
            onCopy: hasCurrentReport ? () => _copy(_currentReport!) : null,
          ),
        if (!_signedOut && _archived.isNotEmpty) ...[
          20.vBox,
          const StyledText(
            'Previous Months',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          4.vBox,
          for (final report in _archived)
            ArchivedReportTile(
              monthKey: report.monthKey,
              report: report.report,
              averageScore: report.averageScore,
              onCopy: report.report.trim().isEmpty
                  ? null
                  : () => _copy(report.report),
            ),
        ],
      ],
    );
  }
}

/// Shown when no Firebase user is signed in — there is no uid to read reports
/// against, so the section explains itself instead of rendering empty.
class _SignedOutNotice extends StatelessWidget {
  const _SignedOutNotice();

  @override
  Widget build(BuildContext context) {
    return const RoundedContainer(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.all(16),
      child: StyledText(
        'Sign in to generate and view your monthly AI report.',
        fontSize: 12,
        isSubtitle: true,
      ),
    );
  }
}
