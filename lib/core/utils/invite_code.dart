// Copyright (c) 2026 NLP digitox

import 'dart:math';

/// Invite codes for shared sessions, and the links that carry them.
///
/// A code is short enough to read aloud and to type, and drawn from an alphabet
/// with the ambiguous characters removed: no `0`/`O`, no `1`/`I`/`L`. Someone
/// reading a code off a screen and typing it on another phone is the whole point,
/// and those four pairs are what makes that fail.
///
/// Codes are not secrets. They name a room the way a table number does — the
/// security rules still decide who may join and what they may write, and the
/// code only has to be *unguessable enough* that a stranger cannot enumerate
/// live rooms. 6 characters over a 31-symbol alphabet is ~8.9e8 combinations.
class InviteCode {
  const InviteCode._();

  /// Unambiguous uppercase alphabet: digits 2-9 and letters minus I, L, O.
  static const String alphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

  /// Characters in a code.
  static const int length = 6;

  /// How long an invite stays usable. A code outliving the lobby it points at
  /// is a dead end for whoever finds it, so it expires with the session.
  static const Duration lifetime = Duration(hours: 24);

  /// The app's own scheme, used for links that open NLP-Digitox directly.
  ///
  /// Matches the scheme already declared in `AndroidManifest.xml`, so no second
  /// scheme has to be registered just for invites.
  static const String scheme = 'com.nlp.digitox';

  /// Host segment of an app-scheme join link.
  static const String joinHost = 'join';

  /// Host used for `https` join links.
  ///
  /// Defaults to the project's own domain so a shared invite is a real,
  /// tappable `https` link — messengers like WhatsApp and Telegram do not make
  /// the custom `com.nlp.digitox://` scheme tappable, so an app-scheme-only
  /// invite arrives as dead text. Override with `--dart-define=SESSION_JOIN_HOST`
  /// (e.g. for a staging host); set it to the empty string to fall back to the
  /// app-scheme link.
  static const String defaultJoinHost = 'nlpdigitox.me';

  static const String _httpsHostOverride =
      String.fromEnvironment('SESSION_JOIN_HOST');

  /// The effective `https` host, or empty when https links are disabled.
  static String get _httpsHost {
    const isOverridden = bool.hasEnvironment('SESSION_JOIN_HOST');
    return isOverridden ? _httpsHostOverride : defaultJoinHost;
  }

  static final Random _random = Random.secure();

  /// Generates a fresh code.
  static String generate() {
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(alphabet[_random.nextInt(alphabet.length)]);
    }
    return buffer.toString();
  }

  /// Normalises anything a person might paste into a code.
  ///
  /// Uppercases, drops separators and whitespace, and maps the characters the
  /// alphabet deliberately excludes onto the ones they are confused with — so a
  /// code read off a screen as `0` or `O` still resolves.
  static String normalize(String raw) {
    final buffer = StringBuffer();
    for (final rune in raw.toUpperCase().runes) {
      final char = String.fromCharCode(rune);
      switch (char) {
        case '0':
        case 'O':
          buffer.write('Q');
          break;
        case '1':
        case 'I':
        case 'L':
          buffer.write('J');
          break;
        default:
          if (alphabet.contains(char)) buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Whether [code] is already a well-formed code.
  static bool isValid(String code) {
    if (code.length != length) return false;
    for (final rune in code.runes) {
      if (!alphabet.contains(String.fromCharCode(rune))) return false;
    }
    return true;
  }

  /// The shareable link for [code], preferring `https` when a host is set.
  static String linkFor(String code) =>
      _httpsHost.isNotEmpty ? 'https://$_httpsHost/join/$code' : deepLinkFor(code);

  /// The app-scheme link for [code]: `com.nlp.digitox://join/AB3K7Q`.
  static String deepLinkFor(String code) => '$scheme://$joinHost/$code';

  /// Extracts a code from anything a user might supply: a bare code, an app
  /// link, an `https` link, or a URL carrying `?code=`.
  ///
  /// Returns null when no plausible code is present, so callers can show "that
  /// does not look like an invite" rather than attempting a doomed lookup.
  static String? parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      final fromQuery = uri.queryParameters['code'] ??
          uri.queryParameters['invite'] ??
          uri.queryParameters['c'];
      if (fromQuery != null) {
        final normalized = normalize(fromQuery);
        if (normalized.isNotEmpty) return _fit(normalized);
      }

      // A path segment carries the code for both link shapes.
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        final candidate = normalize(segments.last);
        if (candidate.isNotEmpty) return _fit(candidate);
      }

      // `com.nlp.digitox://join/AB3K7Q` parses the code as the *host*.
      if (uri.host.isNotEmpty && uri.host != joinHost) {
        final candidate = normalize(uri.host);
        if (candidate.isNotEmpty) return _fit(candidate);
      }
    }

    final normalized = normalize(trimmed);
    return normalized.isEmpty ? null : _fit(normalized);
  }

  /// Truncates an over-long candidate to the code length.
  ///
  /// Pasted links occasionally carry slug text after the code (`/join/AB3K7Q/x`);
  /// taking the first [length] characters keeps those working instead of
  /// rejecting a link the user was legitimately given.
  static String _fit(String candidate) =>
      candidate.length <= length ? candidate : candidate.substring(0, length);
}
