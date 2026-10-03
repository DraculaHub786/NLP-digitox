import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/constants/session_limits.dart';
import 'package:nlp_digitox/features/shared_sessions/session_error_message.dart';
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SeatChip(used: session.memberCount, total: session.maxMembers),
          const SizedBox(width: 4),
          Icon(
            FluentIcons.chevron_right_20_regular,
            size: 22,
            color: colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ],
      ),
      accent: colorScheme.primary,
      onPressed: onTap,
    );
  }
}

/// "3/10" seat counter for a session row, flipping to a warning-coloured
/// "Full" once the cap is reached, so a closed room is obvious from the list
/// without opening it.
///
/// [total] is taken from the session rather than from the constant: a room
/// could have been created under an older cap, and the number shown has to be
/// the number the server will actually enforce for that room.
class _SeatChip extends StatelessWidget {
  const _SeatChip({required this.used, required this.total});

  final int used;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFull = used >= total;
    final accent = isFull ? colorScheme.error : colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: StyledText(
        isFull ? 'Full' : '$used/$total',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: accent,
        maxLines: 1,
      ),
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

  /// Whether this room currently has no free seat, read from the card's own
  /// payload. The button and the tap handler share this one predicate so they
  /// cannot disagree about whether joining is possible.
  bool get _isFull {
    final memberCount = widget.data['memberCount'] as int? ?? 0;
    final maxMembers = SessionLimits.normalizeMaxMembers(
      widget.data['maxMembers'] as int?,
    );
    return memberCount >= maxMembers;
  }

  Future<void> _join() async {
    // The card can be stale by the time it is tapped: the room may have filled
    // since the list was drawn, and the server would then reject the write.
    // Checking here gives the user the reason instead of a spinner that ends in
    // an error.
    if (_isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SessionLimits.fullSessionMessage)),
      );
      return;
    }

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
        // Write the failure the way the join sheets do. `$error` printed the
        // raw exception — including things like "Bad state: Tried to use
        // JoinSessionByIdNotifier after 'dispose' was called" — which tells the
        // user nothing they can act on.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(sessionErrorMessage(error, 'join'))),
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
    final maxMembers = SessionLimits.normalizeMaxMembers(
      widget.data['maxMembers'] as int?,
    );

    // "4/10 members" rather than "4 members": the seat count is the whole
    // point of the cap, and a bare count tells the user nothing about whether
    // there is room left.
    final meta = StringBuffer('$memberCount/$maxMembers members');
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
              : _isFull
                  // No Join button once the room is closed: a disabled control
                  // invites taps that can never succeed. The reason replaces
                  // it instead.
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                      child: StyledText(
                        'Full',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.error,
                        maxLines: 1,
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
