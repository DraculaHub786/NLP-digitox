// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';

/// Modern gradient background with animated orbs
class ModernGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;

  const ModernGradientBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  State<ModernGradientBackground> createState() => _ModernGradientBackgroundState();
}

class _ModernGradientBackgroundState extends State<ModernGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultColors = isDark
        ? [
            const Color(0xFF0F172A), // Dark blue
            const Color(0xFF1E293B), // Lighter dark blue
            const Color(0xFF0F172A),
          ]
        : [
            const Color(0xFFF8FAFC), // Light blue-grey
            const Color(0xFFE0F2FE), // Very light blue
            const Color(0xFFF8FAFC),
          ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.colors ?? defaultColors,
        ),
      ),
      child: Stack(
        children: [
          // Animated floating orbs
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _FloatingOrbsPainter(
                  animation: _controller,
                  isDark: isDark,
                  primaryColor: theme.colorScheme.primary,
                ),
                size: Size.infinite,
              );
            },
          ),
          // Content
          widget.child,
        ],
      ),
    );
  }
}

class _FloatingOrbsPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;
  final Color primaryColor;

  _FloatingOrbsPainter({
    required this.animation,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // First orb (top-right)
    final orb1Offset = Offset(
      size.width * 0.8 + (animation.value * 50),
      size.height * 0.2 - (animation.value * 30),
    );
    paint.shader = RadialGradient(
      colors: [
        primaryColor.withValues(alpha: isDark ? 0.15 : 0.1),
        primaryColor.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: orb1Offset, radius: 200));
    canvas.drawCircle(orb1Offset, 200, paint);

    // Second orb (bottom-left)
    final orb2Offset = Offset(
      size.width * 0.2 - (animation.value * 30),
      size.height * 0.8 + (animation.value * 40),
    );
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF2DD4BF).withValues(alpha: isDark ? 0.12 : 0.08),
        const Color(0xFF2DD4BF).withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: orb2Offset, radius: 180));
    canvas.drawCircle(orb2Offset, 180, paint);

    // Third orb (center)
    final orb3Offset = Offset(
      size.width * 0.5 + (animation.value * 20),
      size.height * 0.5 - (animation.value * 25),
    );
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF60A5FA).withValues(alpha: isDark ? 0.1 : 0.06),
        const Color(0xFF60A5FA).withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: orb3Offset, radius: 150));
    canvas.drawCircle(orb3Offset, 150, paint);
  }

  @override
  bool shouldRepaint(_FloatingOrbsPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}

/// Simple gradient background without animation (better performance)
class SimpleGradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const SimpleGradientBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultColors = isDark
        ? [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B),
          ]
        : [
            const Color(0xFFF8FAFC),
            const Color(0xFFE0F2FE),
          ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors ?? defaultColors,
        ),
      ),
      child: child,
    );
  }
}
