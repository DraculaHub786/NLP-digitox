
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/core/extensions/ext_int.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/providers/usage/weekly_device_usage_provider.dart';
import 'package:nlp_digitox/ui/common/usage_glance_card.dart';

class DataMobileGlance extends ConsumerWidget {
  const DataMobileGlance({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(
      weeklyDeviceUsageProvider(dateToday.weekRange).select(
        (v) => v[dateToday]?.mobileData ?? 0,
      ),
    );

    return UsageGlanceCard(
      title: context.locale.mobile_data_label,
      info: today.toData(),
    );
  }
}
