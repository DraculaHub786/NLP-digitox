// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/providers/notifications/notification_settings_provider.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/common/default_fab_button.dart';
import 'package:nlp_digitox/ui/dialogs/input_field_dialog.dart';

class NewNotificationScheduleFab extends ConsumerWidget {
  const NewNotificationScheduleFab({super.key});

  void _onPressed(BuildContext context, WidgetRef ref) async {
    final scheduleName = await showNotificationScheduleNameDialog(
      context: context,
      heroTag: HeroTags.newNotificationScheduleFABTag,
    );

    if (scheduleName == null || scheduleName.isEmpty) return;

    /// Create new schedule
    ref
        .read(notificationSettingsProvider.notifier)
        .createNewSchedule(scheduleName);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final havePermission = ref.watch(
        permissionProvider.select((v) => v.haveNotificationAccessPermission));

    return havePermission
        ? DefaultFabButton(
            heroTag: HeroTags.newNotificationScheduleFABTag,
            label: context.locale.new_schedule_fab_button,
            icon: FluentIcons.add_20_filled,
            onPressed: () => _onPressed(context, ref),
          )
        : const SizedBox.shrink();
  }
}
