// Copyright (c) 2026 NLP digitox
// DailySentimentScoringService - End-of-day sentiment scoring using Groq API.
// Uses openai/gpt-oss-20b, stores in Firestore 30-day rolling window.

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nlp_digitox/config/api_keys.dart';
import 'package:nlp_digitox/core/services/ai_chatbot_service.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';

/// Scores each day's chat messages on a -1.0 .. +1.0 scale and keeps a rolling
/// 30-day window of results in Firestore.
///
/// Scores live in `users/{uid}/daily_sentiment_scores/{yyyy-MM-dd}` (the source
/// of truth, queried by [get30DayHistory]) and are mirrored into a
/// `wellbeingScores` array on `users/{uid}` for cheap single-document reads.
class DailySentimentScoringService {
  DailySentimentScoringService._();
  static final DailySentimentScoringService instance =
      DailySentimentScoringService._();

  static const String _apiUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'openai/gpt-oss-20b';
  static const Duration _requestTimeout = Duration(seconds: 30);
  static const String _scoresCollection = 'daily_sentiment_scores';
  static const int _retentionDays = 30;

  /// Scores today's chat messages. Convenience wrapper over [scoreDay].
  Future<double?> runDailyScoring() => scoreDay(DateTime.now());

  /// Scores [day]'s chat messages and stores the result under that day's key.
  ///
  /// Returns the score, or null when the day has nothing to score, was already
  /// scored (unless [force] is set), or the API call failed.
  ///
  /// Scoring an arbitrary day — rather than always "today" — is what makes the
  /// nightly job correct: by the time it runs, the day it belongs to has
  /// already ended, and the app may not have been open at all.
  Future<double?> scoreDay(DateTime day, {bool force = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      if (!force && await hasScoreForDay(day, userId: user.uid)) {
        debugPrint(
          'DailySentimentScoringService: ${dayKeyOf(day)} already scored, skipping',
        );
        return null;
      }

      final messages = await AIChatbotService.getUserMessagesForDay(day);
      if (messages.isEmpty) {
        debugPrint(
          'DailySentimentScoringService: no chat messages on ${dayKeyOf(day)}, skipping',
        );
        return null;
      }

      final score = await _scoreMessages(messages, day: day);
      if (score == null) return null;

      await _storeScore(user.uid, score, day: day);
      await _pruneOldScores(user.uid);
      debugPrint(
        'DailySentimentScoringService: Scored ${dayKeyOf(day)} as $score',
      );
      return score;
    } catch (e) {
      debugPrint('DailySentimentScoringService: Error - $e');
      return null;
    }
  }

  /// Fills in every day inside the retention window (today excluded) that has
  /// chat messages but no stored score — i.e. every day the app was never open
  /// when the score should have been taken.
  ///
  /// Days without messages are skipped without spending an API call. Returns
  /// the number of days that were newly scored.
  Future<int> runCatchUpScoring({int lookbackDays = _retentionDays}) async {
    final today = DateTime.now();
    final byDay = await AIChatbotService.getUserMessagesByDay(
      from: today.subtract(Duration(days: lookbackDays)),
      toExclusive: today,
    );

    var scoredDays = 0;
    for (final dayKey in byDay.keys.toList()..sort()) {
      final day = dateFromDayKey(dayKey);
      if (day == null) continue;
      if (await scoreDay(day) != null) scoredDays++;
    }

    if (scoredDays > 0) {
      debugPrint(
        'DailySentimentScoringService: Catch-up scored $scoredDays day(s)',
      );
    }
    return scoredDays;
  }

  /// Whether a score document already exists for [day].
  ///
  /// Pass [userId] when the current user is already known (the background
  /// isolate has no signed-in client state to fall back on).
  Future<bool> hasScoreForDay(DateTime day, {String? userId}) async {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection(_scoresCollection)
          .doc(dayKeyOf(day))
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('DailySentimentScoringService.hasScoreForDay: Error - $e');
      return false;
    }
  }

  Future<double?> _scoreMessages(List<String> messages, {DateTime? day}) async {
    if (ApiKeys.groqApiKey.isEmpty) return null;
    final conversationText = messages.join('\n');
    final dayLabel =
        day == null ? '' : 'Date being analysed: ${dayKeyOf(day)}\n';
    final prompt = '''Analyze the following day's conversation between a user and a digital wellbeing assistant.
${dayLabel}Return a SINGLE number between -1.0 and +1.0 representing the user's overall digital wellbeing sentiment for the day:
-1.0 = Very negative (high anxiety, frustration, digital overload, giving up)
-0.5 = Somewhat negative (stressed about screen time, struggling but trying)
 0.0 = Neutral (balanced, matter-of-fact about usage)
+0.5 = Somewhat positive (making progress, feeling in control)
+1.0 = Very positive (thriving, excellent digital habits, motivated)
Conversation:
$conversationText
Return ONLY the number (e.g., "0.3" or "-0.7"), nothing else.''';
    try {
      final response = await http.post(Uri.parse(_apiUrl), headers: {
        'Authorization': 'Bearer ${ApiKeys.groqApiKey}', 'Content-Type': 'application/json',
      }, body: jsonEncode({'model': _model, 'messages': [
        {'role': 'system', 'content': 'You are a precise sentiment analyzer. Return only a single decimal number between -1.0 and +1.0.'},
        {'role': 'user', 'content': prompt},
      ], 'max_tokens': 10, 'temperature': 0.1,})).timeout(_requestTimeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        final score = double.tryParse(content.trim());
        if (score != null && score >= -1.0 && score <= 1.0) {
          return score.clamp(-1.0, 1.0);
        }
        return null;
      } else {
        debugPrint(
          'DailySentimentScoringService: API error ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('DailySentimentScoringService: Scoring error - $e');
      return null;
    }
  }

  /// Writes [score] to its own day document and rebuilds the deduplicated,
  /// 30-entry `wellbeingScores` array on the user document.
  ///
  /// The array is read-modify-written inside a transaction rather than updated
  /// with `arrayUnion` for two reasons: Firestore rejects `serverTimestamp()`
  /// nested inside an `arrayUnion` element, and `arrayUnion` would append a
  /// duplicate entry every time a day is re-scored instead of replacing it.
  Future<void> _storeScore(
    String userId,
    double score, {
    required DateTime day,
  }) async {
    final dayKey = dayKeyOf(day);
    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection('users').doc(userId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final existing =
          (snapshot.data()?['wellbeingScores'] as List?) ?? const [];

      final windowed = windowScores(
        existing,
        dayKey: dayKey,
        score: score,
        day: day,
      );

      transaction.set(
        userRef,
        {
          'wellbeingScores': windowed,
          'lastWellbeingScore': score,
          'lastWellbeingScoreDate': Timestamp.fromDate(DateTime.now()),
        },
        SetOptions(merge: true),
      );
      transaction.set(
        userRef.collection(_scoresCollection).doc(dayKey),
        {'score': score, 'date': Timestamp.fromDate(day), 'model': _model},
      );
    });
  }

  /// Pure windowing step behind [_storeScore]: drop any stored entry for
  /// [dayKey], append the new score, sort by date, and keep only the newest
  /// [retentionDays] entries.
  ///
  /// Extracted so the "replace on re-score, never append" regression — the one
  /// the transactional rewrite fixed — can be unit-tested without Firestore.
  /// `arrayUnion` would have appended a duplicate entry every time a day was
  /// re-scored; this rebuilds the list with the day replaced instead.
  @visibleForTesting
  static List<Map<String, dynamic>> windowScores(
    List<dynamic> existing, {
    required String dayKey,
    required double score,
    required DateTime day,
    int retentionDays = _retentionDays,
  }) {
    final retained = existing
        .whereType<Map<String, dynamic>>()
        .where((entry) => entry['date'] != dayKey)
        .toList()
      ..add({
        'date': dayKey,
        'score': score,
        'timestamp': Timestamp.fromDate(day),
      });
    retained.sort(
      (a, b) => (a['date'] as String).compareTo(b['date'] as String),
    );
    return retained.length > retentionDays
        ? retained.sublist(retained.length - retentionDays)
        : retained;
  }

  /// Deletes score documents older than the retention window. The user-document
  /// array is trimmed in [_storeScore], so both copies expire on the same clock.
  Future<void> _pruneOldScores(String userId) async {
    final cutoff = DateTime.now().subtract(Duration(days: _retentionDays));
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection(_scoresCollection)
        .where(FieldPath.documentId, isLessThan: dayKeyOf(cutoff))
        .get();
    if (snapshot.docs.isEmpty) return;

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// The stored scores for the last 30 days, oldest first.
  Future<List<DailyScore>> get30DayHistory(String userId) async {
    final cutoff =
        DateTime.now().subtract(Duration(days: _retentionDays - 1));
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(_scoresCollection)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: dayKeyOf(cutoff))
        .orderBy(FieldPath.documentId)
        .get();

    final scores = <DailyScore>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final storedDate = data['date'];
      final date =
          storedDate is Timestamp ? storedDate.toDate() : dateFromDayKey(doc.id);
      final score = data['score'];
      if (date == null || score is! num) continue;
      scores.add(DailyScore(date: date, score: score.toDouble()));
    }
    return scores;
  }

  Future<double?> getLatestScore(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(_scoresCollection)
        .orderBy(FieldPath.documentId, descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final score = snapshot.docs.first.data()['score'];
    return score is num ? score.toDouble() : null;
  }
}

class DailyScore {
  final DateTime date;
  final double score;

  const DailyScore({required this.date, required this.score});

  String get dayKey => dayKeyOf(date);

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'score': score,
      };
}
