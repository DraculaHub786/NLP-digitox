// Copyright (c) 2024 NLP digitox

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nlp_digitox/models/usage_model.dart';
import 'package:nlp_digitox/config/api_keys.dart';

/// AI Service for sentiment analysis and personalized recommendations
/// Uses Groq API (free tier) for accurate and FAST analysis
class AISentimentService {
  static AISentimentService? _instance;
  static AISentimentService get instance {
    _instance ??= AISentimentService._();
    return _instance!;
  }

  AISentimentService._();

  static final String _apiKey = ApiKeys.groqApiKey;
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';
  static const Duration _requestTimeout = Duration(seconds: 15);

  Map<String, double>? _lastSentiment;
  String? _lastSentimentContext;

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
  ///
  /// Phase 3.1: [moodContext] merges MoodService check-ins (self-reported)
  /// into the assessment alongside usage metrics and extracted chat themes.
  /// Weighting: usage metrics > mood check-ins > chat themes.
  Future<Map<String, double>> analyzeSentiment({
    required UsageModel todayUsage,
    required int screenTimeGoalSeconds,
    int? streakDays,
    int? habitsCompleted,
    int? tasksCompleted,
    List<String>? recentChatMessages,
    List<String>? recentIntentSignals,
    List<String>? recentThemes,
    String? moodContext,
  }) async {
    if (_apiKey.isEmpty || _apiKey.contains('YOUR_')) {
      throw Exception('Groq API key is not configured.');
    }

    try {
      final screenTimeHours = (todayUsage.screenTime / 3600).toStringAsFixed(1);
      final goalHours = (screenTimeGoalSeconds / 3600).toStringAsFixed(1);
      final goalPercentage = screenTimeGoalSeconds > 0
          ? ((todayUsage.screenTime / screenTimeGoalSeconds) * 100).toInt()
          : 0;
      final recentChatContext = (recentChatMessages != null && recentChatMessages.isNotEmpty)
          ? recentChatMessages.take(6).map((m) => '- $m').join('\n')
          : 'No recent chat context.';
      final recentIntentContext = (recentIntentSignals != null && recentIntentSignals.isNotEmpty)
          ? recentIntentSignals.take(8).map((s) => '- $s').join('\n')
          : 'No recent app-intent context.';
      final recentThemesContext = (recentThemes != null && recentThemes.isNotEmpty)
          ? recentThemes.take(8).map((m) => '- $m').join('\n')
          : 'No extracted themes yet.';
      final moodBlock = (moodContext != null && moodContext.trim().isNotEmpty)
          ? '$moodContext\n'
          : 'No self-reported mood check-ins.\n';

      final prompt = '''
Analyze the digital wellbeing sentiment of a user based on their smartphone usage patterns today. Provide a psychological assessment.

Usage Data:
- Screen Time: $screenTimeHours hours (Goal: $goalHours hours, $goalPercentage percent of goal)
- Mobile Data: ${(todayUsage.mobileData / 1024).toStringAsFixed(1)} MB
- WiFi Data: ${(todayUsage.wifiData / 1024).toStringAsFixed(1)} MB
- Current Streak: ${streakDays ?? 0} days
- Habits Completed: ${habitsCompleted ?? 0}
- Tasks Completed: ${tasksCompleted ?? 0}

Recent user chat context:
$recentChatContext

Recent app usage intent context:
$recentIntentContext

Recurring themes from the last 30 days of chat (weight these in the assessment):
$recentThemesContext

Self-reported mood check-ins (weight these — the user's own words are the strongest signal of how they feel):
$moodBlock
IMPORTANT: Be deterministic - same usage data should produce consistent results.
IMPORTANT: If the user has self-reported a mood (e.g. Anxious, Stressed, Happy), the check-in should clearly bias the percentages — manual check-ins override keyword guesses from chat history. Otherwise rely on usage + themes.

SCORING GUIDELINES (apply consistently):
1. Screen time under goal: increase Positive and Focused
2. Screen time over 150% of goal: increase Anxious and Negative
3. Streak of 3+ days: increase Positive and Focused
4. Habits completed: increase Positive and Focused
5. Screen time 100-130% of goal: increase Neutral
6. A check-in with average sentiment score ~-0.5 or lower (sad/anxious/stressed): raise Anxious or Negative by 10-15 points
7. A check-in with average sentiment score +0.5 or higher (happy/energized): raise Positive or Focused by 10-15 points

Respond with ONLY these 5 values (must total 100):
Positive: XX
Neutral: XX
Negative: XX
Anxious: XX
Focused: XX
''';

      debugPrint('🤖 AISentimentService: Calling Groq API for sentiment analysis...');

      final response = await http
          .post(
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
          )
          .timeout(_requestTimeout);

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
      rethrow;
    }
  }

  /// Get personalized recommendations based on usage patterns
  ///
  /// Phase 4.1: [avoidTips] = recently-shown tips to not repeat.
  /// Phase 4.3: [avoidTopics] = tips the user marked "not helpful".
  /// Phase 4.2: [themeSuggestion] = specific recurring theme to reference.
  Future<List<String>> getRecommendations({
    required UsageModel todayUsage,
    required int screenTimeGoalSeconds,
    required Map<String, double> currentSentiment,
    List<String>? recentChatMessages, // Include chat context for better recommendations
    List<String>? recentThemes, // Recurring themes from Phase 2 extraction
    List<String>? avoidTips, // Phase 4.1
    List<String>? avoidTopics, // Phase 4.3
    String? themeSuggestion, // Phase 4.2
  }) async {
    if (_apiKey.isEmpty || _apiKey.contains('YOUR_')) {
      throw Exception('Groq API key is not configured.');
    }

    try {
      final screenTimeHours = (todayUsage.screenTime / 3600).toStringAsFixed(1);
      final goalHours = (screenTimeGoalSeconds / 3600).toStringAsFixed(1);
      final recentChatContext = (recentChatMessages != null && recentChatMessages.isNotEmpty)
          ? recentChatMessages.take(6).map((m) => '- $m').join('\n')
          : 'No recent chat context.';
      final recentThemesContext = (recentThemes != null && recentThemes.isNotEmpty)
          ? recentThemes.take(8).map((m) => '- $m').join('\n')
          : 'No extracted themes yet.';
      final avoidTipsContext = (avoidTips != null && avoidTips.isNotEmpty)
          ? avoidTips.take(7).map((m) => '- $m').join('\n')
          : 'None.';
      final avoidTopicsContext = (avoidTopics != null && avoidTopics.isNotEmpty)
          ? avoidTopics.take(5).map((m) => '- $m').join('\n')
          : 'None.';
      final themeSuggestionContext = (themeSuggestion != null && themeSuggestion.trim().isNotEmpty)
          ? 'A recurring theme the user keeps mentioning is "$themeSuggestion". Make at least ONE recommendation specifically about this — directly reference it by name.\n'
          : '';

      final prompt = '''
As a digital wellbeing AI assistant, provide 3-4 personalized, actionable recommendations for this user based on their usage patterns and emotional state.

Current State:
- Screen Time: $screenTimeHours hours (Goal: $goalHours hours)
- Sentiment: ${currentSentiment.entries.map((e) => '${e.key}: ${e.value.toInt()}%').join(', ')}
- Recent chats:
$recentChatContext

Recurring themes from the last 30 days of chat (tie recommendations to these themes where relevant):
$recentThemesContext

Do NOT repeat any of these recently-shown tips (they were already given to this user):
$avoidTipsContext

Avoid these topics entirely — the user marked tips about them as NOT helpful:
$avoidTopicsContext

$themeSuggestionContext
Provide 3-4 brief, actionable recommendations (each max 15 words). Format as a simple numbered list:
1. [Recommendation]
2. [Recommendation]
3. [Recommendation]
4. [Recommendation] (optional)

Focus on:
- Specific actions they can take NOW
- Addressing their emotional state
- Helping them meet their goals
- Referencing the recurring themes (e.g. if work deadlines keep appearing, suggest a concrete work-break tactic)
- Practical, achievable steps
- Each recommendation must be DIFFERENT from everything on the do-not-repeat list
''';

      debugPrint('🤖 AISentimentService: Calling Groq API for recommendations...');

      final response = await http
          .post(
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
          )
          .timeout(_requestTimeout);

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
      rethrow;
    }
  }

  /// Get a funny, mood-based motivational message (separate from serious coaching).
  /// Returns 1-2 sentences of lighthearted encouragement referencing the user's
  /// actual mood, persona, and recent behaviour.
  Future<String> getFunnyMotivation({
    String? persona,
    String? latestMood,
    String? dominantSentiment,
    List<String>? recentChatTopics,
    String? usageContext,
  }) async {
    if (_apiKey.isEmpty || _apiKey.contains('YOUR_')) {
      throw Exception('Groq API key is not configured.');
    }

    try {
      final moodStr = latestMood ?? 'unknown';
      final personaStr = persona ?? 'unknown';
      final sentimentStr = dominantSentiment ?? 'neutral';
      final chatStr = (recentChatTopics != null && recentChatTopics.isNotEmpty)
          ? recentChatTopics.take(3).map((m) => '- $m').join('\n')
          : 'No recent chat.';
      final usageStr = usageContext ?? 'No usage context.';

      final prompt = '''
You are "ditixBot", the snarky-but-loving digital wellbeing sidekick. 
Your job: make the user laugh while still landing an encouraging message.

User context:
- Mood: $moodStr
- Persona: $personaStr
- Dominant AI sentiment: $sentimentStr
- Recent chat topics:
$chatStr
- Screen usage: $usageStr

INSTRUCTIONS (follow strictly):
1. Write exactly ONE sentence (max 20 words).
2. Be FUNNY, not preachy. Use puns, exaggerations, self-deprecating AI humour.
3. Tie the joke to their actual mood/persona/usage — generic jokes are boring.
4. End with genuine encouragement, not sarcasm.
5. Never mention death, depression, or anything dark.
6. If screen time is way over goal, poke gentle fun: "Plot twist: your phone is now your plus-one."
7. If mood is anxious, reassure with absurdity: "Good news: I checked — the WiFi is fine. You can breathe."
8. If they're doing well, celebrate weirdly: "You're out here winning at life. I'm genuinely proud and also slightly intimidated."

Examples of good tone:
- "Your focus streak is impressive. I've alerted the authorities. (Just kidding — you're amazing.)"
- "You've unlocked 'Professional Procrastination Avoider' status. The trophy is a deep breath. You're welcome."
- "I see you're feeling anxious. Relax. I'm the AI — I've seen worse. You've got this."

Respond with ONLY the funny sentence. No prefixes, no labels.
''';

      debugPrint('🤣 AISentimentService: Calling Groq API for funny motivation...');

      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'system', 'content': 'You are a witty, encouraging digital wellbeing sidekick. Short responses only.'},
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.9, // Higher temp for creative humour
              'max_tokens': 80,
            }),
          )
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        debugPrint('❌ AISentimentService: API returned error ${response.statusCode}');
        throw Exception('API error: ${response.statusCode}');
      }

      final jsonResponse = jsonDecode(response.body);
      final text = (jsonResponse['choices'][0]['message']['content'] as String).trim();

      // Clean up quotes the model might wrap around
      final cleaned = text.replaceAll(RegExp("^[\"']|[\"']\$"), '').trim();

      debugPrint('✅ AISentimentService: Got funny motivation: $cleaned');
      return cleaned;

    } catch (e, stackTrace) {
      debugPrint('❌ AISentimentService: Error getting funny motivation - $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
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

    // Treat parse failure as an error to avoid fake fallback sentiment.
    if (sentiments.length < 3) {
      throw FormatException('Failed to parse sentiment response: $text');
    }

    return sentiments;
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
