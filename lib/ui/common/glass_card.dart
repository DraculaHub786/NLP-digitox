import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

/// Layered glass card: gradient fill + gradient border + soft tinted shadow
/// (Guide 6 layered version). Matches the reference card surface 1:1.
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? tint;
  final int elevationLevel;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius = GlassTokens.radiusCard,
    this.tint,
    this.elevationLevel = 1,
  });

  @override
  Widget build(BuildContext context) {
    final glass = GlassTokens.of(context);
    final elevation = ElevationTokens.of(context).level(elevationLevel);
    final radius = BorderRadius.circular(borderRadius);

    final fill = tint != null
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(tint!.withValues(alpha: 0.16), glass.fillTop),
              Color.alphaBlend(tint!.withValues(alpha: 0.06), glass.fillBottom),
            ],
          )
        : glass.fillGradient;

    return AnimatedScale(
      scale: onTap != null ? 1 : 1,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: margin,
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              ...elevation,
              BoxShadow(
                color: glass.shadowColor.withValues(alpha: 0.08),
                blurRadius: glass.blurSigma,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: glass.blurSigma,
                sigmaY: glass.blurSigma,
              ),
              child: Container(
                padding: padding ?? const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: fill,
                  borderRadius: radius,
                ),
                child: _GradientBorder(
                  radius: radius,
                  gradient: glass.borderGradient,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a 1.2px gradient border on top of the glass fill.
class _GradientBorder extends StatelessWidget {
  final BorderRadius radius;
  final Gradient gradient;
  final Widget child;

  const _GradientBorder({
    required this.radius,
    required this.gradient,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _GradientBorderPainter(
        radius: radius,
        gradient: gradient,
      ),
      child: child,
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final BorderRadius radius;
  final Gradient gradient;

  _GradientBorderPainter({required this.radius, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndCorners(
      rect.deflate(0.6),
      topLeft: radius.topLeft,
      topRight: radius.topRight,
      bottomLeft: radius.bottomLeft,
      bottomRight: radius.bottomRight,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = gradient.createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.gradient != gradient;
}
