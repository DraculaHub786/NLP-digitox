// Copyright (c) 2026 NLP digitox

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/utils/firestore_value_utils.dart';

/// A report/block failure whose message is already written for the user.
class ReportBlockException implements Exception {
  final String message;

  const ReportBlockException(this.message);

  @override
  String toString() => message;
}

/// Why someone is being reported.
///
/// A closed list rather than free text: the reviewer's first question is always
/// "what kind of problem is this", and free text makes that question
/// unanswerable at a glance. The optional note on a report carries the detail.
enum ReportReason {
  harassment,
  spam,
  inappropriate,
  impersonation,
  other;

  /// Wire value stored in Firestore.
  String get wireName => name;

  /// The label shown in the report sheet.
  String get label {
    switch (this) {
      case ReportReason.harassment:
        return 'Harassment or bullying';
      case ReportReason.spam:
        return 'Spam or advertising';
      case ReportReason.inappropriate:
        return 'Inappropriate content';
      case ReportReason.impersonation:
        return 'Pretending to be someone else';
      case ReportReason.other:
        return 'Something else';
    }
  }

  /// Parses a stored reason, falling back to [ReportReason.other].
  static ReportReason parse(dynamic raw) {
    if (raw is String) {
      for (final reason in ReportReason.values) {
        if (reason.wireName == raw) return reason;
      }
    }
    return ReportReason.other;
  }
}

/// What is being reported, so a reviewer can find the context.
enum ReportTargetKind {
  /// A person, in the context of one session or group.
  member,

  /// A whole shared session.
  session,

  /// A whole group.
  group;

  String get wireName => name;

  static ReportTargetKind parse(dynamic raw) {
    if (raw is String) {
      for (final kind in ReportTargetKind.values) {
        if (kind.wireName == raw) return kind;
      }
    }
    return ReportTargetKind.member;
  }
}

/// Reports and blocks, backed by Cloud Firestore.
///
/// Two separate mechanisms on purpose, because they answer two different
/// needs:
///   * a **report** is a message to a human — it is written once, read by a
///     reviewer, and changes nothing about what the reporter sees;
///   * a **block** is a local promise — it takes effect immediately, the
///     blocked person's name and photo disappear from every roster this user
///     sees, and nobody else is told.
///
/// Treating them as one action would either make blocking feel useless (nothing
/// happens until someone reviews it) or make reporting feel secret (the
/// reported person is silently hidden and the problem never surfaces).
///
/// Firestore layout:
/// ```
/// reports/{reportId}
///   reporterUid, targetUid, kind, reason, note?, sid?, gid?, at
/// blocks/{uid}/blocked/{blockedUid}
///   displayName?, at
/// ```
class ReportBlockService {
  ReportBlockService._();

  /// The single instance every screen and provider talks to.
  static final ReportBlockService instance = ReportBlockService._();

  static const String reportsCollection = 'reports';
  static const String blocksCollection = 'blocks';
  static const String blockedSubcollection = 'blocked';

  static const Duration _networkTimeout = Duration(seconds: 20);

  /// Longest accepted free-text note on a report.
  static const int maxNoteLength = 500;

  bool _isInitialized = false;
  bool _isFirestoreAvailable = true;
  Future<void>? _initFuture;

  /// The blocked ids last read, so a roster can filter without a round trip.
  final ValueNotifier<Set<String>> blockedUserIds =
      ValueNotifier<Set<String>>(const {});

  bool get isReady => _isInitialized;

  /// Persistent listener on this user's block list.
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _blockSubscription;

  String? get currentUserId => FirebaseAuthService.instance.userId;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Prepares the service. Idempotent.
  Future<void> init() async {
    if (_isInitialized) return;
    await (_initFuture ??= _init());
  }

  Future<void> _init() async {
    try {
      FirebaseFirestore.instance;
      _isFirestoreAvailable = true;
      debugPrint('ReportBlockService: Initialized successfully');
    } catch (e) {
      _isFirestoreAvailable = false;
      debugPrint('ReportBlockService: Firestore unavailable: $e');
    } finally {
      _isInitialized = true;
    }
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    await (_initFuture ??= _init());
  }

  /// Runs [work], turning a timeout into a [ReportBlockException].
  Future<T> _onFirestore<T>(Future<T> Function() work) async {
    await _ensureInitialized();
    try {
      return await work().timeout(_networkTimeout);
    } on TimeoutException {
      throw const ReportBlockException(
        'Could not reach the server. Check your connection and try again.',
      );
    }
  }

  String _requireUserId() {
    final userId = currentUserId;
    if (userId == null) throw StateError('User not authenticated');
    return userId;
  }

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _blockedDocs(String userId) =>
      _db.collection(blocksCollection).doc(userId).collection(
            blockedSubcollection,
          );

  // ---------------------------------------------------------------------------
  // Reports
  // ---------------------------------------------------------------------------

  /// Files a report against [targetUid].
  ///
  /// Returns the new report's id. The report carries the ids of whatever
  /// context it came from, so a reviewer can open the session or group without
  /// having to guess which one the user meant.
  Future<String> submitReport({
    required String targetUid,
    required ReportTargetKind kind,
    required ReportReason reason,
    String? note,
    String? sessionId,
    String? groupId,
  }) async {
    await _ensureInitialized();
    final userId = _requireUserId();

    if (!_isFirestoreAvailable) {
      throw const ReportBlockException(
        'Could not send the report. Check your connection and try again.',
      );
    }
    if (targetUid == userId) {
      throw const ReportBlockException('You cannot report yourself.');
    }
    if (targetUid.isEmpty) {
      throw const ReportBlockException(
        'Could not tell who to report. Reopen the screen and try again.',
      );
    }

    final trimmedNote = note?.trim();
    final report = <String, dynamic>{
      'reporterUid': userId,
      'targetUid': targetUid,
      'kind': kind.wireName,
      'reason': reason.wireName,
      if (trimmedNote != null && trimmedNote.isNotEmpty)
        'note': trimmedNote.length > maxNoteLength
            ? trimmedNote.substring(0, maxNoteLength)
            : trimmedNote,
      if (sessionId != null) 'sid': sessionId,
      if (groupId != null) 'gid': groupId,
      'at': FieldValue.serverTimestamp(),
    };

    final docRef = _db.collection(reportsCollection).doc();
    await _onFirestore(() => docRef.set(report));

    debugPrint('ReportBlockService: filed report ${docRef.id}');
    return docRef.id;
  }

  // ---------------------------------------------------------------------------
  // Blocks
  // ---------------------------------------------------------------------------

  /// Blocks [blockedUid] for the signed-in user.
  ///
  /// Idempotent: blocking someone already blocked is a no-op rather than an
  /// error, because the button that did it is a toggle and a double tap should
  /// not produce a failure message.
  Future<void> blockUser({
    required String blockedUid,
    String? displayName,
  }) async {
    await _ensureInitialized();
    final userId = _requireUserId();

    final current = blockedUserIds.value;
    if (current.contains(blockedUid)) return;

    if (!_isFirestoreAvailable) {
      throw const ReportBlockException(
        'Could not block this person. Check your connection and try again.',
      );
    }

    await _onFirestore(
      () => _blockedDocs(userId).doc(blockedUid).set({
        if (displayName != null && displayName.trim().isNotEmpty)
          'displayName': displayName.trim(),
        'at': FieldValue.serverTimestamp(),
      }),
    );

    // Written locally as well as remotely so the roster filters immediately
    // rather than after the listener's next round trip.
    blockedUserIds.value = {...current, blockedUid};
    debugPrint('ReportBlockService: blocked $blockedUid');
  }

  /// Unblocks [blockedUid].
  Future<void> unblockUser(String blockedUid) async {
    await _ensureInitialized();
    final userId = _requireUserId();

    await _onFirestore(() => _blockedDocs(userId).doc(blockedUid).delete());

    blockedUserIds.value =
        blockedUserIds.value.where((id) => id != blockedUid).toSet();
    debugPrint('ReportBlockService: unblocked $blockedUid');
  }

  /// Whether [userId] is blocked by the signed-in user.
  Future<bool> isBlocked(String userId) async {
    await _ensureInitialized();
    if (!_isFirestoreAvailable) return blockedUserIds.value.contains(userId);

    try {
      final snapshot = await _onFirestore(
        () => _blockedDocs(_requireUserId()).doc(userId).get(),
      );
      return snapshot.exists;
    } catch (e) {
      debugPrint('ReportBlockService: could not read block state: $e');
      return blockedUserIds.value.contains(userId);
    }
  }

  /// Reads the whole block list once.
  Future<Set<String>> getBlockedUserIds() async {
    await _ensureInitialized();
    if (!_isFirestoreAvailable) return blockedUserIds.value;

    try {
      final snapshot = await _onFirestore(
        () => _blockedDocs(_requireUserId()).get(),
      );
      final ids = snapshot.docs.map((doc) => doc.id).toSet();
      blockedUserIds.value = ids;
      return ids;
    } catch (e) {
      debugPrint('ReportBlockService: could not read block list: $e');
      return blockedUserIds.value;
    }
  }

  /// Keeps [blockedUserIds] in step with the server for as long as this user is
  /// signed in.
  ///
  /// Started once from the provider that the rosters watch, so a block made on
  /// another device hides the person here too.
  void startBlockListener() {
    final userId = currentUserId;
    if (userId == null || !_isFirestoreAvailable) return;
    if (_blockSubscription != null) return;

    _blockSubscription = _blockedDocs(userId).snapshots().listen(
      (snapshot) {
        blockedUserIds.value =
            snapshot.docs.map((doc) => doc.id).toSet();
      },
      onError: (Object error) {
        debugPrint('ReportBlockService: block listener error: $error');
      },
    );
  }

  /// Whether the last read of a user's display name is available, for the
  /// "blocked people" list on the settings screen.
  ///
  /// Reads the `displayName` a block was filed with, which is the only record
  /// of who that person was — the roster itself is gone by then.
  Stream<List<({String userId, String? displayName, DateTime? at})>>
      watchBlockedEntries() {
    final userId = currentUserId;
    if (userId == null || !_isFirestoreAvailable) {
      return Stream.value(const []);
    }
    return _blockedDocs(userId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return (
              userId: doc.id,
              displayName: FirestoreValueUtils.stringOrNull(data['displayName']),
              at: FirestoreValueUtils.dateTimeOrNull(data['at']),
            );
          }).toList(),
        );
  }

  /// Drops every piece of process-wide state. Called on sign-out.
  void release() {
    unawaited(_blockSubscription?.cancel());
    _blockSubscription = null;
    blockedUserIds.value = const {};
    _isInitialized = false;
    _initFuture = null;
    _isFirestoreAvailable = true;
    debugPrint('ReportBlockService: released');
  }
}
