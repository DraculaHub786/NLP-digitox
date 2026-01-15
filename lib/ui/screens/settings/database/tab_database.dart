// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/screens/settings/database/export_clear_crash_logs.dart';
import 'package:nlp_digitox/ui/screens/settings/database/import_export_db.dart';

class TabDatabase extends ConsumerWidget {
  const TabDatabase({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        /// Backup, restore and reset
        ImportExportDb(),

        /// Crash logs
        ExportClearCrashLogs(),

        SliverTabsBottomPadding()
      ],
    );
  }
}
