import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

/// Floating pill-shaped bottom navigation bar with a tonal surface and
/// orange selected state (no layered-glass gradient).
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tonal surface for the bar — near-black (#141414) in dark theme, light
    // grey in light theme, per AccentPalette.
    final barColor = AccentPalette.surface(isDark).withValues(alpha: 0.92);
    final borderColor = (isDark
            ? DesignPalette.darkGlassBorder
            : DesignPalette.lightGlassBorder)
        .withValues(alpha: 0.3);

    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, 1.4),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Radii.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(Radii.xl),
                border: Border.all(color: borderColor, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / items.length;
                  return SizedBox(
                    height: 44,
                    child: Stack(
                      children: [
                        /// Single sliding highlight pill — one shared
                        /// AnimatedPositioned that glides between tabs
                        /// instead of each tab resizing itself.
                        AnimatedPositioned(
                          left: selectedIndex * itemWidth + 3,
                          width: itemWidth - 6,
                          top: 2,
                          bottom: 2,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AccentPalette.orange,
                              borderRadius: BorderRadius.circular(Radii.pill),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AccentPalette.orange.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// Nav buttons — every cell is Expanded (equal width),
                        /// so the row can never exceed the bar's width
                        /// regardless of label length.
                        Row(
                          children: [
                            for (var i = 0; i < items.length; i++)
                              Expanded(
                                child: _PillNavButton(
                                  item: items[i],
                                  selected: i == selectedIndex,
                                  maxWidth: itemWidth,
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
    );
  }
}

class _PillNavButton extends StatelessWidget {
  final PillNavItem item;
  final bool selected;
  final double maxWidth;
  final VoidCallback onTap;

  const _PillNavButton({
    required this.item,
    required this.selected,
    required this.maxWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedScale(
          scale: selected ? 1.0 : 0.96,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Icon swaps filled/outline with a subtle pop.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: Icon(
                    selected ? item.filledIcon : item.icon,
                    key: ValueKey(selected),
                    size: 20,
                    color: selected
                        ? Colors.white
                        : DesignPalette.subInk(
                            Theme.of(context).brightness == Brightness.dark),
                  ),
                ),

                /// Label expands horizontally via widthFactor inside ClipRect,
                /// so even mid-animation the growing text is clipped to the
                /// cell — no RenderFlex overflow, no ParentDataWidget error.
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
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
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
      ),
    );
  }
}
