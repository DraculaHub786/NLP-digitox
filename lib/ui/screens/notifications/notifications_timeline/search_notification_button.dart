
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/providers/apps/apps_info_provider.dart';
import 'package:nlp_digitox/providers/notifications/searched_notification_provider.dart';
import 'package:nlp_digitox/ui/common/application_icon.dart';
import 'package:nlp_digitox/ui/common/content_section_header.dart';
import 'package:nlp_digitox/ui/common/empty_list_indicator.dart';
import 'package:nlp_digitox/ui/common/search_bar.dart';
import 'package:nlp_digitox/ui/common/sliver_implicitly_animated_list.dart';
import 'package:nlp_digitox/ui/common/sliver_shimmer_list.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/dialogs/modal_bottom_sheet.dart';
import 'package:nlp_digitox/ui/screens/notifications/notification_tile.dart';
import 'package:sliver_tools/sliver_tools.dart';

class SearchNotificationButton extends StatelessWidget {
  const SearchNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      icon: const Icon(FluentIcons.search_20_filled),
      onPressed: () => showDefaultBottomSheet(
        context: context,
        initialSize: 0.75,
        sliverBody: const _SearchNotificationSheet(),
      ),
    );
  }
}

class _SearchNotificationSheet extends ConsumerStatefulWidget {
  const _SearchNotificationSheet();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SearchNotificationStateSheet();
}

class _SearchNotificationStateSheet
    extends ConsumerState<_SearchNotificationSheet> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(searchedNotificationsProvider(_query));
    final appInfo = ref.watch(appsInfoProvider);

    return MultiSliver(
      children: [
        /// Info
        StyledText(context.locale.search_notifications_sheet_info),

        12.vBox,

        /// Search bar
        PinnedHeaderSliver(
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            padding: const EdgeInsets.only(bottom: 6),
            child: DefaultSearchBar(
              hintText: context.locale.search_notifications_hint,
              onSubmitted: (v) => setState(() => _query = v),
            ),
          ),
        ),

        /// Header
        ContentSectionHeader(
          title: context.locale.notifications_tab_title,
          padding: const EdgeInsets.only(top: 12, bottom: 6),
        ),

        /// Notifications
        SliverAnimatedSwitcher(
          duration: 500.ms,
          child: notifications.when(
            data: (notificationList) {
              final appInfoMap = appInfo.valueOrNull ?? {};
              
              if (notificationList.isEmpty) {
                return EmptyListIndicator(
                  info: context.locale.search_notifications_empty_list_hint,
                ).sliver;
              }
              
              return SliverImplicitlyAnimatedList(
                items: notificationList,
                keyBuilder: (e) => "${e.packageName}: ${e.timeStamp}",
                itemBuilder: (context, i, notification, position) {
                  final appItem = appInfoMap[notification.packageName];
                  return NotificationTile(
                    position: position,
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    leading: appItem != null
                        ? ApplicationIcon(appInfo: appItem)
                        : const Icon(
                            FluentIcons.error_circle_20_filled,
                            size: 36,
                          ),
                    notification: notification,
                  );
                },
              );
            },
            loading: () => const SliverShimmerList(
              includeLeading: true,
              includeSubtitle: true,
              includeTrailing: true,
            ),
            error: (e, s) => EmptyListIndicator(
              info: 'Failed to load notifications',
            ).sliver,
          ),
        )
      ],
    );
  }
}
