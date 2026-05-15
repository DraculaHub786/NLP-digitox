
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/providers/system/mindful_settings_provider.dart';
import 'package:nlp_digitox/ui/common/default_fab_button.dart';
import 'package:nlp_digitox/ui/dialogs/confirmation_dialog.dart';

class EmergencyFAB extends ConsumerWidget {
  const EmergencyFAB({
    super.key,
  });

  void _useEmergency(BuildContext context, WidgetRef ref) async {
    int leftPasses = ref
        .read(mindfulSettingsProvider.notifier)
        .getUpdatedEmergencyPassCount();

    if (leftPasses <= 0) {
      context.showSnackAlert(context.locale.emergency_no_pass_left_snack_alert);
      return;
    }

    final confirmed = await showConfirmationDialog(
      context: context,
      icon: FluentIcons.fire_20_filled,
      heroTag: HeroTags.emergencyTileTag,
      title: context.locale.emergency_fab_button,
      info: context.locale.emergency_dialog_info(leftPasses),
      positiveLabel: context.locale.emergency_dialog_button_use_anyway,
    );

    if (!confirmed) return;
    final success = await MethodChannelService.instance.activeEmergencyPause();

    if (success && context.mounted) {
      context.showSnackAlert(
        context.locale.emergency_started_snack_alert,
        icon: FluentIcons.fire_16_filled,
      );

      ref.read(mindfulSettingsProvider.notifier).useEmergencyPausePass();
    } else if (context.mounted) {
      context.showSnackAlert(
        context.locale.emergency_already_active_snack_alert,
        icon: FluentIcons.fire_16_filled,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultFabButton(
      heroTag: HeroTags.emergencyTileTag,
      icon: FluentIcons.fire_20_filled,
      label: context.locale.emergency_fab_button,
      onPressed: () => _useEmergency(context, ref),
    );
  }
}
