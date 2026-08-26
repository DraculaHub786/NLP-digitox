// ignore_for_file: empty_catches


import 'package:drift/drift.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';

/// A service class responsible for logging Crashes in the Isar database.
class CrashLogService {
  /// Private constructor to enforce singleton pattern.
  CrashLogService._();

  /// Singleton instance of the [CrashLogService].
  static CrashLogService instance = CrashLogService._();

  /// Load logs from native side and insert them to drift db then clear them on native side
  /// Must be called after initializing [MethodChannelService] and [DriftDbService]
  Future<void> loadLogsFromNativeToDriftDb() async {
    try {
      /// Load logs
      final nativeLogs =
          await MethodChannelService.instance.getNativeCrashLogs();

      if (nativeLogs.isEmpty) return;

      /// Insert logs to db
      await DriftDbService.instance.driftDb.dynamicRecordsDao
          .insertCrashLogs(nativeLogs);

      /// Clear logs on native side
      await MethodChannelService.instance.clearNativeCrashLogs();

      /// Remove logs older than 1 month from db
      await DriftDbService.instance.driftDb.dynamicRecordsDao
          .removeCrashLogOlderThanDate(dateToday.subtract(30.days));
    } catch (e) {}
  }

  /// Create a [CrashLog] object from the provided information and stores it in the database
  void recordCrashError(String error, String stackTrace) async {
    /// Create log
    final crashLog = CrashLogsTableCompanion.insert(
      appVersion:
          Value(MethodChannelService.instance.deviceInfo.digitoxVersion),
      error: Value(error),
      stackTrace: Value(stackTrace),
      timeStamp: Value(DateTime.now()),
    );

    /// Insert log to database
    await DriftDbService.instance.driftDb.dynamicRecordsDao
        .insertCrashLog(crashLog);
  }
}
