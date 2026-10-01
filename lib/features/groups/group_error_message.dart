// Copyright (c) 2026 NLP digitox

import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/services/group_service.dart';

/// Turns a thrown group error into text the user can act on.
///
/// Firestore's own message is developer-facing, e.g.
/// `[cloud_firestore/permission-denied] Missing or insufficient permissions.`,
/// so the cases where the user needs to do something different are mapped here
/// instead of being dumped into the UI verbatim.
///
/// [action] is the verb that fits the caller — 'create', 'join', 'update',
/// 'delete' — so the fallback sentence reads naturally on every screen rather
/// than only on the one it was written for.
String groupErrorMessage(Object error, String action) {
  debugPrint('Group $action failed: $error');

  // Already written for the user by GroupService.
  if (error is GroupException) return error.message;

  final message = error.toString();
  if (message.contains('permission-denied') ||
      message.contains('PERMISSION_DENIED')) {
    return 'The server rejected this request. Please sign out and back in, '
        'then try again.';
  }
  if (message.contains('not authenticated')) {
    return 'Please sign in again to $action a group.';
  }
  if (message.contains('Could not reach the server')) {
    return 'Could not reach the server. Check your connection and try again.';
  }
  return 'Could not $action the group. Please try again.';
}
