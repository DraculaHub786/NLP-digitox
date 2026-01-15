// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/providers/focus/focus_mode_provider.dart';
import 'package:nlp_digitox/ui/common/sliver_primary_action_container.dart';

class SliverActiveSessionAlert extends ConsumerWidget {
  const SliverActiveSessionAlert({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession =
        ref.watch(focusModeProvider.select((v) => v.activeSession));

    return SliverPrimaryActionContainer(
      isVisible: activeSession.value != null,
      icon: FluentIcons.timer_20_regular,
      margin: const EdgeInsets.symmetric(vertical: 4),
      title: context.locale.active_session_card_title,
      information: context.locale.active_session_card_info,
      positiveBtn: FilledButton(
        child: Text(context.locale.active_session_card_view_button),
        onPressed: () {
          if (activeSession.value == null) return;

          Navigator.of(context).pushNamed(AppRoutes.activeSessionPath);
        },
      ),
    );
  }
}
