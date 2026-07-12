import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

class DeviceDndTile extends StatelessWidget {
  const DeviceDndTile({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ModernListTile(
      title: context.locale.dnd_settings_tile_title,
      subtitle: context.locale.dnd_settings_tile_subtitle,
      icon: FluentIcons.alert_off_20_regular,
      iconColor: colorScheme.primary,
      onTap: () => MethodChannelService.instance.openDeviceDndSettings(),
    );
  }
}
