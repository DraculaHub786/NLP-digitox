// Copyright (c) 2026 NLP digitox

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/constants/group_limits.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/utils/firestore_value_utils.dart';
import 'package:nlp_digitox/core/utils/invite_code.dart';
import 'package:nlp_digitox/models/focus_group.dart';
import 'package:nlp_digitox/models/group_member.dart';
import 'package:nlp_digitox/models/group_schedule_entry.dart';
import 'package:nlp_digitox/models/group_stats.dart';

/// A group failure whose message is already written for the user.
///
/// Thrown for the cases this service can describe precisely (unreachable
/// server, group gone, group full, bad invite). Anything else — most
/// importantly Firestore's own `permission-denied` — propagates as-is so the UI
/// layer can recognise it and decide what to say.
class GroupException implements Exception {
  final String message;

  const GroupException(this.message);

  @override
  String toString() => message;
}

/// Durable focus groups, backed by Cloud Firestore.
///
/// Firestore rather than the Realtime Database, unlike live sessions: a group
/// has to be *queried* ("every group I am in"), it outlives any single run, and
/// its roster and schedule are collections that a rules file can gate per
/// member. The live session a group starts still lives in RTDB — this service
/// only holds a pointer to it.
///
/// Firestore layout:
/// ```
/// groups/{gid}
///   name, description?, ownerId, visibility, maxMembers, createdAt
///   liveSession?: { sessionId, code?, startedAt }
/// groups/{gid}/members/{uid}
///   userId, displayName, photoUrl?, role, joinedAt, updatedAt
/// groups/{gid}/schedule/{entryId}
///   title, startsAt, durationSec, type, createdBy, createdAt
/// groups/{gid}/stats/{uid}                (written by the points webhook only)
///   sessionsCompleted, focusedSec, streak, updatedAt
/// group_invites/{code}                    (no collection read — codes cannot be listed)
///   gid, name, ownerName, createdAt, expiresAt
/// group_directory/{gid}                   (listed groups only)
///   name, description?, ownerId, maxMembers, updatedAt
/// users/{uid}/groups/{gid}: true          (this user's group index)
/// ```
class GroupService {
  /// Private constructor for the singleton.
  GroupService._();

  /// The single instance every screen and provider talks to.
  static final GroupService instance = GroupService._();

  static const String groupsCollection = 'groups';
  static const String membersSubcollection = 'members';
  static const String scheduleSubcollection = 'schedule';
  static const String statsSubcollection = 'stats';
  static const String invitesCollection = 'group_invites';
  static const String directoryCollection = 'group_directory';
  static const String usersCollection = 'users';
  static const String userGroupsSubcollection = 'groups';

  /// How long a Firestore round trip may take before the caller is told the
  /// server is unreachable.
  ///
  /// Without a bound, a dropped connection leaves the UI spinning with no error
  /// and no feedback at all.
  static const Duration _networkTimeout = Duration(seconds: 20);

  /// Whether [init] has run.
  bool _isInitialized = false;

  /// Whether Firestore is reachable. Set false when the plugin itself fails to
  /// come up, which is what happens in a widget test with no Firebase app.
  bool _isFirestoreAvailable = true;

  /// The in-flight [init] call, so simultaneous first uses share one attempt.
  Future<void>? _initFuture;

  /// Whether the service has been initialised.
  bool get isReady => _isInitialized;

  /// Whether groups can be reached at all.
  bool get isAvailable => _isFirestoreAvailable;

  /// The signed-in user id, or null.
  String? get currentUserId => FirebaseAuthService.instance.userId;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Prepares the service. Idempotent, and safe to call from anywhere.
  ///
  /// Mirroring [SessionService], this is called on demand rather than relying on
  /// startup: `initializeServicesAndSchedules()` runs late and is never repeated,
  /// and every sign-out clears the initialised flag, so a first-use call is the
  /// only reliable trigger.
  Future<void> init() async {
    if (_isInitialized) return;
    await (_initFuture ??= _init());
  }

  Future<void> _init() async {
    try {
      // Touching `FirebaseFirestore.instance` is what fails when no Firebase app
      // has been configured. Catching it here means every later call can simply
      // check [isAvailable] instead of each one re-throwing.
      FirebaseFirestore.instance;
      _isFirestoreAvailable = true;
      debugPrint('GroupService: Initialized successfully');
    } catch (e) {
      _isFirestoreAvailable = false;
      debugPrint('GroupService: Firestore unavailable, running inert: $e');
    } finally {
      _isInitialized = true;
    }
  }

  /// Guarantees the service is ready, initialising it on demand.
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    await (_initFuture ??= _init());
  }

  /// Runs [work], turning a timeout into a [GroupException] the UI can show.
  ///
  /// Every network call in this service goes through here, so no code path can
  /// hang forever with nothing on screen.
  Future<T> _onFirestore<T>(Future<T> Function() work) async {
    await _ensureInitialized();
    try {
      return await work().timeout(_networkTimeout);
    } on TimeoutException {
      throw const GroupException(
        'Could not reach the server. Check your connection and try again.',
      );
    } on FirebaseException catch (error) {
      // A missing composite index is a deployment mistake, not a user error,
      // and its raw message is a console link. Say something actionable instead
      // and leave the detail in the log.
      if (error.code == 'failed-precondition') {
        debugPrint('GroupService: Firestore precondition failed: $error');
        throw const GroupException(
          'Could not load this. Please try again in a moment.',
        );
      }
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Collection helpers
  // ---------------------------------------------------------------------------

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _groups =>
      _db.collection(groupsCollection);

  DocumentReference<Map<String, dynamic>> _groupDoc(String groupId) =>
      _groups.doc(groupId);

  CollectionReference<Map<String, dynamic>> _memberDocs(String groupId) =>
      _groupDoc(groupId).collection(membersSubcollection);

  CollectionReference<Map<String, dynamic>> _scheduleDocs(String groupId) =>
      _groupDoc(groupId).collection(scheduleSubcollection);

  CollectionReference<Map<String, dynamic>> _userGroupDocs(String userId) =>
      _db.collection(usersCollection).doc(userId).collection(
            userGroupsSubcollection,
          );

  /// Requires a signed-in user, throwing the same error everywhere.
  String _requireUserId() {
    final userId = currentUserId;
    if (userId == null) {
      throw StateError('User not authenticated');
    }
    return userId;
  }

  /// Requires a working Firestore connection.
  void _requireFirestore() {
    if (!_isFirestoreAvailable) {
      throw const GroupException(
        'Could not reach the server. Check your connection and try again.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  /// Reads one group, or null when it no longer exists.
  Future<FocusGroup?> getGroup(String groupId) async {
    await _ensureInitialized();
    if (!_isFirestoreAvailable) return null;
    final userId = currentUserId;

    try {
      final snapshot = await _onFirestore(() => _groupDoc(groupId).get());
      if (!snapshot.exists) return null;

      final count = await memberCount(groupId);
      final role = userId == null ? null : await roleOf(groupId, userId);

      return FocusGroup.fromSnapshot(
        snapshot,
        memberCount: count,
        myRole: role,
      );
    } catch (e) {
      debugPrint('GroupService: could not read group $groupId: $e');
      return null;
    }
  }

  /// A live stream of one group, or null once it stops existing.
  ///
  /// The member count and the caller's own role are read once and re-read on
  /// every group-document change rather than on a timer: neither changes
  /// without a write somewhere in this group, and the writes that do happen
  /// (rename, live-session pointer, visibility) all land on the document this
  /// stream watches.
  Stream<FocusGroup?> watchGroup(String groupId) {
    return _groupDoc(groupId).snapshots().asyncMap((snapshot) async {
      if (!snapshot.exists) return null;
      final userId = currentUserId;
      final count = await memberCount(groupId);
      final role = userId == null ? null : await roleOf(groupId, userId);
      return FocusGroup.fromSnapshot(
        snapshot,
        memberCount: count,
        myRole: role,
      );
    });
  }

  /// Reads the whole roster, ordered with the owner first and the rest by
  /// join time.
  Future<List<GroupMember>> getMembers(String groupId) async {
    await _ensureInitialized();
    if (!_isFirestoreAvailable) return const [];

    try {
      final snapshot =
          await _onFirestore(() => _memberDocs(groupId).get());
      final members = snapshot.docs.map(GroupMember.fromSnapshot).toList();
      members.sort(_byRoleThenJoinDate);
      return members;
    } catch (e) {
      debugPrint('GroupService: could not read members of $groupId: $e');
      return const [];
    }
  }

  /// A live stream of the roster.
  Stream<List<GroupMember>> watchMembers(String groupId) {
    return _memberDocs(groupId).snapshots().map((snapshot) {
      final members = snapshot.docs.map(GroupMember.fromSnapshot).toList();
      members.sort(_byRoleThenJoinDate);
      return members;
    });
  }

  /// Reads one member's membership document.
  Future<GroupMember?> getMember({
    required String groupId,
    required String userId,
  }) async {
    await _ensureInitialized();
    if (!_isFirestoreAvailable) return null;

    try {
      final snapshot = await _onFirestore(
        () => _memberDocs(groupId).doc(userId).get(),
      );
      return snapshot.exists ? GroupMember.fromSnapshot(snapshot) : null;
    } catch (e) {
      debugPrint('GroupService: could not read member $userId: $e');
      return null;
    }
  }

  /// The signed-in user's role in [groupId], or null when they are not a
  /// member.
  Future<GroupRole?> roleOf(String groupId, String userId) async {
    // Deliberately reads the membership document directly rather than calling
    // `getMember`, so a `getGroup` that is already inside `_onFirestore` does
    // not nest a second timeout wrapper around the same read.
    if (!_isFirestoreAvailable) return null;
    try {
      final snapshot = await _memberDocs(groupId)
          .doc(userId)
          .get()
          .timeout(_networkTimeout);
      if (!snapshot.exists) return null;
      return GroupRole.parse(snapshot.data()?['role']);
    } catch (e) {
      debugPrint('GroupService: could not read role for $userId: $e');
      return null;
    }
  }

  /// How many people are in the group.
  ///
  /// Uses Firestore's server-side count aggregation, which bills as one document
  /// read regardless of roster size — reading the whole subcollection to call
  /// `.length` would cost one read per member on every group the list screen
  /// shows.
  Future<int> memberCount(String groupId) async {
    if (!_isFirestoreAvailable) return 0;
    try {
      final aggregate = await _memberDocs(groupId)
          .count()
          .get()
          .timeout(_networkTimeout);
      return aggregate.count ?? 0;
    } catch (e) {
      debugPrint('GroupService: could not count members of $groupId: $e');
      return 0;
    }
  }

  /// Every group the signed-in user belongs to.
  ///
  /// Driven from the per-user index (`users/{uid}/groups`) rather than a
  /// collection-group query over `members`: a collection-group query would need
  /// a recursive-wildcard rules block, and the index costs one small read plus
  /// one group read each, which is what the list screen renders anyway.
  Future<List<FocusGroup>> getUserGroups() async {
    await _ensureInitialized();
    if (!_isFirestoreAvailable) return const [];
    final userId = currentUserId;
    if (userId == null) return const [];

    try {
      final index = await _onFirestore(
        () => _userGroupDocs(userId)
            .limit(GroupLimits.maxGroupsPerUser)
            .get(),
      );
      if (index.docs.isEmpty) return const [];

      final groups = await Future.wait(
        index.docs.map((doc) => getGroup(doc.id)),
      );

      return groups.whereType<FocusGroup>().toList()
        ..sort(_byLiveSessionThenName);
    } catch (e) {
      debugPrint('GroupService: could not read user groups: $e');
      return const [];
    }
  }

  /// The groups the signed-in user belongs to, resolved in parallel.
  Future<bool> isMemberOf(String groupId) async {
    final userId = currentUserId;
    if (userId == null) return false;
    return (await roleOf(groupId, userId)) != null;
  }

  /// Reads one member's accumulated record in a group.
  Future<GroupStats?> getStats({
    required String groupId,
    required String userId,
  }) async {
    await _ensureInitialized();
    if (!_isFirestoreAvailable) return null;

    try {
      final snapshot = await _onFirestore(
        () => _groupDoc(groupId).collection(statsSubcollection).doc(userId).get(),
      );
      return snapshot.exists ? GroupStats.fromSnapshot(snapshot) : null;
    } catch (e) {
      debugPrint('GroupService: could not read stats for $userId: $e');
      return null;
    }
  }

  /// A live stream of one member's record in a group.
  Stream<GroupStats> watchStats({
    required String groupId,
    required String userId,
  }) {
    return _groupDoc(groupId)
        .collection(statsSubcollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.exists ? GroupStats.fromSnapshot(snapshot) : GroupStats.empty(userId));
  }

  // ---------------------------------------------------------------------------
  // Ordering
  // ---------------------------------------------------------------------------

  /// Owner first, admins next, then by join time — so the roster reads as a
  /// hierarchy instead of an arbitrary list.
  static int _byRoleThenJoinDate(GroupMember a, GroupMember b) {
    final rank = _roleRank(a.role).compareTo(_roleRank(b.role));
    if (rank != 0) return rank;
    return a.joinedAt.compareTo(b.joinedAt);
  }

  static int _roleRank(GroupRole role) {
    switch (role) {
      case GroupRole.owner:
        return 0;
      case GroupRole.admin:
        return 1;
      case GroupRole.member:
        return 2;
    }
  }

  /// Groups with a run in progress float to the top, then alphabetical — the
  /// one thing a member is most likely to be looking for.
  static int _byLiveSessionThenName(FocusGroup a, FocusGroup b) {
    if (a.hasLiveSession != b.hasLiveSession) {
      return a.hasLiveSession ? -1 : 1;
    }
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  // ---------------------------------------------------------------------------
  // Creation and joining
  // ---------------------------------------------------------------------------

  /// Creates a group and makes the signed-in user its owner.
  ///
  /// The group document, the owner's membership and the per-user index are one
  /// batch: either the creator is the owner of a group that exists, or nothing
  /// is written at all. The invite code and the directory entry are written
  /// *after* that batch commits, because both of their rules read the group
  /// document and would be racing an uncommitted write.
  Future<FocusGroup> createGroup({
    required String name,
    String? description,
    GroupVisibility visibility = GroupVisibility.private,
    int? maxMembers,
    required String displayName,
    String? photoUrl,
  }) async {
    await _ensureInitialized();
    _requireFirestore();
    final userId = _requireUserId();

    final groupName = GroupLimits.normalizeName(name);
    if (!GroupLimits.isValidName(groupName)) {
      throw GroupException(
        'Give the group a name of at least '
        '${GroupLimits.minNameLength} characters.',
      );
    }

    // Checked before writing rather than after: the index query is the same one
    // the groups list already runs, so this costs nothing extra and turns an
    // unbounded list into a clear refusal.
    final existing = await getUserGroups();
    if (existing.length >= GroupLimits.maxGroupsPerUser) {
      throw GroupException(GroupLimits.tooManyGroupsMessage);
    }

    final docRef = _groups.doc();
    final groupId = docRef.id;
    final now = DateTime.now();

    final trimmedDescription = description?.trim();
    final owner = GroupMember(
      userId: userId,
      displayName: _resolveDisplayName(displayName),
      photoUrl: photoUrl,
      role: GroupRole.owner,
      joinedAt: now,
    );

    final group = FocusGroup(
      id: groupId,
      name: groupName,
      description: (trimmedDescription?.isEmpty ?? true)
          ? null
          : trimmedDescription,
      ownerId: userId,
      visibility: visibility,
      maxMembers: GroupLimits.normalizeMaxMembers(maxMembers),
      memberCount: 1,
      createdAt: now,
      myRole: GroupRole.owner,
    );

    final batch = _db.batch();
    batch.set(docRef, group.toFirestore());
    batch.set(_memberDocs(groupId).doc(userId), owner.toFirestore());
    batch.set(
      _userGroupDocs(userId).doc(groupId),
      {'joinedAt': Timestamp.fromDate(now)},
    );
    await _onFirestore(() => batch.commit());

    // Best-effort from here on: the group exists either way, and the invite
    // panel offers to issue a code if this one failed. Failing the whole create
    // over a code would leave a real group behind while reporting an error.
    await _syncDirectoryEntry(group);
    try {
      await issueInviteCode(groupId);
    } catch (e) {
      debugPrint('GroupService: could not issue invite for $groupId: $e');
    }

    debugPrint('GroupService: created group $groupId');
    return group;
  }

  /// Joins the group named by an invite code and returns its id.
  Future<String> joinByCode({
    required String rawCode,
    required String displayName,
    String? photoUrl,
  }) async {
    final groupId = await resolveInviteCode(rawCode);
    final code = InviteCode.normalize(rawCode);

    await _addSelfAsMember(
      groupId: groupId,
      displayName: displayName,
      photoUrl: photoUrl,
      // Stamped on the membership document so a rule can verify the join came
      // through a code that actually points at this group.
      code: InviteCode.isValid(code) ? code : null,
    );
    return groupId;
  }

  /// Joins a listed group without a code and returns its id.
  ///
  /// Only valid for a group whose visibility is public; the rules enforce the
  /// same condition, so a private group cannot be entered this way even by a
  /// modified client.
  Future<String> joinPublicGroup({
    required String groupId,
    required String displayName,
    String? photoUrl,
  }) async {
    await _addSelfAsMember(
      groupId: groupId,
      displayName: displayName,
      photoUrl: photoUrl,
    );
    return groupId;
  }

  /// Shared implementation behind [joinByCode] and [joinPublicGroup].
  ///
  /// Both paths enforce exactly the same things — membership idempotence, the
  /// cap, and the private-group refusal — so they share one write rather than
  /// two that could drift apart. [code] is null for a listed-group join, which
  /// is what the rules expect for a group that does not need a code.
  Future<GroupMember> _addSelfAsMember({
    required String groupId,
    required String displayName,
    String? photoUrl,
    String? code,
  }) async {
    await _ensureInitialized();
    _requireFirestore();
    final userId = _requireUserId();

    final group = await getGroup(groupId);
    if (group == null) {
      throw const GroupException(
        'This group no longer exists. The owner may have deleted it.',
      );
    }

    final existingRole = await roleOf(groupId, userId);
    if (existingRole != null) {
      // Already in: a reinstall or a cold start landing back in the room is a
      // re-entry, not an error, and nothing needs writing.
      final existing = await getMember(groupId: groupId, userId: userId);
      if (existing != null) return existing;
    }

    if (code == null && !group.isListed) {
      throw const GroupException(
        'This group is private. Ask a member for an invite code.',
      );
    }

    if (group.isFull) {
      throw GroupException(GroupLimits.fullGroupMessage);
    }

    if (existingRole == null) {
      final joined = await getUserGroups();
      if (joined.length >= GroupLimits.maxGroupsPerUser) {
        throw GroupException(GroupLimits.tooManyGroupsMessage);
      }
    }

    final now = DateTime.now();
    final member = GroupMember(
      userId: userId,
      displayName: _resolveDisplayName(displayName),
      photoUrl: photoUrl,
      role: GroupRole.member,
      joinedAt: now,
    );

    final payload = member.toFirestore();
    if (code != null) payload['code'] = code;

    final batch = _db.batch();
    batch.set(_memberDocs(groupId).doc(userId), payload);
    batch.set(
      _userGroupDocs(userId).doc(groupId),
      {'joinedAt': Timestamp.fromDate(now)},
    );
    await _onFirestore(() => batch.commit());

    debugPrint('GroupService: $userId joined group $groupId');
    return member;
  }

  /// Refreshes this member's own denormalised name and photo.
  ///
  /// The roster renders from the membership documents alone, so a member who
  /// renames their profile would otherwise keep their old name in every group
  /// for ever. Anyone may update their own row; the rules refuse a role change
  /// on that path.
  Future<void> refreshMyMembership({
    required String groupId,
    required String displayName,
    String? photoUrl,
  }) async {
    await _ensureInitialized();
    _requireFirestore();
    final userId = _requireUserId();

    final existing = await getMember(groupId: groupId, userId: userId);
    if (existing == null) return;

    final updated = existing.copyWith(
      displayName: _resolveDisplayName(displayName),
      photoUrl: photoUrl,
      clearPhotoUrl: photoUrl == null,
    );

    await _onFirestore(
      () => _memberDocs(groupId).doc(userId).set(
            updated.toFirestore()..['role'] = existing.role.wireName,
            SetOptions(merge: true),
          ),
    );
  }

  // ---------------------------------------------------------------------------
  // Leaving, deleting, editing
  // ---------------------------------------------------------------------------

  /// Removes the signed-in user from a group.
  ///
  /// An owner cannot leave: a group with a `ownerId` pointing at someone who is
  /// no longer a member has nobody able to delete or repair it. They must
  /// delete the group or hand ownership over first.
  Future<void> leaveGroup(String groupId) async {
    await _ensureInitialized();
    _requireFirestore();
    final userId = _requireUserId();

    final role = await roleOf(groupId, userId);
    if (role == null) return;

    if (role.isOwner) {
      throw const GroupException(
        'You own this group — delete it instead of leaving, so it does not end '
        'up with nobody able to manage it.',
      );
    }

    final batch = _db.batch();
    batch.delete(_memberDocs(groupId).doc(userId));
    batch.delete(_userGroupDocs(userId).doc(groupId));
    await _onFirestore(() => batch.commit());

    debugPrint('GroupService: $userId left group $groupId');
  }

  /// Deletes a group and everything under it. Owner only.
  ///
  /// Firestore never cascades a delete, so the subcollections are cleared first
  /// and the group document last: if the run is interrupted, the group is still
  /// there with a partly-emptied roster — recoverable — instead of a document
  /// that no longer exists while its members still think they are in it.
  Future<void> deleteGroup(String groupId) async {
    await _ensureInitialized();
    _requireFirestore();
    final userId = _requireUserId();

    final group = await getGroup(groupId);
    if (group == null) return;
    if (!group.isOwnedBy(userId)) {
      throw const GroupException('Only the owner can delete this group.');
    }

    await _deleteCollection(_memberDocs(groupId));
    await _deleteCollection(_scheduleDocs(groupId));
    await _deleteCollection(_groupDoc(groupId).collection(statsSubcollection));

    final batch = _db.batch();
    batch.delete(_groupDoc(groupId));
    batch.delete(_db.collection(directoryCollection).doc(groupId));
    final code = group.inviteCode;
    if (code != null) {
      batch.delete(_db.collection(invitesCollection).doc(code));
    }
    await _onFirestore(() => batch.commit());

    debugPrint('GroupService: deleted group $groupId');
  }

  /// Edits the group itself. Owner or admin only.
  Future<void> updateGroup({
    required String groupId,
    String? name,
    String? description,
    GroupVisibility? visibility,
  }) async {
    await _ensureInitialized();
    _requireFirestore();
    _requireUserId();

    final group = await getGroup(groupId);
    if (group == null) {
      throw const GroupException('This group no longer exists.');
    }
    if (!group.canManage) {
      throw const GroupException('Only an owner or admin can edit this group.');
    }

    final updates = <String, dynamic>{};
    if (name != null) {
      final trimmed = GroupLimits.normalizeName(name);
      if (!GroupLimits.isValidName(trimmed)) {
        throw GroupException(
          'Give the group a name of at least '
          '${GroupLimits.minNameLength} characters.',
        );
      }
      updates['name'] = trimmed;
    }
    if (description != null) {
      final trimmed = description.trim();
      if (trimmed.isEmpty) {
        updates['description'] = FieldValue.delete();
      } else {
        updates['description'] = trimmed.length >
                GroupLimits.maxDescriptionLength
            ? trimmed.substring(0, GroupLimits.maxDescriptionLength)
            : trimmed;
      }
    }
    if (visibility != null) updates['visibility'] = visibility.wireName;

    if (updates.isEmpty) return;

    await _onFirestore(() => _groupDoc(groupId).update(updates));

    // The directory entry mirrors name, description and visibility, so it is
    // rewritten from the edited group rather than left to drift.
    final edited = group.copyWith(
      name: name,
      description: description,
      visibility: visibility,
      clearDescription: description != null && description.trim().isEmpty,
    );
    await _syncDirectoryEntry(edited);
  }

  /// Removes another member. Owner or admin only.
  Future<void> removeMember({
    required String groupId,
    required String memberId,
  }) async {
    await _ensureInitialized();
    _requireFirestore();
    final userId = _requireUserId();

    if (memberId == userId) {
      throw const GroupException(
        'Use "leave group" to remove yourself.',
      );
    }

    final group = await getGroup(groupId);
    if (group == null) return;
    if (!group.canManage) {
      throw const GroupException('Only an owner or admin can remove a member.');
    }
    if (memberId == group.ownerId) {
      throw const GroupException('The owner cannot be removed.');
    }

    final batch = _db.batch();
    batch.delete(_memberDocs(groupId).doc(memberId));
    batch.delete(_userGroupDocs(memberId).doc(groupId));
    await _onFirestore(() => batch.commit());

    debugPrint('GroupService: removed $memberId from $groupId');
  }

  /// Changes another member's role. Owner only.
  Future<void> setMemberRole({
    required String groupId,
    required String memberId,
    required GroupRole role,
  }) async {
    await _ensureInitialized();
    _requireFirestore();
    final userId = _requireUserId();

    final group = await getGroup(groupId);
    if (group == null) {
      throw const GroupException('This group no longer exists.');
    }
    if (!group.isOwnedBy(userId)) {
      throw const GroupException('Only the owner can change roles.');
    }
    if (memberId == group.ownerId) {
      throw const GroupException(
        'The owner already holds the highest role.',
      );
    }
    if (role == GroupRole.owner) {
      // Ownership transfer is not a role edit: it changes `ownerId` on the
      // group as well, and doing half of it would leave two owners or none.
      throw const GroupException(
        'Ownership cannot be handed over from here yet.',
      );
    }

    await _onFirestore(
      () => _memberDocs(groupId).doc(memberId).update({'role': role.wireName}),
    );
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /// A display name that is never empty, so no roster row renders blank.
  static String _resolveDisplayName(String displayName) {
    final trimmed = displayName.trim();
    return trimmed.isEmpty ? 'Member' : trimmed;
  }

  /// Writes or removes the public directory entry for [group].
  ///
  /// Best-effort: the directory is a discovery convenience, and a failure here
  /// must not fail the group edit that prompted it.
  Future<void> _syncDirectoryEntry(FocusGroup group) async {
    try {
      final entry = _db.collection(directoryCollection).doc(group.id);
      if (group.isListed) {
        await _onFirestore(
          () => entry.set(group.toDirectoryEntry(), SetOptions(merge: true)),
        );
      } else {
        await _onFirestore(() => entry.delete());
      }
    } catch (e) {
      debugPrint('GroupService: directory sync failed for ${group.id}: $e');
    }
  }

  /// Deletes every document in [collection], in chunks.
  ///
  /// A Firestore batch is capped at 500 writes, and a group roster plus its
  /// schedule can exceed that only in theory — but the cap is a hard failure,
  /// not a warning, so the chunking is the difference between "deleted" and
  /// "half deleted" for any group near the limit.
  static const int _deleteBatchSize = 400;

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    while (true) {
      final snapshot = await collection
          .limit(_deleteBatchSize)
          .get()
          .timeout(_networkTimeout);
      if (snapshot.docs.isEmpty) return;

      final batch = collection.firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit().timeout(_networkTimeout);

      if (snapshot.docs.length < _deleteBatchSize) return;
    }
  }

  // ---------------------------------------------------------------------------
  // Invite codes
  // ---------------------------------------------------------------------------

  /// Issues a fresh invite code for a group and returns it.
  ///
  /// Any previously issued code is revoked in the same operation: two live
  /// codes for one group means "revoke the invite" has to revoke two things,
  /// and the one that gets forgotten keeps admitting people after the owner
  /// believed they had closed the door.
  Future<String> issueInviteCode(String groupId) async {
    await _ensureInitialized();
    _requireFirestore();
    _requireUserId();

    final group = await getGroup(groupId);
    if (group == null) {
      throw const GroupException('This group no longer exists.');
    }
    if (!group.canManage) {
      throw const GroupException(
        'Only an owner or admin can create an invite code.',
      );
    }

    final now = DateTime.now();
    final code = InviteCode.generate();
    final expiresAt = now.add(GroupLimits.inviteLifetime);

    final batch = _db.batch();
    batch.set(_db.collection(invitesCollection).doc(code), {
      'gid': groupId,
      'name': group.name,
      'ownerName': group.name,
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(expiresAt),
    });
    batch.set(
      _groupDoc(groupId),
      {
        'inviteCode': code,
        'inviteCodeExpiresAt': Timestamp.fromDate(expiresAt),
      },
      SetOptions(merge: true),
    );
    final previous = group.inviteCode;
    if (previous != null && previous != code) {
      batch.delete(_db.collection(invitesCollection).doc(previous));
    }
    await _onFirestore(() => batch.commit());

    debugPrint('GroupService: issued invite $code for $groupId');
    return code;
  }

  /// Revokes a group's current invite code.
  Future<void> revokeInviteCode(String groupId) async {
    await _ensureInitialized();
    _requireFirestore();
    _requireUserId();

    final group = await getGroup(groupId);
    if (group == null) return;
    if (!group.canManage) {
      throw const GroupException('Only an owner or admin can revoke an invite.');
    }

    final code = group.inviteCode;
    final batch = _db.batch();
    batch.set(
      _groupDoc(groupId),
      {'inviteCode': FieldValue.delete()},
      SetOptions(merge: true),
    );
    if (code != null) {
      batch.delete(_db.collection(invitesCollection).doc(code));
    }
    await _onFirestore(() => batch.commit());
  }

  /// Resolves an invite code to the group it names.
  ///
  /// Throws a user-readable [GroupException] for every failure — malformed,
  /// unknown, expired — because the caller is always a screen showing a
  /// message, never code that branches on the reason.
  Future<String> resolveInviteCode(String rawCode) async {
    await _ensureInitialized();
    _requireFirestore();

    final code = InviteCode.normalize(rawCode);
    if (!InviteCode.isValid(code)) {
      throw GroupException(
        'That does not look like an invite code. Codes are '
        '${InviteCode.length} characters, like AB3K7Q.',
      );
    }

    final snapshot = await _onFirestore(
      () => _db.collection(invitesCollection).doc(code).get(),
    );
    if (!snapshot.exists) {
      throw const GroupException(
        'That invite code is not valid any more. Ask for a fresh one.',
      );
    }

    final invite = snapshot.data() ?? const <String, dynamic>{};
    final groupId = FirestoreValueUtils.stringOrNull(invite['gid']);
    if (groupId == null) {
      throw const GroupException(
        'That invite is damaged and cannot be used. Ask for a new code.',
      );
    }

    // Expiry is checked here as well as by the cleanup job: a code can be
    // scanned seconds after the cron ran, and the user deserves the real reason
    // rather than "group not found".
    final expiresAt = FirestoreValueUtils.dateTimeOrNull(invite['expiresAt']);
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      throw const GroupException(
        'That invite has expired. Ask an owner or admin to share a new one.',
      );
    }

    return groupId;
  }

  /// The live invite code for a group, or null when it has none.
  Future<String?> activeInviteCode(String groupId) async {
    final group = await getGroup(groupId);
    return group?.inviteCode;
  }

  /// Reads the public group directory, newest first.
  ///
  /// Read-only browsing. Entries are written by [_syncDirectoryEntry] from the
  /// group document, so the list never has to open a single group to draw
  /// itself.
  Future<List<Map<String, dynamic>>> getDirectory({int limit = 30}) async {
    await _ensureInitialized();
    if (!_isFirestoreAvailable) return const [];

    try {
      final snapshot = await _onFirestore(
        () => _db
            .collection(directoryCollection)
            .orderBy('updatedAt', descending: true)
            .limit(limit)
            .get(),
      );
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('GroupService: could not read directory: $e');
      return const [];
    }
  }

  // ---------------------------------------------------------------------------
  // Schedule
  // ---------------------------------------------------------------------------

  /// Reads a group's planned sessions, soonest first.
  Future<List<GroupScheduleEntry>> getSchedule(String groupId) async {
    await _ensureInitialized();
    if (!_isFirestoreAvailable) return const [];

    try {
      final snapshot = await _onFirestore(
        () => _scheduleDocs(groupId).orderBy('startsAt').get(),
      );
      return snapshot.docs.map(GroupScheduleEntry.fromSnapshot).toList();
    } catch (e) {
      debugPrint('GroupService: could not read schedule of $groupId: $e');
      return const [];
    }
  }

  /// A live stream of a group's planned sessions, soonest first.
  Stream<List<GroupScheduleEntry>> watchSchedule(String groupId) {
    return _scheduleDocs(groupId)
        .orderBy('startsAt')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(GroupScheduleEntry.fromSnapshot).toList());
  }

  /// Adds a planned session. Owner or admin only.
  ///
  /// The time is validated here rather than only in the sheet, because the same
  /// call is reachable from a deep link or a future recurring-session feature,
  /// and a plan in the past would schedule a reminder for a moment that has
  /// already gone.
  Future<GroupScheduleEntry> addScheduleEntry({
    required String groupId,
    required String title,
    required DateTime startsAt,
    required int durationSec,
    String type = 'study',
  }) async {
    await _ensureInitialized();
    _requireFirestore();
    final userId = _requireUserId();

    final group = await getGroup(groupId);
    if (group == null) {
      throw const GroupException('This group no longer exists.');
    }
    if (!group.canManage) {
      throw const GroupException(
        'Only an owner or admin can add a session to the schedule.',
      );
    }

    final now = DateTime.now();
    if (startsAt.isBefore(now.add(GroupLimits.minScheduleLead))) {
      throw const GroupException(
        'Pick a start time at least a few minutes from now.',
      );
    }
    if (startsAt.isAfter(now.add(GroupLimits.maxScheduleHorizon))) {
      throw const GroupException(
        'A session cannot be scheduled more than three months ahead.',
      );
    }

    final existing = await getSchedule(groupId);
    if (existing.length >= GroupLimits.maxScheduleEntriesPerGroup) {
      throw const GroupException(
        'This schedule is full. Remove a planned session before adding '
        'another.',
      );
    }

    final docRef = _scheduleDocs(groupId).doc();
    final entry = GroupScheduleEntry(
      id: docRef.id,
      title: title.trim().isEmpty ? 'Focus session' : title.trim(),
      startsAt: startsAt,
      durationSec: durationSec,
      type: type,
      createdBy: userId,
      createdAt: now,
    );

    await _onFirestore(() => docRef.set(entry.toFirestore()));
    return entry;
  }

  /// Removes a planned session. Owner or admin only.
  Future<void> removeScheduleEntry({
    required String groupId,
    required String entryId,
  }) async {
    await _ensureInitialized();
    _requireFirestore();
    _requireUserId();

    final group = await getGroup(groupId);
    if (group == null) return;
    if (!group.canManage) {
      throw const GroupException(
        'Only an owner or admin can change the schedule.',
      );
    }

    await _onFirestore(() => _scheduleDocs(groupId).doc(entryId).delete());
  }

  // ---------------------------------------------------------------------------
  // Live session pointer
  // ---------------------------------------------------------------------------

  /// Publishes the shared session a group is running right now.
  ///
  /// A pointer, not a session: the run itself lives in the Realtime Database.
  /// Writing it here is what lets the group screen offer "join the run
  /// happening now" without opening RTDB first, and what makes the group card
  /// float to the top of the list while it lasts.
  Future<void> publishLiveSession({
    required String groupId,
    required String sessionId,
    String? code,
  }) async {
    await _ensureInitialized();
    _requireFirestore();
    _requireUserId();

    final group = await getGroup(groupId);
    if (group == null) {
      throw const GroupException('This group no longer exists.');
    }
    if (!group.canManage) {
      throw const GroupException(
        'Only an owner or admin can start a session for this group.',
      );
    }

    final pointer = GroupLiveSession(
      sessionId: sessionId,
      code: code,
      startedAt: DateTime.now(),
    );

    await _onFirestore(
      () => _groupDoc(groupId).set(
        {'liveSession': pointer.toFirestore()},
        SetOptions(merge: true),
      ),
    );
  }

  /// Clears the live-session pointer once the run is over.
  Future<void> clearLiveSession(String groupId) async {
    await _ensureInitialized();
    if (!_isFirestoreAvailable) return;

    try {
      await _onFirestore(
        () => _groupDoc(groupId).set(
          {'liveSession': FieldValue.delete()},
          SetOptions(merge: true),
        ),
      );
    } catch (e) {
      // A stale pointer is a cosmetic problem: the session it names will not
      // resolve, and the next successful start overwrites it.
      debugPrint('GroupService: could not clear live session on $groupId: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Drops every piece of process-wide state. Called on sign-out.
  ///
  /// The service holds no per-account cache — everything is read per call — so
  /// this only resets the initialised flag, which is what forces the next
  /// account to re-check Firestore availability rather than inherit the
  /// previous one's answer.
  void release() {
    _isInitialized = false;
    _initFuture = null;
    _isFirestoreAvailable = true;
    debugPrint('GroupService: released');
  }
}
