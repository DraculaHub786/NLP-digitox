import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/services/chat_context_extractor.dart';
import 'package:nlp_digitox/models/ai_analysis_models.dart';

void main() {
  group('classifyAiFailure', () {
    test('missing API key', () {
      final failure = classifyAiFailure(
        Exception('Groq API key is not configured.'),
      );
      expect(failure.type, AiFailureType.missingApiKey);
    });

    test('invalid API key (401-ish)', () {
      final failure = classifyAiFailure(
        Exception('HTTP 401: Invalid API key provided'),
      );
      expect(failure.type, AiFailureType.invalidApiKey);
    });

    test('quota / rate limit (429)', () {
      final failure = classifyAiFailure(
        Exception('HTTP 429: Rate limit exceeded, limit 30 / min'),
      );
      expect(failure.type, AiFailureType.quotaExceeded);
    });

    test('network failure', () {
      final failure = classifyAiFailure(
        Exception('Connection refused: api.groq.com'),
      );
      expect(failure.type, AiFailureType.network);
    });

    test('timeout', () {
      final failure = classifyAiFailure(
        TimeoutException('timed out'),
      );
      expect(failure.type, AiFailureType.timeout);
    });

    test('parse failure', () {
      final failure = classifyAiFailure(
        FormatException('Failed to parse sentiment response: blah'),
      );
      expect(failure.type, AiFailureType.parseFailure);
    });

    test('server error', () {
      final failure = classifyAiFailure(
        Exception('API error: 500'),
      );
      expect(failure.type, AiFailureType.serverError);
    });

    test('unknown error is classified as unknown', () {
      final failure = classifyAiFailure(
        Exception('Weird error with no special marker'),
      );
      expect(failure.type, AiFailureType.unknown);
    });
  });

  group('SentimentResult', () {
    test('fallback result carries isFallback flag and const fallback data', () {
      const failure = AiFailure(AiFailureType.missingGoal, 'no goal');
      const result = SentimentResult.fallback(failure);
      expect(result.isFallback, isTrue);
      expect(result.failure?.type, AiFailureType.missingGoal);
      expect(result.sentiments, kFallbackSentiment);
    });

    test('real result defaults isFallback to false', () {
      const result = SentimentResult(sentiments: {
        'Positive': 100.0,
        'Neutral': 0.0,
        'Negative': 0.0,
        'Anxious': 0.0,
        'Focused': 0.0,
      });
      expect(result.isFallback, isFalse);
      expect(result.failure, isNull);
    });
  });

  group('RecommendationsResult', () {
    test('fallback result carries isFallback flag and const fallback tips', () {
      const failure = AiFailure(AiFailureType.network, 'no net');
      const result = RecommendationsResult.fallback(failure);
      expect(result.isFallback, isTrue);
      expect(result.recommendations, kFallbackRecommendations);
    });
  });

  group('ChatTheme', () {
    test('JSON round-trip preserves topic and mentions', () {
      const theme = ChatTheme('work', 5);
      final restored = ChatTheme.fromJson(theme.toJson());
      expect(restored.topic, 'work');
      expect(restored.mentions, 5);
    });

    test('fromJson tolerates missing/invalid fields', () {
      final restored = ChatTheme.fromJson(const {'t': null, 'm': 'oops'});
      expect(restored.topic, 'unknown');
      expect(restored.mentions, 0);
    });
  });
}
