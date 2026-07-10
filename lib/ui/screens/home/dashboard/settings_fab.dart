import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/config/app_constants.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';

/// Floating action button that opens the Settings screen.
///
/// This replaces the old top app bar settings icon button
/// (previously `_SettingsButton` in `home_screen.dart`) and the
/// duplicate "Focus Now" FAB, since "Focus Now" already exists
/// under Quick Actions on the dashboard.
class SettingsFab extends StatelessWidget {
  const SettingsFab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultHero(
      tag: HeroTags.donationDialogTag,
      child: FilledButton.icon(
        onPressed: () =>
            Navigator.of(context).pushNamed(AppRoutes.settingsPath),
        icon: const Icon(FluentIcons.settings_20_filled),
        label: const Text("Settings"),
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