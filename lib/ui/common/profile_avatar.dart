import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/services/profile_service.dart';
import 'package:nlp_digitox/ui/common/network_avatar.dart';

/// Shared circular profile picture used on the Dashboard header and the
/// dedicated Profile screen. Loads the Firestore profile URL via
/// [ProfileService] and falls back to a themed person icon.
class ProfileAvatar extends StatefulWidget {
  final double size;

  const ProfileAvatar({super.key, this.size = 40});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  String? _profileUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Refresh when the picture changes elsewhere (account tab / profile screen)
    // instead of relying on this widget being recreated.
    ProfileService.instance.profileUrlNotifier.addListener(_onProfileUrlChanged);
    _loadProfilePic();
  }

  @override
  void dispose() {
    ProfileService.instance.profileUrlNotifier
        .removeListener(_onProfileUrlChanged);
    super.dispose();
  }

  void _onProfileUrlChanged() {
    if (!mounted) return;
    setState(() {
      _profileUrl = ProfileService.instance.profileUrlNotifier.value;
      _isLoading = false;
    });
  }

  Future<void> _loadProfilePic() async {
    try {
      final url = await ProfileService.instance.getProfileUrl();
      if (mounted) {
        setState(() {
          _profileUrl = url;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.primaryContainer,
        ),
        child: Center(
          child: SizedBox(
            width: widget.size * 0.5,
            height: widget.size * 0.5,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (_profileUrl != null && _profileUrl!.isNotEmpty) {
      // NetworkAvatar (CachedNetworkImage under the hood) instead of a raw
      // Image.network: Image.network's errorBuilder has no retry — a single
      // transient load failure right after upload (Cloudinary can be briefly
      // inconsistent right after an unsigned upload finishes) locks this
      // widget onto the fallback icon until it's torn down and recreated,
      // e.g. by restarting the app. NetworkAvatar is what the leaderboard
      // already uses reliably, so both surfaces now share one robust,
      // battle-tested image-loading path, and repeat loads of the same URL
      // are served from disk cache instead of re-fetching over the network.
      return NetworkAvatar(
        imageUrl: _profileUrl,
        radius: widget.size / 2,
        backgroundColor: colorScheme.primaryContainer,
        fallback: Icon(
          FluentIcons.person_20_filled,
          size: widget.size * 0.5,
          color: colorScheme.primary,
        ),
      );
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer,
      ),
      child: Icon(
        FluentIcons.person_20_filled,
        size: widget.size * 0.5,
        color: colorScheme.primary,
      ),
    );
  }
}
