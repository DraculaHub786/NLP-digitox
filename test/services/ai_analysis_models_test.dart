import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/services/ai_sentiment_service.dart';
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

  group('AISentimentService.computeBaseSentiment (Part K)', () {
    final service = AISentimentService.instance;

    Map<String, double> score({
      double screenTimeHours = 2,
      double goalHours = 4,
      int streak = 0,
      int habits = 0,
      int tasks = 0,
    }) {
      return service.computeBaseSentiment(
        screenTimeHours: screenTimeHours,
        goalHours: goalHours,
        streakDays: streak,
        habitsCompleted: habits,
        tasksCompleted: tasks,
      );
    }

    test('returns all five labels summing to ~100', () {
      final result = score(
        screenTimeHours: 2,
        goalHours: 4,
        streak: 5,
        habits: 2,
        tasks: 3,
      );
      expect(result.keys.toSet(), {'Positive', 'Neutral', 'Negative', 'Anxious', 'Focused'});
      final total = result.values.fold(0.0, (sum, v) => sum + v);
      expect(total, closeTo(100.0, 0.001));
    });

    test('under goal boosts Positive/Focused vs over goal', () {
      final underGoal = score(screenTimeHours: 2, goalHours: 4);
      final overGoal = score(screenTimeHours: 8, goalHours: 4);
      expect(underGoal['Positive']!, greaterThan(overGoal['Positive']!));
      expect(underGoal['Focused']!, greaterThan(overGoal['Focused']!));
      expect(overGoal['Anxious']!, greaterThan(underGoal['Anxious']!));
      expect(overGoal['Negative']!, greaterThan(underGoal['Negative']!));
    });

    test('higher streak raises Positive and Focused', () {
      final noStreak = score(streak: 0);
      final strongStreak = score(streak: 7);
      expect(strongStreak['Positive']!, greaterThan(noStreak['Positive']!));
      expect(strongStreak['Focused']!, greaterThan(noStreak['Focused']!));
    });

    test('habits completed raise Positive and Focused', () {
      final noHabits = score(habits: 0);
      final withHabits = score(habits: 3);
      expect(withHabits['Positive']!, greaterThan(noHabits['Positive']!));
      expect(withHabits['Focused']!, greaterThan(noHabits['Focused']!));
    });

    test('zero goal hours does not crash and still sums to 100', () {
      final result = score(screenTimeHours: 1, goalHours: 0);
      final total = result.values.fold(0.0, (sum, v) => sum + v);
      expect(total, closeTo(100.0, 0.001));
    });

    test('goal boundary 100-130% leans Neutral, not Anxious', () {
      // 4.5h vs 4h goal = 112.5% → neutral band: neutral = 40/110 = 36.4%.
      final boundary = score(screenTimeHours: 4.5, goalHours: 4);
      expect(boundary['Neutral']!, greaterThan(35));
      expect(boundary['Anxious']!, lessThan(12));
    });
  });

  group('AISentimentService.parseSentiment (Part L.4)', () {
    final service = AISentimentService.instance;

    test('parses a clean JSON object with all five labels', () {
      final result = service.parseSentiment(
        '{"Positive": 30, "Neutral": 35, "Negative": 10, "Anxious": 10, "Focused": 15}',
      );
      expect(result['Positive'], 30);
      expect(result['Neutral'], 35);
      expect(result['Focused'], 15);
    });

    test('tolerates markdown json fences', () {
      final result = service.parseSentiment(
        '```json\n{"Positive": 40, "Neutral": 30, "Negative": 10, "Anxious": 10, "Focused": 10}\n```',
      );
      expect(result['Positive'], 40);
    });

    test('matches keys case-insensitively', () {
      final result = service.parseSentiment(
        '{"positive": 20, "neutral": 20, "negative": 20, "anxious": 20, "focused": 20}',
      );
      expect(result.keys.toSet(), {'Positive', 'Neutral', 'Negative', 'Anxious', 'Focused'});
    });

    test('normalizes values that drift off-target back to ~100', () {
      final result = service.parseSentiment(
        '{"Positive": 60, "Neutral": 60, "Negative": 10, "Anxious": 10, "Focused": 10}',
      );
      final total = result.values.fold(0.0, (sum, v) => sum + v);
      expect(total, closeTo(100.0, 0.001));
    });

    test('throws FormatException when a label is missing', () {
      expect(
        () => service.parseSentiment('{"Positive": 50, "Neutral": 50}'),
        throwsFormatException,
      );
    });

    test('throws FormatException on non-JSON text', () {
      expect(
        () => service.parseSentiment('Positive: 20\nNeutral: 20'),
        throwsFormatException,
      );
    });
  });

  group('AISentimentService.parseRecommendations (Part M.3)', () {
    final service = AISentimentService.instance;

    test('parses a bare JSON array of strings', () {
      final result = service.parseRecommendations(
        '["Take a 10 minute walk outside", "Set a single focus task now", "Turn off notifications for an hour", "Drink water before another session"]',
      );
      expect(result.length, 4);
      expect(result.first, contains('walk'));
    });

    test('parses an object-wrapped array (Groq json_object mode)', () {
      final result = service.parseRecommendations(
        '{"recommendations": ["Take a 10 minute walk outside", "Set a single focus task now", "Turn off notifications for an hour", "Drink water before another session"]}',
      );
      expect(result.length, 4);
    });

    test('flattens map objects with title/description/action (live Groq shape)', () {
      final result = service.parseRecommendations(
        '{"recommendations": ['
        '{"title": "Work-Segmentation Break", "description": "Set a 5-minute timer to take a break from work every 90 minutes", "action": "Use a Pomodoro timer"},'
        '{"title": "Sleep-Promoting Routine", "description": "Establish a calming pre-sleep routine to signal your brain to sleep", "action": "Try gentle stretches"},'
        '{"title": "Digital Detox Hour", "description": "Schedule a screen-free hour to recharge and reduce anxiety", "action": "Replace screen time"},'
        '{"title": "Progress Tracking", "description": "Monitor your progress and celebrate small achievements", "action": "Keep a daily journal"}'
        ']}',
      );
      expect(result.length, 4);
      // Prefers the most substantive field (description) over title/action.
      expect(result.first, contains('5-minute timer'));
    });

    test('keeps legacy numbered-list parsing as a fallback', () {
      final result = service.parseRecommendations(
        '1. Take a 10 minute walk outside\n2. Set a single focus task now\n3. Turn off notifications for an hour\n4. Drink water before another session',
      );
      expect(result.length, 4);
    });

    test('throws FormatException when nothing parsable', () {
      expect(
        () => service.parseRecommendations('No recommendations available.'),
        throwsFormatException,
      );
    });
  });
}
