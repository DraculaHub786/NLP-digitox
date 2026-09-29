import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

/// Modern aurora-mesh layer for the splash screen.
///
/// Renders large, heavily blurred botanical gradient blobs that drift slowly
/// (Lissajous-style motion) behind the logo — the signature "modern splash"
/// effect. Complements [SplashParticles] (fine drifting orbs) rather than
/// replacing it: the blobs supply the soft mesh-gradient wash, the particles
/// supply the fine texture.
class SplashAurora extends StatefulWidget {
  final Widget child;

  const SplashAurora({super.key, required this.child});

  @override
  State<SplashAurora> createState() => _SplashAuroraState();
}

class _SplashAuroraState extends State<SplashAurora>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_AuroraBlob> _blobs;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _blobs = _AuroraBlob.seeded(Random(7));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _AuroraPainter(
              blobs: _blobs,
              progress: _controller.value,
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

class _AuroraBlob {
  final double baseX, baseY, radius, speed, phase, alpha;
  final Color color;

  _AuroraBlob({
    required this.baseX,
    required this.baseY,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.alpha,
    required this.color,
  });

  static List<_AuroraBlob> seeded(Random rng) {
    const palette = [
      DesignPalette.fern,
      DesignPalette.sage,
      DesignPalette.gold,
      DesignPalette.terra,
    ];
    return List.generate(4, (i) {
      return _AuroraBlob(
        baseX: 0.15 + rng.nextDouble() * 0.7,
        baseY: 0.15 + rng.nextDouble() * 0.7,
        radius: 0.34 + rng.nextDouble() * 0.28,
        speed: 0.5 + rng.nextDouble() * 0.5,
        phase: rng.nextDouble() * 2 * pi,
        alpha: 0.10 + rng.nextDouble() * 0.08,
        color: palette[i % palette.length],
      );
    });
  }
}

class _AuroraPainter extends CustomPainter {
  final List<_AuroraBlob> blobs;
  final double progress;
  final bool isDark;

  _AuroraPainter({
    required this.blobs,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = size.shortestSide;
    for (final blob in blobs) {
      final t = progress * blob.speed;
      final dx = blob.baseX * size.width +
          sin(t * 2 * pi + blob.phase) * size.width * 0.07;
      final dy = blob.baseY * size.height +
          cos(t * 2 * pi * 0.7 + blob.phase * 1.6) * size.height * 0.06;
      final radius = blob.radius * shortest;
      final shader = RadialGradient(
        colors: [
          blob.color.withValues(alpha: isDark ? blob.alpha * 0.85 : blob.alpha),
          blob.color.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(dx, dy), radius: radius),
      );
      canvas.drawCircle(Offset(dx, dy), radius, Paint()..shader = shader);
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
