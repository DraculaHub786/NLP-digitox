import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';

enum StatusDotKind { good, warn, bad }

/// Small filled-circle status indicator (Guide 6 §5).
class StatusDot extends StatelessWidget {
  final StatusDotKind kind;
  final double size;

  const StatusDot({
    super.key,
    this.kind = StatusDotKind.good,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    final glass = GlassTokens.of(context);
    final color = switch (kind) {
      StatusDotKind.good => glass.statusGood,
      StatusDotKind.warn => glass.statusWarn,
      StatusDotKind.bad => glass.statusBad,
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: size * 0.6,
            spreadRadius: size * 0.15,
          ),
        ],
      ),
    );
  }
}
