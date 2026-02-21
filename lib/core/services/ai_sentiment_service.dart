/*
 *
 *  * Copyright (c) 2024 NLP digitox
 *  * Author : Afjal Ansari
 *  *
 *  * This source code is licensed under the GPL-2.0 license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:nlp_digitox/models/usage_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AI Service for sentiment analysis and personalized recommendations
/// Uses Google Gemini AI (free tier) for accurate analysis
class AISentimentService {
  // Singleton pattern
  static AISentimentService? _instance;
  static AISentimentService get instance {
    _instance ??= AISentimentService._();
    return _instance!;
  }

  AISentimentService._() {
    _initializeAI();
    _testAPIConnection();
  }

  // Google Gemini API key - Get your free API key from: https://makersuite.google.com/app/apikey
  static const String _apiKey = 'AIzaSyAJSA_tbqeaSz6Tj-IsIQ1v00Ed7QPSd14'; // Replace with your actual API key
  
  late GenerativeModel _model;
  ChatSession? _sharedChatSession; // Shared with chatbot for context

  // Cache keys
  static const String _lastAnalysisKey = 'last_sentiment_analysis';
  static const String _lastAnalysisDateKey = 'last_sentiment_analysis_date';

  void _initializeAI() {
    try {
      if (_apiKey.isEmpty || _apiKey.contains('YOUR_')) {
        debugPrint('⚠️ AISentimentService: Invalid API key! Please set up your Gemini API key.');
        return;
      }
      _model = GenerativeModel(
        model: 'gemini-1.5-flash', // Free tier model
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
      );
      debugPrint('✅ AISentimentService: Initialized successfully with API key');
    } catch (e) {
      debugPrint('❌ AISentimentService: Error initializing - $e');
    }
  }

  /// Test API connection to verify key is working
  Future<void> _testAPIConnection() async {
    try {
      if (_apiKey.isEmpty || _apiKey.contains('YOUR_')) {
        debugPrint('⚠️ AISentimentService: Skipping API test - no valid key');
        return;
      }
      
      debugPrint('🧪 AISentimentService: Testing API connection...');
      final testResponse = await _model.generateContent([
        Content.text('Respond with OK if you can read this')
      ]);
      
      if (testResponse.text != null && testResponse.text!.isNotEmpty) {
        debugPrint('✅ AISentimentService: API connection successful! Response: ${testResponse.text}');
      } else {
        debugPrint('⚠️ AISentimentService: API responded but with empty content');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ AISentimentService: API connection test failed!');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('💡 Please check:');
      debugPrint('   1. Your API key is valid: https://makersuite.google.com/app/apikey');
      debugPrint('   2. Your device has internet connection');
      debugPrint('   3. The Gemini API is enabled for your key');
    }
  }

  /// Get or create shared chat session for collaborative AI
  ChatSession _getSharedChatSession() {
    _sharedChatSession ??= _model.startChat(history: []);
    return _sharedChatSession!;
  }

  /// Clear chat history (useful for new day or reset)
  void clearChatHistory() {
    _sharedChatSession = null;
    debugPrint('AISentimentService: Chat history cleared');
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
      // Check if API is properly configured
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
      
      // Check if we need to update analysis (once per 6 hours)
      final prefs = await SharedPreferences.getInstance();
      final lastAnalysisDate = prefs.getString(_lastAnalysisDateKey);
      final now = DateTime.now();
      
      if (lastAnalysisDate != null) {
        final lastDate = DateTime.parse(lastAnalysisDate);
        if (now.difference(lastDate).inHours < 6) {
          // Return cached analysis
          final cached = prefs.getString(_lastAnalysisKey);
          if (cached != null) {
            return _parseSentimentFromCache(cached);
          }
        }
      }

      // Prepare usage context
      final screenTimeHours = (todayUsage.screenTime / 3600).toStringAsFixed(1);
      final goalHours = (screenTimeGoalSeconds / 3600).toStringAsFixed(1);
      final goalPercentage = ((todayUsage.screenTime / screenTimeGoalSeconds) * 100).toInt();
      
      final prompt = '''
Analyze the digital wellbeing sentiment of a user based on their smartphone usage patterns today. Provide a psychological assessment.

Usage Data:
- Screen Time: $screenTimeHours hours (Goal: $goalHours hours, ${goalPercentage}% of goal)
- Mobile Data: ${(todayUsage.mobileData / 1024).toStringAsFixed(1)} MB
- WiFi Data: ${(todayUsage.wifiData / 1024).toStringAsFixed(1)} MB
- Current Streak: ${streakDays ?? 0} days
- Habits Completed: ${habitsCompleted ?? 0}
- Tasks Completed: ${tasksCompleted ?? 0}

Analyze the user's sentiment and respond with ONLY 5 percentage values (must add up to 100%) in this exact format:
Positive: XX
Neutral: XX
Negative: XX
Anxious: XX
Focused: XX

Consider:
- Is screen time within healthy limits?
- Is the user maintaining good productivity habits?
- Are they showing signs of digital anxiety or balance?
- Do their patterns suggest focus or distraction?
''';

      debugPrint('🤖 AISentimentService: Calling Gemini API for sentiment analysis...');
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      
      debugPrint('📥 AISentimentService: Received response from API');
      debugPrint('Response text: $text');
      
      // Parse sentiment percentages from AI response
      final sentiments = _parseSentiment(text);
      
      // Cache the result
      await prefs.setString(_lastAnalysisKey, text);
      await prefs.setString(_lastAnalysisDateKey, now.toIso8601String());
      
      // Update shared chat session with this analysis
      _getSharedChatSession();
      
      debugPrint('✅ AISentimentService: Sentiment analysis completed: $sentiments');
      return sentiments;
      
    } catch (e, stackTrace) {
      debugPrint('❌ AISentimentService: Error analyzing sentiment - $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('⚠️ Returning default sentiment values due to API error');
      // Return default sentiment on error
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
      
      // Build chat context if available
      String chatContext = '';
      if (recentChatMessages != null && recentChatMessages.isNotEmpty) {
        chatContext = '\n\nRecent User Conversations:\n${recentChatMessages.join('\n')}';
      }
      
      final prompt = '''
As a digital wellbeing AI assistant, provide 3-4 personalized, actionable recommendations for this user based on their usage patterns and emotional state.

Current State:
- Screen Time: $screenTimeHours hours (Goal: $goalHours hours)
- Sentiment: ${currentSentiment.entries.map((e) => '${e.key}: ${e.value.toInt()}%').join(', ')}
$chatContext

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

      debugPrint('🤖 AISentimentService: Calling Gemini API for recommendations...');
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      
      debugPrint('📥 AISentimentService: Received recommendations from API');
      
      // Parse recommendations
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

  /// Send sentiment context to the shared chat session
  /// This allows the chatbot to be aware of the user's emotional state
  Future<void> shareSentimentWithChat(Map<String, double> sentiment, String context) async {
    try {
      final session = _getSharedChatSession();
      
      final prompt = '''
[System Context Update - Do not respond to this]
User's current emotional sentiment analysis:
${sentiment.entries.map((e) => '${e.key}: ${e.value.toInt()}%').join(', ')}

Context: $context

Remember this for our conversation to provide more empathetic and contextual responses.
''';
      
      await session.sendMessage(Content.text(prompt));
      debugPrint('AISentimentService: Sentiment shared with chatbot');
    } catch (e) {
      debugPrint('AISentimentService: Error sharing sentiment with chat - $e');
    }
  }
}
