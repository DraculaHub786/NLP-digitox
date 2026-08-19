import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/enums/platform_features.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/providers/restrictions/wellbeing_provider.dart';
import 'package:nlp_digitox/providers/system/parental_controls_provider.dart';
import 'package:nlp_digitox/ui/common/default_expandable_list_tile.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

class SliverShortsQuickActions extends ConsumerWidget {
  const SliverShortsQuickActions({
    super.key,
    required this.haveNecessaryPerms,
  });

  final bool haveNecessaryPerms;

  void _toggleFeature(
    BuildContext context,
    WidgetRef ref,
    List<PlatformFeatures> blockedFeatures,
    PlatformFeatures feature,
  ) {
    final isInvincibleRestricted = ref.read(parentalControlsProvider
            .select((v) => v.isInvincibleModeOn && v.includeShortsTimer)) &&
        !ref
            .read(parentalControlsProvider.notifier)
            .isBetweenInvincibleWindow &&
        ref.read(wellBeingProvider.select((v) => v.allowedShortsTimeSec > 0));

    if (isInvincibleRestricted && blockedFeatures.contains(feature)) {
      context.showSnackAlert(context.locale.invincible_mode_snack_alert);
      return;
    }

    ref.read(wellBeingProvider.notifier).insertRemoveBlockedFeature(feature);
  }

  Widget _buildIcon(BuildContext context, String path) => Opacity(
        opacity: haveNecessaryPerms ? 1 : 0.5,
        child: SvgPicture.asset(
          path,
          colorFilter: ColorFilter.mode(
            Theme.of(context).iconTheme.color ?? Colors.grey,
            BlendMode.srcIn,
          ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final blockedFeatures =
        ref.watch(wellBeingProvider.select((v) => v.blockedFeatures));

    return SliverList.list(
      children: [
        /// Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: ModernSectionHeader(
            title: context.locale.quick_actions_heading,
          ),
        ),

        /// Block instagram features
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: DefaultExpandableListTile(
            leading: _buildIcon(context, "assets/vectors/instagram.svg"),
            enabled: haveNecessaryPerms,
            titleText: context.locale.instagram_features_tile_title,
            subtitleText: context.locale.instagram_features_tile_subtitle,
            content: Column(
              children: [
                /// Reels
                DefaultListTile(
                  titleText: context.locale.instagram_features_block_reels,
                  switchValue:
                      blockedFeatures.contains(PlatformFeatures.instagramReels),
                  onPressed: () => _toggleFeature(
                    context,
                    ref,
                    blockedFeatures,
                    PlatformFeatures.instagramReels,
                  ),
                ),

                /// Explore
                DefaultListTile(
                  titleText: context.locale.instagram_features_block_explore,
                  switchValue:
                      blockedFeatures.contains(PlatformFeatures.instagramExplore),
                  onPressed: () => _toggleFeature(
                    context,
                    ref,
                    blockedFeatures,
                    PlatformFeatures.instagramExplore,
                  ),
                ),
              ],
            ),
          ),
        ),

        /// Block snapchat features
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: DefaultExpandableListTile(
            leading: _buildIcon(context, "assets/vectors/snapchat.svg"),
            enabled: haveNecessaryPerms,
            titleText: context.locale.snapchat_features_tile_title,
            subtitleText: context.locale.snapchat_features_tile_subtitle,
            content: Column(
              children: [
                /// Spotlight
                DefaultListTile(
                  titleText: context.locale.snapchat_features_block_spotlight,
                  switchValue: blockedFeatures
                      .contains(PlatformFeatures.snapchatSpotlight),
                  onPressed: () => _toggleFeature(
                    context,
                    ref,
                    blockedFeatures,
                    PlatformFeatures.snapchatSpotlight,
                  ),
                ),

                /// Discover
                DefaultListTile(
                  titleText: context.locale.snapchat_features_block_discover,
                  switchValue:
                      blockedFeatures.contains(PlatformFeatures.snapchatDiscover),
                  onPressed: () => _toggleFeature(
                    context,
                    ref,
                    blockedFeatures,
                    PlatformFeatures.snapchatDiscover,
                  ),
                )
              ],
            ),
          ),
        ),

        /// Block youtube shorts
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(Radii.xl),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: Opacity(
              opacity: haveNecessaryPerms ? 1 : 0.5,
              child: Row(
                children: [
                  _buildIcon(context, "assets/vectors/youtube.svg"),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StyledText(
                          context.locale.youtube_features_tile_title,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        StyledText(
                          context.locale.youtube_features_tile_subtitle,
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.75),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.85,
                    child: Switch.adaptive(
                      value: blockedFeatures.contains(PlatformFeatures.youtubeShorts),
                      onChanged: haveNecessaryPerms
                          ? (_) => _toggleFeature(
                                context,
                                ref,
                                blockedFeatures,
                                PlatformFeatures.youtubeShorts,
                              )
                          : null,
                      activeThumbColor: colorScheme.primary,
                      activeTrackColor: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Block facebook reels
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(Radii.xl),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: Opacity(
              opacity: haveNecessaryPerms ? 1 : 0.5,
              child: Row(
                children: [
                  _buildIcon(context, "assets/vectors/facebook.svg"),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StyledText(
                          context.locale.facebook_features_tile_title,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        StyledText(
                          context.locale.facebook_features_tile_subtitle,
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.75),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.85,
                    child: Switch.adaptive(
                      value: blockedFeatures.contains(PlatformFeatures.facebookReels),
                      onChanged: haveNecessaryPerms
                          ? (_) => _toggleFeature(
                                context,
                                ref,
                                blockedFeatures,
                                PlatformFeatures.facebookReels,
                              )
                          : null,
                      activeThumbColor: colorScheme.primary,
                      activeTrackColor: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Block reddit shorts
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(Radii.xl),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: Opacity(
              opacity: haveNecessaryPerms ? 1 : 0.5,
              child: Row(
                children: [
                  _buildIcon(context, "assets/vectors/reddit.svg"),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StyledText(
                          context.locale.reddit_features_tile_title,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        StyledText(
                          context.locale.reddit_features_tile_subtitle,
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.75),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.85,
                    child: Switch.adaptive(
                      value: blockedFeatures.contains(PlatformFeatures.redditShorts),
                      onChanged: haveNecessaryPerms
                          ? (_) => _toggleFeature(
                                context,
                                ref,
                                blockedFeatures,
                                PlatformFeatures.redditShorts,
                              )
                          : null,
                      activeThumbColor: colorScheme.primary,
                      activeTrackColor: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Block X (Twitter) video feed
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(Radii.xl),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: Opacity(
              opacity: haveNecessaryPerms ? 1 : 0.5,
              child: Row(
                children: [
                  _buildIcon(context, "assets/vectors/x.svg"),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StyledText(
                          context.locale.x_features_tile_title,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        StyledText(
                          context.locale.x_features_tile_subtitle,
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.75),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.85,
                    child: Switch.adaptive(
                      value: blockedFeatures.contains(PlatformFeatures.xVideos),
                      onChanged: haveNecessaryPerms
                          ? (_) => _toggleFeature(
                                context,
                                ref,
                                blockedFeatures,
                                PlatformFeatures.xVideos,
                              )
                          : null,
                      activeThumbColor: colorScheme.primary,
                      activeTrackColor: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Block Threads video/reels
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(Radii.xl),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: Opacity(
              opacity: haveNecessaryPerms ? 1 : 0.5,
              child: Row(
                children: [
                  _buildIcon(context, "assets/vectors/threads.svg"),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StyledText(
                          context.locale.threads_features_tile_title,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        StyledText(
                          context.locale.threads_features_tile_subtitle,
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.75),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.85,
                    child: Switch.adaptive(
                      value: blockedFeatures.contains(PlatformFeatures.threadsReels),
                      onChanged: haveNecessaryPerms
                          ? (_) => _toggleFeature(
                                context,
                                ref,
                                blockedFeatures,
                                PlatformFeatures.threadsReels,
                              )
                          : null,
                      activeThumbColor: colorScheme.primary,
                      activeTrackColor: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
