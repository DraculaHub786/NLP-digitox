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
  });

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final glass = GlassTokens.of(context);
    final buttonColor = widget.color ?? scheme.primary;

    final content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 18),
          if (widget.label != null || widget.child != null) const SizedBox(width: 10),
        ],
        if (widget.label != null)
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.outlined
                      ? (widget.color ?? scheme.primary)
                      : scheme.onPrimary,
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
            ? glass.fillTop.withValues(alpha: 0.35)
            : buttonColor,
        borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
        border: widget.outlined
            ? Border.all(color: (widget.color ?? scheme.primary).withValues(alpha: 0.45))
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
