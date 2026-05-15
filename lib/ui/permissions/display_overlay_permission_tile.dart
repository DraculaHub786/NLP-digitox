
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/permissions/permission_sheet.dart';

class DisplayOverlayPermissionTile extends ConsumerWidget {
  const DisplayOverlayPermissionTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final havePermission = ref.watch(
        permissionProvider.select((v) => v.haveDisplayOverlayPermission));

    return DefaultListTile(
      position: ItemPosition.bottom,
      titleText: context.locale.permission_overlay_title,
      accent: havePermission ? null : Theme.of(context).colorScheme.error,
      subtitleText: havePermission
          ? context.locale.permission_status_allowed
          : context.locale.permission_status_not_allowed,
      isSelected: havePermission,
      onPressed: havePermission ? null : () => _showSheet(context, ref),
    );
  }

  void _showSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => PermissionSheet(
        icon: FluentIcons.app_recent_20_filled,
        title: context.locale.permission_overlay_title,
        description: context.locale.permission_overlay_info,
        deviceSwitchTileLabel:
            context.locale.permission_overlay_device_tile_label,
        onTapGrantPermission: () {
          Navigator.of(sheetContext).maybePop();
          ref.read(permissionProvider.notifier).askDisplayOverlayPermission();
        },
      ),
    );
  }
}
