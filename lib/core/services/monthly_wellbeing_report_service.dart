// Copyright (c) 2026 NLP digitox
// MonthlyWellbeingReportService - Generates comprehensive monthly wellbeing reports
// using openai/gpt-oss-120b based on 30-day sentiment scores and usage data.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:nlp_digitox/config/api_keys.dart';
import 'package:nlp_digitox/core/services/daily_sentiment_scoring_service.dart';
import 'package:nlp_digitox/core/services/wellbeing_report_service.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/models/wellbeing_report_data.dart';

/// Builds the monthly AI wellbeing narrative from the last 30 days of daily
/// sentiment scores plus local usage data.
///
/// Reports are stored per month in
/// `users/{uid}/monthly_wellbeing_reports/{yyyy-MM}`, keyed by the month the
/// report is generated in. Generation is triggered by a scheduled Cloud
/// Function that drops a request marker (see [requestCollection] /
/// [requestDocId]) which the client polls — it cannot run server-side because
/// the chat transcripts and usage data it reads are device-local.
class MonthlyWellbeingReportService {
  MonthlyWellbeingReportService._();
  static final MonthlyWellbeingReportService instance =
      MonthlyWellbeingReportService._();

  static const String _apiUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'openai/gpt-oss-120b';
  static const Duration _requestTimeout = Duration(seconds: 60);
  static const String _reportsCollection = 'monthly_wellbeing_reports';

  /// Firestore location of the scheduler's "please generate" marker. It lives
  /// under `public/` because firestore.rules only grants authenticated clients
  /// read access there (`public/{document=**}`), and the scheduled function
  /// writes it with the Admin SDK, which bypasses rules entirely.
  static const String requestCollection = 'public';
  static const String requestDocId = 'monthly_wellbeing_report_request';

  /// Number of days of history each report is generated from.
  static const int reportingWindowDays = 30;

  /// Regenerates the current month's report, replacing any existing one.
  ///
  /// Returns null when there is nothing to report on (no scores yet) or the
  /// model call failed — callers must not treat null as "report is empty".
  Future<String?> generateMonthlyReport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      final scores =
          await DailySentimentScoringService.instance.get30DayHistory(user.uid);
      if (scores.isEmpty) {
        debugPrint(
          'MonthlyWellbeingReportService: no sentiment scores, nothing to report',
        );
        return null;
      }

      final range = _reportingRange(DateTime.now());
      final wellbeingData = await WellbeingReportService.instance
          .buildReport(range: range);
      final prompt = _buildReportPrompt(scores, wellbeingData, range);
      final report = await _generateReport(prompt);
      if (report == null) return null;

      await _storeReport(user.uid, report, scores, wellbeingData, range);
      debugPrint('MonthlyWellbeingReportService: Generated monthly report');
      return report;
    } catch (e) {
      debugPrint('MonthlyWellbeingReportService: Error - $e');
      return null;
    }
  }

  /// Generates this month's report only when one does not exist yet.
  ///
  /// This is what the scheduled trigger uses: the marker can be delivered more
  /// than once (app opened on several devices, function retried), and each run
  /// must not burn another 4000-token model call rewriting the same report.
  Future<String?> ensureMonthlyReport() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    final existing = await getReportForMonth(monthKeyOf(DateTime.now()));
    if (existing != null) {
      debugPrint('MonthlyWellbeingReportService: current month already reported');
      return existing;
    }
    return generateMonthlyReport();
  }

  /// Whether a report document exists for [monthKey] (`yyyy-MM`).
  Future<bool> hasReportForMonth(String monthKey) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;
    try {
      final doc = await _reportRef(userId, monthKey).get();
      return doc.exists;
    } catch (e) {
      debugPrint('MonthlyWellbeingReportService.hasReportForMonth: Error - $e');
      return false;
    }
  }

  /// The stored report for [monthKey], or null when it has not been generated.
  Future<String?> getReportForMonth(String monthKey) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;
    try {
      final doc = await _reportRef(userId, monthKey).get();
      if (!doc.exists) return null;
      return doc.data()?['report'] as String?;
    } catch (e) {
      debugPrint('MonthlyWellbeingReportService.getReportForMonth: Error - $e');
      return null;
    }
  }

  DocumentReference<Map<String, dynamic>> _reportRef(
    String userId,
    String monthKey,
  ) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(_reportsCollection)
          .doc(monthKey);

  /// The 30-day window a report generated at [generatedAt] describes.
  ///
  /// The stored `periodStart`/`periodEnd` must match the scores actually fed to
  /// the model, otherwise the report's own metadata contradicts its content.
  DateTimeRange _reportingRange(DateTime generatedAt) => DateTimeRange(
        start: generatedAt
            .subtract(const Duration(days: reportingWindowDays - 1)),
        end: generatedAt,
      );

  String _buildReportPrompt(
    List<DailyScore> scores,
    WellbeingReportData data,
    DateTimeRange range,
  ) {
    final avgScore =
        scores.map((s) => s.score).reduce((a, b) => a + b) / scores.length;
    final minScore =
        scores.map((s) => s.score).reduce((a, b) => a < b ? a : b);
    final maxScore =
        scores.map((s) => s.score).reduce((a, b) => a > b ? a : b);
    final scoreByWeek = <String, List<double>>{};
    for (final score in scores) {
      final weekNum =
          ((score.date.difference(range.start).inDays / 7).floor() + 1)
              .toString();
      scoreByWeek.putIfAbsent(weekNum, () => []).add(score.score);
    }
    final weeklyAvgs = scoreByWeek.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return 'Week ${e.key}: ${avg.toStringAsFixed(2)}';
    }).join('\n');
    final topApp = data.topApps.isNotEmpty ? data.topApps.first.appName : 'None';
    return '''Generate a comprehensive monthly digital wellbeing report for a user based on the following data:
Reporting period: ${dayKeyOf(range.start)} to ${dayKeyOf(range.end)}
=== 30-DAY SENTIMENT SCORES (daily, -1.0 to +1.0) ===
Average: ${avgScore.toStringAsFixed(2)}
Range: ${minScore.toStringAsFixed(2)} to ${maxScore.toStringAsFixed(2)}
Total days with data: ${scores.length}
Weekly Averages:
$weeklyAvgs
Daily Scores:
${scores.map((s) => '${s.dayKey}: ${s.score.toStringAsFixed(2)}').join(', ')}
=== USAGE DATA (last 30 days) ===
Total Screen Time: ${data.totalHoursLabel}h
Average Daily: ${data.averageHoursLabel}h
Daily Goal: ${data.goalHoursLabel}h
Days Under Goal: ${data.daysUnderGoal} (${data.percentDaysUnderGoal}%)
Days Over Goal: ${data.daysOverGoal}
Most Used App: $topApp
=== FOCUS SESSIONS ===
Completed: ${data.focusSessionsCompleted}
Failed: ${data.focusSessionsFailed}
Total Focus Time: ${data.focusMinutesTotal} minutes
=== MOOD HISTORY ===
Mood entries: ${data.moodHistory.length}
Trend: ${data.moodTrend?.headline ?? 'Insufficient data'}
=== INSIGHTS FROM LOCAL ANALYSIS ===
${data.insights.join('\n')}
=== INSTRUCTIONS ===
Write a comprehensive, empathetic, and actionable monthly wellbeing report. Structure it as:
1. **Executive Summary** - Overall wellbeing state (1-2 paragraphs)
2. **Sentiment Journey** - Analyze the 30-day sentiment trend, highlight patterns, improvements, setbacks
3. **Screen Time Analysis** - Compare against goals, identify triggers
4. **Focus & Productivity** - Evaluate focus session patterns
5. **Key Insights & Correlations** - Connect sentiment with usage patterns
6. **Personalized Recommendations** - 3-5 specific, actionable recommendations
7. **Looking Ahead** - Encouraging forward-looking statement
Tone: Supportive, non-judgmental, professional but warm. Use the data to tell a story.
Format: Clean markdown with headers. Length: ~800-1200 words.''';
  }

  Future<String?> _generateReport(String prompt) async {
    if (ApiKeys.groqApiKey.isEmpty) return null;
    try {
      final response = await http.post(Uri.parse(_apiUrl), headers: {
        'Authorization': 'Bearer ${ApiKeys.groqApiKey}', 'Content-Type': 'application/json',
      }, body: jsonEncode({'model': _model, 'messages': [
        {'role': 'system', 'content': 'You are an expert digital wellbeing analyst. Write comprehensive, empathetic monthly reports based on user data.'},
        {'role': 'user', 'content': prompt},
      ], 'max_tokens': 4000, 'temperature': 0.7,})).timeout(_requestTimeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else if (response.statusCode == 404) {
        debugPrint('MonthlyWellbeingReportService: Model not found (404)');
        return null;
      } else {
        debugPrint(
          'MonthlyWellbeingReportService: API error ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('MonthlyWellbeingReportService: Generation error - $e');
      return null;
    }
  }

  Future<void> _storeReport(
    String userId,
    String report,
    List<DailyScore> scores,
    WellbeingReportData data,
    DateTimeRange range,
  ) async {
    final average =
        scores.map((s) => s.score).reduce((a, b) => a + b) / scores.length;
    await _reportRef(userId, monthKeyOf(range.end)).set({
      'report': report,
      'generatedAt': FieldValue.serverTimestamp(),
      'periodStart': Timestamp.fromDate(range.start),
      'periodEnd': Timestamp.fromDate(range.end),
      'averageScore': average,
      'daysWithScores': scores.length,
      'totalScreenTimeHours': data.totalScreenTimeSec / 3600,
      'focusMinutesTotal': data.focusMinutesTotal,
      'model': _model,
    });
  }

  /// This month's report, falling back to the most recent one that exists so a
  /// fresh install (or a month in which generation failed) still shows
  /// something instead of an empty screen.
  Future<String?> getLatestReport(String userId) async {
    try {
      final current =
          await _reportRef(userId, monthKeyOf(DateTime.now())).get();
      if (current.exists) return current.data()?['report'] as String?;

      final all = await getAllReports(userId);
      return all.isEmpty ? null : all.first.report;
    } catch (e) {
      debugPrint('MonthlyWellbeingReportService.getLatestReport: Error - $e');
      return null;
    }
  }

  /// Every stored report, newest month first.
  Future<List<MonthlyReport>> getAllReports(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(_reportsCollection)
        .orderBy(FieldPath.documentId, descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return MonthlyReport(
        monthKey: doc.id,
        report: data['report'] as String? ?? '',
        generatedAt: (data['generatedAt'] as Timestamp?)?.toDate() ??
            DateTime.now(),
        averageScore: (data['averageScore'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }
}

class MonthlyReport {
  final String monthKey;
  final String report;
  final DateTime generatedAt;
  final double averageScore;

  const MonthlyReport({
    required this.monthKey,
    required this.report,
    required this.generatedAt,
    required this.averageScore,
  });
}
