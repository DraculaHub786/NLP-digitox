import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/ui/common/clay_widgets.dart';

/// Clay-styled recessed toggle switch with a raised clay thumb,
/// matching the app icon's 3D rendering style (Section S4).
class ClayToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const ClayToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
          color: value
              ? activeColor.withValues(alpha: isDark ? 0.35 : 0.25)
              : isDark
                  ? Colors.white.withValues(alpha: 0.14)
                  : Colors.black.withValues(alpha: 0.08),
          boxShadow: [
            // inset-look: a dark shadow living just inside the top edge
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: ClayStyle.decoration(
              baseColor: value
                  ? activeColor
                  : (isDark
                      ? Colors.blueGrey.shade300
                      : Colors.grey.shade400),
              context: context,
              borderRadius: 12,
            ),
          ),
        ),
      ),
    );
  }
}
