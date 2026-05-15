
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/core/extensions/ext_duration.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/providers/focus/monthly_focus_provider.dart';
import 'package:nlp_digitox/ui/common/go_to_badge_icon.dart';
import 'package:nlp_digitox/ui/common/usage_glance_card.dart';

class FocusMonthlyGlance extends ConsumerWidget {
  const FocusMonthlyGlance({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyFocus = ref.watch(
      monthlyFocusProvider(dateToday.monthRange).select(
        (v) => v.monthlyFocus.values.fold(0, (prev, e) => prev + e),
      ),
    );

    return UsageGlanceCard(
      title: context.locale.focus_monthly_label,
      info: monthlyFocus.seconds.toTimeShort(context),
      badge: const GoToBadgeIcon(),
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.focusModePath,
        arguments: {"tab": 1},
      ),
    );
  }
}
