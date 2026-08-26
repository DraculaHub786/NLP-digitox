import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

/// Sinuous botanical wave painted behind the illustration on onboarding
/// pages. Splash/onboarding only (per locked-in design decisions).
class WaveHeaderPainter extends CustomPainter {
  final Color color;
  final double waveHeight;

  WaveHeaderPainter({required this.color, this.waveHeight = 0.65});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color;
    final path = Path()
      ..lineTo(0, size.height * waveHeight)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * (waveHeight + 0.12),
        size.width * 0.5,
        size.height * waveHeight,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * (waveHeight - 0.12),
        size.width,
        size.height * waveHeight,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveHeaderPainter old) =>
      old.color != color || old.waveHeight != waveHeight;
}

class WaveHeader extends StatelessWidget {
  final double height;
  final Color? color;
  final Widget? child;

  const WaveHeader({super.key, this.height = 300, this.color, this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final waveColor =
        color ?? DesignPalette.fern.withValues(alpha: isDark ? 0.15 : 0.10);
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
