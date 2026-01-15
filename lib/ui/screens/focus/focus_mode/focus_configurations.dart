// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/enums/session_type.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_duration.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/providers/focus/focus_mode_provider.dart';
import 'package:nlp_digitox/ui/common/default_dropdown_tile.dart';
import 'package:nlp_digitox/ui/common/default_expandable_list_tile.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/device_dnd_tile.dart';
import 'package:nlp_digitox/ui/common/content_section_header.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/dialogs/timer_picker_dialog.dart';
import 'package:nlp_digitox/ui/permissions/dnd_switch_tile.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';
import 'package:sliver_tools/sliver_tools.dart';

class FocusConfigurations extends ConsumerWidget {
  const FocusConfigurations({super.key});

  void _pickSessionDuration(
    BuildContext context,
    WidgetRef ref,
    int prevTimer,
  ) async {
    final newTimer = await showFocusTimerPicker(
      heroTag: HeroTags.focusModeTimerTileTag,
      context: context,
      initialTime: prevTimer,
    );

    if (newTimer == null || newTimer == prevTimer) return;
    ref.read(focusModeProvider.notifier).setSessionDuration(newTimer);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionType =
        ref.watch(focusModeProvider.select((v) => v.focusMode.sessionType));

    final isSessionActive = ref
        .watch(focusModeProvider.select((v) => v.activeSession.value != null));

    final profile = ref.watch(focusModeProvider.select((v) => v.focusProfile));

    return MultiSliver(
      children: [
        ContentSectionHeader(
          title: context.locale.quick_actions_heading,
        ).sliver,

        /// Session tag
        DefaultDropdownTile<SessionType>(
          position: ItemPosition.top,
          enabled: !isSessionActive,
          titleText: context.locale.focus_profile_tile_title,
          dialogIcon: FluentIcons.door_tag_20_filled,
          value: sessionType,
          onSelected: ref.read(focusModeProvider.notifier).setSessionType,
          items: sessionTypeLabels(context)
              .entries
              .map((e) => DefaultDropdownItem(label: e.value, value: e.key))
              .toList(),
        ).sliver,

        /// Session timer
        DefaultHero(
          tag: HeroTags.focusModeTimerTileTag,
          child: DefaultListTile(
            position: ItemPosition.mid,
            enabled: !isSessionActive,
            titleText: context.locale.focus_session_duration_tile_title,
            subtitle: StyledText(
              profile.sessionDuration > 0
                  ? profile.sessionDuration.seconds.toTimeFull(context)
                  : context.locale.focus_session_duration_tile_subtitle,
              fontSize: 14,
              isSubtitle: true,
            ),
            onPressed: () => _pickSessionDuration(
              context,
              ref,
              profile.sessionDuration,
            ),
          ),
        ),

        DefaultExpandableListTile(
          position: ItemPosition.mid,
          titleText: context.locale.focus_profile_customization_tile_title,
          subtitleText:
              context.locale.focus_profile_customization_tile_subtitle,
          content: Column(
            children: [
              /// Enforce focus mode
              DefaultListTile(
                position: ItemPosition.mid,
                enabled: !isSessionActive,
                switchValue: profile.enforceSession,
                titleText: context.locale.focus_enforce_tile_title,
                subtitleText: context.locale.focus_enforce_tile_subtitle,
                onPressed: () => ref
                    .read(focusModeProvider.notifier)
                    .setEnforceFocus(!profile.enforceSession),
              ),

              /// Should start dnd
              DndSwitchTile(
                enabled: !isSessionActive,
                switchValue: profile.shouldStartDnd,
                position: ItemPosition.mid,
                onPressed: () => ref
                    .read(focusModeProvider.notifier)
                    .setShouldStartDnd(!profile.shouldStartDnd),
              ),

              /// Manage Dnd settings
              const DeviceDndTile(
                position: ItemPosition.mid,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
