// Copyright (c) 2026 NLP digitox

/// Hard limits that apply to every focus group.
///
/// These numbers appear in two layers that must agree:
///   * the client model and the group screens, which render "3/25" and refuse
///     an over-cap invite before it is sent, and
///   * `firestore.rules`, which refuses the same write even if the client is
///     modified.
///
/// A rules file cannot import Dart, so `firestore.rules` repeats the literal
/// member cap where it matters. Change [maxMembersPerGroup] first, the rule
/// second.
class GroupLimits {
  const GroupLimits._();

  /// Most people allowed in one group, the owner included.
  ///
  /// A group is a *durable* room: its member list is what the group session
  /// start reads, and every member is a row in a Firestore subcollection.
  /// Twenty-five covers a class, a team or an extended family while keeping
  /// the roster readable on one screen.
  static const int maxMembersPerGroup = 25;

  /// The smallest meaningful group: the owner on their own.
  static const int minMembersPerGroup = 1;

  /// How many groups one person may belong to.
  ///
  /// The groups list is built from the membership collection group query, so
  /// this bounds the query fan-out as much as it bounds the UI. Join is
  /// refused client-side with [tooManyGroupsMessage] past this.
  static const int maxGroupsPerUser = 25;

  /// Shortest accepted group name.
  static const int minNameLength = 3;

  /// Longest accepted group name — chosen so the name fits one line in the
  /// group card header at every supported text scale.
  static const int maxNameLength = 40;

  /// Longest accepted group description.
  static const int maxDescriptionLength = 200;

  /// How many upcoming scheduled sessions one group may hold.
  ///
  /// The schedule is a list on the group screen, not a calendar: past roughly
  /// this many entries it stops being something anyone reads.
  static const int maxScheduleEntriesPerGroup = 30;

  /// How far ahead a session may be scheduled.
  static const Duration maxScheduleHorizon = Duration(days: 90);

  /// How soon a scheduled session may start. Below this the reminder would be
  /// scheduled for a moment that has already passed.
  static const Duration minScheduleLead = Duration(minutes: 5);

  /// How long a group invite code stays usable.
  ///
  /// Longer than a single session's code on purpose: a group is meant to be
  /// joined once and kept, and a code that expires in a day makes inviting a
  /// distant friend a chore.
  static const Duration inviteLifetime = Duration(days: 7);

  /// Most reminders the notification service will hold at once.
  ///
  /// `flutter_local_notifications` maps each pending notification to an OS
  /// alarm; an unbounded schedule is a battery and an OS-quota problem.
  static const int maxPendingReminders = 32;

  /// How long before a scheduled session its reminder fires.
  static const Duration reminderLead = Duration(minutes: 10);

  /// Forces [requested] into the supported name length.
  static String normalizeName(String requested) {
    final trimmed = requested.trim();
    if (trimmed.length <= maxNameLength) return trimmed;
    return trimmed.substring(0, maxNameLength);
  }

  /// Whether [name] is long enough to be a group name.
  static bool isValidName(String name) =>
      name.trim().length >= minNameLength;

  /// Forces [requested] into the supported member range.
  ///
  /// Anything that is not a usable limit — `0`, a negative, null, or a number
  /// an edited client made up — becomes [maxMembersPerGroup] rather than
  /// "unlimited", so no code path can opt a group out of its bound.
  static int normalizeMaxMembers(int? requested) {
    if (requested == null || requested < minMembersPerGroup) {
      return maxMembersPerGroup;
    }
    return requested > maxMembersPerGroup ? maxMembersPerGroup : requested;
  }

  /// The user-facing sentence for a group that is already at its cap.
  ///
  /// Lives beside the number it quotes so the member list, the join failure
  /// and the invite panel cannot drift apart in wording.
  static String get fullGroupMessage =>
      'This group is full — all $maxMembersPerGroup seats are taken. '
      'Ask the owner to make room or start a second group.';

  /// The user-facing sentence for someone who has joined too many groups.
  static String get tooManyGroupsMessage =>
      'You are already in $maxGroupsPerUser groups. Leave one before joining '
      'another.';
}
