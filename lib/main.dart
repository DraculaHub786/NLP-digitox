import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  /// Load .env before anything else (provides Cloudinary, API keys, etc.)
  /// Non-blocking: in release builds we use --dart-define-from-file instead,
  /// so .env won't be bundled. Ignore missing file errors.
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('dotenv not loaded (expected in release): $e');
  }

  /// Firebase and the native method channel don't depend on each other — run together.
  /// This avoids a serialized startup where each await blocks the next.
  await Future.wait([
    Firebase.initializeApp().catchError((e) {
      debugPrint('Firebase initialization failed: $e');
      return Firebase.app(); // return a valid FirebaseApp on error
    }),
    MethodChannelService.instance.init(),
  ]);

  /// DB is needed before first frame, keep this blocking
  await DriftDbService.instance.init();

  /// Mood history isn't needed for the very first frame — load it right after
  /// runApp() instead of before, so the splash/launch screen clears sooner.
  unawaited(MoodService().init());

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
