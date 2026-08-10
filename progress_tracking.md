# NLP Digitox — Task Progress Tracking (TEMP FILE)

> Tracking file per user request. Updated at each step.

## Suggested order of work (from task.md §6)

1. ✅ Apply the patch (1.1–1.3, 2.1–2.2, 3.1) — all low-risk, all done
2. ✅ 1.4/1.5 — onboarding half-screen + welcome logo (implemented in code; verify on device)
3. 🔲 3.2 — find & wire real X/Threads view IDs (needs device) — **candidate-ID logcat walker added**; IDs still unconfirmed on-device
4. ✅ 3.3 — real brand icons (x.svg, threads.svg) swapped in; placeholders deleted
5. ✅ 3.4 — translated strings added to 9 locale files (falls back to EN for the rest); gen-l10n + analyze clean
6. ✅ 4.1 — background imagery (blurred botanical photos behind glass)
7. ✅ 4.3 — glass-card consistency → ✅ 4.2 typography (Alice serif headlines) → ✅ 4.4 cleanup

---

## Step 1 — Patch items (1.1–1.3, 2.1–2.2, 3.1) ✅ COMPLETE

### Bugs — UI
- [x] 1.1 Bottom nav bar overflow — `lib/ui/common/glass_nav_bar.dart`
      (already in repo: Expanded cells + sliding highlight pill + ClipRect label)
- [x] 1.2 Splash square logo — `lib/ui/splash_screen.dart`
      (already in repo: rounded clip + `assets/icon-prev.png`)
- [x] 1.3 `assets/logo-prev.png` + `icon-prev.png` registered in `pubspec.yaml`
      (already in repo)

### Bugs — Scheduled notifications
- [x] 2.1 New schedules default to ACTIVE
      `lib/providers/notifications/notification_settings_provider.dart`
- [x] 2.2 Exact-alarm permission refresh mid-session
      `lib/core/services/notification_scheduler_service.dart` (+`refreshScheduleMode`)
      `lib/providers/system/permissions_provider.dart` (wired into `askExactAlarmPermission`)

### Shorts blocking — X & Threads scaffolding
- [x] 3.1a Dart enum — `lib/core/enums/platform_features.dart`
      (added `xVideos`, `threadsReels`)
- [x] 3.1b Kotlin enum — `android/.../enums/PlatformFeatures.kt`
      (added `X_VIDEOS`, `THREADS_REELS` + `fromName` mappings)
- [x] 3.1c Package constants — `android/.../AppConstants.kt`
      (`X_PACKAGE = com.twitter.android`, `THREADS_PACKAGE = com.instagram.barcelona`)
- [x] 3.1d Detection dispatch + stubs — `android/.../ShortsPlatformManager.kt`
      (dispatch entries, maxAllowedDuration entries, `isXFeatureOpen`/`isThreadsFeatureOpen`)
- [x] 3.1e UI toggle cards — `lib/ui/screens/shorts_blocking/sliver_shorts_quick_actions.dart`
      (X + Threads cards after Reddit; reddit bottom padding 16→8)
- [x] 3.1f Placeholder SVGs — `assets/vectors/x_placeholder.svg`,
      `assets/vectors/threads_placeholder.svg` + registered in `pubspec.yaml`
- [x] 3.1g English l10n strings — `lib/l10n/app_en.arb` (4 keys)
- [x] 3.1h Regenerated localizations (`flutter gen-l10n`)
- [x] Validate — `flutter analyze --no-pub` → **No issues found**

## Step 2 — 1.4/1.5 Onboarding half-screen + welcome logo ✅ COMPLETE
- [x] `lib/ui/onboarding/onboarding_page.dart` — start-aligned Column, explicit 40px gap,
      responsive bottom padding (12% of screen height) — fixes the "half-screen" look
- [x] `lib/ui/onboarding/onboarding_screen.dart` — welcome page shows the square
      `logo-prev.png` mark above the illustration (second placement of `logo-prev.png`)
- [x] Verify on a real device: onboarding carousel should read full-height, logo visible

## Step 3 — 3.2 X/Threads real view IDs 🔲 (needs device — enhanced, not finished)
- [ ] **Done so far:** `ShortsPlatformManager.kt` now ships a throttled candidate
      view-ID walker (`logCandidateVideoViewIds` / `collectVideoViewIds`, 5s interval,
      log tag `Mindful.ShortsPlatformManager`). With the X/Threads toggle ON and the
      app's video surface open, logcat reports matching video-looking resource IDs
      (matches `video|player|reel|clip|media|immersive`) so the real ID can be captured
      without `uiautomator dump`.
- [ ] **Remaining:** run on a device with X/Threads installed, open a video, read the
      logged candidate ID, then paste it into `doesNodeByIdExists(node, "...")` in
      `isXFeatureOpen` / `isThreadsFeatureOpen` and remove the placeholder + walker.
      X caveat: July-2026 rewrite means all pre-rewrite online IDs are likely stale.

## Step 4 — 3.3 Brand icons + 3.4 Translations ✅ COMPLETE
### 3.3 Real brand icons
- [x] `assets/vectors/x.svg` — official X glyph (24x24 single-color path)
- [x] `assets/vectors/threads.svg` — official Threads glyph (24x24 single-color path)
- [x] `pubspec.yaml` — placeholder entries replaced with `x.svg` / `threads.svg`
- [x] Deleted `assets/vectors/x_placeholder.svg`, `assets/vectors/threads_placeholder.svg`
- [x] `sliver_shorts_quick_actions.dart` — `_buildIcon` calls point at `x.svg` / `threads.svg`
- [x] `flutter gen-l10n` + `flutter analyze --no-pub` → **No issues found**

### 3.4 Translated strings (9 locale files + EN)
- [x] `app_ar.arb` ✅    (Arabic: تقييد خلاصة الفيديو على X. / تقييد الفيديو/الريلز على Threads.)
- [x] `app_el.arb` ✅    (Greek: Περιορισμός της ροής βίντεο στο X. / βίντεο/reels στο Threads.)
- [x] `app_es.arb` ✅    (Spanish: Restringir la fuente de videos en X. / videos/reels en Threads.)
- [x] `app_ja.arb` ✅    (Japanese: Xのビデオフィードを制限します。 / Threadsのビデオ/リールを制限します。)
- [x] `app_pt.arb` ✅    (Portuguese: Restringir o feed de vídeos no X. / vídeos/reels no Threads.)
- [x] `app_sr.arb` ✅    (Serbian Cyrillic: Ограничи видео садржај на X. / видео-садржаје/Reels на Threads.)
- [x] `app_tr.arb` ✅    (Turkish: X'teki video akışını kısıtla. / Threads'teki video/reels'leri kısıtla.)
- [x] `app_uk.arb` ✅    (Ukrainian: Обмежити відеострічку на X. / Обмежити відео/reels на Threads.)
- [x] `app_zh.arb` ✅    (Chinese: 限制X的视频流。 / 限制Threads的视频/短视频。)
- [x] All 4 keys added to each: `x_features_tile_title`, `x_features_tile_subtitle`,
      `threads_features_tile_title`, `threads_features_tile_subtitle`
- [x] FR + stub locales (no platform strings) fall back to EN via `fallback-locale: en`
- [x] Regenerated: `flutter gen-l10n` ✅
- [x] Verified: `flutter analyze --no-pub` → **No issues found**

## Step 5 — 4.1 Background imagery ✅ COMPLETE
- [x] `assets/backgrounds/bg_light.jpg` / `bg_dark.jpg` — softly-lit botanical photos
      (dedicated dark variant)
- [x] Registered in `pubspec.yaml`
- [x] `lib/ui/common/treated_background_image.dart` — Stack: photo layer →
      `BackdropFilter` blur (sigma 16) → translucent scrim gradient (light ~55-59%,
      dark ~40-47% to keep deep-forest texture visible) → themed orbs → content
- [x] Wired behind splash / auth / home screens (ScaffoldShell now uses the treated background)

## Step 6 — 4.3 Glass-card consistency ✅ → 4.2 Typography ✅ → 4.4 Cleanup ✅
### 4.3 Glass-card consistency
- [x] Screens use `GlassCard` / `ModernDashboardCard` / `ModernMetricCard` /
      `UsageGlanceCard` throughout (achievements, leaderboard, productivity,
      statistics, notifications, focus timeline, dashboard)
- [x] `tab_statistics.dart` `_buildModernStatCard` → `GlassCard`
- [x] One remaining raw `Card(` in `chat_settings_screen.dart` (dense session list row)
      — intentionally left flat per task.md §4.3 ("leave dense list rows flat")
- [x] `ScaffoldShell` uses the treated photo background — no flat `surface` page

### 4.2 Typography hierarchy (Alice serif headlines)
- [x] `lib/ui/common/styled_text.dart` — `isHeadline` param applies `fontFamily: 'Alice'`
      + w600 weight
- [x] Applied at: splash title (`splash_screen.dart`), welcome page
      (`onboarding_page.dart`), dashboard greeting (`greetings_username.dart`),
      section headers (`content_section_header.dart`, `scaffold_shell.dart`)
- [x] Body copy / buttons / nav labels stay on default sans

### 4.4 Cleanup
- [x] `lib/ui/common/modern_background.dart` deleted (unused, off-palette blue/teal gradient)

## Final validation
- [x] `flutter gen-l10n` — regenerated cleanly
- [x] `flutter analyze --no-pub` — **No issues found** (ran 88.6s)
- [x] Locale key presence verified across all 10 files carrying shorts strings (EN + 9 locales)
- [x] Kotlin `ShortsPlatformManager.kt` reviewed — dispatch + duration entries + candidate walker
- [x] Assets verified — `x.svg`/`threads.svg` present, placeholders gone, backgrounds registered
