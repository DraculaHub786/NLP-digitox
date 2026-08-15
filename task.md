# NLP Digitox — REMAINING TASKS

> Everything else from the original task doc (bugs 1.1–1.3, 2.1–2.2, shorts scaffolding 3.1, brand icons 3.3, translations 3.4, UI revamp 4.1–4.4) is **DONE and verified** — `flutter analyze --no-pub` → No issues found, `flutter gen-l10n` clean. See `progress_tracking.md` for the full per-item record.
>
> This file tracks only what's left.

## Remaining

### 🔲 3.2 — REQUIRED before shipping: verify X/Threads view IDs on a real device

**File:** `android/app/src/main/java/com/nlp/digitox/services/accessibility/ShortsPlatformManager.kt`

**Status:** Detection stubs exist and compile, but the two hard-coded view IDs are
UNCONFIRMED. Until verified, the X/Threads toggles render but never trigger blocking.
X caveat: X shipped a full Kotlin/Compose rewrite in July 2026 — any pre-rewrite
online ID is likely stale. Threads is built on Instagram's codebase, so its IDs may
differ from Instagram's.

**Fastest capture path (already instrumented in code):**
The manager ships a throttled Logcat viewer-ID walker (`logCandidateVideoViewIds`,
tag `Mindful.ShortsPlatformManager`, 5s interval, matches
`video|player|reel|clip|media|immersive`).

1. Install the app on a device/emulator, grant Accessibility, enable the X toggle
   in Shorts Blocking.
2. Open the video surface in X (full-screen vertical video player).
3. `adb logcat -s Mindful.ShortsPlatformManager` → the walker logs
   "X video view candidates: [...]". Pick the ID that wraps the video player.
4. Repeat steps 1–3 for Threads (open a Reels-style video) → "Threads video view candidates".
5. Paste the two IDs into `doesNodeByIdExists(node, "...")` inside
   `isXFeatureOpen` / `isThreadsFeatureOpen`, delete the placeholder IDs + the
   commented-out walker, and test that toggling the switch blocks the surface.

**Alternative:** `adb shell uiautomator dump` + search `window_dump.xml` for the
`resource-id` of the video container, then same paste step.

**Note:** X doesn't have one dedicated "Shorts" surface — its short-form video lives
inside the general timeline/video player. Reconsider whether blocking X video playback
(vs. the existing whole-app restriction during focus hours) is the right fit.

---

### 🔲 1.4/1.5 — On-device visual verification only

Implemented in code and analyze-clean, but not yet visually confirmed on a device:
- Onboarding carousel should render full-height (no "half screen" band).
- Welcome page shows the square `logo-prev.png` mark above the illustration.

Run the app once and confirm both; if either still looks off, report back with a
screenshot.

---
# NLP digitox — Remaining TODO
_Updated: 2026-08-15_

---

## ✅ 1. Finish the remaining translations

**COMPLETED 2026-08-15** — all remaining translations are merged:

- **7,322 keys** machine-translated (GTX) and merged across **22 locales** (`af ca cs da de el fi fr he hu it ja ko nl no pl ro ru sr sv tr vi` — roughly 400–426 keys each; the remaining locales `ar es pt uk zh` were already complete).
- All 27 non-English ARB files now contain **every key** present in `app_en.arb` (443 keys); verified **0 missing keys** across all locales.
- ICU plural keys (`nDays`/`nHours`/`nMinutes`/`nSeconds`) rebuilt from corrected unit words — fixed the ordinal-"second" mistranslation that affected 14 locales (e.g. `de`→"zweite", `ru`→"второй").
- `flutter gen-l10n` passes · `flutter analyze` clean ("No issues found!").
- `untranslated_strings.json` now contains `{}` (was ~400 keys × 22 locales).

Note: translations are bulk machine-translated; high-traffic UX surfaces (permissions, onboarding, focus, settings) still warrant a native-speaker review pass before release.
Status: **not yet committed**.

---

## 🔲 2. On-device verification of the sentiment analysis

Cannot be done from a dev machine — requires a real Android device/build and the (already present) Groq key.

1. **Seed emotional context** — send a few chat messages mentioning something concrete (e.g. “work has been stressful” twice), and/or log a mood check-in as *Anxious*.
2. **Check the result** — open Dashboard → AI/Sentiment card. It should visibly shift toward Anxious/Negative, not just track raw screen-time numbers.
3. **Confirm the extractors ran** — watch debug logs for `🧠 ChatContextExtractor:` and `📈 SentimentPersistenceService:` lines.
4. **Fast-forward the 30-day deletion test** — in `lib/core/services/ai_chatbot_service.dart`, temporarily set `_autoDeletionDays = 1`; send a message, wait, reopen the app, and verify the chat session, extracted themes, and sentiment snapshot all disappear together — then revert to `30` and rebuild.

---

## 🔲 3. Push the committed work to origin

Both commits are local on `UI-enhancement` only:

- `4f73fac` — sentiment wiring + 30-day pruning
- `98cc101` — translation backfill + dead `sentiment_filter.dart` removal

The original todo warned this sentiment work would be lost if never pushed. Push when ready:

```
git push origin UI-enhancement
```

Note: `lib/config/api_keys.dart` and `untranslated_strings.json` are gitignored, so they will not (and should not) be pushed. The new translation merge (Task 1) is still uncommitted and should be committed before pushing.

---

## ✅ Done (kept here only as commit refs)

- **Sentiment wiring** — chat-theme + mood-check-in context feed into `AISentimentService.analyzeSentiment()`, results persisted by `aiSentimentProvider` (`sentiment_wiring.patch`). Committed: `4f73fac`
- **30-day retention fix** — `_autoDeleteOldChats()` now prunes `SentimentPersistenceService` snapshots + `ChatContextExtractor` themes on the same 30-day clock as the chats. Committed: `4f73fac`
- **Groq API key** — verified real (`gsk_vA01…`, not the `YOUR_…` placeholder) in `lib/config/api_keys.dart` (gitignored). No action needed.
- **Translation backfill** — 445 strings added across 27 `lib/l10n/app_*.arb` files + regenerated localizations; deleted dead `lib/core/services/sentiment_filter.dart` and its test. Committed: `98cc101`
- **Static checks** — `flutter analyze` clean · `flutter gen-l10n` passes · scoped tests green.
- **Remaining translations (Task 1)** — 7,322 keys machine-translated across 22 locales and merged into `lib/l10n/app_<loc>.arb`; all 27 non-English ARBs have 0 missing keys vs `app_en.arb`; `untranslated_strings.json` = `{}`; `flutter analyze` clean. Not yet committed.
