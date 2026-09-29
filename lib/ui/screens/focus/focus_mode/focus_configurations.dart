import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/enums/session_type.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_duration.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/providers/focus/focus_mode_provider.dart';
import 'package:nlp_digitox/ui/common/default_dropdown_tile.dart';
import 'package:nlp_digitox/ui/common/device_dnd_tile.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/dialogs/timer_picker_dialog.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final sessionType =
        ref.watch(focusModeProvider.select((v) => v.focusMode.sessionType));

    final isSessionActive = ref
        .watch(focusModeProvider.select((v) => v.activeSession.value != null));

    final profile = ref.watch(focusModeProvider.select((v) => v.focusProfile));

    return MultiSliver(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ModernSectionHeader(
            title: context.locale.quick_actions_heading,
          ),
        ).sliver,

        /// Wrapper container for focus settings
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(Radii.xl),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                children: [
                  /// Session tag
                  DefaultDropdownTile<SessionType>(
                    enabled: !isSessionActive,
                    titleText: context.locale.focus_profile_tile_title,
                    dialogIcon: FluentIcons.door_tag_20_filled,
                    value: sessionType,
                    onSelected: ref.read(focusModeProvider.notifier).setSessionType,
                    items: sessionTypeLabels(context)
                        .entries
                        .map((e) => DefaultDropdownItem(label: e.value, value: e.key))
                        .toList(),
                  ),
                  12.vBox,

                  /// Session timer
                  DefaultHero(
                    tag: HeroTags.focusModeTimerTileTag,
                    child: ModernListTile(
                      title: context.locale.focus_session_duration_tile_title,
                      subtitle: profile.sessionDuration > 0
                          ? profile.sessionDuration.seconds.toTimeFull(context)
                          : context.locale.focus_session_duration_tile_subtitle,
                      icon: FluentIcons.timer_20_regular,
                      iconColor: colorScheme.primary,
                      showChevron: false,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(Radii.pill),
                        ),
                        child: StyledText(
                          profile.sessionDuration > 0
                              ? profile.sessionDuration.seconds.toTimeFull(context)
                              : 'Set',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      onTap: !isSessionActive
                          ? () => _pickSessionDuration(context, ref, profile.sessionDuration)
                          : null,
                    ),
                  ),
                  12.vBox,

                  /// Enforce focus mode
                  ModernSettingsTile(
                    title: context.locale.focus_enforce_tile_title,
                    subtitle: context.locale.focus_enforce_tile_subtitle,
                    icon: FluentIcons.shield_20_regular,
                    iconColor: colorScheme.primary,
                    value: profile.enforceSession,
                    onChanged: !isSessionActive
                        ? (_) => ref
                            .read(focusModeProvider.notifier)
                            .setEnforceFocus(!profile.enforceSession)
                        : null,
                  ),
                  12.vBox,

                  /// Should start dnd
                  ModernSettingsTile(
                    title: context.locale.permission_dnd_tile_title,
                    subtitle: context.locale.permission_dnd_tile_subtitle,
                    icon: FluentIcons.brightness_high_20_regular,
                    iconColor: colorScheme.tertiary,
                    value: profile.shouldStartDnd,
                    onChanged: !isSessionActive
                        ? (_) => ref
                            .read(focusModeProvider.notifier)
                            .setShouldStartDnd(!profile.shouldStartDnd)
                        : null,
                  ),
                  12.vBox,

                  /// Manage Dnd settings
                  const DeviceDndTile(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
