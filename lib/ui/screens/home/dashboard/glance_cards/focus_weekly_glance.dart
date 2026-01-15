// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/core/extensions/ext_duration.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/providers/focus/monthly_focus_provider.dart';
import 'package:nlp_digitox/ui/common/usage_glance_card.dart';

class FocusWeeklyGlance extends ConsumerWidget {
  const FocusWeeklyGlance({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyFocus = ref.watch(
      monthlyFocusProvider(dateToday.weekRange).select(
        (v) => v.monthlyFocus.values.fold(0, (prev, e) => prev + e),
      ),
    );

    return UsageGlanceCard(
      title: context.locale.focus_weekly_label,
      info: weeklyFocus.seconds.toTimeShort(context),
    );
  }
}
