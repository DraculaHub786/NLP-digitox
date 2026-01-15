// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'dart:ui';
import 'package:flutter/material.dart';

/// A modern glassmorphic container with blur effect and gradient border
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? primaryColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final bool enableBorder;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blur = 10,
    this.opacity = 0.15,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.primaryColor,
    this.borderColor,
    this.boxShadow,
    this.gradient,
    this.enableBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final defaultPrimaryColor = primaryColor ?? 
        (isDark ? Colors.white : theme.colorScheme.primary);
    
    final defaultBorderColor = borderColor ?? 
        defaultPrimaryColor.withValues(alpha: 0.2);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: defaultPrimaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient ?? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  defaultPrimaryColor.withValues(alpha: opacity),
                  defaultPrimaryColor.withValues(alpha: opacity * 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: enableBorder ? Border.all(
                color: defaultBorderColor,
                width: 1.5,
              ) : null,
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A glassmorphic card with elevated style
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final content = GlassmorphicContainer(
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin,
      width: width,
      height: height,
      primaryColor: color,
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: content,
      );
    }

    return content;
  }
}

/// A glassmorphic button with modern design
class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? color;
  final bool isOutlined;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.color,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;

    return GlassmorphicContainer(
      width: width,
      height: height ?? 56,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      primaryColor: isOutlined ? buttonColor.withValues(alpha: 0.1) : buttonColor,
      opacity: isOutlined ? 0.05 : 0.8,
      blur: 15,
      borderColor: isOutlined ? buttonColor.withValues(alpha: 0.3) : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: DefaultTextStyle(
              style: theme.textTheme.titleMedium!.copyWith(
                color: isOutlined ? buttonColor : Colors.white,
                fontWeight: FontWeight.w600,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
