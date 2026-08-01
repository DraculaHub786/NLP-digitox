
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/app_constants.dart';

class DefaultPageTransitionsBuilder extends PageTransitionsBuilder {
  /// Fade-through page transition for android: the incoming route fades in
  /// with a subtle upward glide while the outgoing route fades out, reading
  /// more premium than the default abrupt slide.
  const DefaultPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: AppConstants.defaultCurve,
      reverseCurve: AppConstants.defaultCurve.flipped,
    );
    final secondaryCurvedAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.easeInToLinear,
    );

    /// Remove the outgoing route from the tree as soon as its fade-out
    /// completes, so it doesn't linger as an invisible layer.
    if (route.isFirst) {
      return _FadeThroughTransition(
        animation: curvedAnimation,
        child: child,
      );
    }

    return _FadeThroughTransition(
      animation: curvedAnimation,
      secondaryAnimation: secondaryCurvedAnimation,
      child: child,
    );
  }
}

class _FadeThroughTransition extends StatelessWidget {
  const _FadeThroughTransition({
    required this.child,
    required this.animation,
    this.secondaryAnimation,
  });

  final Animation<double> animation;
  final Animation<double>? secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final slideOffset = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(animation);

    // When there is no secondary animation (e.g. the first route in the
    // navigator), the outgoing-route fade must be skipped entirely.
    // Using a fallback of kAlwaysCompleteAnimation (= 1.0) here would wrap
    // the child in `FadeTransition(opacity: ReverseAnimation(1.0))`, which is
    // permanently 0.0 — the route paints black forever. This is what caused
    // the black screen right after the splash when Home replaced Splash and
    // became the first route.
    final secondary = secondaryAnimation;
    if (secondary == null) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: slideOffset,
          child: child,
        ),
      );
    }

    final secondarySlideOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.02),
    ).animate(secondary);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: slideOffset,
        child: FadeTransition(
          opacity: ReverseAnimation(secondary),
          child: SlideTransition(
            position: secondarySlideOffset,
            child: child,
          ),
        ),
      ),
    );
  }
}
