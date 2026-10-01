// Copyright (c) 2026 NLP digitox

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/utils/invite_code.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// Shows how to bring someone into a group: the code, a QR, and a share link.
///
/// Deliberately close in shape to the session invite panel — the two are the
/// same idea ("here is the code") and should not look like different features.
/// The difference is that a group code lasts days, so the copy says so.
class GroupInvitePanel extends StatelessWidget {
  const GroupInvitePanel({
    super.key,
    required this.groupName,
    required this.code,
    this.canManage = false,
    this.onRefreshCode,
    this.onRevokeCode,
    this.isBusy = false,
  });

  final String groupName;

  /// The live invite code, or null when the group has none.
  final String? code;

  /// Whether the reader may issue or revoke codes.
  final bool canManage;

  /// Issues a fresh code and returns it; null when the action failed.
  final Future<String?> Function()? onRefreshCode;

  final Future<void> Function()? onRevokeCode;

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final inviteCode = code;

    return SurfaceCard(
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FluentIcons.qr_code_20_filled,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: StyledText(
                  'Invite people',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          if (inviteCode == null || inviteCode.isEmpty)
            _NoCodeBody(
              canManage: canManage,
              isBusy: isBusy,
              onRefreshCode: onRefreshCode,
            )
          else ...[
            // The code, big and letter-spaced so it can be read aloud.
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg,
                  vertical: Spacing.md,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(Radii.lg),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: StyledText(
                  inviteCode,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Center(
              child: Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: QrImageView(
                  data: InviteCode.linkFor(inviteCode),
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: Colors.white,
                  // A decorative QR is meaningless to a screen reader; the code
                  // above is the accessible representation.
                  semanticsLabel: 'Group invite QR code',
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Center(
              child: StyledText(
                'This code stays valid for several days.',
                fontSize: 12,
                textAlign: TextAlign.center,
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        isBusy ? null : () => _copy(context, inviteCode),
                    icon: const Icon(FluentIcons.copy_20_regular, size: 18),
                    label: const Text('Copy code'),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: Spacing.base),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isBusy ? null : () => _share(inviteCode),
                    icon: const Icon(FluentIcons.share_20_filled, size: 18),
                    label: const Text('Share'),
                    style: FilledButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: Spacing.base),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (canManage) ...[
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: isBusy ? null : () => onRefreshCode?.call(),
                      icon: const Icon(
                        FluentIcons.arrow_sync_20_regular,
                        size: 18,
                      ),
                      label: const Text('New code'),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: isBusy ? null : () => onRevokeCode?.call(),
                      icon: Icon(
                        FluentIcons.delete_20_regular,
                        size: 18,
                        color: colorScheme.error,
                      ),
                      label: Text(
                        'Revoke',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context, String inviteCode) async {
    await Clipboard.setData(ClipboardData(text: inviteCode));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied')),
    );
  }

  Future<void> _share(String inviteCode) async {
    final link = InviteCode.linkFor(inviteCode);
    await Share.share(
      'Join "$groupName" on NLP-Digitox.\n'
      'Code: $inviteCode\n'
      '$link',
      subject: 'Join my focus group on NLP-Digitox',
    );
  }
}

/// What the panel shows when a group has no live code.
///
/// Split out so the manager case and the member case are two readable
/// paragraphs rather than a nested conditional in the middle of a build method.
class _NoCodeBody extends StatelessWidget {
  const _NoCodeBody({
    required this.canManage,
    required this.isBusy,
    required this.onRefreshCode,
  });

  final bool canManage;
  final bool isBusy;
  final Future<String?> Function()? onRefreshCode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StyledText(
          canManage
              ? 'This group has no active invite code. Create one to let '
                  'people join.'
              : 'There is no active invite code for this group right now. '
                  'Ask an owner or admin for one.',
          fontSize: 13,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          height: 1.35,
        ),
        if (canManage) ...[
          const SizedBox(height: Spacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isBusy ? null : () => onRefreshCode?.call(),
              icon: const Icon(FluentIcons.add_20_filled, size: 18),
              label: const Text('Create invite code'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: Spacing.base),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
