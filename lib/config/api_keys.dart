// Copyright (c) 2026 NLP digitox
//
// Resolves the AI provider keys used by the NLP features.
//
// Resolution order, highest priority first:
//
//   1. `--dart-define=GROQ_API_KEY=...` (or `--dart-define-from-file`), baked
//      into the binary at compile time. This is how release builds ship keys.
//   2. The bundled `.env` asset, read through `flutter_dotenv`.
//   3. `_groqLiteral` / `_geminiLiteral` below, for a quick local paste.
//
// Why this file resolves instead of holding a bare constant: every NLP service
// used to read `ApiKeys.groqApiKey` as a `static final` snapshot taken at first
// access. A constant can only ever answer "nothing configured" unless someone
// remembers to paste a key into source, and the snapshot meant that even a
// correctly loaded `.env` was read too early to be seen — which is why Groq
// reported "API key not configured" while `.env` was sitting there full.
//
// Get a free Groq key at https://console.groq.com/keys
// Get a Gemini key at https://aistudio.google.com/apikey

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeys {
  // ---------------------------------------------------------------------------
  // Compile-time keys (--dart-define / --dart-define-from-file)
  // ---------------------------------------------------------------------------

  /// Baked into the binary at build time; empty unless a `--dart-define` was
  /// supplied. `String.fromEnvironment` must be `const` to be substituted, so
  /// these cannot be merged with the runtime sources below.
  static const String _groqDefine = String.fromEnvironment('GROQ_API_KEY');
  static const String _geminiDefine = String.fromEnvironment('GEMINI_API_KEY');

  // ---------------------------------------------------------------------------
  // Local paste fallback
  // ---------------------------------------------------------------------------

  /// Last-resort local key. Leave empty and use `.env` or `--dart-define`.
  static const String _groqLiteral = '';
  static const String _geminiLiteral = '';

  // ---------------------------------------------------------------------------
  // Resolution
  // ---------------------------------------------------------------------------

  /// Reads [key] from the bundled `.env`, or returns `''` when the file was
  /// never loaded.
  ///
  /// [dotenv] throws a `StateError` if `dotenv.load()` has not run — for
  /// example in a unit test, or in the background isolate before it loads the
  /// file. That must not blow up a caller that only wants to ask whether a key
  /// exists, so a missing environment is reported as "no value".
  static String _fromEnv(String key) {
    try {
      return dotenv.env[key] ?? '';
    } catch (_) {
      return '';
    }
  }

  /// First non-empty of [values], or `''` when all are empty.
  static String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  /// Groq API key used by the chatbot, sentiment analysis, daily scoring and
  /// the monthly wellbeing report.
  ///
  /// A getter, deliberately: callers must read it at request time so a key
  /// that only becomes available after `dotenv.load()` is still picked up.
  static String get groqApiKey =>
      _firstNonEmpty([_groqDefine, _fromEnv('GROQ_API_KEY'), _groqLiteral]);

  /// Gemini API key. Not yet consumed by any service, but resolved the same
  /// way so it is correct the moment something uses it.
  static String get geminiApiKey => _firstNonEmpty(
        [_geminiDefine, _fromEnv('GEMINI_API_KEY'), _geminiLiteral],
      );

  /// Whether a Groq key resolved from any source.
  static bool get hasGroqApiKey => groqApiKey.isNotEmpty;

  /// Whether a Gemini key resolved from any source.
  static bool get hasGeminiApiKey => geminiApiKey.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Shared-session webhooks (n8n)
  // ---------------------------------------------------------------------------

  static const String _sessionCompleteDefine =
      String.fromEnvironment('SESSION_COMPLETE_WEBHOOK_URL');
  static const String _sessionCleanupDefine =
      String.fromEnvironment('SESSION_CLEANUP_WEBHOOK_URL');

  /// URL of the n8n workflow that verifies a finished shared run and awards
  /// points.
  ///
  /// Empty by default, and empty is a supported state: a build without it runs
  /// shared sessions exactly as before and simply never calls the webhook.
  static String get sessionCompleteWebhookUrl => _firstNonEmpty([
        _sessionCompleteDefine,
        _fromEnv('SESSION_COMPLETE_WEBHOOK_URL'),
      ]);

  /// URL of the n8n cron that deletes stale sessions and expired invites.
  /// Only the workflow uses this; the app never calls it. It exists here so the
  /// whole set of server-side endpoints is documented in one place.
  static String get sessionCleanupWebhookUrl => _firstNonEmpty([
        _sessionCleanupDefine,
        _fromEnv('SESSION_CLEANUP_WEBHOOK_URL'),
      ]);

  // NOTE: there is deliberately no `sessionWebhookSecret`. A shared secret
  // compiled into the app protects nothing — anyone can extract it — so the
  // completion webhook authenticates the caller with the Firebase ID token
  // instead. See `SessionCompletionService`.

  /// Whether a completion webhook is configured.
  static bool get hasSessionCompleteWebhook =>
      sessionCompleteWebhookUrl.isNotEmpty;

  /// Where [groqApiKey] came from — for logs and the settings diagnostics
  /// screen. Never logs the key itself.
  static String get groqKeySource {
    if (_groqDefine.isNotEmpty) return 'dart-define';
    if (_fromEnv('GROQ_API_KEY').isNotEmpty) return '.env';
    if (_groqLiteral.isNotEmpty) return 'api_keys.dart';
    return 'none';
  }
}
