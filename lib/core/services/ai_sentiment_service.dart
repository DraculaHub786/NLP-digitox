// Copyright (c) 2024 NLP digitox

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nlp_digitox/models/usage_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AI Service for sentiment analysis and personalized recommendations
/// Uses Groq API (free tier) for accurate and FAST analysis
class AISentimentService {
  static AISentimentService? _instance;
  static AISentimentService get instance {
    _instance ??= AISentimentService._();
    return _instance!;
  }

  AISentimentService._();

  static const String _apiKey = 'YOUR_GROQ_API_KEY_HERE'; // Get free key at https://console.groq.com/keys
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';

  Map<String, double>? _lastSentiment;
  String? _lastSentimentContext;

  static const String _lastAnalysisKey = 'last_sentiment_analysis';
  static const String _lastAnalysisDateKey = 'last_sentiment_analysis_date';

  /// Get the last sentiment analysis for sharing with chatbot
  Map<String, double>? getLastSentiment() => _lastSentiment;
  String? getLastSentimentContext() => _lastSentimentContext;

  /// Clear sentiment cache (useful for new day or reset)
  void clearSentimentCache() {
    _lastSentiment = null;
    _lastSentimentContext = null;
    debugPrint('AISentimentService: Sentiment cache cleared');
  }

  /// Analyze user's digital wellbeing sentiment based on usage patterns
  /// Returns sentiment percentages: {Positive, Neutral, Negative, Anxious, Focused}
  Future<Map<String, double>> analyzeSentiment({
    required UsageModel todayUsage,
    required int screenTimeGoalSeconds,
    int? streakDays,
    int? habitsCompleted,
    int? tasksCompleted,
  }) async {
    try {
      if (_apiKey.isEmpty || _apiKey.contains('YOUR_')) {
        debugPrint('⚠️ AISentimentService: API key not configured! Returning defaults.');
        return {
          'Positive': 40.0,
          'Neutral': 30.0,
          'Negative': 10.0,
          'Anxious': 10.0,
          'Focused': 10.0,
        };
      }
      
      final prefs = await SharedPreferences.getInstance();
      final lastAnalysisDate = prefs.getString(_lastAnalysisDateKey);
      final now = DateTime.now();
      
      if (lastAnalysisDate != null) {
        final lastDate = DateTime.parse(lastAnalysisDate);
        final minutesSinceLastAnalysis = now.difference(lastDate).inMinutes;
        
        if (minutesSinceLastAnalysis < 30) {
          debugPrint('💾 AISentimentService: Using cached sentiment (${minutesSinceLastAnalysis} minutes old)');
          final cached = prefs.getString(_lastAnalysisKey);
          if (cached != null) {
            final cachedSentiment = _parseSentimentFromCache(cached);
            _lastSentiment = cachedSentiment;
            debugPrint('✅ AISentimentService: Returning cached sentiment: $cachedSentiment');
            return cachedSentiment;
          }
        } else {
          debugPrint('🔄 AISentimentService: Cache expired (${minutesSinceLastAnalysis} minutes old), fetching fresh analysis');
        }
      }

      final screenTimeHours = (todayUsage.screenTime / 3600).toStringAsFixed(1);
      final goalHours = (screenTimeGoalSeconds / 3600).toStringAsFixed(1);
      final goalPercentage = ((todayUsage.screenTime / screenTimeGoalSeconds) * 100).toInt();
      
      final prompt = '''
Analyze the digital wellbeing sentiment of a user based on their smartphone usage patterns today. Provide a psychological assessment.

Usage Data:
- Screen Time: $screenTimeHours hours (Goal: $goalHours hours, $goalPercentage percent of goal)
- Mobile Data: ${(todayUsage.mobileData / 1024).toStringAsFixed(1)} MB
- WiFi Data: ${(todayUsage.wifiData / 1024).toStringAsFixed(1)} MB
- Current Streak: ${streakDays ?? 0} days
- Habits Completed: ${habitsCompleted ?? 0}
- Tasks Completed: ${tasksCompleted ?? 0}

IMPORTANT: Be deterministic - same usage data should produce consistent results.

SCORING GUIDELINES (apply consistently):
1. Screen time under goal: increase Positive and Focused
2. Screen time over 150% of goal: increase Anxious and Negative
3. Streak of 3+ days: increase Positive and Focused
4. Habits completed: increase Positive and Focused
5. Screen time 100-130% of goal: increase Neutral

Respond with ONLY these 5 values (must total 100):
Positive: XX
Neutral: XX
Negative: XX
Anxious: XX
Focused: XX
''';

      debugPrint('🤖 AISentimentService: Calling Groq API for sentiment analysis...');
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': 'You are a deterministic digital wellbeing analyzer. Apply rules consistently. Same input = same output.'},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.1,  // Low temperature for consistency
          'max_tokens': 150,
          'seed': 42,  // Fixed seed for deterministic results
        }),
      );
      
      if (response.statusCode != 200) {
        debugPrint('❌ AISentimentService: API returned error ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        throw Exception('API error: ${response.statusCode}');
      }
      
      final jsonResponse = jsonDecode(response.body);
      final text = jsonResponse['choices'][0]['message']['content'] as String;
      
      debugPrint('📥 AISentimentService: Received response from Groq API');
      debugPrint('Response text: $text');
      
      final sentiments = _parseSentiment(text);
      
      await prefs.setString(_lastAnalysisKey, text);
      await prefs.setString(_lastAnalysisDateKey, now.toIso8601String());
      
      _lastSentiment = sentiments;
      _lastSentimentContext = 'Screen time: $screenTimeHours hrs (goal: $goalHours hrs), Streak: ${streakDays ?? 0} days, Habits: ${habitsCompleted ?? 0}, Tasks: ${tasksCompleted ?? 0}';
      
      debugPrint('✅ AISentimentService: Sentiment analysis completed: $sentiments');
      return sentiments;
      
    } catch (e, stackTrace) {
      debugPrint('❌ AISentimentService: Error analyzing sentiment - $e');
      debugPrint('Stack trace: $stackTrace');
      
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('quota') || errorMsg.contains('limit') || errorMsg.contains('429')) {
        debugPrint('⚠️ API QUOTA/RATE LIMIT ERROR: You may have exceeded the free tier limits.');
        debugPrint('   Solutions:');
        debugPrint('   1. Wait 1 minute and try again (30 requests/minute limit for Groq)');
        debugPrint('   2. Check your usage at https://console.groq.com/');
        debugPrint('   3. Generate a new API key if current one is exhausted');
      } else if (errorMsg.contains('api key') || errorMsg.contains('invalid') || errorMsg.contains('401')) {
        debugPrint('⚠️ INVALID API KEY ERROR: Your Groq API key may be incorrect or disabled.');
        debugPrint('   Get a new key at: https://console.groq.com/keys');
      }
      
      debugPrint('⚠️ Returning default sentiment values due to API error');
      return {
        'Positive': 40.0,
        'Neutral': 30.0,
        'Negative': 10.0,
        'Anxious': 10.0,
        'Focused': 10.0,
      };
    }
  }

  /// Get personalized recommendations based on usage patterns
  Future<List<String>> getRecommendations({
    required UsageModel todayUsage,
    required int screenTimeGoalSeconds,
    required Map<String, double> currentSentiment,
    List<String>? recentChatMessages, // Include chat context for better recommendations
  }) async {
    try {
      // Check if API is properly configured
      if (_apiKey.isEmpty || _apiKey.contains('YOUR_')) {
        debugPrint('⚠️ AISentimentService: API key not configured! Returning default recommendations.');
        return [
          'Take a 5-minute break from your screen',
          'Try focus mode during work hours',
          'Set app timers for social media',
        ];
      }
      
      final screenTimeHours = (todayUsage.screenTime / 3600).toStringAsFixed(1);
      final goalHours = (screenTimeGoalSeconds / 3600).toStringAsFixed(1);
      
      final prompt = '''
As a digital wellbeing AI assistant, provide 3-4 personalized, actionable recommendations for this user based on their usage patterns and emotional state.

Current State:
- Screen Time: $screenTimeHours hours (Goal: $goalHours hours)
- Sentiment: ${currentSentiment.entries.map((e) => '${e.key}: ${e.value.toInt()}%').join(', ')}


Provide 3-4 brief, actionable recommendations (each max 15 words). Format as a simple numbered list:
1. [Recommendation]
2. [Recommendation]
3. [Recommendation]
4. [Recommendation] (optional)

Focus on:
- Specific actions they can take NOW
- Addressing their emotional state
- Helping them meet their goals
- Practical, achievable steps
''';

      debugPrint('🤖 AISentimentService: Calling Groq API for recommendations...');
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': 'You are a digital wellbeing coach. Provide brief, actionable recommendations.'},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.8,
          'max_tokens': 200,
        }),
      );
      
      if (response.statusCode != 200) {
        debugPrint('❌ AISentimentService: API returned error ${response.statusCode}');
        throw Exception('API error: ${response.statusCode}');
      }
      
      final jsonResponse = jsonDecode(response.body);
      final text = jsonResponse['choices'][0]['message']['content'] as String;
      
      debugPrint('📥 AISentimentService: Received recommendations from Groq API');
      
      final recommendations = _parseRecommendations(text);
      
      debugPrint('✅ AISentimentService: Generated ${recommendations.length} recommendations');
      return recommendations;
      
    } catch (e, stackTrace) {
      debugPrint('❌ AISentimentService: Error generating recommendations - $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('⚠️ Returning default recommendations due to API error');
      return [
        'Take a 5-minute break from your screen',
        'Try focus mode during work hours',
        'Set app timers for social media',
      ];
    }
  }

  /// Parse sentiment percentages from AI response
  Map<String, double> _parseSentiment(String text) {
    final Map<String, double> sentiments = {};
    final lines = text.split('\n');
    
    for (final line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length == 2) {
          final sentiment = parts[0].trim();
          final valueStr = parts[1].trim().replaceAll(RegExp(r'[^0-9.]'), '');
          final value = double.tryParse(valueStr);
          
          if (value != null && (sentiment == 'Positive' || sentiment == 'Neutral' || 
              sentiment == 'Negative' || sentiment == 'Anxious' || sentiment == 'Focused')) {
            sentiments[sentiment] = value;
          }
        }
      }
    }
    
    // Normalize to 100% if needed
    final total = sentiments.values.fold(0.0, (sum, val) => sum + val);
    if (total > 0 && (total < 95 || total > 105)) {
      sentiments.updateAll((key, value) => (value / total) * 100);
    }
    
    // Return defaults if parsing failed
    if (sentiments.length < 3) {
      return {
        'Positive': 40.0,
        'Neutral': 30.0,
        'Negative': 10.0,
        'Anxious': 10.0,
        'Focused': 10.0,
      };
    }
    
    return sentiments;
  }

  /// Parse sentiment from cached text
  Map<String, double> _parseSentimentFromCache(String cached) {
    return _parseSentiment(cached);
  }

  /// Parse recommendations from AI response
  List<String> _parseRecommendations(String text) {
    final recommendations = <String>[];
    final lines = text.split('\n');
    
    for (final line in lines) {
      final trimmed = line.trim();
      // Match numbered lists: "1.", "1)", "1 -", etc.
      if (RegExp(r'^\d+[\.\)\-\:]').hasMatch(trimmed)) {
        // Remove the number prefix
        final cleaned = trimmed.replaceFirst(RegExp(r'^\d+[\.\)\-\:]\s*'), '').trim();
        if (cleaned.isNotEmpty && cleaned.length > 10) {
          recommendations.add(cleaned);
        }
      }
    }
    
    // Fallback to simple splitting if parsing failed
    if (recommendations.isEmpty) {
      return text.split('\n')
          .where((line) => line.trim().isNotEmpty && line.length > 15)
          .take(4)
          .toList();
    }
    
    return recommendations.take(4).toList();
  }
}




