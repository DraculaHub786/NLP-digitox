# Task: Fix Groq sentiment wiring, then build funny mood-based motivation

## Root cause summary (confirmed by reading the actual code, not assumed)

1. **`lib/config/api_keys.dart` is gitignored** (`**/api_keys.dart` in
   `.gitignore`) — only `lib/config/api_keys_template.dart` exists, with
   `groqApiKey = 'YOUR_GROQ_API_KEY_HERE'`. `AISentimentService` checks
   `if (_apiKey.isEmpty || _apiKey.contains('YOUR_'))` and throws if so.
2. **`lib/providers/ai_providers.dart`'s `aiSentimentProvider` and
   `aiRecommendationsProvider` both wrap their Groq calls in `try { ... }
   catch (_) { return _fallbackSentiment()/_fallbackRecommendations(); }`**
   — on ANY failure (missing key, network error, timeout, parse failure),
   they silently return the same hardcoded static values. No error is
   surfaced anywhere. This is indistinguishable from "working but boring"
   unless you check `flutter logs`.
3. **`_loadScreenTimeGoalSeconds()` reads the wrong field.** It reads
   `allowedShortsTimeSec` from `WellbeingTable` (`lib/core/database/tables/wellbeing_table.dart`)
   — confirmed by its own doc comment to be *"Allowed time for short content
   in SECONDS"* (default 7 hours), i.e. the Shorts/Reels blocking limit, not
   a general daily screen-time goal. No real "screen time goal" setting
   exists anywhere in the app today (checked the DB schema, Firestore
   settings, and UI strings — nothing).

---

## PHASE 1 — Diagnose your actual current state (do this first, don't skip)

### 1.1 Check whether `api_keys.dart` exists and has a real key
```
ls lib/config/api_keys.dart
cat lib/config/api_keys.dart
```
If the file doesn't exist, or `groqApiKey` still contains `'YOUR_'`, that's
Bug 1 confirmed — copy `api_keys_template.dart` to `api_keys.dart` and put
in a real key from https://console.groq.com/keys.

### 1.2 Temporarily make failures visible
Bug 2 (silent catch) makes it impossible to tell success from failure just
by looking at the UI. Before fixing anything, add a temporary
`debugPrint('SENTIMENT ERROR: $e')` inside both `catch (_)` blocks in
`ai_providers.dart` (lines 44 and 72), run the app, open the dashboard's AI
Analysis card, and check `flutter logs` / the debug console. This tells you
definitively whether calls are failing (and why) or actually succeeding
with boring/static-looking results.

---

## PHASE 2 — Fix the two confirmed bugs

### 2.1 Set up the real API key (if Phase 1.1 confirmed it's missing)
- Copy `lib/config/api_keys_template.dart` → `lib/config/api_keys.dart`
- Add a real Groq key
- Confirm `lib/config/api_keys.dart` is NOT accidentally tracked by git
  (`git status` should not show it as a new/modified file, since it's
  gitignored — if it does show up, something's wrong with the ignore rule)

### 2.2 Add a real "screen time goal" setting — don't keep reusing Shorts time
This requires a small schema addition since nothing like it exists:
- Add a new column to `WellbeingTable` (or a more appropriate settings
  table if one fits better) — e.g. `dailyScreenTimeGoalSec`, with a
  sensible default (e.g. 3-4 hours in seconds).
- Regenerate Drift code (`dart run build_runner build` or whatever this
  repo's existing codegen command is — check for a `build_runner` script
  already used elsewhere in the repo for consistency).
- Add a UI control somewhere reasonable (Settings, or the existing
  wellbeing/limits screen if one exists) so the user can actually set this
  goal — a sentiment feature silently using an invisible, unconfigurable
  number isn't very useful.
- Update `_loadScreenTimeGoalSeconds()` in `ai_providers.dart` to read the
  new field instead of `allowedShortsTimeSec`.

### 2.3 Remove (or gate behind a debug flag) the silent catch-and-fallback
Keep a fallback for genuine network failures (that's reasonable), but:
- Log the actual error (`debugPrint` or a proper logging service if this
  repo has one) every time the fallback path is hit, in production too —
  not just during this debugging phase — so future "nothing's changing"
  reports are diagnosable without re-adding temporary prints.
- Consider surfacing a subtle UI indicator when showing fallback data (e.g.
  a small "using default insights" label) so it's visibly different from a
  live AI result, instead of looking identical.

### 2.4 Verify end-to-end
After 2.1-2.3: change your usage pattern meaningfully (e.g. big screen time
swing, complete some habits, chat with the AI a bit), reload the dashboard's
AI Analysis card, and confirm the sentiment percentages and recommendations
actually differ from the previous load and from the old static fallback
numbers.

---

## PHASE 3 — Build the funny, mood-based motivational message feature

This builds on the now-fixed pipeline from Phase 2 — don't start this until
Phase 2.4 is verified working, otherwise you'll be debugging two things at
once.

### 3.1 Unify the currently-separate mood/persona/chat inputs
Today `MoodService` (heuristic + self-reported mood), `PersonaService`
(quiz-derived persona), and `AIChatbotService` (chat history) are three
separate systems that don't talk to each other. Add a small aggregator
function/service (e.g. `MotivationContextService`) that pulls:
- Latest `MoodEntry` from `MoodService.instance.latestMood`
- Persona from `PersonaService`
- Recent chat messages from `AIChatbotService.instance.getRecentMessages()`
- Current sentiment from the (now-fixed) `AISentimentService`
into one combined context object.

### 3.2 Add a new Groq prompt specifically for humor, not coaching
Add a new method to `AISentimentService` — e.g. `getFunnyMotivation()` —
separate from `getRecommendations()` (don't overload the existing serious
one; different tone, different prompt, different consumers). Prompt should
explicitly instruct: short (1-2 sentences), funny/light tone, references
the user's actual mood/persona/recent behavior, still land on something
encouraging, not just a joke with no point. Include few-shot examples in
the prompt if you want more consistent comedic tone.

### 3.3 Decide the trigger/frequency
A funny message every screen refresh will get old fast. Pick one:
- Time-based (e.g. once every few hours, cached in between)
- Event-based (e.g. after completing a habit, after a long session, on app
  open if it's been N hours since the last one)
- Manual (a "cheer me up" button)
Cache the last generated message (SharedPreferences, matching how
mood/persona are already stored) so it doesn't regenerate on every widget
rebuild — this also reduces Groq API usage.

### 3.4 Surface it in the UI
Options, pick based on how prominent you want it:
- A small dismissible card on the dashboard (new, separate from the
  existing serious "AI Analysis" section — don't conflate the two tones)
- A local notification
- Both, with the notification driving the person back to the dashboard
  where the card lives

### 3.5 Respect the mood-detection privacy angle
`MoodService`'s heuristic detection (rapid unlocks, short sessions) and the
sentiment analyzer's chat-snippet usage both mean real personal signals are
being sent to a third-party API (Groq) via `AISentimentService`. Worth
double-checking `lib/ui/screens/settings/privacy_settings_screen.dart` (it
already exists — read it) to confirm whatever privacy toggle already
exists there properly gates this new feature too, not just the existing
sentiment card.

---

## Acceptance checklist
- [ ] Confirmed whether `api_keys.dart` existed with a real key (Phase 1.1)
- [ ] Confirmed via logs whether failures were happening and why (Phase 1.2)
- [ ] Real Groq key in place, not committed to git
- [ ] New `dailyScreenTimeGoalSec`-style field added, exposed in UI, and
      used instead of `allowedShortsTimeSec`
- [ ] Fallback paths now log errors instead of failing silently
- [ ] Confirmed sentiment/recommendations actually change across different
      real usage patterns, not just returning the same static values
- [ ] New unified mood/persona/chat/sentiment context aggregator built
- [ ] Separate funny-tone Groq prompt/method added, distinct from the
      existing serious recommendations
- [ ] Trigger/frequency and caching strategy decided and implemented
- [ ] Feature surfaced in UI, tonally separated from the existing serious
      AI Analysis card
- [ ] Existing privacy settings confirmed to gate this new feature too