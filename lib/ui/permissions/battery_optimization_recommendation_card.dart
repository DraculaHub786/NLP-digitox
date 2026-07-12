import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/common/sliver_primary_action_container.dart';

/// A sliver card that appears when battery optimization is NOT granted and
/// the user is interacting with features that need background persistence
/// (Shorts Blocking, Tamper Protection, etc.).
///
/// C.1: Surfaces battery optimization more prominently by recommending it
/// right in the feature flow, not buried in Settings.
///
/// C.2: Also includes an OEM-specific "Autostart" button for Xiaomi/Oppo/Vivo/etc.
class BatteryOptimizationRecommendationCard extends ConsumerWidget {
  const BatteryOptimizationRecommendationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBatteryOpt = ref.watch(
      permissionProvider.select((v) => v.haveIgnoreOptimizationPermission),
    );

    return SliverPrimaryActionContainer(
      isVisible: !hasBatteryOpt,
      margin: const EdgeInsets.symmetric(vertical: 4),
      icon: FluentIcons.battery_saver_20_regular,
      title: 'Keep it running smoothly',
      information:
          'Allow NLP digitox to ignore battery optimization so your restrictions keep working even after hours of idle time. This is strongly recommended for Shorts Blocking and Tamper Protection.',
      positiveBtn: FilledButton.icon(
        icon: const Icon(FluentIcons.battery_saver_20_filled, size: 16),
        label: const Text('Ignore Battery Optimization'),
        onPressed: () {
          ref
              .read(permissionProvider.notifier)
              .askIgnoreBatteryOptimizationPermission();
        },
      ),
      negativeBtn: TextButton.icon(
        icon: const Icon(FluentIcons.settings_20_regular, size: 16),
        label: const Text('Autostart (OEM)'),
        onPressed: () async {
          try {
            final opened =
                await MethodChannelService.instance.openAutoStartSettings();
            if (!opened && context.mounted) {
              context.showSnackAlert(
                'Open device Settings → Apps → NLP digitox → enable Autostart',
                icon: FluentIcons.info_20_filled,
              );
            }
          } catch (_) {
            if (context.mounted) {
              context.showSnackAlert(
                'Enable Autostart for NLP digitox in your device Settings',
                icon: FluentIcons.info_20_filled,
              );
            }
          }
        },
      ),
    );
  }
}
