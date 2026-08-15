# 🌿 NLP-Digitox UI Enhancement — Complete Implementation Guide

> **Inspired by** [best-flutter-ui-templates](https://github.com/mitesh77/best-flutter-ui-templates) (curved backgrounds, soft shadows, gradient cards) and [flutter-ui-and-animations](https://github.com/pksunny/flutter-ui-and-animations) (particle systems, spring physics, custom painters)

---

## Locked-In Design Decisions

| Decision | Choice |
|----------|--------|
| **Font** | Alice — everywhere (headings + body) |
| **Color Theme** | Keep existing botanical green palette |
| **Fancy Animations** | Splash & Onboarding only (CustomPainter particles + wave curves) |
| **State Management** | Riverpod — untouched |
| **Glass Effect** | **Remove entirely** — replace with tonal elevation (soft shadows + subtle borders) |

---

## Dependency Map (What Imports What)

Understanding this prevents dead code. Below is the current import chain for every widget you'll modify:

```
scaffold_shell.dart
  ├── glass_nav_bar.dart          ← REPLACE (Phase 2.4)
  ├── styled_text.dart            ← KEEP
  └── tab_controller_provider.dart ← KEEP

default_list_tile.dart
  ├── clay_toggle.dart            ← DELETE (Phase 5)
  ├── clay_widgets.dart           ← DELETE (Phase 5)
  ├── rounded_container.dart      ← DELETE (Phase 5)
  └── styled_text.dart            ← KEEP

pill_button.dart
  └── design_tokens.dart (GlassTokens) ← UPDATE (Phase 1)

usage_glance_card.dart
  └── rounded_container.dart      ← DELETE (Phase 5)

splash_screen.dart
  ├── breathing_widget.dart       ← KEEP (refactor animation)
  ├── pill_button.dart            ← UPDATE (Phase 1)
  ├── treated_background_image.dart ← KEEP
  └── styled_text.dart            ← KEEP

glass_card.dart
  └── design_tokens.dart (GlassTokens, ElevationTokens) ← REPLACED

glassmorphic_container.dart       ← DELETE (Phase 5)
glass_widgets.dart                ← DELETE (Phase 5)
modern_background.dart            ← DELETE (Phase 5)
modern_cards.dart                 ← DELETE (Phase 5)
```

---

## Phase 1: Foundation — Design Tokens & Theme

### 1.1 — Update `lib/config/design_tokens.dart`

> [!IMPORTANT]
> Your existing file already has `DesignPalette`, `GlassTokens`, and `ElevationTokens`. **Do NOT delete the entire file** — keep `DesignPalette` colors unchanged, ADD new spacing/radius/duration constants, and UPDATE `GlassTokens` → `SurfaceTokens`.

**Add these new classes AFTER the existing `DesignPalette` class** (keep all existing palette colors):

```dart
// ===== ADD BELOW existing DesignPalette class =====

/// 8dp-grid spacing system
abstract final class Spacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double base = 16;
  static const double lg  = 20;
  static const double xl  = 24;
  static const double xxl = 32;
  static const double section = 48;

  /// Standard horizontal screen margin
  static const double screenH = 20;
}

/// Consistent corner radii
abstract final class Radii {
  static const double sm   = 12;
  static const double md   = 16;
  static const double lg   = 20;
  static const double xl   = 24;
  static const double pill = 100;
}

/// Animation durations
abstract final class Durations {
  static const fast     = Duration(milliseconds: 150);
  static const normal   = Duration(milliseconds: 300);
  static const slow     = Duration(milliseconds: 500);
  static const entrance = Duration(milliseconds: 600);
  /// Per-item stagger delay in lists
  static const stagger  = Duration(milliseconds: 60);
}

/// Animation curves
abstract final class AppCurves {
  static const standard   = Curves.easeOutCubic;
  static const entrance   = Curves.easeOutQuart;
  static const decelerate = Curves.decelerate;
}
```

**Then FIND every reference to `GlassTokens.of(context)` in `pill_button.dart`** and replace with `Theme.of(context).colorScheme`. The `GlassTokens` class is the main coupling point — once we replace its usages, the old glass system is decoupled.

In `pill_button.dart`, change:
```dart
// ❌ FIND this line:
final glass = GlassTokens.of(context);

// ✅ REPLACE with:
// (remove the line entirely — PillButton should use colorScheme only)
```

And wherever `glass.xxx` is referenced in `pill_button.dart`, replace with the equivalent `scheme.xxx` or `DesignPalette.xxx`.

---

### 1.2 — Update `lib/config/app_themes.dart`

Your existing file has `AppTheme` with `_kSeedColor`, `materialColors`, `_createMaterialColor`, and theme builder methods. **Keep** `materialColors` and `_createMaterialColor` (used by accent color picker). **Add/update** the theme builder to include full widget theming.

**Add these items to your existing `_buildTheme` or `light()`/`dark()` methods:**

```dart
// Inside your ThemeData construction, ADD these theme properties:

// ── Font Family ──
fontFamily: 'Alice',

// ── Card Theme ──
cardTheme: CardThemeData(
  color: isDark ? DesignPalette.darkGlassFill : DesignPalette.lightGlassFill,
  elevation: 0,
  margin: const EdgeInsets.symmetric(horizontal: Spacing.screenH, vertical: Spacing.sm),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Radii.md),
    side: BorderSide(
      color: (isDark ? DesignPalette.darkGlassBorder : DesignPalette.lightGlassBorder)
          .withOpacity(0.5),
      width: 0.5,
    ),
  ),
),

// ── Elevated Buttons ──
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: scheme.primary,
    foregroundColor: scheme.onPrimary,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm)),
    textStyle: const TextStyle(
      fontFamily: 'Alice',
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  ),
),

// ── Input Fields ──
inputDecorationTheme: InputDecorationTheme(
  filled: true,
  fillColor: isDark
      ? DesignPalette.darkBg2.withOpacity(0.6)
      : DesignPalette.lightBg2.withOpacity(0.6),
  contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.md),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(Radii.sm),
    borderSide: BorderSide(
      color: isDark ? DesignPalette.darkGlassBorder : DesignPalette.lightGlassBorder,
      width: 0.5,
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(Radii.sm),
    borderSide: BorderSide(
      color: (isDark ? DesignPalette.darkGlassBorder : DesignPalette.lightGlassBorder)
          .withOpacity(0.5),
      width: 0.5,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(Radii.sm),
    borderSide: BorderSide(color: scheme.primary, width: 1.5),
  ),
  hintStyle: TextStyle(
    fontFamily: 'Alice',
    color: DesignPalette.subInk(isDark).withOpacity(0.6),
    fontSize: 14,
  ),
),

// ── Bottom Sheet ──
bottomSheetTheme: BottomSheetThemeData(
  backgroundColor: isDark ? DesignPalette.darkBg1 : DesignPalette.lightBg0,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
  ),
  dragHandleColor: DesignPalette.subInk(isDark).withOpacity(0.3),
  dragHandleSize: const Size(36, 4),
),

// ── Switch ──
switchTheme: SwitchThemeData(
  thumbColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return scheme.onPrimary;
    return DesignPalette.subInk(isDark);
  }),
  trackColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return scheme.primary;
    return isDark ? DesignPalette.darkGlassBorder : DesignPalette.lightGlassBorder;
  }),
),

// ── Page Transitions (smooth iOS-style) ──
pageTransitionsTheme: const PageTransitionsTheme(
  builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
),
```

---

## Phase 2: New Components (4 New Files + 2 Updates)

### 2.1 — CREATE `lib/ui/common/surface_card.dart`

This is the **single card widget** that replaces `GlassCard`, `GlassmorphicContainer`, `RoundedContainer`, and `ModernDashboardCard`.

```dart
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

/// Unified card surface using tonal elevation (M3 pattern).
/// Inspired by best-flutter-ui-templates soft shadow cards.
///
/// Replaces: GlassCard, GlassmorphicContainer, RoundedContainer, ModernDashboardCard
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? tint;
  final int elevation; // 0 = flat, 1 = default, 2 = prominent
  final bool showBorder;

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
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    // Surface color with optional accent tint
    Color surface = isDark ? DesignPalette.darkGlassFill : DesignPalette.lightGlassFill;
    if (tint != null) {
      surface = Color.alphaBlend(
        tint!.withOpacity(isDark ? 0.08 : 0.05),
        surface,
      );
    }

    // Soft shadows inspired by best-flutter-ui-templates
    final shadows = switch (elevation) {
      0 => <BoxShadow>[],
      2 => [
        BoxShadow(
          color: (isDark ? Colors.black : DesignPalette.lightShadow).withOpacity(isDark ? 0.25 : 0.08),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: (isDark ? Colors.black : DesignPalette.lightShadow).withOpacity(isDark ? 0.1 : 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
      _ => [
        BoxShadow(
          color: (isDark ? Colors.black : DesignPalette.lightShadow).withOpacity(isDark ? 0.15 : 0.06),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
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
            child: Container(
              padding: padding,
              decoration: decoration,
              child: child,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }
}
```

---

### 2.2 — CREATE `lib/ui/common/botanical_background.dart`

Replaces `modern_background.dart`. Uses your existing `DesignPalette` gradient.

```dart
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

/// Full-screen botanical gradient background.
/// Replaces: ModernGradientBackground
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

---

### 2.3 — CREATE `lib/ui/common/splash_particles_painter.dart`

Cool floating particles animation for splash screen. Inspired by pksunny's particle systems.

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

/// Floating botanical particles — leaf-like dots that drift gently.
/// Used ONLY on splash and onboarding screens.
class SplashParticles extends StatefulWidget {
  final Widget child;

  const SplashParticles({super.key, required this.child});

  @override
  State<SplashParticles> createState() => _SplashParticlesState();
}

class _SplashParticlesState extends State<SplashParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    final rng = Random(42);
    _particles = List.generate(25, (_) => _Particle.random(rng));
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
          builder: (context, _) {
            return CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                progress: _ctrl.value,
                isDark: Theme.of(context).brightness == Brightness.dark,
              ),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  final double x, y, radius, speed, phase;
  final int colorIndex;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.colorIndex,
  });

  factory _Particle.random(Random rng) => _Particle(
    x: rng.nextDouble(),
    y: rng.nextDouble(),
    radius: 2 + rng.nextDouble() * 5,
    speed: 0.3 + rng.nextDouble() * 0.7,
    phase: rng.nextDouble() * 2 * pi,
    colorIndex: rng.nextInt(3),
  );
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final bool isDark;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      DesignPalette.fern.withOpacity(isDark ? 0.15 : 0.20),
      DesignPalette.sage.withOpacity(isDark ? 0.12 : 0.18),
      DesignPalette.gold.withOpacity(isDark ? 0.08 : 0.12),
    ];

    for (final p in particles) {
      final t = progress * p.speed;
      // Gentle sine-wave drift
      final dx = p.x * size.width + sin(t * 2 * pi + p.phase) * 30;
      final dy = (p.y + t * 0.1) % 1.0 * size.height;

      final paint = Paint()
        ..color = colors[p.colorIndex]
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius * 0.6);

      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
```

---

### 2.4 — CREATE `lib/ui/common/wave_header_painter.dart`

Curved wave background for onboarding pages. Inspired by best-flutter-ui-templates' CustomPainter curves.

```dart
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

/// Curved wave header — draws a soft botanical curve at the top of a screen.
/// Used for onboarding pages to add visual interest behind illustrations.
class WaveHeaderPainter extends CustomPainter {
  final Color color;
  final double waveHeight;

  WaveHeaderPainter({required this.color, this.waveHeight = 0.65});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    path.lineTo(0, size.height * waveHeight);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * (waveHeight + 0.12),
      size.width * 0.5,
      size.height * waveHeight,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * (waveHeight - 0.12),
      size.width,
      size.height * waveHeight,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveHeaderPainter old) =>
      old.color != color || old.waveHeight != waveHeight;
}

/// Widget wrapper for convenience
class WaveHeader extends StatelessWidget {
  final double height;
  final Color? color;
  final Widget? child;

  const WaveHeader({super.key, this.height = 300, this.color, this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final waveColor = color ??
        (isDark
            ? DesignPalette.fern.withOpacity(0.15)
            : DesignPalette.fern.withOpacity(0.10));

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: WaveHeaderPainter(color: waveColor),
        child: child,
      ),
    );
  }
}
```

---

### 2.5 — CREATE `lib/ui/common/stagger_entrance.dart`

Staggered fade+slide animation for list items. Inspired by pksunny's stagger patterns.

```dart
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

/// Wraps a child with a staggered fade-in + slide-up entrance animation.
/// Use in lists: `StaggerEntrance(index: i, child: MyCard())`
class StaggerEntrance extends StatefulWidget {
  final Widget child;
  final int index;

  const StaggerEntrance({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<StaggerEntrance> createState() => _StaggerEntranceState();
}

class _StaggerEntranceState extends State<StaggerEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Durations.entrance,
    );

    _opacity = CurvedAnimation(parent: _ctrl, curve: AppCurves.entrance);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: AppCurves.entrance));

    // Stagger based on index
    Future.delayed(
      Duration(milliseconds: widget.index * Durations.stagger.inMilliseconds),
      () {
        if (mounted) _ctrl.forward();
      },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}
```

---

### 2.6 — UPDATE `lib/ui/common/glass_nav_bar.dart` (IN-PLACE)

Update the existing file rather than creating a new one (avoids changing `scaffold_shell.dart` imports):

```dart
// REPLACE the entire build method of your existing GlassNavBar with:
// Keep the same class name and constructor so scaffold_shell.dart doesn't need import changes.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

// ... keep your existing class definition, just update the build() to:

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
          height: 64,
          decoration: BoxDecoration(
            color: (isDark ? DesignPalette.darkBg1 : DesignPalette.lightBg0)
                .withOpacity(0.88),
            borderRadius: BorderRadius.circular(Radii.xl),
            border: Border.all(
              color: (isDark ? DesignPalette.darkGlassBorder : DesignPalette.lightGlassBorder)
                  .withOpacity(0.3),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: /* your existing nav items - keep the logic, 
                         update colors to use scheme.primary for active,
                         DesignPalette.subInk(isDark) for inactive */,
          ),
        ),
      ),
    ),
  );
}
```

---

## Phase 3: Screen-by-Screen Migration

### Global Find & Replace Patterns

Run these across your ENTIRE `lib/` directory:

| # | Find | Replace | Scope |
|---|------|---------|-------|
| 1 | `import 'package:nlp_digitox/ui/common/glassmorphic_container.dart';` | `import 'package:nlp_digitox/ui/common/surface_card.dart';` | All files |
| 2 | `import 'package:nlp_digitox/ui/common/glass_card.dart';` | `import 'package:nlp_digitox/ui/common/surface_card.dart';` | All files |
| 3 | `import 'package:nlp_digitox/ui/common/modern_cards.dart';` | `import 'package:nlp_digitox/ui/common/surface_card.dart';` | All files |
| 4 | `import 'package:nlp_digitox/ui/common/modern_background.dart';` | `import 'package:nlp_digitox/ui/common/botanical_background.dart';` | All files |
| 5 | `GlassmorphicContainer(` | `SurfaceCard(` | All files |
| 6 | `GlassCard(` | `SurfaceCard(` | All files |
| 7 | `ModernDashboardCard(` | `SurfaceCard(` | All files |
| 8 | `ModernGradientBackground(` | `BotanicalBackground(` | All files |

---

### 3.1 — `lib/ui/splash_screen.dart`

**Current:** Uses `breathing_widget.dart`, `treated_background_image.dart`, `flutter_animate`  
**Change:** Add `SplashParticles` behind the content, update background to `BotanicalBackground`

```dart
// ❌ FIND (in the build method):
// Whatever the current Scaffold/body structure is

// ✅ REPLACE the Scaffold body with:
Scaffold(
  backgroundColor: Colors.transparent,
  body: BotanicalBackground(
    child: SplashParticles(
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo with scale-in animation (spring physics)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Image.asset('assets/logo.png', width: 96, height: 96),
              ),
              const SizedBox(height: Spacing.lg),
              // Title with fade-in
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Durations.entrance,
                curve: AppCurves.entrance,
                builder: (context, opacity, child) {
                  return Opacity(opacity: opacity, child: child);
                },
                child: StyledText(
                  // Keep your existing StyledText usage
                  'NLP Digitox',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: AppCurves.entrance,
                builder: (context, opacity, child) {
                  return Opacity(opacity: opacity, child: child);
                },
                child: StyledText(
                  'Your Digital Wellbeing Companion',
                  color: DesignPalette.subInk(
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
              // Keep the rest of your initialization logic unchanged
            ],
          ),
        ),
      ),
    ),
  ),
)
```

**Add imports:**
```dart
import 'package:nlp_digitox/ui/common/botanical_background.dart';
import 'package:nlp_digitox/ui/common/splash_particles_painter.dart';
```

---

### 3.2 — `lib/ui/onboarding/` screens

**Change:** Add `WaveHeader` behind illustrations, wrap in `BotanicalBackground`

```dart
// For each onboarding page, wrap the illustration area:
Stack(
  children: [
    const WaveHeader(height: 350),
    Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Image.asset(
          'assets/illustrations/onboarding_1.png',
          height: 280,
        ),
      ),
    ),
  ],
)
```

**Add import:**
```dart
import 'package:nlp_digitox/ui/common/wave_header_painter.dart';
```

---

### 3.3 — `lib/ui/auth/` screens

**Change:** Replace `GlassTextField` → standard `TextFormField` (now auto-themed), replace `GlassmorphicContainer` → `SurfaceCard`

```dart
// ❌ FIND:
GlassTextField(
  hintText: 'Email',
  prefixIcon: Icons.email,
  controller: _emailController,
)

// ✅ REPLACE:
TextFormField(
  controller: _emailController,
  decoration: const InputDecoration(
    hintText: 'Email',
    prefixIcon: Icon(FluentIcons.mail_24_regular),
  ),
)
```

**Remove import:**
```dart
// DELETE this line wherever it appears:
import 'package:nlp_digitox/ui/common/glass_widgets.dart';
```

---

### 3.4 — `lib/ui/common/default_list_tile.dart`

**Critical:** This imports `clay_toggle.dart`, `clay_widgets.dart`, `rounded_container.dart`.

**Changes:**
1. Remove `clay_toggle.dart` import → replace `ClayToggle` usage with `Switch`
2. Remove `clay_widgets.dart` import → replace any clay widget with themed equivalents
3. Replace `RoundedContainer` usage with `SurfaceCard`

```dart
// ❌ FIND these imports:
import 'package:nlp_digitox/ui/common/clay_toggle.dart';
import 'package:nlp_digitox/ui/common/clay_widgets.dart';
import 'package:nlp_digitox/ui/common/rounded_container.dart';

// ✅ REPLACE with:
import 'package:nlp_digitox/ui/common/surface_card.dart';

// Then in the build method:
// ❌ FIND: ClayToggle(value: switchValue, ...)
// ✅ REPLACE: Switch(value: switchValue!, onChanged: (_) => onPressed?.call())

// ❌ FIND: RoundedContainer(...)
// ✅ REPLACE: SurfaceCard(elevation: 0, ...)
```

---

### 3.5 — `lib/ui/common/usage_glance_card.dart`

```dart
// ❌ FIND:
import 'package:nlp_digitox/ui/common/rounded_container.dart';

// ✅ REPLACE:
import 'package:nlp_digitox/ui/common/surface_card.dart';

// In build(), replace RoundedContainer with SurfaceCard:
// ❌: RoundedContainer(...)
// ✅: SurfaceCard(elevation: 0, padding: ..., child: ...)
```

---

### 3.6 — Home Screen (`lib/ui/screens/home/`)

**Changes for each sub-widget:**
- Replace `GlassCard` → `SurfaceCard`
- Wrap list items with `StaggerEntrance(index: i, child: ...)`
- Use `BotanicalBackground` in the scaffold shell (already handled by scaffold_shell)

```dart
// For staggered list items in home tab:
SliverList.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return StaggerEntrance(
      index: index,
      child: SurfaceCard(
        onTap: () => _navigateToDetail(items[index]),
        tint: DesignPalette.fern,
        child: /* your existing row content */,
      ),
    );
  },
)
```

**Add import:**
```dart
import 'package:nlp_digitox/ui/common/stagger_entrance.dart';
```

---

### 3.7 — Focus Screen (`lib/ui/screens/focus/`)

```dart
// Timer display — use Alice displayLarge:
Text(
  formattedTime,
  style: Theme.of(context).textTheme.displayLarge?.copyWith(
    color: DesignPalette.fern,
    fontFeatures: [const FontFeature.tabularFigures()],
  ),
)

// Replace any ClayToggle with Switch (auto-themed)
```

---

### 3.8 — Settings Screen (`lib/ui/screens/settings/`)

**Group related settings into SurfaceCard containers:**

```dart
// ❌ OLD: Individual DefaultListTiles
DefaultListTile(titleText: 'Theme', ...),
DefaultListTile(titleText: 'Language', ...),

// ✅ NEW: Grouped
SurfaceCard(
  padding: EdgeInsets.zero,
  elevation: 1,
  child: Column(
    children: [
      DefaultListTile(titleText: 'Theme', position: ItemPosition.top, ...),
      const Divider(height: 0.5, indent: 56),
      DefaultListTile(titleText: 'Language', position: ItemPosition.bottom, ...),
    ],
  ),
)
```

---

### 3.9 — Leaderboard & Achievements

**Use `DesignPalette` medal colors for tinting:**

```dart
// Gold card
SurfaceCard(tint: DesignPalette.goldWarm, elevation: 2, child: ...)

// Silver card  
SurfaceCard(tint: DesignPalette.silverWarm, elevation: 1, child: ...)

// Bronze card
SurfaceCard(tint: DesignPalette.bronzeWarm, elevation: 1, child: ...)
```

---

### 3.10 — All Blocking Screens (restriction_groups, shorts_blocking, websites_blocking)

```dart
// App/website list items — use flat cards:
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

---

### 3.11 — Dashboard, Productivity, Notifications, Chat Settings, Parental Controls, Change Logs

**Same pattern for all:** Replace any `GlassCard`/`GlassmorphicContainer`/`RoundedContainer` → `SurfaceCard`. The find-and-replace from the table above handles most of this automatically.

---

## Phase 4: Scaffold Shell Background

The `ScaffoldShell` is the root layout widget. Wrap its body with `BotanicalBackground`:

```dart
// In scaffold_shell.dart, in the _ScaffoldShellState build():
// Find where the Scaffold is returned and update:

// ❌ FIND:
return Scaffold(
  // ...existing code

// ✅ WRAP the Scaffold body:
return Scaffold(
  backgroundColor: Colors.transparent,
  // ... wrap the body with BotanicalBackground
  body: BotanicalBackground(
    child: /* existing NestedScrollView / CustomScrollView / body */,
  ),
  // ...
);
```

**Add import to scaffold_shell.dart:**
```dart
import 'package:nlp_digitox/ui/common/botanical_background.dart';
```

---

## Phase 5: Delete Deprecated Files

Only delete AFTER all migrations in Phase 3 are complete.

| # | File to Delete | Replaced By | Migration Needed |
|---|---------------|-------------|-----------------|
| 1 | `lib/ui/common/glassmorphic_container.dart` | `surface_card.dart` | Find-replace done in Phase 3 |
| 2 | `lib/ui/common/glass_card.dart` | `surface_card.dart` | Find-replace done in Phase 3 |
| 3 | `lib/ui/common/glass_widgets.dart` | Theme `inputDecorationTheme` | Auth screens updated in Phase 3.3 |
| 4 | `lib/ui/common/modern_background.dart` | `botanical_background.dart` | Find-replace done in Phase 3 |
| 5 | `lib/ui/common/modern_cards.dart` | `surface_card.dart` | Find-replace done in Phase 3 |
| 6 | `lib/ui/common/rounded_container.dart` | `surface_card.dart` | default_list_tile + usage_glance_card done |
| 7 | `lib/ui/common/clay_widgets.dart` | Theme widgets | default_list_tile updated in Phase 3.4 |
| 8 | `lib/ui/common/clay_toggle.dart` | Theme `Switch` | default_list_tile updated in Phase 3.4 |

---

## Phase 6: Verification

Run these commands from your project root to verify zero dead references:

```bash
# Check for any remaining imports of deleted files
grep -r "glass_card.dart" lib/ --include="*.dart"
grep -r "glassmorphic_container.dart" lib/ --include="*.dart"
grep -r "glass_widgets.dart" lib/ --include="*.dart"
grep -r "modern_background.dart" lib/ --include="*.dart"
grep -r "modern_cards.dart" lib/ --include="*.dart"
grep -r "rounded_container.dart" lib/ --include="*.dart"
grep -r "clay_widgets.dart" lib/ --include="*.dart"
grep -r "clay_toggle.dart" lib/ --include="*.dart"

# Each command should return ZERO results

# Check for any remaining GlassTokens usage
grep -r "GlassTokens" lib/ --include="*.dart"

# Check for any remaining old class names
grep -r "GlassCard(" lib/ --include="*.dart"
grep -r "GlassmorphicContainer(" lib/ --include="*.dart"
grep -r "ModernDashboardCard(" lib/ --include="*.dart"
grep -r "ModernGradientBackground(" lib/ --include="*.dart"
grep -r "ClayToggle(" lib/ --include="*.dart"
grep -r "RoundedContainer(" lib/ --include="*.dart"

# Run Dart analysis
dart analyze

# Build to verify no compile errors
flutter build apk --debug
```

---

## New Files Summary

| File | Purpose | Phase |
|------|---------|-------|
| `lib/ui/common/surface_card.dart` | Unified card widget (replaces 5 widgets) | 2.1 |
| `lib/ui/common/botanical_background.dart` | Gradient background | 2.2 |
| `lib/ui/common/splash_particles_painter.dart` | Cool particle animation (splash/onboarding only) | 2.3 |
| `lib/ui/common/wave_header_painter.dart` | Curved wave header for onboarding | 2.4 |
| `lib/ui/common/stagger_entrance.dart` | Staggered list item animation | 2.5 |

## Updated Files Summary

| File | What Changes | Phase |
|------|-------------|-------|
| `lib/config/design_tokens.dart` | ADD Spacing, Radii, Durations, AppCurves classes | 1.1 |
| `lib/config/app_themes.dart` | ADD cardTheme, elevatedButton, input, switch, etc. | 1.2 |
| `lib/ui/common/glass_nav_bar.dart` | UPDATE styling to botanical palette | 2.6 |
| `lib/ui/common/pill_button.dart` | REMOVE GlassTokens dependency | 1.1 |
| `lib/ui/common/default_list_tile.dart` | REMOVE clay/rounded imports, use SurfaceCard + Switch | 3.4 |
| `lib/ui/common/usage_glance_card.dart` | REMOVE rounded_container, use SurfaceCard | 3.5 |
| `lib/ui/splash_screen.dart` | ADD particles + botanical bg + spring animations | 3.1 |
| `lib/ui/onboarding/*.dart` | ADD wave header + botanical bg | 3.2 |
| `lib/ui/auth/*.dart` | REMOVE glass_widgets, use themed inputs | 3.3 |
| `lib/ui/common/scaffold_shell.dart` | ADD botanical_background import + wrap body | 4 |
| `lib/ui/screens/home/*.dart` | GlassCard → SurfaceCard + StaggerEntrance | 3.6 |
| `lib/ui/screens/focus/*.dart` | ClayToggle → Switch, displayLarge timer | 3.7 |
| `lib/ui/screens/settings/*.dart` | Group tiles in SurfaceCards | 3.8 |
| `lib/ui/screens/leaderboard/*.dart` | Add tinted medal cards | 3.9 |
| `lib/ui/screens/achievements/*.dart` | Add tinted cards | 3.9 |
| All blocking screens | RoundedContainer → SurfaceCard, ClayToggle → Switch | 3.10 |
| All remaining screens | GlassCard/Glassmorphic → SurfaceCard | 3.11 |

## Deleted Files Summary

| File | Phase |
|------|-------|
| `lib/ui/common/glassmorphic_container.dart` | 5 |
| `lib/ui/common/glass_card.dart` | 5 |
| `lib/ui/common/glass_widgets.dart` | 5 |
| `lib/ui/common/modern_background.dart` | 5 |
| `lib/ui/common/modern_cards.dart` | 5 |
| `lib/ui/common/rounded_container.dart` | 5 |
| `lib/ui/common/clay_widgets.dart` | 5 |
| `lib/ui/common/clay_toggle.dart` | 5 |

---

## Execution Order Checklist

> [!IMPORTANT]
> Follow this exact order to avoid broken builds at any step.

- [ ] **Phase 1.1** — Add `Spacing`, `Radii`, `Durations`, `AppCurves` to `design_tokens.dart`
- [ ] **Phase 1.2** — Add widget themes to `app_themes.dart`
- [ ] **Phase 2.1** — Create `surface_card.dart`
- [ ] **Phase 2.2** — Create `botanical_background.dart`
- [ ] **Phase 2.3** — Create `splash_particles_painter.dart`
- [ ] **Phase 2.4** — Create `wave_header_painter.dart`
- [ ] **Phase 2.5** — Create `stagger_entrance.dart`
- [ ] **Phase 2.6** — Update `glass_nav_bar.dart` styling
- [ ] **Build check** — `flutter analyze` (should pass, nothing deleted yet)
- [ ] **Phase 3.1** — Update `splash_screen.dart`
- [ ] **Phase 3.2** — Update onboarding screens
- [ ] **Phase 3.3** — Update auth screens
- [ ] **Phase 3.4** — Update `default_list_tile.dart`
- [ ] **Phase 3.5** — Update `usage_glance_card.dart`
- [ ] **Phase 3.6** — Update home screen
- [ ] **Phase 3.7** — Update focus screen
- [ ] **Phase 3.8** — Update settings screen
- [ ] **Phase 3.9** — Update leaderboard & achievements
- [ ] **Phase 3.10** — Update blocking screens
- [ ] **Phase 3.11** — Update remaining screens (dashboard, productivity, notifications, chat_settings, parental_controls, change_logs)
- [ ] **Phase 4** — Update `scaffold_shell.dart` with BotanicalBackground
- [ ] **Phase 1.1b** — Remove `GlassTokens` from `pill_button.dart`
- [ ] **Build check** — `flutter analyze` (should pass)
- [ ] **Phase 5** — Delete all 8 deprecated files
- [ ] **Phase 6** — Run all grep verification commands
- [ ] **Final** — `flutter build apk --debug` (clean build)
