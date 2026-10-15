import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fitness_ai_app/app/app.dart';
import 'package:fitness_ai_app/core/data/ai_coach_service.dart';
import 'package:fitness_ai_app/core/data/barcode_lookup_service.dart';
import 'package:fitness_ai_app/core/data/halal_content_policy.dart';
import 'package:fitness_ai_app/core/data/supabase_catalog_repository.dart';
import 'package:fitness_ai_app/core/models/app_models.dart';
import 'package:fitness_ai_app/core/models/progress_models.dart';
import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/auth/presentation/auth_page.dart';
import 'package:fitness_ai_app/features/diary/presentation/custom_food_sheet.dart';
import 'package:fitness_ai_app/features/discover/domain/recipe_filter.dart';
import 'package:fitness_ai_app/features/discover/domain/recipe_serving.dart';
import 'package:fitness_ai_app/features/discover/domain/ingredient_match.dart';
import 'package:fitness_ai_app/features/discover/presentation/cook_from_pantry_page.dart';
import 'package:fitness_ai_app/features/discover/presentation/cook_mode_page.dart';
import 'package:fitness_ai_app/features/discover/presentation/recipe_detail_sections.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/introduction_page.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/personalization_page.dart';
import 'package:fitness_ai_app/features/onboarding/domain/personalization_profile.dart';
import 'package:fitness_ai_app/features/subscription/presentation/paywall_page.dart';
import 'package:fitness_ai_app/l10n/catalog_text.dart';
import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:fitness_ai_app/l10n/locale_controller.dart';
import 'package:fitness_ai_app/features/language/presentation/language_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'support/recipe_fixtures.dart' show recipeTestController, setTestScreen;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<dynamic> sourceRecipes;
  late Map<String, String> catalogueTranslations;

  setUpAll(() async {
    await CatalogText.load();
    sourceRecipes =
        jsonDecode(
              File(
                'supabase/imports/i18n/source/recipes_de.json',
              ).readAsStringSync(),
            )
            as List;
    catalogueTranslations = Map<String, String>.from(
      jsonDecode(File('assets/l10n/catalog_en.json').readAsStringSync()) as Map,
    );
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    L10n.use(L10n.english);
  });
  tearDown(() => L10n.use(L10n.german));

  test('every current catalogue text has an English translation', () {
    final missing = <String>{};
    void check(Object? value) {
      if (value is String &&
          value.isNotEmpty &&
          !catalogueTranslations.containsKey(value)) {
        missing.add(value);
      }
      if (value is List) {
        for (final item in value) {
          check(item);
        }
      }
      if (value is Map) {
        for (final entry in value.entries) {
          if (entry.key != 'slug' && entry.key != 'food_slug') {
            check(entry.value);
          }
        }
      }
    }

    check(sourceRecipes);
    check(
      jsonDecode(
        File(
          'supabase/imports/i18n/source/curated_foods_de.json',
        ).readAsStringSync(),
      ),
    );
    expect(missing, isEmpty, reason: missing.join('\n'));
    expect(sourceRecipes.length, 40);
  });

  test(
    'recipe display changes language without changing safety data or nutrition',
    () {
      final recipe = _recipe(sourceRecipes.first as Map<String, dynamic>);
      final originalNutrition = recipe.nutrition.calories;
      expect(recipe.displayTitle, 'Apple cinnamon porridge');
      expect(recipe.steps.first.displayText, startsWith('Bring the oats'));
      expect(
        recipe.premiumDetails!.displayCommonMistakes.first,
        startsWith('Heat that is too high'),
      );
      expect(recipe.title, 'Apfel-Zimt-Porridge');
      expect(recipe.premiumDetails!.stepTips.first, startsWith('Regelmäßig'));
      expect(recipeMatchesQuery(recipe, 'breakfast'), isTrue);
      expect(recipeMatchesQuery(recipe, 'quick'), isTrue);
      expect(ProgressPeriod.threeMonths.label, '3 months');
      L10n.use(L10n.german);
      expect(recipe.displayTitle, 'Apfel-Zimt-Porridge');
      expect(recipe.nutrition.calories, originalNutrition);
      expect(ProgressPeriod.threeMonths.label, '3 Monate');
    },
  );

  test('coach and photo requests carry the active language', () async {
    final calls = <Map<String, Object?>>[];
    final service = AiCoachService(
      invoker: (body, {timeout}) async {
        calls.add(body);
        return const FunctionResponse(
          status: 200,
          data: {
            'answer': 'A balanced meal idea.',
            'remaining': 3,
            'daily_limit': 50,
          },
        );
      },
    );
    await service.send(message: 'A meal idea?', context: const {});
    await service.analyzeImage(
      bytes: Uint8List.fromList([1, 2, 3]),
      mimeType: 'image/jpeg',
      context: const {},
    );
    expect(calls.map((call) => call['locale']), everyElement('en'));
    L10n.use(L10n.german);
    await service.send(message: 'Eine Idee?', context: const {});
    expect(calls.last['locale'], 'de');
  });

  test('English errors, ingredients and scaled measures stay localized', () {
    expect(
      BarcodeLookupService.errorFromPayload({
        'error': 'Produkt nicht gefunden.',
        'code': 'not_found',
      })!.message,
      'This product was not found.',
    );
    expect(
      HalalContentPolicy.restrictionReason('uncertified chicken'),
      contains('explicit halal label'),
    );
    expect(
      AppController.diaryErrorMessage(Exception('offline')),
      startsWith('Connecting to your diary'),
    );
    expect(AppFormat.decimal(-0.5), '-0.5');
    expect(WeightPace.steady.label, 'Steady');
    for (final (english, german) in [
      ('chickpeas', 'Kichererbsen'),
      ('cheese', 'Käse'),
      ('peppers', 'Paprika'),
      ('sweet potatoes', 'Süßkartoffeln'),
      ('coconut milk', 'Kokosmilch'),
    ]) {
      expect(ingredientNamesMatch(english, german), isTrue, reason: english);
    }
    expect(ingredientNamesMatch('coconut milk', 'Milch'), isFalse);
    expect(ingredientNamesMatch('sweet potatoes', 'Kartoffeln'), isFalse);
    expect(CatalogText.measure('1 Paprika'), '1 pepper');
    expect(CatalogText.measure('½ Paprika'), '½ pepper');
    expect(CatalogText.measure('2½ Paprika'), '2½ peppers');
    for (final recipe in sourceRecipes.cast<Map<String, dynamic>>()) {
      for (final ingredient in (recipe['ingredients'] as List).cast<Map>()) {
        final measure = ingredient['measure'] as String?;
        for (final factor in [0.5, 0.75, 1.0, 1.5, 2.0, 3.0]) {
          final scaled = scaleHouseholdMeasure(measure, factor);
          if (scaled == null) continue;
          expect(
            CatalogText.measure(scaled),
            isNot(
              matches(
                RegExp(
                  r'[äöüß]|\b(EL|TL|Zehen|Dosen|Eier|Stück|kleine|Zwiebeln)\b',
                ),
              ),
            ),
            reason: scaled,
          );
        }
      }
    }
  });

  testWidgets(
    'device changes, manual override and returning to automatic language',
    (tester) async {
      final store = MemoryLocaleStore();
      final locales = LocaleController(store: store, device: L10n.english);
      addTearDown(locales.dispose);
      await locales.load();
      await tester.pumpWidget(
        FitnessAiApp(useAuth: false, localeController: locales),
      );
      await tester.pumpAndSettle();
      expect(find.text('Your day'), findsOneWidget);
      locales.didChangeLocales([L10n.german]);
      await tester.pumpAndSettle();
      expect(find.text('Dein Tag'), findsOneWidget);
      await locales.choose(L10n.english);
      locales.didChangeLocales([L10n.german]);
      await tester.pumpAndSettle();
      expect(find.text('Your day'), findsOneWidget);
      await locales.useDeviceLanguage();
      await tester.pumpAndSettle();
      expect(find.text('Dein Tag'), findsOneWidget);
      expect(store.code, 'system');
    },
  );

  testWidgets('English tabs, quick add and profile switch remain interactive', (
    tester,
  ) async {
    final locales = LocaleController(store: MemoryLocaleStore('en'));
    addTearDown(locales.dispose);
    await locales.load();
    await tester.pumpWidget(
      FitnessAiApp(useAuth: false, localeController: locales),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hello, Alex'), findsOneWidget);
    for (final tab in ['AI', 'Recipes', 'Profile', 'Diary']) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(tab),
        ),
      );
      await tester.pumpAndSettle();
      _expectEnglish(tester);
    }
    await tester.tap(find.byKey(const Key('nav-quick-add')));
    await tester.pumpAndSettle();
    expect(find.text('Add meal'), findsOneWidget);
    expect(find.text('AI Photo'), findsOneWidget);
    _expectEnglish(tester);
    Navigator.of(tester.element(find.text('Add meal'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profile'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('profile-language')));
    await tester.tap(find.byKey(const Key('profile-language')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-sheet-de')));
    await tester.pumpAndSettle();
    expect(find.text('Meine täglichen Ziele'), findsOneWidget);
    expect(locales.locale, L10n.german);
    expect(tester.takeException(), isNull);
  });

  testWidgets('all introduction pages are English at 320 pixels', (
    tester,
  ) async {
    setTestScreen(tester, const Size(320, 568), textScale: 1.6);
    await _pump(tester, IntroductionPage(onComplete: () async {}));
    for (var page = 0; page < 6; page++) {
      _expectEnglish(tester);
      expect(tester.takeException(), isNull);
      if (page < 5) {
        await tester.tap(find.byKey(const Key('intro-next')));
        await tester.pumpAndSettle();
      }
    }
    expect(find.text("Let's go"), findsOneWidget);
  });

  testWidgets('language sheet fits large text and returns to device language', (
    tester,
  ) async {
    setTestScreen(tester, const Size(320, 568), textScale: 1.6);
    final locales = LocaleController(
      store: MemoryLocaleStore('en'),
      device: L10n.german,
    );
    addTearDown(locales.dispose);
    await locales.load();
    await tester.pumpWidget(
      LocaleScope(
        controller: locales,
        child: MaterialApp(
          theme: AppTheme.dark,
          locale: L10n.english,
          supportedLocales: L10n.supported,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showLanguageSheet(context),
                child: const Text('Language'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const Key('language-sheet-system')));
    await tester.tap(find.byKey(const Key('language-sheet-system')));
    await tester.pumpAndSettle();
    expect(locales.followsDevice, isTrue);
    expect(locales.locale, L10n.german);
  });

  testWidgets('every question, allergy sheet and completed plan is English', (
    tester,
  ) async {
    setTestScreen(tester, const Size(320, 568), textScale: 1.4);
    PersonalizationProfile? completed;
    await _pump(
      tester,
      PersonalizationPage(
        onComplete: (value) async => completed = value,
        onLater: () async {},
      ),
    );
    Future<void> tap(String key) async {
      final target = find.byKey(ValueKey(key));
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await tester.tap(target);
      await tester.pumpAndSettle();
      _expectEnglish(tester);
    }

    await tap('personal-next');
    await tap('personal-goal-loseWeight');
    await tap('personal-next');
    await tap('personal-motivation-energy');
    await tap('personal-next');
    await tap('personal-sex-female');
    await tap('personal-next');
    for (var i = 0; i < 4; i++) {
      await tap('personal-confirm-value');
      await tap('personal-next');
    }
    await tap('personal-activity-mixed');
    await tap('personal-next');
    await tap('personal-nutrition-vegetarian');
    await tap('edit-allergies');
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('peanuts')),
      180,
      scrollable: find.descendant(
        of: find.byType(ListView).last,
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Peanuts'), findsOneWidget);
    await tap('peanuts');
    await tap('save-allergies');
    await tap('personal-next');
    await tap('personal-cooking-normal');
    await tap('personal-experience-none');
    await tap('personal-next');
    await tap('personal-obstacle-cravings');
    await tap('personal-next');
    await tap('personal-next');
    expect(find.text('Protein'), findsOneWidget);
    expect(find.text('Egg white'), findsNothing);
    await tap('personal-next');
    expect(completed!.allergies, 'Erdnüsse');
    expect(completed!.goal, PersonalGoal.loseWeight);
  });

  testWidgets('pantry staples and suggestions are English', (tester) async {
    setTestScreen(tester, const Size(320, 568), textScale: 1.4);
    final app = await recipeTestController(plus: true);
    addTearDown(app.dispose);
    await _pump(tester, const CookFromPantryPage(), app: app);
    _expectEnglish(tester);
    expect(find.text('Kartoffeln'), findsNothing);
    expect(find.text('Potatoes'), findsWidgets);
    expect(find.textContaining('Salt, pepper, oil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final screen in ['auth', 'questions', 'custom', 'premium']) {
    testWidgets('$screen is English and fits a narrow screen', (tester) async {
      setTestScreen(tester, const Size(320, 568), textScale: 1.6);
      final app = await recipeTestController(plus: false);
      addTearDown(app.dispose);
      final Widget page = switch (screen) {
        'auth' => const AuthPage(startWithSignUp: true),
        'questions' => PersonalizationPage(
          onComplete: (_) async {},
          onLater: () async {},
        ),
        'custom' => Scaffold(
          body: CustomFoodSheet(date: DateTime(2026, 10, 15)),
        ),
        _ => PaywallPage(subscription: app.subscription, onClose: () {}),
      };
      await _pump(tester, page, app: app);
      _expectEnglish(tester);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('recipe Pro tips and all Premium sections use English', (
    tester,
  ) async {
    setTestScreen(tester, const Size(320, 568), textScale: 1.4);
    final recipe = _recipe(sourceRecipes.first as Map<String, dynamic>);
    await _pump(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              RecipeIntro(recipe: recipe),
              RecipeStepsSection(
                recipe: recipe,
                details: recipe.premiumDetails,
                onCookMode: null,
              ),
              RecipePlusArea(recipe: recipe, details: recipe.premiumDetails),
            ],
          ),
        ),
      ),
    );
    expect(
      find.textContaining(
        'Stir regularly to stop the milk sticking to the bottom.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    _expectEnglish(tester);
    for (final key in [
      'mistakes',
      'substitutions',
      'meal-prep',
      'variations',
      'serving',
    ]) {
      final finder = find.byKey(Key('plus-block-$key'));
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      final header = find
          .descendant(of: finder, matching: find.byType(InkWell))
          .first;
      await tester.tap(header);
      await tester.pumpAndSettle();
      _expectEnglish(tester);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('cooking mode translates the actual per-step tip', (
    tester,
  ) async {
    setTestScreen(tester, const Size(320, 568), textScale: 1.4);
    final recipe = _recipe(sourceRecipes.first as Map<String, dynamic>);
    await _pump(
      tester,
      CookModePage(recipe: recipe, details: recipe.premiumDetails),
    );
    expect(
      find.textContaining(
        'Stir regularly to stop the milk sticking to the bottom.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    _expectEnglish(tester);
    expect(tester.takeException(), isNull);
  });
}

Recipe _recipe(Map<String, dynamic> source) =>
    SupabaseCatalogRepository.recipeFromMap(
      {...source, 'id': source['slug'], 'servings': 2},
      const [],
      const {},
      premiumRow: source['premium'] as Map<String, dynamic>,
    );

Future<void> _pump(
  WidgetTester tester,
  Widget page, {
  AppController? app,
}) async {
  Widget child = MaterialApp(
    locale: L10n.english,
    supportedLocales: L10n.supported,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: AppTheme.dark,
    home: page,
  );
  if (app != null) child = AppScope(controller: app, child: child);
  await tester.pumpWidget(child);
  await tester.pumpAndSettle();
}

void _expectEnglish(WidgetTester tester) {
  final german = RegExp(
    r'\b(Dein|Deine|Bitte|Speichern|Abbrechen|Schritt|Zutaten|Frühstück|Mittagessen|Abendessen|Tagebuch|Nährwerte|Rezept|Rezepte|Ändern|Einwilligung|Zurück|Weiter|Kostenlos|wird|werden)\b',
  );
  final offenders = <String>[];
  for (final text in tester.widgetList<Text>(find.byType(Text))) {
    final value = text.data ?? text.textSpan?.toPlainText() ?? '';
    if (german.hasMatch(value)) offenders.add(value);
  }
  expect(offenders, isEmpty, reason: offenders.join('\n'));
}
