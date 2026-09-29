import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nlp_digitox/config/api_keys.dart';

/// Regression tests for [ApiKeys].
///
/// The bug being guarded against: every NLP service read `ApiKeys.groqApiKey`
/// and got an empty string while `.env` sat there fully populated, so Groq
/// answered "API key not configured" on chat, sentiment, nightly scoring and
/// the monthly report. Two separate causes are covered here - the constant
/// never consulted `.env` at all, and callers cached the value in a
/// `static final` before `dotenv.load()` had run.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    // Leave the global dotenv state clean for other test files.
    dotenv.testLoad(fileInput: '');
  });

  group('ApiKeys.groqApiKey', () {
    test('does not throw when the environment was never loaded', () {
      // A fresh isolate that never ran EnvLoader.load() - e.g. a unit test, or
      // the background isolate before its best-effort load.
      expect(
        () => ApiKeys.groqApiKey,
        returnsNormally,
        reason: 'reading a key must never throw when .env is unavailable',
      );
    });

    test('resolves the value from the .env asset', () {
      dotenv.testLoad(fileInput: 'GROQ_API_KEY=gsk_from_env_file');

      expect(ApiKeys.groqApiKey, equals('gsk_from_env_file'));
      expect(ApiKeys.hasGroqApiKey, isTrue);
      expect(ApiKeys.groqKeySource, equals('.env'));
    });

    test('picks up a key loaded after first read', () {
      // This is the exact sequence that used to break: read (empty), then load.
      // A `static final` snapshot would keep returning '' forever after.
      expect(ApiKeys.groqApiKey, isEmpty);

      dotenv.testLoad(fileInput: 'GROQ_API_KEY=gsk_loaded_late');

      expect(
        ApiKeys.groqApiKey,
        equals('gsk_loaded_late'),
        reason: 'the key must be read per request, not cached at first access',
      );
    });

    test('reports no source when nothing is configured', () {
      dotenv.testLoad(fileInput: '');

      expect(ApiKeys.groqApiKey, isEmpty);
      expect(ApiKeys.hasGroqApiKey, isFalse);
      expect(ApiKeys.groqKeySource, equals('none'));
    });

    test('treats a blank .env entry as absent', () {
      dotenv.testLoad(fileInput: 'GROQ_API_KEY=');

      expect(ApiKeys.groqApiKey, isEmpty);
      expect(ApiKeys.hasGroqApiKey, isFalse);
    });
  });

  group('ApiKeys.geminiApiKey', () {
    test('resolves independently of the Groq key', () {
      dotenv.testLoad(fileInput: '''
GROQ_API_KEY=gsk_present
GEMINI_API_KEY=gemini_present
''');

      expect(ApiKeys.groqApiKey, equals('gsk_present'));
      expect(ApiKeys.geminiApiKey, equals('gemini_present'));
      expect(ApiKeys.hasGeminiApiKey, isTrue);
    });

    test('is empty when only the Groq key is set', () {
      dotenv.testLoad(fileInput: 'GROQ_API_KEY=gsk_only');

      expect(ApiKeys.geminiApiKey, isEmpty);
      expect(ApiKeys.hasGeminiApiKey, isFalse);
    });
  });
}
