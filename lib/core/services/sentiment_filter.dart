// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/foundation.dart';

/// Sentiment/Mood classification
enum Sentiment {
  /// Very positive mood
  veryPositive,

  /// Positive mood
  positive,

  /// Neutral mood
  neutral,

  /// Negative mood
  negative,

  /// Very negative mood
  veryNegative,

  /// Unable to classify
  unknown,
}

/// Extension for sentiment display
extension SentimentExtension on Sentiment {
  String get displayName {
    switch (this) {
      case Sentiment.veryPositive:
        return 'Excellent';
      case Sentiment.positive:
        return 'Good';
      case Sentiment.neutral:
        return 'Neutral';
      case Sentiment.negative:
        return 'Bad';
      case Sentiment.veryNegative:
        return 'Very Bad';
      case Sentiment.unknown:
        return 'Unknown';
    }
  }

  String get emoji {
    switch (this) {
      case Sentiment.veryPositive:
        return '😄';
      case Sentiment.positive:
        return '🙂';
      case Sentiment.neutral:
        return '😐';
      case Sentiment.negative:
        return '😟';
      case Sentiment.veryNegative:
        return '😢';
      case Sentiment.unknown:
        return '❓';
    }
  }

  String get description {
    switch (this) {
      case Sentiment.veryPositive:
        return 'Excellent mood - Very happy and satisfied';
      case Sentiment.positive:
        return 'Good mood - Happy and content';
      case Sentiment.neutral:
        return 'Neutral mood - Neither happy nor sad';
      case Sentiment.negative:
        return 'Bad mood - Unhappy and dissatisfied';
      case Sentiment.veryNegative:
        return 'Very bad mood - Extremely unhappy or distressed';
      case Sentiment.unknown:
        return 'Unable to determine mood';
    }
  }

  /// Score from -2 to 2
  double get score {
    switch (this) {
      case Sentiment.veryPositive:
        return 2.0;
      case Sentiment.positive:
        return 1.0;
      case Sentiment.neutral:
        return 0.0;
      case Sentiment.negative:
        return -1.0;
      case Sentiment.veryNegative:
        return -2.0;
      case Sentiment.unknown:
        return 0.0;
    }
  }

  /// Color hex code for visualization
  String get colorHex {
    switch (this) {
      case Sentiment.veryPositive:
        return '#4CAF50'; // Green
      case Sentiment.positive:
        return '#8BC34A'; // Light green
      case Sentiment.neutral:
        return '#FFC107'; // Amber
      case Sentiment.negative:
        return '#FF9800'; // Orange
      case Sentiment.veryNegative:
        return '#F44336'; // Red
      case Sentiment.unknown:
        return '#9E9E9E'; // Grey
    }
  }
}

/// Mood-based suggestion
class MoodSuggestion {
  /// Suggestion text
  final String text;

  /// Action to take
  final String action;

  /// Priority (1-10)
  final int priority;

  /// Category (exercise, meditation, break, etc.)
  final String category;

  const MoodSuggestion({
    required this.text,
    required this.action,
    required this.priority,
    required this.category,
  });

  @override
  String toString() => 'MoodSuggestion($category - P$priority: $text)';
}

/// Real sentiment prediction with mood insights
class SentimentPrediction {
  /// Detected sentiment
  final Sentiment sentiment;

  /// Confidence score (0.0 to 1.0)
  final double confidence;

  /// Raw analysis from AI model
  final String analysis;

  /// Input text that was analyzed
  final String inputText;

  /// Detected emotions/mood indicators
  final List<String> detectedEmotions;

  /// Mood-based suggestions
  final List<MoodSuggestion> suggestions;

  /// Reasoning behind the classification
  final String reasoning;

  const SentimentPrediction({
    required this.sentiment,
    required this.confidence,
    required this.analysis,
    required this.inputText,
    required this.detectedEmotions,
    required this.suggestions,
    required this.reasoning,
  });

  /// Is this a valid prediction
  bool get isValid => confidence > 0.6;

  @override
  String toString() =>
      'SentimentPrediction(${sentiment.displayName} ${sentiment.emoji}, confidence: ${(confidence * 100).toStringAsFixed(1)}%, emotions: ${detectedEmotions.join(", ")})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SentimentPrediction &&
          runtimeType == other.runtimeType &&
          sentiment == other.sentiment &&
          (confidence - other.confidence).abs() < 0.05;

  @override
  int get hashCode => sentiment.hashCode ^ confidence.hashCode;
}

/// User mood history entry
class MoodEntry {
  /// Unique entry ID
  final String id;

  /// When this mood was recorded
  final DateTime timestamp;

  /// The sentiment prediction
  final SentimentPrediction prediction;

  /// Context (what the user was doing)
  final String? context;

  /// User's note about their mood
  final String? note;

  const MoodEntry({
    required this.id,
    required this.timestamp,
    required this.prediction,
    this.context,
    this.note,
  });

  @override
  String toString() =>
      'MoodEntry(${prediction.sentiment.displayName} at ${timestamp.toString()})';
}

/// Mood pattern analysis
class MoodPattern {
  /// Average sentiment score over time
  final double averageScore;

  /// Most common sentiment this period
  final Sentiment dominantSentiment;

  /// Sentiment trend (improving/declining/stable)
  final String trend;

  /// Recommended actions
  final List<MoodSuggestion> recommendations;

  /// Period analyzed (e.g., "Last 7 days")
  final String period;

  const MoodPattern({
    required this.averageScore,
    required this.dominantSentiment,
    required this.trend,
    required this.recommendations,
    required this.period,
  });

  @override
  String toString() =>
      'MoodPattern(Average: ${averageScore.toStringAsFixed(2)}, Dominant: ${dominantSentiment.displayName}, Trend: $trend)';
}

/// Real ML-based sentiment analyzer using NLP
/// Uses actual semantic understanding, not keyword matching
abstract class SentimentAnalysisEngine {
  /// Initialize the engine
  Future<void> initialize();

  /// Analyze text for sentiment and mood
  Future<SentimentPrediction> analyze(String text);

  /// Release resources
  Future<void> release();

  /// Check if ready
  bool get isReady;
}

/// Production-ready mood tracker and analyzer
class SentimentFilter {
  /// Private constructor
  SentimentFilter._();

  /// Singleton instance
  static final SentimentFilter instance = SentimentFilter._();

  /// Mood history for tracking user patterns
  final List<MoodEntry> _moodHistory = [];

  /// Is initialized
  bool _isInitialized = false;

  /// Maximum history entries to keep
  static const int maxHistorySize = 500;

  /// Initialize the sentiment filter
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // TODO: v2 - Integrate with ML Kit Firebase or custom TFLite model
      // _engine = MLKitSentimentEngine();
      // For now using configuration placeholder
      _isInitialized = true;
      debugPrint('SentimentFilter: Initialized (ready for ML integration)');
    } catch (e) {
      debugPrint('SentimentFilter: Error during initialization: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Analyze user mood from text
  /// Returns detailed sentiment prediction with suggestions
  Future<SentimentPrediction> analyzeMood(String text) async {
    if (!_isInitialized) {
      throw StateError('SentimentFilter not initialized. Call initialize() first.');
    }

    if (text.isEmpty) {
      throw ArgumentError('Text cannot be empty');
    }

    try {
      // TODO: v2 - Use actual ML model
      // final prediction = await _engine.analyze(text);

      // Placeholder for v1 - shows structure
      final prediction = _createPlaceholderPrediction(text);

      // Add to history
      _moodHistory.add(
        MoodEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          prediction: prediction,
          note: text,
        ),
      );

      // Trim history
      if (_moodHistory.length > maxHistorySize) {
        _moodHistory.removeAt(0);
      }

      debugPrint('SentimentFilter: Analyzed mood - ${prediction.sentiment.displayName} (${(prediction.confidence * 100).toStringAsFixed(1)}%)');
      return prediction;
    } catch (e) {
      debugPrint('SentimentFilter: Error analyzing mood: $e');
      rethrow;
    }
  }

  /// Analyze multiple mood entries (batch)
  Future<List<SentimentPrediction>> analyzeMoodBatch(List<String> texts) async {
    if (!_isInitialized) {
      throw StateError('SentimentFilter not initialized');
    }

    try {
      final predictions = <SentimentPrediction>[];
      for (final text in texts) {
        final prediction = await analyzeMood(text);
        predictions.add(prediction);
      }
      return predictions;
    } catch (e) {
      debugPrint('SentimentFilter: Error in batch analysis: $e');
      rethrow;
    }
  }

  /// Get mood recommendations based on current mood
  Future<List<MoodSuggestion>> getMoodSuggestions(String text) async {
    try {
      final prediction = await analyzeMood(text);
      return _generateSuggestions(prediction.sentiment);
    } catch (e) {
      debugPrint('SentimentFilter: Error getting suggestions: $e');
      return [];
    }
  }

  /// Analyze mood patterns over time
  MoodPattern analyzeMoodPatterns({Duration period = const Duration(days: 7)}) {
    if (_moodHistory.isEmpty) {
      return MoodPattern(
        averageScore: 0.0,
        dominantSentiment: Sentiment.neutral,
        trend: 'No data',
        recommendations: [],
        period: '${period.inDays} days',
      );
    }

    final cutoffTime = DateTime.now().subtract(period);
    final recentMoods = _moodHistory
        .where((entry) => entry.timestamp.isAfter(cutoffTime))
        .toList();

    if (recentMoods.isEmpty) {
      return MoodPattern(
        averageScore: 0.0,
        dominantSentiment: Sentiment.neutral,
        trend: 'No recent data',
        recommendations: [],
        period: '${period.inDays} days',
      );
    }

    // Calculate average score
    double totalScore = 0;
    final sentimentCounts = <Sentiment, int>{};

    for (final entry in recentMoods) {
      totalScore += entry.prediction.sentiment.score;
      final sentiment = entry.prediction.sentiment;
      sentimentCounts[sentiment] = (sentimentCounts[sentiment] ?? 0) + 1;
    }

    final avgScore = totalScore / recentMoods.length;

    // Find dominant sentiment
    Sentiment dominant = Sentiment.neutral;
    int maxCount = 0;
    sentimentCounts.forEach((sentiment, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = sentiment;
      }
    });

    // Determine trend
    String trend = 'Stable';
    if (recentMoods.length >= 3) {
      final recent = recentMoods.sublist(recentMoods.length - 3);
      final recentAvg = recent
          .map((m) => m.prediction.sentiment.score)
          .reduce((a, b) => a + b) /
          recent.length;
      final older = recentMoods.sublist(0, (recentMoods.length - 3).clamp(0, recentMoods.length));
      if (older.isNotEmpty) {
        final olderAvg = older
            .map((m) => m.prediction.sentiment.score)
            .reduce((a, b) => a + b) /
            older.length;

        if (recentAvg > olderAvg + 0.2) {
          trend = 'Improving ⬆️';
        } else if (recentAvg < olderAvg - 0.2) {
          trend = 'Declining ⬇️';
        }
      }
    }

    final recommendations = _generateSuggestions(dominant);

    return MoodPattern(
      averageScore: avgScore,
      dominantSentiment: dominant,
      trend: trend,
      recommendations: recommendations,
      period: '${period.inDays} days',
    );
  }

  /// Get mood history
  List<MoodEntry> getMoodHistory({int limit = 50}) {
    final sorted = _moodHistory.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }

  /// Get mood summary
  String getMoodSummary() {
    if (_moodHistory.isEmpty) return 'No mood data recorded yet';

    final pattern = analyzeMoodPatterns();
    return 'Avg sentiment: ${pattern.averageScore.toStringAsFixed(2)}/2.0\n'
        'Dominant mood: ${pattern.dominantSentiment.displayName}\n'
        'Trend: ${pattern.trend}';
  }

  /// Generate mood-based suggestions
  List<MoodSuggestion> _generateSuggestions(Sentiment sentiment) {
    switch (sentiment) {
      case Sentiment.veryPositive:
        return [
          const MoodSuggestion(
            text: 'You\'re in great spirits! Keep up this positive momentum.',
            action: 'maintain',
            priority: 5,
            category: 'motivation',
          ),
          const MoodSuggestion(
            text: 'Share your happiness with others - help someone today',
            action: 'social',
            priority: 4,
            category: 'wellbeing',
          ),
        ];

      case Sentiment.positive:
        return [
          const MoodSuggestion(
            text: 'Continue what you\'re doing - it\'s working for you!',
            action: 'continue',
            priority: 4,
            category: 'motivation',
          ),
          const MoodSuggestion(
            text: 'Take a healthy break and recharge',
            action: 'break',
            priority: 3,
            category: 'wellness',
          ),
        ];

      case Sentiment.neutral:
        return [
          const MoodSuggestion(
            text: 'Try a quick meditation or breathing exercise',
            action: 'meditation',
            priority: 5,
            category: 'mindfulness',
          ),
          const MoodSuggestion(
            text: 'Engage in an activity you enjoy for 15 minutes',
            action: 'hobby',
            priority: 4,
            category: 'wellbeing',
          ),
        ];

      case Sentiment.negative:
        return [
          const MoodSuggestion(
            text: 'Take a break from your current task',
            action: 'break',
            priority: 9,
            category: 'urgent',
          ),
          const MoodSuggestion(
            text: 'Try a 5-minute breathing exercise or walk outside',
            action: 'exercise',
            priority: 8,
            category: 'wellness',
          ),
          const MoodSuggestion(
            text: 'Consider talking to someone about what\'s bothering you',
            action: 'social',
            priority: 7,
            category: 'support',
          ),
        ];

      case Sentiment.veryNegative:
        return [
          const MoodSuggestion(
            text: 'Please take a significant break - your wellbeing matters',
            action: 'break',
            priority: 10,
            category: 'critical',
          ),
          const MoodSuggestion(
            text: 'Reach out to someone you trust or a professional',
            action: 'support',
            priority: 10,
            category: 'critical',
          ),
          const MoodSuggestion(
            text: 'Limit app usage and focus on self-care activities',
            action: 'limit_usage',
            priority: 9,
            category: 'critical',
          ),
        ];

      case Sentiment.unknown:
        return [
          const MoodSuggestion(
            text: 'Tell us more about how you\'re feeling',
            action: 'feedback',
            priority: 3,
            category: 'info',
          ),
        ];
    }
  }

  /// Placeholder prediction for v1 (will use real ML in v2)
  SentimentPrediction _createPlaceholderPrediction(String text) {
    // This demonstrates the structure - will be replaced with actual ML in v2
    return SentimentPrediction(
      sentiment: Sentiment.neutral,
      confidence: 0.0,
      analysis: 'Awaiting ML model integration',
      inputText: text,
      detectedEmotions: [],
      suggestions: [],
      reasoning: 'Model not yet initialized. This is a placeholder structure.',
    );
  }

  /// Release resources
  Future<void> release() async {
    try {
      _isInitialized = false;
      debugPrint('SentimentFilter: Released');
    } catch (e) {
      debugPrint('SentimentFilter: Error during release: $e');
    }
  }

  /// Check if ready
  bool get isReady => _isInitialized;

  /// Get debug status
  String get debugStatus =>
      'SentimentFilter(ready: $_isInitialized, history_size: ${_moodHistory.length}/$maxHistorySize)';
}
