import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/screens/focus/focus_mode/tab_focus.dart';
import 'package:nlp_digitox/ui/screens/focus/focus_timeline/tab_focus_timeline.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key, this.initialTabIndex});

  final int? initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return ScaffoldShell(
      initialTab: initialTabIndex,
      items: [
        NavbarItem(
          icon: FluentIcons.brain_circuit_20_regular,
          filledIcon: FluentIcons.brain_circuit_20_filled,
          titleText: context.locale.focus_tab_title,
          sliverBody: const TabFocus(),
        ),
        NavbarItem(
          icon: FluentIcons.history_20_regular,
          filledIcon: FluentIcons.history_20_filled,
          titleText: context.locale.timeline_tab_title,
          sliverBody: const TabFocusTimeline(),
        ),
      ],
    );
  }
}
