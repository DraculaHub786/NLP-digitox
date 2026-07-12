// Copyright (c) 2024 NLP digitox

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void _completeQuiz() {
    // Determine persona based on responses
    final persona = _determinePersona();

    // Save persona - just store the string identifier
    // PersonaService will handle the conversion internally
    debugPrint('Onboarding: Selected persona: $persona');

    // Show result and navigate
    _showPersonaResult(persona);
  }

  String _determinePersona() {
    final occupation = _responses['occupation'] as String?;
    final goal = _responses['primary_goal'] as String?;
    final distraction = _responses['biggest_distraction'] as String?;

    // Simple heuristic-based persona determination
    // Returns persona identifier string
    if (occupation == 'professional') {
      if (goal == 'improve_focus') {
        return 'professional';
      }
    }

    if (occupation == 'student') {
      return 'student';
    }

    if (occupation == 'parent' || goal == 'family_wellness') {
      return 'parent';
    }

    if (occupation == 'senior') {
      return 'senior';
    }

    if (distraction == 'social_media' || distraction == 'videos') {
      return 'socialUser';
    }

    // Default
    return 'general';
  }

  void _showPersonaResult(String persona) {
    final personaInfo = _getPersonaInfo(persona);

    showDialog(
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
