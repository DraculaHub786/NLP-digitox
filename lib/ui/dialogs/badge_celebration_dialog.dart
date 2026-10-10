// Copyright (c) 2026 NLP digitox

import 'dart:math';

import 'package:confetti/confetti.dart';
// Material ships its own `Badge` widget; the earned-badge model is the one in
// use here, so the widget of that name is hidden rather than prefixed — the
// file never renders it.
import 'package:flutter/material.dart' hide Badge;
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/models/badge_model.dart';
import 'package:nlp_digitox/ui/common/network_avatar.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// Shows the "you earned a badge" celebration and resolves when it is dismissed.
///
/// Uses `showGeneralDialog` rather than `showDialog` because the celebration is
/// a moment, not a question: it is deliberately dismissible from the barrier so
/// a user who is mid-task is never trapped behind it.
Future<void> showBadgeCelebrationDialog(BuildContext context, Badge badge) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss badge celebration',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => _BadgeCelebrationDialog(badge: badge),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// The dialog body. Owns its own [ConfettiController] so the animation is
/// created and destroyed with the dialog — the same bounded-blast pattern the
/// session-complete screen uses, and the reason no confetti can outlive this
/// route and keep burning frames.
class _BadgeCelebrationDialog extends StatefulWidget {
  const _BadgeCelebrationDialog({required this.badge});

  final Badge badge;

  @override
  State<_BadgeCelebrationDialog> createState() => _BadgeCelebrationDialogState();
}

class _BadgeCelebrationDialogState extends State<_BadgeCelebrationDialog> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 900));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final badge = widget.badge;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.xl),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(Radii.xl),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NetworkAvatar(
                  radius: 44,
                  imageUrl: badge.imageUrl,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                  fallback: Icon(
                    Icons.workspace_premium,
                    size: 44,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                StyledText(
                  'New badge earned',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: Spacing.sm),
                StyledText(
                  badge.title.isEmpty ? 'Achievement unlocked' : badge.title,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (badge.displayPeriodLabel.isNotEmpty) ...[
                  const SizedBox(height: Spacing.sm),
                  StyledText(
                    badge.displayPeriodLabel,
                    fontSize: 13,
                    isSubtitle: true,
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: Spacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Nice!'),
                  ),
                ),
              ],
            ),
          ),
          // Above the card, and outside its bounds on purpose so the burst
          // falls past the dialog rather than being clipped by it.
          Positioned(
            top: -Spacing.xl,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 10,
              minBlastForce: 5,
              emissionFrequency: 0.07,
              numberOfParticles: 20,
              gravity: 0.25,
              shouldLoop: false,
              colors: [
                colorScheme.primary,
                colorScheme.tertiary,
                DesignPalette.goldWarm,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
