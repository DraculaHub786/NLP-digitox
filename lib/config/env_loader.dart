// Copyright (c) 2026 NLP digitox
//
// Loads the bundled `.env` asset.
//
// `dotenv.load()` used to be called inline from `main()` only. Two problems
// followed from that:
//
//   * The background isolate (see BgExecutorService) never loaded the file at
//     all, so the nightly sentiment score silently found no key.
//   * Nothing guaranteed the caller awaited the load before a service asked
//     for a key, so a key could be read before it existed.
//
// Callers should use [EnvLoader.load] instead of `dotenv.load` directly. It is
// idempotent and treats a missing/unreadable file as "no environment", which
// is a normal state in release builds that ship keys via `--dart-define`.

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvLoader {
  EnvLoader._();

  /// Bundled asset name (declared under `flutter: assets:` in pubspec.yaml).
  static const String fileName = '.env';

  /// True once the file has actually been read in this isolate.
  static bool _isLoaded = false;

  /// True once a load has been tried, so a failure is not retried on every
  /// caller for the life of the isolate.
  static bool _hasAttempted = false;

  /// Whether the environment file was successfully read in this isolate.
  static bool get isLoaded => _isLoaded;

  /// Reads [fileName] at most once per isolate.
  ///
  /// Returns true when the file is available. Returns false when it could not
  /// be read — for example in the background isolate, which has no root isolate
  /// token and therefore no asset access — or when the file is simply absent
  /// because the build supplied keys with `--dart-define` instead.
  static Future<bool> load() async {
    if (_isLoaded) return true;
    if (_hasAttempted) return false;
    _hasAttempted = true;

    try {
      await dotenv.load(fileName: fileName);
      _isLoaded = true;
      debugPrint('EnvLoader: $fileName loaded');
    } catch (error) {
      // Expected in release builds that use --dart-define, and in the
      // background isolate. ApiKeys falls back to the compile-time values.
      debugPrint(
        'EnvLoader: $fileName unavailable ($error). '
        'Falling back to --dart-define values.',
      );
    }

    return _isLoaded;
  }
}
