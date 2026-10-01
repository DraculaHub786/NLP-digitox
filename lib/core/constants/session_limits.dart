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
