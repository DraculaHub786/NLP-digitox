// Copyright (c) 2024 NLP digitox

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nlp_digitox/core/services/ai_sentiment_service.dart';
import 'package:nlp_digitox/core/services/ai_chatbot_service.dart';
import 'package:nlp_digitox/features/mood/mood_service.dart';

/// Aggregates mood, persona, chat, and sentiment into one context object
/// used by the funny motivation feature.
class MotivationContextService {
  static final MotivationContextService _instance =
      MotivationContextService._();
  factory MotivationContextService() => _instance;
  MotivationContextService._();

  static const String _personaKey = 'onboarding_persona';
  static const String _cachedMotivationKey = 'cached_funny_motivation';
  static const String _cachedMotivationTimeKey =
      'cached_funny_motivation_timestamp';

  /// Build a combined context map from all available sources.
  Future<Map<String, dynamic>> buildContext() async {
    final prefs = await SharedPreferences.getInstance();
    final context = <String, dynamic>{};

    // Persona (from onboarding quiz)
    final persona = prefs.getString(_personaKey);
    if (persona != null && persona.isNotEmpty) {
      context['persona'] = persona;
    }

    // Latest mood entry
    final moodService = MoodService();
    final latestMood = moodService.latestMood;
    if (latestMood != null) {
      context['mood'] = latestMood.mood.name;
    }

    // AI sentiment analysis (last cached result)
    final lastSentiment = AISentimentService.instance.getLastSentiment();
    if (lastSentiment != null) {
      context['aiSentiment'] = lastSentiment;
      final dominant =
          lastSentiment.entries.reduce((a, b) => a.value > b.value ? a : b);
      context['dominantSentiment'] = dominant.key;
    }

    // Recent chat messages
    final recentMessages =
        AIChatbotService.instance.getRecentMessages(count: 3);
    if (recentMessages.isNotEmpty) {
      context['recentChatTopics'] = recentMessages;
    }

    // Screen time context
    final lastContext = AISentimentService.instance.getLastSentimentContext();
    if (lastContext != null) {
      context['usageContext'] = lastContext;
    }

    return context;
  }

  /// Read cached funny motivation if still fresh.
  Future<String?> getCachedMotivation({
    Duration maxAge = const Duration(hours: 3),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cachedMotivationKey);
    final timestamp = prefs.getInt(_cachedMotivationTimeKey);

    if (cached == null || timestamp == null) return null;

    final age =
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
    if (age > maxAge) return null;

    debugPrint('💬 Using cached funny motivation (age: ${age.inMinutes}m)');
    return cached;
  }

  /// Cache the generated motivation.
  Future<void> cacheMotivation(String motivation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedMotivationKey, motivation);
    await prefs.setInt(
        _cachedMotivationTimeKey, DateTime.now().millisecondsSinceEpoch);
    debugPrint('💬 Cached funny motivation');
  }

  /// Clear cached motivation.
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedMotivationKey);
    await prefs.remove(_cachedMotivationTimeKey);
  }
}
