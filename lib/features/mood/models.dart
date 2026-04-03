import 'package:flutter/material.dart';

enum MoodType {
  veryHappy,
  happy,
  neutral,
  sad,
  verySad,
  anxious,
  stressed,
  focused,
  tired,
  energized,
}

class MoodEntry {
  final String id;
  final MoodType mood;
  final DateTime timestamp;
  final String? note;
  final List<String> triggers;
  final int? energyLevel;
  final int? stressLevel;

  MoodEntry({
    required this.id,
    required this.mood,
    required this.timestamp,
    this.note,
    this.triggers = const [],
    this.energyLevel,
    this.stressLevel,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      mood: MoodType.values.firstWhere(
        (e) => e.name == json['mood'],
        orElse: () => MoodType.neutral,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
      triggers: (json['triggers'] as List<dynamic>?)?.cast<String>() ?? [],
      energyLevel: json['energyLevel'] as int?,
      stressLevel: json['stressLevel'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': mood.name,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'triggers': triggers,
      'energyLevel': energyLevel,
      'stressLevel': stressLevel,
    };
  }
}

extension MoodTypeExtension on MoodType {
  String get emoji {
    switch (this) {
      case MoodType.veryHappy:
        return '😄';
      case MoodType.happy:
        return '🙂';
      case MoodType.neutral:
        return '😐';
      case MoodType.sad:
        return '😢';
      case MoodType.verySad:
        return '😭';
      case MoodType.anxious:
        return '😰';
      case MoodType.stressed:
        return '😤';
      case MoodType.focused:
        return '🎯';
      case MoodType.tired:
        return '😴';
      case MoodType.energized:
        return '⚡';
    }
  }

  String get displayName {
    switch (this) {
      case MoodType.veryHappy:
        return 'Very Happy';
      case MoodType.happy:
        return 'Happy';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.sad:
        return 'Sad';
      case MoodType.verySad:
        return 'Very Sad';
      case MoodType.anxious:
        return 'Anxious';
      case MoodType.stressed:
        return 'Stressed';
      case MoodType.focused:
        return 'Focused';
      case MoodType.tired:
        return 'Tired';
      case MoodType.energized:
        return 'Energized';
    }
  }

  Color get color {
    switch (this) {
      case MoodType.veryHappy:
        return Colors.green.shade700;
      case MoodType.happy:
        return Colors.green.shade400;
      case MoodType.neutral:
        return Colors.grey.shade500;
      case MoodType.sad:
        return Colors.blue.shade400;
      case MoodType.verySad:
        return Colors.blue.shade700;
      case MoodType.anxious:
        return Colors.orange.shade600;
      case MoodType.stressed:
        return Colors.red.shade600;
      case MoodType.focused:
        return Colors.purple.shade600;
      case MoodType.tired:
        return Colors.indigo.shade400;
      case MoodType.energized:
        return Colors.amber.shade600;
    }
  }

  double get sentimentScore {
    switch (this) {
      case MoodType.veryHappy:
        return 1.0;
      case MoodType.happy:
        return 0.7;
      case MoodType.energized:
        return 0.6;
      case MoodType.focused:
        return 0.5;
      case MoodType.neutral:
        return 0.0;
      case MoodType.tired:
        return -0.3;
      case MoodType.sad:
        return -0.5;
      case MoodType.anxious:
        return -0.6;
      case MoodType.stressed:
        return -0.7;
      case MoodType.verySad:
        return -1.0;
    }
  }
}

class MoodAnalysis {
  final double averageMoodScore;
  final MoodType dominantMood;
  final List<String> commonTriggers;
  final Map<MoodType, int> moodDistribution;

  MoodAnalysis({
    required this.averageMoodScore,
    required this.dominantMood,
    required this.commonTriggers,
    required this.moodDistribution,
  });
}
