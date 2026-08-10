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
    final scheme = Theme.of(context).colorScheme;

    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, 1.4),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: glass.blurSigma,
              sigmaY: glass.blurSigma,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                gradient: glass.fillGradient,
                borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
                boxShadow: ElevationTokens.of(context).level(3),
              ),
              child: _GradientNavBorder(
                radius: GlassTokens.radiusPill,
                gradient: glass.borderGradient,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / items.length;
                    return SizedBox(
                      height: 44,
                      child: Stack(
                        children: [
                          /// Single sliding highlight pill — one shared
                          /// AnimatedPositioned that glides between tabs
                          /// instead of each tab resizing itself (the old
                          /// per-item AnimatedContainer/AnimatedSize caused
                          /// overflow flashes on full-tree rebuilds).
                          AnimatedPositioned(
                            left: selectedIndex * itemWidth + 3,
                            width: itemWidth - 6,
                            top: 2,
                            bottom: 2,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            child: Container(
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius:
                                    BorderRadius.circular(GlassTokens.radiusPill),
                                boxShadow: [
                                  BoxShadow(
                                    color: scheme.primary.withValues(alpha: 0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          /// Nav buttons — every cell is Expanded (equal
                          /// width), so the row can never exceed the bar's
                          /// width regardless of label length.
                          Row(
                            children: [
                              for (var i = 0; i < items.length; i++)
                                Expanded(
                                  child: _PillNavButton(
                                    item: items[i],
                                    selected: i == selectedIndex,
                                    onTap: () => onDestinationSelected(i),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
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
      child: Center(
        child: AnimatedScale(
          scale: selected ? 1.0 : 0.96,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Icon swaps filled/outline with a subtle pop.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutBack,
                transitionBuilder: (child, animation) =>
                    FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: Icon(
                  selected ? item.filledIcon : item.icon,
                  key: ValueKey(selected),
                  size: 20,
                  color: selected
                      ? scheme.onPrimary
                      : scheme.onSurfaceVariant,
                ),
              ),

              /// Label expands horizontally via widthFactor inside ClipRect,
              /// so even mid-animation the growing text is clipped to the
              /// cell — no RenderFlex overflow, no ParentDataWidget error
              /// (unlike the old AnimatedSize > Flexible nesting).
              ClipRect(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment:
                      selected ? Alignment.center : Alignment.centerLeft,
                  widthFactor: selected ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
