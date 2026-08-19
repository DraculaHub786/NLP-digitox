import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

/// Floating botanical particles for the splash screen — slow drifting orbs
/// in fern/sage/gold that animate behind the logo. Splash/onboarding only
/// (per locked-in design decisions: fancy animation stays on those screens).
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
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
      DesignPalette.fern.withValues(alpha: isDark ? 0.15 : 0.20),
      DesignPalette.sage.withValues(alpha: isDark ? 0.12 : 0.18),
      DesignPalette.gold.withValues(alpha: isDark ? 0.08 : 0.12),
    ];
    for (final p in particles) {
      final t = progress * p.speed;
      final dx = p.x * size.width + sin(t * 2 * pi + p.phase) * 30;
      final dy = (p.y + t * 0.1) % 1.0 * size.height;
      canvas.drawCircle(
        Offset(dx, dy),
        p.radius,
        Paint()
          ..color = colors[p.colorIndex]
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
