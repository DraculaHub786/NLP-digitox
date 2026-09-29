import 'dart:async';

import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/core/services/crash_log_service.dart';
import 'package:nlp_digitox/core/services/daily_sentiment_scoring_service.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/initializer.dart';

/// This class handles the Flutter method channel and is responsible for invoking flutter code.
///
/// The service executes tasks requested by native side in background.
class BgExecutorService {
  /// Singleton instance.
  static final BgExecutorService instance = BgExecutorService._();

  /// Private constructor for enforcing the singleton pattern.
  BgExecutorService._();

  /// How long the background isolate waits for Firebase Auth to restore the
  /// persisted session before giving up on the nightly score.
  static const Duration _authRestoreTimeout = Duration(seconds: 20);

  /// The method channel object used for communication.
  final MethodChannel _methodChannel = const MethodChannel(
    'com.nlp.digitox.methodchannel.bg',
  );

  /// Initializes the method channel by setting a handler for incoming method calls from the native side.
  Future<void> init() async {
    /// Every task must complete under 5 minutes
    _methodChannel.setMethodCallHandler(
      (call) async {
        try {
          /// Handle tasks
          switch (call.method) {
            case "onBootOrAppUpdate":
              await _onBootOrAppUpdate();
              break;
            case "onMidnightReset":
              await _onMidnightReset();
              break;
            default:
          }

          // Task is completed with success
          _signalTaskCompletion();
        } catch (e) {
          final error = "${call.method}(): $e";
          debugPrint("BgExecutorService.MethodCall: $error");

          // Task failed with exception
          _signalTaskCompletion(error: error);
        }
      },
    );

    debugPrint('BgExecutorService.init(): Service initialized');
  }

  /// Every call from the native side must call finish to let native side know
  /// that the task is completed and it can release resources
  void _signalTaskCompletion({String? error}) async {
    try {
      debugPrint(
        'BgExecutorService._signalTaskCompletion(): Background task completed',
      );
      _methodChannel.invokeMethod("signalTaskCompleted", error);
      // ignore: empty_catches
    } catch (e) {}
  }

  /// This method will be invoked when the device boots or
  /// if the Digitox app is updated or changed
  ///
  /// Initialize and start all necessary services here
  Future<void> _onBootOrAppUpdate() async {
    await MethodChannelService.instance.init();
    await DriftDbService.instance.init();
    await Initializer.initializeServicesAndSchedules();
  }

  /// This method will be invoked everyday at Midnight 12
  ///
  /// Backup app's usage for yesterday to database
  Future<void> _onMidnightReset() async {
    await MethodChannelService.instance.init();
    await DriftDbService.instance.init();

    final dynamicDao = DriftDbService.instance.driftDb.dynamicRecordsDao;
    final uniqueDao = DriftDbService.instance.driftDb.uniqueRecordsDao;

    /// Load crash logs
    await CrashLogService.instance.loadLogsFromNativeToDriftDb();

    /// Date yesterday
    final dateYesterday = dateToday.subtract(1.days);

    /// ============== Clean older notifications ===============
    final notificationHistoryDays =
        (await uniqueDao.loadNotificationSettings()).notificationHistoryWeeks *
            7;
    await dynamicDao.removeBatchNotificationsBefore(
      dateYesterday.subtract(notificationHistoryDays.days),
    );

    /// ============== Clean older usage and insert fresh ===============

    /// Remove usages before the specified history time
    final usageHistoryDays =
        (await uniqueDao.loadDigitoxSettings()).usageHistoryWeeks * 7;
    await dynamicDao.removeBatchAppUsagesBefore(
      dateYesterday.subtract(usageHistoryDays.days),
    );

    /// Fetch and insert usage for yesterday
    final usages =
        await MethodChannelService.instance.fetchAppsUsageForInterval(
      start: dateYesterday,
      end: dateToday,
    );

    final usageCompanions = usages.entries
        .map(
          (entry) => AppUsageTableCompanion(
            date: Value(dateYesterday),
            packageName: Value(entry.key),
            screenTime: Value(entry.value.screenTime),
            mobileData: Value(entry.value.mobileData),
            wifiData: Value(entry.value.wifiData),
          ),
        )
        .toList();

    await dynamicDao.insertBatchAppUsages(usageCompanions);

    /// ============== Score yesterday's chats ===============
    await _scoreYesterdaysChats(dateYesterday);
  }

  /// Scores the chat conversation of [day] and stores the result in Firestore.
  ///
  /// This runs inside the background isolate that `FlutterBgExecutionWorker`
  /// spins up, which is a *separate* Dart VM with its own `FirebaseApp` — so
  /// Firebase has to be initialised here even though the foreground app
  /// already did it.
  ///
  /// The whole thing is wrapped so that no failure — missing Firebase config,
  /// no signed-in user, no API key, no network — can ever abort the midnight
  /// run, because the usage backup above shares this invocation and matters
  /// far more than the score.
  Future<void> _scoreYesterdaysChats(DateTime day) async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      final user = await _awaitSignedInUser();
      if (user == null) {
        debugPrint(
          'BgExecutorService._scoreYesterdaysChats: no signed-in user in '
          'background isolate, skipping scoring',
        );
        return;
      }

      final score = await DailySentimentScoringService.instance.scoreDay(day);
      debugPrint(
        'BgExecutorService._scoreYesterdaysChats: ${dayKeyOf(day)} = $score',
      );
    } catch (e) {
      debugPrint('BgExecutorService._scoreYesterdaysChats: failed - $e');
    }
  }

  /// Waits briefly for the persisted Firebase Auth session to be restored.
  ///
  /// A freshly created background isolate starts with no user in memory and
  /// restores the persisted session from native storage asynchronously.
  /// Reading `currentUser` straight after `Firebase.initializeApp()` would
  /// therefore normally return null and the nightly score would silently never
  /// be taken, so this gives the restore a bounded window to complete.
  static Future<User?> _awaitSignedInUser() async {
    final current = FirebaseAuth.instance.currentUser;
    if (current != null) return current;

    try {
      return await FirebaseAuth.instance
          .authStateChanges()
          .firstWhere((user) => user != null)
          .timeout(_authRestoreTimeout);
    } on TimeoutException {
      debugPrint(
        'BgExecutorService._awaitSignedInUser: timed out waiting for a '
        'signed-in user',
      );
      return FirebaseAuth.instance.currentUser;
    } catch (e) {
      debugPrint('BgExecutorService._awaitSignedInUser: $e');
      return FirebaseAuth.instance.currentUser;
    }
  }
}
