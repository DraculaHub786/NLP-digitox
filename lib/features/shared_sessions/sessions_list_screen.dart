import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/core/services/session_link_handler.dart';
import 'package:nlp_digitox/features/shared_sessions/session_lobby_screen.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/create_session_sheet.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/join_by_code_sheet.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/join_by_id_sheet.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_cards.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_state_views.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';
import 'package:nlp_digitox/providers/session_provider.dart';
import 'package:nlp_digitox/ui/common/default_fab_button.dart';
import 'package:nlp_digitox/ui/common/default_refresh_indicator.dart';
import 'package:nlp_digitox/ui/common/default_segmented_button.dart';
import 'package:nlp_digitox/ui/common/modern_cards.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

/// The two panes of the shared-sessions screen.
enum SessionTab { mine, discover }

/// Shared focus sessions — browse the groups you belong to, or discover and
/// join a public one.
///
/// Built on the app's standard [ScaffoldShell] so it shares the botanical
/// background, the serif app-bar title and the back affordance with every
/// other pushed route, and it reads correctly in both the light and the dark
/// palette.
class SessionsListScreen extends ConsumerStatefulWidget {
  const SessionsListScreen({super.key});

  @override
  ConsumerState<SessionsListScreen> createState() => _SessionsListScreenState();
}

class _SessionsListScreenState extends ConsumerState<SessionsListScreen> {
  SessionTab _tab = SessionTab.mine;
  StreamSubscription<String>? _linkSubscription;

  @override
  void initState() {
    super.initState();

    // An invite link may have arrived before this screen existed (cold start
    // from the link), so the pending code is read first; the subscription then
    // covers links that arrive while the screen is open.
    final pending = SessionLinkHandler.instance.consumePending();
    if (pending != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _onInviteCode(pending),
      );
    }

    _linkSubscription = SessionLinkHandler.instance.codes.listen(_onInviteCode);
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  /// Opens the join sheet pre-filled with a code from an invite link.
  void _onInviteCode(String code) {
    if (!mounted) return;
    showJoinByCodeSheet(context, initialCode: code);
  }

  Future<void> _refresh() async {
    ref.invalidate(userSessionsProvider);
    ref.invalidate(publicSessionsProvider);
    await Future.wait([
      ref.read(userSessionsProvider.future),
      ref.read(publicSessionsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldShell(
      items: [
        NavbarItem(
          icon: FluentIcons.people_20_regular,
          filledIcon: FluentIcons.people_20_filled,
          titleText: 'Focus Sessions',
          fab: DefaultFabButton(
            heroTag: HeroTags.newSharedSessionFABTag,
            label: 'New Session',
            icon: FluentIcons.add_20_filled,
            onPressed: () => showCreateSessionSheet(context),
          ),
          actions: [
            // The code is the primary join path — it is what a host shares and
            // what a QR opens — so it gets the more prominent affordance.
            IconButton(
              tooltip: 'Join with a code',
              icon: const Icon(FluentIcons.key_20_regular),
              onPressed: () => showJoinByCodeSheet(context),
            ),
            IconButton(
              tooltip: 'Join by ID',
              icon: const Icon(FluentIcons.qr_code_20_regular),
              onPressed: () => showJoinByIdSheet(context),
            ),
          ],
          sliverBody: DefaultRefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
                    child: Center(
                      child: DefaultSegmentedButton<SessionTab>(
                        selected: _tab,
                        onChanged: (value) => setState(() => _tab = value),
                        segments: const [
                          SegmentItem(
                            value: SessionTab.mine,
                            label: 'My Sessions',
                            icon: FluentIcons.people_20_regular,
                            filledIcon: FluentIcons.people_20_filled,
                          ),
                          SegmentItem(
                            value: SessionTab.discover,
                            label: 'Discover',
                            icon: FluentIcons.globe_search_20_regular,
                            filledIcon: FluentIcons.globe_search_20_filled,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_tab == SessionTab.mine)
                  ..._mySessionsSlivers()
                else
                  ..._discoverSlivers(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // My Sessions
  // -------------------------------------------------------------------------

  List<Widget> _mySessionsSlivers() {
    final sessionsAsync = ref.watch(userSessionsProvider);

    return sessionsAsync.when(
      loading: () => [_loadingSliver()],
      error: (error, _) => [
        SliverToBoxAdapter(
          child: SessionErrorView(
            message: error.toString(),
            onRetry: _refresh,
          ),
        ),
      ],
      data: (sessions) {
        if (sessions.isEmpty) {
          return [
            SliverToBoxAdapter(
              child: SessionEmptyView(
                icon: FluentIcons.people_20_regular,
                title: 'No active sessions',
                subtitle: 'Create a focus session to stay accountable with '
                    'friends and family.',
                actionLabel: 'Create Session',
                onAction: () => showCreateSessionSheet(context),
              ),
            ),
            ..._footerSlivers,
          ];
        }

        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
              child: ModernSectionHeader(
                title: 'Your Sessions',
                subtitle: _plural(sessions.length, 'active session',
                    'active sessions'),
                trailing: _CountPill(count: sessions.length),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
              child: SurfaceCard(
                padding: EdgeInsets.zero,
                elevation: 0,
                child: Column(
                  children: [
                    for (final session in sessions) ...[
                      MySessionCard(
                        session: session,
                        margin: EdgeInsets.zero,
                        onTap: () => _openSession(session),
                      ),
                      if (session != sessions.last)
                        const Divider(height: 0.5, indent: 56),
                    ],
                  ],
                ),
              ),
            ),
          ),
          ..._footerSlivers,
        ];
      },
    );
  }

  /// Opens the session's lobby.
  ///
  /// The lobby, not the read-only detail view, is the right destination: it is
  /// where readiness is set and where the host starts the synchronised run, and
  /// it is where every join path (code, ID, deep link) lands. The detail screen
  /// remains the place a session is inspected when its lobby has closed.
  void _openSession(SharedSession session) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SessionLobbyScreen(sessionId: session.id),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Discover
  // -------------------------------------------------------------------------

  List<Widget> _discoverSlivers() {
    final publicAsync = ref.watch(publicSessionsProvider);

    return publicAsync.when(
      loading: () => [_loadingSliver()],
      error: (error, _) => [
        SliverToBoxAdapter(
          child: SessionErrorView(
            message: error.toString(),
            onRetry: _refresh,
          ),
        ),
      ],
      data: (sessions) {
        if (sessions.isEmpty) {
          return [
            SliverToBoxAdapter(
              child: SessionEmptyView(
                icon: FluentIcons.globe_search_20_regular,
                title: 'No public sessions',
                subtitle: 'Be the first to open a public focus session — it '
                    'will show up here for everyone.',
                actionLabel: 'Create Session',
                onAction: () => showCreateSessionSheet(context),
              ),
            ),
            ..._footerSlivers,
          ];
        }

        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
              child: ModernSectionHeader(
                title: 'Open Groups',
                subtitle: _plural(sessions.length, 'public session',
                    'public sessions'),
                trailing: _CountPill(count: sessions.length),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
              child: Column(
                children: [
                  for (final entry in sessions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.md),
                      child: DiscoverSessionCard(data: entry),
                    ),
                ],
              ),
            ),
          ),
          ..._footerSlivers,
        ];
      },
    );
  }

  // -------------------------------------------------------------------------
  // Shared pieces
  // -------------------------------------------------------------------------

  static List<Widget> get _footerSlivers => const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(4, 0, 4, 16),
            child: _HowSessionsWorkCard(),
          ),
        ),
        SliverTabsBottomPadding(),
      ];

  Widget _loadingSliver() => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 64),
          child: Center(child: CircularProgressIndicator()),
        ),
      );

  String _plural(int count, String singular, String plural) =>
      count == 1 ? '1 $singular' : '$count $plural';
}

/// Small count chip shown on the right of a section header.
class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: StyledText(
        '$count',
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }
}

/// Explains what a shared session does, in the app's standard dashboard-card
/// shape.
class _HowSessionsWorkCard extends StatelessWidget {
  const _HowSessionsWorkCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModernDashboardCard(
      title: 'How Sessions Work',
      subtitle: 'Focus together, stay accountable',
      icon: const Icon(FluentIcons.people_community_20_filled),
      accentColor: colorScheme.primary,
      children: [
        _infoRow(
          context,
          icon: FluentIcons.add_circle_20_regular,
          title: 'Create or join a group',
          body: 'Share the session ID, or open a public one from Discover.',
        ),
        const SizedBox(height: Spacing.md),
        _infoRow(
          context,
          icon: FluentIcons.eye_20_regular,
          title: 'See who is focusing',
          body: 'Members show as Focused while they are in the session.',
        ),
        const SizedBox(height: Spacing.md),
        _infoRow(
          context,
          icon: FluentIcons.flag_20_regular,
          title: 'Finish together',
          body: 'The owner completes the session and everyone earns points.',
        ),
      ],
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StyledText(
                title,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              StyledText(
                body,
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.35,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
