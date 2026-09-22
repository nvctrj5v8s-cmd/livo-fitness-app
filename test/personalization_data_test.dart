import 'dart:convert';

import 'package:fitness_ai_app/core/models/app_models.dart';
import 'package:fitness_ai_app/features/onboarding/data/personalization_store.dart';
import 'package:fitness_ai_app/features/onboarding/domain/personalization_profile.dart';
import 'package:fitness_ai_app/features/onboarding/domain/recipe_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// The async API's official in-memory test platform ships with this dependency.
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const _profile = PersonalizationProfile(
  displayName: 'Mina',
  goal: PersonalGoal.buildStrength,
  activity: ActivityPattern.oftenMoving,
  usualMeals: 2,
  desiredMeals: 4,
  nutrition: NutritionPreference.vegetarian,
  allergies: 'Erdnüsse',
  cookingMinutes: 30,
  focus: RoutineFocus.budget,
);

void main() {
  group('PersonalizationProfile', () {
    test('typed answers survive a JSON round trip', () {
      final encoded = jsonEncode(_profile.toJson());
      final restored = PersonalizationProfile.fromJson(
        jsonDecode(encoded) as Map<String, dynamic>,
      );

      expect(restored.toJson(), _profile.toJson());
      expect(restored.goal, PersonalGoal.buildStrength);
      expect(restored.activity, ActivityPattern.oftenMoving);
      expect(restored.nutrition, NutritionPreference.vegetarian);
      expect(restored.allergies, 'Erdnüsse');
      expect(restored.focus, RoutineFocus.budget);
      expect(restored.usualMeals, 2);
      expect(restored.desiredMeals, 4);
      expect(restored.cookingMinutes, 30);
    });

    test('omitted edits preserve answers while explicit null clears them', () {
      final renamed = _profile.copyWith(displayName: 'Nora');
      expect(renamed.toJson(), {..._profile.toJson(), 'display_name': 'Nora'});

      final cleared = _profile.copyWith(
        goal: null,
        activity: null,
        usualMeals: null,
        desiredMeals: null,
        nutrition: null,
        allergies: '',
        cookingMinutes: null,
        focus: null,
      );
      expect(
        cleared.toJson(),
        const PersonalizationProfile(displayName: 'Mina').toJson(),
      );
      expect(_profile.desiredMeals, 4);
    });

    test(
      'missing and invalid answers stay unknown without invented defaults',
      () {
        final restored = PersonalizationProfile.fromJson({
          'version': 1,
          'display_name': 123,
          'goal': 'unrecognized',
          'activity': false,
          'usual_meals': 6,
          'desired_meals': 3.0,
          'nutrition': 'Low Carb',
          'cooking_minutes': '30',
          'focus': <String>[],
        });

        expect(restored.toJson(), const PersonalizationProfile().toJson());
        expect(
          PersonalizationProfile.fromJson({'version': 1}).toJson(),
          const PersonalizationProfile().toJson(),
        );
      },
    );

    test('unknown schema versions fail instead of completing setup', () {
      for (final version in <Object?>[null, 0, 2, '1']) {
        expect(
          () => PersonalizationProfile.fromJson({'version': version}),
          throwsFormatException,
        );
      }
    });

    test('name is trimmed and stored input is length limited', () {
      expect(
        PersonalizationProfile.fromJson({
          'version': 1,
          'display_name': '  Mina  ',
        }).displayName,
        'Mina',
      );
      expect(
        PersonalizationProfile.fromJson({
          'version': 1,
          'display_name': List.filled(45, 'A').join(),
        }).displayName.length,
        40,
      );
    });

    test('prepared context excludes identity and disables prescriptions', () {
      final context = _profile.toPreferenceContext();

      expect(context, isNot(contains('display_name')));
      expect(context, isNot(contains('name')));
      expect(context, isNot(contains('user_id')));
      expect(context.values, isNot(contains('Mina')));
      expect(context['usual_meals'], 2);
      expect(context['desired_meals'], 4);
      expect(context['allergies'], 'Erdnüsse');
      expect(context['suitability_screening'], 'not_performed');
      expect(context['allow_medical_advice'], isFalse);
      expect(context['allow_automatic_calorie_targets'], isFalse);
      expect(context, isNot(contains('calorie_goal')));
      expect(context, isNot(contains('calorie_target')));
    });
  });

  group('recipe preference ranking', () {
    test('dietary metadata outranks convenience without excluding recipes', () {
      final recipes = [
        _recipe('quick-budget', minutes: 10, tags: ['Budget']),
        _recipe('unverified-vegan-title', title: 'Vegane Bowl', minutes: 8),
        _recipe('tagged-vegan', minutes: 45, tags: ['VeGaN']),
      ];
      final ranked = prioritizeRecipes(
        recipes,
        _profile.copyWith(
          nutrition: NutritionPreference.vegan,
          cookingMinutes: 15,
        ),
      );

      expect(_ids(ranked), [
        'tagged-vegan',
        'quick-budget',
        'unverified-vegan-title',
      ]);
      expect(ranked, unorderedEquals(recipes));
      expect(_ids(recipes), [
        'quick-budget',
        'unverified-vegan-title',
        'tagged-vegan',
      ]);
    });

    test('equal scores preserve catalog order and return a separate list', () {
      final recipes = [
        _recipe('first', minutes: 12),
        _recipe('second', minutes: 12),
        _recipe('third', minutes: 12),
      ];
      final ranked = prioritizeRecipes(recipes, _profile);

      expect(_ids(ranked), ['first', 'second', 'third']);
      expect(identical(ranked, recipes), isFalse);
      ranked.removeLast();
      expect(recipes, hasLength(3));
      expect(_ids(prioritizeRecipes(recipes, null)), _ids(recipes));
      expect(identical(prioritizeRecipes(recipes, null), recipes), isFalse);
    });

    test('vegetarian preference accepts explicit vegan metadata', () {
      final recipes = [
        _recipe('unknown'),
        _recipe('vegan', tags: ['vegan']),
        _recipe('vegetarian', tags: ['vegetarian']),
      ];

      expect(_ids(prioritizeRecipes(recipes, _profile)), [
        'vegan',
        'vegetarian',
        'unknown',
      ]);
    });

    test(
      'time focus uses a quick default but never treats unknown as quick',
      () {
        final recipes = [
          _recipe('unknown', minutes: 0),
          _recipe('half-hour', minutes: 30),
          _recipe('quick', minutes: 15),
        ];
        const profile = PersonalizationProfile(focus: RoutineFocus.time);

        expect(_ids(prioritizeRecipes(recipes, profile)), [
          'quick',
          'unknown',
          'half-hour',
        ]);
        expect(
          _ids(
            prioritizeRecipes(recipes, profile.copyWith(cookingMinutes: 30)),
          ),
          ['half-hour', 'quick', 'unknown'],
        );
      },
    );
  });

  group('DevicePersonalizationStore', () {
    const store = DevicePersonalizationStore();
    SharedPreferencesAsyncPlatform? previousPlatform;

    setUp(() {
      previousPlatform = SharedPreferencesAsyncPlatform.instance;
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    tearDown(() {
      SharedPreferencesAsyncPlatform.instance = previousPlatform;
    });

    test('new account has no decision or fabricated profile', () async {
      final record = await store.load('new-account');

      expect(record.hasDecision, isFalse);
      expect(record.profile, isNull);
      expect(record.deferred, isFalse);
    });

    test(
      'accounts stay separate across save and new store instances',
      () async {
        await store.save('account/a', _profile);
        final otherProfile = _profile.copyWith(
          displayName: 'Nora',
          desiredMeals: 3,
        );
        await store.save('account%2Fa', otherProfile);
        const reopened = DevicePersonalizationStore();

        expect(
          (await reopened.load('account/a')).profile?.toJson(),
          _profile.toJson(),
        );
        expect(
          (await reopened.load('account%2Fa')).profile?.toJson(),
          otherProfile.toJson(),
        );
        expect((await reopened.load('account/a')).hasDecision, isTrue);
      },
    );

    test(
      'deferring stores only a decision and later answers replace it',
      () async {
        await store.save('account-a', _profile);
        await store.defer('account-a');
        final deferred = await store.load('account-a');

        expect(deferred.hasDecision, isTrue);
        expect(deferred.deferred, isTrue);
        expect(deferred.profile, isNull);

        await store.save('account-a', const PersonalizationProfile());
        final completedWithoutAnswers = await store.load('account-a');
        expect(completedWithoutAnswers.hasDecision, isTrue);
        expect(completedWithoutAnswers.deferred, isFalse);
        expect(
          completedWithoutAnswers.profile?.toJson(),
          const PersonalizationProfile().toJson(),
        );
      },
    );

    test(
      'clearing one account preserves other accounts and unrelated data',
      () async {
        await store.save('account-a', _profile);
        await store.defer('account-b');
        await SharedPreferencesAsync().setBool('unrelated.introduction', true);

        await store.clear('account-a');

        expect((await store.load('account-a')).hasDecision, isFalse);
        expect((await store.load('account-b')).deferred, isTrue);
        expect(
          await SharedPreferencesAsync().getBool('unrelated.introduction'),
          isTrue,
        );
      },
    );

    test('corrupt or unsupported storage never counts as completion', () async {
      for (final raw in ['broken JSON', '[]', '{"version":2}']) {
        SharedPreferencesAsyncPlatform.instance =
            InMemorySharedPreferencesAsync.withData({
              'livo.personalization.v1.account-a': raw,
            });
        await expectLater(store.load('account-a'), throwsFormatException);
      }
    });
  });
}

Recipe _recipe(
  String id, {
  String? title,
  int minutes = 20,
  List<String> tags = const [],
}) => Recipe(
  id: id,
  title: title ?? id,
  subtitle: '',
  minutes: minutes,
  calories: 500,
  protein: 20,
  imageAsset: '',
  tags: tags,
);

List<String> _ids(List<Recipe> recipes) =>
    recipes.map((recipe) => recipe.id).toList();
