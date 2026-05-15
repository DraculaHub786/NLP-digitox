
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/config/app_constants.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';

class FocusNowFab extends StatelessWidget {
  const FocusNowFab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultHero(
      tag: HeroTags.focusModeFABTag,
      child: FilledButton.icon(
        onPressed: () => Navigator.of(context).pushNamed(
          AppRoutes.focusModePath,
          arguments: 0,
        ),
        icon: const Icon(FluentIcons.brain_circuit_20_filled),
        label: Text(context.locale.focus_now_fab_button),
        style: const ButtonStyle().copyWith(
          elevation: WidgetStatePropertyAll(5),
          padding: const WidgetStatePropertyAll(EdgeInsets.all(16)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    ).animate().scale(
          duration: AppConstants.defaultAnimDuration,
          curve: Curves.easeOutBack,
        );
  }
}
