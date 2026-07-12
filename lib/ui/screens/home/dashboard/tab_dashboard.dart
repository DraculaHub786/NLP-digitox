import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/enums/default_home_tab.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_list.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/ui/screens/productivity/habits_screen.dart';
import 'package:nlp_digitox/ui/screens/productivity/tasks_screen.dart';
import 'package:nlp_digitox/ui/screens/productivity/notes_screen.dart';
import 'package:nlp_digitox/providers/usage/todays_apps_usage_provider.dart';
import 'package:nlp_digitox/ui/common/sliver_active_session_alert.dart';
import 'package:nlp_digitox/ui/common/default_refresh_indicator.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/controllers/tab_controller_provider.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/sliver_ai_analysis.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/sliver_funny_motivation.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_glance_cards.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TabDashboard extends ConsumerWidget {
  const TabDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUsageLoading =
        ref.watch(todaysAppsUsageProvider.select((v) => v.isLoading));

    return DefaultRefreshIndicator(
      onRefresh: () async => ref
          .read(todaysAppsUsageProvider.notifier)
          .refreshTodaysUsage(resetState: true),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// Active session
          const SliverActiveSessionAlert(),

            /// Modern Dashboard UI ABOVE AI Analysis
            MultiSliver(
              children: [
                16.vBox,

              /// Modern Stats Cards Section
              _buildModernStatsSection(context, isUsageLoading),

              24.vBox,

              /// Quick Actions Section
              _buildQuickActionsSection(context),

              24.vBox,

              /// Glance Cards Section
              _buildGlanceSection(context, isUsageLoading),

              24.vBox,

              /// Restrictions Section
              _buildRestrictionsSection(context),

              24.vBox,

              /// Productivity Section
              _buildProductivitySection(context),

              16.vBox,
            ].animateListOnce(
              ref: ref,
              uniqueKey: "home.dashboard",
              delay: 100.ms,
              interval: 80.ms,
            ),
          ),

          /// Funny Motivation — dismissible, tonally separate from AI Analysis
          const SliverFunnyMotivation(),

          /// AI Analysis Section - KEEP EXACTLY AS IS
          const SliverAIAnalysis(),

          const SliverTabsBottomPadding(),
        ],
      ),
    );
  }

  Widget _buildModernStatsSection(BuildContext context, bool isLoading) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ModernSectionHeader(
              title: "Today's Overview",
              subtitle: "Your digital wellness at a glance",
            ),
            const SizedBox(height: 16),
            Skeletonizer.zone(
              enabled: isLoading,
              enableSwitchAnimation: true,
              child: const ModernStatsCards(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ModernSectionHeader(
              title: "Quick Actions",
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                // Only show side-by-side if width allows
                final useRow = constraints.maxWidth >= 240;
                if (useRow) {
                  return Row(
                    children: [
                      Expanded(
                        child: ModernQuickActionButton(
                          title: "Focus Now",
                          icon: FluentIcons.target_20_filled,
                          color: colorScheme.primary,
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.focusModePath,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ModernQuickActionButton(
                          title: "View Stats",
                          icon: FluentIcons.chart_multiple_20_regular,
                          color: colorScheme.secondary,
                          onTap: () => TabControllerProvider.maybeOf(context)?.animateToTab(
                            DefaultHomeTab.statistics.index,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  spacing: 10,
                  children: [
                    ModernQuickActionButton(
                      title: "Focus Now",
                      icon: FluentIcons.target_20_filled,
                      color: colorScheme.primary,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.focusModePath,
                      ),
                    ),
                    ModernQuickActionButton(
                      title: "View Stats",
                      icon: FluentIcons.chart_multiple_20_regular,
                      color: colorScheme.secondary,
                      onTap: () => TabControllerProvider.maybeOf(context)?.animateToTab(
                        DefaultHomeTab.statistics.index,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlanceSection(BuildContext context, bool isLoading) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StyledText(
                        context.locale.glance_tile_title,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      StyledText(
                        context.locale.glance_tile_subtitle,
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Skeletonizer.zone(
              enabled: isLoading,
              enableSwitchAnimation: true,
              child: const ModernGlanceGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestrictionsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ModernCategorySection(
          title: "Restrictions",
          children: [
            /// Apps blocking
            ModernListTile(
              title: context.locale.apps_blocking_tile_title,
              subtitle: context.locale.apps_blocking_tile_subtitle,
              icon: FluentIcons.app_title_20_regular,
              iconColor: colorScheme.primary,
              onTap: () => TabControllerProvider.maybeOf(context)?.animateToTab(
                DefaultHomeTab.statistics.index,
              ),
            ),

            /// Grouped apps blocking
            ModernListTile(
              title: context.locale.grouped_apps_blocking_tile_title,
              subtitle: context.locale.grouped_apps_blocking_tile_subtitle,
              icon: FluentIcons.app_recent_20_regular,
              iconColor: colorScheme.secondary,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.restrictionGroupsPath,
              ),
            ),

            /// Shorts restrictions
            ModernListTile(
              title: context.locale.shorts_blocking_tab_title,
              subtitle: context.locale.shorts_blocking_tile_subtitle,
              icon: FluentIcons.resize_video_20_regular,
              iconColor: colorScheme.tertiary,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.shortsBlockingPath,
              ),
            ),

            /// Website restrictions
            ModernListTile(
              title: context.locale.websites_blocking_tab_title,
              subtitle: context.locale.websites_blocking_tile_subtitle,
              icon: FluentIcons.earth_20_regular,
              iconColor: colorScheme.primary,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.websitesBlockingPath,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivitySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ModernCategorySection(
          title: "Productivity",
          children: [
            /// Habits
            ModernListTile(
              title: "Habits",
              subtitle: "Build better habits and track them.",
              icon: FluentIcons.drink_coffee_20_regular,
              iconColor: colorScheme.secondary,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HabitsScreen()),
              ),
            ),

            /// Tasks and todos
            ModernListTile(
              title: "Tasks and Todos",
              subtitle: "Plan your future with tasks and todos.",
              icon: FluentIcons.reading_list_20_regular,
              iconColor: colorScheme.primary,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TasksScreen()),
              ),
            ),

            /// Notes & lists
            ModernListTile(
              title: "Notes and Lists",
              subtitle: "Capture thoughts, checklists, or ideas.",
              icon: FluentIcons.note_20_regular,
              iconColor: colorScheme.tertiary,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotesScreen()),
              ),
            ),

            /// Parental Controls
            ModernListTile(
              title: context.locale.parental_controls_tab_title,
              subtitle: context.locale.parental_controls_tile_subtitle,
              icon: FluentIcons.shield_keyhole_20_regular,
              iconColor: colorScheme.primary,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.parentalControlsPath,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
