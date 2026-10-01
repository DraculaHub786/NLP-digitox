// Copyright (c) 2026 NLP digitox

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/report_block_service.dart';

/// The singleton report/block service.
final reportBlockServiceProvider = Provider<ReportBlockService>((ref) {
  unawaited(ReportBlockService.instance.init());
  return ReportBlockService.instance;
});

/// The ids this user has blocked, kept live.
///
/// A `StreamProvider` over the service's own `ValueNotifier` rather than a
/// second Firestore listener: the service already owns the one subscription
/// and writes every local change (block and unblock) into the notifier, so the
/// UI sees an immediate result and the server's copy is a backstop rather than
/// the source of latency.
final blockedUserIdsProvider = StreamProvider<Set<String>>((ref) {
  final service = ref.watch(reportBlockServiceProvider);
  service.startBlockListener();

  StreamController<Set<String>>? controller;
  void listener() => controller?.add(service.blockedUserIds.value);

  controller = StreamController<Set<String>>(
    onListen: () {
      service.blockedUserIds.addListener(listener);
      controller?.add(service.blockedUserIds.value);
    },
    onCancel: () => service.blockedUserIds.removeListener(listener),
  );

  ref.onDispose(() async {
    service.blockedUserIds.removeListener(listener);
    await controller?.close();
  });

  return controller.stream;
});

/// The blocked people, with the name each block was filed under.
final blockedEntriesProvider = StreamProvider.autoDispose<
    List<({String userId, String? displayName, DateTime? at})>>((ref) {
  return ref.watch(reportBlockServiceProvider).watchBlockedEntries();
});

/// Whether one specific user is blocked.
final isUserBlockedProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, userId) {
  return ref.watch(reportBlockServiceProvider).isBlocked(userId);
});

/// Files a report and/or blocks someone.
class ReportBlockNotifier extends StateNotifier<AsyncValue<void>> {
  ReportBlockNotifier(this._service) : super(const AsyncValue.data(null));

  final ReportBlockService _service;

  /// Files a report. Returns true when it was accepted.
  Future<bool> report({
    required String targetUid,
    required ReportTargetKind kind,
    required ReportReason reason,
    String? note,
    String? sessionId,
    String? groupId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.submitReport(
        targetUid: targetUid,
        kind: kind,
        reason: reason,
        note: note,
        sessionId: sessionId,
        groupId: groupId,
      ),
    );
    return !state.hasError;
  }

  Future<bool> block({required String userId, String? displayName}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.blockUser(blockedUid: userId, displayName: displayName),
    );
    return !state.hasError;
  }

  Future<bool> unblock(String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.unblockUser(userId));
    return !state.hasError;
  }
}

/// Report/block action provider.
final reportBlockProvider = StateNotifierProvider.autoDispose<
    ReportBlockNotifier, AsyncValue<void>>((ref) {
  return ReportBlockNotifier(ref.watch(reportBlockServiceProvider));
});
