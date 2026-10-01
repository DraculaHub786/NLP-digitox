import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/utils/invite_code.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// Shows how to bring someone else into a session: the code, a QR, and a
/// share action.
///
/// The QR encodes [InviteCode.linkFor] — the `https` join link when a host is
/// configured, and the app-scheme link otherwise. Sharing plain text is the
/// primary path: it always works, whereas a QR only helps when both people are
/// in the same room and the scanning app understands the scheme.
class SessionInvitePanel extends StatelessWidget {
  const SessionInvitePanel({
    super.key,
    required this.code,
    required this.sessionName,
    this.durationSec,
  });

  /// The invite code; when null the panel hides itself, because a local-only
  /// session has no code to share.
  final String? code;

  final String sessionName;
  final int? durationSec;

  @override
  Widget build(BuildContext context) {
    final inviteCode = code;
    if (inviteCode == null || inviteCode.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

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

          // The code itself, big and letter-spaced so it can be read aloud.
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
                semanticsLabel: 'Invite QR code',
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          Center(
            child: StyledText(
              'Scan with a phone camera, or share the link below.',
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
                  onPressed: () => _copy(context, inviteCode),
                  icon: const Icon(FluentIcons.copy_20_regular, size: 18),
                  label: const Text('Copy code'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.base),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _share(inviteCode),
                  icon: const Icon(FluentIcons.share_20_filled, size: 18),
                  label: const Text('Share'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.base),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    final durationLabel = _durationLabel();
    await Share.share(
      'Join "$sessionName"$durationLabel on NLP-Digitox.\n'
      'Code: $inviteCode\n'
      '$link',
      subject: 'Focus with me on NLP-Digitox',
    );
  }

  /// Turns `durationSec` into a short " (25 min)" suffix, or "" when unknown.
  String _durationLabel() {
    final seconds = durationSec;
    if (seconds == null || seconds <= 0) return '';
    final minutes = seconds ~/ 60;
    return ' — $minutes min';
  }
}
