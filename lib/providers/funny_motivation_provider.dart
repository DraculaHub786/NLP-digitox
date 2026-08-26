// Copyright (c) 2026 NLP digitox
//
// Riverpod provider for the funny mood-based motivation feature.
// Aggregates context, calls the Groq API, caches, and respects privacy gating.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/ai_sentiment_service.dart';
import 'package:nlp_digitox/features/motivation/motivation_context_service.dart';
import 'package:nlp_digitox/providers/privacy_provider.dart';

/// Whether a funny-motivation fetch is currently in-flight.
final funnyMotivationLoadingProvider = StateProvider<bool>((ref) => false);

/// The cached funny motivation string, if any.
/// Cleared on privacy toggle or explicit refresh.
final funnyMotivationCacheProvider =
    StateProvider<String?>((ref) => null);

/// Fetches (or returns cached) funny motivation.
/// Returns null when mood tracking is disabled, or on fetch failure.
final funnyMotivationProvider = FutureProvider<String?>((ref) async {
  // ── Privacy gate ──────────────────────────────────────────────
  final privacy = ref.watch(privacyProvider);
  if (!privacy.moodTrackingEnabled) {
    debugPrint('🔇 FunnyMotivation: mood tracking disabled — skipping');
    return null;
  }

  // ── Check cache ───────────────────────────────────────────────
  final cached = ref.read(funnyMotivationCacheProvider);
  if (cached != null) {
    debugPrint('💬 FunnyMotivation: returning cached message');
    return cached;
  }

  // ── Set loading ───────────────────────────────────────────────
  ref.read(funnyMotivationLoadingProvider.notifier).state = true;

  try {
    // Build context from all sources
    final contextService = MotivationContextService();
    final context = await contextService.buildContext();

    final persona = context['persona'] as String?;
    final latestMood = context['mood'] as String?;
    final dominantSentiment = context['dominantSentiment'] as String?;
    final recentChatTopics =
        (context['recentChatTopics'] as List<dynamic>?)
                ?.cast<String>() ??
            [];
    final usageContext = context['usageContext'] as String?;

    // Check cache from MotivationContextService (SharedPreferences)
    final cachedMotivation = await contextService.getCachedMotivation();
    if (cachedMotivation != null) {
      ref.read(funnyMotivationCacheProvider.notifier).state =
          cachedMotivation;
      debugPrint('💬 FunnyMotivation: returning SharedPrefs-cached message');
      return cachedMotivation;
    }

    // Call Groq API
    final result = await AISentimentService.instance.getFunnyMotivation(
      persona: persona,
      latestMood: latestMood,
      dominantSentiment: dominantSentiment,
      recentChatTopics:
          recentChatTopics.isNotEmpty ? recentChatTopics : null,
      usageContext: usageContext,
    );

    // Cache the result
    await contextService.cacheMotivation(result);
    ref.read(funnyMotivationCacheProvider.notifier).state = result;

    return result;
  } catch (e, stackTrace) {
    debugPrint('❌ FunnyMotivation: error — $e');
    debugPrint('Stack trace: $stackTrace');
    return null;
  } finally {
    ref.read(funnyMotivationLoadingProvider.notifier).state = false;
  }
});

/// Manually refresh the funny motivation (e.g. on a "cheer me up" button tap).
final funnyMotivationRefreshProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(funnyMotivationCacheProvider);
    ref.invalidate(funnyMotivationProvider);
  };
});
