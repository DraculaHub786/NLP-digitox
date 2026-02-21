/*
 *
 *  * Copyright (c) 2024 NLP digitox
 *  * Author : Afjal Ansari
 *  *
 *  * This source code is licensed under the GPL-2.0 license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/ai_sentiment_service.dart';
import 'package:nlp_digitox/core/services/ai_chatbot_service.dart';
import 'package:nlp_digitox/core/services/productivity_service.dart';
import 'package:nlp_digitox/models/usage_model.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/providers/usage/weekly_device_usage_provider.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';

/// Provider for AI sentiment analysis
final aiSentimentProvider = FutureProvider.autoDispose<Map<String, double>>((ref) async {
  final todayUsage = ref.watch(
    weeklyDeviceUsageProvider(dateToday.weekRange).select((v) => v[dateToday] ?? const UsageModel()),
  );

  // Get wellbeing settings for screen time goal
  final wellbeingSettings = await DriftDbService.instance.driftDb.uniqueRecordsDao.loadWellBeingSettings();
  final screenTimeGoal = wellbeingSettings.allowedShortsTimeSec;

  // Get productivity stats
  final habitsCompleted = await _getCompletedHabitsToday();
  final tasksCompleted = await _getCompletedTasksToday();
  final streak = await _getCurrentStreak();

  final sentiment = await AISentimentService.instance.analyzeSentiment(
    todayUsage: todayUsage,
    screenTimeGoalSeconds: screenTimeGoal,
    streakDays: streak,
    habitsCompleted: habitsCompleted,
    tasksCompleted: tasksCompleted,
  );

  return sentiment;
});

/// Provider for AI recommendations
final aiRecommendationsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final todayUsage = ref.watch(
    weeklyDeviceUsageProvider(dateToday.weekRange).select((v) => v[dateToday] ?? const UsageModel()),
  );

  // Get wellbeing settings for screen time goal
  final wellbeingSettings = await DriftDbService.instance.driftDb.uniqueRecordsDao.loadWellBeingSettings();
  final screenTimeGoal = wellbeingSettings.allowedShortsTimeSec;

  // Get current sentiment
  final sentiment = await ref.watch(aiSentimentProvider.future);

  // Get recent chat messages for context
  final recentMessages = AIChatbotService.instance.getRecentMessages(count: 3);

  final recommendations = await AISentimentService.instance.getRecommendations(
    todayUsage: todayUsage,
    screenTimeGoalSeconds: screenTimeGoal,
    currentSentiment: sentiment,
    recentChatMessages: recentMessages.isNotEmpty ? recentMessages : null,
  );

  return recommendations;
});

/// Provider for chat messages
final aiChatMessagesProvider = StateProvider<List<ChatMessage>>((ref) {
  return AIChatbotService.instance.chatHistory;
});

/// Provider for loading state during chat
final aiChatLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider for suggested chat prompts
final aiSuggestedPromptsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
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
