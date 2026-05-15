
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/providers/restrictions/bedtime_provider.dart';
import 'package:nlp_digitox/providers/system/parental_controls_provider.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/content_section_header.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/screens/home/bedtime/bedtime_schedule_card.dart';
import 'package:nlp_digitox/ui/screens/home/bedtime/bedtime_quick_actions.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

class TabBedtime extends ConsumerWidget {
  const TabBedtime({super.key});

  void _setScheduleStatus(
    WidgetRef ref,
    BuildContext context,
    bool shouldStart,
  ) async {
    final state = ref.read(bedtimeScheduleProvider);

    if (!state.scheduleDays.contains(true)) {
      context.showSnackAlert(
        context.locale.bedtime_no_days_selected_snack_alert,
      );
      return;
    }

    if (state.scheduleDurationInMins < 30) {
      context.showSnackAlert(
        context.locale.bedtime_minimum_duration_snack_alert,
      );
      return;
    }

    if (shouldStart && state.distractingApps.isEmpty) {
      context.showSnackAlert(
        context.locale.minimum_distracting_apps_snack_alert,
      );
      return;
    }

    final isInvincibleRestricted = ref.read(parentalControlsProvider
            .select((v) => v.isInvincibleModeOn && v.includeBedtimeSchedule)) &&
        !ref.read(parentalControlsProvider.notifier).isBetweenInvincibleWindow;

    final isBetweenSchedule =
        ref.read(bedtimeScheduleProvider.notifier).isBetweenSchedule;

    if (isInvincibleRestricted && state.isScheduleOn && isBetweenSchedule) {
      context.showSnackAlert(context.locale.invincible_mode_snack_alert);
      return;
    }

    ref
        .read(bedtimeScheduleProvider.notifier)
        .switchBedtimeSchedule(shouldStart);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isScheduleOn =
        ref.watch(bedtimeScheduleProvider.select((v) => v.isScheduleOn));

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        /// Modern Header Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                StyledText(
                  context.locale.bedtime_tab_info,
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),

        /// Modern Schedule Toggle Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildScheduleToggleCard(context, ref, isScheduleOn, colorScheme, isDark),
          ),
        ),

        24.vSliverBox,

        /// Schedule Configuration Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black : Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          FluentIcons.calendar_clock_20_regular,
                          color: Color(0xFF6366F1),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      StyledText(
                        context.locale.schedule_tile_title,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const BedtimeScheduleCard(),
                ],
              ),
            ),
          ),
        ),

        24.vSliverBox,

        /// Quick Actions Section
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          sliver: BedtimeQuickActions(),
        ),

        const SliverTabsBottomPadding()
      ],
    );
  }

  Widget _buildScheduleToggleCard(BuildContext context, WidgetRef ref, bool isScheduleOn, ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isScheduleOn
              ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
              : [colorScheme.surfaceContainerHighest, colorScheme.surfaceContainerHighest],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isScheduleOn
                ? const Color(0xFF6366F1).withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isScheduleOn
                  ? Colors.white.withValues(alpha: 0.2)
                  : colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              FluentIcons.sleep_20_filled,
              color: isScheduleOn ? Colors.white : colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  isScheduleOn ? 'Sleep Mode Active' : 'Sleep Mode',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isScheduleOn ? Colors.white : null,
                ),
                const SizedBox(height: 4),
                StyledText(
                  context.locale.schedule_tile_subtitle,
                  fontSize: 12,
                  color: isScheduleOn
                      ? Colors.white.withValues(alpha: 0.8)
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch.adaptive(
              value: isScheduleOn,
              onChanged: (_) => _setScheduleStatus(ref, context, !isScheduleOn),
              activeColor: Colors.white,
              activeTrackColor: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}