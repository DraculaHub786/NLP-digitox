import 'package:flutter/material.dart' hide Durations;
import 'package:nlp_digitox/config/design_tokens.dart';

/// Fade + gentle rise entrance used to stagger list items on the home
/// screen. Each item delays by `index * Durations.stagger` before animating.
class StaggerEntrance extends StatefulWidget {
  final Widget child;
  final int index;

  const StaggerEntrance({super.key, required this.child, required this.index});

  @override
  State<StaggerEntrance> createState() => _StaggerEntranceState();
}

class _StaggerEntranceState extends State<StaggerEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Durations.entrance);
    _opacity = CurvedAnimation(parent: _ctrl, curve: AppCurves.entrance);
    _offset = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: AppCurves.entrance));
    Future.delayed(
      Duration(milliseconds: widget.index * Durations.stagger.inMilliseconds),
      () {
        if (mounted) _ctrl.forward();
      },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _opacity,
        child: SlideTransition(position: _offset, child: widget.child),
      );
}
