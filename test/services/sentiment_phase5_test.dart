// Copyright (c) 2026 NLP digitox
//
// Phase 5 verification tests — sentiment system.
//
// 5.2  Sentiment output must shift when the underlying signals change:
//      verified by saving distinct per-day snapshots and asserting
//      computeTrend() reports movement, and by seeding distinct per-day
//      extracted themes and asserting getRecentThemes() aggregates them
//      (varied 30-day chat -> varied accumulated context -> varied LLM input).
// 5.3  Auto-deletion at the 30-day boundary must remove old chat sessions,
//      extracted context, AND persisted sentiment snapshots together:
//      verified with a single cleanupOldChats() call against seeded 31-day-old
//      data.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/services/ai_chatbot_service.dart';
import 'package:nlp_digitox/core/services/chat_context_extractor.dart';
import 'package:nlp_digitox/core/services/sentiment_persistence_service.dart';
import 'package:nlp_digitox/models/ai_analysis_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  group('Phase 5.2 — sentiment shifts with signal changes', () {
    test('computeTrend reports movement when recent days differ from previous week', () async {
      SharedPreferences.setMockInitialValues({});
      final persistence = SentimentPersistenceService.instance;
      final now = DateTime.now();

      // Previous window (anxious-heavy).
      for (final offset in [10, 9]) {
        await persistence.saveDay(
          now.subtract(Duration(days: offset)),
          SentimentResult(sentiments: {
            'Positive': 20,
            'Neutral': 25,
            'Negative': 15,
            'Anxious': 35,
            'Focused': 5,
          }),
        );
      }

      // Recent window (positive-heavy).
      for (final offset in [2, 1]) {
        await persistence.saveDay(
          now.subtract(Duration(days: offset)),
          SentimentResult(sentiments: {
            'Positive': 60,
            'Neutral': 20,
            'Negative': 5,
            'Anxious': 5,
            'Focused': 10,
          }),
        );
      }

      final trend = await persistence.computeTrend();
      expect(trend.isAvailable, isTrue);
      expect(trend.deltas['Positive'], greaterThanOrEqualTo(2.0));
      expect(trend.deltas['Anxious'], lessThanOrEqualTo(-2.0));
      expect(trend.headline, isNotNull);
    });

    test('getRecentThemes aggregates distinct per-day themes across the window', () async {
      final now = DateTime.now();
      SharedPreferences.setMockInitialValues({
        'extracted_chat_context_v1': jsonEncode({
          dayKey(now.subtract(const Duration(days: 2))): [
            {'t': 'work', 'm': 4},
            {'t': 'anxiety', 'm': 3},
          ],
          dayKey(now.subtract(const Duration(days: 1))): [
            {'t': 'sleep', 'm': 5},
          ],
        }),
      });

      final themes = await ChatContextExtractor.instance.getRecentThemes();
      expect(themes.length, greaterThanOrEqualTo(3));
      expect(themes.any((t) => t.contains('work')), isTrue);
      expect(themes.any((t) => t.contains('sleep')), isTrue);
      expect(themes.any((t) => t.contains('anxiety')), isTrue);
      // Mention counts accumulate across days.
      expect(themes.any((t) => t.contains('x5')), isTrue);
    });
  });

  group('Phase 5.3 — 30-day auto-deletion prunes sessions, themes and snapshots together', () {
    test('cleanupOldChats removes old chat sessions, extracted context and sentiment snapshots', () async {
      final now = DateTime.now();
      final old = now.subtract(const Duration(days: 31));
      final recent = now.subtract(const Duration(days: 1));

      ChatMessage msg(String text, DateTime at, {bool isUser = true}) =>
          ChatMessage(message: text, isUser: isUser, timestamp: at);

      final oldSession = ChatSession(
        id: 'old-1',
        title: 'Old',
        createdAt: old,
        lastMessageAt: old,
        messages: [msg('I was anxious about work', old)],
      );
      final newSession = ChatSession(
        id: 'new-1',
        title: 'New',
        createdAt: recent,
        lastMessageAt: recent,
        messages: [msg('Feeling good today', recent)],
      );

      SharedPreferences.setMockInitialValues({
        'ai_chat_sessions': jsonEncode([oldSession.toMap(), newSession.toMap()]),
        'extracted_chat_context_v1': jsonEncode({
          dayKey(old): [
            {'t': 'work', 'm': 6},
          ],
          dayKey(recent): [
            {'t': 'focus', 'm': 2},
          ],
        }),
        'sentiment_snapshots_v1': jsonEncode({
          dayKey(old): {
            'd': old.toIso8601String(),
            's': {
              'Positive': 10,
              'Neutral': 10,
              'Negative': 40,
              'Anxious': 35,
              'Focused': 5,
            },
          },
          dayKey(recent): {
            'd': recent.toIso8601String(),
            's': {
              'Positive': 55,
              'Neutral': 20,
              'Negative': 5,
              'Anxious': 5,
              'Focused': 15,
            },
          },
        }),
      });

      await AIChatbotService.instance.cleanupOldChats();

      // Old chat session gone, recent one still present.
      final sessions = AIChatbotService.instance.getAllSessions();
      expect(sessions.any((s) => s.id == 'old-1'), isFalse);
      expect(sessions.any((s) => s.id == 'new-1'), isTrue);

      // Extracted context pruned to the recent day only.
      expect(await ChatContextExtractor.instance.storedDayCount(), 1);

      // Sentiment snapshots pruned to the recent day only.
      final history = await SentimentPersistenceService.instance.loadHistory();
      expect(history.length, 1);
      expect(dayKey(history.first.day), dayKey(recent));
    });
  });
}
