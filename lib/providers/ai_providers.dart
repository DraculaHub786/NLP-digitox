// Copyright (c) 2026 NLP digitox

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/ai_sentiment_service.dart';
import 'package:nlp_digitox/core/services/ai_chatbot_service.dart';
import 'package:nlp_digitox/core/services/chat_context_extractor.dart';
import 'package:nlp_digitox/core/services/productivity_service.dart';
import 'package:nlp_digitox/core/services/sentiment_mood_bridge.dart';
import 'package:nlp_digitox/core/services/sentiment_persistence_service.dart';
import 'package:nlp_digitox/models/usage_model.dart';
import 'package:nlp_digitox/models/app_intent_model.dart';
import 'package:nlp_digitox/models/ai_analysis_models.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/providers/usage/weekly_device_usage_provider.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/providers/system/intent_provider.dart';

final aiSentimentProvider = FutureProvider<Map<String, double>>((ref) async {
  final todayUsage = ref.watch(
    weeklyDeviceUsageProvider(dateToday.weekRange)
        .select((v) => v[dateToday] ?? const UsageModel()),
  );
  final intentHistory = ref.watch(intentNotifierProvider);

  // Get wellbeing settings for screen time goal
  final screenTimeGoal = await _loadScreenTimeGoalSeconds();
  if (screenTimeGoal == null) {
    return _usageDrivenFallback(todayUsage, 0, 0, 0);
  }

  final habitsCompleted = await _getCompletedHabitsToday();
  final tasksCompleted = await _getCompletedTasksToday();
  final streak = await _getCurrentStreak();
  final recentMessages = AIChatbotService.instance.getRecentMessages(count: 6);
  final recentIntents = _getRecentIntentSignals(intentHistory);

  try {
    // Hourly TTL cache — avoids re-calling the LLM on every provider
    // rebuild / tab switch / chat message within the same hour.
    final persistence = SentimentPersistenceService.instance;
    if (await persistence.isCacheFresh()) {
      final history = await persistence.loadHistory();
      if (history.isNotEmpty) {
        return history.last.sentiments;
      }
    }

    // Richer context: recurring chat themes extracted locally across the
    // full 30-day chat retention window, plus recent manual mood check-ins.
    // Both are additive prompt context only — if either fails or returns
    // nothing, sentiment analysis still proceeds on usage metrics + recent
    // messages exactly as before.
    List<String> chatThemes = const [];
    String? moodBlock;
    try {
      await ChatContextExtractor.instance.ensureTodayExtracted();
      chatThemes = await ChatContextExtractor.instance.getRecentThemes();
    } catch (e) {
      debugPrint('⚠️ ChatContextExtractor failed, continuing without it: $e');
    }
    try {
      moodBlock = (await SentimentMoodBridge.instance.buildSignal()).promptBlock;
    } catch (e) {
      debugPrint('⚠️ SentimentMoodBridge failed, continuing without it: $e');
    }

    final sentiment = await AISentimentService.instance.analyzeSentiment(
      todayUsage: todayUsage,
      screenTimeGoalSeconds: screenTimeGoal,
      streakDays: streak,
      habitsCompleted: habitsCompleted,
      tasksCompleted: tasksCompleted,
      recentChatMessages: recentMessages.isNotEmpty ? recentMessages : null,
      recentIntentSignals: recentIntents.isNotEmpty ? recentIntents : null,
      recentChatThemes: chatThemes.isNotEmpty ? chatThemes : null,
      moodContextBlock: moodBlock,
    );

    await persistence.stampAnalysisTime();
    await persistence.saveDay(
      dateToday,
      SentimentResult(sentiments: sentiment),
    );

    return sentiment;
  } catch (e) {
    debugPrint('⚠️ aiSentimentProvider fallback triggered: $e');
    // Real, usage-driven fallback instead of a flat static map — the numbers
    // track actual screen time / streak / habits / tasks that day.
    return _usageDrivenFallback(
      todayUsage,
      streak,
      habitsCompleted,
      tasksCompleted,
      screenTimeGoalSeconds: screenTimeGoal,
    );
  }
});

final aiRecommendationsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final todayUsage = ref.watch(
    weeklyDeviceUsageProvider(dateToday.weekRange)
        .select((v) => v[dateToday] ?? const UsageModel()),
  );

  // Get wellbeing settings for screen time goal
  final screenTimeGoal = await _loadScreenTimeGoalSeconds();

  final sentiment = await ref.watch(aiSentimentProvider.future);

  if (screenTimeGoal == null) {
    // Without a configured goal there is nothing meaningful to ask the model
    // about, so go straight to the deterministic tips rather than burning a
    // request that would be based on a missing number.
    return _fallbackRecommendations(
      todayUsage,
      sentiment: sentiment,
    );
  }

  final recentMessages = AIChatbotService.instance.getRecentMessages(count: 3);

  try {
    final recommendations = await AISentimentService.instance
        .getRecommendations(
      todayUsage: todayUsage,
      screenTimeGoalSeconds: screenTimeGoal,
      currentSentiment: sentiment,
      recentChatMessages: recentMessages.isNotEmpty ? recentMessages : null,
    );
    return recommendations;
  } catch (e) {
    debugPrint('⚠️ aiRecommendationsProvider fallback triggered: $e');
    return _fallbackRecommendations(
      todayUsage,
      sentiment: sentiment,
      screenTimeGoalSeconds: screenTimeGoal,
    );
  }
});

final aiChatMessagesProvider = StateProvider<List<ChatMessage>>((ref) {
  return AIChatbotService.instance.chatHistory;
});

final aiChatLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider for suggested chat prompts
final aiSuggestedPromptsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final sentiment = await ref.watch(aiSentimentProvider.future);
  return AIChatbotService.instance.getSuggestedPrompts(sentiment);
});

// Helper functions

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

List<String> _getRecentIntentSignals(
    Map<String, List<AppIntentModel>> history) {
  final signals = <String>[];

  history.forEach((package, intents) {
    if (intents.isEmpty) return;
    final recent = intents.last;
    final appLabel = package.split('.').last;
    signals.add(
        '$appLabel: ${recent.intent.displayName} (${recent.isAllowed ? "allowed" : "not-allowed"})');
  });

  return signals.take(8).toList();
}

Future<int?> _loadScreenTimeGoalSeconds() async {
  try {
    final wellbeingSettings = await DriftDbService
        .instance
        .driftDb
        .uniqueRecordsDao
        .loadWellBeingSettings();
    // Use the dedicated dailyScreenTimeGoalSec field instead of the
    // Shorts/Reels time limit (which was the wrong field to read).
    return wellbeingSettings.dailyScreenTimeGoalSec;
  } catch (e) {
    debugPrint('⚠️ _loadScreenTimeGoalSeconds failed: $e');
    return null;
  }
}

/// Reference goal used only when the user has not configured one, so the
/// deterministic estimators still have a scale to compare screen time
/// against. Everything is expressed as a ratio of screen time to goal, so a
/// zero goal would make every ratio meaningless.
const double _unsetGoalHours = 1.0;

/// Resolves the goal in hours, falling back to [_unsetGoalHours] when the
/// user has not set one.
double _goalHoursOr(int screenTimeGoalSeconds) =>
    screenTimeGoalSeconds > 0
        ? screenTimeGoalSeconds / 3600
        : _unsetGoalHours;

/// Deterministic, usage-driven fallback — delegates to the real
/// `computeBaseSentiment()` estimator (which mirrors the Groq prompt's
/// scoring rules) so the numbers genuinely reflect the user's day instead of
/// a static flat map.
Map<String, double> _usageDrivenFallback(
  UsageModel todayUsage,
  int streak,
  int habitsCompleted,
  int tasksCompleted, {
  int screenTimeGoalSeconds = 0,
}) {
  return AISentimentService.instance.computeBaseSentiment(
    screenTimeHours: todayUsage.screenTime / 3600,
    goalHours: _goalHoursOr(screenTimeGoalSeconds),
    streakDays: streak,
    habitsCompleted: habitsCompleted,
    tasksCompleted: tasksCompleted,
  );
}

/// Deterministic tips derived from the day's usage and sentiment.
///
/// Used whenever the Groq recommendation call cannot run (no key, offline,
/// rate limited, or an unparseable reply) and when no screen time goal is
/// configured. This replaces a previous hardcoded three-string list that was
/// identical for every user and every day.
List<String> _fallbackRecommendations(
  UsageModel todayUsage, {
  required Map<String, double> sentiment,
  int screenTimeGoalSeconds = 0,
}) {
  return AISentimentService.instance.computeBaseRecommendations(
    screenTimeHours: todayUsage.screenTime / 3600,
    goalHours: _goalHoursOr(screenTimeGoalSeconds),
    sentiment: sentiment,
    screenTimeGoalSeconds: screenTimeGoalSeconds,
  );
}
