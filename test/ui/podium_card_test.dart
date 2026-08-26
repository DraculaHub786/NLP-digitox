import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/ui/screens/leaderboard/podium_card.dart';

void main() {
  Future<void> pumpPodium(WidgetTester tester, {double textScale = 1.0}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE1793C)),
        ),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: PodiumCard(rank: 2, name: 'Second', points: 80)),
                Expanded(child: PodiumCard(rank: 1, name: 'First', points: 120)),
                Expanded(child: PodiumCard(rank: 3, name: 'Third', points: 60)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('ranks 1-3 render without RenderFlex overflow', (tester) async {
    await pumpPodium(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    expect(find.text('Third'), findsOneWidget);
    expect(find.text('120 pts'), findsOneWidget);
    expect(find.text('80 pts'), findsOneWidget);
    expect(find.text('60 pts'), findsOneWidget);
  });

  testWidgets('long usernames still fit without overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE1793C)),
        ),
        home: const Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: PodiumCard(
                  rank: 3,
                  name: 'AQuiteLongUsernameThatTriesHard',
                  points: 99999,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('large system font scale does not overflow', (tester) async {
    await pumpPodium(tester, textScale: 1.6);
    expect(tester.takeException(), isNull);

    await pumpPodium(tester, textScale: 2.0);
    expect(tester.takeException(), isNull);
  });
}
