import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/config/app_themes.dart';
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
void main() {
  final now = DateTime(2026, 1, 5, 9, 30);

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
        expect(find.text('4 members • Reading'), findsOneWidget);
        expect(find.text('Join'), findsOneWidget);
      });
    });

    group('Session presentational widgets ($mode theme)', () {
      Widget wrap(Widget child) => Scaffold(
            body: SingleChildScrollView(
              child: Padding(padding: const EdgeInsets.all(16), child: child),
            ),
          );

      testWidgets('MySessionCard renders name, presence and theme',
          (tester) async {
        await pump(
          tester,
          wrap(MySessionCard(session: session, onTap: () {})),
          dark: dark,
        );

        expect(find.text('Morning Study Group'), findsOneWidget);
        expect(find.text('1 focusing now'), findsOneWidget);
        expect(find.text('2'), findsOneWidget); // member count badge
      });

      testWidgets('DiscoverSessionCard renders its metadata',
          (tester) async {
        await pump(
          tester,
          wrap(const DiscoverSessionCard(data: publicEntry)),
          dark: dark,
        );

        expect(find.text('Open Reading Room'), findsOneWidget);
        expect(find.text('4 members • Reading'), findsOneWidget);
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

      testWidgets('CreateSessionSheet renders its fields', (tester) async {
        await pump(
          tester,
          const Scaffold(body: CreateSessionSheet()),
          dark: dark,
        );

        expect(find.text('New Session'), findsOneWidget);
        expect(find.text('Session name'), findsOneWidget);
        expect(find.text('Public session'), findsOneWidget);
        expect(find.text('Create Session'), findsOneWidget);
      });

      testWidgets('JoinByIdSheet renders its fields', (tester) async {
        await pump(
          tester,
          const Scaffold(body: JoinByIdSheet()),
          dark: dark,
        );

        expect(find.text('Join by ID'), findsOneWidget);
        expect(find.text('Session ID'), findsOneWidget);
        expect(find.text('Join Session'), findsOneWidget);
      });
    });
  }
}
