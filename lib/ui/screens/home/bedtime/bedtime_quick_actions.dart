import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/providers/restrictions/bedtime_provider.dart';
import 'package:nlp_digitox/ui/common/device_dnd_tile.dart';
import 'package:nlp_digitox/ui/dialogs/modal_bottom_sheet.dart';
import 'package:nlp_digitox/ui/screens/home/bedtime/bedtime_distracting_apps_list.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';
import 'package:sliver_tools/sliver_tools.dart';

class BedtimeQuickActions extends ConsumerWidget {
  const BedtimeQuickActions({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final shouldStartDnd =
        ref.watch(bedtimeScheduleProvider.select((v) => v.shouldStartDnd));

    final isScheduleOn =
        ref.watch(bedtimeScheduleProvider.select((v) => v.isScheduleOn));

    return MultiSliver(
      children: [
        /// Bedtime actions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ModernSectionHeader(title: context.locale.quick_actions_heading),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(Radii.xl),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  /// Should start dnd
                  ModernSettingsTile(
                    title: context.locale.permission_dnd_tile_title,
                    subtitle: context.locale.permission_dnd_tile_subtitle,
                    icon: FluentIcons.brightness_high_20_regular,
                    iconColor: colorScheme.tertiary,
                    value: shouldStartDnd,
                    onChanged: !isScheduleOn
                        ? (_) => ref
                            .read(bedtimeScheduleProvider.notifier)
                            .setShouldStartDnd(!shouldStartDnd)
                        : null,
                  ),
                  const SizedBox(height: 12),

                  /// Manage Dnd settings
                  const DeviceDndTile(),

                  const SizedBox(height: 12),

                  /// Manage distracting apps
                  ModernListTile(
                    title: context.locale.distracting_apps_tile_title,
                    subtitle: context.locale.distracting_apps_tile_subtitle,
                    icon: FluentIcons.weather_moon_20_regular,
                    iconColor: colorScheme.primary,
                    showChevron: true,
                    onTap: () => showDefaultBottomSheet(
                      context: context,
                      sliverBody: const BedtimeDistractingAppsList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
