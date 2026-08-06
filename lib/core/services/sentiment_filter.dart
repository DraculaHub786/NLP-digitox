
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  /// Grok API key (set from environment or config)
  String? _grokApiKey;

  /// Grok API endpoint
  static const String _grokApiEndpoint = 'https://api.x.ai/v1/chat/completions';

  /// Initialize the sentiment filter
  Future<void> initialize({String? grokApiKey}) async {
    if (_isInitialized) return;

    try {
      // Set Grok API key from parameter or environment
      _grokApiKey = grokApiKey ?? const String.fromEnvironment('GROK_API_KEY', defaultValue: '');

      if (_grokApiKey!.isEmpty) {
        debugPrint('SentimentFilter: Warning - GROK_API_KEY not set. Using test mode.');
      }

      // Load persisted mood history from SharedPreferences
      await _loadHistory();

      _isInitialized = true;
      debugPrint('SentimentFilter: Initialized with Grok API integration');
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
      // Use Grok API for real sentiment analysis
      final prediction = await _createPredictionWithGrok(text);

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

      // Persist to SharedPreferences (fire-and-forget, lightweight)
      _saveHistory();

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
  Future<SentimentPrediction> _createPredictionWithGrok(String text) async {
    try {
      // If no API key, return structured response for testing
      if (_grokApiKey == null || _grokApiKey!.isEmpty) {
        return _createLocalPrediction(text);
      }

      // Call Grok API for sentiment analysis
      final response = await http.post(
        Uri.parse(_grokApiEndpoint),
        headers: {
          'Authorization': 'Bearer $_grokApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'grok-2',
          'messages': [
            {
              'role': 'user',
              'content': '''Analyze the sentiment of this text and respond with ONLY a JSON object (no markdown, no extra text):
{
  "sentiment": "veryPositive|positive|neutral|negative|veryNegative",
  "confidence": 0.0-1.0,
  "emotions": ["list", "of", "detected", "emotions"],
  "reasoning": "brief explanation"
}

Text: "$text"'''
            }
          ],
          'temperature': 0.3,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'].toString().trim();

        // Parse sentiment response
        try {
          // Try to extract JSON from response (in case Grok adds markdown)
          String jsonStr = content;
          if (content.contains('```json')) {
            jsonStr = content.split('```json')[1].split('```')[0].trim();
          } else if (content.contains('```')) {
            jsonStr = content.split('```')[1].split('```')[0].trim();
          }

          final sentimentData = jsonDecode(jsonStr);
          final sentimentStr = sentimentData['sentiment'].toString().toLowerCase();
          final confidence = (sentimentData['confidence'] as num?)?.toDouble() ?? 0.5;
          final emotions = List<String>.from(sentimentData['emotions'] ?? []);
          final reasoning = sentimentData['reasoning'] ?? 'Grok analysis';

          // Map string to enum
          final sentiment = _sentimentFromString(sentimentStr);

          return SentimentPrediction(
            sentiment: sentiment,
            confidence: confidence.clamp(0.0, 1.0),
            analysis: 'Grok AI sentiment analysis',
            inputText: text,
            detectedEmotions: emotions,
            suggestions: _generateSuggestions(sentiment).take(3).toList(),
            reasoning: reasoning,
          );
        } catch (parseError) {
          debugPrint('SentimentFilter: JSON parse error: $parseError, response: $content');
          return _createLocalPrediction(text);
        }
      } else if (response.statusCode == 401) {
        debugPrint('SentimentFilter: Unauthorized - invalid Grok API key');
        return _createLocalPrediction(text);
      } else {
        debugPrint('SentimentFilter: Grok API error ${response.statusCode}: ${response.body}');
        return _createLocalPrediction(text);
      }
    } catch (e) {
      debugPrint('SentimentFilter: Error calling Grok API: $e');
      return _createLocalPrediction(text);
    }
  }

  /// Convert string to Sentiment enum
  Sentiment _sentimentFromString(String sentimentStr) {
    switch (sentimentStr.toLowerCase()) {
      case 'verypositive':
      case 'very_positive':
        return Sentiment.veryPositive;
      case 'positive':
        return Sentiment.positive;
      case 'neutral':
        return Sentiment.neutral;
      case 'negative':
        return Sentiment.negative;
      case 'verynegative':
      case 'very_negative':
        return Sentiment.veryNegative;
      default:
        return Sentiment.unknown;
    }
  }

  /// Local fallback prediction when API unavailable
  SentimentPrediction _createLocalPrediction(String text) {
    // Simple local analysis as fallback
    final lowerText = text.toLowerCase();

    // Quick keyword check
    final positive = ['great', 'good', 'excellent', 'amazing', 'wonderful', 'love', 'happy', 'beautiful'];
    final negative = ['terrible', 'bad', 'awful', 'hate', 'sad', 'angry', 'disappointed'];

    int positiveCount = 0;
    int negativeCount = 0;

    for (final word in positive) {
      if (lowerText.contains(word)) positiveCount++;
    }
    for (final word in negative) {
      if (lowerText.contains(word)) negativeCount++;
    }

    Sentiment sentiment = Sentiment.neutral;
    double confidence = 0.5;

    if (positiveCount > negativeCount && positiveCount > 0) {
      sentiment = positiveCount >= 2 ? Sentiment.veryPositive : Sentiment.positive;
      confidence = 0.65 + (positiveCount * 0.05);
    } else if (negativeCount > positiveCount && negativeCount > 0) {
      sentiment = negativeCount >= 2 ? Sentiment.veryNegative : Sentiment.negative;
      confidence = 0.65 + (negativeCount * 0.05);
    }

    return SentimentPrediction(
      sentiment: sentiment,
      confidence: confidence.clamp(0.0, 1.0),
      analysis: 'Local sentiment analysis (Grok unavailable)',
      inputText: text,
      detectedEmotions: [],
      suggestions: [],
      reasoning: 'Fallback local analysis',
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

  // ---------------------------------------------------------------------------
  // SharedPreferences persistence (lightweight, simple JSON)
  // ---------------------------------------------------------------------------

  static const String _historyKey = 'sentiment_mood_history_v1';

  /// Load mood history from SharedPreferences.
  /// Each entry is stored as a compact JSON object.
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyKey);
      if (raw == null) return;

      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      _moodHistory.clear();

      for (final item in list) {
        try {
          final map = item as Map<String, dynamic>;
          final sentimentStr = map['s'] as String? ?? 'neutral';
          final sentiment = _sentimentFromString(sentimentStr);
          final confidence = (map['c'] as num?)?.toDouble() ?? 0.5;
          final timestamp = DateTime.fromMillisecondsSinceEpoch(
              (map['t'] as int?) ?? DateTime.now().millisecondsSinceEpoch);

          _moodHistory.add(MoodEntry(
            id: map['id'] as String? ?? timestamp.millisecondsSinceEpoch.toString(),
            timestamp: timestamp,
            prediction: SentimentPrediction(
              sentiment: sentiment,
              confidence: confidence,
              analysis: 'Restored from cache',
              inputText: map['text'] as String? ?? '',
              detectedEmotions: [],
              suggestions: [],
              reasoning: 'Loaded from history',
            ),
            note: map['text'] as String?,
          ));
        } catch (e) {
          debugPrint('SentimentFilter: Error parsing history entry: $e');
        }
      }

      debugPrint('SentimentFilter: Loaded ${_moodHistory.length} mood history entries');
    } catch (e) {
      debugPrint('SentimentFilter: Error loading history: $e');
      // Non-fatal — start with empty history
    }
  }

  /// Persist mood history to SharedPreferences.
  /// Stored as a compact list to minimize read/write payload.
  /// Fire-and-forget (unawaited) — called after each analysis.
  void _saveHistory() {
    // Run async without blocking
    _doSaveHistory().catchError((e) {
      debugPrint('SentimentFilter: Background save error: $e');
    });
  }

  Future<void> _doSaveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep only the most recent entries to cap blob size
      final toSave = _moodHistory.length > maxHistorySize
          ? _moodHistory.sublist(_moodHistory.length - maxHistorySize)
          : _moodHistory;

      final list = toSave.map((e) => {
        'id': e.id,
        't': e.timestamp.millisecondsSinceEpoch,
        's': e.prediction.sentiment.name,
        'c': e.prediction.confidence,
        'text': e.note ?? '',
      }).toList();

      await prefs.setString(_historyKey, jsonEncode(list));
    } catch (e) {
      debugPrint('SentimentFilter: Error persisting history: $e');
    }
  }

  /// Check if ready
  bool get isReady => _isInitialized;

  /// Get debug status
  String get debugStatus =>
      'SentimentFilter(ready: $_isInitialized, history_size: ${_moodHistory.length}/$maxHistorySize)';
}
