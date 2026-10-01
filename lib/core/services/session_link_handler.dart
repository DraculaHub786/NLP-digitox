// Copyright (c) 2026 NLP digitox

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/utils/invite_code.dart';

/// Receives `join` links and turns them into invite codes.
///
/// This is the door an invite comes in through. The host shares
/// `com.nlp.digitox://join/AB3K7Q` (or, when a web host is configured, an
/// `https` link); tapping it on another phone opens NLP-Digitox with that URI,
/// and this service is what notices and extracts the code.
///
/// It deliberately does **not** navigate or join on its own. Two things can go
/// wrong if it did: the user may not be signed in yet (the link has to survive
/// the whole auth flow and be replayed afterwards), and the app may be on a
/// screen that should not be interrupted. So all this does is publish the code
/// on a stream and remember the most recent one; the widget layer decides when
/// it is safe to act on it.
class SessionLinkHandler {
  SessionLinkHandler._();

  static final SessionLinkHandler instance = SessionLinkHandler._();

  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _subscription;

  /// Codes that arrived and have not yet been consumed by the UI.
  ///
  /// A link can arrive before the first frame is built (a cold start), so the
  /// code cannot only be delivered as an event — it would be missed. The
  /// pending code is held here until [consumePending] reads it.
  String? _pendingCode;

  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  /// Codes as they arrive, for a listener that is already mounted.
  Stream<String> get codes => _controller.stream;

  /// The code from a link that has not been acted on yet, if any.
  String? get pendingCode => _pendingCode;

  /// Starts listening. Safe to call once; repeats are ignored.
  Future<void> start() async {
    if (_subscription != null) return;

    _subscription = _appLinks.uriLinkStream.listen(
      _onUri,
      onError: (Object error) {
        debugPrint('SessionLinkHandler: link stream error: $error');
      },
    );

    // A cold start does not go through the stream, so the initial link has to
    // be read separately.
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _onUri(initial);
    } catch (e) {
      debugPrint('SessionLinkHandler: no initial link: $e');
    }
  }

  /// Stops listening — for sign-out and tests.
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Reads and clears the pending code.
  String? consumePending() {
    final code = _pendingCode;
    _pendingCode = null;
    return code;
  }

  /// Feeds a URI in directly — the test seam for a stream that needs a real
  /// platform channel.
  @visibleForTesting
  void handleUri(Uri uri) => _onUri(uri);

  void _onUri(Uri uri) {
    final code = codeFrom(uri);
    if (code == null) return;
    _pendingCode = code;
    if (!_controller.isClosed) _controller.add(code);
  }

  /// Extracts a session invite code from [uri], or null if it is not a join
  /// link.
  ///
  /// Only the app's own scheme with the `join` host, or an `https` link whose
  /// path contains a `join` segment, is treated as an invite. Anything else —
  /// including the app's existing `open` link — is ignored, so this cannot
  /// accidentally swallow a different deep link.
  @visibleForTesting
  static String? codeFrom(Uri uri) {
    final isAppJoin =
        uri.scheme == InviteCode.scheme && uri.host == InviteCode.joinHost;
    final isHttpsJoin = (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments.first == InviteCode.joinHost;

    if (!isAppJoin && !isHttpsJoin) return null;

    final candidate = isAppJoin
        ? (uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null)
        : (uri.pathSegments.length > 1 ? uri.pathSegments[1] : null);

    if (candidate == null) return null;
    final code = InviteCode.parse(candidate);
    if (code == null || !InviteCode.isValid(code)) return null;
    return code;
  }

  /// Disposes the stream controller. Test-only.
  @visibleForTesting
  void dispose() {
    _controller.close();
  }
}
