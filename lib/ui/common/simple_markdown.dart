// Copyright (c) 2026 NLP digitox

import 'package:flutter/material.dart';

/// Renders the subset of Markdown that the AI wellbeing reports actually use.
///
/// `pubspec.yaml` has no markdown package and the reports arrive as plain text
/// from the model, so a full parser is not available. This covers exactly what
/// the report prompt asks for — `#`/`##`/`###` headings, `-`/`*` bullets,
/// `1.` numbered items, `---` dividers, and `**bold**` / `*italic*` /
/// `` `code` `` inline spans — and falls back to plain paragraphs for anything
/// it does not recognise, so unknown syntax renders as readable prose rather
/// than disappearing.
class SimpleMarkdown extends StatelessWidget {
  const SimpleMarkdown({
    super.key,
    required this.data,
    this.baseFontSize = 13,
  });

  /// The raw Markdown source.
  final String data;

  /// Body font size; headings scale relative to it.
  final double baseFontSize;

  @override
  Widget build(BuildContext context) {
    final blocks = SimpleMarkdownParser.parse(data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < blocks.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : blocks[i].topSpacing),
            child: _buildBlock(context, blocks[i]),
          ),
      ],
    );
  }

  Widget _buildBlock(BuildContext context, MarkdownBlock block) {
    final colors = Theme.of(context).colorScheme;
    final textColor = colors.onSurface;

    switch (block.kind) {
      case MarkdownBlockKind.divider:
        return Divider(
          height: 1,
          thickness: 1,
          color: colors.outlineVariant.withValues(alpha: 0.6),
        );

      case MarkdownBlockKind.heading:
        return Text.rich(
          TextSpan(
            children: _parseInline(
              block.text,
              _headingStyle(context, block.headingLevel),
            ),
          ),
        );

      case MarkdownBlockKind.bullet:
        return _withMarker(
          context,
          marker: '\u2022',
          child: _bodyText(block.text, textColor),
        );

      case MarkdownBlockKind.numbered:
        return _withMarker(
          context,
          marker: '${block.ordinal}.',
          child: _bodyText(block.text, textColor),
        );

      case MarkdownBlockKind.quote:
        return Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: colors.outlineVariant, width: 3),
            ),
          ),
          child: _bodyText(block.text, colors.onSurfaceVariant,
              italic: true),
        );

      case MarkdownBlockKind.paragraph:
        return _bodyText(block.text, textColor);
    }
  }

  Widget _withMarker(
    BuildContext context, {
    required String marker,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Text(
            marker,
            style: TextStyle(
              fontSize: baseFontSize,
              height: 1.45,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _bodyText(String text, Color color, {bool italic = false}) {
    return Text.rich(
      TextSpan(
        children: _parseInline(
          text,
          TextStyle(
            fontSize: baseFontSize,
            height: 1.45,
            color: color,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }

  TextStyle _headingStyle(BuildContext context, int level) {
    final scale = switch (level) {
      1 => 1.55,
      2 => 1.35,
      3 => 1.18,
      _ => 1.08,
    };
    return TextStyle(
      fontFamily: 'Alice',
      fontSize: baseFontSize * scale,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}

/// Builds the styled spans for one line, resolving `**bold**`, `*italic*` and
/// `` `code` `` inline markers into [TextSpan]s.
List<TextSpan> _parseInline(String text, TextStyle baseStyle) {
  final spans = <TextSpan>[];
  final plain = StringBuffer();
  var index = 0;

  void flushPlain() {
    if (plain.isEmpty) return;
    spans.add(TextSpan(text: plain.toString(), style: baseStyle));
    plain.clear();
  }

  while (index < text.length) {
    if (text.startsWith('**', index)) {
      final end = text.indexOf('**', index + 2);
      if (end > index + 2) {
        flushPlain();
        spans.add(TextSpan(
          text: text.substring(index + 2, end),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ));
        index = end + 2;
        continue;
      }
    }

    final char = text[index];
    if (char == '`' || char == '*') {
      final end = text.indexOf(char, index + 1);
      if (end > index + 1) {
        final inner = text.substring(index + 1, end);
        // A lone `*` surrounded by spaces is punctuation, not emphasis.
        if (char == '`' || inner.trim() == inner) {
          flushPlain();
          spans.add(TextSpan(
            text: inner,
            style: char == '`'
                ? baseStyle.copyWith(
                    fontFamily: 'monospace',
                    backgroundColor:
                        baseStyle.color?.withValues(alpha: 0.08),
                  )
                : baseStyle.copyWith(fontStyle: FontStyle.italic),
          ));
          index = end + 1;
          continue;
        }
      }
    }

    plain.write(char);
    index++;
  }

  flushPlain();
  return spans;
}

/// One parsed Markdown block.
enum MarkdownBlockKind { heading, bullet, numbered, quote, divider, paragraph }

@immutable
class MarkdownBlock {
  const MarkdownBlock({
    required this.kind,
    required this.text,
    this.headingLevel = 0,
    this.ordinal = 0,
  });

  final MarkdownBlockKind kind;
  final String text;
  final int headingLevel;

  /// 1-based number for [MarkdownBlockKind.numbered] items.
  final int ordinal;

  /// Vertical gap to insert above this block.
  double get topSpacing => switch (kind) {
        MarkdownBlockKind.heading => 16,
        MarkdownBlockKind.divider => 12,
        MarkdownBlockKind.paragraph => 10,
        _ => 4,
      };
}

/// Line-oriented parser backing [SimpleMarkdown].
abstract final class SimpleMarkdownParser {
  static List<MarkdownBlock> parse(String source) {
    final blocks = <MarkdownBlock>[];
    final paragraph = StringBuffer();

    void flushParagraph() {
      if (paragraph.isEmpty) return;
      blocks.add(MarkdownBlock(
        kind: MarkdownBlockKind.paragraph,
        text: paragraph.toString(),
      ));
      paragraph.clear();
    }

    for (final rawLine in source.split('\n')) {
      final line = rawLine.trim();

      if (line.isEmpty) {
        flushParagraph();
        continue;
      }

      final heading = _matchHeading(line);
      if (heading != null) {
        flushParagraph();
        blocks.add(heading);
        continue;
      }

      if (_isDivider(line)) {
        flushParagraph();
        blocks.add(const MarkdownBlock(
          kind: MarkdownBlockKind.divider,
          text: '',
        ));
        continue;
      }

      final numbered = _matchNumbered(line);
      if (numbered != null) {
        flushParagraph();
        blocks.add(numbered);
        continue;
      }

      if (line.startsWith('- ') || line.startsWith('* ') ||
          line.startsWith('\u2022 ')) {
        flushParagraph();
        blocks.add(MarkdownBlock(
          kind: MarkdownBlockKind.bullet,
          text: line.substring(2).trim(),
        ));
        continue;
      }

      if (line.startsWith('> ')) {
        flushParagraph();
        blocks.add(MarkdownBlock(
          kind: MarkdownBlockKind.quote,
          text: line.substring(2).trim(),
        ));
        continue;
      }

      // Hard-wrapped prose: join consecutive lines into one paragraph so the
      // model's 80-column wrapping does not turn into ragged one-line blocks.
      if (paragraph.isNotEmpty) paragraph.write(' ');
      paragraph.write(line);
    }

    flushParagraph();
    return blocks;
  }

  /// Matches `#`..`######` followed by a space.
  static MarkdownBlock? _matchHeading(String line) {
    var level = 0;
    while (level < line.length && line[level] == '#') {
      level++;
    }
    if (level == 0 || level > 6) return null;
    if (level >= line.length || line[level] != ' ') return null;

    final text = line.substring(level).trim();
    if (text.isEmpty) return null;
    // A heading written as `## **Title**` should not keep the bold markers.
    final cleaned = text.replaceAll('**', '').replaceAll('__', '');
    return MarkdownBlock(
      kind: MarkdownBlockKind.heading,
      text: cleaned,
      headingLevel: level,
    );
  }

  static MarkdownBlock? _matchNumbered(String line) {
    var digits = 0;
    while (digits < line.length && _isDigit(line.codeUnitAt(digits))) {
      digits++;
    }
    if (digits == 0 || digits > 2) return null;
    if (digits + 1 >= line.length) return null;
    if (line[digits] != '.' && line[digits] != ')') return null;
    if (line[digits + 1] != ' ') return null;

    final text = line.substring(digits + 1).trim();
    if (text.isEmpty) return null;
    return MarkdownBlock(
      kind: MarkdownBlockKind.numbered,
      text: text,
      ordinal: int.tryParse(line.substring(0, digits)) ?? 0,
    );
  }

  static bool _isDivider(String line) {
    if (line.length < 3) return false;
    final char = line[0];
    if (char != '-' && char != '*' && char != '_') return false;
    for (final c in line.split('')) {
      if (c != char) return false;
    }
    return true;
  }

  static bool _isDigit(int codeUnit) => codeUnit >= 0x30 && codeUnit <= 0x39;
}
