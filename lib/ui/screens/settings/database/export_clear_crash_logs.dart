
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/services/crash_log_service.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/dialogs/confirmation_dialog.dart';
import 'package:nlp_digitox/ui/dialogs/modal_bottom_sheet.dart';
import 'package:nlp_digitox/ui/screens/settings/database/sliver_crash_logs_list.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ExportClearCrashLogs extends ConsumerStatefulWidget {
  const ExportClearCrashLogs({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExportClearCrashLogsState();
}

class _ExportClearCrashLogsState extends ConsumerState<ExportClearCrashLogs> {
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    CrashLogService.instance.loadLogsFromNativeToDriftDb();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MultiSliver(
      children: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ModernSectionHeader(title: 'Crash Logs'),
                8.vBox,
                StyledText(
                  context.locale.crash_logs_info,
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                ),
                16.vBox,
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      /// Export
                      ModernListTile(
                        title: context.locale.crash_logs_export_tile_title,
                        subtitle: context.locale.crash_logs_export_tile_subtitle,
                        icon: FluentIcons.arrow_upload_20_regular,
                        iconColor: colorScheme.primary,
                        showChevron: true,
                        trailing: _isExporting
                            ? const SizedBox.square(
                                dimension: 24,
                                child: CircularProgressIndicator(strokeCap: StrokeCap.round),
                              )
                            : null,
                        onTap: _exportLogs,
                      ),
                      8.vBox,

                      /// View
                      ModernListTile(
                        title: context.locale.crash_logs_view_tile_title,
                        subtitle: context.locale.crash_logs_view_tile_subtitle,
                        icon: FluentIcons.notepad_20_regular,
                        iconColor: colorScheme.secondary,
                        showChevron: true,
                        onTap: () => showDefaultBottomSheet(
                          context: context,
                          headerTitle: context.locale.crash_logs_heading,
                          sliverBody: const SliverCrashLogsList(),
                        ),
                      ),
                      8.vBox,

                      /// Clear
                      ModernListTile(
                        title: context.locale.crash_logs_clear_tile_title,
                        subtitle: context.locale.crash_logs_clear_tile_subtitle,
                        icon: FluentIcons.delete_lines_20_regular,
                        iconColor: colorScheme.error,
                        showChevron: false,
                        onTap: _clearLogs,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- ALL LOGIC METHODS REMAIN EXACTLY THE SAME ---

  void _exportLogs() async {
    try {
      setState(() => _isExporting = true);

      final logs = await DriftDbService.instance.driftDb.dynamicRecordsDao
          .fetchCrashLogs();
      final deviceInfo = MethodChannelService.instance.deviceInfo;

      final crashLogMap = {
        "Manufacturer": deviceInfo.manufacturer,
        "Model": deviceInfo.model,
        "Android Version": deviceInfo.androidVersion,
        "SDK Version": deviceInfo.sdkVersion,
        'Crash Logs': logs.map((e) => e.toJson()).toList()
      };

      final jsonString = jsonEncode(crashLogMap);

      /// Create file and write logs
      final timeStamp = DateFormat('yyyy-MM-dThh-mm-ss').format(DateTime.now());

      final resultPath = await FilePicker.platform.saveFile(
        fileName: "NLP_digitox_Logs_$timeStamp.json",
        bytes: Uint8List.fromList(utf8.encode(jsonString)),
      );

      /// user aborted
      if (resultPath == null) {
        throw Exception('User aborted the exporting operation');
      }
    } catch (e) {
      debugPrint("Failed to export crash logs to a file : $e");
      if (!mounted) return;
      context.showSnackAlert(context.locale.operation_failed_snack_alert);
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _clearLogs() async {
    final confirm = await showConfirmationDialog(
      context: context,
      heroTag: 'clear_crash_logs',
      title: context.locale.crash_logs_clear_tile_title,
      info: context.locale.crash_logs_clear_dialog_info,
      icon: FluentIcons.delete_lines_20_filled,
      positiveLabel: context.locale.crash_logs_clear_dialog_button_clear_anyway,
    );

    if (confirm) {
      await MethodChannelService.instance.clearNativeCrashLogs();
      await DriftDbService.instance.driftDb.dynamicRecordsDao.clearCrashLogs();
    }
  }
}
