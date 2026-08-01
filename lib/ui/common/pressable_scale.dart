import 'package:flutter/material.dart';

/// Wraps a child in an [AnimatedScale] that subtly shrinks while pressed.
///
/// Uses a raw [Listener] instead of a [GestureDetector] so the scale feedback
/// never competes with, or steals gestures from, an inner [InkWell]/[InkResponse]
/// — the InkWell keeps its ripple + onTap, and the card still "gives" on press.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.scale = 0.97,
    this.duration = const Duration(milliseconds: 100),
  });

  final Widget child;

  /// Scale applied while the pointer is down. Defaults to 0.97.
  final double scale;

  /// How long the scale transition takes. Defaults to 100ms.
  final Duration duration;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
