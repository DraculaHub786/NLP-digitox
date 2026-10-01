// Copyright (c) 2026 NLP digitox

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/features/groups/widgets/group_member_tile.dart';
import 'package:nlp_digitox/models/focus_group.dart';
import 'package:nlp_digitox/models/group_member.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

/// The group roster, with per-member actions for whoever may manage it.
///
/// The actions are passed in rather than performed here: the screen owns the
/// confirmations and the error surfacing, and a section that reached into the
/// action provider itself would give the screen two ways to report the same
/// failure.
class GroupRosterSection extends StatelessWidget {
  const GroupRosterSection({
    super.key,
    required this.group,
    required this.members,
    required this.currentUserId,
    required this.onReportBlock,
    required this.onRemoveMember,
    required this.onToggleRole,
  });

  final FocusGroup group;
  final List<GroupMember> members;
  final String? currentUserId;

  /// Opens the report/block sheet for one member.
  final void Function(GroupMember member) onReportBlock;

  /// Removes one member. Owner or admin only.
  final void Function(GroupMember member) onRemoveMember;

  /// Flips one member between admin and regular member. Owner only.
  final void Function(GroupMember member) onToggleRole;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: 'Members',
          subtitle: members.isEmpty
              ? 'Nobody loaded yet'
              : '${members.length} of ${group.maxMembers}',
        ),
        const SizedBox(height: Spacing.sm),
        SurfaceCard(
          padding: EdgeInsets.zero,
          elevation: 0,
          child: Column(
            children: [
              for (final member in members) ...[
                GroupMemberTile(
                  member: member,
                  isMe: member.userId == currentUserId,
                  onTap: member.userId == currentUserId
                      ? null
                      : () => _showMemberActions(context, member),
                ),
                if (member != members.last)
                  const Divider(height: 0.5, indent: 56),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// The action sheet for one member.
  ///
  /// Only the options this reader may actually use are shown: an ordinary
  /// member sees "report or block" alone, which is the one thing they can do
  /// about somebody else.
  void _showMemberActions(BuildContext context, GroupMember member) {
    final canManage = group.canManage;
    final isOwner = group.isOwnedByMe;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colorScheme = Theme.of(sheetContext).colorScheme;

        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(Radii.lg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Spacing.base),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          member.displayName,
                          style: Theme.of(sheetContext)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        member.role.label,
                        style: Theme.of(sheetContext).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(FluentIcons.flag_20_regular),
                  title: const Text('Report or block'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onReportBlock(member);
                  },
                ),
                if (isOwner && !member.isOwner)
                  ListTile(
                    leading: const Icon(FluentIcons.shield_20_regular),
                    title: Text(
                      member.role == GroupRole.admin
                          ? 'Make a regular member'
                          : 'Make an admin',
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      onToggleRole(member);
                    },
                  ),
                if (canManage && !member.isOwner)
                  ListTile(
                    leading: Icon(
                      FluentIcons.person_delete_20_regular,
                      color: colorScheme.error,
                    ),
                    title: Text(
                      'Remove from group',
                      style: TextStyle(color: colorScheme.error),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      onRemoveMember(member);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
