// Copyright (c) 2024 NLP digitox
//
// SentimentMoodBridge — Phase 3.1.
//
// Merges the third disconnected signal source — MoodService's manual mood
// check-ins and behavioral heuristics — into a compact block the sentiment
// LLM can reason about, alongside usage metrics and extracted chat themes.
//
// Weighting decision (documented for TODO 3.1):
//   Mood check-ins are self-reported truth, but sparse. Chat themes are
//   frequent but noisy. Usage metrics are objective but narrow.
//   The LLM prompt therefore weights: usage metrics > mood check-ins > chat
//   themes, and lets the LLM resolve conflicts. This keeps the analysis
//   grounded in objective screen-time facts while still honouring explicit
//   check-ins ("I'm anxious") over keyword-derived guesses.

import 'package:nlp_digitox/features/mood/mood_service.dart';
import 'package:nlp_digitox/features/mood/models.dart';

class MoodSignal {
  /// Human-readable summary of recent mood check-ins, e.g.
  /// "Anxious (x2), Stressed (x1) today; recent avg -0.5".
  final String summary;

  /// Inline context block for the sentiment prompt (empty when no data).
  final String promptBlock;

  /// Dominant mood name in the last 7 days, or null.
  final String? dominantMood;

  const MoodSignal({
    required this.summary,
    required this.promptBlock,
    this.dominantMood,
  });
}

/// Builds a mood signal from [MoodService] for use by sentiment analysis.
class SentimentMoodBridge {
  static SentimentMoodBridge? _instance;
  static SentimentMoodBridge get instance {
    _instance ??= SentimentMoodBridge._();
    return _instance!;
  }

  SentimentMoodBridge._();

  /// Gather mood check-ins from the last 7 days plus the latest entry.
  Future<MoodSignal> buildSignal() async {
    try {
      final moodService = MoodService();
      final history = moodService.moodHistory;

      if (history.isEmpty) {
        return const MoodSignal(
          summary: 'No mood check-ins yet.',
          promptBlock: 'No mood check-ins recorded.',
        );
      }

      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(days: 7));
      final recent =
          history.where((e) => e.timestamp.isAfter(cutoff)).toList();
      final pool = recent.isEmpty ? history : recent;

      // Count moods over the window.
      final counts = <MoodType, int>{};
      for (final entry in pool) {
        counts[entry.mood] = (counts[entry.mood] ?? 0) + 1;
      }
      final sorted = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final dominant = sorted.first.key;
      final breakdown = sorted
          .take(3)
          .map((e) => '${e.key.displayName} (x${e.value})')
          .join(', ');

      final summary = '$breakdown over the last ${recent.isEmpty ? '30' : '7'} days; '
          'latest: ${pool.first.mood.displayName}'
          '${pool.first.stressLevel != null ? ', stress ${pool.first.stressLevel}/10' : ''}'
          '${pool.first.energyLevel != null ? ', energy ${pool.first.energyLevel}/10' : ''}';

      final promptBlock = '''
Self-reported mood check-ins (weight these — they are the user's own words):
- $summary
- Recent triggers: ${_joinedTriggers(pool)}
- Average sentiment score: ${_avgScore(pool).toStringAsFixed(2)} (-1 very negative, +1 very positive)
''';

      return MoodSignal(
        summary: summary,
        promptBlock: promptBlock,
        dominantMood: dominant.name,
      );
    } catch (e) {
      return const MoodSignal(
        summary: 'No mood check-ins yet.',
        promptBlock: 'No mood check-ins recorded.',
      );
    }
  }

  List<String> _joinedTriggers(List<MoodEntry> pool) {
    final triggerCounts = <String, int>{};
    for (final entry in pool) {
      for (final trigger in entry.triggers) {
        triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
      }
    }
    final sorted = triggerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.isEmpty) return const ['none reported'];
    return sorted.take(4).map((e) => '${e.key} (x${e.value})').toList();
  }

  double _avgScore(List<MoodEntry> pool) {
    if (pool.isEmpty) return 0;
    return pool
            .map((e) => e.mood.sentimentScore)
            .reduce((a, b) => a + b) /
        pool.length;
  }
}
