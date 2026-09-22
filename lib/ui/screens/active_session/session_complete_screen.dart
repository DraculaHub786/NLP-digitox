import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// Dedicated completion screen for a finished focus session. Owns its own
/// ConfettiController with a short, bounded blast — since the controller is
/// created and disposed with THIS screen, the animation can never outlive
/// the screen the way the old app-level overlay confetti could.
class SessionCompleteScreen extends StatefulWidget {
  const SessionCompleteScreen({super.key, required this.session});

  final FocusSession session;

  @override
  State<SessionCompleteScreen> createState() => _SessionCompleteScreenState();
}

class _SessionCompleteScreenState extends State<SessionCompleteScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Bounded blast duration — this alone caps how long particles can ever
    // emit for, regardless of gravity/velocity tuning.
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 700));
    _confettiController.play();
  }

  @override
  void dispose() {
    // Disposing here is what makes exiting this screen immediately stop
    // and clear the animation — there is no global overlay to leak.
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.session.durationSecs ~/ 60;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // downward
              maxBlastForce: 12,
              minBlastForce: 6,
              emissionFrequency: 0.08,
              numberOfParticles: 24,
              gravity: 0.25, // finishes falling well within ~2.5s total
              shouldLoop: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 72, color: Colors.green),
                16.vBox,
                StyledText('Session Complete!', fontSize: 24, fontWeight: FontWeight.bold),
                8.vBox,
                StyledText('You focused for $minutes minutes.', fontSize: 14),
                32.vBox,
                FilledButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}