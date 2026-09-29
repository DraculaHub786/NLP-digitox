import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// Empty state for the session screens.
///
/// Matches the app's shared empty-state pattern (leaderboard / achievements):
/// a large [FluentIcons] glyph, a bold title and a quieter subtitle, all
/// centred with generous vertical padding. Optionally renders a single call to
/// action below the copy.
class SessionEmptyView extends StatelessWidget {
  const SessionEmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final showAction = actionLabel != null && onAction != null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: 48,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: colorScheme.primary),
          ),
          const SizedBox(height: Spacing.base),
          StyledText(
            title,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.sm),
          StyledText(
            subtitle,
            fontSize: 14,
            isSubtitle: true,
            height: 1.4,
            textAlign: TextAlign.center,
          ),
          if (showAction) ...[
            const SizedBox(height: Spacing.xl),
            FilledButton.icon(
              onPressed: onAction,
              icon: Icon(
                actionIcon ?? FluentIcons.add_20_filled,
                size: 18,
              ),
              label: Text(actionLabel!),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.xl,
                  vertical: Spacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error state for the session screens.
///
/// Uses the theme's error colour rather than a hard-coded red so it stays
/// legible in both the light and dark palettes, and keeps the raw exception
/// out of the headline — it lands in the smaller, secondary line.
class SessionErrorView extends StatelessWidget {
  const SessionErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: 48,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FluentIcons.error_circle_20_filled,
            size: 48,
            color: colorScheme.error,
          ),
          const SizedBox(height: Spacing.base),
          StyledText(
            'Could not load sessions',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.sm),
          StyledText(
            message,
            fontSize: 13,
            isSubtitle: true,
            height: 1.4,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: Spacing.lg),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(FluentIcons.arrow_clockwise_20_regular, size: 18),
              label: const Text('Try again'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg,
                  vertical: Spacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
