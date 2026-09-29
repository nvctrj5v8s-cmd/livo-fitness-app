import 'package:fitness_ai_app/core/config/feature_flags.dart';
import 'package:fitness_ai_app/core/models/app_models.dart';
import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/features/discover/domain/kitchen_planning.dart';
import 'package:fitness_ai_app/features/discover/presentation/cook_from_pantry_page.dart';
import 'package:fitness_ai_app/features/discover/presentation/discover_page.dart';
import 'package:fitness_ai_app/features/discover/presentation/planning_sheets.dart';
import 'package:fitness_ai_app/features/subscription/data/subscription_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/kitchen_fixtures.dart';
import 'support/recipe_fixtures.dart';

Recipe _recipe(
  String id,
  String title,
  List<String> ingredients, {
  bool premium = false,
  List<String> tags = const ['Abendessen'],
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
  tags: ['Für dich', ...tags],
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

Future<AppController> _controller({
  bool plus = false,
  String? userId,
  MemoryPlanningStore? store,
}) async {
  final controller = AppController(
    personalizationUserId: userId,
    planningStore: store,
    subscriptionRepository: plus
        ? const PlusSubscriptionRepository()
        : const PreviewSubscriptionRepository(),
  );
  controller.recipes = [
    for (final recipe in _testRecipes)
      if (plus || !recipe.isPremium) recipe,
  ];
  await controller.subscription.load();
  await controller.planning.load();
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

/// Scrolls the innermost list until [finder] is built and visible.
Future<void> _reveal(
  WidgetTester tester,
  Finder finder, {
  bool up = false,
}) async {
  await tester.scrollUntilVisible(
    finder,
    up ? -150 : 150,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pumpAndSettle();
}

/// Opens a sheet from a button inside a plain test page.
Widget _launcher(Future<void> Function(BuildContext context) open) => Scaffold(
  body: Builder(
    builder: (context) => Center(
      child: FilledButton(
        key: const Key('launch'),
        onPressed: () => open(context),
        child: const Text('Öffnen'),
      ),
    ),
  ),
);

void main() {
  testWidgets('Rezepte-Tab: „Nur Kartoffeln“ zeigt Kartoffelrezepte zuerst', (
    tester,
  ) async {
    final controller = await _controller();
    await _pump(tester, controller, const Scaffold(body: DiscoverPage()));

    expect(find.byKey(const Key('cook-from-pantry-banner')), findsOneWidget);
    await _tap(tester, find.byKey(const Key('cook-from-pantry-banner')));
    expect(find.text('Was kann ich kochen?'), findsWidgets);
    expect(find.text('Was hast du zu Hause?'), findsOneWidget);

    await _tap(tester, find.byKey(const ValueKey('cook-staple-Kartoffeln')));

    expect(find.byKey(const Key('cook-result-count')), findsOneWidget);
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
    expect(find.text('2 von 2 da'), findsOneWidget);
    // Free account: the premium pointer instead of locked recipes.
    expect(find.byKey(const Key('premium-recipes-card')), findsOneWidget);

    final missingToShopping = find.byKey(
      const ValueKey('cook-missing-to-shopping-bratkartoffeln'),
    );
    if (kitchenPlanningEnabled) {
      await _tap(tester, missingToShopping);
      expect(controller.planning.shopping.map((i) => i.name), ['Zwiebel']);
      expect(controller.planning.shopping.single.source, 'Bratkartoffeln');
      expect(
        find.textContaining('auf die Einkaufsliste gesetzt'),
        findsOneWidget,
      );
    } else {
      expect(missingToShopping, findsNothing);
      expect(find.byKey(const Key('cook-use-pantry')), findsNothing);
    }

    // Switching off the basics makes salt a missing ingredient.
    await _tap(tester, find.byKey(const Key('cook-basics')));
    expect(controller.planning.assumeBasics, isFalse);
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

    final saveToPantry = find.byKey(const Key('cook-save-to-pantry'));
    if (kitchenPlanningEnabled) {
      await _tap(tester, saveToPantry);
      expect(controller.planning.pantryNames, ['erdäpfel', 'Sahne']);
      expect(find.byKey(const Key('cook-use-pantry')), findsOneWidget);
    } else {
      expect(saveToPantry, findsNothing);
    }
  });

  testWidgets('Vorräte: Schnellauswahl, eigene Menge und Kochen damit', (
    tester,
  ) async {
    final controller = await _controller();
    await _pump(
      tester,
      controller,
      _launcher((context) => showPantrySheet(context, controller)),
    );
    await _tap(tester, find.byKey(const Key('launch')));

    expect(find.text('Meine Vorräte'), findsOneWidget);
    expect(find.byKey(const Key('kitchen-storage-note')), findsOneWidget);
    expect(find.textContaining('bis zum Neustart'), findsOneWidget);

    await _tap(tester, find.byKey(const ValueKey('pantry-staple-Kartoffeln')));
    expect(controller.planning.pantryNames, ['Kartoffeln']);

    await tester.enterText(
      find.byKey(const ValueKey('pantry-name')),
      'Zwiebeln',
    );
    await tester.enterText(find.byKey(const ValueKey('pantry-amount')), '1 kg');
    await _tap(tester, find.byKey(const ValueKey('pantry-add')));
    expect(
      controller.planning.pantryItemFor('Zwiebeln')!.amount,
      const KitchenAmount(1000, KitchenUnit.gram),
    );

    await tester.enterText(find.byKey(const ValueKey('pantry-name')), 'Speck');
    await _tap(tester, find.byKey(const ValueKey('pantry-add')));
    expect(find.byKey(const Key('kitchen-feedback')), findsOneWidget);
    expect(controller.planning.pantryNames, ['Kartoffeln', 'Zwiebeln']);

    // Tapping a selected staple removes it again.
    await _tap(tester, find.byKey(const ValueKey('pantry-staple-Zwiebeln')));
    expect(controller.planning.pantryNames, ['Kartoffeln']);
    await _tap(tester, find.byKey(const ValueKey('pantry-staple-Zwiebeln')));

    // Cooking with the pantry is only offered while planning is enabled.
    if (!kitchenPlanningEnabled) return;
    await _reveal(tester, find.byKey(const Key('pantry-cook')), up: true);
    await _tap(tester, find.byKey(const Key('pantry-cook')));
    expect(find.byKey(const Key('cook-use-pantry')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('cook-result-bratkartoffeln')),
      findsOneWidget,
    );
    expect(find.text('Alles da'), findsNWidgets(2));
  });

  testWidgets('Einkaufsliste: hinzufügen, abhaken, in Vorräte, löschen', (
    tester,
  ) async {
    final controller = await _controller();
    await _pump(
      tester,
      controller,
      _launcher((context) => showShoppingSheet(context, controller)),
    );
    await _tap(tester, find.byKey(const Key('launch')));
    expect(find.textContaining('Deine Einkaufsliste ist leer'), findsOneWidget);

    // One field: name and amount are read from the text.
    final input = find.byKey(const Key('shopping-input'));
    await tester.enterText(input, '500 g Reis');
    await tester.pumpAndSettle();
    expect(
      find.text('Reis · 500 g · Nudeln, Reis & Vorrat', findRichText: true),
      findsOneWidget,
    );
    await _tap(tester, find.byKey(const Key('shopping-add')));
    await tester.enterText(input, 'Milch 1 l');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('2 Artikel offen'), findsOneWidget);
    expect(find.text('1 l'), findsOneWidget);
    expect(
      controller.planning.shopping.first.amount,
      const KitchenAmount(500, KitchenUnit.gram),
    );
    // Sorted by supermarket section.
    expect(find.text('Kühlregal & Eier'), findsOneWidget);
    expect(find.text('Nudeln, Reis & Vorrat'), findsOneWidget);

    // Quick pick adds a staple right away.
    await _tap(tester, find.byKey(const ValueKey('shopping-quick-Eier')));
    expect(controller.planning.shopping.map((i) => i.name), [
      'Reis',
      'Milch',
      'Eier',
    ]);
    expect(find.byKey(const ValueKey('shopping-quick-Eier')), findsNothing);

    final rice = controller.planning.shopping.first;
    await _tap(tester, find.byKey(ValueKey('shopping-item-${rice.id}')));
    expect(controller.planning.shopping.first.done, isTrue);
    expect(find.text('2 Artikel offen · 1 im Wagen'), findsOneWidget);
    expect(find.text('Im Wagen · 1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('shopping-move-to-pantry')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(controller.planning.pantryNames, ['Reis']);
    expect(find.textContaining('in deine Vorräte übernommen'), findsOneWidget);
    // The message disappears on its own.
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shopping-toast')), findsNothing);

    // Edit amount, then delete and undo.
    final milk = controller.planning.shopping.first;
    await _tap(tester, find.byTooltip('Milch bearbeiten'));
    await tester.enterText(
      find.byKey(const Key('shopping-edit-amount')),
      '2 l',
    );
    await _tap(tester, find.byKey(const Key('shopping-edit-save')));
    expect(
      controller.planning.shopping.first.amount,
      const KitchenAmount(2000, KitchenUnit.milliliter),
    );
    expect(find.text('2 l'), findsOneWidget);

    await _tap(tester, find.byTooltip('Milch bearbeiten'));
    await tester.tap(find.byKey(const Key('shopping-edit-delete')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(controller.planning.shopping.map((i) => i.name), ['Eier']);
    await tester.tap(find.byKey(const Key('shopping-undo')));
    await tester.pumpAndSettle();
    expect(controller.planning.shopping.first.id, milk.id);

    // Duplicates are reported under the field.
    await tester.enterText(input, 'eier');
    await _tap(tester, find.byKey(const Key('shopping-add')));
    expect(find.text('„eier“ steht schon auf der Liste.'), findsOneWidget);
    expect(controller.planning.shopping, hasLength(2));
  });

  testWidgets('Einkaufsliste: ohne Animation sofort abgehakt', (tester) async {
    final controller = await _controller();
    controller.planning.addShoppingItem('Tomaten');
    await _pump(
      tester,
      controller,
      _launcher((context) => showShoppingSheet(context, controller)),
      reduceMotion: true,
    );
    await _tap(tester, find.byKey(const Key('launch')));
    final item = controller.planning.shopping.single;
    await tester.tap(find.byKey(ValueKey('shopping-item-${item.id}')));
    await tester.pump();
    expect(controller.planning.shopping.single.done, isTrue);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shopping-all-done')), findsOneWidget);
    expect(find.text('Alles im Wagen'), findsOneWidget);
  });

  testWidgets('Wochenplan: Rezept planen, verschieben, Liste erstellen', (
    tester,
  ) async {
    final controller = await _controller();
    controller.planning.addPantryItem('Zwiebeln');
    await _pump(
      tester,
      controller,
      _launcher((context) => showWeekPlanSheet(context, controller)),
    );
    await _tap(tester, find.byKey(const Key('launch')));

    expect(find.text('Wochenplan'), findsOneWidget);
    final create = find.byKey(const Key('plan-create-shopping'));
    await _reveal(tester, create);
    expect(tester.widget<FilledButton>(create).onPressed, isNull);

    await _reveal(tester, find.byKey(const ValueKey('plan-add-0')), up: true);
    await _tap(tester, find.byKey(const ValueKey('plan-add-0')));
    await _tap(tester, find.byKey(const ValueKey('plan-pick-bratkartoffeln')));
    expect(find.text('Einplanen'), findsOneWidget);
    await _tap(tester, find.byKey(const Key('plan-portions-plus')));
    expect(find.text('3 Portionen'), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('plan-slot-lunch')));
    await _tap(tester, find.byKey(const Key('plan-confirm')));

    final entry = controller.planning.plan.single;
    final monday = weekStartOf(DateTime.now());
    expect(entry.day, monday);
    expect(entry.slot, MealSlot.lunch);
    expect(entry.portions, 3);
    expect(find.text('Mittagessen · 3 Portionen'), findsOneWidget);

    // Move it to Tuesday via the entry menu.
    await _tap(tester, find.byKey(ValueKey('plan-entry-menu-${entry.id}')));
    await _tap(tester, find.text('Verschieben oder ändern'));
    await _tap(tester, find.byKey(const ValueKey('plan-day-1')));
    await _tap(tester, find.byKey(const Key('plan-confirm')));
    expect(
      controller.planning.plan.single.day,
      DateTime(monday.year, monday.month, monday.day + 1),
    );

    await _reveal(tester, create);
    await _tap(tester, create);
    expect(find.byKey(const Key('plan-shopping-summary')), findsOneWidget);
    expect(find.text('1 Zutat hinzugefügt.'), findsOneWidget);
    expect(find.textContaining('In deinen Vorräten: Zwiebel'), findsOneWidget);
    expect(find.textContaining('Rapsöl, Salz'), findsOneWidget);
    final potatoes = controller.planning.shopping.single;
    expect(potatoes.name, 'Kartoffeln');
    expect(potatoes.amount, const KitchenAmount(300, KitchenUnit.gram));

    await _tap(tester, find.byKey(const Key('plan-summary-open-shopping')));
    expect(find.text('Einkaufsliste'), findsWidgets);
    expect(find.text('Kartoffeln'), findsOneWidget);

    // Navigate weeks.
    await tester.tap(find.byTooltip('Schließen').last);
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('plan-next-week')));
    expect(find.text('Noch nichts geplant'), findsOneWidget);
    expect(find.byKey(const Key('plan-this-week')), findsOneWidget);
    await _tap(tester, find.byKey(const Key('plan-this-week')));
    expect(find.text('1 Mahlzeit in dieser Woche'), findsOneWidget);

    final menu = find.byKey(ValueKey('plan-entry-menu-${entry.id}'));
    await _reveal(tester, menu, up: true);
    await _tap(tester, menu);
    await _tap(tester, find.text('Entfernen'));
    expect(controller.planning.plan, isEmpty);
  });

  testWidgets('Rezeptdetail: Wochenplan nur wenn freigeschaltet', (
    tester,
  ) async {
    final controller = await recipeTestController(plus: false);
    await _pump(
      tester,
      controller,
      const RecipeDetailPage(recipe: curryRecipe),
    );
    if (!kitchenPlanningEnabled) {
      expect(find.byKey(const Key('recipe-add-plan')), findsNothing);
      expect(find.byKey(const Key('recipe-add-shopping')), findsNothing);
      return;
    }
    await _tap(tester, find.byKey(const Key('recipe-add-plan')));
    expect(find.text('Einplanen'), findsOneWidget);
    expect(find.text('2 Portionen'), findsOneWidget);
    await _tap(tester, find.byKey(const Key('plan-confirm')));
    expect(controller.planning.plan.single.recipeTitle, curryRecipe.title);
    expect(controller.planning.plan.single.slot, MealSlot.dinner);
    expect(find.textContaining('eingeplant'), findsOneWidget);
  });

  testWidgets('Mit Konto bleiben Listen nach einem Neustart erhalten', (
    tester,
  ) async {
    final store = MemoryPlanningStore();
    final first = await _controller(userId: 'konto-1', store: store);
    await _pump(
      tester,
      first,
      _launcher((context) => showPantrySheet(context, first)),
    );
    await _tap(tester, find.byKey(const Key('launch')));
    expect(
      find.textContaining('Nur auf diesem Gerät gespeichert'),
      findsOneWidget,
    );
    await _tap(tester, find.byKey(const ValueKey('pantry-staple-Reis')));
    await first.planning.pendingWrites;
    await tester.pumpWidget(const SizedBox());
    first.dispose();

    final restarted = await _controller(userId: 'konto-1', store: store);
    expect(restarted.planning.pantryNames, ['Reis']);
    final otherAccount = await _controller(userId: 'konto-2', store: store);
    expect(otherAccount.planning.pantry, isEmpty);
    restarted.dispose();
    otherAccount.dispose();
  });

  testWidgets('Unlesbare Listen: Hinweis statt Überschreiben', (tester) async {
    final controller = await _controller(
      userId: 'konto-1',
      store: MemoryPlanningStore(failLoad: true),
    );
    await _pump(
      tester,
      controller,
      _launcher((context) => showShoppingSheet(context, controller)),
    );
    await _tap(tester, find.byKey(const Key('launch')));
    expect(find.textContaining('nicht gelesen werden'), findsOneWidget);
    expect(find.byKey(const Key('shopping-input')), findsNothing);
    expect(find.byKey(const Key('kitchen-reset')), findsOneWidget);
  });

  for (final (label, size, scale) in [
    ('320 px, doppelte Schrift', const Size(320, 568), 2.0),
    ('Querformat', const Size(740, 360), 1.0),
    ('Desktop', const Size(1280, 800), 1.0),
  ]) {
    testWidgets('ohne Layoutfehler: $label', (tester) async {
      final controller = await _controller();
      controller.planning
        ..addPantryItem('Kartoffeln', amountText: '1,5 kg')
        ..addShoppingItem('Haferflocken, zart', amountText: '500 g')
        ..addShoppingItem('Mineralwasser, still', amountText: '6 Flaschen');
      controller.planning.toggleShoppingItem(
        controller.planning.shopping.last.id,
      );
      controller.planning.addPlanEntry(
        recipe: _testRecipes[1],
        day: DateTime.now(),
        slot: MealSlot.dinner,
      );
      await _pump(
        tester,
        controller,
        const CookFromPantryPage(),
        size: size,
        textScale: scale,
        reduceMotion: true,
      );
      expect(tester.takeException(), isNull);
      if (kitchenPlanningEnabled) {
        expect(find.text('Alles da'), findsOneWidget);
        expect(find.text('Salzkartoffeln'), findsOneWidget);
      }

      for (final open in [
        showPantrySheet,
        showShoppingSheet,
        showWeekPlanSheet,
      ]) {
        await _pump(
          tester,
          controller,
          _launcher((context) => open(context, controller)),
          size: size,
          textScale: scale,
          reduceMotion: true,
        );
        await _tap(tester, find.byKey(const Key('launch')));
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Schließen').last);
        await tester.pumpAndSettle();
      }

      await _pump(
        tester,
        controller,
        const Scaffold(body: DiscoverPage()),
        size: size,
        textScale: scale,
        reduceMotion: true,
      );
      expect(tester.takeException(), isNull);
      expect(
        find.text('1 Zutat zu Hause'),
        kitchenPlanningEnabled ? findsOneWidget : findsNothing,
      );
    });
  }
}
