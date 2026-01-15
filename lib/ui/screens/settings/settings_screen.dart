// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/screens/settings/about/tab_about.dart';
import 'package:nlp_digitox/ui/screens/settings/account/tab_account.dart';
import 'package:nlp_digitox/ui/screens/settings/database/tab_database.dart';
import 'package:nlp_digitox/ui/screens/settings/general/tab_general.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    this.initialTabIndex,
  });

  final int? initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return ScaffoldShell(
      initialTab: initialTabIndex,
      items: [
        NavbarItem(
          titleText: context.locale.general_tab_title,
          icon: FluentIcons.color_20_regular,
          filledIcon: FluentIcons.color_20_filled,
          sliverBody: const TabGeneral(),
        ),
        NavbarItem(
          titleText: 'Account',
          icon: FluentIcons.person_20_regular,
          filledIcon: FluentIcons.person_20_filled,
          sliverBody: const TabAccount(),
        ),
        NavbarItem(
          titleText: context.locale.database_tab_title,
          icon: FluentIcons.database_20_regular,
          filledIcon: FluentIcons.database_20_filled,
          sliverBody: const TabDatabase(),
        ),
        NavbarItem(
          titleText: context.locale.about_tab_title,
          icon: FluentIcons.info_20_regular,
          filledIcon: FluentIcons.info_20_filled,
          sliverBody: const TabAbout(),
        ),
      ],
    );
  }
}
