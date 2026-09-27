import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Circular avatar backed by a remote image URL.
///
/// Used for user pictures, podium slots and badges. `CircleAvatar`'s
/// `backgroundImage` (and a bare `NetworkImage`) has no error fallback — a
/// broken or expired URL paints the framework's broken-image glyph, so this
/// widget always renders [fallback] instead when the URL is missing, still
/// loading, or fails to load. Images are disk-cached, which keeps the
/// leaderboard from re-downloading every avatar on each rebuild.
class NetworkAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Widget fallback;
  final Color backgroundColor;

  const NetworkAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    required this.fallback,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              width: diameter,
              height: diameter,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 150),
              placeholder: (context, url) => _buildFallback(),
              errorWidget: (context, url, error) => _buildFallback(),
            )
          : _buildFallback(),
    );
  }

  Widget _buildFallback() => Center(child: fallback);
}
