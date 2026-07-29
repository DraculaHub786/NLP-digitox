
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/core/utils/db_utils.dart';
import 'package:nlp_digitox/ui/dialogs/time_countdown_dialog.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ImportExportDb extends ConsumerStatefulWidget {
  const ImportExportDb({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImportExportDbState();
}

class _ImportExportDbState extends ConsumerState<ImportExportDb> {
  bool _isExporting = false;
  bool _isImporting = false;

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
                const ModernSectionHeader(title: 'Database'),
                12.vBox,
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      /// Import
                      ModernListTile(
                        title: context.locale.import_db_tile_title,
                        subtitle: context.locale.import_db_tile_subtitle,
                        icon: FluentIcons.arrow_download_20_regular,
                        iconColor: colorScheme.primary,
                        showChevron: true,
                        trailing: _isImporting
                            ? const SizedBox.square(
                                dimension: 24,
                                child: CircularProgressIndicator(strokeCap: StrokeCap.round),
                              )
                            : null,
                        onTap: _importDatabase,
                      ),
                      8.vBox,

                      /// Export
                      ModernListTile(
                        title: context.locale.export_db_tile_title,
                        subtitle: context.locale.export_db_tile_subtitle,
                        icon: FluentIcons.arrow_upload_20_regular,
                        iconColor: colorScheme.secondary,
                        showChevron: true,
                        trailing: _isExporting
                            ? const SizedBox.square(
                                dimension: 24,
                                child: CircularProgressIndicator(strokeCap: StrokeCap.round),
                              )
                            : null,
                        onTap: _exportDatabase,
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

  void _importDatabase() async {
    try {
      setState(() => _isImporting = true);

      /// Original DB file
      final originalDbFile = File(await getSqliteDbPath());
      final result = await FilePicker.platform.pickFiles(
        compressionQuality: 0,
        type: FileType.any,
      );

      if (result == null ||
          result.count < 1 ||
          result.files.first.extension != 'sqlite') {
        throw Exception(
          'Either selected file is null or invalid extension',
        );
      }

      /// Backup DB file
      final backupFile = File(result.files.first.xFile.path);

      if (await backupFile.exists()) {
        /// dispose, clean, copy
        await DriftDbService.instance.driftDb.close();
        await originalDbFile.delete();
        await backupFile.copy(originalDbFile.path);

        /// let user know about the restart
        mounted
            ? await showCountDownDialog(
                context: context,
                heroTag: 'import_database',
                timerDuration: 5.seconds,
                title: context.locale.app_restart_dialog_title,
                info: context.locale.app_restart_dialog_info,
                icon: FluentIcons.arrow_repeat_all_20_filled,
                onCountDownFinish: MethodChannelService.instance.restartApp,
              )
            : await MethodChannelService.instance.restartApp();
      } else {
        throw Exception('Backup file does not exist');
      }
    } catch (e) {
      debugPrint("Error occurred while importing database: $e");
      if (!mounted) return;
      context.showSnackAlert(context.locale.operation_failed_snack_alert);
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  void _exportDatabase() async {
    try {
      setState(() => _isExporting = true);

      /// Get the database path: /data/user/0/com.mindful.android/app_flutter/Mindful.sqlite
      final dbFile = File(await getSqliteDbPath());
      if (!await dbFile.exists()) {
        throw Exception('Database file not found at ${dbFile.path}');
      }

      /// export to file
      final dbFileBytes = await dbFile.readAsBytes();
      final timeStamp = DateFormat('yyyy-MM-dThh-mm-ss').format(DateTime.now());
      final dbVersionCode = DriftDbService.instance.driftDb.schemaVersion;
      final mindfulVersionCode = MethodChannelService
          .instance.deviceInfo.mindfulVersion
          .split("+")
          .lastOrNull;

      final resultPath = await FilePicker.platform.saveFile(
        fileName:
            "NLP_digitox_v${mindfulVersionCode}_dbv${dbVersionCode}_$timeStamp.sqlite",
        bytes: Uint8List.fromList(dbFileBytes),
      );

      /// user aborted
      if (resultPath == null) {
        throw Exception('User aborted the exporting operation');
      }
    } catch (e) {
      debugPrint("Error occurred while exporting database: $e");
      if (!mounted) return;
      context.showSnackAlert(context.locale.operation_failed_snack_alert);
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
}
