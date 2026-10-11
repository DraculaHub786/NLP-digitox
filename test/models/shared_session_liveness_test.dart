import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/enums/session_phase.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';

/// Guards "My Sessions".
///
/// A run that reaches its end by *time* is deliberately never written to the
/// database — `finished` is derived from `runStartAt + countdown + duration` so
/// that no device has to win a race to write it. The side effect is that
/// `isActive` stays `true` on such a session forever, so a list filtering on
/// `isActive` alone kept showing an ended run as live.
///
/// [SharedSession.isLiveAt] is the read-time predicate that fixes it. These
/// tests pin every phase, and in particular the expired-but-still-`isActive`
/// case that was the bug.
void main() {
  // A fixed origin so the arithmetic below is exact and clock-independent.
  final runStart = DateTime.utc(2026, 1, 1, 12);
  const countdownSec = 5;
  const durationSec = 60;

  /// The instant the shared timer actually starts.
  final startEffective = runStart.add(const Duration(seconds: countdownSec));

  /// The instant the run ends.
  final endAt = startEffective.add(const Duration(seconds: durationSec));

  int msAt(DateTime moment) => moment.millisecondsSinceEpoch;

  SharedSession running({
    bool isActive = true,
    DateTime? completedAt,
    SharedSessionState state = SharedSessionState.running,
  }) {
    return SharedSession(
      id: 's1',
      name: 'Deep work',
      ownerId: 'me',
      createdAt: runStart.subtract(const Duration(minutes: 1)),
      isActive: isActive,
      completedAt: completedAt,
      state: state,
      runStartAt: runStart,
      countdownSec: countdownSec,
      durationSec: durationSec,
    );
  }

  group('isLiveAt', () {
    test('a lobby is live — members can still join and the host can start', () {
      final lobby = SharedSession(
        id: 'lobby',
        name: 'Gathering',
        ownerId: 'me',
        createdAt: runStart,
        state: SharedSessionState.lobby,
      );

      expect(lobby.phaseAt(msAt(runStart)), SessionPhase.lobby);
      expect(lobby.isLiveAt(msAt(runStart)), isTrue);
    });

    test('the countdown is live', () {
      // Before startEffective.
      final at = runStart.add(const Duration(seconds: 1));
      expect(running().phaseAt(msAt(at)), SessionPhase.countdown);
      expect(running().isLiveAt(msAt(at)), isTrue);
    });

    test('the run itself is live', () {
      final at = startEffective.add(const Duration(seconds: 10));
      expect(running().phaseAt(msAt(at)), SessionPhase.running);
      expect(running().isLiveAt(msAt(at)), isTrue);
    });

    test('an expired run is NOT live, even though isActive is still true', () {
      // This is the bug: the end is derived, never written, so `isActive` is
      // still true here. The predicate must not trust it.
      final expired = running(isActive: true);

      expect(expired.isActive, isTrue,
          reason: 'the stored flag is the trap this test exists to catch');
      expect(expired.phaseAt(msAt(endAt)), SessionPhase.finished);
      expect(expired.isLiveAt(msAt(endAt)), isFalse);
      expect(expired.isLiveAt(msAt(endAt.add(const Duration(hours: 6)))),
          isFalse);
    });

    test('a cancelled run is not live', () {
      final cancelled = running(state: SharedSessionState.cancelled);
      final at = startEffective.add(const Duration(seconds: 10));

      expect(cancelled.phaseAt(msAt(at)), SessionPhase.cancelled);
      expect(cancelled.isLiveAt(msAt(at)), isFalse);
    });

    test('a completed run is not live', () {
      final completed = running(completedAt: endAt);

      expect(completed.phaseAt(msAt(runStart)), SessionPhase.finished);
      expect(completed.isLiveAt(msAt(runStart)), isFalse);
    });

    test('an open-ended run (durationSec 0) stays live while running', () {
      // No endAt is derivable, so the run cannot expire on its own.
      final openEnded = SharedSession(
        id: 'open',
        name: 'Open run',
        ownerId: 'me',
        createdAt: runStart,
        state: SharedSessionState.running,
        runStartAt: runStart,
        countdownSec: countdownSec,
        durationSec: 0,
      );

      final muchLater = startEffective.add(const Duration(hours: 3));
      expect(openEnded.endAt, isNull);
      expect(openEnded.isLiveAt(msAt(muchLater)), isTrue);
    });
  });
}
