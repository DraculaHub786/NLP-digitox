// Copyright (c) 2026 NLP digitox

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/models/group_member.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/network_avatar.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// One member row in a group's roster.
///
/// Mirrors the session roster's shape — an avatar, the display name and a
/// trailing role marker — so a group roster and a session roster read as the
/// same list. The avatar is the member's real photo when they have one and an
/// initial circle otherwise.
///
/// [isMe] is passed in rather than resolved here: reading the auth singleton
/// from a leaf widget would force every render — and every widget test — to
/// bring up Firebase.
class GroupMemberTile extends StatelessWidget {
  const GroupMemberTile({
    super.key,
    required this.member,
    this.isMe = false,
    this.onTap,
    this.trailing,
  });

  final GroupMember member;

  /// Accents the row and appends "(you)" so the reader finds themselves.
  final bool isMe;

  /// Opens the member's actions (report/block, promote, remove).
  final VoidCallback? onTap;

  /// Overrides the default role marker on the trailing edge.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = isMe ? colorScheme.primary : null;

    return DefaultListTile(
      onPressed: onTap,
      accent: accent,
      leading: NetworkAvatar(
        imageUrl: member.photoUrl,
        radius: 20,
        backgroundColor:
            (accent ?? colorScheme.primary).withValues(alpha: 0.14),
        fallback: Text(
          member.initial,
          style: TextStyle(
            color: accent ?? colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
      titleText: isMe ? '${member.displayName} (you)' : member.displayName,
      subtitle: _RoleLine(role: member.role, isMe: isMe),
      trailing: trailing ??
          (member.isOwner
              ? Icon(
                  FluentIcons.crown_20_filled,
                  size: 16,
                  color: DesignPalette.goldWarm,
                )
              : null),
    );
  }
}

/// The role label under a member's name.
///
/// Split out so the wording lives in one place: the roster, the role picker
/// and the removal confirmation all read the same phrase.
class _RoleLine extends StatelessWidget {
  const _RoleLine({required this.role, required this.isMe});

  final GroupRole role;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        StyledText(
          role.label,
          fontSize: 14,
          isSubtitle: true,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (isMe) ...[
          const SizedBox(width: Spacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
            child: StyledText(
              'You',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
              maxLines: 1,
            ),
          ),
        ],
      ],
    );
  }
}
