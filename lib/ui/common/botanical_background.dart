import 'package:flutter/material.dart';
import 'package:nlp_digitox/ui/common/treated_background_image.dart';

/// Full-bleed botanical background used on screens that live outside the
/// `ScaffoldShell` stack (Phase 4's pushed detail routes).
///
/// IMPORTANT: This deliberately reuses the exact same background layer the
/// shell renders behind its 5 tabs — `TreatedBackgroundImage` (blurred
/// botanical photo + translucent scrim + ambient orbs) — so pushed screens
/// get pixel-identical parity with the Dashboard tab. Do NOT swap this to a
/// flat gradient; the source of truth is `scaffold_shell.dart`.
class BotanicalBackground extends StatelessWidget {
  final Widget child;
  final bool useDrift;

  const BotanicalBackground({
    super.key,
    required this.child,
    this.useDrift = true,
  });

  @override
  Widget build(BuildContext context) {
    return TreatedBackgroundImage(useDrift: useDrift, child: child);
  }
}
