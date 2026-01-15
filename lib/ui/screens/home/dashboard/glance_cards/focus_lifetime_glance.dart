// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_duration.dart';
import 'package:nlp_digitox/providers/focus/lifetime_focus_provider.dart';
import 'package:nlp_digitox/ui/common/usage_glance_card.dart';

class FocusLifetimeGlance extends ConsumerWidget {
  const FocusLifetimeGlance({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifeTimeFocus =
        ref.watch(lifetimeFocusProvider.select((v) => v.value)) ??
            Duration.zero;

    return UsageGlanceCard(
      title: context.locale.focus_lifetime_label,
      info: lifeTimeFocus.toTimeShort(context),
    );
  }
}
