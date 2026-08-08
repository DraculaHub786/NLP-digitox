import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

/// A decorated container with the provided properties.
///
/// Defaults to the botanical glass surface (radius = [GlassTokens.radiusCard],
/// soft tinted fill + hairline border) so list tiles, time cards and other
/// shared rows inherit the reference look without each caller passing styles.
///
/// If [onPressed] is not null it builds an inkwell widget, otherwise a normal
/// container with the decorations.
class RoundedContainer extends StatelessWidget {
  const RoundedContainer({
    super.key,
    this.height,
    this.width,
    this.color,
    this.borderRadius,
    this.child,
    this.onPressed,
    this.circularRadius = GlassTokens.radiusCard,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.center,
    this.borderSide,
    this.boxShadow,
  });

  final double? height;
  final double? width;
  final Color? color;
  final double circularRadius;
  final BorderRadius? borderRadius;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Widget? child;
  final VoidCallback? onPressed;
  final AlignmentGeometry alignment;
  final BorderSide? borderSide;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Botanical glass surface: soft tinted fill + hairline outline instead of
    // the old flat `surfaceContainer`. Callers can still pass an explicit
    // `color` to override (e.g. primaryContainer badges).
    final bgColor =
        color ?? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);
    final radius = borderRadius ?? BorderRadius.circular(circularRadius);
    final outline =
        borderSide ?? BorderSide(color: colorScheme.outline.withValues(alpha: 0.18));
    final boxBorder = outline == BorderSide.none ? null : Border.fromBorderSide(outline);

    return onPressed == null
        /// Static container
        ? Container(
            width: width,
            height: height,
            margin: margin,
            padding: padding,
            alignment: alignment,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: radius,
              border: boxBorder,
              boxShadow: boxShadow,
            ),
            child: child,
          )

        /// Interactive container
        : Container(
            height: height,
            width: width,
            margin: margin,
            child: Material(
              color: bgColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: outline,
              ),
              child: InkWell(
                onTap: onPressed,
                splashFactory: InkSparkle.splashFactory,
                splashColor: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: radius,
                child: Padding(
                  padding: padding,
                  child: Align(
                    alignment: alignment,
                    child: child,
                  ),
                ),
              ),
            ),
          );
  }
}
