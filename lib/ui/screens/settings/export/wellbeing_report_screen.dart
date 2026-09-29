import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/services/monthly_wellbeing_report_service.dart';
import 'package:nlp_digitox/core/services/pdf_report_generator.dart';
import 'package:nlp_digitox/core/services/wellbeing_report_service.dart';
import 'package:nlp_digitox/models/wellbeing_report_data.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/screens/settings/export/monthly_report_section.dart';
import 'package:printing/printing.dart';

/// Exports the local wellbeing data as a two-page PDF.
///
/// Page 1 is the overall picture, page 2 the weekly and monthly breakdowns.
/// The data is collected here (not inside the generator) so a failed load can
/// be retried by simply tapping the download button again.
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

  /// Gathers every window the PDF needs in one place.
  ///
  /// Uses [WellbeingReportService.lastDaysRange] rather than subtracting
  /// `Duration(days: 6)` from `DateTime.now()`: that older form kept the
  /// current time of day on the start date, which clipped the first day's data.
  Future<ReportBundle> _collect() async {
    final service = WellbeingReportService.instance;
    final weekly = await service.buildReport(range: service.lastDaysRange(7));
    final monthly = await service.buildReport(range: service.lastDaysRange(30));

    String? narrative;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      narrative =
          await MonthlyWellbeingReportService.instance.getLatestReport(uid);
    }

    return ReportBundle(
      weekly: weekly,
      monthly: monthly,
      monthlyNarrative: narrative,
    );
  }

  Future<void> _load() async {
    try {
      final bundle = await _collect();
      if (!mounted) return;
      setState(() => _bundle = bundle);
    } catch (e, stackTrace) {
      // A failed load must not leave the spinner running forever; the screen
      // still renders, and downloading re-collects from scratch.
      debugPrint('WellbeingReportScreen: load failed: $e\n$stackTrace');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Builds the PDF and writes it to a file the user chooses.
  ///
  /// Falls back to the system share sheet when saving is unavailable, so a
  /// platforms quirk can never turn "download" into a silent no-op.
  Future<void> _downloadPdf() async {
    if (_exporting) return;
    setState(() => _exporting = true);

    Uint8List? bytes;
    final fileName = 'wellbeing-report-'
        '${DateTime.now().toIso8601String().split('T').first}.pdf';

    try {
      // Re-collected so the file always reflects the latest local data.
      final bundle = await _collect();
      if (mounted) setState(() => _bundle = bundle);

      bytes = await PdfReportGenerator.generate(bundle);

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save wellbeing report',
        fileName: fileName,
        bytes: bytes,
      );
      if (path == null) return; // Cancelled by the user — not an error.

      // On desktop file_picker returns a path without writing the bytes.
      if (!(Platform.isAndroid || Platform.isIOS)) {
        await File(path).writeAsBytes(bytes);
      }
      _showMessage('Report saved');
    } catch (e, stackTrace) {
      debugPrint('WellbeingReportScreen: export failed: $e\n$stackTrace');

      if (bytes != null) {
        // The PDF itself built fine, so at least let the user share it.
        try {
          await Printing.sharePdf(bytes: bytes, filename: fileName);
          return;
        } catch (shareError) {
          debugPrint(
              'WellbeingReportScreen: share fallback failed: $shareError');
        }
      }
      _showMessage('Could not create the report. Please try again.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bundle = _bundle;

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
                            const StyledText(
                              'Export your report',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            8.vBox,
                            const StyledText(
                              'Page 1: overall stats, most-used apps and the '
                              'screen-time trend.\n'
                              'Page 2: weekly and monthly reports.',
                              fontSize: 12,
                              isSubtitle: true,
                            ),
                            if (bundle != null) ...[
                              12.vBox,
                              _StatusRow('Weekly report', bundle.hasWeekly),
                              _StatusRow('Monthly report', bundle.hasMonthly),
                              4.vBox,
                              const StyledText(
                                'Sections without enough data stay empty in '
                                'the PDF.',
                                fontSize: 11,
                                isSubtitle: true,
                              ),
                            ],
                            20.vBox,
                            // Always enabled: an empty report is still a
                            // valid download, and it is the retry path if the
                            // initial load failed.
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _exporting ? null : _downloadPdf,
                                icon: _exporting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.download_rounded),
                                label: Text(_exporting
                                    ? 'Preparing…'
                                    : 'Download PDF Report'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
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

/// One line summarising whether a report section has enough data to print.
class _StatusRow extends StatelessWidget {
  final String label;
  final bool ready;

  const _StatusRow(this.label, this.ready);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            ready ? Icons.check_circle : Icons.remove_circle_outline,
            size: 16,
            color: ready ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ${ready ? 'ready' : 'not enough data yet'}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
