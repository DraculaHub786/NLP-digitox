// Copyright (c) 2024 NLP digitox

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nlp_digitox/models/usage_model.dart';
import 'package:nlp_digitox/config/api_keys.dart';

/// AI Service for sentiment analysis and personalized recommendations
/// Uses Groq API (free tier) for accurate and FAST analysis
///
/// PART K / L (TODO): sentiment scoring is now split in two —
///   1. A deterministic, local-only base score (`computeBaseSentiment`) that
///      mirrors the SCORING GUIDELINES that used to live inside the LLM
///      prompt. Pure arithmetic, no network, always sums to ~100.
///   2. A small, JSON-only LLM call that ONLY nudges the base percentages
///      based on self-reported mood check-ins and chat context. If there is
///      no mood/chat context at all, the LLM call is skipped entirely.
///
/// PART M (TODO): recommendations are hardened the same way — the LLM is
/// asked for a strict JSON array of 4 strings via `response_format:
/// json_object` (with max_tokens bumped for margin), and parsing goes
/// through `jsonDecode` directly instead of regex-matching numbered lines.
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

  /// PART K — deterministic, local-only sentiment scoring.
  ///
  /// Replicates the SCORING GUIDELINES that were previously embedded in the
  /// LLM prompt as plain Dart arithmetic. This is the baseline that the LLM
  /// (when called) may only nudge slightly based on mood/chat context.
  ///
  /// Returns {Positive, Neutral, Negative, Anxious, Focused} percentages that
  /// always normalize to ~100.
  Map<String, double> computeBaseSentiment({
    required double screenTimeHours,
    required double goalHours,
    required int streakDays,
    required int habitsCompleted,
    required int tasksCompleted,
  }) {
    double positive = 40, neutral = 30, negative = 10, anxious = 10, focused = 10;
    final goalPct = goalHours > 0 ? (screenTimeHours / goalHours) * 100 : 0;

    // Rule 1/5: under goal → Positive/Focused; 100-130% → Neutral;
    // over 150% → Anxious/Negative.
    if (goalPct < 100) {
      positive += 10;
      focused += 10;
    } else if (goalPct > 150) {
      anxious += 10;
      negative += 10;
    } else if (goalPct >= 100 && goalPct <= 130) {
      neutral += 10;
    }

    // Rule 3: streak of 3+ days → Positive/Focused.
    if (streakDays >= 3) {
      positive += 8;
      focused += 8;
    }

    // Rule 4: habits completed → Positive/Focused.
    if (habitsCompleted > 0) {
      positive += 5;
      focused += 5;
    }

    // Gentle encouragement signal for a productive day — encourage rather
    // than punish, so it stays small and never dominates the other rules.
    if (tasksCompleted >= 5) {
      positive += 3;
      focused += 3;
    }

    // Normalize to 100.
    final total = positive + neutral + negative + anxious + focused;
    return {
      'Positive': (positive / total) * 100,
      'Neutral': (neutral / total) * 100,
      'Negative': (negative / total) * 100,
      'Anxious': (anxious / total) * 100,
      'Focused': (focused / total) * 100,
    };
  }

  /// Analyze user's digital wellbeing sentiment based on usage patterns.
  ///
  /// Returns sentiment percentages: {Positive, Neutral, Negative, Anxious, Focused}.
  ///
  /// PART K/L: the deterministic base score is computed locally first. The
  /// Groq LLM is ONLY called when there is real mood/chat context worth
  /// adjusting for; the LLM receives the base score as JSON and returns a
  /// small JSON nudge. On days with no chat/mood activity this method returns
  /// the computed base instantly with zero network calls.
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
      final screenTimeH = todayUsage.screenTime / 3600;
      final goalH = screenTimeGoalSeconds / 3600;
      final screenTimeHours = screenTimeH.toStringAsFixed(1);
      final goalHours = goalH.toStringAsFixed(1);

      // PART K: deterministic base scoring — no LLM needed for this part.
      final baseSentiment = computeBaseSentiment(
        screenTimeHours: screenTimeH,
        goalHours: goalH,
        streakDays: streakDays ?? 0,
        habitsCompleted: habitsCompleted ?? 0,
        tasksCompleted: tasksCompleted ?? 0,
      );

      final contextSummary =
          'Screen time: $screenTimeHours hrs (goal: $goalHours hrs), '
          'Streak: ${streakDays ?? 0} days, Habits: ${habitsCompleted ?? 0}, '
          'Tasks: ${tasksCompleted ?? 0}';

      // PART L.5: skip the API call entirely when there is no meaningful
      // mood/chat context to adjust for. Note: the mood bridge returns a
      // non-empty "No mood check-ins recorded." placeholder when there is no
      // mood data, so a real mood signal must exclude that placeholder.
      final hasMoodContext = moodContext != null &&
          moodContext.trim().isNotEmpty &&
          !moodContext.contains('No mood check-ins') &&
          !moodContext.contains('No self-reported mood');
      final hasChatContext =
          recentChatMessages != null && recentChatMessages.isNotEmpty;
      final hasThemes = recentThemes != null && recentThemes.isNotEmpty;
      final hasIntentContext =
          recentIntentSignals != null && recentIntentSignals.isNotEmpty;
      final hasNudgeContext =
          hasMoodContext || hasChatContext || hasThemes || hasIntentContext;

      if (!hasNudgeContext) {
        _lastSentiment = baseSentiment;
        _lastSentimentContext = contextSummary;
        debugPrint('⏭️ AISentimentService: No mood/chat context — using deterministic base sentiment (no API call): $baseSentiment');
        return baseSentiment;
      }

      final moodBlock = hasMoodContext
          ? moodContext.trim()
          : 'No self-reported mood check-ins.';
      final recentChatContext = hasChatContext
          ? recentChatMessages.take(6).map((m) => '- $m').join('\n')
          : 'No recent chat messages.';
      final recentThemesContext = hasThemes
          ? recentThemes.take(8).map((m) => '- $m').join('\n')
          : 'No recurring chat themes.';
      final recentIntentContext = hasIntentContext
          ? recentIntentSignals.take(8).map((s) => '- $s').join('\n')
          : 'No app-intent signals.';

      final baseSentimentJson = jsonEncode(baseSentiment);

      final prompt = '''
A user's baseline digital wellbeing sentiment (from deterministic usage scoring) is:
$baseSentimentJson

Adjust these percentages slightly based on the following context, if relevant. If there's no meaningful signal, return the baseline unchanged.

Self-reported mood check-ins (strongest signal):
$moodBlock

Recurring chat themes (last 30 days):
$recentThemesContext

Recent chat context:
$recentChatContext

Recent app-intent signals:
$recentIntentContext

Respond with ONLY a JSON object, no explanation, in this exact format:
{"Positive": 20, "Neutral": 20, "Negative": 20, "Anxious": 20, "Focused": 20}
The 5 values must sum to 100.
''';

      debugPrint('🤖 AISentimentService: Calling Groq API for sentiment mood-nudge...');

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
                {'role': 'system', 'content': 'You are a digital wellbeing sentiment adjuster. Respond with a single JSON object only.'},
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.1, // Low temperature for consistency
              'max_tokens': 200,
              'response_format': {'type': 'json_object'},
              'seed': 42, // Fixed seed for deterministic results
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
      _lastSentimentContext = contextSummary;

      debugPrint('✅ AISentimentService: Sentiment analysis completed: $sentiments');
      return sentiments;

    } catch (e, stackTrace) {
      debugPrint('❌ AISentimentService: Error analyzing sentiment - $e');
      debugPrint('Stack trace: $stackTrace');

      // PART L.6: the caller (aiSentimentProvider) falls back to
      // `computeBaseSentiment(...)` on failure, so even the fallback is a
      // real computed value instead of an arbitrary placeholder. We still
      // rethrow so the provider can classify the failure and mark the result
      // as a fallback (never poisoning persisted trends).
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
  ///
  /// PART M: the LLM is asked for a strict JSON array of exactly 4 strings
  /// (`response_format: json_object`, max_tokens 300) and the result is
  /// decoded with `jsonDecode` — no more numbered-list regex parsing.
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
As a digital wellbeing AI assistant, provide 4 personalized, actionable recommendations for this user based on their usage patterns and emotional state.

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
Focus on:
- Specific actions they can take NOW
- Addressing their emotional state
- Helping them meet their goals
- Referencing the recurring themes (e.g. if work deadlines keep appearing, suggest a concrete work-break tactic)
- Practical, achievable steps
- Each recommendation must be DIFFERENT from everything on the do-not-repeat list

Respond with ONLY a JSON array of exactly 4 short, actionable recommendations, no explanation:
["...", "...", "...", "..."]
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
                {'role': 'system', 'content': 'You are a digital wellbeing coach. Provide a JSON array of exactly 4 brief, actionable recommendations.'},
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.8,
              'max_tokens': 300,
              'response_format': {'type': 'json_object'},
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
      debugPrint('Response text: $text');

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

  /// PART L.4 — parse sentiment percentages from a JSON-only LLM response.
  ///
  /// Accepts the exact {"Positive":..,"Neutral":..,"Negative":..,"Anxious":..,
  /// "Focused":..} object returned by the mood-nudge call. Tolerates markdown
  /// code fences and case variations in keys, but throws [FormatException] if
  /// any of the 5 labels is missing so the provider never shows fake data.
  @visibleForTesting
  Map<String, double> parseSentiment(String text) => _parseSentiment(text);

  Map<String, double> _parseSentiment(String text) {
    dynamic decodedRaw;
    try {
      decodedRaw = jsonDecode(_stripJsonFence(text));
    } on FormatException {
      throw FormatException('Failed to parse sentiment JSON: $text');
    }
    if (decodedRaw is! Map) {
      throw FormatException('Failed to parse sentiment JSON: $text');
    }

    final decoded = decodedRaw as Map<String, dynamic>;
    const labels = ['Positive', 'Neutral', 'Negative', 'Anxious', 'Focused'];
    // Some models lowercase the keys even in JSON mode — match case-insensitively.
    final lowerToLabel = {for (final label in labels) label.toLowerCase(): label};

    final sentiments = <String, double>{};
    decoded.forEach((key, value) {
      final label = lowerToLabel[key.toLowerCase()];
      if (label != null && value is num) sentiments[label] = value.toDouble();
    });

    if (sentiments.length < 5) {
      throw FormatException('Failed to parse sentiment JSON: $text');
    }

    // Normalize to 100% if the model drifted off-target.
    final total = sentiments.values.fold(0.0, (sum, val) => sum + val);
    if (total > 0 && (total < 95 || total > 105)) {
      sentiments.updateAll((key, value) => (value / total) * 100);
    }

    return sentiments;
  }

  /// Strip an optional markdown ```json ... ``` fence around a JSON payload.
  @visibleForTesting
  String stripJsonFence(String text) => _stripJsonFence(text);

  String _stripJsonFence(String text) {
    final trimmed = text.trim();
    final fenceMatch = RegExp(
      r'^```(?:json)?\s*(.*?)\s*```$',
      dotAll: true,
    ).firstMatch(trimmed);
    if (fenceMatch != null) return fenceMatch.group(1)!;
    return trimmed;
  }

  /// PART M.3 — parse recommendations from a JSON-only LLM response.
  ///
  /// Decodes the `["...", "...", "...", "..."]` array (optionally wrapped in
  /// a `{"recommendations": [...]}` object since Groq json_object mode always
  /// needs an object). Array elements may be plain strings OR objects with a
  /// text field (observed live: `{"title":..., "description":..., "action":...}`),
  /// so map elements are flattened to their most useful string. Falls back to
  /// legacy numbered-list parsing only for older cached/raw text, so
  /// previously-working output stays compatible. Throws [FormatException]
  /// when nothing usable can be extracted.
  @visibleForTesting
  List<String> parseRecommendations(String text) => _parseRecommendations(text);

  List<String> _parseRecommendations(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw FormatException('Failed to parse recommendations JSON: $text');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(_stripJsonFence(trimmed));
    } on FormatException {
      decoded = null;
    }

    List<String>? recommendations;

    if (decoded is List) {
      recommendations = _flattenRecommendationEntries(decoded);
    } else if (decoded is Map) {
      // Groq json_object mode requires an object: the model wraps the array
      // as {"recommendations": [...]} (or similar key).
      final rawList = _findListInMap(decoded);
      if (rawList != null) {
        recommendations = _flattenRecommendationEntries(rawList);
      }
    }

    if (recommendations != null && recommendations.isNotEmpty) {
      return recommendations.take(4).toList();
    }

    // Legacy fallback: numbered-list lines ("1. ...", "1) ...") from older
    // responses or previously-cached text.
    final legacy = _parseLegacyNumberedList(trimmed);
    if (legacy.isNotEmpty) {
      return legacy.take(4).toList();
    }

    throw FormatException('Failed to parse recommendations JSON: $text');
  }

  /// Flatten JSON array entries into recommendation strings.
  ///
  /// Plain strings pass through; map objects are reduced to their best
  /// string field, preferring the most substantive one ("description" >
  /// "action" > "title" > "recommendation" > "tip") because Groq was
  /// observed returning `{title, description, action}` objects in
  /// json_object mode.
  List<String> _flattenRecommendationEntries(List<dynamic> entries) {
    const preferredKeys = [
      'description',
      'action',
      'title',
      'recommendation',
      'tip',
      'text',
    ];

    final result = <String>[];
    for (final entry in entries) {
      String? candidate;

      if (entry is String) {
        candidate = entry.trim();
      } else if (entry is Map) {
        for (final key in preferredKeys) {
          final value = entry[key];
          if (value is String && value.trim().isNotEmpty) {
            candidate = value.trim();
            break;
          }
        }
        if (candidate == null) {
          // Fallback: any string value in the object.
          for (final value in entry.values) {
            if (value is String && value.trim().isNotEmpty) {
              candidate = value.trim();
              break;
            }
          }
        }
      }

      if (candidate != null &&
          candidate.isNotEmpty &&
          candidate.length > 10 &&
          !result.contains(candidate)) {
        result.add(candidate);
      }
    }
    return result;
  }

  List<dynamic>? _findListInMap(Map<dynamic, dynamic> map) {
    for (final value in map.values) {
      if (value is List) return value;
    }
    return null;
  }

  List<String> _parseLegacyNumberedList(String text) {
    final recommendations = <String>[];
    final lines = text.split('\n');

    for (final line in lines) {
      final trimmedLine = line.trim();
      // Match numbered lists: "1.", "1)", "1 -", etc.
      if (RegExp(r'^\d+[\.\)\-\:]').hasMatch(trimmedLine)) {
        // Remove the number prefix
        final cleaned =
            trimmedLine.replaceFirst(RegExp(r'^\d+[\.\)\-\:]\s*'), '').trim();
        if (cleaned.isNotEmpty && cleaned.length > 10) {
          recommendations.add(cleaned);
        }
      }
    }

    // Note: no plain-line splitting fallback here. If the text isn't a JSON
    // array/object and isn't a numbered list, it's not a valid response and
    // the caller throws a FormatException rather than surfacing junk tips.
    return recommendations;
  }
}
