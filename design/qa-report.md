# Cross-Theme QA Report — Task 8 (Guide 7)

**Date:** 2026-08-07 (updated 2026-08-08)
**References:** `Demo-light.png`, `Demo-dark.png` (repo root)

## Status — FINAL

Tasks 0–5 complete; Task 6 per-screen sweeps complete for all primary and
most secondary screens; Task 7 corner-radius unification (24/999) applied
to all swept task.md-covered screens. The re-run audit sweep now shows every
dashboard file, and the general/account/about/database/bedtime/parental-
controls settings screens at **OK** (fully tokenized). Remaining non-OK
files are intentional design panels (AI-analysis hero chart), low-traffic
auth/onboarding/features flows structurally outside the reference
screenshots, the token definitions themselves (`app_themes.dart` /
`design_tokens.dart`), and `privacy_settings_screen.dart` (still carries
legacy Material icons + 12/16/18/20 radii).

## What was implemented

| Guide 7 task | Deliverable | File(s) |
|---|---|---|
| Task 0 | Inventory + hardcoded-color audit | `design/audit.md` |
| Task 1 | Botanical palette, `GlassTokens` (layered), `ElevationTokens` z1–z4 | `lib/config/design_tokens.dart` |
| Task 1 | Theme wiring: light/dark `ColorScheme`, both extensions attached, scaffold bg = botanical surface | `lib/config/app_themes.dart` |
| Task 2 | Layered `GlassCard` (gradient fill + gradient border + tinted shadow) | `lib/ui/common/glass_card.dart` |
| Task 2 | `PillButton` — stadium, `AnimatedScale` press, no `InkWell` | `lib/ui/common/pill_button.dart` |
| Task 2 | Floating pill `GlassNavBar` | `lib/ui/common/glass_nav_bar.dart` |
| Task 2 | `TreatedBackgroundImage` — botanical gradient + soft orbs | `lib/ui/common/treated_background_image.dart` |
| Task 2 | `StatusDot` — filled status indicator | `lib/ui/common/status_dot.dart` |
| Task 3/5 | Dashboard glance/quick-action cards → `GlassCard` + status tokens (fixes dark-mode glare) | `lib/ui/screens/home/dashboard/modern_glance_cards.dart` |
| Task 3 | Remaining dashboard hardcoded colors (funny-motivation card) → `DesignPalette` tokens | `lib/ui/screens/home/dashboard/sliver_funny_motivation.dart` |
| Task 3/5 | Dashboard list/settings tiles → `GlassCard` surfaces | `lib/ui/screens/home/dashboard/modern_dashboard_components.dart` |
| Task 4 | Splash re-skin (treated bg, glass-chip logo, serif title, pill CTA, staggered entrance) | `lib/ui/splash_screen.dart` |
| Nav shell | Tab `NavigationBar` → floating `GlassNavBar` | `lib/ui/common/scaffold_shell.dart` |
| Task 6 (shared) | Dashboard/metric/list cards → primitives (benefits achievements/leaderboard/statistics) | `lib/ui/common/modern_cards.dart` |
| Task 7 | Corner-radius audit: stray 16/20 → `radiusCard` 24 / `radiusPill` 999 | `modern_glance_cards.dart`, `modern_dashboard_components.dart`, `modern_cards.dart` |
| Fix | Compile blockers: `AppRoutes.forgotPassword*` getters registered | `lib/config/navigation/app_routes.dart` |
| Fix | Unused `flutter_animate` import removed | `lib/ui/common/scaffold_shell.dart` |

## Fidelity vs reference

- **Palette:** warm cream light / deep forest dark surfaces, fern accents —
  matches reference tones. User accent picker still works via `seedColor`.
- **Glass:** layered gradient fill + 1.2px gradient border (light top edge,
  sage bottom edge) + soft tinted `z1–z4` shadows — matches reference cards.
- **Radius:** two values only — 24 (cards), 999 (pills/chips).
- **Type:** Alice serif retained app-wide; titles now display-weight.
- **Motion:** press-scale on `PillButton`/`GlassCard`; staggered entrances on
  splash + dashboard.

## Remaining gaps

1. **Task 7 icon audit (final pass)** — fluentui_system_icons is the single
   package on swept screens; a few legacy `Icons.*` usages remain in
   untouched screens (auth, onboarding flow, `focus_session_screen.dart`,
   `intent_prompt.dart`), and a strict stroke-weight unification pass is
   still open.
2. **Un-swept low-traffic screens** — auth/login/signup, onboarding, and a
   few `features/` screens still use legacy styling (they are structurally
   outside the reference-image screenshots, so they were not re-skinned in
   this pass).
3. **Residual deprecation infos (22, all info-level)** — color hashing via
   `.value` in `app_themes.dart`, `avoid_print` in `platform_restriction_service.dart`,
   `sort_child_properties_last` in auth screens, `Switch.activeColor` on 4
   switches, and 3 `use_build_context_synchronously` infos (guarded by
   `mounted`). None affect runtime; all `withOpacity` deprecations are gone.

## Verification

- `flutter analyze lib` — **0 errors, 0 warnings**; 22 info-level issues
  remain (down from 77 incl. 2 errors + 1 warning at session start, and from
  47 at the previous checkpoint). All ~30 `withOpacity` deprecations across
  the sweep eliminated (converted to `withValues`).
- `findstr` over `lib/ui/screens/home/dashboard/*.dart` — zero matches for
  `Colors.white`, `Colors.black`, `Color(0x` (hardcoded-color bug fully
  closed for the originally-buggy screen area).
- Theme switching (light/dark) now changes surfaces app-wide because every
  re-skinned widget reads `Theme.of(context)` / `GlassTokens.of(context)`.

## Task 6/7 sweep (2026-08-08)

Completion of the per-screen sweeps that were open at the 2026-08-07
checkpoint, plus full `withOpacity → withValues` conversion:

- **Dashboard/AI**: `sliver_ai_analysis.dart` — sentiment colors →
  `GlassTokens.status*`/`DesignPalette`, all `withOpacity` → `withValues`,
  radius 16 → `radiusCard`/`radiusPill`.
- **Achievements**: `achievements_screen.dart` — `Colors.orange` →
  `DesignPalette.goldWarm` (2 sites), chip/card radius → 24/999.
- **Restriction/blocking**: `restriction_groups_screen.dart`,
  `restriction_group_card.dart`, `shorts_blocking_screen.dart`,
  `sliver_shorts_quick_actions.dart`, `websites_blocking_screen.dart`,
  `website_tile.dart` — info cards 16 → 24, count chips 20 → 999,
  Material `Icons.*` → `FluentIcons`.
- **Leaderboard**: `leaderboard_screen.dart` — error banner/skeleton → 24,
  reset-copy chip → 999 (file rewritten cleanly).
- **Focus**: `focus_configurations.dart` — timer chip 20 → 999
  (`tab_focus.dart`, `focus_timeline` were already tokenized).
- **Settings**: `tab_general.dart` — 4 card containers 20 → 24,
  `withOpacity` → `withValues`; `chat_settings_screen.dart` —
  `Colors.red` → `colorScheme.error`, `withOpacity` → `withValues`,
  `Card` radius → 24.
- **Global deprecation sweep**: `focus_session_screen.dart`,
  `soft_lock_overlay.dart`, `permission_page.dart` — remaining
  `withOpacity` → `withValues`.

### Final sweep (2026-08-08, session 2)

Re-ran `audit_sweep.ps1` and closed the remaining task.md-covered gaps:

- **Dashboard leftovers (all show OK in the audit now):**
  - `modern_glance_cards.dart` — trend badge + icon chips 12/14 →
    `radiusPill`.
  - `modern_dashboard_components.dart` — Material `Icons.chevron_right_rounded`
    → `FluentIcons.chevron_right_20_regular`; icon chips 14 → `radiusPill`.
  - `greetings_username.dart` — edit chip 8 → `radiusPill`.
  - `sliver_funny_motivation.dart` — card 20 → `radiusCard`; shimmer 6 →
    `radiusPill`.
  - `sliver_tips_and_tricks.dart` — `Colors.primaries[...]` →
    theme-aware `colorScheme` / `GlassTokens` accent rotation.
- **Settings tabs & database (all OK):**
  - `tab_account.dart` — danger zone → `colorScheme.error`; email-verify
    banner → `GlassTokens.statusWarn`; spinners → `onPrimary`/`scrim`; all
    cards 20 → 24; all chips 12/10 → pill; dialog reds → `colorScheme.error`.
  - `tab_about.dart` — hero/support/contribute/privacy cards 20 → 24;
    badges 20 → pill; logo chip 120 → pill; donation tile 16 → 24 +
    icon 14 → pill; shield chip 12 → pill.
  - `tab_analysis.dart` — range selector 16/12 → pill; error card 20 → 24.
    (Hero chart card keeps its dark-gradient/white palette by design — a
    deliberate contrast panel matching the reference.)
  - `tab_general.dart` — color swatch 18 → pill; AI-goal chip 12 → pill;
    stepper buttons 8 → pill.
  - `export_clear_crash_logs.dart`, `import_export_db.dart` — containers
    20 → `radiusCard`.
- **Home & parental (all OK):**
  - `bedtime_quick_actions.dart` — container 20 → `radiusCard`.
  - `parental_controls_screen.dart` — uninstall-window chip 20 → pill.
  - `invincible_mode_settings.dart` — info/mode/restriction cards 16/20 →
    24; icon chips 12/10 → pill; window chip 20 → pill; check-item cards
    16 → 24.

**Final verification:** `flutter analyze lib` — **0 errors, 0 warnings**;
22 info-level issues (same pre-existing set: color-hash deprecations in
`app_themes.dart`/`focus_session/models.dart`, `avoid_print`,
`sort_child_properties_last` in auth screens, `Switch.activeColor` on 4
switches, 3 `use_build_context_synchronously`, all guarded/info-level).
`design/sweep-audit.txt` persists the full-file audit results.
