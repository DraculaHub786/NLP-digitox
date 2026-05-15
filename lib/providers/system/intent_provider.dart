
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/models/app_intent_model.dart';

/// Provider to manage app intent history and state
final intentHistoryProvider =
    StateProvider<Map<String, List<AppIntentModel>>>((ref) => {});

/// Provider to manage the current pending intent for an app
final pendingIntentProvider =
    StateProvider<Map<String, AppIntent?>>((ref) => {});

/// Provider to track apps that require intent prompt
final intentRequiredAppsProvider =
    StateProvider<Set<String>>((ref) => {});

/// Provider for intent-based rules/policies
final intentRulesProvider = StateProvider<Map<String, Set<AppIntent>>>((ref) {
  // Default rules: social and entertainment apps require intent prompts
  return {
    'social': {AppIntent.social, AppIntent.entertainment},
    'optional': {AppIntent.productivity, AppIntent.education},
  };
});

/// Notifier to manage intent state changes
class IntentNotifier extends StateNotifier<Map<String, List<AppIntentModel>>> {
  IntentNotifier() : super({});

  /// Add or update intent for an app
  void recordIntent(AppIntentModel intent) {
    final appIntents = state[intent.appPackage] ?? [];
    final updatedIntents = [...appIntents, intent];

    // Keep only last 100 intents per app to save memory
    if (updatedIntents.length > 100) {
      updatedIntents.removeAt(0);
    }

    state = {
      ...state,
      intent.appPackage: updatedIntents,
    };
  }

  /// Get most recent intent for an app
  AppIntent? getRecentIntent(String appPackage) {
    final intents = state[appPackage];
    if (intents == null || intents.isEmpty) return null;
    return intents.last.intent;
  }

  /// Get intent frequency for an app
  Map<AppIntent, int> getIntentFrequency(String appPackage) {
    final intents = state[appPackage];
    if (intents == null) return {};

    final frequency = <AppIntent, int>{};
    for (final intent in intents) {
      frequency[intent.intent] = (frequency[intent.intent] ?? 0) + 1;
    }
    return frequency;
  }

  /// Clear history for an app
  void clearHistory(String appPackage) {
    final newState = Map<String, List<AppIntentModel>>.from(state);
    newState.remove(appPackage);
    state = newState;
  }

  /// Clear all history
  void clearAllHistory() {
    state = {};
  }
}

/// Provider for intent notifier
final intentNotifierProvider =
    StateNotifierProvider<IntentNotifier, Map<String, List<AppIntentModel>>>(
  (ref) => IntentNotifier(),
);

/// Selector to get most recent intent for an app
final recentIntentProvider = Provider.family<AppIntent?, String>((ref, appPackage) {
  final history = ref.watch(intentNotifierProvider);
  final intents = history[appPackage];
  if (intents == null || intents.isEmpty) return null;
  return intents.last.intent;
});

/// Selector to get intent frequency for an app
final intentFrequencyProvider =
    Provider.family<Map<AppIntent, int>, String>((ref, appPackage) {
  final history = ref.watch(intentNotifierProvider);
  final intents = history[appPackage];
  if (intents == null) return {};

  final frequency = <AppIntent, int>{};
  for (final intent in intents) {
    frequency[intent.intent] = (frequency[intent.intent] ?? 0) + 1;
  }
  return frequency;
});

/// Selector to get most common intent for an app
final mostCommonIntentProvider =
    Provider.family<AppIntent?, String>((ref, appPackage) {
  final frequency = ref.watch(intentFrequencyProvider(appPackage));
  if (frequency.isEmpty) return null;

  AppIntent? mostCommon;
  int maxCount = 0;
  frequency.forEach((intent, count) {
    if (count > maxCount) {
      maxCount = count;
      mostCommon = intent;
    }
  });
  return mostCommon;
});
