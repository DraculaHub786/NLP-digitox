
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/providers/apps/apps_info_provider.dart';
import 'package:nlp_digitox/providers/notifications/dated_conversation_provider.dart';
import 'package:nlp_digitox/providers/notifications/dated_notifications_provider.dart';
import 'package:nlp_digitox/ui/common/application_icon.dart';
import 'package:nlp_digitox/ui/common/content_section_header.dart';
import 'package:nlp_digitox/ui/common/default_segmented_button.dart';
import 'package:nlp_digitox/ui/common/empty_list_indicator.dart';
import 'package:nlp_digitox/ui/common/sliver_implicitly_animated_list.dart';
import 'package:nlp_digitox/ui/common/sliver_shimmer_list.dart';
import 'package:nlp_digitox/ui/screens/notifications/conversation_tile.dart';
import 'package:nlp_digitox/ui/screens/notifications/notification_tile.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:nlp_digitox/core/database/app_database.dart' as db;

class SliverNotificationsList extends ConsumerStatefulWidget {
  const SliverNotificationsList({
    super.key,
    required this.timeRange,
    required this.header,
  });

  final DateTimeRange timeRange;
  final String header;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SliverNotificationsListState();
}

class _SliverNotificationsListState
    extends ConsumerState<SliverNotificationsList> {
  bool _shouldGroup = false;

  void _onDismissed(db.Notification notification) => ref
      .read(datedNotificationsProvider(widget.timeRange).notifier)
      .deleteNotification(notification);

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: [
        /// Header
        ContentSectionHeader(title: widget.header).sliver,

        /// Group un-group conversation
        DefaultSegmentedButton<bool>(
          selected: _shouldGroup,
          onChanged: (value) => setState(() => _shouldGroup = value),
          segments: [
            SegmentItem(
              value: false,
              label: context.locale.notifications_tab_title,
              icon: FluentIcons.chat_multiple_20_filled,
            ),
            SegmentItem(
              value: true,
              label: context.locale.conversations_label,
              icon: FluentIcons.chat_20_filled,
            ),
          ],
        ).leftCentered.sliver,

        12.vSliverBox,

        /// List
        SliverAnimatedSwitcher(
          duration: 200.ms,
          child: _shouldGroup
              ? _SliverConversationList(
                  timeRange: widget.timeRange,
                )
              : _SliverNotificationsList(
                  timeRange: widget.timeRange,
                  onDismissed: _onDismissed,
                ),
        )
      ],
    );
  }
}

class _SliverNotificationsList extends ConsumerWidget {
  const _SliverNotificationsList({
    required this.timeRange,
    this.onDismissed,
  });

  final DateTimeRange timeRange;
  final void Function(db.Notification notification)? onDismissed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(datedNotificationsProvider(timeRange));
    final appInfo = ref.watch(appsInfoProvider);

    return notifications.when(
      data: (notificationList) {
        final appInfoMap = appInfo.valueOrNull ?? {};
        
        if (notificationList.isEmpty) {
          return EmptyListIndicator(
            info: context.locale.notifications_empty_list_hint,
          ).sliver;
        }
        
        return SliverImplicitlyAnimatedList(
          items: notificationList,
          keyBuilder: (e) => e.id.toString(),
          itemBuilder: (context, i, notification, position) {
            final appItem = appInfoMap[notification.packageName];
            return NotificationTile(
              position: position,
              leading: appItem != null
                  ? ApplicationIcon(appInfo: appItem)
                  : const Icon(
                      FluentIcons.error_circle_20_filled,
                      size: 36,
                    ),
              notification: notification,
              onDismissed: onDismissed,
            );
          },
        );
      },
      loading: () => const SliverShimmerList(
        includeLeading: true,
        includeSubtitle: true,
        includeTrailing: true,
      ),
      error: (error, stack) => EmptyListIndicator(
        info: 'Failed to load notifications',
      ).sliver,
    );
  }
}

class _SliverConversationList extends ConsumerWidget {
  const _SliverConversationList({
    required this.timeRange,
  });

  final DateTimeRange timeRange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsByApp = ref.watch(datedConversationProvider(timeRange));
    final appInfo = ref.watch(appsInfoProvider);

    return notificationsByApp.when(
      data: (notificationMap) {
        final appInfoMap = appInfo.valueOrNull ?? {};
        
        if (notificationMap.isEmpty) {
          return EmptyListIndicator(
            info: context.locale.notifications_empty_list_hint,
          ).sliver;
        }
        
        return SliverImplicitlyAnimatedList(
          items: notificationMap.entries.toList(),
          keyBuilder: (entry) => entry.key,
          itemBuilder: (context, i, entry, position) {
            final appItem = appInfoMap[entry.key];
            return ConversationTile(
              appName: appItem?.name ?? entry.key,
              leading: appItem != null
                  ? ApplicationIcon(appInfo: appItem)
                  : const Icon(
                      FluentIcons.error_circle_20_filled,
                      size: 36,
                    ),
              packageName: entry.key,
              conversations: entry.value,
              position: position,
            );
          },
        );
      },
      loading: () => const SliverShimmerList(
        includeLeading: true,
        includeSubtitle: true,
        includeTrailing: true,
      ),
      error: (error, stack) => EmptyListIndicator(
        info: 'Failed to load conversations',
      ).sliver,
    );
  }
}
