import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// Shared container for every session bottom sheet (create / join).
///
/// Painted from the same glass surface tokens as [SurfaceCard] rather than
/// `colorScheme.surface`, so the sheet reads as the same material as the cards
/// behind it in both the light and the dark palette. The height is capped to
/// what is actually left once the keyboard is up, and the body scrolls inside
/// that cap, so every field and the submit button stay reachable on short
/// screens.
class SessionSheetScaffold extends StatelessWidget {
  const SessionSheetScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  /// Sheet body, rendered below the title block.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height - bottomInset - 48;

    final surface = isDark
        ? DesignPalette.darkGlassFill
        : DesignPalette.lightGlassFill;
    final border = isDark
        ? DesignPalette.darkGlassBorder
        : DesignPalette.lightGlassBorder;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.md,
        Spacing.lg,
        bottomInset + Spacing.xl,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: border.withValues(alpha: 0.6)),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(Radii.sm),
                    ),
                    child: Icon(icon, size: 20, color: colorScheme.primary),
                  ),
                  const SizedBox(width: Spacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StyledText(
                        title,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        StyledText(
                          subtitle!,
                          fontSize: 13,
                          isSubtitle: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Inline failure banner for the session bottom sheets.
///
/// Rendered inside the sheet rather than as a SnackBar: the sheet is drawn on
/// top of the screen's Scaffold, so a SnackBar would appear *behind* it and
/// every failure would look like the button doing nothing.
class SessionSheetErrorBanner extends StatelessWidget {
  const SessionSheetErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Spacing.md),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FluentIcons.error_circle_20_filled,
            size: 18,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: StyledText(
              message,
              fontSize: 13,
              height: 1.35,
              color: colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}
