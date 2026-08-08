import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

/// Floating pill-shaped bottom navigation bar with layered glass surface.
class PillNavItem {
  final IconData icon;
  final IconData filledIcon;
  final String label;

  const PillNavItem({
    required this.icon,
    required this.filledIcon,
    required this.label,
  });
}

class GlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<PillNavItem> items;
  final bool isVisible;

  const GlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    final glass = GlassTokens.of(context);

    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, 1.4),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: glass.blurSigma,
              sigmaY: glass.blurSigma,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                gradient: glass.fillGradient,
                borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
                boxShadow: ElevationTokens.of(context).level(3),
              ),
              child: _GradientNavBorder(
                radius: GlassTokens.radiusPill,
                gradient: glass.borderGradient,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var i = 0; i < items.length; i++)
                      _PillNavButton(
                        item: items[i],
                        selected: i == selectedIndex,
                        onTap: () => onDestinationSelected(i),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillNavButton extends StatelessWidget {
  final PillNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _PillNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.filledIcon : item.icon,
              size: 20,
              color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: selected
                  ? Text(
                      item.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    )
                  : const SizedBox(width: 0),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientNavBorder extends StatelessWidget {
  final double radius;
  final Gradient gradient;
  final Widget child;

  const _GradientNavBorder({
    required this.radius,
    required this.gradient,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _GradientNavBorderPainter(
        radius: radius,
        gradient: gradient,
      ),
      child: child,
    );
  }
}

class _GradientNavBorderPainter extends CustomPainter {
  final double radius;
  final Gradient gradient;

  _GradientNavBorderPainter({required this.radius, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect =
        RRect.fromRectAndRadius(rect.deflate(0.6), Radius.circular(radius));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = gradient.createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientNavBorderPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.gradient != gradient;
}
