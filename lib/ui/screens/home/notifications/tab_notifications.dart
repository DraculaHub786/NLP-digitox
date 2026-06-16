
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/enums/recap_type.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/providers/notifications/dated_notifications_provider.dart';
import 'package:nlp_digitox/providers/notifications/notification_settings_provider.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/common/default_dropdown_tile.dart';
import 'package:nlp_digitox/ui/common/default_refresh_indicator.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/dialogs/modal_bottom_sheet.dart';
import 'package:nlp_digitox/ui/permissions/notification_access_permission_card.dart';
import 'package:nlp_digitox/ui/screens/home/notifications/sliver_batched_apps_list.dart';
import 'package:nlp_digitox/ui/screens/home/notifications/sliver_schedules_list.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

class TabNotifications extends ConsumerStatefulWidget {
  const TabNotifications({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TabNotificationsState();
}

class _TabNotificationsState extends ConsumerState<TabNotifications> {
  DateTimeRange _last24Hours = DateTime.now().last24Hours;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final havePermission = ref.watch(
        permissionProvider.select((v) => v.haveNotificationAccessPermission));

    final settings = ref.watch(notificationSettingsProvider);

    final notificationsCount = ref.watch(
        datedNotificationsProvider(_last24Hours)
            .select((v) => v.value?.length ?? 0));

return DefaultRefreshIndicator(
      onRefresh: () async {
        if (mounted) setState(() => _last24Hours = DateTime.now().last24Hours);
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// Modern Header Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StyledText(
                    context.locale.notifications_tab_info,
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),

          /// Modern Stats Cards Row
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final textScale = MediaQuery.textScalerOf(context).scale(1);
                  final cardHeight = textScale > 1.1 ? 180.0 : 140.0;
                  return SizedBox(
                    height: cardHeight,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildModernStatCard(
                            context: context,
                            title: 'Notifications',
                            value: notificationsCount.toString(),
                            icon: FluentIcons.alert_badge_20_regular,
                            color: colorScheme.primary,
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.notificationsPath),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModernStatCard(
                            context: context,
                            title: 'Batched Apps',
                            value: settings.batchedApps.length.toString(),
                            icon: FluentIcons.app_recent_20_regular,
                            color: colorScheme.secondary,
                            onTap: () => showDefaultBottomSheet(
                              context: context,
                              sliverBody: const SliverBatchedAppsList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          24.vSliverBox,

          /// Permission Card
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            sliver: NotificationAccessPermissionCard(),
          ),

          16.vSliverBox,

          /// Modern Settings Tiles
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  /// Store all toggle
                  ModernSettingsTile(
                    title: context.locale.store_all_tile_title,
                    subtitle: context.locale.store_all_tile_subtitle,
                    icon: FluentIcons.save_20_regular,
                    iconColor: colorScheme.tertiary,
                    value: settings.storeNonBatchedToo,
                    onChanged: (_) => ref
                        .read(notificationSettingsProvider.notifier)
                        .toggleStoreNonBatched,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          /// History dropdown
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DefaultDropdownTile<int>(
                value: settings.notificationHistoryWeeks,
                onSelected: ref
                    .read(notificationSettingsProvider.notifier)
                    .changeNotificationHistoryWeeks,
                titleText: context.locale.notification_history_tile_title,
                dialogIcon: FluentIcons.history_20_filled,
                items: [
                  DefaultDropdownItem(label: '15 Days', value: 2),
                  DefaultDropdownItem(label: '1 Month', value: 4),
                  DefaultDropdownItem(label: '3 Months', value: 13),
                  DefaultDropdownItem(label: '6 Months', value: 26),
                  DefaultDropdownItem(label: '1 Year', value: 52),
                ],
              ),
            ),
          ),

          /// Recap type dropdown
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DefaultDropdownTile<RecapType>(
                value: settings.recapType,
                onSelected:
                    ref.read(notificationSettingsProvider.notifier).setRecapType,
                titleText: context.locale.batch_recap_dropdown_title,
                infoText: context.locale.batch_recap_dropdown_info,
                dialogIcon: FluentIcons.alert_urgent_20_filled,
                items: [
                  DefaultDropdownItem(label: 'Summary Only', value: RecapType.summeryOnly),
                  DefaultDropdownItem(label: 'All Notifications', value: RecapType.allNotifications),
                ],
              ),
            ),
          ),

          24.vSliverBox,

          /// Schedules Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StyledText(
                context.locale.schedules_heading,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          12.vSliverBox,

          SliverSchedulesList(
            haveNotificationAccessPermission: havePermission,
          ),

          const SliverTabsBottomPadding(),
        ],
      ),
    );
  }

  Widget _buildModernStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final borderColor = colorScheme.outline.withValues(alpha: 0.2);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 150;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isCompact ? 8 : 10),
                      decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: isCompact ? 20 : 22,
                      ),
                    ),
                    const SizedBox.shrink(),
                  ],
                ),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: StyledText(
                    value,
                    fontSize: isCompact ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                StyledText(
                  title,
                  fontSize: 13,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
