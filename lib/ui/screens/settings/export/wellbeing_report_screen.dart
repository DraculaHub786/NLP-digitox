import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
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
                            StyledText(
                              'Last 7 Days',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            8.vBox,
                            // The monthly AI report is the durable artifact: it is
                            // stored under the user's uid and must stay reachable
                            // even when there is no 7-day usage data, so it is
                            // rendered outside the `_data != null` branch below.
                            if (_data != null) ...[
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
                            ] else
                              StyledText(
                                'No screen-time data for the last 7 days yet. Your '
                                'monthly AI report is still available below.',
                                fontSize: 12,
                                isSubtitle: true,
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
