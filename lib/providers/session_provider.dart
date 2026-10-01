// Session provider for state management with Riverpod

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/enums/session_phase.dart';
import 'package:nlp_digitox/core/services/session_clock.dart';
import 'package:nlp_digitox/core/services/session_service.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';

/// Session service provider
final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService.instance;
});

/// User's sessions provider
final userSessionsProvider = FutureProvider<List<SharedSession>>((ref) async {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.getUserSessions();
});

/// Single session provider (requires sessionId).
///
/// A stream, not a future: a lobby that only reads once goes stale the moment
/// another member joins, marks ready or the host starts the run. `watchSession`
/// emits the whole document on every change, so the detail screen updates
/// itself without anyone invalidating this provider.
final sessionDetailProvider =
    StreamProvider.family<SharedSession?, String>((ref, sessionId) {
  return ref.watch(sessionServiceProvider).watchSession(sessionId);
});

/// Session members provider (requires sessionId)
final sessionMembersProvider = FutureProvider.family<List<SessionMember>, String>((ref, sessionId) async {
  final session = await ref.watch(sessionDetailProvider(sessionId).future);
  return session?.members ?? [];
});

/// Active members count provider (requires sessionId)
final activeMembersCountProvider = FutureProvider.family<int, String>((ref, sessionId) async {
  final members = await ref.watch(sessionMembersProvider(sessionId).future);
  return members.where((m) => m.isActive).length;
});

/// Create session notifier
class CreateSessionNotifier extends StateNotifier<AsyncValue<SharedSession?>> {
  final SessionService _sessionService;

  // Starts as idle data (null), not loading — loading should only begin
  // once the user actually taps Create. Starting in .loading() disabled
  // the Create button from the moment the sheet opened, since the button
  // is gated on `createState.isLoading`.
  CreateSessionNotifier(this._sessionService) : super(const AsyncValue.data(null));

  /// [maxMembers] is a request, not a guarantee: the service and the server
  /// rules both clamp it to
  /// [SessionLimits.maxMembersPerSession]. Leaving it null asks for the cap.
  Future<void> createSession({
    required String name,
    String? description,
    String? theme,
    bool isPublic = false,
    int? maxMembers,
    SessionSettings? settings,
    String type = 'study',
    int? durationSec,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _sessionService.createSession(
      name: name,
      description: description,
      theme: theme,
      isPublic: isPublic,
      maxMembers: maxMembers,
      settings: settings,
      type: type,
      durationSec: durationSec,
    ));
  }
}

/// Create session provider
final createSessionProvider =
    StateNotifierProvider.autoDispose<CreateSessionNotifier,
        AsyncValue<SharedSession?>>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return CreateSessionNotifier(sessionService);
});

/// Join session notifier
class JoinSessionNotifier extends StateNotifier<AsyncValue<void>> {
  final SessionService _sessionService;

  JoinSessionNotifier(this._sessionService) : super(const AsyncValue.data(null));

  Future<void> joinSession({
    required String sessionId,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _sessionService.joinSession(
      sessionId: sessionId,
      displayName: displayName,
    ));
  }
}

/// Join session provider
final joinSessionProvider = StateNotifierProvider.autoDispose<JoinSessionNotifier, AsyncValue<void>>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return JoinSessionNotifier(sessionService);
});

/// Leave session notifier
class LeaveSessionNotifier extends StateNotifier<AsyncValue<void>> {
  final SessionService _sessionService;

  LeaveSessionNotifier(this._sessionService) : super(const AsyncValue.data(null));

  Future<void> leaveSession(String sessionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _sessionService.leaveSession(sessionId: sessionId));
  }
}

/// Leave session provider
final leaveSessionProvider = StateNotifierProvider.autoDispose<LeaveSessionNotifier, AsyncValue<void>>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return LeaveSessionNotifier(sessionService);
});

/// Complete session notifier — owner-only "finish this session" action.
///
/// On success it invalidates [userSessionsProvider] and the session's own
/// detail provider, because completing a session flips `isActive` to false and
/// the finished session must drop out of the active list immediately.
class CompleteSessionNotifier
    extends StateNotifier<AsyncValue<SharedSession?>> {
  final SessionService _sessionService;
  final Ref _ref;

  CompleteSessionNotifier(this._sessionService, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> completeSession(String sessionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _sessionService.completeSession(sessionId: sessionId),
    );

    if (state.hasValue) {
      // The detail and member providers are streams now and update
      // themselves; only the list of the user's sessions needs a refresh.
      _ref.invalidate(userSessionsProvider);
    }
  }
}

/// Complete session provider
final completeSessionProvider = StateNotifierProvider.autoDispose<
    CompleteSessionNotifier, AsyncValue<SharedSession?>>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return CompleteSessionNotifier(sessionService, ref);
});

/// Public sessions provider — for browse-and-join flow
final publicSessionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.getPublicSessions();
});

/// Join session by ID notifier
class JoinSessionByIdNotifier extends StateNotifier<AsyncValue<void>> {
  final SessionService _sessionService;

  JoinSessionByIdNotifier(this._sessionService)
      : super(const AsyncValue.data(null));

  Future<void> joinById({
    required String sessionId,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _sessionService.joinSession(
          sessionId: sessionId,
          displayName: displayName,
        ));
  }
}

/// Join session by ID provider
final joinByIdProvider =
    StateNotifierProvider.autoDispose<JoinSessionByIdNotifier, AsyncValue<void>>(
        (ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return JoinSessionByIdNotifier(sessionService);
});
// =============================================================================
// Live (Realtime Database) providers — synchronised sessions.
//
// Everything above this line is the older FutureProvider surface the existing
// screens and tests use. The providers below are the ones every synchronised
// screen reads: they stream from RTDB so a lobby updates the instant a member
// joins, and they derive the shared phase from the *server* clock rather than
// a local wall clock.
// =============================================================================

/// The app-wide [SessionClock] — the single source of "now" for every timer.
///
/// `start()` is idempotent, so watching this from any screen is enough to make
/// sure the `.info/serverTimeOffset` subscription is live before a run begins.
final sessionClockProvider = Provider<SessionClock>((ref) {
  final clock = SessionClock.instance;
  clock.start();
  return clock;
});

/// A live stream of one session, or `null` once it stops existing.
final sessionStreamProvider = StreamProvider.autoDispose
    .family<SharedSession?, String>((ref, sessionId) {
  return ref.watch(sessionServiceProvider).watchSession(sessionId);
});

/// A live stream of the member map for one session.
final sessionMembersStreamProvider = StreamProvider.autoDispose
    .family<List<SessionMember>, String>((ref, sessionId) {
  return ref.watch(sessionServiceProvider).watchMembers(sessionId);
});

/// One-second ticks of the **server** clock, used to drive countdowns.
final sessionTickerProvider = StreamProvider.autoDispose<int>((ref) {
  return ref.watch(sessionClockProvider).ticks();
});

/// The derived lifecycle phase for a session, recomputed every tick.
///
/// Deliberately derived and never stored: the host writes exactly one server
/// timestamp on Start, and every device — the host's own included — works out
/// "countdown", "running" and "finished" from that value. This is what keeps
/// devices whose wall clocks disagree within a second of each other.
final sessionPhaseProvider =
    Provider.autoDispose.family<SessionPhase, String>((ref, sessionId) {
  final session = ref.watch(sessionStreamProvider(sessionId)).valueOrNull;
  final clock = ref.watch(sessionClockProvider);

  // Prefer the latest tick so the phase flips at the right second, but fall
  // back to a direct read so the very first frame — before a tick has been
  // delivered — is still correct rather than defaulting to the lobby.
  final nowMs =
      ref.watch(sessionTickerProvider).valueOrNull ?? clock.nowMs();

  return session?.phaseAt(nowMs) ?? SessionPhase.lobby;
});

/// Seconds left in the run (or countdown), recomputed every tick.
///
/// Null in the lobby and after `endAt`.
final sessionRemainingSecProvider =
    Provider.autoDispose.family<int?, String>((ref, sessionId) {
  final session = ref.watch(sessionStreamProvider(sessionId)).valueOrNull;
  if (session == null) return null;

  final clock = ref.watch(sessionClockProvider);
  final nowMs =
      ref.watch(sessionTickerProvider).valueOrNull ?? clock.nowMs();

  return session.remainingSecAt(nowMs) ??
      session.countdownRemainingSecAt(nowMs);
});

/// Joins the session named by an invite code and returns its id so the caller
/// can navigate to the lobby.
class JoinByCodeNotifier extends StateNotifier<AsyncValue<String?>> {
  JoinByCodeNotifier(this._sessionService)
      : super(const AsyncValue.data(null));

  final SessionService _sessionService;

  Future<String?> joinByCode({
    required String code,
    required String displayName,
    String? photoUrl,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _sessionService.joinByCode(
          rawCode: code,
          displayName: displayName,
          photoUrl: photoUrl,
        ));
    return state.valueOrNull;
  }
}

/// Join-by-invite-code provider.
final joinByCodeProvider = StateNotifierProvider.autoDispose<
    JoinByCodeNotifier, AsyncValue<String?>>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return JoinByCodeNotifier(sessionService);
});

// -----------------------------------------------------------------------------
// Lobby actions
// -----------------------------------------------------------------------------

/// The member actions a lobby offers: ready toggle, host start/cancel/kick.
///
/// One notifier for all of them so a screen can show a single busy state and
/// surface a single error, rather than juggling four separate providers for
/// what is, from the user's side, one set of buttons.
class SessionLobbyNotifier extends StateNotifier<AsyncValue<void>> {
  SessionLobbyNotifier(this._sessionService, this._ref)
      : super(const AsyncValue.data(null));

  final SessionService _sessionService;
  final Ref _ref;

  Future<void> setReady({
    required String sessionId,
    required bool ready,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _sessionService.setReady(sessionId: sessionId, ready: ready),
    );
  }

  Future<void> start(String sessionId, {int? durationSec}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _sessionService.startSession(
        sessionId: sessionId,
        durationSec: durationSec,
      ),
    );
  }

  Future<void> cancel(String sessionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _sessionService.cancelSession(sessionId: sessionId),
    );
    if (!state.hasError) {
      _ref.invalidate(userSessionsProvider);
    }
  }

  Future<void> kick({
    required String sessionId,
    required String memberId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _sessionService.kickMember(
        sessionId: sessionId,
        memberId: memberId,
      ),
    );
  }

  Future<void> leave(String sessionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _sessionService.leaveSession(sessionId: sessionId),
    );
    if (!state.hasError) {
      _ref.invalidate(userSessionsProvider);
    }
  }
}

/// Lobby action provider.
final sessionLobbyProvider = StateNotifierProvider.autoDispose<
    SessionLobbyNotifier, AsyncValue<void>>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return SessionLobbyNotifier(sessionService, ref);
});
