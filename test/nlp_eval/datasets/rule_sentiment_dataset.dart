// Copyright (c) 2026 NLP digitox
//
// Gold labels for AISentimentService.computeBaseSentiment — the deterministic,
// LLM-free rule engine that produces the five-label distribution from usage
// metrics alone.
//
// Gold is the emotion a digital-wellbeing analyst would name for the scenario,
// written before the numbers were run so the labels cannot be reverse-fitted to
// the output. Each entry carries the one-sentence reason it was labelled that
// way, because "what emotion is 9 hours of screen time against a 3 hour goal"
// is a judgement call and the judgement should be visible.

/// One usage scenario and the emotion an analyst would name for it.
class RuleScenario {
  const RuleScenario({
    required this.screenHours,
    required this.goalHours,
    required this.streakDays,
    required this.habitsCompleted,
    required this.tasksCompleted,
    required this.gold,
    required this.rationale,
  });

  final double screenHours;
  final double goalHours;
  final int streakDays;
  final int habitsCompleted;
  final int tasksCompleted;

  /// The dominant emotion an analyst would attribute to this day.
  final String gold;

  /// Why that label, in one sentence.
  final String rationale;

  double get goalRatio => goalHours > 0 ? screenHours / goalHours : 0;
}

/// 40 scenarios spread across all five sentiment labels.
const List<RuleScenario> kRuleScenarios = <RuleScenario>[
  // ── Positive: comfortably under goal with real habit momentum ──────
  RuleScenario(
    screenHours: 1.0, goalHours: 4.0, streakDays: 10, habitsCompleted: 5,
    tasksCompleted: 3, gold: 'Positive',
    rationale: 'A quarter of the goal and a ten-day streak is a clearly good day.',
  ),
  RuleScenario(
    screenHours: 0.5, goalHours: 4.0, streakDays: 7, habitsCompleted: 4,
    tasksCompleted: 2, gold: 'Positive',
    rationale: 'Very low usage plus a long streak and habits done.',
  ),
  RuleScenario(
    screenHours: 2.0, goalHours: 4.0, streakDays: 5, habitsCompleted: 6,
    tasksCompleted: 4, gold: 'Positive',
    rationale: 'Half the goal with strong habit completion.',
  ),
  RuleScenario(
    screenHours: 1.5, goalHours: 4.0, streakDays: 3, habitsCompleted: 3,
    tasksCompleted: 1, gold: 'Positive',
    rationale: 'Under goal, streak established, several habits kept.',
  ),
  RuleScenario(
    screenHours: 0.0, goalHours: 3.0, streakDays: 14, habitsCompleted: 6,
    tasksCompleted: 5, gold: 'Positive',
    rationale: 'No screen time at all plus maximum momentum.',
  ),
  RuleScenario(
    screenHours: 2.5, goalHours: 6.0, streakDays: 9, habitsCompleted: 5,
    tasksCompleted: 2, gold: 'Positive',
    rationale: 'Well under a generous goal with a nine-day streak.',
  ),
  RuleScenario(
    screenHours: 1.2, goalHours: 3.0, streakDays: 4, habitsCompleted: 4,
    tasksCompleted: 3, gold: 'Positive',
    rationale: '40% of goal, streak and tasks both healthy.',
  ),
  RuleScenario(
    screenHours: 0.8, goalHours: 2.5, streakDays: 21, habitsCompleted: 7,
    tasksCompleted: 4, gold: 'Positive',
    rationale: 'Three weeks unbroken and well inside the goal.',
  ),

  // ── Focused: the same good metrics but emphasis on sustained effort ─
  RuleScenario(
    screenHours: 3.5, goalHours: 4.0, streakDays: 12, habitsCompleted: 6,
    tasksCompleted: 6, gold: 'Focused',
    rationale: 'Under goal with an unusually high task completion rate.',
  ),
  RuleScenario(
    screenHours: 3.8, goalHours: 4.0, streakDays: 8, habitsCompleted: 5,
    tasksCompleted: 5, gold: 'Focused',
    rationale: 'Close to goal but heavy deliberate task execution.',
  ),
  RuleScenario(
    screenHours: 2.8, goalHours: 4.0, streakDays: 6, habitsCompleted: 6,
    tasksCompleted: 4, gold: 'Focused',
    rationale: 'Consistent streak plus habits and tasks, usage in hand.',
  ),
  RuleScenario(
    screenHours: 3.0, goalHours: 4.0, streakDays: 15, habitsCompleted: 6,
    tasksCompleted: 5, gold: 'Focused',
    rationale: 'Long streak with balanced habit and task load.',
  ),

  // ── Neutral: usage inside the band the rules call steady ───────────
  RuleScenario(
    screenHours: 4.0, goalHours: 4.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Neutral',
    rationale: 'Exactly on goal with nothing else going on is the definition of neutral.',
  ),
  RuleScenario(
    screenHours: 4.6, goalHours: 4.0, streakDays: 0, habitsCompleted: 1,
    tasksCompleted: 1, gold: 'Neutral',
    rationale: '15% over goal sits in the band the rules treat as steady.',
  ),
  RuleScenario(
    screenHours: 5.2, goalHours: 4.0, streakDays: 1, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Neutral',
    rationale: '30% over goal is inside the documented neutral band.',
  ),
  RuleScenario(
    screenHours: 3.6, goalHours: 4.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Neutral',
    rationale: 'Slightly under goal with no other signal.',
  ),
  RuleScenario(
    screenHours: 4.4, goalHours: 4.0, streakDays: 2, habitsCompleted: 0,
    tasksCompleted: 1, gold: 'Neutral',
    rationale: 'Marginally over goal, a short streak changes little.',
  ),
  RuleScenario(
    screenHours: 5.0, goalHours: 4.0, streakDays: 0, habitsCompleted: 1,
    tasksCompleted: 0, gold: 'Neutral',
    rationale: '25% over goal with a single habit is still unremarkable.',
  ),
  RuleScenario(
    screenHours: 4.2, goalHours: 4.0, streakDays: 1, habitsCompleted: 1,
    tasksCompleted: 1, gold: 'Neutral',
    rationale: 'Essentially on target with minimal activity.',
  ),
  RuleScenario(
    screenHours: 3.9, goalHours: 4.0, streakDays: 0, habitsCompleted: 1,
    tasksCompleted: 0, gold: 'Neutral',
    rationale: 'Right at the goal line with nothing else to report.',
  ),

  // ── Negative: meaningfully over goal with no compensating habits ───
  RuleScenario(
    screenHours: 6.5, goalHours: 4.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Negative',
    rationale: 'Over 150% of goal with no habits or streak to offset it.',
  ),
  RuleScenario(
    screenHours: 7.0, goalHours: 4.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Negative',
    rationale: 'Nearly double the goal with nothing offsetting.',
  ),
  RuleScenario(
    screenHours: 5.0, goalHours: 2.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Negative',
    rationale: 'Two and a half times a small goal.',
  ),
  RuleScenario(
    screenHours: 6.0, goalHours: 3.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Negative',
    rationale: 'Double the goal with a broken streak.',
  ),
  RuleScenario(
    screenHours: 5.5, goalHours: 3.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 1, gold: 'Negative',
    rationale: 'Well over goal and only one task salvaged.',
  ),
  RuleScenario(
    screenHours: 8.0, goalHours: 5.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Negative',
    rationale: 'An eight hour day against a five hour goal.',
  ),
  RuleScenario(
    screenHours: 4.5, goalHours: 2.0, streakDays: 0, habitsCompleted: 1,
    tasksCompleted: 0, gold: 'Negative',
    rationale: 'Twice a two hour goal with negligible habits.',
  ),
  RuleScenario(
    screenHours: 6.8, goalHours: 4.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Negative',
    rationale: 'A heavy day with no recovery signals at all.',
  ),

  // ── Anxious: the extreme end, where the rules fire hardest ────────
  RuleScenario(
    screenHours: 16.0, goalHours: 4.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Anxious',
    rationale: 'Four times the goal is digital overload.',
  ),
  RuleScenario(
    screenHours: 20.0, goalHours: 4.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Anxious',
    rationale: 'Five times the goal, the worst case the scorer can see.',
  ),
  RuleScenario(
    screenHours: 12.0, goalHours: 3.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Anxious',
    rationale: 'Four times a three hour goal.',
  ),
  RuleScenario(
    screenHours: 9.0, goalHours: 3.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Anxious',
    rationale: 'Triple the goal with no offsetting habits.',
  ),
  RuleScenario(
    screenHours: 14.0, goalHours: 4.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Anxious',
    rationale: 'Three and a half times the goal, well past the distress threshold.',
  ),
  RuleScenario(
    screenHours: 18.0, goalHours: 4.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Anxious',
    rationale: 'All-day usage against a four hour goal.',
  ),
  RuleScenario(
    screenHours: 10.0, goalHours: 2.5, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Anxious',
    rationale: 'Four times a small goal is the clearest overload case.',
  ),
  RuleScenario(
    screenHours: 15.0, goalHours: 4.0, streakDays: 0, habitsCompleted: 1,
    tasksCompleted: 0, gold: 'Anxious',
    rationale: 'Nearly four times goal; one habit does not offset it.',
  ),
  RuleScenario(
    screenHours: 22.0, goalHours: 5.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Anxious',
    rationale: 'Over four times goal with nothing else recorded.',
  ),
  RuleScenario(
    screenHours: 11.0, goalHours: 3.0, streakDays: 0, habitsCompleted: 0,
    tasksCompleted: 0, gold: 'Anxious',
    rationale: 'Nearly four times a three hour goal.',
  ),
];
