import 'package:fitness_ai_app/core/models/app_models.dart';
import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/features/discover/presentation/cook_from_pantry_page.dart';
import 'package:fitness_ai_app/features/discover/presentation/discover_page.dart';
import 'package:fitness_ai_app/features/subscription/data/subscription_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/recipe_fixtures.dart';

Recipe _recipe(
  String id,
  String title,
  List<String> ingredients, {
  bool premium = false,
}) => Recipe(
  id: id,
  title: title,
  subtitle: 'Test',
  minutes: 25,
  calories: 450,
  protein: 18,
  servings: 2,
  imageAsset: '',
  isPremium: premium,
  tags: const ['Für dich', 'Abendessen'],
  ingredients: [
    for (final name in ingredients)
      RecipeIngredient(foodId: name, name: name, amountGrams: 200),
  ],
  steps: const [RecipeStep(text: 'Alles zubereiten.')],
);

final _testRecipes = [
  _recipe('pasta', 'Tomatennudeln', ['Spaghetti', 'Dosentomaten', 'Olivenöl']),
  _recipe('bratkartoffeln', 'Bratkartoffeln', [
    'Kartoffeln, festkochend',
    'Zwiebel',
    'Rapsöl',
    'Salz',
  ]),
  _recipe('salzkartoffeln', 'Salzkartoffeln', ['Kartoffeln', 'Salz']),
  _recipe('kartoffel-gratin', 'Kartoffelgratin', [
    'Kartoffeln',
    'Sahne',
    'Käse',
  ], premium: true),
];

Future<AppController> _controller({bool plus = false}) async {
  final controller = AppController(
    subscriptionRepository: plus
        ? const PlusSubscriptionRepository()
        : const PreviewSubscriptionRepository(),
  );
  controller.recipes = [
    for (final recipe in _testRecipes)
      if (plus || !recipe.isPremium) recipe,
  ];
  await controller.subscription.load();
  return controller;
}

Future<void> _pump(
  WidgetTester tester,
  AppController controller,
  Widget home, {
  Size size = const Size(390, 844),
  double textScale = 1,
  bool reduceMotion = false,
}) async {
  setTestScreen(tester, size, textScale: textScale);
  if (reduceMotion) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
  await tester.pumpWidget(recipeTestApp(controller, home));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Rezepte-Tab: „Nur Kartoffeln“ zeigt Kartoffelrezepte zuerst', (
    tester,
  ) async {
    final controller = await _controller();
    await _pump(tester, controller, const Scaffold(body: DiscoverPage()));

    // Week plan, shopping list and pantry are gone from the recipe tab.
    expect(find.text('Planen & vorbereiten'), findsNothing);
    expect(find.text('Rezepte mit dem, was du zu Hause hast'), findsOneWidget);
    await _tap(tester, find.byKey(const Key('cook-from-pantry-banner')));
    expect(find.text('Was kann ich kochen?'), findsWidgets);
    expect(find.text('Was hast du zu Hause?'), findsOneWidget);

    await _tap(tester, find.byKey(const ValueKey('cook-staple-Kartoffeln')));

    expect(find.text('2 passende Rezepte · 1 sofort kochbar'), findsOneWidget);
    expect(find.byKey(const ValueKey('cook-result-pasta')), findsNothing);
    final first = tester.getTopLeft(
      find.byKey(const ValueKey('cook-result-salzkartoffeln')),
    );
    final second = tester.getTopLeft(
      find.byKey(const ValueKey('cook-result-bratkartoffeln')),
    );
    expect(first.dy, lessThan(second.dy));
    expect(find.text('Alles da'), findsOneWidget);
    expect(find.text('1 Zutat fehlt'), findsOneWidget);
    // Free account: the premium pointer instead of locked recipes.
    expect(find.byKey(const Key('premium-recipes-card')), findsOneWidget);
    expect(find.textContaining('Einkaufsliste'), findsNothing);
    expect(find.textContaining('Vorräte'), findsNothing);

    // Switching off the basics makes salt a missing ingredient.
    await _tap(tester, find.byKey(const Key('cook-basics')));
    expect(find.textContaining('sofort kochbar'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tippen, Vorschlag übernehmen und Plus-Rezepte markieren', (
    tester,
  ) async {
    final controller = await _controller(plus: true);
    await _pump(tester, controller, const CookFromPantryPage());

    await tester.enterText(find.byKey(const Key('cook-input')), 'erdäpfel');
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('cook-add')));
    expect(find.byKey(const ValueKey('cook-chip-erdäpfel')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('cook-result-kartoffel-gratin')),
      findsOneWidget,
    );
    expect(find.text('Plus'), findsWidgets);
    expect(find.byKey(const Key('premium-recipes-card')), findsNothing);

    await tester.enterText(find.byKey(const Key('cook-input')), 'sah');
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const ValueKey('cook-suggestion-Sahne')));
    expect(find.byKey(const ValueKey('cook-chip-Sahne')), findsOneWidget);
  });

  testWidgets('Allergene: Rezepte mit Konflikt werden nicht vorgeschlagen', (
    tester,
  ) async {
    final controller = await _controller(plus: true);
    controller.allergies = 'Milch';
    await _pump(tester, controller, const Scaffold(body: DiscoverPage()));
    expect(
      find.text('1 Rezept wegen deiner Allergieangaben ausgeblendet.'),
      findsOneWidget,
    );

    await _pump(tester, controller, const CookFromPantryPage());

    await _tap(tester, find.byKey(const ValueKey('cook-staple-Kartoffeln')));
    expect(
      find.byKey(const ValueKey('cook-result-kartoffel-gratin')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('cook-result-salzkartoffeln')),
      findsOneWidget,
    );
  });

  for (final (label, size, scale) in [
    ('320 px, doppelte Schrift', const Size(320, 568), 2.0),
    ('Querformat', const Size(740, 360), 1.0),
    ('Desktop', const Size(1280, 800), 1.0),
  ]) {
    testWidgets('ohne Layoutfehler: $label', (tester) async {
      final controller = await _controller();
      await _pump(
        tester,
        controller,
        const CookFromPantryPage(),
        size: size,
        textScale: scale,
        reduceMotion: true,
      );
      await _tap(tester, find.byKey(const ValueKey('cook-staple-Kartoffeln')));
      expect(tester.takeException(), isNull);
      expect(find.text('Alles da'), findsOneWidget);

      await _pump(
        tester,
        controller,
        const Scaffold(body: DiscoverPage()),
        size: size,
        textScale: scale,
        reduceMotion: true,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
