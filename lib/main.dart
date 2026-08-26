import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/bg_executor_service.dart';
import 'package:nlp_digitox/core/services/crash_log_service.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/features/mood/mood_service.dart';
import 'package:nlp_digitox/digitox_app.dart';

/// Dart background
@pragma('vm:entry-point')
Future<void> initBgExecutorService() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BgExecutorService.instance.init();
}

/// Flutter main app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  /// Initialize method channel and drift Database
  await MethodChannelService.instance.init();
  await DriftDbService.instance.init();

  /// Load saved mood check-ins back from disk. Without this, MoodService's
  /// in-memory history starts empty on every launch — even for a user with
  /// weeks of saved check-ins — which silently breaks SentimentMoodBridge's
  /// mood signal (it always reports "No mood check-ins yet").
  await MoodService().init();

  FlutterError.onError = (errorDetails) {
    CrashLogService.instance.recordCrashError(
      errorDetails.exception.toString(),
      errorDetails.stack.toString(),
    );

    if (kDebugMode) {
      FlutterError.presentError(errorDetails);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    CrashLogService.instance.recordCrashError(
      error.toString(),
      stack.toString(),
    );
    return !kDebugMode;
  };

  /// Scale app from edge-edge behind system ui
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  /// run main app
  runApp(
    const ProviderScope(
      child: DigitoxApp(),
    ),
  );
}
