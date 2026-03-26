import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/models/app_intent_model.dart';
import 'package:nlp_digitox/core/services/restriction_engine.dart';

void main() {
  group('AppIntent and AppIntentModel', () {
    test('AppIntent enum should have all expected values', () {
      expect(AppIntent.values.length, equals(7));
      expect(AppIntent.values, contains(AppIntent.education));
      expect(AppIntent.values, contains(AppIntent.entertainment));
      expect(AppIntent.values, contains(AppIntent.productivity));
      expect(AppIntent.values, contains(AppIntent.social));
      expect(AppIntent.values, contains(AppIntent.health));
      expect(AppIntent.values, contains(AppIntent.utility));
      expect(AppIntent.values, contains(AppIntent.other));
    });

    test('AppIntent extension should return correct display names', () {
      expect(AppIntent.education.displayName, equals('Education'));
      expect(AppIntent.entertainment.displayName, equals('Entertainment'));
      expect(AppIntent.productivity.displayName, equals('Productivity'));
      expect(AppIntent.social.displayName, equals('Social'));
      expect(AppIntent.health.displayName, equals('Health & Fitness'));
      expect(AppIntent.utility.displayName, equals('Utility'));
      expect(AppIntent.other.displayName, equals('Other'));
    });

    test('AppIntent extension should return correct descriptions', () {
      expect(
        AppIntent.education.description,
        equals('Learning, courses, educational content'),
      );
      expect(
        AppIntent.entertainment.description,
        equals('Movies, games, entertainment content'),
      );
      expect(AppIntent.productivity.description, contains('Work'));
      expect(AppIntent.social.description, contains('Social media'));
    });

    test('AppIntentModel should create with correct properties', () {
      final now = DateTime.now();
      final model = AppIntentModel(
        id: 'intent_1',
        appPackage: 'com.example.app',
        intent: AppIntent.education,
        recordedAt: now,
        notes: 'Learning session',
        isAllowed: true,
      );

      expect(model.id, equals('intent_1'));
      expect(model.appPackage, equals('com.example.app'));
      expect(model.intent, equals(AppIntent.education));
      expect(model.recordedAt, equals(now));
      expect(model.notes, equals('Learning session'));
      expect(model.isAllowed, isTrue);
    });

    test('AppIntentModel copyWith should create modified copy', () {
      final original = AppIntentModel(
        id: 'intent_1',
        appPackage: 'com.example.app',
        intent: AppIntent.education,
        recordedAt: DateTime.now(),
        isAllowed: false,
      );

      final modified = original.copyWith(
        intent: AppIntent.productivity,
        isAllowed: true,
      );

      expect(modified.id, equals(original.id));
      expect(modified.appPackage, equals(original.appPackage));
      expect(modified.intent, equals(AppIntent.productivity));
      expect(modified.isAllowed, isTrue);
      expect(original.intent, equals(AppIntent.education)); // Original unchanged
    });

    test('AppIntentModel equality should work correctly', () {
      final now = DateTime.now();
      final model1 = AppIntentModel(
        id: 'intent_1',
        appPackage: 'com.example.app',
        intent: AppIntent.education,
        recordedAt: now,
        isAllowed: true,
      );

      final model2 = AppIntentModel(
        id: 'intent_1',
        appPackage: 'com.example.app',
        intent: AppIntent.education,
        recordedAt: DateTime(2020), // Different time
        isAllowed: true,
      );

      expect(model1, equals(model2)); // Should be equal (time not in equality)
    });

    test('AppIntentModel toString should format correctly', () {
      final model = AppIntentModel(
        id: 'intent_1',
        appPackage: 'com.example.app',
        intent: AppIntent.education,
        recordedAt: DateTime.now(),
        isAllowed: true,
      );

      final str = model.toString();
      expect(str, contains('intent_1'));
      expect(str, contains('com.example.app'));
      expect(str, contains('Education'));
      expect(str, contains('allowed: true'));
    });
  });

  group('RestrictionEngine Intent Support', () {
    test('RestrictionType should include intentRequired', () {
      expect(RestrictionType.values, contains(RestrictionType.intentRequired));
    });

    test('requiresIntentPrompt should identify social apps', () {
      final engine = RestrictionEngine.instance;

      expect(engine.requiresIntentPrompt('com.facebook.katana'), isTrue);
      expect(engine.requiresIntentPrompt('com.twitter.android'), isTrue);
      expect(engine.requiresIntentPrompt('com.instagram.android'), isTrue);
      expect(engine.requiresIntentPrompt('com.snapchat.android'), isTrue);
    });

    test('requiresIntentPrompt should identify entertainment apps', () {
      final engine = RestrictionEngine.instance;

      expect(engine.requiresIntentPrompt('com.netflix.mediaclient'), isTrue);
      expect(engine.requiresIntentPrompt('com.spotify.music'), isTrue);
      expect(engine.requiresIntentPrompt('com.youtube'), isTrue);
    });

    test('requiresIntentPrompt should return false for other apps', () {
      final engine = RestrictionEngine.instance;

      expect(engine.requiresIntentPrompt('com.google.android.calculator'), isFalse);
      expect(engine.requiresIntentPrompt('com.google.android.gms'), isFalse);
      expect(engine.requiresIntentPrompt('com.example.unknown'), isFalse);
    });

    test('recordAppIntent should not throw', () async {
      final engine = RestrictionEngine.instance;
      expect(
        () => engine.recordAppIntent('com.example.app', 'education'),
        returnsNormally,
      );
    });
  });

  group('AppIntent Default Display', () {
    test('All AppIntent values should have display names', () {
      for (final intent in AppIntent.values) {
        expect(intent.displayName, isNotEmpty);
        expect(intent.displayName, isNotEmpty);
      }
    });

    test('All AppIntent values should have descriptions', () {
      for (final intent in AppIntent.values) {
        expect(intent.description, isNotEmpty);
        expect(intent.description, isNotEmpty);
      }
    });
  });

  group('AppIntentModel Default Values', () {
    test('AppIntentModel should have default isAllowed=false', () {
      final model = AppIntentModel(
        id: 'test',
        appPackage: 'com.example',
        intent: AppIntent.education,
        recordedAt: DateTime.now(),
      );

      expect(model.isAllowed, isFalse);
    });

    test('AppIntentModel notes should be nullable', () {
      final model1 = AppIntentModel(
        id: 'test',
        appPackage: 'com.example',
        intent: AppIntent.education,
        recordedAt: DateTime.now(),
      );

      final model2 = AppIntentModel(
        id: 'test',
        appPackage: 'com.example',
        intent: AppIntent.education,
        recordedAt: DateTime.now(),
        notes: 'Some notes',
      );

      expect(model1.notes, isNull);
      expect(model2.notes, equals('Some notes'));
    });
  });

  group('Intent Blocking Decision Logic', () {
    test('RestrictionDecision.block should work with intentRequired type', () {
      final decision = RestrictionDecision.block(
        'Intent prompt required',
        RestrictionType.intentRequired,
      );

      expect(decision.canOpen, isFalse);
      expect(decision.reason, equals('Intent prompt required'));
      expect(decision.type, equals(RestrictionType.intentRequired));
    });

    test('RestrictionDecision.allow should be independent of intent', () {
      final decision = RestrictionDecision.allow();

      expect(decision.canOpen, isTrue);
      expect(decision.type, equals(RestrictionType.none));
    });
  });

  group('AppIntentModel Hash and Equality', () {
    test('AppIntentModel with same values should have same hash', () {
      final model1 = AppIntentModel(
        id: 'intent_1',
        appPackage: 'com.example.app',
        intent: AppIntent.education,
        recordedAt: DateTime(2020),
        isAllowed: true,
      );

      final model2 = AppIntentModel(
        id: 'intent_1',
        appPackage: 'com.example.app',
        intent: AppIntent.education,
        recordedAt: DateTime(2020),
        isAllowed: true,
      );

      expect(model1.hashCode, equals(model2.hashCode));
    });

    test('AppIntentModel with different values should have different hash', () {
      final model1 = AppIntentModel(
        id: 'intent_1',
        appPackage: 'com.example.app',
        intent: AppIntent.education,
        recordedAt: DateTime.now(),
        isAllowed: true,
      );

      final model2 = AppIntentModel(
        id: 'intent_2',
        appPackage: 'com.example.app',
        intent: AppIntent.education,
        recordedAt: DateTime.now(),
        isAllowed: true,
      );

      expect(model1.hashCode, isNot(equals(model2.hashCode)));
    });
  });
}
