import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';
import 'package:nlp_digitox/providers/system/digitox_settings_provider.dart'
    show digitoxSettingsProvider;
import 'package:nlp_digitox/providers/session_provider.dart';

/// Shared Focus Sessions screen with glassmorphic design.
/// Two tabs: My Sessions and Discover (public sessions to join).
class SessionsListScreen extends ConsumerStatefulWidget {
  const SessionsListScreen({super.key});

  @override
  ConsumerState<SessionsListScreen> createState() => _SessionsListScreenState();
}

class _SessionsListScreenState extends ConsumerState<SessionsListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.08),
                  theme.colorScheme.surface,
                  theme.colorScheme.surface,
                ],
              ),
            ),
          ),

          // Main content
          NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                pinned: true,
                expandedHeight: 140,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsets.only(left: 20, bottom: 56),
                  title: Text(
                    'Focus Sessions',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.12),
                          theme.colorScheme.surface,
                        ],
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: _GlassTabBar(controller: _tabController),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Join by ID',
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    onPressed: () => _showJoinByIdSheet(context),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _MySessionsTab(onCreateTap: () => _showCreateDialog(context, ref)),
                const _DiscoverTab(),
              ],
            ),
          ),

          // FAB
          Positioned(
            bottom: 24,
            right: 20,
            child: _GlassFAB(
              icon: Icons.add_rounded,
              label: 'New Session',
              onPressed: () => _showCreateDialog(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateSessionSheet(),
    );
  }

  void _showJoinByIdSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JoinByIdSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// My Sessions Tab
// ---------------------------------------------------------------------------

class _MySessionsTab extends ConsumerWidget {
  final VoidCallback onCreateTap;
  const _MySessionsTab({required this.onCreateTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(userSessionsProvider);

    return sessionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(message: e.toString()),
      data: (sessions) {
        if (sessions.isEmpty) {
          return _EmptyView(
            icon: Icons.group_rounded,
            title: 'No active sessions',
            subtitle: 'Create a focus session to stay accountable with friends.',
            actionLabel: 'Create Session',
            onAction: onCreateTap,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: sessions.length,
          itemBuilder: (ctx, i) =>
              _SessionCard(session: sessions[i]).animate(
            delay: Duration(milliseconds: 60 * i),
          ).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Discover Tab
// ---------------------------------------------------------------------------

class _DiscoverTab extends ConsumerWidget {
  const _DiscoverTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicAsync = ref.watch(publicSessionsProvider);

    return publicAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(message: e.toString()),
      data: (sessions) {
        if (sessions.isEmpty) {
          return _EmptyView(
            icon: Icons.explore_rounded,
            title: 'No public sessions',
            subtitle: 'Be the first to create a public focus session!',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: sessions.length,
          itemBuilder: (ctx, i) {
            final s = sessions[i];
            return _PublicSessionCard(data: s).animate(
              delay: Duration(milliseconds: 60 * i),
            ).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Session Card (My Sessions)
// ---------------------------------------------------------------------------

class _SessionCard extends StatelessWidget {
  final SharedSession session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SessionDetailScreen(sessionId: session.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDark ? Colors.white : theme.colorScheme.primary)
                      .withValues(alpha: 0.10),
                  (isDark ? Colors.white : theme.colorScheme.primary)
                      .withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (isDark ? Colors.white : theme.colorScheme.primary)
                    .withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar / member count
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          session.memberCount.toString(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              _StatusDot(isActive: session.activeMembers > 0),
                              const SizedBox(width: 6),
                              Text(
                                '${session.activeMembers} focused now',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                if (session.theme != null) ...[
                  const SizedBox(height: 12),
                  _ThemeChip(label: session.theme!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Public Session Card (Discover)
// ---------------------------------------------------------------------------

class _PublicSessionCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  const _PublicSessionCard({required this.data});

  @override
  ConsumerState<_PublicSessionCard> createState() =>
      _PublicSessionCardState();
}

class _PublicSessionCardState extends ConsumerState<_PublicSessionCard> {
  bool _joining = false;

  Future<void> _join() async {
    setState(() => _joining = true);
    try {
      // Use the app's configured username as the in-session display name
      // (falls back to 'Me' if somehow empty).
      final username =
          ref.read(digitoxSettingsProvider).username.trim();
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.data['name'] as String? ?? 'Session';
    final theme2 = widget.data['theme'] as String?;
    final memberCount = widget.data['memberCount'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.secondary.withValues(alpha: 0.10),
              theme.colorScheme.secondary.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.secondary.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.public_rounded,
                color: theme.colorScheme.secondary, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(
                    '$memberCount member${memberCount == 1 ? '' : 's'}${theme2 != null ? ' · $theme2' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            _joining
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : TextButton(
                    onPressed: _join,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.secondary,
                    ),
                    child: const Text('Join'),
                  ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Session Detail Screen
// ---------------------------------------------------------------------------

class SessionDetailScreen extends ConsumerWidget {
  final String sessionId;

  const SessionDetailScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessionAsync = ref.watch(sessionDetailProvider(sessionId));
    final membersAsync = ref.watch(sessionMembersProvider(sessionId));
    final leaveState = ref.watch(leaveSessionProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.08),
                  theme.colorScheme.surface,
                ],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: sessionAsync.maybeWhen(
                    data: (s) => Text(s?.name ?? 'Session'),
                    orElse: () => const Text('Session')),
              ),
              sessionAsync.when(
                loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator())),
                error: (e, _) => SliverFillRemaining(
                    child: _ErrorView(message: e.toString())),
                data: (session) {
                  if (session == null) {
                    return const SliverFillRemaining(
                        child: Center(child: Text('Session not found')));
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Stats row
                        Row(
                          children: [
                            _StatBubble(
                                value: '${session.memberCount}',
                                label: 'Members',
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            _StatBubble(
                                value: '${session.activeMembers}',
                                label: 'Active now',
                                color: Colors.green),
                            const SizedBox(width: 12),
                            _StatBubble(
                                value:
                                    session.isPublic ? 'Public' : 'Private',
                                label: 'Type',
                                color: theme.colorScheme.secondary),
                          ],
                        )
                            .animate()
                            .fadeIn(duration: 350.ms)
                            .slideY(begin: 0.04, end: 0),

                        if (session.theme != null) ...[
                          const SizedBox(height: 12),
                          _ThemeChip(label: session.theme!),
                        ],

                        if (session.description != null) ...[
                          const SizedBox(height: 16),
                          _GlassInfoBlock(text: session.description!),
                        ],

                        const SizedBox(height: 24),

                        Text(
                          'Members',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        // Members list
                        membersAsync.when(
                          loading: () => const Center(
                              child: CircularProgressIndicator()),
                          error: (e, _) =>
                              Text('Error: $e'),
                          data: (members) => Column(
                            children: members
                                .asMap()
                                .entries
                                .map((e) => _MemberTile(
                                      member: e.value,
                                      delay: Duration(
                                          milliseconds: 50 * e.key),
                                    ))
                                .toList(),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Leave button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: leaveState.isLoading
                                ? null
                                : () => _confirmLeave(
                                    context, ref, sessionId),
                            icon: leaveState.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.logout_rounded),
                            label: const Text('Leave Session'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade400,
                              side: BorderSide(
                                  color: Colors.red.shade400
                                      .withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmLeave(
      BuildContext context, WidgetRef ref, String sessionId) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Leave session?'),
        content: const Text(
            'Are you sure? If you are the owner, the session will be marked inactive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(leaveSessionProvider.notifier)
                  .leaveSession(sessionId);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom Sheets
// ---------------------------------------------------------------------------

class _CreateSessionSheet extends ConsumerStatefulWidget {
  const _CreateSessionSheet();

  @override
  ConsumerState<_CreateSessionSheet> createState() =>
      _CreateSessionSheetState();
}

class _CreateSessionSheetState
    extends ConsumerState<_CreateSessionSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPublic = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createState = ref.watch(createSessionProvider);

    return _BottomSheetWrapper(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Session',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Session Name',
                hintText: 'e.g., Morning Study Group',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _isPublic,
              onChanged: (v) => setState(() => _isPublic = v),
              title: const Text('Public Session'),
              subtitle: const Text('Allow anyone to discover and join'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: createState.isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: createState.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(createSessionProvider.notifier).createSession(
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          isPublic: _isPublic,
        );
    if (mounted) {
      Navigator.pop(context);
      ref.invalidate(userSessionsProvider);
    }
  }
}

class _JoinByIdSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_JoinByIdSheet> createState() => _JoinByIdSheetState();
}

class _JoinByIdSheetState extends ConsumerState<_JoinByIdSheet> {
  final _idCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final joinState = ref.watch(joinByIdProvider);

    return _BottomSheetWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Join by ID',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Enter the session ID shared by your group.',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 20),
          TextField(
            controller: _idCtrl,
            decoration: InputDecoration(
              labelText: 'Session ID',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14)),
              prefixIcon: const Icon(Icons.tag_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Your display name',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14)),
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: joinState.isLoading ? null : _join,
              style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: joinState.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Join Session'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _join() async {
    final id = _idCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (id.isEmpty || name.isEmpty) return;

    await ref.read(joinByIdProvider.notifier).joinById(
          sessionId: id,
          displayName: name,
        );

    final state = ref.read(joinByIdProvider);
    if (!mounted) return;

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${state.error}')),
      );
    } else if (!state.isLoading) {
      Navigator.pop(context);
      ref.invalidate(userSessionsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Joined session!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Small reusable widgets
// ---------------------------------------------------------------------------

class _GlassTabBar extends StatelessWidget {
  final TabController controller;
  const _GlassTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: TabBar(
        controller: controller,
        tabs: const [Tab(text: 'My Sessions'), Tab(text: 'Discover')],
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor:
            theme.colorScheme.onSurface.withValues(alpha: 0.5),
        indicator: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
    );
  }
}

class _GlassFAB extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _GlassFAB({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(
        begin: 0.3, end: 0, curve: Curves.easeOutBack);
  }
}

class _MemberTile extends StatelessWidget {
  final SessionMember member;
  final Duration delay;

  const _MemberTile({required this.member, required this.delay});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor:
                theme.colorScheme.primary.withValues(alpha: 0.15),
            child: Text(
              member.displayName.isNotEmpty
                  ? member.displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member.displayName,
              style:
                  theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          _StatusDot(isActive: member.isActive),
          const SizedBox(width: 6),
          Text(
            member.isActive ? 'Focused' : 'Away',
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  member.isActive ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    ).animate(delay: delay).fadeIn(duration: 250.ms);
  }
}

class _StatusDot extends StatelessWidget {
  final bool isActive;
  const _StatusDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.green : Colors.grey,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.4),
                  blurRadius: 6,
                )
              ]
            : null,
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  const _ThemeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBubble({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassInfoBlock extends StatelessWidget {
  final String text;
  const _GlassInfoBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
    );
  }
}

class _BottomSheetWrapper extends StatelessWidget {
  final Widget child;
  const _BottomSheetWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyView({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(
        begin: const Offset(0.94, 0.94), end: const Offset(1, 1));
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
