// Copyright (c) 2026 NLP digitox

import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/ui/common/status_dot.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// One "this is on/off, here is the fix" row of the background-health card.
///
/// [onFix] being null is the signal that the row is already healthy: the
/// trailing action is then omitted rather than shown disabled, because a
/// greyed-out "Fix" invites the user to hunt for a problem that is not there.
class HealthActionRow extends StatelessWidget {
  const HealthActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.status,
    required this.kind,
    this.fixLabel = 'Fix',
    this.onFix,
  });

  final IconData icon;
  final String title;
  final String status;
  final StatusDotKind kind;

  /// Label of the trailing action. Ignored when [onFix] is null.
  final String fixLabel;

  /// Null when there is nothing to do.
  final Future<void> Function()? onFix;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fix = onFix;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
            child: Icon(icon, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  title,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: StatusDot(kind: kind, size: 7),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: StyledText(
                        status,
                        fontSize: 12,
                        isSubtitle: true,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (fix != null) ...[
            const SizedBox(width: Spacing.sm),
            TextButton(
              onPressed: () => fix(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
              ),
              child: Text(fixLabel),
            ),
          ],
        ],
      ),
    );
  }
}

/// A read-only `label — value` line, for the facts that have no fix: when the
/// watchdog last checked in and how the process last ended.
class HealthFactRow extends StatelessWidget {
  const HealthFactRow({
    super.key,
    required this.label,
    required this.value,
    this.kind = StatusDotKind.good,
  });

  final String label;
  final String value;
  final StatusDotKind kind;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: StatusDot(kind: kind, size: 7),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: StyledText(
              label,
              fontSize: 13,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Flexible(
            child: StyledText(
              value,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
