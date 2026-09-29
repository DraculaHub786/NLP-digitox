# Design Audit — Task 0 inventory (Guide 7)

**Date:** 2026-08-07
**References:** `Demo-light.png`, `Demo-dark.png` (repo root)

## 1. Reference images

- `Demo-light.png` — light botanical-glass reference.
- `Demo-dark.png` — dark deep-forest-glass reference.

## 2. Screen inventory

- `lib/ui/screens/` — splash, auth (login/signup/forgot-password ×3),
  home/dashboard (`tab_dashboard`, `modern_glance_cards`,
  `modern_dashboard_components`, `sliver_ai_analysis`,
  `sliver_funny_motivation`, `sliver_tips_and_tricks`,
  `greetings_username`, `settings_fab`), home tabs (statistics,
  notifications, bedtime, focus timeline), focus, achievements,
  leaderboard, settings (general/account/analysis/about + privacy),
  productivity (habits/tasks/notes), restriction groups, websites
  blocking, shorts blocking, app dashboard, active session, change
  logs, parental controls, onboarding, moods, shared sessions.
- `lib/ui/common/` — 50+ shared widgets including the new primitives
  `glass_card.dart`, `pill_button.dart`, `glass_nav_bar.dart`,
  `treated_background_image.dart`, `status_dot.dart`.

## 3. Theme wiring (`lib/config/app_themes.dart` / `digitox_app.dart`)

- Both `AppTheme.lightTheme` and `AppTheme.darkTheme` define full
  `ColorScheme` (seed-based botanical + explicit botanical surfaces).
- `ThemeExtension` is used: `GlassTokens` and `ElevationTokens` are
  attached to both `ThemeData` objects.
- `MaterialApp` in `lib/digitox_app.dart` wires
  `theme: AppTheme.lightTheme(...)`, `darkTheme: AppTheme.darkTheme(...)`,
  `themeMode: ThemeMode.values[themeMode.index]` driven by
  `digitoxSettingsProvider` — the plumbing was already correct.
  The dark-mode bug was caused by hardcoded literals in widgets, not
  by missing theme plumbing.

## 4. Hardcoded-color inventory (files with `Colors.white` / `Colors.black` / `Color(0x…` outside `app_themes.dart`/`design_tokens.dart`)

| File | Literal(s) | Status |
|---|---|---|
| `lib/ui/screens/home/dashboard/sliver_funny_motivation.dart` | `Colors.white70/white54/white12/white/black/black87`, `Color(0xFF2D2A1A)`, `Color(0xFFFFF3CD)`, `Color(0x33000000)` | **FIXED** — converted to `DesignPalette.funny*` tokens + `colorScheme`-derived colors |
| `lib/ui/screens/home/dashboard/modern_glance_cards.dart` | none | clean (Task 3 fixed) |
| `lib/ui/screens/home/dashboard/modern_dashboard_components.dart` | none | clean (Task 3 fixed) |
| `lib/ui/screens/home/dashboard/sliver_ai_analysis.dart` | none (only `withOpacity` deprecation infos) | clean |

`findstr` re-scan of `lib/ui/screens/home/dashboard/*.dart` now returns
zero matches for `Colors.white`, `Colors.black`, or `Color(0x`.

## 5. Radius audit (Guide 6 §7 / Task 7)

- Token values: `GlassTokens.radiusCard = 24`, `radiusPill = 999`.
- Stray intermediates found and unified:
  - `modern_glance_cards.dart`: `_ModernMiniCard` 20 → 24;
    `ModernQuickActionButton` 16 → 999 (pill).
  - `modern_dashboard_components.dart`: `ModernListTile` 16 → 24;
    `ModernSettingsTile` 16 → 24.
  - `modern_cards.dart`: `ModernMetricCard` 20 → 24;
    `ModernListTile` 16 → 24.

## 6. Verification

- `flutter analyze lib` — **0 errors, 0 warnings** after fixes; remaining
  issues are pre-existing info-level deprecations (`withOpacity`,
  `activeColor`, `use_build_context_synchronously`).
- Previous compile blockers fixed: missing `AppRoutes.forgotPassword*`
  getters registered in `lib/config/navigation/app_routes.dart`; unused
  `flutter_animate` import removed from `scaffold_shell.dart`.
