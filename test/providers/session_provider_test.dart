import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/providers/session_provider.dart';

/// Guards why the shared-session **action** providers must not `autoDispose`.
///
/// Every one of them is driven from call sites that `ref.read(...notifier)` and
/// never watch the provider — the "Join" button on a Discover card
/// (`session_cards.dart`) and "join the run" on a group
/// (`group_detail_screen.dart`) both work that way. A listener that *does*
/// watch the same provider (the join sheets do, for their busy state) is
/// removed the moment its sheet closes, and an `autoDispose` provider is then
/// disposed while the join is still in flight; the write that resumes after the
/// network `await` throws
/// "Tried to use JoinSessionByIdNotifier after 'dispose' was called".
///
/// These notifiers hold nothing but a `SessionService` reference, so keeping
/// them alive for the container's lifetime costs nothing. This test pins that:
/// if someone re-adds `autoDispose`, it fails with the offending provider named.
///
/// The live/stream providers (`sessionStreamProvider`,
/// `sessionMembersStreamProvider`, `sessionTickerProvider`,
/// `sessionPhaseProvider`, `sessionRemainingSecProvider`) are *deliberately*
/// still `autoDispose` — they own Realtime Database listeners and must release
/// them when their screen goes away — so they are not asserted here.
void main() {
  /// `autoDispose` providers report a runtime type prefixed `AutoDispose…`,
  /// e.g. `AutoDisposeStateNotifierProvider<JoinSessionByIdNotifier, …>`.
  /// Asserting on that avoids guessing at Riverpod's class hierarchy.
  void expectKeptAlive(Object provider, String name) {
    expect(
      provider.runtimeType.toString(),
      isNot(startsWith('AutoDispose')),
      reason: '$name is read from call sites that never watch it, so it must '
          'stay alive for the container instead of auto-disposing mid-join',
    );
  }

  group('session action providers stay alive for the container', () {
    test('create / join / leave / complete', () {
      expectKeptAlive(createSessionProvider, 'createSessionProvider');
      expectKeptAlive(joinSessionProvider, 'joinSessionProvider');
      expectKeptAlive(leaveSessionProvider, 'leaveSessionProvider');
      expectKeptAlive(completeSessionProvider, 'completeSessionProvider');
    });

    test('join-by-id / join-by-code / lobby actions', () {
      expectKeptAlive(joinByIdProvider, 'joinByIdProvider');
      expectKeptAlive(joinByCodeProvider, 'joinByCodeProvider');
      expectKeptAlive(sessionLobbyProvider, 'sessionLobbyProvider');
    });
  });
}
