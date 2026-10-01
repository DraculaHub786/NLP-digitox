import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/status_dot.dart';

/// One member row in the session detail screen.
///
/// Keeps the app's `DefaultListTile` row shape: an initial-circle avatar, the
/// display name, and a presence indicator on the trailing edge. The local user
/// is accented so they can find themselves in a long list.
///
/// [isMe] and [isOwner] are passed in rather than resolved here: the caller
/// already knows who the signed-in user is, and reading the auth singleton
/// from inside a leaf widget forces every render (and every widget test) to
/// bring up Firebase.
class SessionMemberTile extends StatelessWidget {
  const SessionMemberTile({
    super.key,
    required this.member,
    required this.isOwner,
    this.isMe = false,
  });

  final SessionMember member;
  final bool isOwner;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = isMe ? colorScheme.primary : null;

    final subtitle = isOwner
        ? 'Owner • ${member.isActive ? 'Focused' : 'Away'}'
        : (member.isActive ? 'Focused' : 'Away');

    return DefaultListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: (accent ?? colorScheme.primary)
            .withValues(alpha: 0.14),
        child: Text(
          member.displayName.isNotEmpty
              ? member.displayName.characters.first.toUpperCase()
              : '?',
          style: TextStyle(
            color: accent ?? colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
      titleText: isMe ? '${member.displayName} (you)' : member.displayName,
      subtitleText: subtitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOwner) ...[
            Icon(
              FluentIcons.crown_20_filled,
              size: 16,
              color: DesignPalette.goldWarm,
            ),
            const SizedBox(width: Spacing.sm),
          ],
          StatusDot(
            kind: member.isActive ? StatusDotKind.good : StatusDotKind.warn,
            size: 10,
          ),
        ],
      ),
      accent: accent,
    );
  }
}
