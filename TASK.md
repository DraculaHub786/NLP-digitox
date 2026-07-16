# NLP-Digitox — Quiz System Fix Tasks

> Scope: Onboarding quiz only — persona persistence, AI integration, answer storage, structural cleanup.
> Priority: 🔴 Critical (breaks core feature) → 🟡 Medium (degrades AI quality) → 🟢 Low (cleanup/polish)

---

## Background: What Is Broken and Why It Matters

The onboarding quiz is the app's only mechanism to learn who the user is. Every
AI feature — the chatbot, sentiment analysis, motivation messages, recommendations
— is supposed to be personalized based on the quiz result. **None of that works.**

The quiz runs, asks 5 questions, computes a persona label, shows a dialog, and
then throws everything away. The label is never saved. The AI services never
read it. The persona is always `null` when any AI feature tries to use it. The
result is that the app treats a retired senior and a college student identically
in every AI response.

Below are **8 distinct problems** found, each as a separate task with root
cause, best solution, exact files, and acceptance criteria.

---

## TASK Q-1 — Two Competing Quiz Files (Structural Confusion)

**Severity:** 🟡 Medium
**Files:**
- `lib/features/onboarding/quiz.dart` — `OnboardingQuizPage` ✅ actually wired into onboarding
- `lib/ui/onboarding/quiz_screen.dart` — `QuizScreen` ❌ orphaned, not used anywhere

### Problem

There are two entirely separate quiz implementations in the codebase. They ask
different questions, use different scoring logic, produce different persona
taxonomies, and have different persistence code. Having both creates:

- Confusion about which is canonical
- Risk that future changes are made to the wrong file
- Dead code that inflates the binary
- Two different persona enum/string schemas that will collide if ever used together

`QuizScreen` has the *correct* persistence logic (it calls
`PersonaService.instance.savePersona()`), but it is never shown to the user.

`OnboardingQuizPage` is what new users actually see, but it has *no* persistence
logic at all.

### Best Solution

Delete `QuizScreen`. It is the orphan. Before deleting, extract and port its
`PersonaService.savePersona()` call into `OnboardingQuizPage` (covered in
Task Q-2). Do not merge the two quiz UIs — the question sets are different enough
that merging would require a design decision, and `OnboardingQuizPage` is already
wired and working as a UI.

**Steps:**
1. Copy the `PersonaService.savePersona()` invocation from `QuizScreen._completeQuiz()` into `OnboardingQuizPage._completeQuiz()`.
2. Delete `lib/ui/onboarding/quiz_screen.dart`.
3. Search for any import of `QuizScreen` across `lib/` and remove them.

```bash
# Verify no references remain
grep -rn "QuizScreen" lib/
# Should return zero results
```

### Acceptance Criteria
- [ ] `lib/ui/onboarding/quiz_screen.dart` does not exist
- [ ] `grep -rn "QuizScreen" lib/` returns empty
- [ ] `OnboardingQuizPage` is the single quiz implementation
- [ ] Nothing in the onboarding flow is broken after deletion

---

## TASK Q-2 — Quiz Result Is Never Persisted (Most Critical Bug)

**Severity:** 🔴 Critical
**File:** `lib/features/onboarding/quiz.dart`

### Problem

`OnboardingQuizPage._completeQuiz()` computes the persona via
`_determinePersona()` and immediately discards it. The method prints it to
the debug console and shows a dialog — but never writes it to storage.

**Current broken flow:**
```dart
Future<void> _completeQuiz() async {
  final persona = _determinePersona();    // computed ✅
  // ... show dialog ...
  widget.onComplete();                     // navigates away
  // persona is garbage-collected ❌
}
```

After the user completes the quiz, `PersonaService.instance.getPersona()`
returns `null` for the entire lifetime of the app. Every AI feature that
depends on persona data is silently fed nothing.

### Best Solution

Call `PersonaService.instance.savePersona()` immediately after computing the
persona, before showing the dialog. Also store the raw answers, not just the
computed label — the individual answers contain richer context than the final
string (see Task Q-5 for why this matters).

```dart
Future<void> _completeQuiz() async {
  final personaLabel = _determinePersona();   // e.g. 'professional', 'student'

  // 1. Map the heuristic label to the UserPersona enum used by PersonaService
  final persona = _mapToUserPersona(personaLabel);

  // 2. Persist BOTH the persona AND the raw answers
  await PersonaService.instance.savePersona(
    UserPersonaProfile(
      primaryPersona: persona,
      answers: Map<String, String>.from(_answers),  // all 5 question answers
      completedAt: DateTime.now(),
    ),
  );

  if (!mounted) return;

  // 3. Show dialog as before
  await _showPersonaDialog(personaLabel);

  widget.onComplete();
}

UserPersona _mapToUserPersona(String label) {
  return switch (label) {
    'professional' => UserPersona.optimizer,
    'student'      => UserPersona.learner,
    'parent'       => UserPersona.caretaker,
    'senior'       => UserPersona.senior,
    'socialUser'   => UserPersona.connector,
    _              => UserPersona.general,
  };
}
```

Check `PersonaService` for the exact `UserPersonaProfile` constructor
signature before implementing. If `_answers` is not already a Map field on the
state, collect it as `Map<String, String> _answers = {}` and populate it as
each question is answered (e.g. `_answers[question.key] = selectedOption`).

### Acceptance Criteria
- [ ] After completing the quiz, `await PersonaService.instance.getPersona()` returns a non-null profile
- [ ] The profile's `primaryPersona` matches the persona shown in the dialog
- [ ] The profile's `answers` map contains all 5 raw question answers
- [ ] Kill the app and relaunch — `getPersona()` still returns the saved profile (persistence survives cold start)
- [ ] Quiz dialog still appears before navigating away

---

## TASK Q-3 — SharedPreferences Key Mismatch Breaks All AI Persona Reads

**Severity:** 🔴 Critical
**File:** `lib/services/motivation_context_service.dart`

### Problem

`PersonaService` writes persona data to SharedPreferences under key
`'user_persona_v1'`. But `MotivationContextService.buildContext()` reads
directly from SharedPreferences using key `'onboarding_persona'`.

These two keys never match. Even *if* Task Q-2 is fixed and the persona is
now being saved, `MotivationContextService` will still read `null` because it
is looking at the wrong key. The Groq motivation API will always receive a
context that says persona is unknown.

**Current broken code pattern:**
```dart
// MotivationContextService — reads wrong key
final prefs = await SharedPreferences.getInstance();
final personaStr = prefs.getString('onboarding_persona');  // ❌ never written
```

**PersonaService — writes to different key:**
```dart
prefs.setString('user_persona_v1', ...);  // ✅ correct key, but never read above
```

### Best Solution

Remove the raw SharedPreferences access from `MotivationContextService`
entirely. Route all persona reads through `PersonaService` — that way there
is one canonical place for the key, and it only ever needs to change in one
file.

```dart
// MotivationContextService — after fix
Future<String> buildContext() async {
  // Route through PersonaService, not raw prefs
  final persona = await PersonaService.instance.getPersona();

  final personaBlock = persona != null
    ? '''
User Persona: ${persona.primaryPersona.name}
Their occupation context: ${persona.answers['occupation'] ?? 'unknown'}
Primary goal: ${persona.answers['primary_goal'] ?? 'unknown'}
Biggest distraction: ${persona.answers['biggest_distraction'] ?? 'unknown'}
Daily screen time: ${persona.answers['usage_time'] ?? 'unknown'}
Motivation style: ${persona.answers['motivation'] ?? 'unknown'}
'''
    : 'No user profile available. Respond with general wellness advice.';

  return personaBlock;
}
```

Also audit the entire `lib/` codebase for any other direct
`prefs.getString('onboarding_persona')` calls and replace them all:

```bash
grep -rn "onboarding_persona" lib/
# Every result must be replaced with PersonaService.instance.getPersona()
```

### Acceptance Criteria
- [ ] `grep -rn "'onboarding_persona'" lib/` returns zero results
- [ ] `MotivationContextService.buildContext()` returns persona-populated context after quiz completion
- [ ] The Groq motivation API call includes the user's persona and raw answers
- [ ] Changing the storage key in `PersonaService` automatically propagates everywhere (no other hardcoded keys)

---

## TASK Q-4 — `_determinePersona()` Uses Only 1 of 5 Answers (Logic Bug)

**Severity:** 🟡 Medium
**File:** `lib/features/onboarding/quiz.dart`

### Problem

`_determinePersona()` is a heuristic function that maps quiz answers to a
persona label. But based on the audit, it branches **only on the occupation
answer** to choose the persona. The other 4 answers — primary goal, biggest
distraction, screen usage time, motivation style — are completely ignored in
the decision logic.

This means:
- 80% of the user's self-reported data is discarded at classification time
- A 14-year-old student gaming 10h/day and a PhD student studying 2h/day both
  get `'student'` regardless of their completely different usage patterns
- The persona label carries almost no signal

**Example of what likely exists:**
```dart
String _determinePersona() {
  final occupation = _answers['occupation'];
  if (occupation == 'Professional / Working Adult') return 'professional';
  if (occupation == 'Student') return 'student';
  if (occupation == 'Parent / Caregiver') return 'parent';
  if (occupation == 'Retired / Senior') return 'senior';
  return 'socialUser';
  // ← answers for primary_goal, biggest_distraction, usage_time,
  //   motivation are never touched
}
```

### Best Solution

Implement a weighted scoring system (similar to what the orphaned `QuizScreen`
was doing) that considers all 5 answers. Each answer contributes points to
multiple persona categories, and the highest-scoring persona wins.

```dart
String _determinePersona() {
  final scores = <String, int>{
    'professional': 0,
    'student': 0,
    'parent': 0,
    'senior': 0,
    'socialUser': 0,
  };

  // Occupation (primary signal — highest weight)
  switch (_answers['occupation']) {
    case 'Professional / Working Adult': scores['professional'] = scores['professional']! + 3;
    case 'Student': scores['student'] = scores['student']! + 3;
    case 'Parent / Caregiver': scores['parent'] = scores['parent']! + 3;
    case 'Retired / Senior': scores['senior'] = scores['senior']! + 3;
    default: scores['socialUser'] = scores['socialUser']! + 1;
  }

  // Primary goal (secondary signal)
  switch (_answers['primary_goal']) {
    case 'Improve productivity / focus': scores['professional'] = scores['professional']! + 2;
    case 'Study better': scores['student'] = scores['student']! + 2;
    case 'Spend more time with family': scores['parent'] = scores['parent']! + 2;
    case 'Reduce social media use': scores['socialUser'] = scores['socialUser']! + 2;
  }

  // Biggest distraction
  switch (_answers['biggest_distraction']) {
    case 'Work emails / notifications': scores['professional'] = scores['professional']! + 1;
    case 'Social media': scores['socialUser'] = scores['socialUser']! + 1;
    case 'YouTube / streaming': scores['student'] = scores['student']! + 1;
  }

  // Usage time (heavy usage → social; light → professional / parent)
  switch (_answers['usage_time']) {
    case 'More than 6 hours': scores['socialUser'] = scores['socialUser']! + 1;
    case 'Less than 2 hours': scores['professional'] = scores['professional']! + 1;
  }

  // Motivation style
  switch (_answers['motivation']) {
    case 'Accountability / challenges': scores['professional'] = scores['professional']! + 1;
    case 'Gentle reminders': scores['parent'] = scores['parent']! + 1;
    case 'Rewards / streaks': scores['student'] = scores['student']! + 1;
  }

  // Return the highest-scoring persona
  return scores.entries
      .reduce((a, b) => a.value >= b.value ? a : b)
      .key;
}
```

Adjust the case strings to match the actual option text in the quiz. Add more
weight entries as needed based on what the real options are.

### Acceptance Criteria
- [ ] `_determinePersona()` uses at least 3 of the 5 question answers in its logic
- [ ] Two users with the same occupation but different goals/distractions can receive different personas
- [ ] The function is unit-testable — extract it to a pure function that takes a `Map<String, String>` and returns a `String`

---

## TASK Q-5 — Raw Quiz Answers Not Stored, Only Coarse Persona Label

**Severity:** 🟡 Medium
**Files:** `lib/features/onboarding/quiz.dart`, `lib/services/persona_service.dart`

### Problem

Even after fixing Tasks Q-2 and Q-3, the AI will only know a coarse label like
`'professional'`. It will not know that this particular professional works as a
nurse on night shifts, is most distracted by Instagram at 2am, and wants gentle
reminders rather than streaks. That level of specificity requires the raw answers.

If `UserPersonaProfile` in `PersonaService` does not have an `answers` field,
the raw data has nowhere to go and is thrown away at the class boundary.

### Best Solution

**If `UserPersonaProfile` already has an `answers` field:** Ensure Task Q-2
populates it with `_answers` (the Map of question key → selected option).

**If `UserPersonaProfile` does not have an `answers` field:** Add it:

```dart
// In persona_service.dart or models/user_persona_profile.dart
class UserPersonaProfile {
  final UserPersona primaryPersona;
  final Map<String, String> answers;   // ← add this field
  final DateTime completedAt;

  const UserPersonaProfile({
    required this.primaryPersona,
    required this.answers,
    required this.completedAt,
  });

  // Update toJson / fromJson to include answers
  Map<String, dynamic> toJson() => {
    'primaryPersona': primaryPersona.name,
    'answers': answers,                  // ← serialize
    'completedAt': completedAt.toIso8601String(),
  };

  factory UserPersonaProfile.fromJson(Map<String, dynamic> json) =>
    UserPersonaProfile(
      primaryPersona: UserPersona.values.byName(json['primaryPersona']),
      answers: Map<String, String>.from(json['answers'] ?? {}),  // ← deserialize
      completedAt: DateTime.parse(json['completedAt']),
    );
}
```

Then when building AI prompts (in Tasks Q-6, Q-7), use `persona.answers`
directly rather than just `persona.primaryPersona.name`.

### Acceptance Criteria
- [ ] After quiz completion, `PersonaService.instance.getPersona()` returns a profile where `answers` contains all 5 question answers as strings
- [ ] `answers` survives a cold restart (serialized correctly in JSON)
- [ ] AI prompts use individual answer values, not just the top-level label

---

## TASK Q-6 — AI Chatbot Has Zero Persona Awareness

**Severity:** 🟡 Medium
**File:** `lib/services/ai_chatbot_service.dart`

### Problem

The chatbot's system prompt is initialized in `_initializeAI()` with sentiment
context (screen time, habits, streaks) but no persona data. The AI does not
know if it is talking to a student, a parent, a working professional, or a
senior. All users get the same generic wellness advice regardless of their
context.

### Best Solution

Load persona inside `_initializeAI()` (or wherever the system prompt is
constructed) and inject both the persona label and the raw answers:

```dart
Future<void> _initializeAI() async {
  final persona = await PersonaService.instance.getPersona();
  final sentiment = await _loadSentimentContext();   // existing logic

  final personaSection = persona != null ? '''
=== USER PROFILE ===
Persona type: ${persona.primaryPersona.name}
Occupation context: ${persona.answers['occupation'] ?? 'not provided'}
Primary wellness goal: ${persona.answers['primary_goal'] ?? 'not provided'}
Biggest digital distraction: ${persona.answers['biggest_distraction'] ?? 'not provided'}
Typical daily screen time: ${persona.answers['usage_time'] ?? 'not provided'}
Preferred motivation style: ${persona.answers['motivation'] ?? 'not provided'}
=== END PROFILE ===

Tailor all responses, tone, examples, and advice to this specific user.
For example:
- If persona is 'student': use study-focused examples, academic language
- If persona is 'parent': emphasize family time and modeling healthy habits
- If persona is 'professional': focus on work-life boundaries, deep work
- If 'motivation' is 'gentle reminders': be encouraging, never prescriptive
- If 'motivation' is 'accountability': be direct, set measurable goals
'''
    : '(No user profile yet — give general digital wellness advice)';

  _systemPrompt = '''
You are a digital wellness AI coach inside NLP-Digitox.
$personaSection
Current emotional context: $sentiment
''';
}
```

If `_initializeAI()` is called once at startup, also add a method to
re-initialize the system prompt after the quiz is completed for the first time
(so the chatbot picks up the persona in the same session without requiring a
restart).

### Acceptance Criteria
- [ ] After quiz completion, a new chat session's system prompt includes the persona and all 5 answer fields
- [ ] Debug-log the system prompt in dev mode and verify it contains persona data
- [ ] The chatbot gives clearly different advice when persona is 'student' vs 'professional'
  (manual test: ask both "how do I focus better" and compare responses)
- [ ] If `getPersona()` returns null (pre-quiz), the chatbot falls back gracefully without throwing

---

## TASK Q-7 — No Mechanism to Retake Quiz or Update Profile

**Severity:** 🟡 Medium
**Files:** Settings screen, `lib/services/persona_service.dart`

### Problem

Once the onboarding quiz is completed, there is no way for a user to retake
it or update their profile. Life circumstances change — a student graduates
and becomes a professional; a solo user has a child and becomes a parent. The
AI's persona context becomes stale and wrong with no recourse.

Additionally, if a user skipped or dismissed the quiz during onboarding and
`PersonaService` returns null, there is no fallback prompt to complete it later.

### Best Solution

Add a "Retake Digital Profile Quiz" option in the app's Settings or Profile
screen:

```dart
// In settings screen
ListTile(
  leading: const Icon(FluentIcons.person_feedback_20_regular),
  title: const Text('Update My Digital Profile'),
  subtitle: const Text('Retake the quiz to improve AI personalization'),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => OnboardingQuizPage(
        onComplete: () {
          Navigator.pop(context);
          // Show confirmation snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated! AI will now adapt to your new answers.')),
          );
        },
      ),
    ),
  ),
)
```

Also add a banner/prompt in the AI chatbot or home screen when
`PersonaService.instance.getPersona()` returns null:

```dart
// In AI chatbot or home screen build()
final persona = ref.watch(personaProvider);
if (persona == null)
  MaterialBanner(
    content: const Text('Complete your profile quiz to get personalized AI advice'),
    actions: [
      TextButton(
        onPressed: () => _openQuiz(context),
        child: const Text('Start Quiz'),
      ),
    ],
  )
```

`PersonaService.savePersona()` should overwrite any existing profile (which
`SharedPreferences.setString` already does naturally), so re-taking the quiz
just replaces the stored data.

### Acceptance Criteria
- [ ] A "Update My Digital Profile" option exists in the Settings screen
- [ ] Completing the quiz from Settings overwrites the old persona
- [ ] AI features pick up the new persona immediately (without requiring a cold restart)
- [ ] When `getPersona()` returns null, a non-blocking prompt encourages the user to complete the quiz
- [ ] Dismissing that prompt does not show it again in the same session

---

## TASK Q-8 — No Quiz Completion Flag (Quiz May Re-Show on Restart)

**Severity:** 🔴 Critical
**Files:** `lib/features/onboarding/onboarding_screen.dart`, `lib/services/persona_service.dart`

### Problem

The onboarding flow checks some condition to decide whether to show the quiz
to a new user. If that condition is based on the persona being non-null (which
it will be after Task Q-2 is fixed), this is self-solving. But if the
condition is a *separate* boolean flag (e.g. `'quiz_completed'` in SharedPreferences)
that is currently never set (because `_completeQuiz()` never persists
anything), then:

- The quiz re-shows on every cold start
- Users who have already answered see the quiz again
- Any progress they had in the main app is gated behind re-completing the quiz

This needs to be verified and, if the flag is separate, explicitly written on
quiz completion.

### Best Solution

Make `PersonaService.savePersona()` itself serve as the completion signal.
In `onboarding_screen.dart`, check `PersonaService.instance.getPersona() != null`
rather than a separate boolean flag:

```dart
// In onboarding_screen.dart or main.dart routing logic
Future<Widget> _resolveStartScreen() async {
  final persona = await PersonaService.instance.getPersona();
  if (persona != null) {
    return const HomeScreen();      // quiz done, go to app
  }
  return const OnboardingScreen();  // quiz not done, show onboarding
}
```

If a separate `'quiz_completed'` SharedPreferences flag exists, set it inside
`PersonaService.savePersona()` so it is impossible to save a persona without
also setting the flag:

```dart
// Inside PersonaService.savePersona()
Future<void> savePersona(UserPersonaProfile profile) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('user_persona_v1', jsonEncode(profile.toJson()));
  prefs.setBool('quiz_completed', true);  // ← set atomically with persona save
}
```

### Acceptance Criteria
- [ ] Complete the quiz → kill the app → relaunch: the app goes directly to the home screen, not the quiz again
- [ ] A fresh install (no stored data) → app correctly routes to onboarding
- [ ] If only `'quiz_completed'` is true but `'user_persona_v1'` is missing (corrupted state), the app re-shows the quiz rather than navigating to home with a null persona

---

## Summary — Problem → Root Cause → Fix Chain

```
NEW USER opens app
    └──► OnboardingQuizPage shown ✅ (wired correctly)
         └──► User answers 5 questions
              └──► _determinePersona() runs
                   └──► Uses only 1 of 5 answers        ← BUG [Q-4]
                   └──► Returns a coarse label
              └──► Label discarded, nothing saved        ← BUG [Q-2] ← CRITICAL
              └──► Quiz completion flag not set          ← BUG [Q-8] ← CRITICAL

AI FEATURES try to use persona
    ├──► AIChatbotService._initializeAI()
    │    └──► No persona call at all                     ← BUG [Q-6]
    │
    ├──► MotivationContextService.buildContext()
    │    └──► Reads wrong SharedPrefs key                ← BUG [Q-3] ← CRITICAL
    │    └──► Always returns null persona
    │
    └──► aiSentimentProvider / aiRecommendationsProvider
         └──► No persona call at all                     ← (related, fix alongside Q-6)

STRUCTURAL
    ├──► Two quiz files, one orphaned                    ← BUG [Q-1]
    ├──► Raw answers not stored in profile model        ← BUG [Q-5]
    └──► No way to retake quiz after onboarding          ← BUG [Q-7]
```

---

## Fix Order (Recommended)

| Order | Task | Why First |
|-------|------|-----------|
| 1 | **Q-2** | Persona save — nothing works without this |
| 2 | **Q-8** | Quiz re-show on restart — users get stuck without this |
| 3 | **Q-3** | Key mismatch — AI reads wrong prefs key even after Q-2 |
| 4 | **Q-1** | Delete orphan — clean up confusion before adding more code |
| 5 | **Q-5** | Raw answers in model — needed before Q-6 can use rich context |
| 6 | **Q-6** | Chatbot persona injection — first AI feature to benefit |
| 7 | **Q-4** | Better persona scoring — improves classification accuracy |
| 8 | **Q-7** | Retake quiz UI — polish, UX improvement |