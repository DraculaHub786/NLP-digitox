import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nlp_digitox/config/app_constants.dart';
import 'package:nlp_digitox/ui/common/clay_widgets.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';

/// Primary floating action button styled with the app's clay/3D recipe
/// (raised gradient + drop shadow, presses flat) — Section S3/S7.
class DefaultFabButton extends StatelessWidget {
  const DefaultFabButton({
    super.key,
    this.heroTag,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final Object? heroTag;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = ClayStyle.foregroundColor(colorScheme.primary);

    return DefaultHero(
      tag: heroTag ?? "defaultScaffoldFabButton",
      child: ClayContainer(
        baseColor: colorScheme.primary,
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        onTap: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: foreground, size: 20),
            const SizedBox(width: 8),
            StyledText(
              label,
              color: foreground,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().scale(
          duration: AppConstants.defaultAnimDuration,
          curve: Curves.easeOutBack,
        );
  }
}
