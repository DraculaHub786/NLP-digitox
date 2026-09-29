import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';
import 'package:nlp_digitox/providers/session_provider.dart';
import 'package:nlp_digitox/providers/system/digitox_settings_provider.dart'
    show digitoxSettingsProvider;
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/status_dot.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';

/// One row in "My Sessions" — the app's standard `DefaultListTile` row with a
/// leading member-count avatar, a live presence line and a chevron.
class MySessionCard extends StatelessWidget {
  const MySessionCard({
    super.key,
    required this.session,
    required this.onTap,
    this.margin,
  });

  final SharedSession session;
  final VoidCallback onTap;

  /// Forwarded to [DefaultListTile]. Pass [EdgeInsets.zero] when the rows are
  /// grouped inside one card so they sit flush against their dividers.
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasActive = session.activeMembers > 0;

    return DefaultListTile(
      margin: margin,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.primary.withValues(alpha: 0.14),
        ),
        alignment: Alignment.center,
        child: StyledText(
          '${session.memberCount}',
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
      titleText: session.name,
      subtitle: _SessionSubtitle(
        hasActive: hasActive,
        activeMembers: session.activeMembers,
        theme: session.theme,
      ),
      trailing: Icon(
        FluentIcons.chevron_right_20_regular,
        size: 22,
        color: colorScheme.onSurface.withValues(alpha: 0.45),
      ),
      accent: colorScheme.primary,
      onPressed: onTap,
    );
  }
}

/// Presence + theme line shared by the session rows.
class _SessionSubtitle extends StatelessWidget {
  const _SessionSubtitle({
    required this.hasActive,
    required this.activeMembers,
    this.theme,
  });

  final bool hasActive;
  final int activeMembers;
  final String? theme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeLabel = theme;

    return Row(
      children: [
        StatusDot(
          kind: hasActive ? StatusDotKind.good : StatusDotKind.warn,
          size: 8,
        ),
        const SizedBox(width: Spacing.sm),
        Flexible(
          child: StyledText(
            hasActive
                ? '$activeMembers focusing now'
                : 'No one focusing yet',
            fontSize: 14,
            isSubtitle: true,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (themeLabel != null && themeLabel.isNotEmpty) ...[
          const SizedBox(width: Spacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
            child: StyledText(
              themeLabel,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.secondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

/// One card in "Discover" — a public session with a join action.
///
/// Joining is optimistic in the UI sense only: the row shows an inline spinner
/// while the write is in flight and reports success or failure through a
/// SnackBar on the screen's Scaffold, so the card itself never blocks.
class DiscoverSessionCard extends ConsumerStatefulWidget {
  const DiscoverSessionCard({super.key, required this.data});

  /// Raw `publicSessions/{id}` entry, with `id` and a live `memberCount`
  /// injected by `SessionService.getPublicSessions`.
  final Map<String, dynamic> data;

  @override
  ConsumerState<DiscoverSessionCard> createState() => _DiscoverSessionCardState();
}

class _DiscoverSessionCardState extends ConsumerState<DiscoverSessionCard> {
  bool _joining = false;

  Future<void> _join() async {
    setState(() => _joining = true);
    try {
      // Use the app's configured username as the in-session display name
      // (falls back to 'Me' if somehow empty).
      final username = ref.read(digitoxSettingsProvider).username.trim();
      await ref.read(joinByIdProvider.notifier).joinById(
            sessionId: widget.data['id'] as String,
            displayName: username.isNotEmpty ? username : 'Me',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You joined the session!'),
            backgroundColor: Colors.green,
          ),
        );
        // Invalidate to refresh My Sessions tab
        ref.invalidate(userSessionsProvider);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = widget.data['name'] as String? ?? 'Session';
    final sessionTheme = widget.data['theme'] as String?;
    final memberCount = widget.data['memberCount'] as int? ?? 0;

    final meta = StringBuffer(
      '$memberCount member${memberCount == 1 ? '' : 's'}',
    );
    if (sessionTheme != null && sessionTheme.isNotEmpty) {
      meta.write(' • $sessionTheme');
    }

    return SurfaceCard(
      padding: const EdgeInsets.all(Spacing.base),
      borderRadius: Radii.lg,
      tint: colorScheme.secondary,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
            child: Icon(
              FluentIcons.globe_20_filled,
              size: 20,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(width: Spacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  name,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                StyledText(
                  meta.toString(),
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          _joining
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.secondary,
                  ),
                )
              : TextButton(
                  onPressed: _join,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                  ),
                  child: const Text('Join'),
                ),
        ],
      ),
    );
  }
}
