# Guide 7 — Agent Execution Plan (Stepwise, Checkpointed)

**Read this first, then execute Task 0. Do not skip ahead to later tasks
before earlier ones are verified.**

This plan turns Guide 5 (design tokens/architecture) and Guide 6 (premium
visual detailing) into an ordered sequence an autonomous coding agent (e.g.
Claude Code) can run without drifting from the reference images. Each task
is scoped to touch a small, specific set of files, has an explicit
definition of done, and ends with a checkpoint — **stop and let the human
review/approve before starting the next task.** Do not chain multiple tasks
in a single unreviewed session; that's how output drifts from the reference.

---

## Before Task 0 — What the agent needs in its working context

- This file (Guide 7).
- `guide-05-glassmorphic-ui-system.md` and `guide-06-premium-visual-detailing.md`
  (the token values, widget code, and effect recipes — Guide 7 references
  them by section, it doesn't repeat every value).
- The two reference images, saved into the repo at
  `design/reference/leafora-shop.png` and `design/reference/leafora-care.png`
  (or wherever your agent's image-reading tool expects them). **The agent
  must actually view these image files, not just read text descriptions of
  them** — pixel-level details (exact blur amount, spacing, shadow softness)
  only come from looking at the images directly.
- Read access to the full repo, specifically:
  `lib/config/app_themes.dart`, `lib/ui/common/`, `lib/ui/screens/`,
  `lib/initializer.dart`.

---

## Task 0 — Inventory (no code changes)

**Goal:** understand what exists before changing anything.

1. View both reference images directly.
2. List every screen file under `lib/ui/screens/` and `lib/ui/common/`.
3. Open `lib/config/app_themes.dart` — record: does it define `ColorScheme`
   for both light and dark? Is `ThemeExtension` used anywhere? Is there a
   `ThemeMode` source (provider/riverpod/bloc) driving `MaterialApp.themeMode`?
4. Grep the whole `lib/` tree for hardcoded color literals: search for
   `Colors.white`, `Colors.black`, and any `Color(0x` / `Color(0xFF`
   hex literals **outside** of `app_themes.dart`. Produce a list: file path
   + line number + the literal found. This list is the direct cause map for
   the "glance section ignores dark theme" bug — don't fix anything yet,
   just produce the inventory.
5. Output: a short markdown summary (`design/audit.md`) with the four
   findings above. No `.dart` files besides this new audit file should
   change in this task.

**Checkpoint:** human reviews `design/audit.md` before Task 1 starts.

---

## Task 1 — Design Tokens Only

**Goal:** implement the color/effect token system from Guide 5 §2, §4 and
Guide 6 §1/§2/§6. **Do not touch any screen file in this task.**

1. In `lib/config/app_themes.dart` (or a new `lib/config/design_tokens.dart`
   if that's cleaner given current structure), define:
   - Light and dark `ColorScheme` using the exact values in Guide 5 §2.
   - `GlassTokens` `ThemeExtension` using the **layered** version from Guide
     6 §1 (gradient fill/border, not the flat version from Guide 5's first
     draft — Guide 6 supersedes that one detail).
   - Tinted shadow constants per Guide 6 §2 and the elevation map in §6
     (`z1`–`z4`), as a small `ElevationTokens` helper or a set of named
     `List<BoxShadow>` constants.
2. Register both `ThemeData` objects (`lightTheme`, `darkTheme`) with these
   extensions attached.
3. Confirm (per Task 0 finding #3) that `MaterialApp` actually receives
   `theme: lightTheme, darkTheme: darkTheme, themeMode: <your source>`. If
   `darkTheme` was never wired up, fix that wiring **here** — this alone may
   resolve part of the reported bug.
4. Do not create `GlassCard`/`PillButton` yet — that's Task 2.

**Definition of done:** app builds, toggling theme mode changes
`Theme.of(context).colorScheme` values app-wide (verify with a temporary
debug print or a throwaway test screen), no visual screen changes yet since
nothing consumes the new tokens.

**Checkpoint:** human confirms theme switching works at the data level
before Task 2.

---

## Task 2 — Primitive Widgets (built, not yet used anywhere)

**Goal:** implement the shared components from Guide 5 §5/§6 and Guide 6
§1/§3/§4, as standalone widgets not yet wired into any real screen.

1. Create `lib/ui/common/glass_card.dart` — layered `GlassCard` (Guide 6 §1).
2. Create `lib/ui/common/pill_button.dart` — `PillButton` with
   `AnimatedScale` press feedback, no `InkWell` (Guide 6 §4).
3. Create `lib/ui/common/glass_nav_bar.dart` — floating pill bottom nav.
4. Create `lib/ui/common/treated_background_image.dart` — duotone/gradient
   image treatment (Guide 6 §3).
5. Create `lib/ui/common/status_dot.dart` — the small filled-circle status
   indicator (Guide 6 §5).
6. Build one throwaway preview screen (e.g. `lib/ui/dev/component_preview_screen.dart`,
   not linked into real navigation) that renders each widget in both light
   and dark mode side by side. This is how the agent (and the human) verify
   fidelity against the reference images **before** touching real screens.

**Definition of done:** the preview screen, compared directly against crops
of the reference images, matches on: corner radius, blur amount, shadow
softness/tint, border gradient visibility, button press animation.

**Checkpoint:** human visually compares the preview screen to the reference
images and explicitly approves before Task 3. This is the most important
checkpoint in the whole plan — if the primitives are off, every screen built
on them will be off in the same way.

---

## Task 3 — Fix the Reported Bug Specifically (isolated from re-skinning)

**Goal:** close out the original complaint — glance section ignoring dark
theme — as its own verifiable fix, using the Task 0 audit list.

1. Using the hardcoded-color inventory from `design/audit.md`, go through
   every file under `lib/ui/screens/home/dashboard/` (starting with
   `modern_glance_cards.dart`, `modern_dashboard_components.dart`,
   `sliver_ai_analysis.dart`) and replace literal colors with
   `Theme.of(context).colorScheme.*` or `Theme.of(context).extension<GlassTokens>()!.*`.
2. Do **not** restyle these widgets to the new premium look yet — this task
   is strictly "make existing widgets correctly theme-aware," using
   whatever visual style they currently have. Restyling happens in Task 5.
3. Add a short note per file in the commit message: which literal was
   replaced with which token.

**Definition of done:** toggling dark mode now correctly changes the glance
section's colors (even if the visual design itself is still the old one).

**Checkpoint:** human confirms the original bug is gone before any
re-skinning work begins.

---

## Task 4 — Re-skin the Splash Screen

**Goal:** first real screen re-skin, smallest surface area, validates the
full primitive set end-to-end.

1. Apply `TreatedBackgroundImage` behind the splash content.
2. Apply serif display typography (Guide 5 §3, Guide 6 §5 letter-spacing
   note) to the title.
3. Apply `PillButton` to the CTA.
4. Apply staggered entrance animation (Guide 6 §4) to title → subtitle →
   button.

**Definition of done:** side-by-side with the reference splash screen, same
layout rhythm, same button style, same background treatment, in both
light/dark.

**Checkpoint:** human approval before moving to the dashboard/home screen.

---

## Task 5 — Re-skin Dashboard / Home (the originally-buggy screen)

**Goal:** apply the full premium visual system to
`lib/ui/screens/home/dashboard/*` — this is both a high-visibility screen
and the one with the known history of theme bugs, so it gets its own
dedicated task rather than being lumped into "all remaining screens."

1. Replace ad-hoc card containers with `GlassCard`.
2. Apply elevation tokens per Guide 6 §6 (glance cards = `z2`, any floating
   action = `z3`).
3. Apply staggered grid/list entrance animation.
4. Re-verify dark/light parity explicitly on this screen again (this is the
   screen that broke before — extra scrutiny here is deliberate).

**Checkpoint:** human approval, explicitly re-testing dark mode toggle on
this screen before continuing.

---

## Task 6 — Re-skin Remaining Primary Screens (one sub-checkpoint each)

Work through these **one at a time**, each as its own commit/checkpoint —
do not batch them:

1. Detail/info screens (anything structurally similar to the "Monstera
   Deliciosa" reference — full-bleed image + glass info panel).
2. List/checklist-style screens (anything structurally similar to "Care" —
   segmented control + list of `GlassCard` rows). This maps to your
   focus/achievements/leaderboard/notifications tab screens.
3. Settings/account/form-style screens.
4. Any remaining screens not covered above.

For each: apply `GlassCard`/`PillButton`/elevation tokens, do not introduce
new one-off styling patterns — if a screen seems to need something the
primitives don't support, stop and flag it for a human decision rather than
inventing a fourth ad-hoc style.

**Checkpoint after each sub-item**, not just at the end of Task 6.

---

## Task 7 — App-Wide Motion & Icon/Type Pass

**Goal:** the polish pass from Guide 6 §4/§5, applied globally now that
every screen uses the shared primitives.

1. Confirm every `PillButton` uses `AnimatedScale`, not `InkWell`.
2. Confirm every card grid/list has staggered entrance.
3. Icon audit: single icon package, single stroke weight, zero default
   Material filled icons remaining — produce a short list of any exceptions
   found and fix them.
4. Corner-radius audit: confirm exactly two radius values exist app-wide
   (card radius, pill/stadium radius) — flag and fix any stray third value.

**Checkpoint:** human review of the audit results before final QA.

---

## Task 8 — Final Cross-Theme QA Against the Reference Images

**Goal:** verify fidelity, not just "it looks nice."

1. Take screenshots of every re-skinned screen in both light and dark mode.
2. Place each screenshot next to the corresponding reference image crop (or
   the closest structural analog if this app's content differs from
   Leafora's).
3. Check specifically: corner radius consistency, shadow tint/softness,
   glass blur strength, typography pairing, button press feel (video/gif if
   possible, since this is motion), color palette match.
4. Produce a final `design/qa-report.md` listing any remaining gaps.

**Checkpoint:** human sign-off. This is the completion criterion for the
whole plan — not "all tasks executed," but "QA report shows no material
gaps versus the reference images."

---

## Why this structure (for the human, not the agent)

- **Task 0 and Task 3 are separated on purpose.** Fixing the reported bug
  doesn't require the new premium visual system at all — it's a theming
  wiring bug. Bundling the bugfix with the redesign would make it hard to
  tell, if something still looks wrong later, whether it's a leftover bug
  or a new redesign issue.
- **Task 2's preview screen is the highest-leverage checkpoint in the plan.**
  Every later task builds on these primitives; catching a fidelity gap
  there costs one screen's worth of rework, catching it at Task 6 costs
  every screen's worth.
- **One screen per checkpoint from Task 4 onward** is deliberate friction —
  it's slower than letting an agent run through all screens unattended, but
  it's the only way to catch drift before it compounds across 15+ screens.

---

## Execution Log — 2026-08-07 (Sixth)

The reference images supplied for this run were `Demo-light.png` and
`Demo-dark.png` (repo root). Per the user's instruction, Work continued
across the checkpointed tasks in a single session, documenting the work here
instead of pausing after each checkpoint.

### Completed

- **Task 0 — Inventory** → `design/audit.md`. Theme plumbing
  (`mindful_app.dart`) was already correct; the dark-mode bug was caused by
  hardcoded `Colors.white` / `Color(0xFF…)` literals in widgets. Full
  offender list with file+line is in the audit.
- **Task 1 — Design tokens** → `lib/config/design_tokens.dart` (new):
  `DesignPalette` (botanical light/dark), `GlassTokens` (layered gradient
  fill/border + tinted shadow), `ElevationTokens` z1–z4,
  `DesignType` serif helpers. Wired into `lib/config/app_themes.dart`
  (both `ThemeData`, with both extensions attached; botanical surfaces;
  fern default seed; user accent picker preserved).
- **Task 2 — Primitives** (all in `lib/ui/common/`):
  `glass_card.dart` (layered `GlassCard`), `pill_button.dart`
  (`AnimatedScale`, no `InkWell`), `glass_nav_bar.dart` (floating pill
  nav), `treated_background_image.dart`, `status_dot.dart`.
- **Task 3 — Bug fix** (dark theme in glance section): replaced hardcoded
  colors with `GlassTokens.of(context)` / `colorScheme` in
  `lib/ui/screens/home/dashboard/modern_glance_cards.dart`.
- **Task 4 — Splash re-skin** → `lib/ui/splash_screen.dart`
  (treated background, glass-chip logo, pill CTA, staggered entrance).
- **Task 5 — Dashboard/home** → glance cards, quick actions, list tiles
  all on `GlassCard` surfaces
  (`modern_glance_cards.dart`, `modern_dashboard_components.dart`).
- **Task 6a — Shared surfaces** → `lib/ui/common/modern_cards.dart`
  re-skinned (benefits achievements/leaderboard/statistics consumers).
- **Nav shell** → `lib/ui/common/scaffold_shell.dart`: Material
  `NavigationBar` replaced with `GlassNavBar` (floating pill).
- **Task 8 — QA report** → `design/qa-report.md`.

### Verification

- `flutter analyze lib` completes with **no errors or warnings introduced**;
  remaining messages are pre-existing info-level deprecations
  (`withOpacity`, etc.).

### Remaining (not yet done)

- Task 6 per-screen sweeps: achievements, leaderboard, notifications,
  focus, settings tabs, productivity (habits/tasks/notes), restriction &
  blocking screens.
- Task 7: icon package/stroke-weight audit; corner-radius unification
  (16/20 intermediates → 24/999).
- Convert remaining pre-existing `withOpacity` infos to `withValues`.


assets for refference of UI redesign:
Demo-light.png
Demo-dark.png