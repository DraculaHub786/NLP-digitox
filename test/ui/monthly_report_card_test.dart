// Copyright (c) 2026 NLP digitox

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/ui/common/simple_markdown.dart';
import 'package:nlp_digitox/ui/screens/settings/export/monthly_report_card.dart';

/// Widget tests for [MonthlyReportCard] — the presentational half of the
/// monthly AI report. It owns no fetching, so every state can be driven purely
/// from constructor arguments.
void main() {
  const monthKey = '2026-09';

  Future<void> pumpCard(WidgetTester tester, MonthlyReportCard card) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: card)),
      ),
    );
  }

  // `FilledButton.icon` / `TextButton.icon` build private subclasses, so an
  // exact-type finder (`find.widgetWithText(FilledButton, …)`) matches nothing.
  // Match the button labelled `label` by base type instead.
  Finder buttonWithLabel<T extends Widget>(String label) => find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate((widget) => widget is T),
      );

  group('MonthlyReportCard header', () {
    testWidgets('renders the human month label for the key', (tester) async {
      await pumpCard(
        tester,
        const MonthlyReportCard(monthKey: monthKey, isCurrentMonth: true),
      );

      expect(find.text('September 2026'), findsOneWidget);
    });

    testWidgets('shows the average score only when one is supplied',
        (tester) async {
      await pumpCard(
        tester,
        const MonthlyReportCard(monthKey: monthKey, averageScore: 0.5),
      );
      expect(find.text('avg 0.50'), findsOneWidget);

      await pumpCard(tester, const MonthlyReportCard(monthKey: monthKey));
      expect(find.textContaining('avg '), findsNothing);
    });
  });

  group('MonthlyReportCard states', () {
    testWidgets('busy state shows progress and hides actions', (tester) async {
      await pumpCard(
        tester,
        MonthlyReportCard(
          monthKey: monthKey,
          isBusy: true,
          onGenerate: () {},
          onCopy: () {},
        ),
      );

      expect(
        find.textContaining('Analysing your last 30 days'),
        findsOneWidget,
      );
      expect(find.byType(SimpleMarkdown), findsNothing);
      expect(buttonWithLabel<TextButton>('Copy'), findsNothing);
    });

    testWidgets('empty state invites generation and fires the callback',
        (tester) async {
      var generateCalls = 0;
      await pumpCard(
        tester,
        MonthlyReportCard(
          monthKey: monthKey,
          isCurrentMonth: true,
          onGenerate: () => generateCalls++,
        ),
      );

      expect(
        find.textContaining('No report for this month yet'),
        findsOneWidget,
      );
      final generateButton = buttonWithLabel<FilledButton>('Generate report');
      expect(generateButton, findsOneWidget);

      await tester.tap(generateButton);
      await tester.pump();

      expect(generateCalls, 1);
    });

    testWidgets('error state shows the message and a retry action',
        (tester) async {
      var retryCalls = 0;
      await pumpCard(
        tester,
        MonthlyReportCard(
          monthKey: monthKey,
          error: 'Report generation failed.',
          onRegenerate: () => retryCalls++,
        ),
      );

      expect(find.text('Report generation failed.'), findsOneWidget);
      final retry = buttonWithLabel<FilledButton>('Try again');
      expect(retry, findsOneWidget);

      await tester.tap(retry);
      await tester.pump();

      expect(retryCalls, 1);
    });

    testWidgets('report state renders the markdown body and both actions',
        (tester) async {
      const body = '# Executive Summary\n\nYou had a **steady** month.';
      var copyCalls = 0;
      var regenerateCalls = 0;

      await pumpCard(
        tester,
        MonthlyReportCard(
          monthKey: monthKey,
          report: body,
          onCopy: () => copyCalls++,
          onRegenerate: () => regenerateCalls++,
        ),
      );

      final markdown =
          tester.widget<SimpleMarkdown>(find.byType(SimpleMarkdown));
      expect(markdown.data, body);

      final copy = buttonWithLabel<TextButton>('Copy');
      final regenerate = buttonWithLabel<TextButton>('Regenerate');
      expect(copy, findsOneWidget);
      expect(regenerate, findsOneWidget);

      await tester.tap(copy);
      await tester.tap(regenerate);
      await tester.pump();

      expect(copyCalls, 1);
      expect(regenerateCalls, 1);
    });

    testWidgets('a whitespace-only report is treated as empty', (tester) async {
      await pumpCard(
        tester,
        MonthlyReportCard(
          monthKey: monthKey,
          report: '   \n  ',
          isCurrentMonth: true,
          onGenerate: () {},
        ),
      );

      expect(find.byType(SimpleMarkdown), findsNothing);
      expect(
        buttonWithLabel<FilledButton>('Generate report'),
        findsOneWidget,
      );
    });
  });
}
