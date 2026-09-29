// Copyright (c) 2026 NLP digitox
//
// ChatContextExtractor — Phase 2 "real context" extraction.
//
// Pulls messages across ALL chat sessions in the 30-day retention window
// (not just the current in-memory session), extracts recurring themes via
// lightweight local keyword/topic frequency analysis (TODO 2.2 "simple/fast"
// option), and persists the extracted context keyed by date so it
// accumulates over the window instead of being recomputed from scratch on
// every sentiment check (TODO 2.3).
//
// The 30-day auto-deletion in AIChatbotService calls [pruneBefore] so stored
// themes die with their source sessions (TODO 2.5).

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nlp_digitox/core/services/ai_chatbot_service.dart';

/// A recurring theme with how many times it was observed.
class ChatTheme {
  final String topic;
  final int mentions;

  const ChatTheme(this.topic, this.mentions);

  Map<String, dynamic> toJson() => {'t': topic, 'm': mentions};

  factory ChatTheme.fromJson(Map<String, dynamic> json) {
    final rawMentions = json['m'];
    final mentions = rawMentions is num ? rawMentions.toInt() : 0;
    return ChatTheme(
      json['t'] as String? ?? 'unknown',
      mentions,
    );
  }

  @override
  String toString() => '$topic (x$mentions)';
}

/// Lightweight topic extraction + local persistence over the chat retention
/// window. Pure local computation — no extra LLM calls (TODO 2.2).
class ChatContextExtractor {
  static ChatContextExtractor? _instance;
  static ChatContextExtractor get instance {
    _instance ??= ChatContextExtractor._();
    return _instance!;
  }

  ChatContextExtractor._();

  static const String _storageKey = 'extracted_chat_context_v1';

  /// Number of days of chat history to consider (matches chat auto-deletion).
  static const int retentionDays = 30;

  /// Max themes kept per day / per query.
  static const int topThemesCount = 8;

  /// Topic dictionary: canonical topic -> keywords that signal it.
  static const Map<String, List<String>> _topicKeywords = {
    'sleep': ['sleep', 'tired', 'insomnia', 'rest', 'wake', 'bedtime', 'exhausted', 'slept'],
    'work': ['work', 'deadline', 'job', 'office', 'project', 'meeting', 'boss', 'shift', 'client'],
    'study': ['exam', 'study', 'test', 'revision', 'syllabus', 'assignment', 'studying', 'results'],
    'anxiety': ['anxious', 'anxiety', 'stress', 'stressed', 'worried', 'overwhelm', 'panic', 'nervous'],
    'family': ['family', 'mom', 'dad', 'parent', 'kids', 'children', 'brother', 'sister', 'home'],
    'social media': ['instagram', 'tiktok', 'reels', 'youtube', 'scrolling', 'social media', 'shorts', 'feed'],
    'focus': ['focus', 'distracted', 'concentration', 'procrastinat', 'attention', 'mindful', 'distraction'],
    'health': ['health', 'workout', 'gym', 'exercise', 'diet', 'food', 'meditation', 'fitness', 'walk'],
    'loneliness': ['lonely', 'alone', 'sad', 'depressed', 'down', 'isolated', 'crying'],
    'productivity': ['productive', 'productivity', 'efficient', 'organize', 'plan', 'routine', 'schedule', 'habits'],
    'phone usage': ['phone', 'screen time', 'addicted', 'usage', 'detox', 'notification', 'hours', 'battery'],
  };

  /// Extract one day's themes from chat sessions and persist them.
  /// `day` defaults to today. Returns the persisted themes for that day.
  Future<List<ChatTheme>> extractDay(DateTime day) async {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    int totalMentions = 0;
    final counts = <String, int>{};

    for (final session in AIChatbotService.instance.getAllSessions()) {
      for (final message in session.messages) {
        if (!message.isUser) continue;
        if (message.timestamp.isBefore(startOfDay) ||
            message.timestamp.isAfter(endOfDay)) {
          continue;
        }
        final lower = message.message.toLowerCase();
        _topicKeywords.forEach((topic, keywords) {
          for (final keyword in keywords) {
            if (lower.contains(keyword)) {
              counts[topic] = (counts[topic] ?? 0) + 1;
              totalMentions++;
              break;
            }
          }
        });
      }
    }

    final themes = counts.entries
        .where((e) => e.value >= 2) // a theme needs at least 2 mentions
        .map((e) => ChatTheme(e.key, e.value))
        .toList()
      ..sort((a, b) => b.mentions.compareTo(a.mentions));
    final top = themes.take(topThemesCount).toList();

    final key = _dayKey(startOfDay);
    if (top.isEmpty) {
      await _removeDay(key);
    } else {
      await _storeDay(key, top);
    }

    debugPrint('🧠 ChatContextExtractor: day $key → ${top.map((t) => t.toString()).join(', ')} ($totalMentions mentions scanned)');
    return top;
  }

  /// Ensure today's entry is extracted (idempotent per day — it always
  /// re-extracts, cheap local computation, so the data is always fresh).
  Future<void> ensureTodayExtracted() => extractDay(DateTime.now());

  /// Get accumulated themes across the retention window. Prunes entries
  /// older than the window first. Topics are returned newest-first by day,
  /// with counts accumulated; only the most frequent are kept.
  ///
  /// Returns a list of human-readable theme summaries, e.g.
  /// `["work", "sleep (x5)", "anxiety (x3)"]`, or an empty list when there
  /// is no chat history in the window.
  Future<List<String>> getRecentThemes({int days = retentionDays}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    await pruneBefore(cutoff);

    final stored = await _loadAllDays();
    final totalMentions = <String, int>{};
    for (final entry in stored.entries) {
      if (DateTime.parse(entry.key).isBefore(cutoff)) continue;
      for (final theme in entry.value) {
        totalMentions[theme.topic] =
            (totalMentions[theme.topic] ?? 0) + theme.mentions;
      }
    }

    final sorted = totalMentions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.isEmpty) return const [];

    final top = sorted.take(topThemesCount);
    return top
        .map((e) => e.value > 1 ? '${e.key} (x${e.value})' : e.key)
        .toList();
  }

  /// Delete stored context entries older than [cutoff]. Called by
  /// AIChatbotService's auto-deletion so themes are not orphaned past the
  /// retention window (TODO 2.5).
  Future<void> pruneBefore(DateTime cutoff) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;

    try {
      final all = json.decode(raw) as Map<String, dynamic>;
      final before = all.length;
      all.removeWhere(
          (dateKey, _) => DateTime.parse(dateKey).isBefore(cutoff));
      if (all.length != before) {
        if (all.isEmpty) {
          await prefs.remove(_storageKey);
        } else {
          await prefs.setString(_storageKey, json.encode(all));
        }
        debugPrint('🧠 ChatContextExtractor: pruned ${before - all.length} day(s) of stored themes (older than $cutoff)');
      }
    } catch (e) {
      debugPrint('⚠️ ChatContextExtractor: error pruning stored context: $e');
    }
  }

  /// Number of stored context days (debug/health check).
  Future<int> storedDayCount() async {
    final all = await _loadAllDays();
    return all.length;
  }

  // ── Storage helpers ────────────────────────────────────────────

  String _dayKey(DateTime day) =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  Future<void> _storeDay(String key, List<ChatTheme> themes) async {
    final prefs = await SharedPreferences.getInstance();
    final all = <String, dynamic>{};
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        all.addAll(json.decode(raw) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('⚠️ ChatContextExtractor: error reading stored context: $e');
      }
    }
    all[key] = themes.map((t) => t.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(all));
  }

  Future<void> _removeDay(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final all = <String, dynamic>{};
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        all.addAll(json.decode(raw) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('⚠️ ChatContextExtractor: error reading stored context: $e');
      }
    }
    if (all.containsKey(key)) {
      all.remove(key);
      await prefs.setString(_storageKey, json.encode(all));
    }
  }

  Future<Map<String, List<ChatTheme>>> _loadAllDays(
      {SharedPreferences? prefs}) async {
    final resolved = prefs ?? await SharedPreferences.getInstance();
    final raw = resolved.getString(_storageKey);
    if (raw == null) return {};

    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return decoded.map((dateKey, value) {
        final themes = (value as List<dynamic>)
            .map((e) => ChatTheme.fromJson(e as Map<String, dynamic>))
            .toList();
        return MapEntry(dateKey, themes);
      });
    } catch (e) {
      debugPrint('⚠️ ChatContextExtractor: error loading stored context: $e');
      return {};
    }
  }
}
