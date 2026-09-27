// Copyright (c) 2026 NLP digitox

import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/ui/common/default_expandable_list_tile.dart';
import 'package:nlp_digitox/ui/common/simple_markdown.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// One archived month inside the Monthly AI Report section.
///
/// A collapsed [DefaultExpandableListTile] showing the month label and its
/// average sentiment, expanding to the full narrative plus a copy action. It
/// owns no fetching — the section hands it an already-loaded report.
class ArchivedReportTile extends StatelessWidget {
  const ArchivedReportTile({
    super.key,
    required this.monthKey,
    required this.report,
    required this.averageScore,
    this.onCopy,
  });

  /// `yyyy-MM` of the month.
  final String monthKey;

  /// The stored narrative. May be empty for a malformed document.
  final String report;

  /// Mean daily sentiment the stored document recorded.
  final double averageScore;

  /// Copies the report to the clipboard. Null hides the button.
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final hasContent = report.trim().isNotEmpty;

    return DefaultExpandableListTile(
      leadingIcon: Icons.auto_awesome_rounded,
      titleText: monthKeyLabel(monthKey),
      subtitleText: 'Average sentiment ${averageScore.toStringAsFixed(2)}',
      content: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasContent)
              SimpleMarkdown(data: report)
            else
              const StyledText(
                'No report content was stored for this month.',
                fontSize: 12,
                isSubtitle: true,
              ),
            if (hasContent && onCopy != null) ...[
              12.vBox,
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.content_copy_rounded, size: 16),
                  label: const Text('Copy'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
