
/// Enumeration of possible app usage intents/categories
enum AppIntent {
  education,
  entertainment,
  productivity,
  social,
  health,
  utility,
  other,
}

/// Extension to provide human-readable names for AppIntent
extension AppIntentExtension on AppIntent {
  String get displayName {
    switch (this) {
      case AppIntent.education:
        return 'Education';
      case AppIntent.entertainment:
        return 'Entertainment';
      case AppIntent.productivity:
        return 'Productivity';
      case AppIntent.social:
        return 'Social';
      case AppIntent.health:
        return 'Health & Fitness';
      case AppIntent.utility:
        return 'Utility';
      case AppIntent.other:
        return 'Other';
    }
  }

  String get description {
    switch (this) {
      case AppIntent.education:
        return 'Learning, courses, educational content';
      case AppIntent.entertainment:
        return 'Movies, games, entertainment content';
      case AppIntent.productivity:
        return 'Work, tasks, productivity tools';
      case AppIntent.social:
        return 'Social media, messaging, communication';
      case AppIntent.health:
        return 'Exercise, health tracking, wellness';
      case AppIntent.utility:
        return 'Tools, utilities, system apps';
      case AppIntent.other:
        return 'Other purposes';
    }
  }
}

/// Model representing the intent/context of app usage
class AppIntentModel {
  /// Unique identifier for the intent record
  final String id;

  /// Package name of the app
  final String appPackage;

  /// Intent/category of app usage
  final AppIntent intent;

  /// Time when the intent was recorded
  final DateTime recordedAt;

  /// Additional notes about the intent
  final String? notes;

  /// Whether this intent is allowed (for tracking allowances)
  final bool isAllowed;

  const AppIntentModel({
    required this.id,
    required this.appPackage,
    required this.intent,
    required this.recordedAt,
    this.notes,
    this.isAllowed = false,
  });

  /// Creates a copy of the [AppIntentModel] with potentially modified values
  AppIntentModel copyWith({
    String? id,
    String? appPackage,
    AppIntent? intent,
    DateTime? recordedAt,
    String? notes,
    bool? isAllowed,
  }) {
    return AppIntentModel(
      id: id ?? this.id,
      appPackage: appPackage ?? this.appPackage,
      intent: intent ?? this.intent,
      recordedAt: recordedAt ?? this.recordedAt,
      notes: notes ?? this.notes,
      isAllowed: isAllowed ?? this.isAllowed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppIntentModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          appPackage == other.appPackage &&
          intent == other.intent &&
          isAllowed == other.isAllowed;

  @override
  int get hashCode =>
      id.hashCode ^ appPackage.hashCode ^ intent.hashCode ^ isAllowed.hashCode;

  @override
  String toString() =>
      'AppIntentModel(id: $id, app: $appPackage, intent: ${intent.displayName}, allowed: $isAllowed)';
}
