import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/app_themes.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/enums/app_theme_mode.dart';
import 'package:nlp_digitox/core/enums/default_home_tab.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/config/locales.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/l10n/generated/app_localizations.dart';
import 'package:nlp_digitox/providers/system/digitox_settings_provider.dart';
import 'package:nlp_digitox/providers/restrictions/wellbeing_provider.dart';
import 'package:nlp_digitox/ui/common/default_dropdown_tile.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/permissions/battery_permission_tile.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

class TabGeneral extends ConsumerWidget {
  const TabGeneral({super.key});

  void _openAutoStartSettings(BuildContext context) async {
    final success = await MethodChannelService.instance.openAutoStartSettings();

    if (!success && context.mounted) {
      context.showSnackAlert(
        context.locale.whitelist_app_unsupported_snack_alert,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final digitoxSettings = ref.watch(digitoxSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        /// Appearance
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ModernSectionHeader(
              title: context.locale.appearance_heading,
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SurfaceCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// Theme mode
                  DefaultDropdownTile<AppThemeMode>(
                    value: digitoxSettings.themeMode,
                    dialogIcon: FluentIcons.dark_theme_20_filled,
                    titleText: context.locale.theme_mode_tile_title,
                    onSelected:
                        ref.read(digitoxSettingsProvider.notifier).changeThemeMode,
                    items: [
                      DefaultDropdownItem(
                        label: context.locale.theme_mode_system_label,
                        value: AppThemeMode.system,
                      ),
                      DefaultDropdownItem(
                        label: context.locale.theme_mode_light_label,
                        value: AppThemeMode.light,
                      ),
                      DefaultDropdownItem(
                        label: context.locale.theme_mode_dark_label,
                        value: AppThemeMode.dark,
                      ),
                    ],
                  ),
                  12.vBox,

                  /// Material Color
                  DefaultDropdownTile<String>(
                    titleText: context.locale.material_color_tile_title,
                    dialogIcon: FluentIcons.color_20_filled,
                    value: digitoxSettings.accentColor,
                    onSelected: ref.read(digitoxSettingsProvider.notifier).changeColor,
                    trailingBuilder: (item) => Container(
                      height: 18,
                      width: 18,
                      decoration: BoxDecoration(
                        color: AppTheme.materialColors[item],
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                    ),
                    items: AppTheme.materialColors.entries
                        .map((e) => DefaultDropdownItem(
                              label: e.key,
                              value: e.key,
                            ))
                        .toList(),
                  ),
                  12.vBox,

                  /// Amoled dark
                  ModernSettingsTile(
                    title: context.locale.amoled_dark_tile_title,
                    subtitle: context.locale.amoled_dark_tile_subtitle,
                    icon: FluentIcons.dark_theme_20_regular,
                    iconColor: colorScheme.primary,
                    value: digitoxSettings.useAmoledDark,
                    onChanged: (_) =>
                        ref.read(digitoxSettingsProvider.notifier).switchAmoledDark(),
                  ),
                  8.vBox,

                  /// Dynamic colors
                  ModernSettingsTile(
                    title: context.locale.dynamic_colors_tile_title,
                    subtitle: context.locale.dynamic_colors_tile_subtitle,
                    icon: FluentIcons.color_20_regular,
                    iconColor: colorScheme.tertiary,
                    value: digitoxSettings.useDynamicColors,
                    onChanged: (_) =>
                        ref.read(digitoxSettingsProvider.notifier).switchDynamicColor(),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Default settings
        12.vSliverBox,
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ModernSectionHeader(title: context.locale.defaults_heading),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SurfaceCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// App Language
                  DefaultDropdownTile<String>(
                    titleText: context.locale.app_language_tile_title,
                    dialogIcon: FluentIcons.color_20_filled,
                    value: digitoxSettings.localeCode,
                    onSelected: ref.read(digitoxSettingsProvider.notifier).changeLocale,
                    items: AppLocalizations.supportedLocales
                        .map((e) => DefaultDropdownItem(
                              value: e.languageCode,
                              label: Locales.knownLocales[e.languageCode] ??
                                  e.languageCode,
                            ))
                        .toList(),
                  ),
                  12.vBox,

                  /// Default home tab
                  DefaultDropdownTile<DefaultHomeTab>(
                    titleText: context.locale.default_home_tab_tile_title,
                    dialogIcon: FluentIcons.color_20_filled,
                    value: digitoxSettings.defaultHomeTab,
                    onSelected:
                        ref.read(digitoxSettingsProvider.notifier).changeHomeTab,
                    items: [
                      DefaultDropdownItem(
                        label: context.locale.dashboard_tab_title,
                        value: DefaultHomeTab.dashboard,
                      ),
                      DefaultDropdownItem(
                        label: context.locale.statistics_tab_title,
                        value: DefaultHomeTab.statistics,
                      ),
                      DefaultDropdownItem(
                        label: context.locale.notifications_tab_title,
                        value: DefaultHomeTab.notifications,
                      ),
                      DefaultDropdownItem(
                        label: context.locale.bedtime_tab_title,
                        value: DefaultHomeTab.bedtime,
                      ),
                    ],
                  ),
                  12.vBox,

                  /// Usage history in weeks
                  DefaultDropdownTile<int>(
                    titleText: context.locale.usage_history_tile_title,
                    dialogIcon: FluentIcons.history_20_filled,
                    value: digitoxSettings.usageHistoryWeeks,
                    onSelected: ref
                        .read(digitoxSettingsProvider.notifier)
                        .changeUsageHistoryWeeks,
                    items: [
                      DefaultDropdownItem(
                        label: context.locale.usage_history_15_days,
                        value: 2,
                      ),
                      DefaultDropdownItem(
                        label: context.locale.usage_history_1_month,
                        value: 4,
                      ),
                      DefaultDropdownItem(
                        label: context.locale.usage_history_3_month,
                        value: 13,
                      ),
                      DefaultDropdownItem(
                        label: context.locale.usage_history_6_month,
                        value: 26,
                      ),
                      DefaultDropdownItem(
                        label: context.locale.usage_history_1_year,
                        value: 52,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        /// AI Analysis settings
        12.vSliverBox,
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ModernSectionHeader(title: 'AI Analysis'),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SurfaceCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(Radii.pill),
                        ),
                        child: Icon(
                          FluentIcons.target_20_filled,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StyledText(
                              'Daily Screen Time Goal',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            StyledText(
                              'Used by AI to measure your progress',
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.75),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  20.vBox,
                  Consumer(
                    builder: (context, ref, _) {
                      final dailyGoalSec = ref.watch(
                        wellBeingProvider.select((v) => v.dailyScreenTimeGoalSec),
                      );
                      return Column(
                        children: [
                          Row(
                            children: [
                              _AIStepper(
                                colorScheme: colorScheme,
                                label: 'Hours',
                                value: dailyGoalSec ~/ 3600,
                                min: 1,
                                max: 12,
                                onDecrement: () {
                                  final newVal = (dailyGoalSec - 3600).clamp(3600, 12 * 3600);
                                  ref.read(wellBeingProvider.notifier).setDailyScreenTimeGoal(newVal);
                                },
                                onIncrement: () {
                                  final newVal = (dailyGoalSec + 3600).clamp(3600, 12 * 3600);
                                  ref.read(wellBeingProvider.notifier).setDailyScreenTimeGoal(newVal);
                                },
                              ),
                              const SizedBox(width: 12),
                              _AIStepper(
                                colorScheme: colorScheme,
                                label: 'Mins',
                                value: (dailyGoalSec % 3600) ~/ 60,
                                min: 0,
                                max: 59,
                                step: 15,
                                onDecrement: () {
                                  final newVal = dailyGoalSec - (15 * 60);
                                  if (newVal >= 3600) {
                                    ref.read(wellBeingProvider.notifier).setDailyScreenTimeGoal(newVal);
                                  }
                                },
                                onIncrement: () {
                                  final newVal = dailyGoalSec + (15 * 60);
                                  if (newVal <= 12 * 3600) {
                                    ref.read(wellBeingProvider.notifier).setDailyScreenTimeGoal(newVal);
                                  }
                                },
                              ),
                            ],
                          ),
                          8.vBox,
                          Center(
                            child: StyledText(
                              'Goal: ${(dailyGoalSec / 3600).toStringAsFixed(1)} hours',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Service
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ModernSectionHeader(title: context.locale.service_heading),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SurfaceCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  StyledText(
                    context.locale.service_stopping_warning,
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    textAlign: TextAlign.justify,
                  ),
                  12.vBox,
                  const SliverBatteryPermissionSwitchTile(),
                  12.vBox,
                  ModernListTile(
                    title: context.locale.whitelist_app_tile_title,
                    subtitle: context.locale.whitelist_app_tile_subtitle,
                    icon: FluentIcons.leaf_three_20_regular,
                    iconColor: colorScheme.primary,
                    showChevron: true,
                    onTap: () => _openAutoStartSettings(context),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverTabsBottomPadding(),
      ],
    );
  }
}

class _AIStepper extends StatelessWidget {
  final ColorScheme colorScheme;
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const _AIStepper({
    required this.colorScheme,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.step = 1,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          StyledText(
            label,
            fontSize: 11,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          8.vBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: value > min ? onDecrement : null,
                borderRadius: BorderRadius.circular(Radii.pill),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: value > min
                        ? colorScheme.primary.withValues(alpha: 0.1)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                  child: Icon(
                    FluentIcons.subtract_20_regular,
                    size: 16,
                    color: value > min ? colorScheme.primary : colorScheme.outline,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: StyledText(
                  value.toString(),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: value < max ? onIncrement : null,
                borderRadius: BorderRadius.circular(Radii.pill),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: value < max
                        ? colorScheme.primary.withValues(alpha: 0.1)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                  child: Icon(
                    FluentIcons.add_20_regular,
                    size: 16,
                    color: value < max ? colorScheme.primary : colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
