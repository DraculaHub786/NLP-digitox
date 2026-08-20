import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';

/// Podium slot for the leaderboard top-3. Rank 1 is the tallest card in the
/// center; 2 and 3 sit lower on either side so all three align on a common
/// bottom edge. Medal-tinted tonal card surface (no glass blur).
class PodiumCard extends StatelessWidget {
  final int rank; // 1, 2, or 3
  final String name;
  final int points;
  final bool isCurrentUser;

  const PodiumCard({
    super.key,
    required this.rank,
    required this.name,
    required this.points,
    this.isCurrentUser = false,
  });

  static const _heights = {1: 150.0, 2: 120.0, 3: 100.0};

  static const _medalColors = {
    1: Color(0xFFFFC145), // gold
    2: Color(0xFFC0C0C0), // silver
    3: Color(0xFFCD7F32), // bronze
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final medal = _medalColors[rank]!;

    return SizedBox(
      height: _heights[rank],
      width: double.infinity,
      child: SurfaceCard(
        tint: medal,
        elevation: rank == 1 ? 2 : 1,
        // 8px vertical padding (instead of 12) buys back the 6px the rank-3
        // card's fixed height was short, so the avatar renders at full size
        // at the default font scale. The Flexible guard below then absorbs
        // any larger system font scale / longer username.
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.sm,
          horizontal: Spacing.sm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // The avatar is the only compressible element in the fixed-height
            // card. Wrapping it in Flexible + FittedBox lets it shrink when
            // the name/points rows (which grow with long usernames or larger
            // system font scales) eat into the card's fixed height — otherwise
            // the Column overflows (~6px on the rank-3 card) and Flutter
            // paints the yellow/black overflow stripe.
            Flexible(
              fit: FlexFit.loose,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: CircleAvatar(
                  radius: rank == 1 ? 26 : 20,
                  backgroundColor: medal.withValues(alpha: 0.25),
                ),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                name,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isCurrentUser
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              '$points pts',
              style: TextStyle(
                fontSize: 12,
                color: DesignPalette.subInk(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
