import 'package:flutter/material.dart';

/// Generates the 3-stop "clay" gradient + matching shadow for a given base color.
/// Pass a LIGHTER base color when brightness is dark, so it doesn't vanish against
/// a near-black stage.
class ClayStyle {
  /// Returns the color that reads best on top of a clay surface built from
  /// [baseColor]. Light bases get a dark foreground, dark bases get white.
  /// This is what keeps clay elements legible in both light and dark themes
  /// (Section S8) — dark themes produce *light* `colorScheme.primary` values,
  /// so a hardcoded white foreground would disappear.
  static Color foregroundColor(Color baseColor) {
    final luminance = baseColor.computeLuminance();
    return luminance > 0.45 ? const Color(0xFF14180F) : Colors.white;
  }

  static BoxDecoration decoration({
    required Color baseColor,
    required BuildContext context,
    double borderRadius = 16,
    bool pressed = false,
  }) {
    final hsl = HSLColor.fromColor(baseColor);
    final highlight =
        hsl.withLightness((hsl.lightness + 0.18).clamp(0.0, 1.0)).toColor();
    final shadow =
        hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = pressed
        ? [
            shadow,
            baseColor,
            highlight
          ] // inverted on press — light source appears to flip
        : [highlight, baseColor, shadow];

    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
        stops: const [0.0, 0.45, 1.0],
      ),
      border: Border.all(
        color: Colors.white.withValues(alpha: pressed ? 0.05 : 0.25),
        width: 1,
      ),
      boxShadow: pressed
          ? []
          : [
              BoxShadow(
                color: (isDark ? Colors.black : shadow)
                    .withValues(alpha: isDark ? 0.5 : 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
    );
  }
}

/// Generic clay wrapper for buttons/cards.
class ClayContainer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const ClayContainer({
    super.key,
    required this.child,
    required this.baseColor,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  State<ClayContainer> createState() => _ClayContainerState();
}

class _ClayContainerState extends State<ClayContainer> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:
          widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapUp:
          widget.onTap == null ? null : (_) => setState(() => _pressed = false),
      onTapCancel:
          widget.onTap == null ? null : () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        padding: widget.padding,
        decoration: ClayStyle.decoration(
          baseColor: widget.baseColor,
          context: context,
          borderRadius: widget.borderRadius,
          pressed: _pressed,
        ),
        transform: _pressed
            ? (Matrix4.identity()..scaleByDouble(0.98, 0.98, 1, 1))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}

/// The "icon puck" — a raised, glossy clay button used in many places.
class ClayIconPuck extends StatelessWidget {
  final IconData icon;
  final Color baseColor;
  final double size;

  /// When null, an adaptive foreground ([ClayStyle.foregroundColor]) is chosen
  /// from [baseColor] so pucks stay legible in both light and dark themes.
  final Color? iconColor;

  const ClayIconPuck({
    super.key,
    required this.icon,
    required this.baseColor,
    this.size = 44,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ClayStyle.decoration(
        baseColor: baseColor,
        context: context,
        borderRadius: size / 2,
      ),
      child: Icon(
        icon,
        color: iconColor ?? ClayStyle.foregroundColor(baseColor),
        size: size * 0.5,
      ),
    );
  }
}
