
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/rounded_container.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

class PermissionGrantingSteps extends StatelessWidget {
  const PermissionGrantingSteps({
    super.key,
    required this.deviceSwitchTileLabel,
    required this.labelOfBtnToClick,
    this.isAccessibilityPerm = false,
  });

  final String deviceSwitchTileLabel;
  final String labelOfBtnToClick;
  final bool isAccessibilityPerm;

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      circularRadius: 24,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// First step
          StyledText(
            context.locale.permission_grant_step_one(labelOfBtnToClick),
            fontSize: 14,
          ),
          6.vBox,

          /// Second step
          StyledText(
            context.locale.permission_grant_step_two,
            fontSize: 14,
          ),
          6.vBox,
          DefaultListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.sm),
              child: Image.asset('assets/logo.png', width: 40, height: 40),
            ),
            titleText: "NLP digitox",
            subtitleText: isAccessibilityPerm
                ? context.locale.permission_status_off
                : context.locale.permission_status_not_allowed,
          ),

          12.vBox,

          /// Third step
          StyledText(
            context.locale.permission_grant_step_three,
            fontSize: 14,
          ),
          6.vBox,
          DefaultListTile(
            // margin: const EdgeInsets.only(left: 16, top: 4),
            color: Theme.of(context).colorScheme.surfaceContainer,
            switchValue: true,
            titleText: deviceSwitchTileLabel,
          ),

          6.vBox,
        ],
      ),
    );
  }
}
