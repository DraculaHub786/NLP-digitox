// Session provider for state management with Riverpod

import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Single session provider (requires sessionId)
final sessionDetailProvider = FutureProvider.family<SharedSession?, String>((ref, sessionId) async {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.getSession(sessionId);
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
class CreateSessionNotifier extends StateNotifier<AsyncValue<SharedSession>> {
  final SessionService _sessionService;

  CreateSessionNotifier(this._sessionService) : super(const AsyncValue.loading());

  Future<void> createSession({
    required String name,
    String? description,
    String? theme,
    bool isPublic = false,
    int maxMembers = 0,
    SessionSettings? settings,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _sessionService.createSession(
      name: name,
      description: description,
      theme: theme,
      isPublic: isPublic,
      maxMembers: maxMembers,
      settings: settings,
    ));
  }
}

/// Create session provider
final createSessionProvider = StateNotifierProvider.autoDispose<CreateSessionNotifier, AsyncValue<SharedSession>>((ref) {
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
