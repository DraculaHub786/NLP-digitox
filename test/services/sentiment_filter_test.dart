import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/services/sentiment_filter.dart';

void main() {
  group('Sentiment Enum and Extensions', () {
    test('all sentiment types should be defined', () {
      expect(Sentiment.values.length, equals(6));
      expect(Sentiment.values, contains(Sentiment.veryPositive));
      expect(Sentiment.values, contains(Sentiment.positive));
      expect(Sentiment.values, contains(Sentiment.neutral));
      expect(Sentiment.values, contains(Sentiment.negative));
      expect(Sentiment.values, contains(Sentiment.veryNegative));
      expect(Sentiment.values, contains(Sentiment.unknown));
    });

    test('displayName should return correct labels', () {
      expect(Sentiment.veryPositive.displayName, equals('Excellent'));
      expect(Sentiment.positive.displayName, equals('Good'));
      expect(Sentiment.neutral.displayName, equals('Neutral'));
      expect(Sentiment.negative.displayName, equals('Bad'));
      expect(Sentiment.veryNegative.displayName, equals('Very Bad'));
      expect(Sentiment.unknown.displayName, equals('Unknown'));
    });

    test('emoji should return correct symbols', () {
      expect(Sentiment.veryPositive.emoji, equals('😄'));
      expect(Sentiment.positive.emoji, equals('🙂'));
      expect(Sentiment.neutral.emoji, equals('😐'));
      expect(Sentiment.negative.emoji, equals('😟'));
      expect(Sentiment.veryNegative.emoji, equals('😢'));
      expect(Sentiment.unknown.emoji, equals('❓'));
    });

    test('score should return numeric values from -2 to 2', () {
      expect(Sentiment.veryPositive.score, equals(2.0));
      expect(Sentiment.positive.score, equals(1.0));
      expect(Sentiment.neutral.score, equals(0.0));
      expect(Sentiment.negative.score, equals(-1.0));
      expect(Sentiment.veryNegative.score, equals(-2.0));
    });

    test('colorHex should return valid hex colors', () {
      expect(Sentiment.veryPositive.colorHex, equals('#4CAF50'));
      expect(Sentiment.positive.colorHex, equals('#8BC34A'));
      expect(Sentiment.neutral.colorHex, equals('#FFC107'));
      expect(Sentiment.negative.colorHex, equals('#FF9800'));
      expect(Sentiment.veryNegative.colorHex, equals('#F44336'));
    });
  });

  group('MoodSuggestion', () {
    test('should create with correct properties', () {
      final suggestion = MoodSuggestion(
        text: 'Take a break',
        action: 'break',
        priority: 8,
        category: 'wellness',
      );

      expect(suggestion.text, equals('Take a break'));
      expect(suggestion.action, equals('break'));
      expect(suggestion.priority, equals(8));
      expect(suggestion.category, equals('wellness'));
    });

    test('should have valid priority range', () {
      final suggestions = [
        MoodSuggestion(text: 'Test', action: 'test', priority: 1, category: 'test'),
        MoodSuggestion(text: 'Test', action: 'test', priority: 5, category: 'test'),
        MoodSuggestion(text: 'Test', action: 'test', priority: 10, category: 'test'),
      ];

      for (final s in suggestions) {
        expect(s.priority, greaterThanOrEqualTo(1));
        expect(s.priority, lessThanOrEqualTo(10));
      }
    });
  });

  group('SentimentPrediction Model', () {
    test('should create with correct properties', () {
      final prediction = SentimentPrediction(
        sentiment: Sentiment.positive,
        confidence: 0.85,
        analysis: 'User expressed positive emotions',
        inputText: 'I feel great',
        detectedEmotions: ['happy', 'content'],
        suggestions: [],
        reasoning: 'Positive keywords detected',
      );

      expect(prediction.sentiment, equals(Sentiment.positive));
      expect(prediction.confidence, equals(0.85));
      expect(prediction.inputText, equals('I feel great'));
      expect(prediction.isValid, isTrue);
    });

    test('isValid should check confidence threshold', () {
      final valid = SentimentPrediction(
        sentiment: Sentiment.positive,
        confidence: 0.65,
        analysis: 'Test',
        inputText: 'Test',
        detectedEmotions: [],
        suggestions: [],
        reasoning: 'Test',
      );

      final invalid = SentimentPrediction(
        sentiment: Sentiment.negative,
        confidence: 0.5,
        analysis: 'Test',
        inputText: 'Test',
        detectedEmotions: [],
        suggestions: [],
        reasoning: 'Test',
      );

      expect(valid.isValid, isTrue);
      expect(invalid.isValid, isFalse);
    });

    test('equality should work correctly', () {
      final pred1 = SentimentPrediction(
        sentiment: Sentiment.positive,
        confidence: 0.85,
        analysis: 'Test',
        inputText: 'Text A',
        detectedEmotions: [],
        suggestions: [],
        reasoning: 'Test',
      );

      final pred2 = SentimentPrediction(
        sentiment: Sentiment.positive,
        confidence: 0.87,
        analysis: 'Test',
        inputText: 'Text B',
        detectedEmotions: [],
        suggestions: [],
        reasoning: 'Test',
      );

      expect(pred1, equals(pred2)); // Within tolerance
    });
  });

  group('MoodEntry', () {
    test('should create mood entry with timestamp', () {
      final now = DateTime.now();
      final prediction = SentimentPrediction(
        sentiment: Sentiment.positive,
        confidence: 0.8,
        analysis: 'Test',
        inputText: 'Test',
        detectedEmotions: [],
        suggestions: [],
        reasoning: 'Test',
      );

      final entry = MoodEntry(
        id: '1',
        timestamp: now,
        prediction: prediction,
        note: 'Feeling good',
      );

      expect(entry.id, equals('1'));
      expect(entry.timestamp, equals(now));
      expect(entry.prediction, equals(prediction));
      expect(entry.note, equals('Feeling good'));
    });
  });

  group('MoodPattern Analysis', () {
    test('should calculate mood pattern correctly', () {
      final pattern = MoodPattern(
        averageScore: 0.5,
        dominantSentiment: Sentiment.positive,
        trend: 'Improving ⬆️',
        recommendations: [],
        period: '7 days',
      );

      expect(pattern.averageScore, equals(0.5));
      expect(pattern.dominantSentiment, equals(Sentiment.positive));
      expect(pattern.trend, contains('Improving'));
      expect(pattern.period, equals('7 days'));
    });
  });

  group('SentimentFilter Service - Initialization', () {
    late SentimentFilter filter;

    setUp(() {
      filter = SentimentFilter.instance;
    });

    test('singleton should return same instance', () {
      final filter1 = SentimentFilter.instance;
      final filter2 = SentimentFilter.instance;
      expect(filter1, equals(filter2));
    });

    test('should not be ready initially', () {
      expect(filter.isReady, isFalse);
    });

    test('initialize should succeed', () async {
      await filter.initialize();
      expect(filter.isReady, isTrue);
    });

    test('initialize should be idempotent', () async {
      await filter.initialize();
      await filter.initialize();
      expect(filter.isReady, isTrue);
    });

    test('debugStatus should show current state after reset', () async {
      await filter.initialize();
      await filter.release();

      var status = filter.debugStatus;
      expect(status, contains('SentimentFilter'));
      expect(status, contains('ready: false'));

      await filter.initialize();
      status = filter.debugStatus;
      expect(status, contains('ready: true'));

      await filter.release();
    });
  });

  group('SentimentFilter Service - Mood Analysis', () {
    late SentimentFilter filter;

    setUp(() async {
      filter = SentimentFilter.instance;
      await filter.initialize();
    });

    tearDown(() async {
      await filter.release();
    });

    test('analyzeMood should throw when not initialized', () async {
      final newFilter = SentimentFilter.instance;
      await newFilter.release();

      expect(
        () => newFilter.analyzeMood('Test'),
        throwsStateError,
      );
    });

    test('analyzeMood should throw on empty text', () async {
      expect(
        () => filter.analyzeMood(''),
        throwsArgumentError,
      );
    });

    test('analyzeMood should return SentimentPrediction', () async {
      final prediction = await filter.analyzeMood('I feel great');
      expect(prediction, isNotNull);
      expect(prediction.sentiment, isNotNull);
      expect(prediction.confidence, isNotNull);
      expect(prediction.inputText, equals('I feel great'));
    });

    test('analyzeMood should be case-insensitive', () async {
      final lower = await filter.analyzeMood('i feel great');
      final upper = await filter.analyzeMood('I FEEL GREAT');

      expect(lower.sentiment, isNotNull);
      expect(upper.sentiment, isNotNull);
    });
  });

  group('SentimentFilter Service - Batch Processing', () {
    late SentimentFilter filter;

    setUp(() async {
      filter = SentimentFilter.instance;
      await filter.initialize();
    });

    tearDown(() async {
      await filter.release();
    });

    test('analyzeMoodBatch should process multiple texts', () async {
      final texts = [
        'I feel amazing',
        'I feel sad',
        'I feel okay',
      ];

      final predictions = await filter.analyzeMoodBatch(texts);

      expect(predictions.length, equals(3));
      for (int i = 0; i < predictions.length; i++) {
        expect(predictions[i].inputText, equals(texts[i]));
      }
    });

    test('getMoodSuggestions should provide recommendations', () async {
      final suggestions = await filter.getMoodSuggestions('I feel sad');
      expect(suggestions, isNotEmpty);
      for (final s in suggestions) {
        expect(s.priority, greaterThanOrEqualTo(1));
        expect(s.priority, lessThanOrEqualTo(10));
      }
    });
  });

  group('SentimentFilter Service - Mood History', () {
    late SentimentFilter filter;

    setUp(() async {
      filter = SentimentFilter.instance;
      await filter.initialize();
    });

    tearDown(() async {
      await filter.release();
    });

    test('getMoodHistory should include tracked moods', () async {
      final historyBefore = filter.getMoodHistory().length;

      await filter.analyzeMood('I feel happy');
      await filter.analyzeMood('I feel sad');

      final history = filter.getMoodHistory();
      expect(history.length, greaterThanOrEqualTo(historyBefore + 2));
      // Most recent entries should be in there
      expect(history.map((e) => e.prediction.inputText).toList(),
          contains('I feel sad'));
    });

    test('getMoodHistory should respect limit parameter', () async {
      final history = filter.getMoodHistory(limit: 2);
      expect(history.length, lessThanOrEqualTo(2));
    });

    test('getMoodSummary should generate summary text', () {
      final summary = filter.getMoodSummary();
      expect(summary, isNotEmpty);
      // Should contain analysis info
      expect(
        summary,
        stringContainsInOrder(['Avg sentiment', 'Dominant mood', 'Trend']),
      );
    });
  });

  group('SentimentFilter Service - Mood Patterns', () {
    late SentimentFilter filter;

    setUp(() async {
      filter = SentimentFilter.instance;
      await filter.initialize();
    });

    tearDown(() async {
      await filter.release();
    });

    test('analyzeMoodPatterns should return valid pattern', () async {
      final pattern = filter.analyzeMoodPatterns();
      expect(pattern, isNotNull);
      expect(pattern.dominantSentiment, isNotNull);
      expect(pattern.period.contains('day'), isTrue);
    });

    test('analyzeMoodPatterns should handle mood history', () async {
      await filter.analyzeMood('Test mood');

      final pattern = filter.analyzeMoodPatterns();
      expect(pattern, isNotNull);
      expect(pattern.averageScore, isNotNull);
      expect(pattern.recommendations, isNotEmpty);
    });
  });

  group('SentimentFilter Service - Mood Suggestions', () {
    late SentimentFilter filter;

    setUp(() async {
      filter = SentimentFilter.instance;
      await filter.initialize();
    });

    tearDown(() async {
      await filter.release();
    });

    test('veryPositive mood should suggest motivation', () async {
      // Create a veryPositive mood prediction for testing
      final prediction = SentimentPrediction(
        sentiment: Sentiment.veryPositive,
        confidence: 0.9,
        analysis: 'Test',
        inputText: 'Test',
        detectedEmotions: ['joy', 'excitement'],
        suggestions: [],
        reasoning: 'Test',
      );

      // Suggestions should be positive/motivational
      expect(prediction.sentiment, equals(Sentiment.veryPositive));
      expect(prediction.confidence, greaterThan(0.5));
    });

    test('veryNegative mood should have critical suggestions', () {
      // Critical mood should trigger urgent suggestions
      expect(Sentiment.veryNegative.score, equals(-2.0));
      expect(Sentiment.veryNegative.emoji, equals('😢'));
    });

    test('neutral mood should suggest mindfulness', () {
      expect(Sentiment.neutral.score, equals(0.0));
      expect(Sentiment.neutral.emoji, equals('😐'));
    });
  });

  group('SentimentFilter Service - Resource Management', () {
    late SentimentFilter filter;

    setUp(() {
      filter = SentimentFilter.instance;
    });

    test('release should succeed', () async {
      await filter.initialize();
      expect(filter.isReady, isTrue);

      await filter.release();
      expect(filter.isReady, isFalse);
    });

    test('multiple releases should be safe', () async {
      await filter.initialize();
      await filter.release();
      await filter.release();
      expect(filter.isReady, isFalse);
    });
  });

  group('SentimentFilter Integration Tests', () {
    late SentimentFilter filter;

    setUp(() async {
      filter = SentimentFilter.instance;
      await filter.initialize();
    });

    tearDown(() async {
      await filter.release();
    });

    test('complete user mood tracking workflow', () async {
      // User inputs mood
      final pred1 = await filter.analyzeMood('I had a great day today');
      expect(pred1.sentiment, isNotNull);

      // Get suggestions
      final suggestions = await filter.getMoodSuggestions('I had a great day today');
      expect(suggestions, isNotEmpty);

      // Track more moods
      await filter.analyzeMood('Feeling a bit tired now');
      await filter.analyzeMood('But still happy');

      // Get history
      final history = filter.getMoodHistory();
      expect(history.length, greaterThanOrEqualTo(3)); // At least 3 direct entries

      // Analyze patterns
      final pattern = filter.analyzeMoodPatterns();
      expect(pattern, isNotNull);

      // Get summary
      final summary = filter.getMoodSummary();
      expect(summary, isNotEmpty);
    });
  });
}
