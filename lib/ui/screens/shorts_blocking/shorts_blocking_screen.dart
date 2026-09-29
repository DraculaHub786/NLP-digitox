import 'dart:math';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/providers/restrictions/wellbeing_provider.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/providers/usage/shorts_screen_time_provider.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';
import 'package:nlp_digitox/ui/permissions/accessibility_permission_card.dart';
import 'package:nlp_digitox/ui/permissions/battery_optimization_recommendation_card.dart';
import 'package:nlp_digitox/ui/screens/shorts_blocking/shorts_timer_chart.dart';
import 'package:nlp_digitox/ui/screens/shorts_blocking/sliver_shorts_quick_actions.dart';

class ShortsBlockingScreen extends ConsumerWidget {
  const ShortsBlockingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final shortsScreenTimeSec = ref.watch(shortsScreenTimeProvider).value ?? 0;

    final allowedShortContentTimeSec =
        ref.watch(wellBeingProvider.select((v) => v.allowedShortsTimeSec));

    final haveAccessibilityPermission = ref.watch(
      permissionProvider.select((v) => v.haveAccessibilityPermission),
    );

    final remainingTimeSec = allowedShortContentTimeSec.isNegative
        ? 0
        : max(
            0,
            (allowedShortContentTimeSec - shortsScreenTimeSec),
          );

    return ScaffoldShell(
      items: [
        NavbarItem(
          icon: FluentIcons.resize_video_20_regular,
          filledIcon: FluentIcons.resize_video_20_filled,
          titleText: context.locale.shorts_blocking_tab_title,
          sliverBody: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Section header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                  child: ModernSectionHeader(
                    title: context.locale.shorts_blocking_tab_title,
                    subtitle: allowedShortContentTimeSec > 0
                        ? '${(shortsScreenTimeSec / 60).toStringAsFixed(0)}m used today'
                        : 'No time limit set',
                    trailing: allowedShortContentTimeSec > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: remainingTimeSec > 0
                                  ? colorScheme.primaryContainer
                                  : colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(Radii.pill),
                            ),
                            child: StyledText(
                              '${(remainingTimeSec / 60).toStringAsFixed(0)}m left',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: remainingTimeSec > 0
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onErrorContainer,
                            ),
                          )
                        : null,
                  ),
                ),
              ),

              // Info card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(Radii.xl),
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
                            context.locale.shorts_blocking_tab_info,
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

              // Short content header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                  child: ModernSectionHeader(
                    title: context.locale.short_content_heading,
                  ),
                ),
              ),

              // Short usage progress bar
              ShortsTimerChart(
                haveNecessaryPerms: haveAccessibilityPermission,
                allowedTimeSec: max(allowedShortContentTimeSec, 0),
                remainingTimeSec: remainingTimeSec,
              ).sliver,

              const AccessibilityPermissionCard(),

              // C.1 + C.2: Battery optimization recommendation & OEM autostart
              const BatteryOptimizationRecommendationCard(),

              // Quick actions
              SliverShortsQuickActions(
                haveNecessaryPerms: haveAccessibilityPermission,
              ),

              const SliverTabsBottomPadding(),
            ],
          ),
        )
      ],
    );
  }
}
