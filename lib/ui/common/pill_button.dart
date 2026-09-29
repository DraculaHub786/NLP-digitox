import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

/// Stadium-shaped primary button with `AnimatedScale` press feedback.
/// No `InkWell` — matches Guide 6 §4 press feel and the reference CTAs.
class PillButton extends StatefulWidget {
  final String? label;
  final Widget? child;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool outlined;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final double? minimumSize;
  final bool fullWidth;
  final Color? iconColor;
  final Color? iconChipColor;

  const PillButton({
    super.key,
    this.label,
    this.child,
    this.icon,
    required this.onPressed,
    this.outlined = false,
    this.color,
    this.padding,
    this.minimumSize,
    this.fullWidth = false,
    this.iconColor,
    this.iconChipColor,
  });

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final buttonColor = widget.color ?? scheme.primary;

    final resolvedIconColor =
        widget.iconColor ?? scheme.primary;
    final resolvedChipColor =
        widget.iconChipColor ?? resolvedIconColor.withValues(alpha: 0.12);
    final labelColor = widget.outlined
        ? (widget.color ?? scheme.primary)
        : (ThemeData.estimateBrightnessForColor(buttonColor) == Brightness.dark
            ? Colors.white
            : Colors.black);

    final content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: resolvedChipColor,
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, size: 18, color: resolvedIconColor),
          ),
          if (widget.label != null || widget.child != null) const SizedBox(width: 10),
        ],
        if (widget.label != null)
          Text(
            widget.label!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        if (widget.child != null) widget.child!,
      ],
    );

    final button = Container(
      padding:
          widget.padding ?? const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      constraints: BoxConstraints(minHeight: widget.minimumSize ?? 52),
      decoration: BoxDecoration(
        color: widget.outlined
            ? buttonColor.withValues(alpha: 0.10)
            : buttonColor,
        borderRadius: BorderRadius.circular(Radii.pill),
        border: widget.outlined
            ? Border.all(color: buttonColor.withValues(alpha: 0.45))
            : null,
        boxShadow: widget.outlined
            ? null
            : [
                BoxShadow(
                  color: buttonColor.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: content,
    );

    return AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: button,
        ),
      ),
    );
  }
}
