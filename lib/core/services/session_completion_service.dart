// Copyright (c) 2026 NLP digitox

import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nlp_digitox/config/api_keys.dart';

/// Reports a finished shared run to the server so it can be verified and paid.
///
/// The client is trusted with exactly one thing here: *saying* that it reached
/// the end of the run. It does not decide whether that is true, and it never
/// writes points. The n8n workflow re-reads the session through the Realtime
/// Database REST API with a service account, re-derives `endAt` from the stored
/// server timestamp, checks the member was present and within the break
/// allowance, and only then writes `sessionResults/{sid}/{uid}` and credits the
/// leaderboard. That is why no client path can fabricate a reward.
///
/// When [ApiKeys.sessionCompleteWebhookUrl] is empty — the default for a build
/// that has not configured the workflow — this is a no-op, and shared sessions
/// behave exactly as they did before it existed.
class SessionCompletionService {
  SessionCompletionService._();

  static final SessionCompletionService instance = SessionCompletionService._();

  /// How long the workflow may take to acknowledge.
  ///
  /// Generous: the workflow performs an ID-token verification, a Realtime
  /// Database read and up to three Firestore writes, and it is idempotent, so
  /// a slow call is a retry rather than a duplicate.
  static const Duration _timeout = Duration(seconds: 20);

  /// Sessions already reported during this app launch.
  ///
  /// The workflow is idempotent per `sid + uid`, so a second call would be
  /// harmless — but there is no reason to pay for the round trip when a phase
  /// change re-fires the report, and this keeps the network log clean.
  final Set<String> _reported = <String>{};

  /// Whether a completion webhook is configured for this build.
  bool get isEnabled => ApiKeys.hasSessionCompleteWebhook;

  /// Tells the server that the signed-in member finished [sessionId].
  ///
  /// Safe to call repeatedly: the session is reported once per launch, and a
  /// failed call is forgotten so a later phase observation can retry it.
  Future<void> reportCompletion(String sessionId) async {
    if (sessionId.isEmpty || !isEnabled) return;
    if (!_reported.add(sessionId)) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _reported.remove(sessionId);
      return;
    }

    try {
      // The workflow resolves the uid from this token rather than trusting a
      // uid in the body, so a modified client cannot claim another user's run.
      final idToken = await user.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        _reported.remove(sessionId);
        return;
      }

      final response = await http
          .post(
            Uri.parse(ApiKeys.sessionCompleteWebhookUrl),
            headers: {
              'Content-Type': 'application/json',
              if (ApiKeys.sessionWebhookSecret.isNotEmpty)
                'x-digitox-secret': ApiKeys.sessionWebhookSecret,
            },
            body: jsonEncode({'sid': sessionId, 'idToken': idToken}),
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint(
          'SessionCompletionService: completion verified for $sessionId',
        );
      } else {
        // Leave it un-reported so a later observation can try again.
        _reported.remove(sessionId);
        debugPrint(
          'SessionCompletionService: webhook ${response.statusCode} for '
          '$sessionId: ${response.body}',
        );
      }
    } catch (e) {
      _reported.remove(sessionId);
      debugPrint('SessionCompletionService: webhook call failed: $e');
    }
  }

  /// Forgets everything reported — for sign-out and for tests.
  @visibleForTesting
  void reset() => _reported.clear();
}
