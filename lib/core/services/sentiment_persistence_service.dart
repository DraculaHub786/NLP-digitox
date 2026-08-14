// Copyright (c) 2026 NLP digitox
//
// SentimentPersistenceService — Phase 3.
//
// 3.2  Persist each day's sentiment result (not just the latest) so trends
//      ("more anxious than last week") can be computed instead of a
//      point-in-time snapshot.
// 3.4  Lightweight local cache with a short TTL (re-analyze at most once per
//      hour, not on every provider read). Riverpod's `aiSentimentProvider` is
//      a plain FutureProvider so each invalidation would otherwise re-call the
//      LLM; this service gives us an explicit hour TTL on top.
//
// Snapshots live in SharedPreferences under `sentiment_snapshots_v1`, keyed
// by date-only. `AIChatbotService`'s 30-day auto-deletion also prunes here so
// old snapshots never outlive the retention window (same rule as Phase 2.5).

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nlp_digitox/models/ai_analysis_models.dart';

class SentimentPersistenceService {
  static SentimentPersistenceService? _instance;
  static SentimentPersistenceService get instance {
    _instance ??= SentimentPersistenceService._();
    return _instance!;
  }

  SentimentPersistenceService._();

  static const String _snapshotsKey = 'sentiment_snapshots_v1';
  static const String _lastAnalysisKey = 'sentiment_last_analysis_ms';
  static const String _shownTipsKey = 'sentiment_shown_tips_v1';
  static const String _dismissedTipsKey = 'sentiment_dismissed_tips_v1';

  /// Retention window for snapshots (matches chat auto-deletion).
  static const int retentionDays = 30;

  /// Re-analysis TTL — analysis is recomputed at most once per hour.
  static const Duration analysisTtl = Duration(hours: 1);

  /// How many of the most recent shown tips to remember.
  static const int shownTipsWindow = 7;

  String _dayKey(DateTime day) =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  // ── Snapshot persistence (Phase 3.2) ──────────────────────────────

  /// Persist today's real sentiment result. Fallback results are not stored —
  /// a fallback means the call failed, and storing it would poison trends.
  Future<void> saveToday(SentimentResult result) async {
    if (result.isFallback) return;
    await saveDay(dateTodayOnly, result);
  }

  Future<void> saveDay(DateTime day, SentimentResult result) async {
    if (result.isFallback) return;
    final prefs = await SharedPreferences.getInstance();
    final all = await _loadAll(prefs);

    final key = _dayKey(day);
    all[key] = SentimentSnapshot(
      day: DateTime.parse(key),
      sentiments: result.sentiments,
    ).toJson();

    await _saveAll(prefs, all);
    debugPrint('📈 SentimentPersistenceService: saved ${result.sentiments} for $key');
  }

  /// Load all persisted snapshots, oldest first.
  Future<List<SentimentSnapshot>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _loadAll(prefs);
    final snapshots = all.values
        .map((json) => SentimentSnapshot.fromJson(json as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    return snapshots;
  }

  /// Compute a 7-day vs previous-7-day trend from persisted snapshots.
  Future<SentimentTrend> computeTrend() async {
    final history = await loadHistory();
    if (history.isEmpty) {
      return const SentimentTrend(
        history: [],
        recentAverage: {},
        previousAverage: {},
        deltas: {},
      );
    }

    final today = dateTodayOnly;
    final recentWindowStart = today.subtract(const Duration(days: 6));
    final previousWindowStart = today.subtract(const Duration(days: 13));

    final recent = history
        .where((s) => !s.day.isBefore(recentWindowStart) && !s.day.isAfter(today))
        .toList();
    final previous = history
        .where((s) => !s.day.isBefore(previousWindowStart) && s.day.isBefore(recentWindowStart))
        .toList();

    final recentAverage = _averageLabels(recent);
    final previousAverage = _averageLabels(previous);

    final deltas = <String, double>{};
    for (final label in kSentimentLabels) {
      final delta = (recentAverage[label] ?? 0) - (previousAverage[label] ?? 0);
      if (delta.abs() >= 2 && previousAverage.isNotEmpty) {
        deltas[label] = delta;
      }
    }

    return SentimentTrend(
      history: history,
      recentAverage: recentAverage,
      previousAverage: previousAverage,
      deltas: deltas,
    );
  }

  /// Delete snapshots older than [cutoff]. Called from AIChatbotService's
  /// 30-day auto-deletion so stored results die with the chat window.
  Future<void> pruneBefore(DateTime cutoff) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _loadAll(prefs);
    final before = all.length;
    all.removeWhere((key, _) {
      final parsed = DateTime.tryParse(key);
      return parsed == null || parsed.isBefore(cutoff);
    });
    if (all.length != before) {
      await _saveAll(prefs, all);
      debugPrint('📈 SentimentPersistenceService: pruned ${before - all.length} snapshot(s) (older than $cutoff)');
    }
  }

  // ── Hour TTL cache (Phase 3.4) ─────────────────────────────────────

  /// Whether the last real analysis is still fresh enough to reuse.
  Future<bool> isCacheFresh() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_lastAnalysisKey);
    if (last == null) return false;
    return DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(last),
        ) <
        analysisTtl;
  }

  /// Stamp the last real analysis time.
  Future<void> stampAnalysisTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastAnalysisKey, DateTime.now().millisecondsSinceEpoch);
  }

  // ── Shown-tips history + feedback (Phase 4.1 / 4.3) ────────────────

  /// Load the most recent shown tips.
  Future<List<String>> getRecentShownTips() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_shownTipsKey) ?? const [];
    return raw.take(shownTipsWindow).toList();
  }

  /// Record tips as shown, keeping only the last [shownTipsWindow].
  Future<void> recordShownTips(List<String> tips) async {
    if (tips.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_shownTipsKey) ?? <String>[];
    // Newest first: prepend, then dedupe and trim to the window.
    final merged = [...tips, ...existing];
    final deduped = <String>[];
    for (final tip in merged) {
      if (!deduped.contains(tip)) deduped.add(tip);
    }
    await prefs.setStringList(
        _shownTipsKey, deduped.take(shownTipsWindow).toList());
    debugPrint('💬 SentimentPersistenceService: recorded ${tips.length} shown tip(s)');
  }

  /// Record thumbs feedback for a tip (only "not helpful" is persisted —
  /// used to steer future prompts away from disliked tips).
  Future<void> recordTipFeedback(String tip, bool helpful) async {
    if (helpful) return;
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getStringList(_dismissedTipsKey) ?? <String>[];
    if (!dismissed.contains(tip)) {
      dismissed.add(tip);
      // Cap to avoid unbounded growth.
      await prefs.setStringList(_dismissedTipsKey, dismissed.take(50).toList());
      debugPrint('👎 SentimentPersistenceService: tip marked not helpful');
    }
  }

  /// Load tips the user previously marked "not helpful".
  Future<List<String>> getDismissedTips() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_dismissedTipsKey) ?? const [];
  }

  // ── Helpers ────────────────────────────────────────────────────────

  DateTime get dateTodayOnly {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Map<String, double> _averageLabels(List<SentimentSnapshot> snapshots) {
    if (snapshots.isEmpty) return {};
    final totals = <String, double>{};
    for (final snapshot in snapshots) {
      for (final label in kSentimentLabels) {
        totals[label] = (totals[label] ?? 0) + (snapshot.sentiments[label] ?? 0);
      }
    }
    return totals.map(
      (label, total) => MapEntry(label, total / snapshots.length),
    );
  }

  Future<Map<String, dynamic>> _loadAll(SharedPreferences prefs) async {
    final raw = prefs.getString(_snapshotsKey);
    if (raw == null) return {};
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('⚠️ SentimentPersistenceService: error loading snapshots: $e');
      return {};
    }
  }

  Future<void> _saveAll(SharedPreferences prefs, Map<String, dynamic> all) async {
    if (all.isEmpty) {
      await prefs.remove(_snapshotsKey);
    } else {
      await prefs.setString(_snapshotsKey, json.encode(all));
    }
  }
}
