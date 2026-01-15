// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/providers/restrictions/bedtime_provider.dart';
import 'package:nlp_digitox/ui/common/sliver_distracting_apps_list.dart';

class BedtimeDistractingAppsList extends ConsumerWidget {
  const BedtimeDistractingAppsList({
    super.key,
  });

  void _insertRemoveDistractingApp(
    WidgetRef ref,
    BuildContext context,
    String packageName,
    bool shouldInsert,
  ) async {
    /// If bedtime schedule is active or ON
    if (ref.read(bedtimeScheduleProvider).isScheduleOn) {
      context.showSnackAlert(
          context.locale.bedtime_distracting_apps_modify_snack_alert);
      return;
    }

    ref
        .read(bedtimeScheduleProvider.notifier)
        .insertRemoveDistractingApp(packageName, shouldInsert);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distractingApps =
        ref.watch(bedtimeScheduleProvider.select((v) => v.distractingApps));

    return SliverDistractingAppsList(
      distractingApps: distractingApps,
      onSelectionChanged: (package, isSelected) => _insertRemoveDistractingApp(
        ref,
        context,
        package,
        isSelected,
      ),
    );
  }
}
