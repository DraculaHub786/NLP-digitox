import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

/// Theme-aware ambient background: softly-blurred botanical photograph plus
/// a translucent scrim and slow drifting blurred orbs. Used behind splash /
/// auth / home screens — the photo layer replaces the old flat gradient with
/// the rich, blurred plant photography the Leafora reference shows behind
/// every glass card.
class TreatedBackgroundImage extends StatelessWidget {
  final Widget child;
  final bool useDrift;

  const TreatedBackgroundImage({
    super.key,
    required this.child,
    this.useDrift = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Botanical photograph — a dedicated dark variant is used in dark
        // mode so the ambient backdrop matches the deep-forest palette of the
        // dark theme (instead of crushing one bright photo under heavy scrims).
        // Pre-blurred at build time (assets/backgrounds/*_blurred.jpg)
        // instead of blurred live every frame. The image never changes or
        // moves, so paying a per-frame SaveLayer + sigma-16 blur for it was
        // pure waste on the most-visited screens.
        Image.asset(
          isDark
              ? 'assets/backgrounds/bg_dark_blurred.jpg'
              : 'assets/backgrounds/bg_light_blurred.jpg',
          // Keying by brightness guarantees the ImageProvider swaps even
          // when the widget tree is otherwise identical across a theme
          // change (prevents any cached-light-frame edge cases).
          key: ValueKey(isDark),
          fit: BoxFit.cover,
        ),

        // 3. Translucent scrim — keeps text/cards legible over the photo.
        // Dark mode uses the deep-forest palette at high alpha, which
        // turns the bright photo into a moody dark background.
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      // Deliberately translucent: `bg_dark.jpg` is already a
                      // deep-forest image, so a heavy scrim here would paint
                      // it out entirely and the theme-aware swap would be
                      // invisible. ~40-47% lets the botanical texture show.
                      Color(0x66121712),
                      Color(0x70161D15),
                      Color(0x781B241B),
                    ]
                  : const [
                      Color(0x8CF6F3EA),
                      Color(0x8CEEECDD),
                      Color(0x96DFE3CE),
                    ],
            ),
          ),
        ),

        // 4. Soft tinted orbs (theme accent ambience).
        Positioned(
          top: -80,
          right: -60,
          child: _Orb(
            size: 260,
            color: scheme.primary.withValues(alpha: isDark ? 0.10 : 0.12),
          ),
        ),
        Positioned(
          bottom: -90,
          left: -70,
          child: _Orb(
            size: 300,
            color: DesignPalette.sage.withValues(alpha: isDark ? 0.08 : 0.10),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          left: MediaQuery.of(context).size.width * 0.25,
          child: _Orb(
            size: 180,
            color: DesignPalette.gold.withValues(alpha: isDark ? 0.05 : 0.07),
          ),
        ),

        // 5. Foreground content. Always interactive — this widget is used
        // as a full-body wrapper (splash unlock button, auth forms, home
        // tabs), so the child must never be wrapped in IgnorePointer.
        child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;

  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    // Deliberately no BackdropFilter: the RadialGradient already fades to
    // fully transparent at the edge, which reads as "soft" on its own.
    // Three of these stack on every screen using TreatedBackgroundImage, so
    // the blurs were a pure cost with no visual difference.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
