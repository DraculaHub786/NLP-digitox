// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/database/adapters/time_of_day_adapter.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/ui/common/time_card.dart';

class TimePeriodStartEndCards extends StatelessWidget {
  const TimePeriodStartEndCards({
    super.key,
    this.bgColor,
    this.isModifiable,
    this.enabled = true,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  final Color? bgColor;
  final bool Function()? isModifiable;
  final bool enabled;
  final TimeOfDayAdapter startTime;
  final TimeOfDayAdapter endTime;
  final Function(TimeOfDayAdapter timeTod) onStartTimeChanged;
  final Function(TimeOfDayAdapter timeTod) onEndTimeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// Schedule start time
        Expanded(
          child: TimeCard(
            enabled: enabled,
            isModifiable: isModifiable,
            label: context.locale.schedule_start_label,
            heroTag: HeroTags.scheduleStartTimePickerTag,
            initialTime: startTime,
            bgColor: bgColor,
            onChange: onStartTimeChanged,
          ),
        ),

        12.hBox,

        /// Schedule end time
        Expanded(
          child: TimeCard(
            enabled: enabled,
            isModifiable: isModifiable,
            label: context.locale.schedule_end_label,
            heroTag: HeroTags.scheduleEndTimePickerTag,
            initialTime: endTime,
            bgColor: bgColor,
            onChange: onEndTimeChanged,
          ),
        ),
      ],
    );
  }
}
