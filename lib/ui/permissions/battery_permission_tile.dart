import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

class SliverBatteryPermissionSwitchTile extends ConsumerWidget {
  /// Creates a [ModernSettingsTile] for asking permission from user
  const SliverBatteryPermissionSwitchTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final havePermission = ref.watch(
        permissionProvider.select((v) => v.haveIgnoreOptimizationPermission));

    return ModernSettingsTile(
      title: context.locale.permission_battery_optimization_tile_title,
      subtitle: havePermission
          ? context.locale.permission_battery_optimization_status_enabled
          : context.locale.permission_battery_optimization_status_disabled,
      icon: FluentIcons.battery_saver_20_regular,
      iconColor: Theme.of(context).colorScheme.primary,
      value: havePermission,
      onChanged: havePermission
          ? null
          : (_) => ref
              .read(permissionProvider.notifier)
              .askIgnoreBatteryOptimizationPermission(),
    );
  }
}

class BatteryPermissionTile extends ConsumerWidget {
  const BatteryPermissionTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final havePermission = ref.watch(
        permissionProvider.select((v) => v.haveIgnoreOptimizationPermission));

    return ModernListTile(
      title: context.locale.permission_battery_optimization_tile_title,
      subtitle: havePermission
          ? context.locale.permission_status_allowed
          : context.locale.permission_status_not_allowed,
      icon: FluentIcons.battery_saver_20_regular,
      iconColor: havePermission ? colorScheme.primary : colorScheme.error,
      showChevron: true,
      onTap: havePermission
          ? null
          : () {
              final sdkVersion =
                  MethodChannelService.instance.deviceInfo.sdkVersion;
              if (sdkVersion >= 31) {
                context.showSnackAlert(
                  context.locale.permission_battery_optimization_allow_info,
                  icon: FluentIcons.info_20_filled,
                );
              }
              ref
                  .read(permissionProvider.notifier)
                  .askIgnoreBatteryOptimizationPermission();
            },
    );
  }
}
