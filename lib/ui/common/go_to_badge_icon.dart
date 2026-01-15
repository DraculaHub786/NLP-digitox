// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class GoToBadgeIcon extends StatelessWidget {
  const GoToBadgeIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      FluentIcons.arrow_up_right_20_filled,
      color: Theme.of(context).hintColor,
      size: 12,
    );
  }
}
