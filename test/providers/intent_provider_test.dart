import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/models/app_intent_model.dart';
import 'package:nlp_digitox/providers/system/intent_provider.dart';

void main() {
  group('IntentNotifier', () {
    test('should be initialized as empty', () {
      final container = ProviderContainer();
      final state = container.read(intentNotifierProvider);
      expect(state, equals({}));
    });

    test('recordIntent should add intent to history', () {
      final container = ProviderContainer();
      final notifier = container.read(intentNotifierProvider.notifier);

      final intent = AppIntentModel(
        id: 'intent_1',
        appPackage: 'com.example.app',
        intent: AppIntent.education,
        recordedAt: DateTime.now(),
        isAllowed: true,
      );

      notifier.recordIntent(intent);
      final state = container.read(intentNotifierProvider);

      expect(state['com.example.app'], isNotNull);
      expect(state['com.example.app']!.length, equals(1));
      expect(state['com.example.app']!.first, equals(intent));
    });

    test('recordIntent should handle multiple intents', () {
      final container = ProviderContainer();
      final notifier = container.read(intentNotifierProvider.notifier);

      final intent1 = AppIntentModel(
        id: 'intent_1',
        appPackage: 'com.example.app',
        intent: AppIntent.education,
        recordedAt: DateTime.now(),
        isAllowed: true,
      );

      final intent2 = AppIntentModel(
        id: 'intent_2',
        appPackage: 'com.example.app',
        intent: AppIntent.productivity,
        recordedAt: DateTime.now(),
        isAllowed: false,
      );

      notifier.recordIntent(intent1);
      notifier.recordIntent(intent2);
      final state = container.read(intentNotifierProvider);

      expect(state['com.example.app']!.length, equals(2));
      expect(state['com.example.app']!.last.intent, equals(AppIntent.productivity));
    });

    test('getRecentIntent should return last intent', () {
      final container = ProviderContainer();
      final notifier = container.read(intentNotifierProvider.notifier);

      final intent1 = AppIntentModel(
        id: 'intent_1',
        appPackage: 'com.example.app',
        intent: AppIntent.education,
        recordedAt: DateTime.now(),
        isAllowed: true,
      );

      final intent2 = AppIntentModel(
        id: 'intent_2',
        appPackage: 'com.example.app',
        intent: AppIntent.productivity,
        recordedAt: DateTime.now(),
        isAllowed: false,
      );

      notifier.recordIntent(intent1);
      notifier.recordIntent(intent2);

      final recent = notifier.getRecentIntent('com.example.app');
      expect(recent, equals(AppIntent.productivity));
    });

    test('getRecentIntent should return null for unknown app', () {
      final container = ProviderContainer();
      final notifier = container.read(intentNotifierProvider.notifier);

      final recent = notifier.getRecentIntent('com.unknown.app');
      expect(recent, isNull);
    });

    test('getIntentFrequency should count intents correctly', () {
      final container = ProviderContainer();
      final notifier = container.read(intentNotifierProvider.notifier);

      // Add 3 education intents and 2 productivity intents
      for (int i = 0; i < 3; i++) {
        notifier.recordIntent(AppIntentModel(
          id: 'intent_$i',
          appPackage: 'com.example.app',
          intent: AppIntent.education,
          recordedAt: DateTime.now(),
          isAllowed: true,
        ));
      }

      for (int i = 3; i < 5; i++) {
        notifier.recordIntent(AppIntentModel(
          id: 'intent_$i',
          appPackage: 'com.example.app',
          intent: AppIntent.productivity,
          recordedAt: DateTime.now(),
          isAllowed: true,
        ));
      }

      final frequency = notifier.getIntentFrequency('com.example.app');
      expect(frequency[AppIntent.education], equals(3));
      expect(frequency[AppIntent.productivity], equals(2));
    });

    test('clearHistory should remove app history', () {
      final container = ProviderContainer();
      final notifier = container.read(intentNotifierProvider.notifier);

      notifier.recordIntent(AppIntentModel(
        id: 'intent_1',
        appPackage: 'com.example.app',
        intent: AppIntent.education,
        recordedAt: DateTime.now(),
        isAllowed: true,
      ));

      var state = container.read(intentNotifierProvider);
      expect(state.containsKey('com.example.app'), isTrue);

      notifier.clearHistory('com.example.app');
      state = container.read(intentNotifierProvider);
      expect(state.containsKey('com.example.app'), isFalse);
    });

    test('clearAllHistory should clear all history', () {
      final container = ProviderContainer();
      final notifier = container.read(intentNotifierProvider.notifier);

      notifier.recordIntent(AppIntentModel(
        id: 'intent_1',
        appPackage: 'com.example.app1',
        intent: AppIntent.education,
        recordedAt: DateTime.now(),
        isAllowed: true,
      ));

      notifier.recordIntent(AppIntentModel(
        id: 'intent_2',
        appPackage: 'com.example.app2',
        intent: AppIntent.productivity,
        recordedAt: DateTime.now(),
        isAllowed: true,
      ));

      var state = container.read(intentNotifierProvider);
      expect(state.length, equals(2));

      notifier.clearAllHistory();
      state = container.read(intentNotifierProvider);
      expect(state.isEmpty, isTrue);
    });

    test('recordIntent should limit history to 100 per app', () {
      final container = ProviderContainer();
      final notifier = container.read(intentNotifierProvider.notifier);

      // Add 150 intents for one app
      for (int i = 0; i < 150; i++) {
        notifier.recordIntent(AppIntentModel(
          id: 'intent_$i',
          appPackage: 'com.example.app',
          intent: i.isEven ? AppIntent.education : AppIntent.productivity,
          recordedAt: DateTime.now(),
          isAllowed: true,
        ));
      }

      final state = container.read(intentNotifierProvider);
      expect(state['com.example.app']!.length, equals(100));
      // Should keep the most recent 100
      expect(state['com.example.app']!.first.id, equals('intent_50'));
    });
  });

  group('Intent Providers', () {
    test('recentIntentProvider should get recent intent', () {
      final container = ProviderContainer();
      final notifier = container.read(intentNotifierProvider.notifier);

      notifier.recordIntent(AppIntentModel(
        id: 'intent_1',
        appPackage: 'com.example.app',
        intent: AppIntent.education,
        recordedAt: DateTime.now(),
        isAllowed: true,
      ));

      final recent = container.read(recentIntentProvider('com.example.app'));
      expect(recent, equals(AppIntent.education));
    });

    test('recentIntentProvider should return null for unknown app', () {
      final container = ProviderContainer();
      final recent = container.read(recentIntentProvider('com.unknown.app'));
      expect(recent, isNull);
    });

    test('intentFrequencyProvider should calculate frequency', () {
      final container = ProviderContainer();
      final notifier = container.read(intentNotifierProvider.notifier);

      for (int i = 0; i < 3; i++) {
        notifier.recordIntent(AppIntentModel(
          id: 'intent_$i',
          appPackage: 'com.example.app',
          intent: AppIntent.education,
          recordedAt: DateTime.now(),
          isAllowed: true,
        ));
      }

      for (int i = 3; i < 4; i++) {
        notifier.recordIntent(AppIntentModel(
          id: 'intent_$i',
          appPackage: 'com.example.app',
          intent: AppIntent.productivity,
          recordedAt: DateTime.now(),
          isAllowed: true,
        ));
      }

      final frequency = container.read(intentFrequencyProvider('com.example.app'));
      expect(frequency[AppIntent.education], equals(3));
      expect(frequency[AppIntent.productivity], equals(1));
    });

    test('mostCommonIntentProvider should find most common intent', () {
      final container = ProviderContainer();
      final notifier = container.read(intentNotifierProvider.notifier);

      for (int i = 0; i < 5; i++) {
        notifier.recordIntent(AppIntentModel(
          id: 'intent_$i',
          appPackage: 'com.example.app',
          intent: AppIntent.education,
          recordedAt: DateTime.now(),
          isAllowed: true,
        ));
      }

      for (int i = 5; i < 7; i++) {
        notifier.recordIntent(AppIntentModel(
          id: 'intent_$i',
          appPackage: 'com.example.app',
          intent: AppIntent.productivity,
          recordedAt: DateTime.now(),
          isAllowed: true,
        ));
      }

      final mostCommon = container.read(mostCommonIntentProvider('com.example.app'));
      expect(mostCommon, equals(AppIntent.education));
    });

    test('mostCommonIntentProvider should return null for unknown app', () {
      final container = ProviderContainer();
      final mostCommon = container.read(mostCommonIntentProvider('com.unknown.app'));
      expect(mostCommon, isNull);
    });
  });

  group('Intent State Providers', () {
    test('intentHistoryProvider should be empty initially', () {
      final container = ProviderContainer();
      final history = container.read(intentHistoryProvider);
      expect(history, equals({}));
    });

    test('pendingIntentProvider should be empty initially', () {
      final container = ProviderContainer();
      final pending = container.read(pendingIntentProvider);
      expect(pending, equals({}));
    });

    test('intentRequiredAppsProvider should be empty initially', () {
      final container = ProviderContainer();
      final apps = container.read(intentRequiredAppsProvider);
      expect(apps, equals(<String>{}));
    });

    test('intentRulesProvider should have default rules', () {
      final container = ProviderContainer();
      final rules = container.read(intentRulesProvider);
      expect(rules.containsKey('social'), isTrue);
      expect(rules.containsKey('optional'), isTrue);
      expect(rules['social']!.contains(AppIntent.social), isTrue);
      expect(rules['social']!.contains(AppIntent.entertainment), isTrue);
    });
  });
}
