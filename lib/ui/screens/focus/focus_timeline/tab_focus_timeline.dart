import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/core/extensions/ext_duration.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/core/utils/widget_utils.dart';
import 'package:nlp_digitox/providers/focus/dated_focus_provider.dart';
import 'package:nlp_digitox/providers/focus/monthly_focus_provider.dart';
import 'package:nlp_digitox/ui/common/default_refresh_indicator.dart';
import 'package:nlp_digitox/ui/common/empty_list_indicator.dart';
import 'package:nlp_digitox/ui/common/sliver_shimmer_list.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/usage_glance_card.dart';
import 'package:nlp_digitox/ui/screens/focus/focus_timeline/session_card.dart';
import 'package:nlp_digitox/ui/screens/focus/focus_timeline/sliver_heatmap_calender.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TabFocusTimeline extends ConsumerStatefulWidget {
  const TabFocusTimeline({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TabTimelineState();
}

class _TabTimelineState extends ConsumerState<TabFocusTimeline> {
  DateTimeRange _monthRange = dateToday.monthRange;
  DateTime _selectedDay = dateToday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final monthlyFocus = ref.watch(monthlyFocusProvider(_monthRange));
    final dailyFocus = ref.watch(datedFocusProvider(_selectedDay));

    return DefaultRefreshIndicator(
      onRefresh: () async {
        await ref
            .read(datedFocusProvider(_selectedDay).notifier)
            .refreshTimeline();
        await ref
            .read(monthlyFocusProvider(_monthRange).notifier)
            .refreshTimeline();
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// Modern info card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.18),
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
                        context.locale.focus_timeline_tab_info,
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

          24.vSliverBox,

          /// Productivity stats in modern card container
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          /// Total productive time
                          Expanded(
                            child: UsageGlanceCard(
                              isPrimary: true,
                              position: ItemPosition.topLeft,
                              icon: FluentIcons.clock_20_regular,
                              title: context.locale.focus_monthly_label,
                              info: monthlyFocus.totalProductiveTime.toTimeShort(context),
                              onTap: () => context.showSnackAlert(
                                context.locale.selected_month_productive_time_snack_alert(
                                  monthlyFocus.totalProductiveTime.toTimeFull(context),
                                ),
                                icon: FluentIcons.clock_20_filled,
                              ),
                            ),
                          ),
                          4.hBox,

                          /// Productive days
                          Expanded(
                            child: UsageGlanceCard(
                              isPrimary: true,
                              position: ItemPosition.topRight,
                              icon: FluentIcons.calendar_day_20_regular,
                              title: context.locale.selected_month_productive_days_label,
                              info:
                                  context.locale.nDays(monthlyFocus.totalProductiveDays),
                              onTap: () => context.showSnackAlert(
                                context.locale.selected_month_productive_days_snack_alert(
                                  monthlyFocus.totalProductiveDays,
                                ),
                                icon: FluentIcons.calendar_day_20_filled,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    4.vBox,

                    /// Today's total focused time
                    Skeletonizer.zone(
                      enabled: dailyFocus.selectedDaysSessions.isLoading,
                      ignorePointers: false,
                      child: UsageGlanceCard(
                        isPrimary: true,
                        position: ItemPosition.bottom,
                        icon: FluentIcons.shifts_day_20_regular,
                        title: context.locale.selected_day_focused_time_label,
                        info: dailyFocus.selectedDaysFocusedTime.toTimeFull(context),
                        onTap: () => context.showSnackAlert(
                          context.locale.selected_day_focused_time_snack_alert(
                            dailyFocus.selectedDaysFocusedTime.toTimeFull(context),
                          ),
                          icon: FluentIcons.shifts_day_20_filled,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Calendar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: ModernSectionHeader(title: context.locale.calender_heading),
            ),
          ),
          SliverHeatMapCalendar(
            heatmapData: monthlyFocus.monthlyFocus,
            onDayChanged: (day) => setState(() => _selectedDay = day),
            onMonthChanged: (date) =>
                setState(() => _monthRange = date.monthRange),
          ),

          8.vSliverBox,
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ModernSectionHeader(title: context.locale.your_sessions_heading),
            ),
          ),
          8.vSliverBox,

          /// List of today's sessions
          dailyFocus.selectedDaysSessions.when(
            data: (sessions) {
              if (sessions.isEmpty) {
                return EmptyListIndicator(
                  info: context.locale.your_sessions_empty_list_hint,
                ).sliver;
              }
              return SliverList.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) => SessionCard(
                  position: getItemPositionInList(index, sessions.length),
                  session: sessions[index],
                ),
              );
            },
            loading: () => SliverShimmerList(includeSubtitle: true),
            error: (e, s) => EmptyListIndicator(
              info: 'Failed to load sessions',
            ).sliver,
          ),

          const SliverTabsBottomPadding(),
        ],
      ),
    );
  }
}
