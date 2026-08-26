// Copyright (c) 2026 NLP digitox
//
// Part N live smoke test — verifies the new JSON-only Groq request shapes:
//   1. Sentiment mood-nudge: response_format json_object + max_tokens 200.
//   2. Recommendations:     response_format json_object + max_tokens 300.
//
// Run with: dart test_sentiment_json.dart
// Only touches the network + parses responses; the in-app parsing logic that
// consumes these responses is covered by unit tests in
// test/services/ai_analysis_models_test.dart.

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

final apiKey = Platform.environment['GROQ_API_KEY'] ?? '';
const apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
const modelName = 'groq/compound-mini';

Future<Map<String, dynamic>> _post(Map<String, dynamic> body) async {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: json.encode(body),
  );
  if (response.statusCode != 200) {
    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }
  return json.decode(response.body) as Map<String, dynamic>;
}

String _extractContent(Map<String, dynamic> data) =>
    data['choices'][0]['message']['content'] as String;

void main() async {
  print('🧪 Testing JSON-only sentiment + recommendations (Part N)');
  print('Model: $modelName');
  if (apiKey.isEmpty) {
    print('❌ GROQ_API_KEY environment variable is not set.');
    print('   Copy .env.example to .env, add your key, and export it.');
    return;
  }
  print('');

  // ── 1. Sentiment mood-nudge (matches analyzeSentiment's LLM path) ──────
  try {
    const baseSentimentJson =
        '{"Positive": 52.63, "Neutral": 27.37, "Negative": 8.77, "Anxious": 8.77, "Focused": 2.63}';
    final prompt = '''
A user's baseline digital wellbeing sentiment (from deterministic usage scoring) is:
$baseSentimentJson

Adjust these percentages slightly based on the following context, if relevant. If there's no meaningful signal, return the baseline unchanged.

Self-reported mood check-ins (strongest signal):
- Anxious (x2) over the last 7 days; latest: Anxious, stress 7/10
- Recent triggers: work deadline (x1)
- Average sentiment score: -0.35

Recurring chat themes (last 30 days):
- work (x4)
- anxiety (x3)

Recent chat context:
- I'm stressed about the deadline tomorrow.
- Can't sleep, keep thinking about work.

Recent app-intent signals:
- Instagram: Reels (not-allowed)

Respond with ONLY a JSON object, no explanation, in this exact format:
{"Positive": 20, "Neutral": 20, "Negative": 20, "Anxious": 20, "Focused": 20}
The 5 values must sum to 100.
''';

    print('⏳ [1/2] Sentiment mood-nudge (json_object, max_tokens 200)...');
    final data = await _post({
      'model': modelName,
      'messages': [
        {'role': 'system', 'content': 'You are a digital wellbeing sentiment adjuster. Respond with a single JSON object only.'},
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.1,
      'max_tokens': 200,
      'response_format': {'type': 'json_object'},
      'seed': 42,
    });
    final text = _extractContent(data);
    print('   Raw response: $text');
    final decoded = json.decode(text) as Map<String, dynamic>;
    final sum = ['Positive', 'Neutral', 'Negative', 'Anxious', 'Focused']
        .map((k) => (decoded[k] as num?)?.toDouble() ?? 0.0)
        .fold(0.0, (a, b) => a + b);
    print('   Sum: ${sum.toStringAsFixed(1)}');
    print(decoded.keys.length == 5 && (sum - 100).abs() <= 5
        ? '   ✅ Sentiment JSON valid (5 keys, sum ~100)'
        : '   ⚠️ Unexpected shape — check output above.');
  } catch (e) {
    print('   ❌ Sentiment smoke test failed: $e');
  }
  print('');

  // ── 2. Recommendations (matches getRecommendations' LLM path) ──────────
  try {
    final prompt = '''
As a digital wellbeing AI assistant, provide 4 personalized, actionable recommendations for this user based on their usage patterns and emotional state.

Current State:
- Screen Time: 3.5 hours (Goal: 4 hours)
- Sentiment: Positive: 20%, Neutral: 20%, Negative: 20%, Anxious: 20%, Focused: 20%
- Recent chats:
- I'm stressed about the deadline tomorrow.
- Can't sleep, keep thinking about work.

Recurring themes from the last 30 days of chat (tie recommendations to these themes where relevant):
- work (x4)
- anxiety (x3)

Do NOT repeat any of these recently-shown tips (they were already given to this user):
- None.

Avoid these topics entirely — the user marked tips about them as NOT helpful:
- None.

A recurring theme the user keeps mentioning is "work". Make at least ONE recommendation specifically about this — directly reference it by name.
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

    print('⏳ [2/2] Recommendations (json_object, max_tokens 300)...');
    final data = await _post({
      'model': modelName,
      'messages': [
        {'role': 'system', 'content': 'You are a digital wellbeing coach. Provide a JSON array of exactly 4 brief, actionable recommendations.'},
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.8,
      'max_tokens': 300,
      'response_format': {'type': 'json_object'},
    });
    final text = _extractContent(data);
    print('   Raw response: $text');
    final decoded = json.decode(text);
    print('   ✅ Recommendations response decoded successfully.');
    if (decoded is Map) {
      decoded.forEach((key, value) {
        print('   → "$key": $value');
      });
    } else if (decoded is List) {
      print('   → ${decoded.map((e) => '"$e"').join('\n   → ')}');
    }
  } catch (e) {
    print('   ❌ Recommendations smoke test failed: $e');
  }
  print('');
  print('✅ Smoke test complete.');
}
