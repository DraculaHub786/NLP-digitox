// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/providers/focus/focus_mode_provider.dart';
import 'package:nlp_digitox/ui/common/sliver_distracting_apps_list.dart';

class FocusDistractingAppsList extends ConsumerWidget {
  const FocusDistractingAppsList({
    super.key,
  });

  void _onDistractingAppsChanged(
    BuildContext context,
    WidgetRef ref,
    String package,
    bool isSelected,
  ) async {
    // User want to remove app from list and session is active
    if (!isSelected &&
        ref.read(focusModeProvider).activeSession.value != null) {
      context.showSnackAlert(
        context.locale.focus_distracting_apps_removal_snack_alert,
      );
      return;
    }

    // User want to add app to list
    ref
        .read(focusModeProvider.notifier)
        .insertRemoveDistractingApp(package, isSelected);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distractingApps = ref
        .watch(focusModeProvider.select((v) => v.focusProfile.distractingApps));

    return SliverDistractingAppsList(
      distractingApps: distractingApps,
      isInsideModalSheet: false,
      onSelectionChanged: (package, isSelected) => _onDistractingAppsChanged(
        context,
        ref,
        package,
        isSelected,
      ),
    );
  }
}
