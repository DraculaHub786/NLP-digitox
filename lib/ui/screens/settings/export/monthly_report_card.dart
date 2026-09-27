// Copyright (c) 2026 NLP digitox

import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/ui/common/rounded_container.dart';
import 'package:nlp_digitox/ui/common/simple_markdown.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// Renders one monthly AI wellbeing report (or the state that stands in for it:
/// not generated yet, generating, or failed).
///
/// Purely presentational — it owns no fetching and no persistence, so it can be
/// reused for the current month at the top of the screen and for every archived
/// month further down.
class MonthlyReportCard extends StatelessWidget {
  const MonthlyReportCard({
    super.key,
    required this.monthKey,
    this.report,
    this.isCurrentMonth = false,
    this.isBusy = false,
    this.error,
    this.averageScore,
    this.onGenerate,
    this.onRegenerate,
    this.onCopy,
  });

  /// `yyyy-MM` of the month this card describes.
  final String monthKey;

  /// The generated narrative, or null when nothing has been stored yet.
  final String? report;

  final bool isCurrentMonth;
  final bool isBusy;

  /// Message shown instead of the report when generation failed.
  final String? error;

  /// Mean daily sentiment for the window, when the stored document has one.
  final double? averageScore;

  /// Starts generation for a month that has none. Null hides the button.
  final VoidCallback? onGenerate;

  /// Rewrites the report for a month that already has one. Null hides it.
  final VoidCallback? onRegenerate;

  /// Copies the report to the clipboard. Null hides the button.
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasReport = report != null && report!.trim().isNotEmpty;

    return RoundedContainer(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          if (isCurrentMonth) ...[
            4.vBox,
            StyledText(
              'A 30-day narrative built from your sentiment scores, screen '
              'time and chat conversations.',
              fontSize: 11,
              isSubtitle: true,
            ),
          ],
          12.vBox,
          if (isBusy)
            _busyRow(context)
          else if (error != null)
            _errorState(context, colors)
          else if (!hasReport)
            _emptyState(context)
          else
            _reportBody(context, hasReport),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          Icons.auto_awesome_rounded,
          size: 18,
          color: colors.primary,
        ),
        8.hBox,
        Expanded(
          child: StyledText(
            monthKeyLabel(monthKey),
            fontSize: 15,
            fontWeight: FontWeight.w600,
            isHeadline: true,
          ),
        ),
        if (averageScore != null)
          StyledText(
            'avg ${averageScore!.toStringAsFixed(2)}',
            fontSize: 11,
            isSubtitle: true,
          ),
      ],
    );
  }

  Widget _busyRow(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        12.hBox,
        Expanded(
          child: StyledText(
            'Analysing your last 30 days…',
            fontSize: 12,
            isSubtitle: true,
          ),
        ),
      ],
    );
  }

  Widget _errorState(BuildContext context, ColorScheme colors) {
    final retry = onRegenerate ?? onGenerate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          error!,
          style: TextStyle(fontSize: 12, height: 1.4, color: colors.error),
        ),
        if (retry != null) ...[
          12.vBox,
          _button(
            context,
            icon: Icons.refresh_rounded,
            label: 'Try again',
            onPressed: retry,
          ),
        ],
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StyledText(
          isCurrentMonth
              ? 'No report for this month yet. Generate one to see how your '
                  'last 30 days went.'
              : 'This month has no stored report.',
          fontSize: 12,
          isSubtitle: true,
        ),
        if (onGenerate != null) ...[
          12.vBox,
          _button(
            context,
            icon: Icons.auto_awesome_rounded,
            label: 'Generate report',
            onPressed: onGenerate!,
          ),
        ],
      ],
    );
  }

  Widget _reportBody(BuildContext context, bool hasReport) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasReport) SimpleMarkdown(data: report!),
        16.vBox,
        Wrap(
          spacing: 4,
          children: [
            if (onCopy != null)
              TextButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.content_copy_rounded, size: 16),
                label: const Text('Copy'),
              ),
            if (onRegenerate != null)
              TextButton.icon(
                onPressed: onRegenerate,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Regenerate'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _button(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}
