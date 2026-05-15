
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/config/app_constants.dart';
import 'package:nlp_digitox/core/utils/provider_utils.dart';
import 'package:nlp_digitox/models/usage_filter_model.dart';
import 'package:nlp_digitox/models/usage_model.dart';
import 'package:nlp_digitox/providers/usage/weekly_device_usage_provider.dart';
import 'package:nlp_digitox/providers/apps/apps_info_provider.dart';
import 'package:nlp_digitox/providers/apps/filtered_packages_provider.dart';
import 'package:nlp_digitox/providers/usage/todays_apps_usage_provider.dart';
import 'package:nlp_digitox/ui/common/default_refresh_indicator.dart';
import 'package:nlp_digitox/ui/common/content_section_header.dart';
import 'package:nlp_digitox/ui/common/sliver_implicitly_animated_list.dart';
import 'package:nlp_digitox/ui/common/sliver_usage_chart_panel.dart';
import 'package:nlp_digitox/ui/common/sliver_usage_cards.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/screens/home/statistics/application_tile.dart';
import 'package:nlp_digitox/ui/common/sliver_shimmer_list.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TabStatistics extends ConsumerStatefulWidget {
  const TabStatistics({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TabStatisticsState();
}

class _TabStatisticsState extends ConsumerState<TabStatistics> {
  UsageFilterModel _filter = UsageFilterModel.constant(includeAll: false);
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final weeklyUsages = ref.watch(weeklyDeviceUsageProvider(_filter.selectedWeek));
    final filteredApps = ref.watch(filteredPackagesProvider(_filter));

    return DefaultRefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        ref.read(appsInfoProvider.notifier).refreshAppsInfo();
        await ref.read(todaysAppsUsageProvider.notifier).refreshTodaysUsage();
        if (!mounted) return;
        setState(() => _isLoading = false);
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// Modern Stats Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeletonizer.zone(
                    enabled: _isLoading,
                    child: _buildModernUsageCards(context, _filter, weeklyUsages, colorScheme, isDark),
                  ),
                ],
              ),
            ),
          ),

            /// Usage chart section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverUsageChartPanel(
                selectedDay: _filter.selectedDay,
                selectedWeek: _filter.selectedWeek,
                usageType: _filter.usageType,
                barChartData: _isLoading ? generateEmptyWeekUsage(_filter.selectedDay) : weeklyUsages,
                onDayOfWeekChanged: (day) => setState(() => _filter = _filter.copyWith(selectedDay: day)),
                onWeekChanged: (day) => setState(() => _filter = _filter.copyWith(selectedWeek: day.weekRange)),
              ),
            ),

            24.vSliverBox,

            /// Most used apps section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StyledText(
                    context.locale.most_used_apps_heading,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  StyledText(
                    _filter.selectedDay.dateString(context),
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),

          16.vSliverBox,

          /// Apps list
          filteredApps.isLoading
              ? const SliverShimmerList(includeSubtitle: true)
              : SliverImplicitlyAnimatedList<String>(
                  items: filteredApps.value ?? [],
                  animationDurationMultiplier: 1.5,
                  keyBuilder: (item) => item,
                  itemBuilder: (context, i, package, itemPosition) =>
                      ApplicationTile(
                        packageName: package,
                        usageType: _filter.usageType,
                        selectedDay: _filter.selectedDay,
                        position: itemPosition,
                      ),
                ),

          20.vSliverBox,

          /// Show all apps button
          if (!_filter.includeAll && filteredApps.hasValue)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ModernListTile(
                  title: context.locale.show_all_apps_tile_title,
                  subtitle: 'View all installed apps',
                  icon: FluentIcons.select_all_off_20_regular,
                  iconColor: colorScheme.primary,
                  showChevron: true,
                  onTap: () => setState(() => _filter = _filter.copyWith(includeAll: true)),
                ),
              ),
            ),

          const SliverTabsBottomPadding(),
        ],
      ),
    );
  }

  Widget _buildModernUsageCards(BuildContext context, UsageFilterModel filter, Map<DateTime, UsageModel> weeklyUsages, ColorScheme colorScheme, bool isDark) {
    final usage = weeklyUsages[filter.selectedDay] ?? const UsageModel();

    return Row(
      children: [
        Expanded(
          child: _buildModernStatCard(
            context: context,
            title: 'Screen Time',
            value: usage.screenTime.toString(),
            icon: FluentIcons.phone_screen_time_20_regular,
            color: const Color(0xFF4DD6D9),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModernStatCard(
            context: context,
            title: 'Data',
            value: '${(usage.mobileData / 1024).toStringAsFixed(0)}MB',
            icon: FluentIcons.cellular_data_1_20_filled,
            color: const Color(0xFFF59E0B),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModernStatCard(
            context: context,
            title: 'WiFi',
            value: '${(usage.wifiData / 1024 / 1024).toStringAsFixed(1)}GB',
            icon: FluentIcons.wifi_1_20_filled,
            color: const Color(0xFFEC4899),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildModernStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          StyledText(value, fontSize: 16, fontWeight: FontWeight.bold),
          const SizedBox(height: 2),
          StyledText(title, fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
        ],
      ),
    );
  }
}
