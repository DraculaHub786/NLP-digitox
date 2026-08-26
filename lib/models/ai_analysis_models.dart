// Copyright (c) 2026 NLP digitox
//
// Result models for AI sentiment analysis and recommendations.
//
// These replace the raw Map<String, double> / List<String> returned by
// providers. They carry an `isFallback` flag and a structured failure reason
// so the UI can distinguish real AI output from static fallback data
// (TODO Phase 1.2 / 1.3) instead of silently showing hardcoded numbers.

import 'dart:async';

import 'package:flutter/foundation.dart';

/// Canonical fallback sentiment percentages — the values users were seeing
/// when the real Groq call was failing. Kept here so providers, UI and tests
/// reference one source of truth.
const Map<String, double> kFallbackSentiment = {
  'Positive': 30.0,
  'Neutral': 45.0,
  'Negative': 10.0,
  'Anxious': 10.0,
  'Focused': 5.0,
};

/// Canonical fallback tips — shown only when the real call is unavailable.
const List<String> kFallbackRecommendations = [
  'Set one small focus goal for the next 20 minutes.',
  'Take a short break and return with a clear next task.',
  'Review today\'s habits and complete one quick win now.',
];

/// The five sentiment labels used everywhere in analysis and trends.
const List<String> kSentimentLabels = [
  'Positive',
  'Neutral',
  'Negative',
  'Anxious',
  'Focused',
];

/// The category of failure that caused a fallback result.
enum AiFailureType {
  /// Groq API key is empty or still the template placeholder.
  missingApiKey,

  /// Groq returned 401 / rejected the key.
  invalidApiKey,

  /// Groq returned 429 / quota or rate limit exceeded.
  quotaExceeded,

  /// Network-level failure (no connection, DNS, refused).
  network,

  /// The request exceeded its timeout window.
  timeout,

  /// The LLM response could not be parsed into sentiment/recommendations.
  parseFailure,

  /// The screen-time goal is null — analysis cannot be computed.
  missingGoal,

  /// Groq returned a 5xx or other server-side error.
  serverError,

  /// Anything else.
  unknown,
}

/// A structured description of why an AI request failed.
class AiFailure {
  final AiFailureType type;

  /// Human-readable reason safe to show in the UI.
  final String message;

  const AiFailure(this.type, this.message);

  @override
  String toString() => 'AiFailure(${type.name}: $message)';
}

/// Classify an arbitrary error into a [AiFailure] so the provider logs
/// *which* failure mode occurred (key vs. goal vs. parse vs. network)
/// rather than swallowing them all identically.
AiFailure classifyAiFailure(Object error) {
  if (error is TimeoutException) {
    return const AiFailure(AiFailureType.timeout, 'The request timed out.');
  }

  final message = error.toString().toLowerCase();

  if (message.contains('key is not configured') ||
      message.contains('api key is not configured')) {
    return const AiFailure(
      AiFailureType.missingApiKey,
      'Groq API key is not configured.',
    );
  }
  if (message.contains('"api key"') ||
      message.contains('invalid api key') ||
      message.contains('invalid key')) {
    return const AiFailure(
      AiFailureType.invalidApiKey,
      'The Groq API key is invalid. Update it in Settings.',
    );
  }
  if (message.contains('401') || message.contains('unauthorized')) {
    return const AiFailure(
      AiFailureType.invalidApiKey,
      'The Groq API key was rejected (401). Update it in Settings.',
    );
  }
  if (message.contains('429') ||
      message.contains('quota') ||
      message.contains('rate limit')) {
    return const AiFailure(
      AiFailureType.quotaExceeded,
      'Groq rate/quota limit reached. Try again in a minute.',
    );
  }
  if (message.contains('failed to parse') ||
      message.contains('formatexception') ||
      message.contains('parse error') ||
      message.contains('json')) {
    return const AiFailure(
      AiFailureType.parseFailure,
      'The AI response could not be parsed.',
    );
  }
  if (message.contains('socket') ||
      message.contains('connection') ||
      message.contains('failed host lookup') ||
      message.contains('clientexception') ||
      message.contains('network') ||
      message.contains('connection refused')) {
    return const AiFailure(
      AiFailureType.network,
      'Network error — check your internet connection.',
    );
  }
  if (message.contains('api error: 5')) {
    return const AiFailure(
      AiFailureType.serverError,
      'The AI service had a server error. Try again later.',
    );
  }
  if (message.contains('api error:')) {
    return AiFailure(
      AiFailureType.serverError,
      'The AI service returned an error: ${error.toString().trim()}',
    );
  }

  debugPrint('⚠️ classifyAiFailure: unclassified error: $error');
  return const AiFailure(AiFailureType.unknown, 'Unexpected analysis error.');
}

/// Result of a sentiment analysis call, with an `isFallback` flag.
class SentimentResult {
  final Map<String, double> sentiments;
  final bool isFallback;
  final AiFailure? failure;

  const SentimentResult({
    required this.sentiments,
    this.isFallback = false,
    this.failure,
  });

  /// Build a fallback result (real call failed or inputs missing).
  const SentimentResult.fallback(AiFailure this.failure)
      : sentiments = kFallbackSentiment,
        isFallback = true;

  Map<String, dynamic> toJson() => {
        'sentiments': sentiments,
        'isFallback': isFallback,
        if (failure != null)
          'failure': {'type': failure!.type.name, 'message': failure!.message},
      };

  factory SentimentResult.fromJson(Map<String, dynamic> json) {
    final sentiments = _decodeSentiments(json['sentiments']);
    final isFallback = json['isFallback'] == true;
    if (isFallback) {
      final failureJson = json['failure'];
      final failure = failureJson is Map<String, dynamic>
          ? AiFailure(
              AiFailureType.values.firstWhere(
                (e) => e.name == failureJson['type'],
                orElse: () => AiFailureType.unknown,
              ),
              failureJson['message'] as String? ?? 'Unknown failure',
            )
          : const AiFailure(AiFailureType.unknown, 'Unknown failure');
      return SentimentResult.fallback(failure);
    }
    return SentimentResult(sentiments: sentiments);
  }
}

/// Result of a recommendations call, with an `isFallback` flag.
class RecommendationsResult {
  final List<String> recommendations;
  final bool isFallback;
  final AiFailure? failure;

  const RecommendationsResult({
    required this.recommendations,
    this.isFallback = false,
    this.failure,
  });

  /// Build a fallback result (real call failed or inputs missing).
  const RecommendationsResult.fallback(AiFailure this.failure)
      : recommendations = kFallbackRecommendations,
        isFallback = true;

  Map<String, dynamic> toJson() => {
        'recommendations': recommendations,
        'isFallback': isFallback,
        if (failure != null)
          'failure': {'type': failure!.type.name, 'message': failure!.message},
      };

  factory RecommendationsResult.fromJson(Map<String, dynamic> json) {
    final recommendations = (json['recommendations'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final isFallback = json['isFallback'] == true;
    if (isFallback) {
      final failureJson = json['failure'];
      final failure = failureJson is Map<String, dynamic>
          ? AiFailure(
              AiFailureType.values.firstWhere(
                (e) => e.name == failureJson['type'],
                orElse: () => AiFailureType.unknown,
              ),
              failureJson['message'] as String? ?? 'Unknown failure',
            )
          : const AiFailure(AiFailureType.unknown, 'Unknown failure');
      return RecommendationsResult.fallback(failure);
    }
    return RecommendationsResult(recommendations: recommendations);
  }
}

/// One day's persisted sentiment analysis — the building block of trends
/// (TODO Phase 3.2). Keyed by date; pruned alongside the 30-day chat window.
class SentimentSnapshot {
  final DateTime day;
  final Map<String, double> sentiments;

  const SentimentSnapshot({required this.day, required this.sentiments});

  Map<String, dynamic> toJson() => {
        'd': day.toIso8601String(),
        's': sentiments,
      };

  factory SentimentSnapshot.fromJson(Map<String, dynamic> json) {
    return SentimentSnapshot(
      day: DateTime.tryParse(json['d'] as String? ?? '') ?? DateTime.now(),
      sentiments: _decodeSentiments(json['s']),
    );
  }
}

/// Computed trend over persisted daily snapshots: last-7-days average vs the
/// 7 days before that, plus per-label percentage-point deltas (Phase 3.2).
class SentimentTrend {
  final List<SentimentSnapshot> history;

  /// Average of each label over the last 7 days (including today).
  final Map<String, double> recentAverage;

  /// Average of each label over the 7 days before the recent window.
  final Map<String, double> previousAverage;

  /// Per-label percentage-point change (recent − previous). Only labels that
  /// moved by at least 2 points are included.
  final Map<String, double> deltas;

  const SentimentTrend({
    required this.history,
    required this.recentAverage,
    required this.previousAverage,
    required this.deltas,
  });

  bool get isAvailable => history.isNotEmpty && deltas.isNotEmpty;

  /// Human-readable headline for the biggest movement, e.g.
  /// "Anxious is up 8 pts vs last week". Null when no trend is computable.
  String? get headline {
    if (deltas.isEmpty) return null;
    final biggest =
        deltas.entries.reduce((a, b) => b.value.abs() > a.value.abs() ? b : a);
    final direction = biggest.value >= 0 ? 'up' : 'down';
    return '${biggest.key} is $direction ${biggest.value.abs().toStringAsFixed(0)} pts vs last week';
  }
}

Map<String, double> _decodeSentiments(Object? raw) {
  final map = <String, double>{};
  if (raw is Map) {
    raw.forEach((key, value) {
      if (value is num) map[key.toString()] = value.toDouble();
    });
  }
  return map;
}
