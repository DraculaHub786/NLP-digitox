import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

/// Single card widget replacing `GlassCard`, `GlassmorphicContainer`,
/// `RoundedContainer`, `ModernDashboardCard`. No blur, no translucency —
/// tonal elevation only (soft shadow + thin border).
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? tint; // pass AccentPalette.orange for accented cards
  final int elevation; // 0 = flat, 1 = default, 2 = prominent
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
      surface = Color.alphaBlend(
          tint!.withValues(alpha: isDark ? 0.08 : 0.05), surface);
    }

    final shadows = switch (elevation) {
      0 => <BoxShadow>[],
      2 => [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      _ => [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
    };

    final borderColor =
        (isDark ? DesignPalette.darkGlassBorder : DesignPalette.lightGlassBorder)
            .withValues(alpha: elevation == 0 ? 0.2 : 0.4);
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
            splashColor:
                (tint ?? scheme.primary).withValues(alpha: 0.08),
            highlightColor:
                (tint ?? scheme.primary).withValues(alpha: 0.04),
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
