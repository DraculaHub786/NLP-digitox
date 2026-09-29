import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/services/session_service.dart';

/// Turns a thrown session error into text the user can act on.
///
/// Firebase's own message is developer-facing, e.g.
/// `[firebase_database/permission-denied] Client doesn't have permission to
/// access the desired data.`, so the cases where the user needs to do something
/// different are mapped here instead of being dumped into the UI verbatim.
///
/// Shared by the create and join sheets so both describe the same failure the
/// same way. [action] is the verb that fits the caller: 'create' or 'join'.
String sessionErrorMessage(Object error, String action) {
  debugPrint('Session $action failed: $error');

  // Already written for the user by SessionService.
  if (error is SessionException) return error.message;

  final message = error.toString();
  if (message.contains('permission-denied') ||
      message.contains('PERMISSION_DENIED')) {
    return 'The server rejected this request. Please sign out and back in, '
        'then try again.';
  }
  if (message.contains('not authenticated')) {
    return 'Please sign in again to $action a session.';
  }
  if (message.contains('not initialized')) {
    return 'Sessions are still starting up. Please try again in a moment.';
  }
  if (message.contains('Could not reach the server')) {
    return 'Could not reach the server. Check your connection and try again.';
  }
  return 'Could not $action the session. Please try again.';
}
