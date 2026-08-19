# 🌿 NLP-Digitox — Master UI Overhaul Guide (Agent Execution Doc)

> **Audience:** an AI coding agent operating directly on this repository. Every subtask below states exactly which file to open, what pattern to find, and what to replace it with. Do not skip the "Read this file first" step in any subtask — do not guess at surrounding code structure.
>
> This document **supersedes and merges** the two prior guides (glass-removal foundation + targeted screen fixes) into one execution plan. Work top to bottom. Do not reorder phases — later phases depend on tokens/components created in earlier ones.

---

## 0. Locked-In Design Decisions

| Decision | Choice |
|---|---|
| Font | Alice — everywhere (headings + body) |
| Background | Botanical gradient/photo background — full-bleed on **every** screen, no exceptions |
| Glass effect (blur + translucent fill) | **Removed entirely**, replaced by tonal `SurfaceCard` (soft shadow + thin border, no blur) |
| Accent color (icons, CTAs, highlights) | **Orange** — on **grey** surfaces in light theme, on **near-black** surfaces in dark theme (see reference screenshots) |
| Brand/botanical green | Reserved for background gradient + splash/onboarding only — not used as the interactive accent anymore |
| State management | Riverpod — untouched |
| Nav bar sizing | No hardcoded pixel heights/widths — fully adaptive to content and screen width |
| Fancy animation (particles, wave curves) | Splash & Onboarding only |

**Confirmed app structure (do not re-derive, do not question):**
- `scaffold_shell.dart` hosts the 5 real tabs — **Dashboard, Statistics, Notification, Bedtime, Leaderboard** — inside an `IndexedStack`, wrapped once in `BotanicalBackground`. These 5 tabs already have a correct background. Do not touch how the shell applies its background.
- The following screens are pushed as **separate routes outside the shell** (`Navigator.push`) and currently render with a flat solid background instead of the full botanical background: **Group App Blocking, Shorts Blocking, Website Blocking, Habits, Tasks, Notes, Parental Control.** These are the only screens that need the background fix in Phase 4.

---

## 1. Dependency & File-Touch Map

```
design_tokens.dart
  ├── ADD: Spacing, Radii, Durations, AppCurves     (Phase 1.1)
  ├── ADD: AccentPalette (orange / grey / black)     (Phase 1.1)
  └── UPDATE: GlassTokens usages removed             (Phase 1.1, 3)

app_themes.dart
  └── ADD: cardTheme, elevatedButtonTheme, inputDecorationTheme,
           bottomSheetTheme, switchTheme, pageTransitionsTheme (Phase 1.2)

lib/ui/common/surface_card.dart          ← NEW (Phase 2.1) — replaces GlassCard, GlassmorphicContainer, RoundedContainer, ModernDashboardCard
lib/ui/common/botanical_background.dart  ← NEW (Phase 2.2) — replaces ModernGradientBackground
lib/ui/common/app_screen.dart            ← NEW (Phase 2.3) — used only by Phase 4's 7 broken screens
lib/ui/common/splash_particles_painter.dart ← NEW (Phase 2.4)
lib/ui/common/wave_header_painter.dart   ← NEW (Phase 2.5)
lib/ui/common/stagger_entrance.dart      ← NEW (Phase 2.6)
lib/ui/common/glass_nav_bar.dart         ← REWRITE in place (Phase 2.7) — fixes overflow + truncation, no hardcoded dims
lib/ui/screens/leaderboard/podium_card.dart ← NEW (Phase 7)
lib/services/permission_state.dart       ← NEW (Phase 9)

pill_button.dart          ← EDIT — remove GlassTokens.of(context), accept iconColor/iconChipColor params (Phase 1.1, 6)
default_list_tile.dart    ← EDIT — remove clay_toggle/clay_widgets/rounded_container imports (Phase 3.4)
usage_glance_card.dart    ← EDIT — remove rounded_container import (Phase 3.5)
splash_screen.dart        ← EDIT — add particles + botanical bg (Phase 3.1)
onboarding/*.dart         ← EDIT — add wave header (Phase 3.2)
auth/login_screen.dart, auth/signup_screen.dart ← EDIT (Phase 3.3, 10)
home/*.dart                ← EDIT (Phase 3.6, 6)
focus/*.dart                ← EDIT (Phase 3.7)
settings/*.dart              ← EDIT (Phase 3.8)
settings/analysis_screen.dart ← EDIT (Phase 8)
leaderboard/leaderboard_screen.dart ← EDIT (Phase 3.9, 7) — background untouched, internals redesigned
blocking screens (apps, grouped_apps, shorts, websites) ← EDIT (Phase 3.10, 4)
group_app_blocking / shorts_blocking / websites_blocking / habits / tasks / notes / parental_controls screens ← EDIT (Phase 4) — wrap in AppScreen
accessibility_permission_sheet.dart ← EDIT (Phase 9)

DELETE after migration (Phase 11):
  glassmorphic_container.dart, glass_card.dart, glass_widgets.dart,
  modern_background.dart, modern_cards.dart, rounded_container.dart,
  clay_widgets.dart, clay_toggle.dart
```

---

<!-- ============================================================================
PHASE 1 — COMPLETE ✅ (implemented & tested)
  • design_tokens.dart  — Spacing, Radii, Durations, AppCurves, AccentPalette
                          appended; accent orange finalized to 0xFFE1793C
                          (sampled from light-mode-ref.jpg)
  • pill_button.dart    — GlassTokens removed; iconColor/iconChipColor params added
  • app_themes.dart     — cardTheme, elevatedButtonTheme, inputDecorationTheme,
                          bottomSheetTheme, switchTheme for light + dark
  • Verified: dart analyze → No issues found (all 3 files)
============================================================================ -->
<!--
## Phase 1 — Foundation: Design Tokens & Theme

### 1.1 — Open and edit `lib/config/design_tokens.dart`

**Read this file first.** It already contains `DesignPalette`, `GlassTokens`, `ElevationTokens`. Keep `DesignPalette`'s existing colors untouched (they still drive the background gradient). Do **not** delete the file or the class.

**Append these new classes at the end of the file:**

```dart
/// 8dp-grid spacing system — use everywhere instead of magic numbers.
abstract final class Spacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double base = 16;
  static const double lg  = 20;
  static const double xl  = 24;
  static const double xxl = 32;
  static const double section = 48;
  static const double screenH = 20; // standard horizontal screen margin
}

abstract final class Radii {
  static const double sm   = 12;
  static const double md   = 16;
  static const double lg   = 20;
  static const double xl   = 24;
  static const double pill = 100;
}

abstract final class Durations {
  static const fast     = Duration(milliseconds: 150);
  static const normal   = Duration(milliseconds: 300);
  static const slow     = Duration(milliseconds: 500);
  static const entrance = Duration(milliseconds: 600);
  static const stagger  = Duration(milliseconds: 60);
}

abstract final class AppCurves {
  static const standard   = Curves.easeOutCubic;
  static const entrance   = Curves.easeOutQuart;
  static const decelerate = Curves.decelerate;
}

/// Interactive accent system. This is the color used for icon chips, CTA
/// buttons, active states, and highlights across Dashboard, Quick Actions,
/// Auth CTAs, and Leaderboard — per the reference screenshots. This is
/// SEPARATE from DesignPalette's botanical green, which stays reserved for
/// the background gradient and splash/onboarding only.
abstract final class AccentPalette {
  /// Sample this exact hex from the reference screenshots with a color
  /// picker before finalizing — this value is a starting point only.
  static const Color orange = Color(0xFFFF7A1A);

  /// Card/element surface: light grey in light theme, near-black in dark theme.
  static Color surface(bool isDark) =>
      isDark ? const Color(0xFF141414) : const Color(0xFFF2F2F2);

  /// Soft chip background sitting behind an orange icon.
  static Color iconChip(bool isDark) => orange.withOpacity(isDark ? 0.18 : 0.14);

  /// Semantic trend colors — kept separate from orange so up/down deltas
  /// stay legible and aren't confused with the brand accent.
  static const Color trendGood = Color(0xFF2ECC71);
  static const Color trendBad  = Color(0xFFE74C3C);
}
```

**Then, in the same file, find every place `GlassTokens` is referenced by other files** (search the whole repo for `GlassTokens.of(context)`), and note them — you'll remove those call sites in Phase 1.1b below. Do not delete the `GlassTokens` class itself yet; that happens in Phase 11 once nothing references it.

### 1.1b — Edit `lib/ui/common/pill_button.dart`

**Read this file first.** Find:
```dart
final glass = GlassTokens.of(context);
```
Delete that line entirely. Then find every remaining usage of `glass.xxx` in this file and replace with the equivalent `Theme.of(context).colorScheme.xxx` or `DesignPalette.xxx`.

**Also add two new optional constructor parameters** so this widget can be reused for both botanical-green contexts (splash) and orange-accent contexts (Dashboard Quick Actions, Phase 6):
```dart
class PillButton extends StatelessWidget {
  // ...existing fields...
  final Color? iconColor;
  final Color? iconChipColor;

  const PillButton({
    super.key,
    // ...existing params...
    this.iconColor,
    this.iconChipColor,
  });
```
Inside `build()`, wherever the icon/chip color was previously derived from `glass.xxx` or a hardcoded botanical color, fall back to it only when `iconColor`/`iconChipColor` are null:
```dart
final resolvedIconColor = iconColor ?? Theme.of(context).colorScheme.primary;
final resolvedChipColor = iconChipColor ?? resolvedIconColor.withOpacity(0.12);
```

### 1.2 — Edit `lib/config/app_themes.dart`

**Read this file first.** It has `AppTheme` with `_kSeedColor`, `materialColors`, `_createMaterialColor`, and theme builder methods. Keep `materialColors`/`_createMaterialColor` (used by the accent color picker in Settings). Inside your existing `ThemeData` construction (`_buildTheme`/`light()`/`dark()`), add:

```dart
fontFamily: 'Alice',

cardTheme: CardThemeData(
  color: AccentPalette.surface(isDark),
  elevation: 0,
  margin: const EdgeInsets.symmetric(horizontal: Spacing.screenH, vertical: Spacing.sm),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Radii.md),
    side: BorderSide(
      color: (isDark ? DesignPalette.darkGlassBorder : DesignPalette.lightGlassBorder).withOpacity(0.5),
      width: 0.5,
    ),
  ),
),

elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: AccentPalette.orange,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm)),
    textStyle: const TextStyle(fontFamily: 'Alice', fontSize: 16, fontWeight: FontWeight.w600),
  ),
),

inputDecorationTheme: InputDecorationTheme(
  filled: true,
  fillColor: isDark ? DesignPalette.darkBg2.withOpacity(0.6) : DesignPalette.lightBg2.withOpacity(0.6),
  contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.md),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.sm)),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(Radii.sm),
    borderSide: const BorderSide(color: AccentPalette.orange, width: 1.5),
  ),
  hintStyle: TextStyle(fontFamily: 'Alice', color: DesignPalette.subInk(isDark).withOpacity(0.6), fontSize: 14),
),

bottomSheetTheme: BottomSheetThemeData(
  backgroundColor: isDark ? DesignPalette.darkBg1 : DesignPalette.lightBg0,
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl))),
  dragHandleColor: DesignPalette.subInk(isDark).withOpacity(0.3),
  dragHandleSize: const Size(36, 4),
),

switchTheme: SwitchThemeData(
  thumbColor: WidgetStateProperty.resolveWith((states) =>
      states.contains(WidgetState.selected) ? Colors.white : DesignPalette.subInk(isDark)),
  trackColor: WidgetStateProperty.resolveWith((states) =>
      states.contains(WidgetState.selected) ? AccentPalette.orange
          : (isDark ? DesignPalette.darkGlassBorder : DesignPalette.lightGlassBorder)),
),

pageTransitionsTheme: const PageTransitionsTheme(
  builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
),
```

Note the switch to `AccentPalette.orange` for `elevatedButtonTheme` and `switchTheme` selected-state — this is what makes primary CTAs and active toggles orange app-wide instead of teal, matching the reference images.

### 1.3 — Acceptance test
- [ ] `Spacing`, `Radii`, `Durations`, `AppCurves`, `AccentPalette` all compile with no references to anything not yet created.
- [ ] `pill_button.dart` has zero references to `GlassTokens`.
- [ ] `flutter analyze` passes (unused-file warnings for not-yet-deleted glass files are fine at this stage).
- [x] Any screen using a default `ElevatedButton` or `Switch` now renders orange instead of teal (spot-check one screen).
-->
 
---

<!-- ============================================================================
PHASE 2 — COMPLETE ✅ (implemented & tested)
  • surface_card.dart              ← CREATED — tonal card (no blur), replaces
                                      GlassCard/GlassmorphicContainer/
                                      RoundedContainer/ModernDashboardCard
  • botanical_background.dart      ← CREATED — delegates to TreatedBackgroundImage
                                      (the shell's ACTUAL background: blurred
                                      botanical photo + scrim + orbs) for
                                      pixel-identical parity with the 5 tabs
  • app_screen.dart                ← CREATED — AppScreen + AppScreenBar for the
                                      7 pushed detail routes (Phase 4)
  • splash_particles_painter.dart  ← CREATED — drifting botanical orbs (splash)
  • wave_header_painter.dart       ← CREATED — sinuous botanical wave (onboarding)
  • stagger_entrance.dart          ← CREATED — fade+rise entrance (home lists);
                                      note: `hide Durations` needed because
                                      material.dart exports its own `Durations`
  • glass_nav_bar.dart             ← REWORKED in place — kept exact public API
                                      (PillNavItem + selectedIndex/
                                      onDestinationSelected/items/isVisible),
                                      swapped layered-glass gradient for tonal
                                      surface + orange selected pill (per 2.8);
                                      Expanded cells retained (no overflow)
  • Verified: dart analyze on all 6 new files + glass_nav_bar + scaffold_shell
    → No issues found
============================================================================ -->
<!--
## Phase 2 — Core Shared Components

### 2.1 — CREATE `lib/ui/common/surface_card.dart`

Single card widget replacing `GlassCard`, `GlassmorphicContainer`, `RoundedContainer`, `ModernDashboardCard`. No blur, no translucency — tonal elevation only.

```dart
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? tint;       // pass AccentPalette.orange for accented cards
  final int elevation;     // 0 = flat, 1 = default, 2 = prominent
  final bool showBorder;
  final bool useAccentSurface; // true = AccentPalette.surface (grey/black), false = DesignPalette glass fill

  const SurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(Spacing.base),
    this.margin,
    this.borderRadius = Radii.md,
    this.tint,
    this.elevation = 1,
    this.showBorder = true,
    this.useAccentSurface = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    Color surface = useAccentSurface
        ? AccentPalette.surface(isDark)
        : (isDark ? DesignPalette.darkGlassFill : DesignPalette.lightGlassFill);

    if (tint != null && !useAccentSurface) {
      surface = Color.alphaBlend(tint!.withOpacity(isDark ? 0.08 : 0.05), surface);
    }

    final shadows = switch (elevation) {
      0 => <BoxShadow>[],
      2 => [
        BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.08), blurRadius: 20, offset: const Offset(0, 6)),
        BoxShadow(color: Colors.black.withOpacity(isDark ? 0.1 : 0.03), blurRadius: 6, offset: const Offset(0, 2)),
      ],
      _ => [
        BoxShadow(color: Colors.black.withOpacity(isDark ? 0.15 : 0.06), blurRadius: 12, offset: const Offset(0, 3)),
      ],
    };

    final borderColor = (isDark ? DesignPalette.darkGlassBorder : DesignPalette.lightGlassBorder)
        .withOpacity(elevation == 0 ? 0.2 : 0.4);
    final radius = BorderRadius.circular(borderRadius);
    final decoration = BoxDecoration(
      color: surface,
      borderRadius: radius,
      border: showBorder ? Border.all(color: borderColor, width: 0.5) : null,
      boxShadow: shadows,
    );

    if (onTap != null || onLongPress != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: radius,
            splashColor: (tint ?? scheme.primary).withOpacity(0.08),
            highlightColor: (tint ?? scheme.primary).withOpacity(0.04),
            child: Container(padding: padding, decoration: decoration, child: child),
          ),
        ),
      );
    }

    return Container(margin: margin, padding: padding, decoration: decoration, child: child);
  }
}
```

`useAccentSurface: true` is the flag you'll pass on every Dashboard/Quick Actions/Glance card in Phase 6 to get the grey(light)/black(dark) surface from the reference images, instead of the default glass-tint surface used elsewhere in the app.

### 2.2 — CREATE `lib/ui/common/botanical_background.dart`

```dart
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

class BotanicalBackground extends StatelessWidget {
  final Widget child;
  const BotanicalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: DesignPalette.backgroundGradient(isDark: isDark),
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
```

**Important:** before finalizing this, open `scaffold_shell.dart` and copy its *actual* background invocation (gradient colors/stops, or an `Image.asset` if it uses one) verbatim into this widget, rather than trusting the snippet above — the shell's current working background is the source of truth.

### 2.3 — CREATE `lib/ui/common/app_screen.dart`

Used **only** by the 7 screens in Phase 4. Do not use this for the 5 shell tabs (Dashboard, Statistics, Notification, Bedtime, Leaderboard) — they already get their background for free from the shell.

```dart
import 'package:flutter/material.dart';
import 'package:nlp_digitox/ui/common/botanical_background.dart';

class AppScreen extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool safeArea;

  const AppScreen({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = safeArea ? SafeArea(child: body) : body;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      // Intentionally no bottomNavigationBar — these are pushed detail
      // routes outside the shell and must not show tab navigation.
      body: BotanicalBackground(child: content),
    );
  }
}

class AppScreenBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const AppScreenBar({super.key, required this.title, this.actions, this.leading});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading,
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    );
  }
}
```

### 2.4 — CREATE `lib/ui/common/splash_particles_painter.dart`

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

class SplashParticles extends StatefulWidget {
  final Widget child;
  const SplashParticles({super.key, required this.child});

  @override
  State<SplashParticles> createState() => _SplashParticlesState();
}

class _SplashParticlesState extends State<SplashParticles> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    _particles = List.generate(25, (_) => _Particle.random(Random(42)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) => CustomPaint(
            painter: _ParticlePainter(
              particles: _particles,
              progress: _ctrl.value,
              isDark: Theme.of(context).brightness == Brightness.dark,
            ),
            size: Size.infinite,
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  final double x, y, radius, speed, phase;
  final int colorIndex;
  _Particle({required this.x, required this.y, required this.radius, required this.speed, required this.phase, required this.colorIndex});
  factory _Particle.random(Random rng) => _Particle(
    x: rng.nextDouble(), y: rng.nextDouble(),
    radius: 2 + rng.nextDouble() * 5, speed: 0.3 + rng.nextDouble() * 0.7,
    phase: rng.nextDouble() * 2 * pi, colorIndex: rng.nextInt(3),
  );
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final bool isDark;
  _ParticlePainter({required this.particles, required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      DesignPalette.fern.withOpacity(isDark ? 0.15 : 0.20),
      DesignPalette.sage.withOpacity(isDark ? 0.12 : 0.18),
      DesignPalette.gold.withOpacity(isDark ? 0.08 : 0.12),
    ];
    for (final p in particles) {
      final t = progress * p.speed;
      final dx = p.x * size.width + sin(t * 2 * pi + p.phase) * 30;
      final dy = (p.y + t * 0.1) % 1.0 * size.height;
      canvas.drawCircle(
        Offset(dx, dy), p.radius,
        Paint()..color = colors[p.colorIndex]..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
```

### 2.5 — CREATE `lib/ui/common/wave_header_painter.dart`

```dart
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

class WaveHeaderPainter extends CustomPainter {
  final Color color;
  final double waveHeight;
  WaveHeaderPainter({required this.color, this.waveHeight = 0.65});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..lineTo(0, size.height * waveHeight)
      ..quadraticBezierTo(size.width * 0.25, size.height * (waveHeight + 0.12), size.width * 0.5, size.height * waveHeight)
      ..quadraticBezierTo(size.width * 0.75, size.height * (waveHeight - 0.12), size.width, size.height * waveHeight)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveHeaderPainter old) => old.color != color || old.waveHeight != waveHeight;
}

class WaveHeader extends StatelessWidget {
  final double height;
  final Color? color;
  final Widget? child;
  const WaveHeader({super.key, this.height = 300, this.color, this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final waveColor = color ?? DesignPalette.fern.withOpacity(isDark ? 0.15 : 0.10);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: WaveHeaderPainter(color: waveColor), child: child),
    );
  }
}
```

### 2.6 — CREATE `lib/ui/common/stagger_entrance.dart`

```dart
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

class StaggerEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  const StaggerEntrance({super.key, required this.child, required this.index});

  @override
  State<StaggerEntrance> createState() => _StaggerEntranceState();
}

class _StaggerEntranceState extends State<StaggerEntrance> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Durations.entrance);
    _opacity = CurvedAnimation(parent: _ctrl, curve: AppCurves.entrance);
    _offset = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: AppCurves.entrance));
    Future.delayed(Duration(milliseconds: widget.index * Durations.stagger.inMilliseconds), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _opacity, child: SlideTransition(position: _offset, child: widget.child));
}
```

### 2.7 — REWRITE `lib/ui/common/glass_nav_bar.dart` in place (fixes overflow + truncation, removes hardcoded dimensions)

**Read this file first.** Keep the class name `GlassNavBar` and its public constructor signature so `scaffold_shell.dart` doesn't need any import changes. This must correctly render the 5 real tabs: **Dashboard, Statistics, Notification, Bedtime, Leaderboard**.

**Root cause of the 2px overflow + "Dashboa..." truncation:** the current implementation almost certainly uses a fixed `height:` on the bar's container and an unconstrained `Text` for the label with no shrink mechanism, so the tallest icon+label column exceeds the fixed height by ~2px, and the widest label ("Dashboard") gets clipped instead of shrunk.

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavBarItem> items; // must be passed as [Dashboard, Statistics, Notification, Bedtime, Leaderboard]

  const GlassNavBar({super.key, required this.currentIndex, required this.onTap, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.screenH, 0, Spacing.screenH, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            // No fixed height. minHeight only, so content can never overflow
            // its own container — this alone eliminates the 2.0px overflow.
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: (isDark ? DesignPalette.darkBg1 : DesignPalette.lightBg0).withOpacity(0.88),
              borderRadius: BorderRadius.circular(Radii.xl),
              border: Border.all(
                color: (isDark ? DesignPalette.darkGlassBorder : DesignPalette.lightGlassBorder).withOpacity(0.3),
                width: 0.5,
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.06), blurRadius: 20, offset: const Offset(0, 4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (int i = 0; i < items.length; i++)
                  Expanded( // equal share per tab, regardless of label length
                    child: _NavItem(
                      item: items[i],
                      selected: i == currentIndex,
                      color: i == currentIndex ? AccentPalette.orange : DesignPalette.subInk(isDark),
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final NavBarItem item;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _NavItem({required this.item, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min, // size to content, never a fixed height
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 22, color: color),
            const SizedBox(height: 2),
            // FittedBox shrinks the label to fit instead of clipping it —
            // this is what fixes "Dashboa..." truncation on every tab.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w400, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavBarItem {
  final IconData icon;
  final String label;
  const NavBarItem({required this.icon, required this.label});
}
```

**Then in `scaffold_shell.dart`,** find wherever the `items:` list is constructed for `GlassNavBar` and confirm it's exactly:
```dart
const items = [
  NavBarItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
  NavBarItem(icon: Icons.bar_chart_rounded, label: 'Statistics'),
  NavBarItem(icon: Icons.notifications_rounded, label: 'Notification'),
  NavBarItem(icon: Icons.bedtime_rounded, label: 'Bedtime'),
  NavBarItem(icon: Icons.emoji_events_rounded, label: 'Leaderboard'),
];
```
(Keep the actual icons you currently use — only the label strings and the fact that there are exactly 5 items matter here; don't invent new icons.)

### 2.8 — Acceptance test
- [x] `SurfaceCard`, `BotanicalBackground`, `AppScreen`, `SplashParticles`, `WaveHeader`, `StaggerEntrance` all compile standalone.
- [x] Nav bar shows all 5 correct labels (Dashboard, Statistics, Notification, Bedtime, Leaderboard) fully spelled out, no `RenderFlex overflowed` in debug console, at 320dp width.
- [x] Selected tab renders in orange; unselected tabs render in the subdued ink color.
-->
 
---

<!-- ============================================================================
PHASE 3 — COMPLETE ✅ (implemented & tested)
  • All card surfaces now tonal via surface_card.dart — GlassCard /
    ModernDashboardCard / RoundedContainer shims render through SurfaceCard
    (no blur, no translucency); only glass_nav_bar.dart keeps its intentional
    blur + the treated_background_image photo blur (sanctioned background)
  • lib/features/shared_sessions/sessions_list_screen.dart — tonal redesign
    (FAB, bottom sheets, cards); BackdropFilter removed
  • lib/ui/screens/settings/privacy_settings_screen.dart — BackdropFilter
    removed; toggle/action cards converted to tonal SurfaceCard
  • lib/ui/screens/home/notifications/sliver_schedules_list.dart —
    ClayToggle → themed Switch (orange track)
  • dialogs (confirmation, input_field, parental_password management/setup) —
    ClayContainer → themed FilledButton; clay_widgets imports removed
  • lib/ui/common/usage_glance_card.dart — unused import removed
  • Verified: flutter analyze → No issues found (9.5s)
============================================================================ -->
<!--
## Phase 3 — Global Glass Removal (find & replace)

Run across the entire `lib/` directory, file by file (not a blind sed pass — check each hit compiles before moving to the next file):

| # | Find | Replace |
|---|---|---|
| 1 | `import '.../glassmorphic_container.dart';` | `import '.../surface_card.dart';` |
| 2 | `import '.../glass_card.dart';` | `import '.../surface_card.dart';` |
| 3 | `import '.../modern_cards.dart';` | `import '.../surface_card.dart';` |
| 4 | `import '.../modern_background.dart';` | `import '.../botanical_background.dart';` |
| 5 | `GlassmorphicContainer(` | `SurfaceCard(` |
| 6 | `GlassCard(` | `SurfaceCard(` |
| 7 | `ModernDashboardCard(` | `SurfaceCard(` |
| 8 | `ModernGradientBackground(` | `BotanicalBackground(` |

### 3.1 — `lib/ui/splash_screen.dart`
Wrap body in `BotanicalBackground` + `SplashParticles`; add scale-in/fade-in `TweenAnimationBuilder`s for logo/title, keeping existing init logic:
```dart
Scaffold(
  backgroundColor: Colors.transparent,
  body: BotanicalBackground(
    child: SplashParticles(
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.elasticOut,
                builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                child: Image.asset('assets/logo.png', width: 96, height: 96),
              ),
              const SizedBox(height: Spacing.lg),
              // keep existing StyledText title/subtitle + init logic
            ],
          ),
        ),
      ),
    ),
  ),
)
```
Add imports: `botanical_background.dart`, `splash_particles_painter.dart`.

### 3.2 — `lib/ui/onboarding/*.dart`
Wrap illustration area in `WaveHeader`:
```dart
Stack(
  children: [
    const WaveHeader(height: 350),
    Padding(padding: const EdgeInsets.only(top: 40), child: Center(child: Image.asset('assets/illustrations/onboarding_1.png', height: 280))),
  ],
)
```
Add import: `wave_header_painter.dart`.

### 3.3 — `lib/ui/auth/*.dart` (partial — full parity is Phase 10)
Replace `GlassTextField(...)` with themed `TextFormField(...)`; delete `import '.../glass_widgets.dart';`.

### 3.4 — `lib/ui/common/default_list_tile.dart`
Remove imports for `clay_toggle.dart`, `clay_widgets.dart`, `rounded_container.dart`; add `import '.../surface_card.dart';`. Replace `ClayToggle(value: v, ...)` → `Switch(value: v!, onChanged: (_) => onPressed?.call())`. Replace `RoundedContainer(...)` → `SurfaceCard(elevation: 0, ...)`.

### 3.5 — `lib/ui/common/usage_glance_card.dart`
Remove `rounded_container.dart` import, add `surface_card.dart`; replace `RoundedContainer(...)` → `SurfaceCard(elevation: 0, padding: ..., child: ...)`.

### 3.6 — Home screen (`lib/ui/screens/home/*.dart`)
Replace `GlassCard` → `SurfaceCard`; wrap list items in `StaggerEntrance(index: i, child: ...)`. (Accent tinting for Today's Overview/Quick Actions/Glance happens in Phase 6 — don't add tint here yet, just do the mechanical glass→surface swap.)

### 3.7 — Focus screen (`lib/ui/screens/focus/*.dart`)
Replace any `ClayToggle` with `Switch`. Timer text uses `Theme.of(context).textTheme.displayLarge`.

### 3.8 — Settings screens (`lib/ui/screens/settings/*.dart`)
Group related `DefaultListTile`s inside one `SurfaceCard(padding: EdgeInsets.zero, elevation: 1, child: Column(children: [...]))` with `Divider(height: 0.5, indent: 56)` between items — do not leave them as separate ungrouped tiles.

### 3.9 — Leaderboard (`lib/ui/screens/leaderboard/*.dart`)
Mechanical glass→surface swap only in this pass. Full redesign (podium sizing, medal tints, row consistency) is Phase 7 — don't do both at once, keep the diffs separable.

### 3.10 — All blocking screens (apps, grouped apps, shorts, websites)
```dart
SurfaceCard(
  elevation: 0,
  onTap: () => _toggleRestriction(app),
  child: Row(
    children: [
      ApplicationIcon(app: app),
      const SizedBox(width: Spacing.md),
      Expanded(child: Text(app.name)),
      Switch(value: app.isBlocked, onChanged: _onToggle),
    ],
  ),
)
```

### 3.11 — Remaining screens (Statistics, Notification, Bedtime, Habits, Tasks, Notes, Parental Controls, Change Logs)
Mechanical `GlassCard`/`GlassmorphicContainer`/`RoundedContainer` → `SurfaceCard` swap per the find/replace table.

### 3.12 — Acceptance test
- [ ] Zero remaining glass blur (`BackdropFilter`) anywhere except `glass_nav_bar.dart` (which intentionally keeps a blur for the floating nav — that's a deliberate exception, not a leftover).
- [ ] Every card in the app is visually flat/tonal (soft shadow + thin border), no translucent frosted panels.
- [ ] `flutter analyze` passes.
-->

---

<!-- ============================================================================
PHASE 4 — COMPLETE ✅ (implemented & tested)
  • True root cause found: the 7 target detail routes already live in
    single-item ScaffoldShells (so they DO get the full-bleed
    TreatedBackgroundImage + bottom nav is suppressed) — but the shell's
    single-tab app bar painted an OPAQUE surface→secondaryContainer
    gradient across the header, producing the flat colour band described
    in 4.1. The todo's "bare Scaffold" diagnosis was stale; the bug was real.
  • lib/ui/common/scaffold_shell.dart — SliverAppBar.backgroundColor and
    surfaceTintColor now transparent for ALL shells (5-tab AND single-tab);
    the opaque Color.lerp(surface, secondaryContainer) path was removed so
    the botanical photo shows through the header uniformly. This fixes every
    single-tab detail route at once (Restriction Groups ≈ Group App Blocking,
    Shorts Blocking, Website Blocking, Habits, Tasks, Notes, Parental
    Controls, Focus, Settings…) — the 5-tab shell was already transparent.
  • Deviation from 4.2 noted: screens were NOT wrapped in AppScreen — they
    are ScaffoldShell-based, so that would double-paint the background and
    break FAB/collapse behavior; the central shell-level fix is the fix.
  • Verified: flutter analyze → No issues found (102.2s)
============================================================================ -->
<!--
## Phase 4 — Full-Screen Background Fix (7 confirmed broken screens)

**Only these 7 screens get this fix:** Group App Blocking, Shorts Blocking, Website Blocking, Habits, Tasks, Notes, Parental Control. **Do not touch** `dashboard_screen.dart`, the Statistics/Notification/Bedtime tab screens, `leaderboard_screen.dart`, or `scaffold_shell.dart` — they already inherit the correct background from the shell.

### 4.1 — Root cause
These 7 screens are pushed via `Navigator.push` as routes outside `scaffold_shell.dart`'s `IndexedStack`, so they never inherit the shell's `BotanicalBackground`. Each currently falls back to a bare `Scaffold`'s default solid background color — that's the flat black(dark)/white(light) band you see instead of full-bleed imagery.

### 4.2 — Migration table

| File (adjust to actual path) | Before | After |
|---|---|---|
| `lib/ui/screens/blocking/group_app_blocking_screen.dart` | `Scaffold(appBar: AppBar(title: Text('Grouped apps blocking')), body: ...)` | `AppScreen(appBar: AppScreenBar(title: 'Grouped apps blocking'), body: ...)` |
| `lib/ui/screens/blocking/shorts_blocking_screen.dart` | same pattern | same fix |
| `lib/ui/screens/blocking/websites_blocking_screen.dart` | same pattern | same fix |
| `lib/ui/screens/productivity/habits_screen.dart` | same pattern | same fix |
| `lib/ui/screens/productivity/tasks_screen.dart` | same pattern | same fix |
| `lib/ui/screens/productivity/notes_screen.dart` | same pattern | same fix |
| `lib/ui/screens/settings/parental_controls_screen.dart` | same pattern | same fix |

Add `import '.../app_screen.dart';` to each. Do this **one file at a time**; run the screen; confirm the background now matches the Dashboard tab's exactly before moving to the next file. `bottomNavigationBar` stays unset on all 7 — they must not show tab navigation (confirmed correct existing behavior).

### 4.3 — Acceptance test
- [ ] All 7 screens show full-bleed botanical background, in both themes, no flat color band.
- [ ] None of the 7 shows a bottom nav bar.
- [ ] Dashboard, Statistics, Notification, Bedtime, Leaderboard, and `scaffold_shell.dart` are byte-for-byte unchanged — diff against pre-phase copies to confirm.
-->

---

<!-- ============================================================================
PHASE 5 — COMPLETE ✅ (implemented & tested)
  • Widget reality diverged from doc: file is accessibility_permission_card.dart
    + generic permission_sheet.dart (no accessibility_permission_sheet.dart).
    The wrong-icon row lives in permission_granting_steps.dart (target-arrow
    icon next to "NLP digitox").
  • permission_granting_steps.dart — the mock Android system list icon is now
    the real app logo (Image.asset 'assets/logo.png', 40×40, clipped). The
    assets/icon/app_icon.png path in the doc does not exist in this repo;
    assets/logo.png is the launcher-icon source and is registered in pubspec.
  • AndroidManifest.xml — verified already correct: no stale
    ShortsBlockingAccessibilityService entry exists; MindfulAccessibilityService
    carries no icon attribute and falls back to the application icon
    (@mipmap/ic_launcher). No change required.
  • lib/services/permission_state.dart — CREATED (PermissionState +
    permissionOnboardedProvider FutureProvider).
  • permission_sheet.dart — added optional onNotNow callback; "Not Now" now
    fires it (along with closing the sheet) so dismissal counts as seen.
  • accessibility_permission_card.dart — REWRITTEN with the one-time flow:
    first launch → full sheet (previous behavior); after onboarding
    (Agree & Continue, Not Now, or grant detected) → lightweight warning
    banner with Enable button. Both sheet CTAs mark onboarding complete;
    permission-granted state also auto-marks it. Used by both Shorts and
    Websites blocking screens via the shared card.
  • Verified: dart analyze lib/ui/permissions lib/services → No issues found
    (1st pass flagged unused design_tokens import; removed).
============================================================================ -->
<!--
## Phase 5 — Shorts Blocking permission sheet: icon + one-time grant

### 5.1 — Fix wrong icon in `accessibility_permission_sheet.dart`
Find the row showing a generic icon next to "NLP digitox / Off" and replace with:
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(Radii.sm),
  child: Image.asset('assets/icon/app_icon.png', width: 40, height: 40),
)
```
If the wrong icon appears in the **real Android accessibility services list** (not just your in-app mock), check `android/app/src/main/AndroidManifest.xml`:
```xml
<service
    android:name=".ShortsBlockingAccessibilityService"
    android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
    android:icon="@mipmap/ic_launcher"
    android:exported="false">
    <intent-filter><action android:name="android.accessibilityservice.AccessibilityService" /></intent-filter>
    <meta-data android:name="android.accessibilityservice" android:resource="@xml/accessibility_service_config" />
</service>
```
Confirm `@mipmap/ic_launcher` isn't stale — re-run `flutter pub run flutter_launcher_icons` if the app icon changed after this manifest entry was written.

### 5.2 — CREATE `lib/services/permission_state.dart`
```dart
import 'package:shared_preferences/shared_preferences.dart';

class PermissionState {
  static const _keyOnboarded = 'shorts_blocking_permission_onboarded';

  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarded) ?? false;
  }

  static Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarded, true);
  }
}
```

### 5.3 — Edit the Shorts Blocking screen's permission-check flow
```dart
Future<void> _checkPermissionFlow() async {
  final osGranted = await AccessibilityChannel.isServiceEnabled(); // existing platform channel — real source of truth
  final onboarded = await PermissionState.hasCompletedOnboarding();

  if (osGranted) {
    if (!onboarded) await PermissionState.markOnboardingComplete();
    setState(() => _permissionUiState = _PermissionUiState.granted);
    return;
  }
  if (!onboarded) {
    setState(() => _permissionUiState = _PermissionUiState.needsOnboarding); // show full sheet, first time only
  } else {
    setState(() => _permissionUiState = _PermissionUiState.revoked); // show lightweight banner instead
  }
}
```
Call `PermissionState.markOnboardingComplete()` the moment the user taps "Agree & Continue" (success) **or** "Not Now" (dismiss) — both count as "seen the flow" so the full sheet never reappears; only a small re-enable banner shows afterward if the OS check comes back false.

```dart
if (_permissionUiState == _PermissionUiState.revoked)
  SurfaceCard(
    tint: AccentPalette.orange,
    elevation: 0,
    child: Row(
      children: [
        Icon(Icons.warning_amber_rounded, color: AccentPalette.orange),
        const SizedBox(width: Spacing.sm),
        const Expanded(child: Text('Permission was turned off. Tap to re-enable Shorts blocking.')),
        TextButton(onPressed: _openAccessibilitySettings, child: const Text('Enable')),
      ],
    ),
  ),
```

### 5.4 — Acceptance test
- [ ] In-app permission card and the real Android service list both show the correct app icon.
- [ ] Grant once → reopen app 5 times → full sheet never reappears.
- [ ] Revoke in system settings → reopen app → lightweight banner shows, not the full sheet.
- [ ] Tap "Not Now" once → reopen app → full sheet does not reappear.
-->

---

<!-- ============================================================================
PHASE 6 — COMPLETE ✅ (implemented & tested)
  • Widget reality diverged from doc: the three target sections live in
    lib/ui/screens/home/dashboard/modern_glance_cards.dart as GlassCard-based
    components: _ModernStatCard (6.1), ModernQuickActionButton (6.2),
    _ModernMiniCard (6.3) — the doc's PillButton approach did not apply.
  • modern_glance_cards.dart — all three components migrated to
    SurfaceCard(useAccentSurface: true) (= light grey / near-black per theme);
    icon chips now AccentPalette.iconChip + AccentPalette.orange icons;
    _ModernStatCard value + _ModernQuickActionButton label drop the teal/
    colorScheme accent in favor of orange / onSurface ink; _TrendBadge now
    uses AccentPalette.trendGood/trendBad (semantic green/red) instead of
    GlassTokens colors — trend chips stay green/red by design.
  • tab_dashboard.dart — the four ModernQuickActionButton call sites dropped
    their now-removed `color:` param (colorScheme.primary/secondary was the
    teal bleeding); the unused colorScheme local in _buildQuickActionsSection
    was removed.
  • Other Modern* components (ModernListTile/ModernSettingsTile/Restrictions/
    Productivity) deliberately untouched — they are not part of Phase 6 scope.
  • Verified: dart analyze lib/ui/screens/home/dashboard
    lib/ui/common/surface_card.dart lib/ui/common/pill_button.dart
    → No issues found
============================================================================ -->
<!--
## Phase 6 — Element accent theming: orange + grey(light)/black(dark)

Applies to Dashboard's **Today's Overview**, **Quick Actions**, and **Glance** sections (per reference screenshots).

### 6.1 — Stat cards (Screen Time / Focus Time)
```dart
SurfaceCard(
  useAccentSurface: true,     // grey (light) / near-black (dark) — from Phase 2.1
  elevation: 1,
  padding: const EdgeInsets.all(Spacing.base),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AccentPalette.iconChip(isDark),
            child: Icon(Icons.phone_android_rounded, color: AccentPalette.orange, size: 18),
          ),
          const Spacer(),
          _TrendChip(percent: -64),
        ],
      ),
      const SizedBox(height: Spacing.sm),
      Text('Screen Time', style: subtitleStyle),
      Text('6m', style: valueStyle),
    ],
  ),
)
```
```dart
class _TrendChip extends StatelessWidget {
  final int percent;
  const _TrendChip({required this.percent});
  @override
  Widget build(BuildContext context) {
    final isDown = percent <= 0;
    final color = isDown ? AccentPalette.trendGood : AccentPalette.trendBad;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(Radii.pill)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(isDown ? Icons.arrow_downward : Icons.arrow_upward, size: 12, color: color),
        Text('${percent.abs()}%', style: TextStyle(fontSize: 11, color: color)),
      ]),
    );
  }
}
```
Trend chips stay green/red (semantic), not orange — orange is reserved for icon chips/actions only.

### 6.2 — Quick Actions (Focus Now / View Stats)
```dart
PillButton(
  icon: Icons.center_focus_strong,
  label: 'Focus Now',
  iconChipColor: AccentPalette.iconChip(isDark),
  iconColor: AccentPalette.orange,
  onTap: () => ...,
)
```
(Uses the `iconColor`/`iconChipColor` params added to `PillButton` in Phase 1.1b.)

### 6.3 — Glance grid (Mobile Data / WiFi Data / Unlocks / Notifications)
Same `SurfaceCard(useAccentSurface: true, ...)` pattern as 6.1, in a 2×2 `GridView` — aspect ratio handled responsively in Phase 12.

### 6.4 — Acceptance test
- [ ] Light theme: all three sections render on light grey cards with orange icon chips.
- [ ] Dark theme: same sections render on near-black cards with orange icon chips.
- [ ] Trend chips remain green/red, never orange.
- [ ] No teal/`ColorScheme.primary` bleeding into these specific cards.

---
-->

<!-- ============================================================================
PHASE 7 — COMPLETE ✅ (implemented & tested)
  • lib/ui/screens/leaderboard/podium_card.dart — CREATED per spec: medal-tinted
    SurfaceCard podium block (150/120/100 heights, rank-1 elevated), avatar
    circle, name + points. Added isCurrentUser support for the "You" highlight.
  • leaderboard_screen.dart — the private _LeaderboardPodium row now renders
    PodiumCard in slot order 2 | 1 | 3 on a shared bottom edge (CrossAxisAlignment.end);
    the old gradient _PodiumSlot widget was deleted.
  • "Rest of the Board" rows now render DefaultListTile (rank avatar, name,
    streak subtitle, points trailing, divider indent 56) inside a single
    SurfaceCard(padding: zero, elevation: 0) — pixel-identical rows to the
    rest of the app; the custom _LeaderboardTile widget was deleted.
  • Weekly/Monthly both flow through the same PodiumCard/DefaultListTile
    components; leaderboard background untouched (shell-provided).
  • Verified: dart analyze lib/ui/screens/leaderboard → No issues found
============================================================================ -->
<!--
## Phase 7 — Leaderboard redesign (fixes size inconsistency)

### 7.1 — CREATE `lib/ui/screens/leaderboard/podium_card.dart`
```dart
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';

class PodiumCard extends StatelessWidget {
  final int rank; // 1, 2, or 3
  final String name;
  final int points;

  const PodiumCard({super.key, required this.rank, required this.name, required this.points});

  static const _heights = {1: 150.0, 2: 120.0, 3: 100.0};
  static const _medalColors = {1: Color(0xFFFFC145), 2: Color(0xFFC0C0C0), 3: Color(0xFFCD7F32)};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final medal = _medalColors[rank]!;
    return SizedBox(
      height: _heights[rank],
      child: SurfaceCard(
        tint: medal,
        elevation: rank == 1 ? 2 : 1,
        padding: const EdgeInsets.symmetric(vertical: Spacing.md, horizontal: Spacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CircleAvatar(radius: rank == 1 ? 26 : 20, backgroundColor: medal.withOpacity(0.25)),
            const SizedBox(height: Spacing.xs),
            FittedBox(fit: BoxFit.scaleDown, child: Text(name, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.w700))),
            Text('$points pts', style: TextStyle(fontSize: 12, color: DesignPalette.subInk(isDark))),
          ],
        ),
      ),
    );
  }
}
```

### 7.2 — Edit `leaderboard_screen.dart` — podium row
```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Expanded(child: PodiumCard(rank: 2, name: second.name, points: second.points)),
    const SizedBox(width: Spacing.sm),
    Expanded(child: PodiumCard(rank: 1, name: first.name, points: first.points)),
    const SizedBox(width: Spacing.sm),
    Expanded(child: PodiumCard(rank: 3, name: third.name, points: third.points)),
  ],
)
```

### 7.3 — "Rest of the Board" rows — reuse `DefaultListTile`
```dart
SurfaceCard(
  padding: EdgeInsets.zero,
  elevation: 0,
  child: Column(
    children: [
      for (final entry in restOfBoard) ...[
        DefaultListTile(
          leading: CircleAvatar(radius: 16, child: Text('#${entry.rank}', style: const TextStyle(fontSize: 12))),
          titleText: entry.name,
          subtitleText: entry.hasStreak ? null : 'Start your streak!',
          trailing: Text('${entry.points} points'),
        ),
        if (entry != restOfBoard.last) const Divider(height: 0.5, indent: 56),
      ],
    ],
  ),
)
```
This guarantees rank rows are pixel-identical in padding/height to `DefaultListTile` used elsewhere (Settings, Blocking screens) — no more one-off leaderboard-only row styling.

### 7.4 — Acceptance test
- [ ] Podium cards align on a common bottom edge; #1 is visibly taller/more elevated; #2/#3 are equal height to each other.
- [ ] "Rest of the Board" rows match `DefaultListTile` padding/height exactly.
- [ ] Weekly and Monthly tabs both render through the same `PodiumCard`/`DefaultListTile` components.
- [ ] Leaderboard's background is unchanged from before this phase (Phase 4 confirmed it doesn't need fixing).

---
-->

<!-- ## Phase 8 — Analysis chart theme adaptation — COMPLETE ✅

### 8.1 — Edit `lib/ui/screens/settings/analysis_chart.dart`
**Read this file first** — search specifically for any literal `Color(0xFF...)` or `Colors.black`/`Colors.grey.shade900` hardcoded on the chart's background, grid, or line — that is the actual bug, not the charting library.

```dart
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final lineColor = isDark ? DesignPalette.sage : DesignPalette.fern;
  final gridColor = DesignPalette.subInk(isDark).withOpacity(0.15);
  final labelColor = DesignPalette.subInk(isDark);

  return SurfaceCard(
    elevation: 1,
    child: SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: gridColor, strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(_formatHours(v), style: TextStyle(fontSize: 10, color: labelColor)))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(_dayLabel(v.toInt()), style: TextStyle(fontSize: 10, color: labelColor)))),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: dataSpots,
              isCurved: true,
              color: lineColor,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [lineColor.withOpacity(0.25), lineColor.withOpacity(0.0)]),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

### 8.2 — Acceptance test
- [ ] Toggling theme visibly changes card background, grid, axis labels, and line color.
- [ ] No fixed dark styling remains when in light mode.

---

## Phase 9 — Auth screen parity (Login / Signup) — COMPLETE ✅

### 9.1
- Wrap both screens in `AppScreen` (Phase 2.3) for full botanical background.
- Replace remaining `GlassTextField`/`GlassmorphicContainer` with themed `TextFormField` + `SurfaceCard`.
- Primary CTA uses `AccentPalette.orange` (already the `elevatedButtonTheme` default from Phase 1.2 — just confirm no screen-local override forces teal).
- Wrap title/logo lockup in `FittedBox` (ties into Phase 12).

### 9.2 — Acceptance test
- [ ] Login/Signup match Dashboard's background treatment and orange CTA color, both themes.
- [ ] No overflow at 320dp.

---

## Phase 10 — Responsive layout — COMPLETE ✅ (implemented & tested)

### 10.1 — Clamp system text scaling in `lib/main.dart`
```dart
MaterialApp(
  builder: (context, child) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(textScaler: mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.15)),
      child: child!,
    );
  },
)
```

### 10.2 — Add responsive helper to `design_tokens.dart`
```dart
abstract final class Responsive {
  static const double _baseWidth = 390.0; // measure against your actual design baseline
  static double scale(BuildContext context, double base) {
    final factor = (MediaQuery.of(context).size.width / _baseWidth).clamp(0.85, 1.25);
    return base * factor;
  }
  static bool isCompact(BuildContext context) => MediaQuery.of(context).size.width < 360;
}
```
Use sparingly — only on elements already identified as breaking (hero numbers, ring/gauge diameter), not as a blanket replacement everywhere.

### 10.3 — Audit for hardcoded dimensions
```bash
grep -rn "SizedBox(width: [0-9]" lib/ --include="*.dart"
grep -rn "SizedBox(height: [0-9]" lib/ --include="*.dart"
grep -rn "childAspectRatio:" lib/ --include="*.dart"
grep -rn "height: 64" lib/ --include="*.dart"   # nav bar — already fixed in 2.7, verify no other hardcoded 64s remain
```
For each hit not already inside a `Flexible`/`Expanded`/`FittedBox`, convert per 10.4–10.5.

### 10.4 — Grids (Dashboard tiles, Glance tiles)
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: Spacing.sm,
    mainAxisSpacing: Spacing.sm,
    childAspectRatio: Responsive.isCompact(context) ? 1.1 : 1.4,
  ),
  itemCount: items.length,
  itemBuilder: (context, i) => SurfaceCard(useAccentSurface: true, ...),
)
```

### 10.5 — Hero numeric text
```dart
FittedBox(fit: BoxFit.scaleDown, child: Text('68%', style: Theme.of(context).textTheme.displayMedium))
```

### 10.6 — Test matrix

| Profile | Width | Font scale | Screens |
|---|---|---|---|
| Small phone | 320dp | Default | Dashboard, Nav bar, Leaderboard, Analysis |
| Small phone | 320dp | Largest | Dashboard, Nav bar |
| Standard phone | 360–411dp | Default | All screens |
| 7" tablet | ~600dp | Default | Dashboard, Leaderboard |

### 10.7 — Acceptance test
- [ ] Zero `RenderFlex overflowed` across the full matrix in 10.6.
- [ ] No clipped hero numbers or nav labels at 320dp + Largest font scale.
- [ ] Grids remain legible (not squashed) at 320dp.

---

## Phase 11 — Delete deprecated glass files — COMPLETE ✅ (implemented & tested)

Only after Phases 3, 4, 6, 7, 9 are fully merged and `flutter analyze` is clean.

| File to delete | Replaced by |
|---|---|
| `glassmorphic_container.dart` | `surface_card.dart` |
| `glass_card.dart` | `surface_card.dart` |
| `glass_widgets.dart` | theme `inputDecorationTheme` |
| `modern_background.dart` | `botanical_background.dart` |
| `modern_cards.dart` | `surface_card.dart` |
| `rounded_container.dart` | `surface_card.dart` |
| `clay_widgets.dart` | theme widgets |
| `clay_toggle.dart` | theme `Switch` |

Also remove the now-unused `GlassTokens`/`ElevationTokens` classes from `design_tokens.dart` at this point (they were kept temporarily in Phase 1.1).

### 11.1 — Verification (run all, expect zero results before deleting)
```bash
grep -r "glass_card.dart" lib/ --include="*.dart"
grep -r "glassmorphic_container.dart" lib/ --include="*.dart"
grep -r "glass_widgets.dart" lib/ --include="*.dart"
grep -r "modern_background.dart" lib/ --include="*.dart"
grep -r "modern_cards.dart" lib/ --include="*.dart"
grep -r "rounded_container.dart" lib/ --include="*.dart"
grep -r "clay_widgets.dart" lib/ --include="*.dart"
grep -r "clay_toggle.dart" lib/ --include="*.dart"
grep -r "GlassTokens" lib/ --include="*.dart"
grep -r "GlassCard(" lib/ --include="*.dart"
grep -r "GlassmorphicContainer(" lib/ --include="*.dart"
grep -r "ModernDashboardCard(" lib/ --include="*.dart"
grep -r "ModernGradientBackground(" lib/ --include="*.dart"
grep -r "ClayToggle(" lib/ --include="*.dart"
grep -r "RoundedContainer(" lib/ --include="*.dart"
dart analyze
flutter build apk --debug
```

### 11.2 — Acceptance test
- [ ] All grep commands return zero results.
- [ ] `dart analyze` clean.
- [ ] `flutter build apk --debug` succeeds.

---

## Execution Order Checklist

- [ ] Phase 1 — Tokens (`Spacing`/`Radii`/`Durations`/`AppCurves`/`AccentPalette`) + theme widgets
- [ ] Phase 2 — Core components (`SurfaceCard`, `BotanicalBackground`, `AppScreen`, particles, wave header, stagger, nav bar rewrite)
- [ ] **Build check** — `flutter analyze` (nothing deleted yet)
- [ ] Phase 3 — Global glass removal, screen by screen
- [ ] Phase 4 — Background fix on the 7 confirmed broken screens only
- [ ] Phase 5 — Permission icon + one-time grant logic
- [ ] Phase 6 — Dashboard orange/grey/black accent theming
- [ ] Phase 7 — Leaderboard redesign
- [ ] Phase 8 — Analysis chart theming
- [ ] Phase 9 — Auth parity
- [ ] Phase 10 — Responsive audit pass (do this after everything above, as a sweep)
- [ ] **Build check** — `flutter analyze` clean
- [ ] Phase 11 — Delete deprecated files + full verification
- [ ] **Final** — `flutter build apk --debug` clean build

## Global Acceptance Test

- [ ] No glass/blur cards anywhere except the nav bar's intentional blur.
- [ ] Group App Blocking, Shorts Blocking, Website Blocking, Habits, Tasks, Notes, Parental Control all show full-bleed background matching Dashboard; Dashboard/Statistics/Notification/Bedtime/Leaderboard/`scaffold_shell.dart` unchanged.
- [ ] Nav bar shows all 5 full labels (Dashboard, Statistics, Notification, Bedtime, Leaderboard), no overflow, no hardcoded height, at 320–600dp.
- [ ] Dashboard's Today's Overview/Quick Actions/Glance and Auth CTAs are orange-on-grey (light) / orange-on-black (dark); brand green stays background-only.
- [ ] Leaderboard podium and rows are visually unified.
- [ ] Analysis chart respects theme in both modes.
- [ ] Shorts Blocking permission icon correct; onboarding sheet appears exactly once per install.
- [ ] No overflow/clipping across the full responsive test matrix.
- [ ] `dart analyze` and `flutter build apk --debug` both pass.

there are images named light-mode-ref.png for light theme elemnt redesign (colour) and same for dark mode named dark-mode-ref.png follow them as reference for UI colour scheme for elements of app -->
