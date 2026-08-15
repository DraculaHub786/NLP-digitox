import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/services/profile_service.dart';

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
    _loadProfilePic();
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
      return ClipOval(
        child: Image.network(
          _profileUrl!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultAvatar(colorScheme),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildDefaultAvatar(colorScheme);
          },
        ),
      );
    }

    return _buildDefaultAvatar(colorScheme);
  }

  Widget _buildDefaultAvatar(ColorScheme colorScheme) {
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
