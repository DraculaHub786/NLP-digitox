// Persona model for NLP-Digitox onboarding quiz

/// User persona types determined by the onboarding quiz
enum UserPersona {
  /// Focused on maximizing output and eliminating distraction
  optimizer,

  /// Values relationships and family; manages device time for others too
  caretaker,

  /// Curious, variety-seeking; needs novelty caps not blanket blocks
  explorer,

  /// Resistant to restrictions; responds better to identity-based framing
  rebel,

  /// Avoidance-driven; uses screen time to escape tasks or emotions
  avoider,
}

/// Human-readable labels and descriptions for each persona
extension UserPersonaExtension on UserPersona {
  String get displayName {
    switch (this) {
      case UserPersona.optimizer:
        return 'The Optimizer';
      case UserPersona.caretaker:
        return 'The Caretaker';
      case UserPersona.explorer:
        return 'The Explorer';
      case UserPersona.rebel:
        return 'The Rebel';
      case UserPersona.avoider:
        return 'The Avoider';
    }
  }

  String get tagline {
    switch (this) {
      case UserPersona.optimizer:
        return 'Focus-driven. Every minute counts.';
      case UserPersona.caretaker:
        return 'Family first. Balanced for everyone.';
      case UserPersona.explorer:
        return 'Curious mind. Wide but intentional.';
      case UserPersona.rebel:
        return 'Your rules. Your identity.';
      case UserPersona.avoider:
        return 'Gentle nudges. No shame, just growth.';
    }
  }

  String get emoji {
    switch (this) {
      case UserPersona.optimizer:
        return '⚡';
      case UserPersona.caretaker:
        return '🤝';
      case UserPersona.explorer:
        return '🧭';
      case UserPersona.rebel:
        return '🔥';
      case UserPersona.avoider:
        return '🌱';
    }
  }

  /// Recommended daily screen time limit (minutes per app)
  int get recommendedDailyLimitMinutes {
    switch (this) {
      case UserPersona.optimizer:
        return 30;
      case UserPersona.caretaker:
        return 60;
      case UserPersona.explorer:
        return 45;
      case UserPersona.rebel:
        return 90; // Start relaxed, let identity framing do the work
      case UserPersona.avoider:
        return 60;
    }
  }

  /// Default break reminder interval (minutes)
  int get breakReminderMinutes {
    switch (this) {
      case UserPersona.optimizer:
        return 25; // Pomodoro style
      case UserPersona.caretaker:
        return 45;
      case UserPersona.explorer:
        return 30;
      case UserPersona.rebel:
        return 60; // Less intrusive
      case UserPersona.avoider:
        return 20; // Gentle, frequent
    }
  }

  /// Identity-based motivational framing prefix
  String get identityStatement {
    switch (this) {
      case UserPersona.optimizer:
        return 'Be the kind of person who masters their time.';
      case UserPersona.caretaker:
        return 'Be present for the people who need you most.';
      case UserPersona.explorer:
        return 'Go deep, not just wide — quality over quantity.';
      case UserPersona.rebel:
        return 'Real freedom means choosing what YOU let in.';
      case UserPersona.avoider:
        return 'One small step at a time — no pressure.';
    }
  }

  /// JSON key for SharedPreferences storage
  String get key => name;

  static UserPersona fromKey(String key) {
    return UserPersona.values.firstWhere(
      (p) => p.key == key,
      orElse: () => UserPersona.optimizer,
    );
  }
}

/// Full persona profile with quiz score breakdown
class PersonaProfile {
  final UserPersona persona;
  final Map<UserPersona, int> scores;
  final DateTime determinedAt;

  const PersonaProfile({
    required this.persona,
    required this.scores,
    required this.determinedAt,
  });

  factory PersonaProfile.fromScores(Map<UserPersona, int> scores) {
    int maxScore = -1;
    UserPersona result = UserPersona.optimizer;
    for (final entry in scores.entries) {
      if (entry.value > maxScore) {
        maxScore = entry.value;
        result = entry.key;
      }
    }
    return PersonaProfile(
      persona: result,
      scores: scores,
      determinedAt: DateTime.now(),
    );
  }
}
