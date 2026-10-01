// Copyright (c) 2026 NLP digitox

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/services/ai_sentiment_service.dart';

/// Tests for the parsing and deterministic-fallback paths of
/// [AISentimentService].
///
/// Context for these tests: `openai/gpt-oss-20b` is a reasoning model whose
/// reasoning tokens are charged against the completion budget, so the
/// dashboard calls used to come back with an *empty* `message.content`. That
/// surfaced as `Failed to parse sentiment response: ` (nothing after the
/// colon) and a tips panel showing "Generated 0 recommendations". The fixes
/// are a real token budget on the request side and a meaningful fallback on
/// the parse side — both covered here.
void main() {
  final service = AISentimentService.instance;

  group('parseSentiment', () {
    test('parses the legacy Label: value format and normalises to ~100', () {
      final sentiment = service.parseSentiment(
        'Positive: 40\nNeutral: 30\nNegative: 10\nAnxious: 10\nFocused: 10',
      );

      expect(sentiment.keys.length, 5);
      expect(sentiment.values.reduce((a, b) => a + b), closeTo(100, 0.01));
      expect(sentiment['Positive'], closeTo(40, 0.01));
    });

    test('parses a JSON object response', () {
      final sentiment = service.parseSentiment(
        '{"Positive": 45, "Neutral": 25, "Negative": 10, '
        '"Anxious": 10, "Focused": 10}',
      );

      expect(sentiment['Positive'], closeTo(45, 0.01));
      expect(sentiment['Neutral'], closeTo(25, 0.01));
    });

    test('parses a fenced JSON response', () {
      final sentiment = service.parseSentiment(
        '```json\n{"Positive": 50, "Neutral": 20, "Negative": 10, '
        '"Anxious": 10, "Focused": 10}\n```',
      );

      expect(sentiment['Positive'], closeTo(50, 0.01));
    });

    test('throws a readable error for an empty response', () {
      // Exactly what the dashboard used to receive from the model.
      expect(
        () => service.parseSentiment(''),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('Failed to parse sentiment response'),
          ),
        ),
      );
    });

    test('throws when fewer than three labels are present', () {
      expect(
        () => service.parseSentiment('Positive: 50\nNeutral: 50'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('parseRecommendations', () {
    test('parses a numbered list from the model', () {
      final tips = service.parseRecommendations(
        '1. Put your phone face-down for an hour.\n'
        '2. Take a two minute breathing break.\n'
        '3. Finish one habit you usually skip.',
      );

      expect(tips.length, 3);
      expect(tips.first, 'Put your phone face-down for an hour.');
    });

    test('parses a bare JSON array', () {
      final tips = service.parseRecommendations(
        '["Take a screen-free walk outside.", '
        '"Silence non-essential notifications."]',
      );

      expect(tips, contains('Take a screen-free walk outside.'));
      expect(tips.length, 2);
    });

    test('parses an object-wrapped array', () {
      final tips = service.parseRecommendations(
        '{"recommendations": ["Start a 20 minute focus session now.", '
        '"Close the apps you did not need today."]}',
      );

      expect(tips.length, 2);
    });

    test('throws when there is nothing usable in the response', () {
      expect(
        () => service.parseRecommendations(''),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('computeBaseRecommendations', () {
    test('always returns actionable tips', () {
      final tips = service.computeBaseRecommendations(
        screenTimeHours: 2,
        goalHours: 3,
        sentiment: const {'Neutral': 60, 'Positive': 40},
        screenTimeGoalSeconds: 10800,
      );

      expect(tips, isNotEmpty);
      expect(tips.every((tip) => tip.length > 20), isTrue);
    });

    test('calls out over-goal screen time with the actual percentage', () {
      final tips = service.computeBaseRecommendations(
        screenTimeHours: 6,
        goalHours: 3,
        sentiment: const {'Anxious': 70, 'Neutral': 30},
      );

      expect(tips.first, contains('200%'));
    });

    test('reassures inside the goal instead of warning', () {
      final tips = service.computeBaseRecommendations(
        screenTimeHours: 1,
        goalHours: 3,
        sentiment: const {'Positive': 70, 'Neutral': 30},
        screenTimeGoalSeconds: 10800,
      );

      expect(tips.first, contains('inside your screen time goal'));
    });

    test('responds to the dominant sentiment', () {
      final anxiousTips = service.computeBaseRecommendations(
        screenTimeHours: 2,
        goalHours: 3,
        sentiment: const {'Anxious': 70, 'Neutral': 30},
      );
      final focusedTips = service.computeBaseRecommendations(
        screenTimeHours: 2,
        goalHours: 3,
        sentiment: const {'Focused': 70, 'Neutral': 30},
      );

      expect(anxiousTips.join(' '), contains('breathing'));
      expect(focusedTips.join(' '), contains('focus is high'));
    });

    test('handles an empty sentiment map without throwing', () {
      final tips = service.computeBaseRecommendations(
        screenTimeHours: 2,
        goalHours: 0,
        sentiment: const {},
      );

      expect(tips, isNotEmpty);
    });

    test('never returns more than four tips', () {
      final tips = service.computeBaseRecommendations(
        screenTimeHours: 9,
        goalHours: 3,
        sentiment: const {'Anxious': 70, 'Positive': 30},
        screenTimeGoalSeconds: 10800,
      );

      expect(tips.length, lessThanOrEqualTo(4));
    });
  });

  group('computeBaseSentiment', () {
    test('weights the five labels to ~100', () {
      final sentiment = service.computeBaseSentiment(
        screenTimeHours: 2,
        goalHours: 3,
        streakDays: 5,
        habitsCompleted: 2,
        tasksCompleted: 3,
      );

      expect(sentiment.keys.length, 5);
      expect(sentiment.values.reduce((a, b) => a + b), closeTo(100, 0.01));
    });

    test('over-goal usage raises Anxious above under-goal usage', () {
      final over = service.computeBaseSentiment(
        screenTimeHours: 9,
        goalHours: 3,
        streakDays: 0,
        habitsCompleted: 0,
        tasksCompleted: 0,
      );
      final under = service.computeBaseSentiment(
        screenTimeHours: 1,
        goalHours: 3,
        streakDays: 0,
        habitsCompleted: 0,
        tasksCompleted: 0,
      );

      expect(over['Anxious']!, greaterThan(under['Anxious']!));
      expect(under['Positive']!, greaterThan(over['Positive']!));
    });

    test('is deterministic for the same input', () {
      Map<String, double> compute() => service.computeBaseSentiment(
            screenTimeHours: 4,
            goalHours: 3,
            streakDays: 4,
            habitsCompleted: 1,
            tasksCompleted: 2,
          );

      expect(compute(), equals(compute()));
    });
  });
}
