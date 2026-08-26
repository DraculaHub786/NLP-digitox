// Copyright (c) 2026 NLP digitox

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/persona_service.dart';
import 'package:nlp_digitox/models/persona_model.dart';

/// Onboarding Quiz Page
/// Implements persona fingerprinting based on user responses
/// 
/// This quiz helps identify the user type (Professional, Student, Senior, Parent, etc.)
/// and customizes the app experience accordingly.
class OnboardingQuizPage extends ConsumerStatefulWidget {
  const OnboardingQuizPage({
    super.key,
    this.onComplete,
  });

  /// Called when the user completes the quiz and taps "Get Started".
  /// Should call [MindfulSettingsNotifier.markOnboardingDone] and navigate
  /// into the app (instead of the quiz navigating directly, which would
  /// bypass persisting the onboarding-done state).
  final VoidCallback? onComplete;

  @override
  ConsumerState<OnboardingQuizPage> createState() => _OnboardingQuizPageState();
}

class _OnboardingQuizPageState extends ConsumerState<OnboardingQuizPage> {
  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _responses = {};

  // Quiz questions for persona fingerprinting
  // Reframed to reference the onboarding topics (Focus, Block Distractions,
  // Privacy First, Know Your Habits) by name.
  final List<QuizQuestion> _questions = [
    QuizQuestion(
      id: 'occupation',
      question: 'What best describes your current situation?',
      options: [
        QuizOption('Working Professional — needs Focus mode most', 'professional', Icons.work),
        QuizOption('Student — wants to Block Distractions', 'student', Icons.school),
        QuizOption('Parent — needs Family Wellness', 'parent', Icons.family_restroom),
        QuizOption('Senior/Retired — values Privacy First', 'senior', Icons.elderly),
        QuizOption('Other', 'other', Icons.person),
      ],
    ),
    QuizQuestion(
      id: 'primary_goal',
      question: 'Which area matters most to you right now?',
      options: [
        QuizOption('Master Focus — improve deep work', 'improve_focus', Icons.psychology),
        QuizOption('Block Distractions — reduce social media', 'reduce_social', Icons.phone_android),
        QuizOption('Know My Habits — track screen time', 'reduce_screen', Icons.timer_off),
        QuizOption('Better sleep — set Bedtime boundaries', 'better_sleep', Icons.bedtime),
        QuizOption('Family digital wellness', 'family_wellness', Icons.family_restroom),
      ],
    ),
    QuizQuestion(
      id: 'biggest_distraction',
      question: 'What pulls you away from your focus the most?',
      options: [
        QuizOption('Social media scrolling', 'social_media', Icons.chat),
        QuizOption('News & articles', 'news', Icons.article),
        QuizOption('Games', 'games', Icons.videogame_asset),
        QuizOption('YouTube/Videos (Shorts)', 'videos', Icons.play_circle),
        QuizOption('Shopping apps', 'shopping', Icons.shopping_cart),
      ],
    ),
    QuizQuestion(
      id: 'usage_time',
      question: 'When do you usually reach for your phone?',
      options: [
        QuizOption('Morning (6am-12pm) — check Statistics first', 'morning', Icons.wb_sunny),
        QuizOption('Afternoon (12pm-6pm)', 'afternoon', Icons.light_mode),
        QuizOption('Evening (6pm-10pm) — Block Distractions needed', 'evening', Icons.nightlight),
        QuizOption('Late night (10pm-2am) — use Bedtime Mode', 'night', Icons.dark_mode),
        QuizOption('All day — let\'s Know My Habits', 'all_day', Icons.access_time),
      ],
    ),
    QuizQuestion(
      id: 'motivation',
      question: 'What keeps you going on your digital wellness journey?',
      options: [
        QuizOption('Achieving Focus goals', 'goals', Icons.flag),
        QuizOption('Earning rewards and streaks', 'rewards', Icons.emoji_events),
        QuizOption('Seeing Statistics progress', 'progress', Icons.trending_up),
        QuizOption('Competing on the Leaderboard', 'competition', Icons.leaderboard),
        QuizOption('Personal growth — Privacy First', 'growth', Icons.self_improvement),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Question ${_currentQuestionIndex + 1} of ${_questions.length}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question
                    Text(
                      currentQuestion.question,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Options
                    ...currentQuestion.options.map((option) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildOptionCard(option, currentQuestion.id),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    OutlinedButton.icon(
                      onPressed: _previousQuestion,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  const Spacer(),
                  if (_currentQuestionIndex < _questions.length - 1)
                    ElevatedButton.icon(
                      onPressed: _canProceed() ? _nextQuestion : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _canProceed() ? _completeQuiz : null,
                      icon: const Icon(Icons.check),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(QuizOption option, String questionId) {
    final isSelected = _responses[questionId] == option.value;

    return InkWell(
      onTap: () {
        setState(() {
          _responses[questionId] = option.value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    return _responses.containsKey(_questions[_currentQuestionIndex].id);
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _completeQuiz() async {
    // Determine persona based on responses
    final personaLabel = _determinePersona();

    // Map the heuristic label to UserPersona enum used by PersonaService
    final persona = _mapToUserPersona(personaLabel);

    // Collect raw answers as Map<String, String> for richer AI context
    final answers = _responses.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    // Persist the persona profile (including raw answers) so AI services can read it
    await PersonaService.instance.savePersona(
      PersonaProfile(
        persona: persona,
        scores: {},
        determinedAt: DateTime.now(),
        answers: answers,
      ),
    );

    debugPrint('Onboarding: Saved persona — ${persona.displayName} ($personaLabel) with ${answers.length} answers');

    if (!mounted) return;

    // Show result and navigate
    await _showPersonaResult(personaLabel);
  }

  /// Maps the heuristic quiz persona string to the [UserPersona] enum.
  UserPersona _mapToUserPersona(String label) {
    return switch (label) {
      'professional' => UserPersona.optimizer,
      'student'      => UserPersona.explorer,
      'parent'       => UserPersona.caretaker,
      'senior'       => UserPersona.optimizer,
      'socialUser'   => UserPersona.avoider,
      _              => UserPersona.optimizer,
    };
  }

  String _determinePersona() {
    // Weighted multi-factor scoring — considers all 5 answers.
    final scores = <String, int>{
      'professional': 0,
      'student': 0,
      'parent': 0,
      'senior': 0,
      'socialUser': 0,
    };

    final occupation = _responses['occupation'] as String?;
    final goal = _responses['primary_goal'] as String?;
    final distraction = _responses['biggest_distraction'] as String?;
    final usageTime = _responses['usage_time'] as String?;
    final motivation = _responses['motivation'] as String?;

    // 1. Occupation (primary signal — highest weight)
    switch (occupation) {
      case 'professional':
        scores['professional'] = scores['professional']! + 3;
      case 'student':
        scores['student'] = scores['student']! + 3;
      case 'parent':
        scores['parent'] = scores['parent']! + 3;
      case 'senior':
        scores['senior'] = scores['senior']! + 3;
      case 'other':
        scores['socialUser'] = scores['socialUser']! + 1;
    }

    // 2. Primary goal (secondary signal)
    switch (goal) {
      case 'improve_focus':
        scores['professional'] = scores['professional']! + 2;
      case 'reduce_social':
        scores['socialUser'] = scores['socialUser']! + 2;
      case 'reduce_screen':
        scores['student'] = scores['student']! + 1;
      case 'better_sleep':
        scores['senior'] = scores['senior']! + 1;
      case 'family_wellness':
        scores['parent'] = scores['parent']! + 2;
    }

    // 3. Biggest distraction
    switch (distraction) {
      case 'social_media':
        scores['socialUser'] = scores['socialUser']! + 2;
      case 'news':
        scores['professional'] = scores['professional']! + 1;
      case 'games':
        scores['student'] = scores['student']! + 2;
      case 'videos':
        scores['socialUser'] = scores['socialUser']! + 1;
      case 'shopping':
        scores['parent'] = scores['parent']! + 1;
    }

    // 4. Usage time
    switch (usageTime) {
      case 'morning':
        scores['professional'] = scores['professional']! + 1;
      case 'afternoon':
        scores['professional'] = scores['professional']! + 1;
      case 'evening':
        scores['socialUser'] = scores['socialUser']! + 1;
      case 'night':
        scores['student'] = scores['student']! + 1;
      case 'all_day':
        scores['socialUser'] = scores['socialUser']! + 1;
    }

    // 5. Motivation style
    switch (motivation) {
      case 'goals':
        scores['professional'] = scores['professional']! + 1;
      case 'rewards':
        scores['student'] = scores['student']! + 1;
      case 'progress':
        scores['professional'] = scores['professional']! + 1;
      case 'competition':
        scores['student'] = scores['student']! + 1;
      case 'growth':
        scores['senior'] = scores['senior']! + 1;
    }

    // Return the highest-scoring persona; ties go to the first occurrence
    return scores.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  Future<void> _showPersonaResult(String persona) async {
    final personaInfo = _getPersonaInfo(persona);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(personaInfo.icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(personaInfo.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(personaInfo.description),
            const SizedBox(height: 16),
            Text(
              'We\'ve customized your experience based on your profile!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Call onComplete (provided by OnboardingScreen) which
              // calls markOnboardingDone() and navigates into the app.
              // This ensures onboarding state is persisted.
              widget.onComplete?.call();
            },
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  PersonaInfo _getPersonaInfo(String persona) {
    switch (persona) {
      case 'professional':
        return PersonaInfo(
          title: 'Professional Mode',
          description: 'Focus-driven features to help you maintain productivity during work hours.',
          icon: Icons.work_outline,
        );
      case 'student':
        return PersonaInfo(
          title: 'Student Mode',
          description: 'Study sessions and distraction blocking to help you ace your exams.',
          icon: Icons.school_outlined,
        );
      case 'parent':
        return PersonaInfo(
          title: 'Parent Mode',
          description: 'Family-friendly controls and shared device management.',
          icon: Icons.family_restroom_outlined,
        );
      case 'senior':
        return PersonaInfo(
          title: 'Senior Mode',
          description: 'Simplified interface with larger text and essential features.',
          icon: Icons.elderly_outlined,
        );
      case 'socialUser':
        return PersonaInfo(
          title: 'Social Media Manager',
          description: 'Smart controls to help you manage social media and video app usage.',
          icon: Icons.groups_outlined,
        );
      default:
        return PersonaInfo(
          title: 'General Mode',
          description: 'Balanced digital wellbeing features tailored to your needs.',
          icon: Icons.person_outline,
        );
    }
  }
}

/// Quiz question model
class QuizQuestion {
  final String id;
  final String question;
  final List<QuizOption> options;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
  });
}

/// Quiz option model
class QuizOption {
  final String label;
  final String value;
  final IconData icon;

  QuizOption(this.label, this.value, this.icon);
}

/// Persona information for result display
class PersonaInfo {
  final String title;
  final String description;
  final IconData icon;

  PersonaInfo({
    required this.title,
    required this.description,
    required this.icon,
  });
}
