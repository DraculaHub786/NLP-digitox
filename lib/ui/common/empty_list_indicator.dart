
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

class EmptyListIndicator extends StatelessWidget {
  const EmptyListIndicator({
    super.key,
    required this.info,
    this.isHappy = false,
  });

  final bool isHappy;
  final String info;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Happy/Sad
          Icon(
            isHappy
                ? FluentIcons.emoji_laugh_20_filled
                : FluentIcons.emoji_sad_20_filled,
            size: 96,
            color: Theme.of(context).colorScheme.primary.withAlpha(150),
          ),

          /// Info
          12.vBox,
          StyledText(
            info,
            fontSize: 16,
            isSubtitle: true,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
