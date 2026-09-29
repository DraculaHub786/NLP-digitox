// Copyright (c) 2026 NLP digitox

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nlp_digitox/config/api_keys.dart';
import 'package:nlp_digitox/models/ai_analysis_models.dart';
import 'package:nlp_digitox/models/usage_model.dart';

/// AI Service for sentiment analysis and personalized recommendations
/// Uses Groq API (free tier) for accurate and FAST analysis
class AISentimentService {
  static AISentimentService? _instance;
  static AISentimentService get instance {
    _instance ??= AISentimentService._();
    return _instance!;
  }

  AISentimentService._();

  /// Resolved on every read rather than snapshotted.
  ///
  /// This was `static final String _apiKey = ApiKeys.groqApiKey;`, which froze
  /// the value at first access - before `dotenv.load()` had run - so the key
  /// read back empty and every request reported "not configured" even with a
  /// fully populated `.env`.
  static String get _apiKey => ApiKeys.groqApiKey;

  /// One shared message for all three call sites, so the guidance cannot drift
  /// apart again (it previously pointed at a deleted template file).
  static const String _apiKeyNotConfiguredMessage =
      'Groq API key is not configured. Add GROQ_API_KEY to the .env file (or '
      'pass --dart-define=GROQ_API_KEY=...) and restart the app.';

  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'openai/gpt-oss-20b';
  static const Duration _requestTimeout = Duration(seconds: 15);

  /// `openai/gpt-oss-20b` is a *reasoning* model: it always emits reasoning
  /// tokens, and those tokens are charged against the completion budget
  /// rather than added on top of it. The sentiment call used to ask for only
  /// 150 tokens and recommendations for 200, so the entire budget was spent
  /// on internal reasoning and `message.content` came back as an empty
  /// string — which surfaced as `Failed to parse sentiment response:` with
  /// nothing after the colon, and a dashboard with no tips at all. Groq's own
  /// guidance is that the 1024 default is a floor for reasoning models, not a
  /// target. See https://console.groq.com/docs/reasoning.
  static const int _sentimentMaxTokens = 1024;
  static const int _recommendationsMaxTokens = 1024;
  static const int _motivationMaxTokens = 512;

  /// Keeps reasoning short so the answer still fits the budget above and the
  /// extra thinking does not add needless latency to a call the dashboard
  /// waits on. `low`/`medium`/`high` are the only values GPT-OSS accepts.
  static const String _reasoningEffort = 'low';

  /// Pulls `choices[0].message.content` out of a chat-completions payload.
  ///
  /// Throws a [FormatException] naming the call and its `finish_reason` when
  /// the model returned no text. Previously the empty string travelled on to
  /// the sentiment/recommendation parsers, which then reported the opaque
  /// `Failed to parse sentiment response: ` — with nothing after the colon —
  /// so the real cause (the token budget running out, `finish_reason:
  /// length`) was invisible in the logs.
  static String _extractContent(
    Map<String, dynamic> jsonResponse,
    String callLabel,
  ) {
    final choices = jsonResponse['choices'];
    if (choices is List && choices.isNotEmpty && choices.first is Map) {
      final choice = choices.first as Map;
      final message = choice['message'];
      final content = message is Map ? message['content'] : null;
      if (content is String && content.trim().isNotEmpty) return content;

      final finishReason = choice['finish_reason'] ?? 'unknown';
      throw FormatException(
        'Groq returned no text for the $callLabel call '
        '(finish_reason: $finishReason).',
      );
    }
    throw FormatException(
      'Groq returned an unexpected payload for the $callLabel call: '
      '${jsonResponse.keys.join(', ')}',
    );
  }

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

  /// Deterministic, rule-based baseline sentiment computed from daily usage
  /// without any LLM call. Same input always yields the same five labels
  /// (summing to ~100): Positive, Neutral, Negative, Anxious, Focused.
  ///
  /// Rules mirror the Groq prompt's scoring guidelines:
  /// - Screen time under goal boosts Positive/Focused.
  /// - Over 150% of goal boosts Anxious/Negative.
  /// - 100–130% of goal leans Neutral (not Anxious).
  /// - Streak of 3+ days boosts Positive/Focused.
  /// - Completed habits/tasks boost Positive/Focused.
  Map<String, double> computeBaseSentiment({
    required double screenTimeHours,
    required double goalHours,
    required int streakDays,
    required int habitsCompleted,
    required int tasksCompleted,
  }) {
    var positive = 28.0;
    var neutral = 40.0;
    var negative = 12.0;
    var anxious = 10.0;
    var focused = 10.0;

    final ratio = goalHours > 0 ? screenTimeHours / goalHours : 0.0;

    if (ratio < 1.0) {
      final bonus = (1.0 - ratio) * 10;
      positive += bonus;
      focused += bonus;
    } else if (ratio >= 1.5) {
      final penalty = (ratio - 1.5) * 12 + 6;
      anxious += penalty;
      negative += penalty * 0.8;
      positive -= penalty * 0.5;
    } else {
      // 100–130% neutral band — neutral absorbs the pressure instead of
      // tipping into anxious.
      neutral += 6;
      anxious -= 3;
    }

    if (streakDays >= 3) {
      final streakBonus = (streakDays / 3.5).clamp(0.5, 2.0);
      positive += 4 * streakBonus;
      focused += 4 * streakBonus;
    }

    positive += habitsCompleted * 2.0;
    focused += habitsCompleted * 2.0;
    positive += tasksCompleted * 1.0;
    focused += tasksCompleted * 1.0;

    final raw = <String, double>{
      'Positive': positive,
      'Neutral': neutral,
      'Negative': negative,
      'Anxious': anxious,
      'Focused': focused,
    };
    final total = raw.values.fold(0.0, (sum, value) => sum + value);
    return total > 0
        ? raw.map((key, value) => MapEntry(key, (value / total) * 100))
        : raw;
  }

  /// Parse sentiment percentages from an AI response.
  ///
  /// Accepts a JSON object (optionally wrapped in ```json fences) with
  /// case-insensitive key matching, or the legacy Groq line format
  /// ("Positive: 30"). Values are normalized so the five canonical labels
  /// sum to ~100. Throws [FormatException] when fewer than three labels can
  /// be extracted.
  Map<String, double> parseSentiment(String text) {
    final sentiments = <String, double>{};
    final cleaned = text
        .trim()
        .replaceAll(
          RegExp(r'^```(?:json)?\s*|\s*```$', caseSensitive: false),
          '',
        )
        .trim();

    final decoded = _tryDecodeMap(cleaned);
    if (decoded != null) {
      for (final label in kSentimentLabels) {
        final value = _numericValueForKey(decoded, label);
        if (value != null) sentiments[label] = value;
      }
    } else {
      // Legacy "Label: value" line format.
      for (final line in cleaned.split('\n')) {
        if (!line.contains(':')) continue;
        final parts = line.split(':');
        if (parts.length != 2) continue;
        final rawLabel = parts[0].trim();
        final value =
            double.tryParse(parts[1].trim().replaceAll(RegExp(r'[^0-9.]'), ''));
        if (value == null) continue;
        final match = kSentimentLabels
            .where((l) => l.toLowerCase() == rawLabel.toLowerCase())
            .firstOrNull;
        if (match != null) sentiments[match] = value;
      }
    }

    final total = sentiments.values.fold(0.0, (sum, value) => sum + value);
    if (total > 0) {
      sentiments.updateAll((key, value) => (value / total) * 100);
    }

    if (sentiments.length < 3) {
      throw FormatException('Failed to parse sentiment response: $text');
    }
    return sentiments;
  }

  /// Parse recommendations from an AI response.
  ///
  /// Accepts a bare JSON array of strings, an object-wrapped array
  /// ("recommendations"), arrays of {title, description, action} maps
  /// (preferring the most substantive field), or the legacy numbered-list
  /// line format. Throws [FormatException] when nothing usable is found.
  List<String> parseRecommendations(String text) {
    final trimmed = text.trim();
    final recommendations = <String>[];

    final decoded = _tryDecodeJson(trimmed);
    if (decoded != null) {
      Object? raw = decoded;
      if (decoded is Map && decoded['recommendations'] is List) {
        raw = decoded['recommendations'];
      }
      if (raw is List) {
        for (final item in raw) {
          final suggestion = _extractRecommendationText(item);
          if (suggestion != null && suggestion.length > 10) {
            recommendations.add(suggestion);
          }
        }
      }
    }

    if (recommendations.isEmpty) {
      // Legacy numbered-list fallback ("1. Take a walk...").
      for (final line in trimmed.split('\n')) {
        final match =
            RegExp(r'^\s*\d+[\.\)\-\:]\s*(.{11,})').firstMatch(line);
        if (match != null) {
          recommendations.add(match.group(1)!.trim());
        }
      }
    }

    if (recommendations.isEmpty) {
      throw FormatException('Failed to parse recommendations: $text');
    }
    return recommendations.take(4).toList();
  }

  /// Analyze user's digital wellbeing sentiment based on usage patterns
  /// Returns sentiment percentages: {Positive, Neutral, Negative, Anxious, Focused}
  Future<Map<String, double>> analyzeSentiment({
    required UsageModel todayUsage,
    required int screenTimeGoalSeconds,
    int? streakDays,
    int? habitsCompleted,
    int? tasksCompleted,
    List<String>? recentChatMessages,
    List<String>? recentIntentSignals,
    List<String>? recentChatThemes,
    String? moodContextBlock,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception(_apiKeyNotConfiguredMessage);
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
      // Recurring themes extracted locally (keyword/topic frequency, no
      // extra LLM call — see ChatContextExtractor) across the full 30-day
      // chat retention window, not just the last few messages of the
      // current session. Gives the LLM a sense of what the user has been
      // talking about lately, not just right now.
      final chatThemesContext = (recentChatThemes != null && recentChatThemes.isNotEmpty)
          ? recentChatThemes.take(8).map((t) => '- $t').join('\n')
          : 'No recurring chat themes yet.';
      final moodBlock = (moodContextBlock != null && moodContextBlock.trim().isNotEmpty)
          ? moodContextBlock
          : 'No mood check-ins recorded.';

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

Recurring chat themes over the last 30 days:
$chatThemesContext

$moodBlock

Recent app usage intent context:
$recentIntentContext

IMPORTANT: Be deterministic - same usage data should produce consistent results.

SCORING GUIDELINES (apply consistently):
1. Screen time under goal: increase Positive and Focused
2. Screen time over 150% of goal: increase Anxious and Negative
3. Streak of 3+ days: increase Positive and Focused
4. Habits completed: increase Positive and Focused
5. Screen time 100-130% of goal: increase Neutral
6. Self-reported mood check-ins (if present) should outweigh keyword-derived
   chat themes when the two disagree — they are the user's own words.
7. Recurring chat themes are supporting context, not a primary signal —
   use them to nudge Anxious/Negative/Positive/Focused, not to override the
   objective usage-metric scoring above.

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
              'max_tokens': _sentimentMaxTokens,
              // Reasoning tokens are charged against max_tokens, so without
              // this the model can think its way through the entire budget
              // and return an empty answer.
              'reasoning_effort': _reasoningEffort,
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
      final text = _extractContent(jsonResponse, 'sentiment analysis');
      
      debugPrint('📥 AISentimentService: Received response from Groq API');
      debugPrint('Response text: $text');
      
      final sentiments = parseSentiment(text);
      
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
  Future<List<String>> getRecommendations({
    required UsageModel todayUsage,
    required int screenTimeGoalSeconds,
    required Map<String, double> currentSentiment,
    List<String>? recentChatMessages, // Include chat context for better recommendations
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception(_apiKeyNotConfiguredMessage);
    }

    try {
      final screenTimeHours = (todayUsage.screenTime / 3600).toStringAsFixed(1);
      final goalHours = (screenTimeGoalSeconds / 3600).toStringAsFixed(1);
      final recentChatContext = (recentChatMessages != null && recentChatMessages.isNotEmpty)
          ? recentChatMessages.take(6).map((m) => '- $m').join('\n')
          : 'No recent chat context.';
      
      final prompt = '''
As a digital wellbeing AI assistant, provide 3-4 personalized, actionable recommendations for this user based on their usage patterns and emotional state.

Current State:
- Screen Time: $screenTimeHours hours (Goal: $goalHours hours)
- Sentiment: ${currentSentiment.entries.map((e) => '${e.key}: ${e.value.toInt()}%').join(', ')}
- Recent chats:
$recentChatContext


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
              'max_tokens': _recommendationsMaxTokens,
              'reasoning_effort': _reasoningEffort,
            }),
          )
          .timeout(_requestTimeout);
      
      if (response.statusCode != 200) {
        debugPrint('❌ AISentimentService: API returned error ${response.statusCode}');
        throw Exception('API error: ${response.statusCode}');
      }
      
      final jsonResponse = jsonDecode(response.body);
      final text = _extractContent(jsonResponse, 'recommendations');
      
      debugPrint('📥 AISentimentService: Received recommendations from Groq API');
      
      final recommendations = parseRecommendations(text);
      
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
    if (_apiKey.isEmpty) {
      throw Exception(_apiKeyNotConfiguredMessage);
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
              'max_tokens': _motivationMaxTokens,
              'reasoning_effort': _reasoningEffort,
            }),
          )
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        debugPrint('❌ AISentimentService: API returned error ${response.statusCode}');
        throw Exception('API error: ${response.statusCode}');
      }

      final jsonResponse = jsonDecode(response.body);
      final text = _extractContent(jsonResponse, 'funny motivation').trim();

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

  /// Deterministic, rule-based recommendations derived from the day's usage
  /// and sentiment — no LLM call.
  ///
  /// This is the safety net behind [getRecommendations]: if the Groq call
  /// fails for any reason (offline, rate limited, key missing), the dashboard
  /// still shows advice that is about *this* user's day rather than the same
  /// three canned strings for everybody. Rules mirror the sentiment
  /// guidelines in [computeBaseSentiment].
  List<String> computeBaseRecommendations({
    required double screenTimeHours,
    required double goalHours,
    required Map<String, double> sentiment,
    int screenTimeGoalSeconds = 0,
  }) {
    final ratio = goalHours > 0 ? screenTimeHours / goalHours : 0.0;
    final dominant = sentiment.isEmpty
        ? 'Neutral'
        : sentiment.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    final recommendations = <String>[];

    if (ratio >= 1.5) {
      recommendations.add(
        'You are at ${(ratio * 100).round()}% of your screen time goal — '
        'put the phone face-down for the next hour.',
      );
    } else if (ratio >= 1.0) {
      recommendations.add(
        'You are just over your screen time goal. Close one app you did not '
        'actually need today.',
      );
    } else if (screenTimeGoalSeconds > 0) {
      recommendations.add(
        'You are inside your screen time goal — keep this pace for the rest '
        'of the day.',
      );
    }

    switch (dominant) {
      case 'Anxious':
        recommendations.add(
          'Try a two-minute breathing pause before your next scroll — '
          'notifications can wait.',
        );
      case 'Negative':
        recommendations.add(
          'Pick one small win right now, like clearing a single task, to '
          'break the slump.',
        );
      case 'Focused':
        recommendations.add(
          'Your focus is high — protect it by silencing non-essential '
          'notifications for the next hour.',
        );
      case 'Positive':
        recommendations.add(
          'You are in a good place — bank it by finishing one habit you '
          'usually skip.',
        );
      default:
        recommendations.add(
          'Set one concrete goal for the next 20 minutes and start a focus '
          'session.',
        );
    }

    recommendations.add(
      'Take a short screen-free break — stand up, look away, and reset '
      'before the next block of work.',
    );

    return recommendations.take(4).toList();
  }

  // ── JSON parsing helpers (public parse methods) ─────────────────────

  /// Decode [source] as a JSON map, returning null when it isn't one.
  Map<String, dynamic>? _tryDecodeMap(String source) {
    final decoded = _tryDecodeJson(source);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  /// Decode [source] as JSON (map or list), stripping surrounding markers.
  Object? _tryDecodeJson(String source) {
    var candidate = source.trim();
    if (candidate.startsWith('{') || candidate.startsWith('[')) {
      try {
        return jsonDecode(candidate);
      } catch (_) {
        return null;
      }
    }
    // Some models wrap JSON in prose or code fences.
    final fenced = RegExp(r'```(?:json)?\s*(.*?)\s*```', dotAll: true)
        .firstMatch(candidate);
    if (fenced != null) {
      try {
        return jsonDecode(fenced.group(1)!);
      } catch (_) {
        return null;
      }
    }
    final jsonStart = candidate.indexOf(RegExp(r'[\[{]'));
    if (jsonStart >= 0) {
      final slice = candidate.substring(jsonStart);
      final jsonEnd =
          slice.lastIndexOf(slice.startsWith('[') ? ']' : '}');
      if (jsonEnd >= 0) {
        try {
          return jsonDecode(slice.substring(0, jsonEnd + 1));
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  /// Case-insensitively look up a numeric value for [label] in [map].
  double? _numericValueForKey(Map<String, dynamic> map, String label) {
    for (final entry in map.entries) {
      if (entry.key.toLowerCase() != label.toLowerCase()) continue;
      if (entry.value is num) return (entry.value as num).toDouble();
      final parsed = double.tryParse(entry.value.toString().trim());
      if (parsed != null) return parsed;
    }
    return null;
  }

  /// Extract the most substantive piece of text from a recommendation item
  /// (string, or a {title, description, action} map) preferring
  /// description > title > action, in that order.
  String? _extractRecommendationText(Object? item) {
    if (item is String) return item.trim();
    if (item is Map) {
      String pick(String key) =>
          item[key] is String ? (item[key] as String).trim() : '';
      final description = pick('description');
      if (description.length > 10) return description;
      final title = pick('title');
      if (title.length > 10) return title;
      final action = pick('action');
      if (action.length > 10) return action;
    }
    return null;
  }

  /// Tests only whether [_apiKey] itself is valid - independent of which
  /// model is configured. 200 = key works, 401 = key is bad/revoked,
  /// anything else = network/Groq-side issue.
  static Future<ApiKeyStatus> testApiKey() async {
    if (_apiKey.isEmpty) return ApiKeyStatus.notConfigured;
    try {
      final response = await http.get(
        Uri.parse('https://api.groq.com/openai/v1/models'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      if (response.statusCode == 200) return ApiKeyStatus.valid;
      if (response.statusCode == 401) return ApiKeyStatus.invalid;
      return ApiKeyStatus.unknownError;
    } catch (e) {
      debugPrint('❌ AISentimentService.testApiKey: $e');
      return ApiKeyStatus.networkError;
    }
  }

  /// Tests whether the configured model [_model] is available and responding.
  /// Makes a minimal chat completion request to verify the model works.
  /// Returns true if model responds successfully, false otherwise.
  static Future<bool> testModel() async {
    if (_apiKey.isEmpty) {
      debugPrint('⚠️ AISentimentService.testModel: API key not configured');
      return false;
    }
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': 'test'}
          ],
          'max_tokens': 1,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint('✅ AISentimentService.testModel: Model \'$_model\' is available and responding');
        return true;
      } else if (response.statusCode == 404) {
        debugPrint('❌ AISentimentService.testModel: Model \'$_model\' NOT FOUND (404). Check available models at https://console.groq.com/docs/models');
        return false;
      } else if (response.statusCode == 401) {
        debugPrint('❌ AISentimentService.testModel: Invalid API key (401)');
        return false;
      } else {
        debugPrint('⚠️ AISentimentService.testModel: Model request failed with status ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ AISentimentService.testModel: Error - $e');
      return false;
    }
  }
}

/// Tests only whether the Groq API key is valid - independent of which
/// model is configured.
enum ApiKeyStatus { valid, invalid, notConfigured, networkError, unknownError }
