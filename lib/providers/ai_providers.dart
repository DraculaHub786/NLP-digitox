// Copyright (c) 2024 NLP digitox

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/ai_sentiment_service.dart';
import 'package:nlp_digitox/core/services/ai_chatbot_service.dart';
import 'package:nlp_digitox/core/services/chat_context_extractor.dart';
import 'package:nlp_digitox/core/services/productivity_service.dart';
import 'package:nlp_digitox/core/services/sentiment_mood_bridge.dart';
import 'package:nlp_digitox/core/services/sentiment_persistence_service.dart';
import 'package:nlp_digitox/models/ai_analysis_models.dart';
import 'package:nlp_digitox/models/usage_model.dart';
import 'package:nlp_digitox/models/app_intent_model.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/providers/usage/weekly_device_usage_provider.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/providers/system/intent_provider.dart';

/// AI sentiment analysis with an `isFallback` flag so the UI can tell real
/// AI output apart from static fallback data (Phase 1.2 / 1.3).
final aiSentimentProvider = FutureProvider<SentimentResult>((ref) async {
  final todayUsage = ref.watch(
    weeklyDeviceUsageProvider(dateToday.weekRange).select((v) => v[dateToday] ?? const UsageModel()),
  );
  final intentHistory = ref.watch(intentNotifierProvider);

  // Get wellbeing settings for screen time goal
  final screenTimeGoal = await _loadScreenTimeGoalSeconds();
  if (screenTimeGoal == null) {
    const failure = AiFailure(AiFailureType.missingGoal, 'No screen-time goal set yet.');
    debugPrint('⚠️ aiSentimentProvider fallback (missingGoal): $failure');
    return const SentimentResult.fallback(failure);
  }

  final persistence = SentimentPersistenceService.instance;

  // Phase 3.4: explicit hour TTL cache — skip the LLM entirely when the last
  // real analysis is still fresh. Riverpod's own provider caching alone is
  // not enough because the provider is invalidated (e.g. via the refresh
  // button) and on navigation; this guarantees at most one Groq call per
  // hour for sentiment regardless of how often the UI rebuilds.
  if (await persistence.isCacheFresh()) {
    final cached = await _loadCachedSentimentResult();
    if (cached != null) {
      debugPrint('⏱️ aiSentimentProvider: reusing fresh cached sentiment (TTL ${SentimentPersistenceService.analysisTtl.inMinutes}m)');
      return cached;
    }
  }

  final habitsCompleted = await _getCompletedHabitsToday();
  final tasksCompleted = await _getCompletedTasksToday();
  final streak = await _getCurrentStreak();
  final recentMessages = AIChatbotService.instance.getRecentMessages(count: 6);
  final recentIntents = _getRecentIntentSignals(intentHistory);

  // Phase 2: extract recurring themes across the 30-day chat window. Pure
  // local computation — no extra API calls.
  final recentThemes = await ChatContextExtractor.instance.getRecentThemes();

  // Phase 3.1: merge the third signal source — manual mood check-ins and
  // behavioral heuristics from MoodService — into the assessment.
  final moodSignal = await SentimentMoodBridge.instance.buildSignal();

  try {
    final sentiment = await AISentimentService.instance.analyzeSentiment(
      todayUsage: todayUsage,
      screenTimeGoalSeconds: screenTimeGoal,
      streakDays: streak,
      habitsCompleted: habitsCompleted,
      tasksCompleted: tasksCompleted,
      recentChatMessages: recentMessages.isNotEmpty ? recentMessages : null,
      recentIntentSignals: recentIntents.isNotEmpty ? recentIntents : null,
      recentThemes: recentThemes.isNotEmpty ? recentThemes : null,
      moodContext: moodSignal.promptBlock,
    );
    debugPrint('✅ aiSentimentProvider: real AI result $sentiment (themes: $recentThemes, mood: ${moodSignal.dominantMood ?? "none"})');

    // Phase 3.2: persist today's real snapshot + Phase 3.4: stamp cache time.
    await persistence.saveToday(SentimentResult(sentiments: sentiment));
    await persistence.stampAnalysisTime();

    return SentimentResult(sentiments: sentiment);
  } catch (e) {
    final failure = classifyAiFailure(e);

    // PART L.6: fall back to the locally-computed base sentiment instead of
    // the generic hardcoded default — even the "fallback" is now a real
    // computed value (deterministic scoring of today's actual usage), so the
    // UI still shows sensible, usage-derived numbers when the LLM is down.
    // Still flagged isFallback so it is never persisted as a real snapshot
    // (saveToday ignores fallbacks) and never poisons trend history.
    final fallbackSentiment = AISentimentService.instance.computeBaseSentiment(
      screenTimeHours: todayUsage.screenTime / 3600,
      goalHours: screenTimeGoal / 3600,
      streakDays: streak,
      habitsCompleted: habitsCompleted,
      tasksCompleted: tasksCompleted,
    );
    debugPrint('⚠️ aiSentimentProvider fallback triggered — failure: $failure. Using computed base sentiment: $fallbackSentiment');
    return SentimentResult(
      sentiments: fallbackSentiment,
      isFallback: true,
      failure: failure,
    );
  }
});

/// Sentiment trend provider — 7-day vs previous-7-day movement computed from
/// persisted daily snapshots (Phase 3.2). Pure local computation.
final aiSentimentTrendProvider = FutureProvider<SentimentTrend>((ref) async {
  return SentimentPersistenceService.instance.computeTrend();
});

/// AI recommendations with an `isFallback` flag (Phase 1.2 / 1.3 + Phase 2.4).
/// Phase 4: anti-repeat (4.1), theme-tied tips (4.2), feedback (4.3).
final aiRecommendationsProvider = FutureProvider.autoDispose<RecommendationsResult>((ref) async {
  final todayUsage = ref.watch(
    weeklyDeviceUsageProvider(dateToday.weekRange).select((v) => v[dateToday] ?? const UsageModel()),
  );

  // Get wellbeing settings for screen time goal
  final screenTimeGoal = await _loadScreenTimeGoalSeconds();
  if (screenTimeGoal == null) {
    const failure = AiFailure(AiFailureType.missingGoal, 'No screen-time goal set yet.');
    debugPrint('⚠️ aiRecommendationsProvider fallback (missingGoal): $failure');
    return const RecommendationsResult.fallback(failure);
  }

  final sentimentResult = await ref.watch(aiSentimentProvider.future);

  final recentMessages = AIChatbotService.instance.getRecentMessages(count: 3);

  // Phase 2: same accumulated 30-day themes used for sentiment analysis.
  final recentThemes = await ChatContextExtractor.instance.getRecentThemes();

  final persistence = SentimentPersistenceService.instance;

  // Phase 4.1: recently shown tips to avoid repeating.
  final shownTips = await persistence.getRecentShownTips();
  // Phase 4.3: tips the user marked "not helpful".
  final dismissedTips = await persistence.getDismissedTips();
  // Phase 4.2: pick the top recurring theme to explicitly reference.
  final themeSuggestion = _extractThemeSuggestion(recentThemes);

  try {
    final recommendations = await AISentimentService.instance.getRecommendations(
      todayUsage: todayUsage,
      screenTimeGoalSeconds: screenTimeGoal,
      currentSentiment: sentimentResult.sentiments,
      recentChatMessages: recentMessages.isNotEmpty ? recentMessages : null,
      recentThemes: recentThemes.isNotEmpty ? recentThemes : null,
      avoidTips: shownTips.isNotEmpty ? shownTips : null,
      avoidTopics: dismissedTips.isNotEmpty ? dismissedTips : null,
      themeSuggestion: themeSuggestion,
    );
    debugPrint('✅ aiRecommendationsProvider: real AI result $recommendations (themes: $recentThemes, avoid ${shownTips.length} shown, ${dismissedTips.length} dismissed)');

    // Record shown tips so the next call can avoid repeating them (4.1).
    await persistence.recordShownTips(recommendations);

    return RecommendationsResult(recommendations: recommendations);
  } catch (e) {
    final failure = classifyAiFailure(e);
    debugPrint('⚠️ aiRecommendationsProvider fallback triggered — failure: $failure');
    return RecommendationsResult.fallback(failure);
  }
});

final aiChatMessagesProvider = StateProvider<List<ChatMessage>>((ref) {
  return AIChatbotService.instance.chatHistory;
});

final aiChatLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider for suggested chat prompts
final aiSuggestedPromptsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final sentimentResult = await ref.watch(aiSentimentProvider.future);
  return AIChatbotService.instance.getSuggestedPrompts(sentimentResult.sentiments);
});

// Helper functions

Future<SentimentResult?> _loadCachedSentimentResult() async {
  try {
    final history = await SentimentPersistenceService.instance.loadHistory();
    if (history.isEmpty) return null;
    final latest = history.last;
    final now = DateTime.now();
    final isToday = latest.day.year == now.year &&
        latest.day.month == now.month &&
        latest.day.day == now.day;
    if (!isToday) return null;
    return SentimentResult(sentiments: latest.sentiments);
  } catch (e) {
    debugPrint('⚠️ _loadCachedSentimentResult failed: $e');
    return null;
  }
}

/// Phase 4.2: extract a single concrete theme to reference in a tip.
String? _extractThemeSuggestion(List<String> themes) {
  if (themes.isEmpty) return null;
  // Prefer themes about recurring pressure points over generic wellness topics.
  const priorityTopics = {
    'work', 'study', 'exam', 'sleep', 'anxiety', 'social media',
    'deadline', 'health', 'loneliness', 'focus',
  };
  for (final theme in themes) {
    final topic = theme.split(' ').first.toLowerCase();
    if (priorityTopics.contains(topic)) return theme;
  }
  return themes.first;
}

Future<int> _getCompletedHabitsToday() async {
  try {
    final habits = await ProductivityService.instance.getHabits();
    final today = dateToday;

    int completed = 0;
    for (final habit in habits) {
      if (habit.completedToday) {
        final lastCompleted = habit.lastCompletedDate;
        if (lastCompleted != null &&
            lastCompleted.year == today.year &&
            lastCompleted.month == today.month &&
            lastCompleted.day == today.day) {
          completed++;
        }
      }
    }
    return completed;
  } catch (e) {
    return 0;
  }
}

Future<int> _getCompletedTasksToday() async {
  try {
    final tasks = await ProductivityService.instance.getTasks();
    final today = dateToday;

    return tasks.where((task) {
      if (!task.completed) return false;
      final completedAt = task.completedAt;
      return completedAt != null &&
          completedAt.year == today.year &&
          completedAt.month == today.month &&
          completedAt.day == today.day;
    }).length;
  } catch (e) {
    return 0;
  }
}

Future<int> _getCurrentStreak() async {
  try {
    final habits = await ProductivityService.instance.getHabits();

    if (habits.isEmpty) return 0;

    // Get the highest streak from all habits
    int maxStreak = 0;
    for (final habit in habits) {
      if (habit.streak > maxStreak) {
        maxStreak = habit.streak;
      }
    }
    return maxStreak;
  } catch (e) {
    return 0;
  }
}

List<String> _getRecentIntentSignals(Map<String, List<AppIntentModel>> history) {
  final signals = <String>[];

  history.forEach((package, intents) {
    if (intents.isEmpty) return;
    final recent = intents.last;
    final appLabel = package.split('.').last;
    signals.add('$appLabel: ${recent.intent.displayName} (${recent.isAllowed ? "allowed" : "not-allowed"})');
  });

  return signals.take(8).toList();
}

Future<int?> _loadScreenTimeGoalSeconds() async {
  try {
    final wellbeingSettings = await DriftDbService.instance.driftDb.uniqueRecordsDao.loadWellBeingSettings();
    // Use the dedicated dailyScreenTimeGoalSec field instead of the
    // Shorts/Reels time limit (which was the wrong field to read).
    return wellbeingSettings.dailyScreenTimeGoalSec;
  } catch (e) {
    debugPrint('⚠️ _loadScreenTimeGoalSeconds failed: $e');
    return null;
  }
}
