// Personality Quiz Screen for first-time onboarding — NLP-Digitox

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nlp_digitox/core/services/persona_service.dart';
import 'package:nlp_digitox/models/persona_model.dart';

/// Multi-step persona quiz shown once during first-time onboarding.
/// Determines the user's digital personality fingerprint.
class QuizScreen extends StatefulWidget {
  /// Called when the quiz completes with the determined profile.
  final VoidCallback onComplete;

  const QuizScreen({super.key, required this.onComplete});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentStep = 0;
  bool _saving = false;

  /// Scores accumulated per persona during quiz
  final Map<UserPersona, int> _scores = {
    for (final p in UserPersona.values) p: 0,
  };

  // ---------------------------------------------------------------------------
  // Quiz data
  // ---------------------------------------------------------------------------

  static const _questions = [
    _QuizQuestion(
      question: 'What best describes why you want to reduce screen time?',
      options: [
        _QuizOption('I want to be more productive and focused', UserPersona.optimizer, 3),
        _QuizOption('I want to be more present for family / friends', UserPersona.caretaker, 3),
        _QuizOption('I want to explore offline hobbies and variety', UserPersona.explorer, 3),
        _QuizOption('I want to feel in control, not controlled by apps', UserPersona.rebel, 3),
        _QuizOption('I use my phone to escape stress or boredom', UserPersona.avoider, 3),
      ],
    ),
    _QuizQuestion(
      question: 'How do you feel when you try to put your phone down?',
      options: [
        _QuizOption('I just set a timer and get to work', UserPersona.optimizer, 2),
        _QuizOption('I worry about missing messages from loved ones', UserPersona.caretaker, 2),
        _QuizOption('I get restless and look for something new', UserPersona.explorer, 2),
        _QuizOption('I feel annoyed — I should be the one to decide', UserPersona.rebel, 2),
        _QuizOption('I feel anxious or uncomfortable', UserPersona.avoider, 2),
      ],
    ),
    _QuizQuestion(
      question: 'Which statement feels most true for you right now?',
      options: [
        _QuizOption('Every minute I waste is a minute someone else gains', UserPersona.optimizer, 2),
        _QuizOption('My screen time affects the people I love', UserPersona.caretaker, 2),
        _QuizOption('I consume a lot, but rarely go deep on anything', UserPersona.explorer, 2),
        _QuizOption('I hate being told what to do, even by an app', UserPersona.rebel, 2),
        _QuizOption('I scroll when I should be doing something else', UserPersona.avoider, 2),
      ],
    ),
    _QuizQuestion(
      question: 'What kind of support works best for you?',
      options: [
        _QuizOption('Hard limits and data — no fluff', UserPersona.optimizer, 2),
        _QuizOption('Gentle reminders that help me stay balanced', UserPersona.caretaker, 2),
        _QuizOption('Suggestions for new offline activities', UserPersona.explorer, 2),
        _QuizOption('Freedom with a bit of accountability — not rules', UserPersona.rebel, 2),
        _QuizOption('Compassionate nudges without shaming me', UserPersona.avoider, 2),
      ],
    ),
    _QuizQuestion(
      question: 'Which goal would matter most to you after 30 days?',
      options: [
        _QuizOption('Doubled my deep work hours', UserPersona.optimizer, 3),
        _QuizOption('Been more present at dinner every night', UserPersona.caretaker, 3),
        _QuizOption('Tried 3 new hobbies offline', UserPersona.explorer, 3),
        _QuizOption('Felt genuinely in charge of my time', UserPersona.rebel, 3),
        _QuizOption('Reduced the urge to scroll when stressed', UserPersona.avoider, 3),
      ],
    ),
  ];

  void _onOptionSelected(_QuizOption option) {
    setState(() => _scores[option.persona] = (_scores[option.persona] ?? 0) + option.weight);

    Future.delayed(250.ms, () {
      if (!mounted) return;
      if (_currentStep < _questions.length - 1) {
        setState(() => _currentStep++);
      } else {
        _finishQuiz();
      }
    });
  }

  Future<void> _finishQuiz() async {
    setState(() => _saving = true);
    final profile = PersonaProfile.fromScores(_scores);
    await PersonaService.instance.savePersona(profile);
    if (mounted) widget.onComplete();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = _questions[_currentStep];
    final progress = (_currentStep + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.12),
                  theme.colorScheme.secondary.withValues(alpha: 0.08),
                  theme.colorScheme.surface,
                ],
              ),
            ),
          ),

          SafeArea(
            child: _saving
                ? _buildSavingState(theme)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(theme, progress),
                      Expanded(
                        child: _buildQuestionBody(theme, question),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, double progress) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _GlassChip(
                label: 'Question ${_currentStep + 1} of ${_questions.length}',
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary),
            ),
          ).animate().fadeIn(duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildQuestionBody(ThemeData theme, _QuizQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Text(
            question.question,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          )
              .animate(key: ValueKey(_currentStep))
              .fadeIn(duration: 350.ms)
              .slideX(begin: 0.05, end: 0),

          const SizedBox(height: 32),

          // Options
          ...question.options.asMap().entries.map((e) {
            final index = e.key;
            final opt = e.value;
            return _QuizOptionCard(
              option: opt,
              delay: Duration(milliseconds: 80 * index),
              onTap: () => _onOptionSelected(opt),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSavingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Building your profile…',
            style: theme.textTheme.titleMedium,
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
    );
  }
}

// ---------------------------------------------------------------------------
// Quiz option card with glassmorphic style
// ---------------------------------------------------------------------------

class _QuizOptionCard extends StatefulWidget {
  final _QuizOption option;
  final Duration delay;
  final VoidCallback onTap;

  const _QuizOptionCard({
    required this.option,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_QuizOptionCard> createState() => _QuizOptionCardState();
}

class _QuizOptionCardState extends State<_QuizOptionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: 120.ms,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isDark ? Colors.white : theme.colorScheme.primary)
                          .withValues(alpha: 0.08),
                      (isDark ? Colors.white : theme.colorScheme.primary)
                          .withValues(alpha: 0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDark ? Colors.white : theme.colorScheme.primary)
                        .withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.option.label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
          .animate(delay: widget.delay)
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.06, end: 0),
    );
  }
}

// ---------------------------------------------------------------------------
// Persona result card shown at end (optional — reuse in settings)
// ---------------------------------------------------------------------------

class PersonaResultCard extends StatelessWidget {
  final UserPersona persona;
  final bool compact;

  const PersonaResultCard({
    super.key,
    required this.persona,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.all(compact ? 16 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.15),
                theme.colorScheme.secondary.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Text(
                persona.emoji,
                style: TextStyle(fontSize: compact ? 28 : 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      persona.displayName,
                      style: (compact
                              ? theme.textTheme.titleMedium
                              : theme.textTheme.titleLarge)
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      persona.tagline,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
        );
  }
}

// ---------------------------------------------------------------------------
// Small glass chip
// ---------------------------------------------------------------------------

class _GlassChip extends StatelessWidget {
  final String label;
  final Color color;

  const _GlassChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal data classes
// ---------------------------------------------------------------------------

class _QuizQuestion {
  final String question;
  final List<_QuizOption> options;

  const _QuizQuestion({required this.question, required this.options});
}

class _QuizOption {
  final String label;
  final UserPersona persona;
  final int weight;

  const _QuizOption(this.label, this.persona, this.weight);
}
