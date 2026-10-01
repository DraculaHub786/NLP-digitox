import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/env_loader.dart';
import 'package:nlp_digitox/core/services/bg_executor_service.dart';
import 'package:nlp_digitox/core/services/crash_log_service.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/core/services/session_link_handler.dart';
import 'package:nlp_digitox/features/mood/mood_service.dart';
import 'package:nlp_digitox/digitox_app.dart';

/// Dart background
@pragma('vm:entry-point')
Future<void> initBgExecutorService() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// The midnight job scores yesterday's chats through the Groq API, so this
  /// isolate needs the keys too. Asset access is not guaranteed here (a cold
  /// background start has no root isolate token), so this is best-effort:
  /// EnvLoader never throws, and ApiKeys falls back to any --dart-define.
  await EnvLoader.load();

  await BgExecutorService.instance.init();
}

/// Flutter main app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Load .env before anything else (provides Cloudinary, API keys, etc.).
  /// .env IS bundled (see pubspec.yaml assets) and supplies the Groq key in
  /// debug builds; release builds may instead pass --dart-define. Either way
  /// EnvLoader reports failure instead of throwing, and ApiKeys resolves from
  /// whichever source is present.
  await EnvLoader.load();

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

  /// Start watching for shared-session invite links. Any code that arrives
  /// before a screen is listening is held by the handler, so a cold start from
  /// a link is not lost while the splash and sign-in run.
  unawaited(SessionLinkHandler.instance.start());

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
