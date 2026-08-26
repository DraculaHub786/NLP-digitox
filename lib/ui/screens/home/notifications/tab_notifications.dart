import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/enums/recap_type.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/services/notification_scheduler_service.dart';
import 'package:nlp_digitox/models/notification_schedule.dart';
import 'package:nlp_digitox/providers/notifications/dated_notifications_provider.dart';
import 'package:nlp_digitox/providers/notifications/notification_settings_provider.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/common/default_dropdown_tile.dart';
import 'package:nlp_digitox/ui/common/default_refresh_indicator.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';
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
                        .toggleStoreNonBatched(),
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

          /// Debug diagnostic (P0 todo 1.7) — surfaces exactly what's
          /// registered with the OS right now, so "no notification" reports
          /// can be answered with data instead of log re-reading.
          /// Debug builds only; stripped from release by kDebugMode check.
          if (kDebugMode)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _PendingNotificationsDiagnosticTile(),
              ),
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
    final cardColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);
    final borderColor = colorScheme.outline.withValues(alpha: 0.18);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(Radii.xl),
          border: Border.all(color: borderColor),
          boxShadow: ElevationTokens.of(context).level(1),
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
                      borderRadius: BorderRadius.circular(Radii.pill),
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

/// Debug-only tile cross-referencing the app's ACTIVE [NotificationSchedule]s
/// against what the OS has ACTUALLY registered as pending. A mismatch means
/// some enabled schedules were silently dropped between our zonedSchedule()
/// call and the OS AlarmManager — pinpointing exactly where the pipeline
/// broke, instead of guessing from logs.
class _PendingNotificationsDiagnosticTile extends ConsumerStatefulWidget {
  const _PendingNotificationsDiagnosticTile();

  @override
  ConsumerState<_PendingNotificationsDiagnosticTile> createState() =>
      _PendingNotificationsDiagnosticTileState();
}

class _PendingNotificationsDiagnosticTileState
    extends ConsumerState<_PendingNotificationsDiagnosticTile> {
  List<PendingNotificationRequest>? _pending;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await NotificationSchedulerService.instance.initialize();
      final pending =
          await NotificationSchedulerService.instance.getPendingNotifications();
      // Only show the app's own scheduled reminders (IDs 1000-1099).
      final scheduleIds =
          pending.where((n) => n.id >= 1000 && n.id < 1100).toList();
      if (!mounted) return;
      setState(() {
        _pending = scheduleIds;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _formatScheduleTime(NotificationSchedule s) =>
      '${s.time.hour}:${s.time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    /// App-side source of truth: which schedules the user has switched ON.
    /// Each active one SHOULD have a matching pending entry in the OS.
    final List<NotificationSchedule> activeSchedules = ref.watch(
      notificationSettingsProvider.select(
        (v) => v.schedules.where((s) => s.isActive).toList(),
      ),
    );

    final registered = _pending?.length ?? 0;
    final hasLoaded = _pending != null;
    // More active schedules than OS registrations = silent drops.
    final hasMismatch = hasLoaded && registered < activeSchedules.length;
    final statusColor = !hasLoaded
        ? colorScheme.onSurface.withValues(alpha: 0.7)
        : hasMismatch
            ? Colors.orangeAccent
            : (activeSchedules.isEmpty || registered > 0)
                ? Colors.greenAccent.shade400
                : colorScheme.onSurface.withValues(alpha: 0.7);
    final statusLabel = !hasLoaded
        ? (_loading ? '(refreshing…)' : '')
        : hasMismatch
            ? 'MISMATCH — ${activeSchedules.length - registered} active schedule(s) NOT registered with OS!'
            : activeSchedules.isEmpty
                ? 'No active schedules (expected)'
                : 'All $registered active schedule(s) registered ✓';

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      borderRadius: Radii.md,
      onTap: _loading ? null : _load,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FluentIcons.bug_20_regular, size: 18, color: statusColor),
              const SizedBox(width: 8),
              Expanded(
                child: StyledText(
                  'DEBUG: Active ${activeSchedules.length} · OS-pending $registered'
                  '${_loading ? ' (refreshing…)' : ''} — tap to refresh',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  color: statusColor,
                ),
              ),
            ],
          ),

          /// App-side: every schedule the user turned ON (label + time).
          if (activeSchedules.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: StyledText(
                'Active in app:',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            ...activeSchedules.map(
              (s) => Padding(
                padding: const EdgeInsets.only(top: 2, left: 34),
                child: StyledText(
                  '• "${s.label}" @ ${_formatScheduleTime(s)}',
                  fontSize: 11,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],

          /// OS-side: what AlarmManager actually holds.
          if (_pending != null && _pending!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: StyledText(
                'Registered with OS:',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            ..._pending!.map(
              (n) => Padding(
                padding: const EdgeInsets.only(top: 2, left: 34),
                child: StyledText(
                  '• ID ${n.id}: ${n.title ?? '(no title)'}',
                  fontSize: 11,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],

          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: StyledText(statusLabel, fontSize: 11, color: statusColor),
          ),
        ],
      ),
    );
  }
}
