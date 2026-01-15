// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';

class DeviceDndTile extends StatelessWidget {
  const DeviceDndTile({super.key, this.position});

  final ItemPosition? position;

  @override
  Widget build(BuildContext context) {
    return DefaultListTile(
      position: position,
      leading: const Icon(FluentIcons.alert_off_20_regular),
      titleText: context.locale.dnd_settings_tile_title,
      subtitleText: context.locale.dnd_settings_tile_subtitle,
      trailing: const Icon(FluentIcons.chevron_right_20_filled),
      onPressed: () => MethodChannelService.instance.openDeviceDndSettings(),
    );
  }
}
