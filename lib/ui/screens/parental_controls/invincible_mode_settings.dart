import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/providers/system/parental_controls_provider.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/dialogs/confirmation_dialog.dart';
import 'package:nlp_digitox/ui/dialogs/time_picker_dialog.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';
import 'package:sliver_tools/sliver_tools.dart';

class InvincibleModeSettings extends ConsumerWidget {
  const InvincibleModeSettings({super.key});

  void _turnOnInvincibleMode(
    BuildContext context,
    WidgetRef ref,
    bool isOn,
  ) async {
    if (!isOn) {
      final isConfirm = await showConfirmationDialog(
        context: context,
        icon: FluentIcons.animal_cat_20_filled,
        heroTag: HeroTags.invincibleModeTileTag,
        title: context.locale.invincible_mode_heading,
        info: context.locale.invincible_mode_dialog_info,
        positiveLabel:
            context.locale.invincible_mode_dialog_button_start_anyway,
      );
      if (isConfirm) {
        ref.read(parentalControlsProvider.notifier).switchInvincibleMode();
      }
    } else {
      context.showSnackAlert(
        context.locale.invincible_mode_turn_off_snack_alert,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final parentalControls = ref.watch(parentalControlsProvider);

    return MultiSliver(
      children: [
        /// Invincible mode header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ModernSectionHeader(
            title: context.locale.invincible_mode_heading,
          ),
        ).sliver,

        /// Information card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      FluentIcons.info_20_filled,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: StyledText(
                      context.locale.invincible_mode_info,
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.75),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Mode toggle + window in modern card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  /// Invincible mode toggle
                  DefaultHero(
                    tag: HeroTags.invincibleModeTileTag,
                    child: ModernSettingsTile(
                      title: context.locale.invincible_mode_tile_title,
                      subtitle: null,
                      icon: FluentIcons.animal_cat_20_regular,
                      iconColor: colorScheme.primary,
                      value: parentalControls.isInvincibleModeOn,
                      onChanged: (_) => _turnOnInvincibleMode(
                        context,
                        ref,
                        parentalControls.isInvincibleModeOn,
                      ),
                    ),
                  ),
                  12.vBox,

                  /// Invincible window
                  DefaultHero(
                    tag: HeroTags.invincibleWindowTileTag,
                    child: ModernListTile(
                      title: context.locale.invincible_window_tile_title,
                      subtitle: context.locale.invincible_window_tile_subtitle,
                      icon: FluentIcons.clock_20_regular,
                      iconColor: colorScheme.primary,
                      showChevron: false,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: StyledText(
                          parentalControls.invincibleWindowTime.format(context),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      onTap: () async {
                        /// Check if between the specified window
                        if (parentalControls.isInvincibleModeOn &&
                            !ref
                                .read(parentalControlsProvider.notifier)
                                .isBetweenInvincibleWindow) {
                          context
                              .showSnackAlert(context.locale.invincible_mode_snack_alert);
                          return;
                        }

                        final pickedTime = await showCustomTimePickerDialog(
                          context: context,
                          heroTag: HeroTags.invincibleWindowTileTag,
                          initialTime: parentalControls.invincibleWindowTime,
                          info: context.locale.invincible_window_tile_title,
                        );

                        if (pickedTime != null && context.mounted) {
                          ref
                              .read(parentalControlsProvider.notifier)
                              .changeInvincibleWindowTime(pickedTime);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        12.vSliverBox,

        /// App restrictions in modern card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          FluentIcons.apps_20_regular,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      12.hBox,
                      StyledText(
                        context.locale.invincible_mode_app_restrictions_tile_title,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  12.vBox,
                  /// Apps timer
                  _buildCheckItem(
                    context: context,
                    colorScheme: colorScheme,
                    enabled: !parentalControls.isInvincibleModeOn ||
                        !parentalControls.includeAppsTimer,
                    isSelected: parentalControls.includeAppsTimer,
                    icon: FluentIcons.timer_20_regular,
                    title: context.locale.invincible_mode_include_timer_tile_title,
                    onTap: ref
                        .read(parentalControlsProvider.notifier)
                        .toggleIncludeAppsTimer,
                  ),
                  4.vBox,
                  /// Apps launch limit
                  _buildCheckItem(
                    context: context,
                    colorScheme: colorScheme,
                    enabled: !parentalControls.isInvincibleModeOn ||
                        !parentalControls.includeAppsLaunchLimit,
                    isSelected: parentalControls.includeAppsLaunchLimit,
                    icon: FluentIcons.rocket_20_regular,
                    title: context.locale.invincible_mode_include_launch_limit_tile_title,
                    onTap: ref
                        .read(parentalControlsProvider.notifier)
                        .toggleIncludeAppsLaunchLimit,
                  ),
                  4.vBox,
                  /// Apps active period
                  _buildCheckItem(
                    context: context,
                    colorScheme: colorScheme,
                    enabled: !parentalControls.isInvincibleModeOn ||
                        !parentalControls.includeAppsActivePeriod,
                    isSelected: parentalControls.includeAppsActivePeriod,
                    icon: FluentIcons.drink_coffee_20_regular,
                    title: context.locale.invincible_mode_include_active_period_tile_title,
                    onTap: ref
                        .read(parentalControlsProvider.notifier)
                        .toggleIncludeAppsActivePeriod,
                  ),
                ],
              ),
            ),
          ),
        ),

        12.vSliverBox,

        /// Group restrictions in modern card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          FluentIcons.app_recent_20_regular,
                          color: colorScheme.secondary,
                          size: 20,
                        ),
                      ),
                      12.hBox,
                      StyledText(
                        context.locale.invincible_mode_group_restrictions_tile_title,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  12.vBox,
                  /// Groups timer
                  _buildCheckItem(
                    context: context,
                    colorScheme: colorScheme,
                    enabled: !parentalControls.isInvincibleModeOn ||
                        !parentalControls.includeGroupsTimer,
                    isSelected: parentalControls.includeGroupsTimer,
                    icon: FluentIcons.timer_20_regular,
                    title: context.locale.invincible_mode_include_timer_tile_title,
                    onTap: ref
                        .read(parentalControlsProvider.notifier)
                        .toggleIncludeGroupsTimer,
                  ),
                  4.vBox,
                  /// Groups active period
                  _buildCheckItem(
                    context: context,
                    colorScheme: colorScheme,
                    enabled: !parentalControls.isInvincibleModeOn ||
                        !parentalControls.includeGroupsActivePeriod,
                    isSelected: parentalControls.includeGroupsActivePeriod,
                    icon: FluentIcons.drink_coffee_20_regular,
                    title: context.locale.invincible_mode_include_active_period_tile_title,
                    onTap: ref
                        .read(parentalControlsProvider.notifier)
                        .toggleIncludeGroupsActivePeriod,
                  ),
                ],
              ),
            ),
          ),
        ),

        12.vSliverBox,

        /// Shorts timer + Bedtime in modern card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  /// Shorts timer
                  _buildCheckItem(
                    context: context,
                    colorScheme: colorScheme,
                    enabled: !parentalControls.isInvincibleModeOn ||
                        !parentalControls.includeShortsTimer,
                    isSelected: parentalControls.includeShortsTimer,
                    icon: FluentIcons.video_clip_multiple_20_regular,
                    title: context.locale.invincible_mode_include_shorts_timer_tile_title,
                    subtitle: context.locale.invincible_mode_include_shorts_timer_tile_subtitle,
                    onTap: ref
                        .read(parentalControlsProvider.notifier)
                        .toggleIncludeShortsTimer,
                  ),
                  4.vBox,

                  /// Bedtime schedule
                  _buildCheckItem(
                    context: context,
                    colorScheme: colorScheme,
                    enabled: !parentalControls.isInvincibleModeOn ||
                        !parentalControls.includeBedtimeSchedule,
                    isSelected: parentalControls.includeBedtimeSchedule,
                    icon: FluentIcons.sleep_20_regular,
                    title: context.locale.invincible_mode_include_bedtime_tile_title,
                    subtitle: context.locale.invincible_mode_include_bedtime_tile_subtitle,
                    onTap: ref
                        .read(parentalControlsProvider.notifier)
                        .toggleIncludeBedtimeSchedule,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckItem({
    required BuildContext context,
    required ColorScheme colorScheme,
    required bool enabled,
    required bool isSelected,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.25)
                    : colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: colorScheme.primary),
                ),
                12.hBox,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StyledText(
                        title,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        StyledText(
                          subtitle,
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? FluentIcons.checkbox_checked_20_filled
                      : FluentIcons.checkbox_unchecked_20_regular,
                  color: isSelected ? colorScheme.primary : colorScheme.outline,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
