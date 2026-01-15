// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/ui/common/default_fab_button.dart';

class FocusNowFab extends StatelessWidget {
  const FocusNowFab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultFabButton(
      heroTag: HeroTags.focusModeFABTag,
      icon: FluentIcons.target_arrow_20_filled,
      label: context.locale.focus_now_fab_button,
      onPressed: () => Navigator.of(context).pushNamed(
        AppRoutes.focusModePath,
        arguments: 0,
      ),
    );
  }
}
