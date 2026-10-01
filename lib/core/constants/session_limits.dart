// Copyright (c) 2026 NLP digitox

/// Hard limits that apply to every shared focus session.
///
/// These numbers appear in three layers that must agree:
///   * the client model ([SharedSession.maxMembers]), which renders "3/10",
///   * `SessionService`, which refuses a join before it ever reaches the
///     server, and
///   * `database.rules.json`, which refuses it even if the client is modified.
///
/// A rules file cannot import Dart, so `database.rules.json` repeats the
/// literal `10`. Change [maxMembersPerSession] first, the rule second.
class SessionLimits {
  const SessionLimits._();

  /// Most people allowed in one shared session, the owner included.
  ///
  /// Every member is a live presence heartbeat plus a fan-out of the same
  /// session write, so an unbounded room is both a load and a moderation
  /// problem. Ten covers a study group or a family without either.
  static const int maxMembersPerSession = 10;

  /// The smallest meaningful cap: the owner on their own.
  static const int minMembersPerSession = 1;

  /// Shortest run a synchronised session may be set to.
  ///
  /// Five minutes is the point below which a "focus session" is not one. The
  /// same bound is repeated in `database.rules.json` on `durationSec`, so an
  /// edited client cannot start a one-second run and still claim completion.
  static const int minDurationSec = 300;

  /// Longest run a synchronised session may be set to — four hours.
  ///
  /// Past this the apps stay blocked long after anyone stopped paying
  /// attention, and a forgotten session is indistinguishable from a curated
  /// one. Repeated in the security rules.
  static const int maxDurationSec = 14400;

  /// Default run length: 25 minutes.
  static const int defaultDurationSec = 1500;

  /// Shortest shared countdown.
  static const int minCountdownSec = 3;

  /// Longest shared countdown. Long enough to switch apps, short enough that
  /// nobody assumes the start failed.
  static const int maxCountdownSec = 30;

  /// Default shared countdown.
  static const int defaultCountdownSec = 5;

  /// How many focus breaks a member may take and still be credited.
  ///
  /// Not zero: Android kills backgrounded apps routinely, and a run that
  /// survives one genuine interruption deserves credit. Past this it stops
  /// looking like an interruption and starts looking like leaving. The same
  /// number is repeated in `database.rules.json` on `breaks`.
  static const int maxBreaksPerRun = 2;

  /// Forces [requested] seconds into the supported run range.
  static int normalizeDurationSec(int? requested) {
    if (requested == null) return defaultDurationSec;
    if (requested < minDurationSec) return minDurationSec;
    if (requested > maxDurationSec) return maxDurationSec;
    return requested;
  }

  /// Forces [requested] into the supported range.
  ///
  /// Anything that is not a usable limit — `0`, a negative, null, a value from
  /// a session created before the cap existed, or a number an edited client
  /// made up — becomes [maxMembersPerSession] rather than "unlimited", so no
  /// code path can opt a session out of its bound.
  static int normalizeMaxMembers(int? requested) {
    if (requested == null || requested < minMembersPerSession) {
      return maxMembersPerSession;
    }
    return requested > maxMembersPerSession ? maxMembersPerSession : requested;
  }

  /// The user-facing sentence for a room that is already at its cap.
  ///
  /// Lives beside the number it quotes so the Discover card, the join failure
  /// and the service cannot drift apart in wording. It deliberately promises
  /// nothing about a waitlist — the only remedy is a new session.
  /// Exposed as a getter (not a method) so call sites read as a value.
  static String get fullSessionMessage =>
      'This session is full — all $maxMembersPerSession seats are taken. '
      'Ask the owner to start a new one.';
}
