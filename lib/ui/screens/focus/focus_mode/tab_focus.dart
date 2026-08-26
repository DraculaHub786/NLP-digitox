import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/providers/focus/focus_mode_provider.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/rounded_container.dart';
import 'package:nlp_digitox/ui/common/sliver_active_session_alert.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/screens/focus/focus_mode/focus_distracting_apps_list.dart';
import 'package:nlp_digitox/ui/screens/focus/focus_mode/focus_configurations.dart';
import 'package:slide_action/slide_action.dart';

class TabFocus extends StatelessWidget {
  const TabFocus({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        /// Information card with modern styling
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(Radii.xl),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      FluentIcons.info_20_filled,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: StyledText(
                      context.locale.focus_tab_info,
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.75),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        8.vSliverBox,

        const SliverActiveSessionAlert(),

        const FocusConfigurations(),

        /// Swipe to start focus session
        2.vSliverBox,
        Consumer(
          builder: (_, WidgetRef ref, __) {
            final thumbWidth = MediaQuery.of(context).size.width * 0.25;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SlideAction(
                trackHeight: 64,
                actionSnapThreshold: 0.6,
                stretchThumb: true,
                thumbWidth: thumbWidth,
                thumbDragStartBehavior: DragStartBehavior.down,
                trackBuilder: (context, currentState) => DefaultListTile(
                  margin: EdgeInsets.zero,
                  color: Theme.of(context).colorScheme.primary,
                  position: ItemPosition.bottom,
                  title: Padding(
                    padding: EdgeInsetsGeometry.only(left: thumbWidth),
                    child: StyledText(
                      context.locale.focus_session_start_button,
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                thumbBuilder: (context, currentState) => RoundedContainer(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  margin: EdgeInsets.all(0),
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(24)),
                  child: Icon(
                    FluentIcons.chevron_right_20_filled,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                action: () => _startFocusSession(context, ref),
              ),
            );
          },
        ).sliver,

        40.vSliverBox,
        const FocusDistractingAppsList(),

        const SliverTabsBottomPadding(),
      ],
    );
  }

  void _startFocusSession(BuildContext context, WidgetRef ref) async {
    final focusMode = ref.read(focusModeProvider);

    /// If another focus session is already active
    if (focusMode.activeSession.value != null) {
      context.showSnackAlert(
        context.locale.focus_session_already_active_snack_alert,
      );
      return;
    }

    // If no distracting apps selected
    if (focusMode.focusProfile.distractingApps.isEmpty) {
      context.showSnackAlert(
        context.locale.focus_session_minimum_apps_snack_alert,
      );
      return;
    }

    await ref.read(focusModeProvider.notifier).startNewSession();

    await Future.delayed(300.ms);
    if (context.mounted) {
      Navigator.of(context).pushNamed(AppRoutes.activeSessionPath);
    }
  }
}
