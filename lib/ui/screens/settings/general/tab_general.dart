import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/app_themes.dart';
import 'package:nlp_digitox/core/enums/app_theme_mode.dart';
import 'package:nlp_digitox/core/enums/default_home_tab.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/config/locales.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/l10n/generated/app_localizations.dart';
import 'package:nlp_digitox/providers/system/mindful_settings_provider.dart';
import 'package:nlp_digitox/ui/common/content_section_header.dart';
import 'package:nlp_digitox/ui/common/default_dropdown_tile.dart';
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
    final mindfulSettings = ref.watch(mindfulSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        /// Appearance
        ContentSectionHeader(
          title: context.locale.appearance_heading,
        ).sliver,

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  /// Theme mode
                  DefaultDropdownTile<AppThemeMode>(
                    value: mindfulSettings.themeMode,
                    dialogIcon: FluentIcons.dark_theme_20_filled,
                    titleText: context.locale.theme_mode_tile_title,
                    onSelected:
                        ref.read(mindfulSettingsProvider.notifier).changeThemeMode,
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
                    value: mindfulSettings.accentColor,
                    onSelected: ref.read(mindfulSettingsProvider.notifier).changeColor,
                    trailingBuilder: (item) => Container(
                      height: 18,
                      width: 18,
                      decoration: BoxDecoration(
                        color: AppTheme.materialColors[item],
                        borderRadius: BorderRadius.circular(18),
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
                    value: mindfulSettings.useAmoledDark,
                    onChanged: (_) =>
                        ref.read(mindfulSettingsProvider.notifier).switchAmoledDark(),
                  ),
                  8.vBox,

                  /// Dynamic colors
                  ModernSettingsTile(
                    title: context.locale.dynamic_colors_tile_title,
                    subtitle: context.locale.dynamic_colors_tile_subtitle,
                    icon: FluentIcons.color_20_regular,
                    iconColor: colorScheme.tertiary,
                    value: mindfulSettings.useDynamicColors,
                    onChanged: (_) =>
                        ref.read(mindfulSettingsProvider.notifier).switchDynamicColor(),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Default settings
        12.vSliverBox,
        ContentSectionHeader(title: context.locale.defaults_heading).sliver,

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  /// App Language
                  DefaultDropdownTile<String>(
                    titleText: context.locale.app_language_tile_title,
                    dialogIcon: FluentIcons.color_20_filled,
                    value: mindfulSettings.localeCode,
                    onSelected: ref.read(mindfulSettingsProvider.notifier).changeLocale,
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
                    value: mindfulSettings.defaultHomeTab,
                    onSelected:
                        ref.read(mindfulSettingsProvider.notifier).changeHomeTab,
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
                    value: mindfulSettings.usageHistoryWeeks,
                    onSelected: ref
                        .read(mindfulSettingsProvider.notifier)
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

        /// Service
        ContentSectionHeader(title: context.locale.service_heading).sliver,

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  StyledText(
                    context.locale.service_stopping_warning,
                    fontSize: 13,
                    color: colorScheme.onSurface.withOpacity(0.7),
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
