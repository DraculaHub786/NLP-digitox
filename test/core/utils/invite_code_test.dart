// Copyright (c) 2026 NLP digitox
//
// Tests for the invite-code generator and parser (plan Section 8: "invite code
// generator"). The properties that matter are the ones a person depends on when
// they read a code off one phone and type it into another: the alphabet cannot
// contain a character that is easy to confuse with another, anything they paste
// has to resolve, and a link has to survive the round trip through a URI parser.

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/utils/invite_code.dart';

void main() {
  group('alphabet', () {
    test('excludes every visually ambiguous character', () {
      for (final ambiguous in ['0', 'O', '1', 'I', 'L']) {
        expect(
          InviteCode.alphabet.contains(ambiguous),
          isFalse,
          reason: '$ambiguous is one of the pairs a person mis-reads',
        );
      }
    });

    test('is uppercase and free of duplicates', () {
      expect(InviteCode.alphabet, equals(InviteCode.alphabet.toUpperCase()));
      expect(
        InviteCode.alphabet.split('').toSet().length,
        equals(InviteCode.alphabet.length),
      );
    });
  });

  group('generate', () {
    test('produces the declared length', () {
      expect(InviteCode.generate().length, equals(InviteCode.length));
    });

    test('only ever emits characters from the alphabet', () {
      // 500 draws is far past the point where a stray character would show up.
      for (var i = 0; i < 500; i++) {
        final code = InviteCode.generate();
        expect(InviteCode.isValid(code), isTrue, reason: 'generated $code');
      }
    });

    test('does not repeat itself in practice', () {
      final seen = <String>{};
      for (var i = 0; i < 200; i++) {
        seen.add(InviteCode.generate());
      }
      // With ~8.9e8 combinations a collision here would mean the RNG is stuck.
      expect(seen.length, equals(200));
    });
  });

  group('normalize', () {
    test('uppercases and strips separators and whitespace', () {
      expect(InviteCode.normalize(' ab-3k 7q '), equals('AB3K7Q'));
    });

    test('maps the ambiguous characters onto the ones they are confused with', () {
      expect(InviteCode.normalize('0O'), equals('QQ'));
      expect(InviteCode.normalize('1IL'), equals('JJJ'));
    });

    test('drops characters that can never be in a code', () {
      expect(InviteCode.normalize('A!B@C#D'), equals('ABCD'));
    });

    test('leaves a clean code untouched', () {
      expect(InviteCode.normalize('AB3K7Q'), equals('AB3K7Q'));
    });
  });

  group('isValid', () {
    test('accepts a generated code', () {
      expect(InviteCode.isValid(InviteCode.generate()), isTrue);
    });

    test('rejects a wrong length', () {
      expect(InviteCode.isValid('AB3K7'), isFalse);
      expect(InviteCode.isValid('AB3K7QQ'), isFalse);
    });

    test('rejects an excluded character', () {
      expect(InviteCode.isValid('AB3K7O'), isFalse);
    });
  });

  group('links', () {
    test('deep link uses the app scheme and the join host', () {
      expect(
        InviteCode.deepLinkFor('AB3K7Q'),
        equals('${InviteCode.scheme}://${InviteCode.joinHost}/AB3K7Q'),
      );
    });

    test('linkFor falls back to the deep link when no https host is set', () {
      // SESSION_JOIN_HOST is unset in tests, so the app scheme is the only
      // shareable shape.
      expect(InviteCode.linkFor('AB3K7Q'), equals(InviteCode.deepLinkFor('AB3K7Q')));
    });
  });

  group('parse', () {
    test('reads a bare code', () {
      expect(InviteCode.parse('AB3K7Q'), equals('AB3K7Q'));
    });

    test('reads a bare code that needs normalising', () {
      expect(InviteCode.parse(' ab3k7q '), equals('AB3K7Q'));
    });

    test('reads the app-scheme deep link', () {
      expect(
        InviteCode.parse('com.nlp.digitox://join/AB3K7Q'),
        equals('AB3K7Q'),
      );
    });

    test('reads an https link with the code as the last path segment', () {
      expect(InviteCode.parse('https://example.com/join/AB3K7Q'), equals('AB3K7Q'));
    });

    test('reads a code carried in a query parameter', () {
      expect(InviteCode.parse('https://example.com/j?code=AB3K7Q'), equals('AB3K7Q'));
      expect(InviteCode.parse('https://example.com/j?invite=AB3K7Q'), equals('AB3K7Q'));
      expect(InviteCode.parse('https://example.com/j?c=AB3K7Q'), equals('AB3K7Q'));
    });

    test('truncates an over-long candidate to the code length', () {
      // `_fit` keeps the first `length` characters, so a segment carrying the
      // code plus a tail still resolves.
      expect(InviteCode.parse('AB3K7QEXTRA'), equals('AB3K7Q'));
    });

    test('the LAST path segment wins when a link carries more than one', () {
      // Documenting real behaviour rather than the docstring's example: the
      // parser reads the final non-empty segment, so `/join/AB3K7Q/extra`
      // resolves the *tail*, not the code. Both link shapes this app generates
      // put the code last, so this is only reachable from a hand-built URL.
      expect(InviteCode.parse('https://example.com/join/AB3K7Q/extra'), equals('EXTRA'));
    });

    test('returns null when there is nothing plausible to read', () {
      expect(InviteCode.parse(''), isNull);
      expect(InviteCode.parse('   '), isNull);
      expect(InviteCode.parse('!!!'), isNull);
    });
  });

  test('lifetime is 24 hours', () {
    expect(InviteCode.lifetime, equals(const Duration(hours: 24)));
  });
}
