import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/ui/common/simple_markdown.dart';

void main() {
  group('SimpleMarkdownParser — headings', () {
    test('parses # / ## / ### with their levels', () {
      final blocks = SimpleMarkdownParser.parse('# One\n## Two\n### Three');

      expect(blocks.length, 3);
      expect(blocks.every((b) => b.kind == MarkdownBlockKind.heading), isTrue);
      expect(blocks.map((b) => b.headingLevel).toList(), [1, 2, 3]);
      expect(blocks.map((b) => b.text).toList(), ['One', 'Two', 'Three']);
    });

    test('strips bold markers from a heading text', () {
      final blocks = SimpleMarkdownParser.parse('## **Executive Summary**');
      expect(blocks.single.kind, MarkdownBlockKind.heading);
      expect(blocks.single.text, 'Executive Summary');
    });

    test('a "#" without a following space is prose, not a heading', () {
      final blocks = SimpleMarkdownParser.parse('#NoSpace');
      expect(blocks.single.kind, MarkdownBlockKind.paragraph);
    });
  });

  group('SimpleMarkdownParser — lists', () {
    test('parses dash and star bullets', () {
      final blocks = SimpleMarkdownParser.parse('- one\n- two\n* three');

      expect(blocks.length, 3);
      expect(blocks.every((b) => b.kind == MarkdownBlockKind.bullet), isTrue);
      expect(blocks.map((b) => b.text).toList(), ['one', 'two', 'three']);
    });

    test('parses numbered items and records their ordinal', () {
      final blocks = SimpleMarkdownParser.parse('1. first\n2. second');

      expect(blocks.length, 2);
      expect(blocks[0].kind, MarkdownBlockKind.numbered);
      expect(blocks[0].ordinal, 1);
      expect(blocks[0].text, 'first');
      expect(blocks[1].ordinal, 2);
      expect(blocks[1].text, 'second');
    });
  });

  group('SimpleMarkdownParser — dividers', () {
    test('parses a standalone --- as a divider between paragraphs', () {
      final blocks = SimpleMarkdownParser.parse('above\n\n---\n\nbelow');

      expect(
        blocks.map((b) => b.kind).toList(),
        [
          MarkdownBlockKind.paragraph,
          MarkdownBlockKind.divider,
          MarkdownBlockKind.paragraph,
        ],
      );
    });
  });

  group('SimpleMarkdownParser — prose', () {
    test('joins consecutive lines into a single paragraph', () {
      final blocks = SimpleMarkdownParser.parse('line one\nline two');

      expect(blocks.length, 1);
      expect(blocks.single.kind, MarkdownBlockKind.paragraph);
      expect(blocks.single.text, 'line one line two');
    });

    test('a blank line starts a new paragraph', () {
      final blocks = SimpleMarkdownParser.parse('first\n\nsecond');
      expect(blocks.length, 2);
      expect(blocks.map((b) => b.text).toList(), ['first', 'second']);
    });

    test('keeps inline **bold** markers for the renderer', () {
      final blocks = SimpleMarkdownParser.parse('This is **bold** text.');
      expect(blocks.single.text, 'This is **bold** text.');
    });
  });

  group('SimpleMarkdown rendering', () {
    testWidgets('**bold** renders as an actual bold span', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SimpleMarkdown(data: 'A **bold** word')),
        ),
      );

      final richText = tester.widget<RichText>(find.byType(RichText).first);
      final boldSpans = <String>[];
      richText.text.visitChildren((span) {
        if (span is TextSpan &&
            span.style?.fontWeight == FontWeight.bold &&
            span.text != null) {
          boldSpans.add(span.text!);
        }
        return true;
      });

      expect(boldSpans, contains('bold'));
    });

    testWidgets('renders headings and bullets without throwing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleMarkdown(
              data: '# Title\n\n- bullet one\n- bullet two\n\n1. numbered',
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Title'), findsOneWidget);
      expect(find.textContaining('bullet one'), findsOneWidget);
      expect(find.textContaining('numbered'), findsOneWidget);
    });
  });
}
