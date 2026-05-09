// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nlp_digitox/core/database/adapters/time_of_day_adapter.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/ui/common/rounded_container.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/dialogs/time_picker_dialog.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';

class TimeCard extends StatelessWidget {
  const TimeCard({
    super.key,
    required this.label,
    required this.heroTag,
    required this.onChange,
    required this.initialTime,
    this.bgColor,
    this.icon,
    this.iconColor,
    this.isModifiable,
    this.iconSize = 32,
    this.enabled = true,
  });

  final String label;
  final Object heroTag;
  final bool enabled;
  final TimeOfDayAdapter initialTime;
  final Function(TimeOfDayAdapter time) onChange;
  final bool Function()? isModifiable;
  final Color? bgColor;
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final timeString = initialTime.format(context);
    final timeParts = timeString.split(' ');

    return DefaultHero(
      tag: heroTag,
      child: RoundedContainer(
        color: bgColor,
        padding: const EdgeInsets.all(16),
        onPressed: enabled
            ? () async {
                if (!(isModifiable?.call() ?? true)) return;

                final pickedTime = await showCustomTimePickerDialog(
                  context: context,
                  initialTime: initialTime,
                  heroTag: heroTag,
                  info: label,
                );

                await Future.delayed(50.ms);
                onChange(pickedTime ?? initialTime);
              }
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Icon
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: enabled ? iconColor : Theme.of(context).disabledColor,
                ),
              ),

            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Label
                StyledText(
                  label,
                  isSubtitle: !enabled,
                ),
                4.vBox,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      /// Time in hour and minutes
                      StyledText(
                        timeParts.firstOrNull ?? timeString,
                        height: 1,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        isSubtitle: !enabled,
                      ),
                      4.hBox,

                      /// Time period AM/PM
                      StyledText(
                        timeParts.elementAtOrNull(1) ?? "",
                        height: 2,
                        isSubtitle: !enabled,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
