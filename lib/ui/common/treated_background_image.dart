import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

/// Theme-aware ambient background: soft botanical gradient plus slow drifting
/// blurred orbs. Used behind splash / auth screens to replace the old
/// animated gradient while keeping a feeling of calm depth.
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: DesignPalette.backgroundGradient(isDark: isDark),
        ),
      ),
      child: Stack(
        children: [
          // Soft tinted orbs
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
          child,
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;

  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const SizedBox.shrink(),
      ),
    );
  }
}
