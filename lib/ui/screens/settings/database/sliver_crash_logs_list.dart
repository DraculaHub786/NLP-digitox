
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/core/utils/widget_utils.dart';
import 'package:nlp_digitox/ui/common/default_expandable_list_tile.dart';
import 'package:nlp_digitox/ui/common/empty_list_indicator.dart';
import 'package:nlp_digitox/ui/common/rounded_container.dart';
import 'package:nlp_digitox/ui/common/sliver_shimmer_list.dart';
import 'package:nlp_digitox/ui/common/status_label.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

final _crashLogsProvider = FutureProvider.autoDispose<List<CrashLog>>(
  (ref) async =>
      await DriftDbService.instance.driftDb.dynamicRecordsDao.fetchCrashLogs(),
);

class SliverCrashLogsList extends ConsumerWidget {
  const SliverCrashLogsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(_crashLogsProvider);

    return logs.when(
      loading: () => const SliverShimmerList(includeSubtitle: true),
      error: (e, st) => const SliverShimmerList(includeSubtitle: true),
      data: (logs) => logs.isEmpty
          ? EmptyListIndicator(
              isHappy: true,
              info: context.locale.crash_logs_empty_list_hint,
            ).sliver
          : SliverList.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];

                return DefaultExpandableListTile(
                  position: getItemPositionInList(
                    index,
                    logs.length,
                  ),
                  titleText: log.timeStamp.dateTimeString(context),
                  subtitleText: log.error.trim(),
                  content: RoundedContainer(
                    borderRadius: getBorderRadiusFromPosition(ItemPosition.mid),
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Version and copy
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// Version label
                            StatusLabel(
                              label: log.appVersion,
                            ),

                            /// Copy button
                            IconButton(
                              onPressed: () => _copyLogToClipboard(log),
                              icon: Icon(FluentIcons.copy_20_regular),
                            ),
                          ],
                        ),

                        12.vBox,

                        /// Stacktrace
                        StyledText(
                          log.stackTrace.trim(),
                        ),
                      ],
                    ),
                  ),
                );
              }),
    );
  }

  void _copyLogToClipboard(CrashLog log) async {
    final deviceInfo = MethodChannelService.instance.deviceInfo;

    final logInfo = {
      "Manufacturer": deviceInfo.manufacturer,
      "Model": deviceInfo.model,
      "Android Version": deviceInfo.androidVersion,
      "SDK Version": deviceInfo.sdkVersion,
      "App Version": log.appVersion,
      "Error": log.error,
      "StackTrace": log.stackTrace
    }.entries.map((e) => "${e.key} : ${e.value}").join("\n");

    await Clipboard.setData(ClipboardData(text: logInfo));
  }
}
