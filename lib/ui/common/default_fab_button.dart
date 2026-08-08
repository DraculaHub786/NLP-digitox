
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nlp_digitox/config/app_constants.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';

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
    return DefaultHero(
      tag: heroTag ?? "defaultScaffoldFabButton",
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: const ButtonStyle().copyWith(
          elevation: WidgetStatePropertyAll(5),
          padding: const WidgetStatePropertyAll(EdgeInsets.all(16)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
            ),
          ),
        ),
      ),
    ).animate().scale(
          duration: AppConstants.defaultAnimDuration,
          curve: Curves.easeOutBack,
        );
  }
}
