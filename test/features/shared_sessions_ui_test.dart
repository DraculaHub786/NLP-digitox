import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/config/app_themes.dart';
import 'package:nlp_digitox/core/constants/session_limits.dart';
import 'package:nlp_digitox/features/shared_sessions/sessions_list_screen.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/create_session_sheet.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/join_by_id_sheet.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_cards.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_member_tile.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_state_views.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';
import 'package:nlp_digitox/providers/session_provider.dart';

/// Renders the redesigned shared-session surfaces in both the light and the
/// dark theme.
///
/// The point of these tests is regression safety on the redesign: the screens
/// must build without throwing and must render their real content in either
/// palette (the previous hand-rolled gradient cards were the thing that read
/// badly in both). They deliberately assert on structure/content rather than
/// pixels — pixel checks belong in golden tests.
///
/// The capacity assertions cover the 10-member cap as the user sees it: the
/// "used/total" seat count on both card styles, and the "Full" state that
/// replaces the Join action once a room is closed.
void main() {
  final now = DateTime(2026, 1, 5, 9, 30);

  SessionMember member(String userId) => SessionMember(
        userId: userId,
        displayName: userId,
        joinedAt: now,
        isActive: true,
        lastActive: now,
      );

  final session = SharedSession(
    id: 'session-1',
    name: 'Morning Study Group',
    description: 'Deep work before the day starts.',
    ownerId: 'me',
    isPublic: true,
    createdAt: now,
    theme: 'Deep Work',
    members: [
      SessionMember(
        userId: 'me',
        displayName: 'Afjal',
        joinedAt: now,
        isActive: true,
        lastActive: now,
      ),
      SessionMember(
        userId: 'friend',
        displayName: 'Ravi',
        joinedAt: now,
        isActive: false,
        lastActive: now,
      ),
    ],
    settings: const SessionSettings(sharedDailyLimit: 60),
  );

  const publicEntry = <String, dynamic>{
    'id': 'session-2',
    'name': 'Open Reading Room',
    'memberCount': 4,
    'theme': 'Reading',
  };

  /// A public entry with an explicit capacity, used for the full-room cases.
  Map<String, dynamic> publicEntryWithCap({
    required int memberCount,
    required int maxMembers,
  }) =>
      {
        'id': 'session-full',
        'name': 'Closed Room',
        'memberCount': memberCount,
        'maxMembers': maxMembers,
      };

  /// Pumps [child] inside a scope that fakes the session providers, themed
  /// with the app's real light or dark theme.
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    required bool dark,
    List<SharedSession> sessions = const [],
    List<Map<String, dynamic>> publicSessions = const [],
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSessionsProvider.overrideWith((ref) async => sessions),
          publicSessionsProvider.overrideWith((ref) async => publicSessions),
        ],
        child: MaterialApp(
          theme: dark
              ? AppTheme.darkTheme(isAmoled: false)
              : AppTheme.lightTheme(),
          home: child,
        ),
      ),
    );

    // Let the async providers resolve and the entrance animations run, without
    // pumpAndSettle (the shell's background image never fully settles).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';

    group('SessionsListScreen ($mode theme)', () {
      testWidgets('renders the active session with its details',
          (tester) async {
        await pump(
          tester,
          const SessionsListScreen(),
          dark: dark,
          sessions: [session],
        );

        expect(find.text('Focus Sessions'), findsOneWidget);
        expect(find.text('My Sessions'), findsOneWidget);
        expect(find.text('Discover'), findsOneWidget);
        expect(find.text('Your Sessions'), findsOneWidget);
        expect(find.text('Morning Study Group'), findsOneWidget);
        expect(find.text('1 focusing now'), findsOneWidget);
        expect(find.text('Deep Work'), findsOneWidget);
      });

      testWidgets('renders the empty state with its call to action',
          (tester) async {
        await pump(tester, const SessionsListScreen(), dark: dark);

        expect(find.text('No active sessions'), findsOneWidget);
        expect(find.text('Create Session'), findsOneWidget);
      });

      testWidgets('renders Discover with a joinable public session',
          (tester) async {
        await pump(
          tester,
          const SessionsListScreen(),
          dark: dark,
          publicSessions: [publicEntry],
        );

        await tester.tap(find.text('Discover'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Open Groups'), findsOneWidget);
        expect(find.text('Open Reading Room'), findsOneWidget);
        // The seat count is the whole point of the cap, so a card must show
        // "used/total" and not a bare member count.
        expect(find.text('4/10 members • Reading'), findsOneWidget);
        expect(find.text('Join'), findsOneWidget);
      });

      testWidgets('a full public session offers no Join action',
          (tester) async {
        await pump(
          tester,
          const SessionsListScreen(),
          dark: dark,
          publicSessions: [
            publicEntryWithCap(
              memberCount: SessionLimits.maxMembersPerSession,
              maxMembers: SessionLimits.maxMembersPerSession,
            ),
          ],
        );

        await tester.tap(find.text('Discover'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Closed Room'), findsOneWidget);
        expect(find.text('10/10 members'), findsOneWidget);
        // A closed room replaces the Join control with the reason, so nobody
        // can tap a button that can never succeed.
        expect(find.text('Full'), findsOneWidget);
        expect(find.text('Join'), findsNothing);
      });
    });

    group('Session presentational widgets ($mode theme)', () {
      Widget wrap(Widget child) => Scaffold(
            body: SingleChildScrollView(
              child: Padding(padding: const EdgeInsets.all(16), child: child),
            ),
          );

      testWidgets('MySessionCard renders name, presence and seat count',
          (tester) async {
        await pump(
          tester,
          wrap(MySessionCard(session: session, onTap: () {})),
          dark: dark,
        );

        expect(find.text('Morning Study Group'), findsOneWidget);
        expect(find.text('1 focusing now'), findsOneWidget);
        expect(find.text('2'), findsOneWidget); // member count badge
        // Two members against the default cap of ten.
        expect(find.text('2/10'), findsOneWidget);
      });

      testWidgets('MySessionCard flags a full room', (tester) async {
        final full = SharedSession(
          id: 'session-full',
          name: 'Full Room',
          ownerId: 'me',
          createdAt: now,
          maxMembers: 3,
          members: List.generate(3, (i) => member('user$i')),
        );

        await pump(
          tester,
          wrap(MySessionCard(session: full, onTap: () {})),
          dark: dark,
        );

        expect(find.text('Full'), findsOneWidget);
        expect(find.text('3/3'), findsNothing);
      });

      testWidgets('DiscoverSessionCard renders its capacity metadata',
          (tester) async {
        await pump(
          tester,
          wrap(const DiscoverSessionCard(data: publicEntry)),
          dark: dark,
        );

        expect(find.text('Open Reading Room'), findsOneWidget);
        expect(find.text('4/10 members • Reading'), findsOneWidget);
      });

      testWidgets('DiscoverSessionCard shows Full instead of Join at the cap',
          (tester) async {
        await pump(
          tester,
          wrap(
            DiscoverSessionCard(
              data: publicEntryWithCap(memberCount: 10, maxMembers: 10),
            ),
          ),
          dark: dark,
        );

        expect(find.text('10/10 members'), findsOneWidget);
        expect(find.text('Full'), findsOneWidget);
        expect(find.text('Join'), findsNothing);
      });

      testWidgets('SessionMemberTile marks the owner and the local user',
          (tester) async {
        await pump(
          tester,
          wrap(
            SessionMemberTile(
              member: session.members.first,
              isOwner: true,
              isMe: true,
            ),
          ),
          dark: dark,
        );

        expect(find.text('Afjal (you)'), findsOneWidget);
        expect(find.text('Owner • Focused'), findsOneWidget);
      });

      testWidgets('SessionEmptyView renders title, subtitle and action',
          (tester) async {
        var taps = 0;
        await pump(
          tester,
          wrap(
            SessionEmptyView(
              icon: Icons.people_rounded,
              title: 'No active sessions',
              subtitle: 'Create one to get started.',
              actionLabel: 'Create Session',
              onAction: () => taps++,
            ),
          ),
          dark: dark,
        );

        expect(find.text('No active sessions'), findsOneWidget);
        expect(find.text('Create one to get started.'), findsOneWidget);

        await tester.tap(find.text('Create Session'));
        expect(taps, 1);
      });

      testWidgets('SessionErrorView renders the message and retry',
          (tester) async {
        var retries = 0;
        await pump(
          tester,
          wrap(
            SessionErrorView(
              message: 'Could not reach the server.',
              onRetry: () => retries++,
            ),
          ),
          dark: dark,
        );

        expect(find.text('Could not reach the server.'), findsOneWidget);

        await tester.tap(find.text('Try again'));
        expect(retries, 1);
      });

      testWidgets('CreateSessionSheet renders its fields and the cap',
          (tester) async {
        await pump(
          tester,
          const Scaffold(body: CreateSessionSheet()),
          dark: dark,
        );

        expect(find.text('New Session'), findsOneWidget);
        expect(find.text('Session name'), findsOneWidget);
        expect(find.text('Public session'), findsOneWidget);
        expect(find.text('Create Session'), findsOneWidget);
        // The cap is stated before the session exists so the owner knows the
        // limit up front rather than discovering it when someone is refused.
        expect(find.text('Up to 10 people'), findsOneWidget);
      });

      testWidgets('JoinByIdSheet renders its fields and the cap hint',
          (tester) async {
        await pump(
          tester,
          const Scaffold(body: JoinByIdSheet()),
          dark: dark,
        );

        expect(find.text('Join a public session'), findsOneWidget);
        expect(find.text('Public session ID'), findsOneWidget);
        expect(find.text('Join Session'), findsOneWidget);
        expect(
          find.textContaining('Rooms hold up to 10 people'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Only open sessions can be joined by ID'),
          findsOneWidget,
        );
      });
    });
  }
}
