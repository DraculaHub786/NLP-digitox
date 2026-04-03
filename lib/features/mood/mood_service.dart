import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class MoodService extends ChangeNotifier {
  static final MoodService _instance = MoodService._internal();
  factory MoodService() => _instance;
  MoodService._internal();

  List<MoodEntry> _moodHistory = [];
  MoodEntry? _latestMood;
  
  // Heuristic detection state
  int _unlockCount = 0;
  DateTime? _lastUnlockTime;
  int _shortSessionCount = 0;
  DateTime _dayStartTime = DateTime.now();

  List<MoodEntry> get moodHistory => _moodHistory;
  MoodEntry? get latestMood => _latestMood;

  Future<void> init() async {
    await _loadMoodHistory();
    _resetDailyCounters();
  }

  Future<void> recordMood(MoodEntry entry) async {
    _moodHistory.insert(0, entry);
    _latestMood = entry;
    
    if (_moodHistory.length > 100) {
      _moodHistory = _moodHistory.take(100).toList();
    }
    
    await _saveMoodHistory();
    notifyListeners();
  }

  Future<void> recordMoodCheckIn({
    required MoodType mood,
    String? note,
    List<String> triggers = const [],
    int? energyLevel,
    int? stressLevel,
  }) async {
    final entry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mood: mood,
      timestamp: DateTime.now(),
      note: note,
      triggers: triggers,
      energyLevel: energyLevel,
      stressLevel: stressLevel,
    );

    await recordMood(entry);
  }

  // Heuristic-based mood detection
  Future<MoodType?> detectMoodFromBehavior() async {
    final now = DateTime.now();
    
    // Reset daily counters
    if (now.difference(_dayStartTime).inHours >= 24) {
      _resetDailyCounters();
    }

    // Detect anxious behavior: frequent unlocks in short time
    if (_unlockCount > 10 && now.difference(_lastUnlockTime ?? now).inMinutes < 30) {
      return MoodType.anxious;
    }

    // Detect stressed behavior: many short sessions (< 2 minutes)
    if (_shortSessionCount > 8) {
      return MoodType.stressed;
    }

    return null;
  }

  void recordUnlock() {
    _unlockCount++;
    _lastUnlockTime = DateTime.now();
  }

  void recordShortSession() {
    _shortSessionCount++;
  }

  void _resetDailyCounters() {
    _unlockCount = 0;
    _shortSessionCount = 0;
    _dayStartTime = DateTime.now();
  }

  MoodAnalysis analyzeMoodTrend({Duration? period}) {
    final cutoffDate = period != null 
        ? DateTime.now().subtract(period) 
        : DateTime(2000);
    
    final recentMoods = _moodHistory
        .where((entry) => entry.timestamp.isAfter(cutoffDate))
        .toList();

    if (recentMoods.isEmpty) {
      return MoodAnalysis(
        averageMoodScore: 0.0,
        dominantMood: MoodType.neutral,
        commonTriggers: [],
        moodDistribution: {},
      );
    }

    // Calculate average mood score
    final avgScore = recentMoods
        .map((e) => e.mood.sentimentScore)
        .reduce((a, b) => a + b) / recentMoods.length;

    // Find dominant mood
    final moodCounts = <MoodType, int>{};
    for (final entry in recentMoods) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    final dominantMood = moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Find common triggers
    final triggerCounts = <String, int>{};
    for (final entry in recentMoods) {
      for (final trigger in entry.triggers) {
        triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
      }
    }

    final commonTriggers = triggerCounts.entries
        .where((e) => e.value >= 2)
        .map((e) => e.key)
        .toList();

    return MoodAnalysis(
      averageMoodScore: avgScore,
      dominantMood: dominantMood,
      commonTriggers: commonTriggers,
      moodDistribution: moodCounts,
    );
  }

  List<String> getSuggestedInterventions() {
    if (_latestMood == null) return [];

    final interventions = <String>[];

    switch (_latestMood!.mood) {
      case MoodType.anxious:
        interventions.addAll([
          'Try a 5-minute breathing exercise',
          'Take a short walk outside',
          'Limit social media for the next hour',
        ]);
        break;
      case MoodType.stressed:
        interventions.addAll([
          'Schedule a 15-minute break',
          'Do a quick stretching routine',
          'Listen to calming music',
        ]);
        break;
      case MoodType.tired:
        interventions.addAll([
          'Consider a 20-minute power nap',
          'Get some fresh air',
          'Hydrate and have a healthy snack',
        ]);
        break;
      case MoodType.sad:
      case MoodType.verySad:
        interventions.addAll([
          'Reach out to a friend or family member',
          'Engage in a hobby you enjoy',
          'Practice gratitude journaling',
        ]);
        break;
      default:
        break;
    }

    return interventions;
  }

  Future<void> _saveMoodHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _moodHistory.take(100).map((e) => e.toJson()).toList();
    await prefs.setString('mood_history', jsonEncode(historyJson));
  }

  Future<void> _loadMoodHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('mood_history');
    
    if (historyJson != null) {
      try {
        final List<dynamic> historyData = jsonDecode(historyJson) as List<dynamic>;
        _moodHistory = historyData
            .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        
        if (_moodHistory.isNotEmpty) {
          _latestMood = _moodHistory.first;
        }
      } catch (e) {
        _moodHistory = [];
      }
    }
  }
}
