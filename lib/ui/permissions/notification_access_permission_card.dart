// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/utils/widget_utils.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/common/sliver_primary_action_container.dart';
import 'package:nlp_digitox/ui/permissions/permission_sheet.dart';

class NotificationAccessPermissionCard extends ConsumerWidget {
  const NotificationAccessPermissionCard({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final havePermission = ref.watch(
        permissionProvider.select((v) => v.haveNotificationAccessPermission));

    return SliverPrimaryActionContainer(
      isVisible: !havePermission,
      radius: getBorderRadiusFromPosition(ItemPosition.mid),
      margin: const EdgeInsets.only(top: 4),
      icon: FluentIcons.alert_urgent_20_filled,
      title: context.locale.permission_notification_access_title,
      information: context.locale.permission_notification_access_required,
      positiveBtn: FilledButton(
        child: Text(context.locale.permission_button_grant_permission),
        onPressed: () => _showSheet(context, ref),
      ),
    );
  }

  void _showSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => PermissionSheet(
        icon: FluentIcons.alert_urgent_20_filled,
        title: context.locale.permission_notification_access_title,
        description: context.locale.permission_notification_access_info,
        deviceSwitchTileLabel:
            context.locale.permission_notification_access_device_tile_label,
        onTapGrantPermission: () {
          Navigator.of(sheetContext).maybePop();
          ref
              .read(permissionProvider.notifier)
              .askNotificationAccessPermission();
        },
      ),
    );
  }
}
