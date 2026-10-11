// Copyright (c) 2026 NLP digitox

import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nlp_digitox/config/api_keys.dart';

/// What the server decided about one member's finished shared run.
enum SessionCompletionStatus {
  /// Verified and paid.
  credited,

  /// Verified, but nothing was owed (too few people, or too short a run).
  noPoints,

  /// No completion webhook is configured for this build.
  disabled,

  /// The call itself failed (offline, rejected, no signed-in user).
  failed;

  static SessionCompletionStatus parse(dynamic raw) {
    if (raw is String) {
      switch (raw) {
        case 'credited':
        case 'awarded':
        case 'ok':
          return SessionCompletionStatus.credited;
        case 'no_points':
        case 'not_eligible':
        case 'skipped':
          return SessionCompletionStatus.noPoints;
      }
    }
    return SessionCompletionStatus.noPoints;
  }
}

/// The server's verdict on one member's finished shared run.
///
/// Returned by [SessionCompletionService.reportCompletion] so the UI can show
/// what the server actually decided rather than a locally assumed number. The
/// client never computes a payout; it only renders this.
@immutable
class SessionCompletionResult {
  /// What the server did with this report.
  final SessionCompletionStatus status;

  /// Points credited, as decided by the workflow. Zero when nothing was paid.
  final int points;

  /// A short, user-facing explanation. Empty when there is nothing to add.
  final String reason;

  const SessionCompletionResult({
    required this.status,
    this.points = 0,
    this.reason = '',
  });

  /// A report that could not be made because no webhook is configured.
  static const SessionCompletionResult disabled = SessionCompletionResult(
    status: SessionCompletionStatus.disabled,
  );

  /// A report that was attempted but failed (network, non-2xx, no user).
  static SessionCompletionResult failed(String reason) =>
      SessionCompletionResult(
        status: SessionCompletionStatus.failed,
        reason: reason,
      );

  /// Whether points were credited.
  bool get isCredited => status == SessionCompletionStatus.credited;

  /// A one-line message for a dialog or snackbar.
  String get message {
    switch (status) {
      case SessionCompletionStatus.credited:
        return 'Completed — $points points added.';
      case SessionCompletionStatus.noPoints:
        return reason.isEmpty
            ? 'Completed — no points this time.'
            : 'Completed — no points ($reason).';
      case SessionCompletionStatus.disabled:
        return 'Session completed.';
      case SessionCompletionStatus.failed:
        return reason.isEmpty
            ? 'Session completed, but the server could not verify it yet.'
            : 'Session completed, but the server could not verify it: $reason';
    }
  }
}

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
/// Authentication is the Firebase ID token. There is deliberately no shared
/// secret: it would ship inside the binary and protect nothing, whereas the ID
/// token identifies the caller and cannot be forged.
///
/// When [ApiKeys.sessionCompleteWebhookUrl] is empty — the default for a build
/// that has not configured the workflow — this is a no-op that reports
/// [SessionCompletionStatus.disabled].
class SessionCompletionService {
  SessionCompletionService._();

  static final SessionCompletionService instance = SessionCompletionService._();

  /// How long the workflow may take to acknowledge.
  ///
  /// Generous: the workflow performs an ID-token verification, a Realtime
  /// Database read and up to three Firestore writes, and it is idempotent, so
  /// a slow call is a retry rather than a duplicate.
  static const Duration _timeout = Duration(seconds: 20);

  /// Sessions already reported during this app launch, and the verdict each
  /// one got.
  ///
  /// The workflow is idempotent per `sid + uid`, so a second call would be
  /// harmless — but there is no reason to pay for the round trip when a phase
  /// change re-fires the report, and caching the verdict means a later
  /// observation returns the same answer instead of an empty one.
  final Map<String, SessionCompletionResult> _reported = {};

  /// Whether a completion webhook is configured for this build.
  bool get isEnabled => ApiKeys.hasSessionCompleteWebhook;

  /// Tells the server that the signed-in member finished [sessionId].
  ///
  /// Safe to call repeatedly: the session is reported once per launch and the
  /// verdict is cached, and a failed call is forgotten so a later phase
  /// observation can retry it.
  Future<SessionCompletionResult> reportCompletion(String sessionId) async {
    if (sessionId.isEmpty) return SessionCompletionResult.disabled;
    if (!isEnabled) return SessionCompletionResult.disabled;

    final cached = _reported[sessionId];
    if (cached != null) return cached;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return SessionCompletionResult.failed('not signed in');
    }

    try {
      // The workflow resolves the uid from this token rather than trusting a
      // uid in the body, so a modified client cannot claim another user's run.
      final idToken = await user.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        return SessionCompletionResult.failed('could not authenticate');
      }

      final response = await http
          .post(
            Uri.parse(ApiKeys.sessionCompleteWebhookUrl),
            headers: {
              'Content-Type': 'application/json',
              // The ID token is the authentication. Sent as a bearer header so
              // it is not duplicated in logs that capture request bodies.
              'Authorization': 'Bearer $idToken',
            },
            // `idToken` stays in the body too: the workflow accepts either.
            body: jsonEncode({'sid': sessionId, 'idToken': idToken}),
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = _parseResponse(sessionId, response.body);
        _reported[sessionId] = result;
        debugPrint(
          'SessionCompletionService: $sessionId -> ${result.status.name} '
          '(${result.points} points)',
        );
        return result;
      }

      debugPrint(
        'SessionCompletionService: webhook ${response.statusCode} for '
        '$sessionId: ${response.body}',
      );
      return SessionCompletionResult.failed(
        'server error ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('SessionCompletionService: webhook call failed: $e');
      return SessionCompletionResult.failed('could not reach the server');
    }
  }

  /// Parses the workflow's JSON reply, tolerating a plain text or empty body.
  SessionCompletionResult _parseResponse(String sessionId, String body) {
    if (body.isEmpty) {
      return const SessionCompletionResult(
        status: SessionCompletionStatus.credited,
      );
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final points = _asInt(decoded['points']) ?? 0;
        final status = SessionCompletionStatus.parse(decoded['status']);
        final reason = decoded['reason'] as String? ?? '';
        // A workflow that returned 2xx with a positive `points` paid out,
        // whatever its status string says.
        if (status != SessionCompletionStatus.credited && points > 0) {
          return SessionCompletionResult(
            status: SessionCompletionStatus.credited,
            points: points,
            reason: reason,
          );
        }
        return SessionCompletionResult(
          status: status,
          points: points,
          reason: reason,
        );
      }
    } catch (e) {
      debugPrint('SessionCompletionService: non-JSON reply for $sessionId: $e');
    }

    return const SessionCompletionResult(
      status: SessionCompletionStatus.credited,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  /// The cached verdict for [sessionId], if it has been reported this launch.
  SessionCompletionResult? resultFor(String sessionId) => _reported[sessionId];

  /// Forgets everything reported — for sign-out and for tests.
  @visibleForTesting
  void reset() => _reported.clear();
}
