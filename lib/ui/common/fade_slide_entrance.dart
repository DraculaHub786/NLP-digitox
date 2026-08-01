import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Reusable Section-O entrance animation: fades the child in and slides it up
/// slightly. Pass an [index] to stagger cards relative to one another.
class FadeSlideEntrance extends StatelessWidget {
  const FadeSlideEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 400),
  });

  final Widget child;

  /// Stagger position. Each step adds [staggerInterval].
  final int index;

  /// Base animation duration.
  final Duration duration;

  /// Delay between each stagger step.
  static const Duration staggerInterval = Duration(milliseconds: 80);

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(
          duration: duration,
          delay: staggerInterval * index,
        )
        .slideY(
          begin: 0.15,
          end: 0,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }
}
