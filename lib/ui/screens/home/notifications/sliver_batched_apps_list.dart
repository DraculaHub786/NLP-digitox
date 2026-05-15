
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/providers/notifications/notification_settings_provider.dart';
import 'package:nlp_digitox/ui/common/sliver_distracting_apps_list.dart';

class SliverBatchedAppsList extends ConsumerWidget {
  const SliverBatchedAppsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchedApps =
        ref.watch(notificationSettingsProvider.select((v) => v.batchedApps));

    return SliverDistractingAppsList(
      distractingApps: batchedApps,
      onSelectionChanged: (package, isSelected) => ref
          .read(notificationSettingsProvider.notifier)
          .batchUnBatchApp(package, isSelected),
    );
  }
}
