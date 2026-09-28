import 'dart:convert';

import 'package:fitness_ai_app/core/models/app_models.dart';
import 'package:fitness_ai_app/features/discover/application/planning_controller.dart';
import 'package:fitness_ai_app/features/discover/data/planning_store.dart';
import 'package:fitness_ai_app/features/discover/domain/kitchen_planning.dart';
import 'package:fitness_ai_app/features/discover/presentation/kitchen_format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'support/kitchen_fixtures.dart';

final _now = DateTime(2026, 9, 30, 12); // Wednesday
final _monday = DateTime(2026, 9, 28);

Recipe _recipe(
  String id,
  Map<String, double> ingredients, {
  int servings = 2,
  List<String> measures = const [],
}) => Recipe(
  id: id,
  title: 'Rezept $id',
  subtitle: '',
  minutes: 20,
  calories: 400,
  protein: 20,
  imageAsset: '',
  servings: servings,
  tags: const ['Für dich', 'Abendessen'],
  ingredients: [
    for (final (index, entry) in ingredients.entries.indexed)
      RecipeIngredient(
        foodId: entry.key,
        name: entry.key,
        amountGrams: entry.value,
        measure: index < measures.length ? measures[index] : null,
      ),
  ],
);

void main() {
  group('Mengen', () {
    test('werden als Zahl mit Einheit gelesen', () {
      expect(
        parseKitchenAmount('500 g'),
        const KitchenAmount(500, KitchenUnit.gram),
      );
      expect(
        parseKitchenAmount('1,5 kg'),
        const KitchenAmount(1500, KitchenUnit.gram),
      );
      expect(
        parseKitchenAmount('2 Stück'),
        const KitchenAmount(2, KitchenUnit.piece),
      );
      expect(
        parseKitchenAmount('3'),
        const KitchenAmount(3, KitchenUnit.piece),
      );
      expect(
        parseKitchenAmount('1 l'),
        const KitchenAmount(1000, KitchenUnit.milliliter),
      );
      expect(
        parseKitchenAmount('2 Dosen'),
        const KitchenAmount(2, KitchenUnit.can),
      );
      expect(
        parseKitchenAmount('½ Packung'),
        const KitchenAmount(0.5, KitchenUnit.pack),
      );
      expect(
        parseKitchenAmount('1 Pck.'),
        const KitchenAmount(1, KitchenUnit.pack),
      );
    });

    test('Unklares wird nicht geraten', () {
      expect(parseKitchenAmount('etwas'), isNull);
      expect(parseKitchenAmount('2 Hände voll'), isNull);
      expect(parseKitchenAmount(''), isNull);
      expect(parseKitchenAmount('0 g'), isNull);
    });

    test('werden erst in der Oberfläche formatiert', () {
      expect(
        formatKitchenAmount(const KitchenAmount(1500, KitchenUnit.gram)),
        '1,5 kg',
      );
      expect(
        formatKitchenAmount(const KitchenAmount(250, KitchenUnit.gram)),
        '250 g',
      );
      expect(
        formatKitchenAmount(const KitchenAmount(1, KitchenUnit.can)),
        '1 Dose',
      );
      expect(
        formatKitchenAmount(const KitchenAmount(2, KitchenUnit.can)),
        '2 Dosen',
      );
      expect(kitchenAmountLabel(null, null), isNull);
      expect(
        kitchenAmountLabel(const KitchenAmount(10, KitchenUnit.gram), '1 EL'),
        '1 EL · 10 g',
      );
    });

    test('nur gleiche Einheiten werden addiert', () {
      const grams = KitchenAmount(200, KitchenUnit.gram);
      expect(
        grams.plus(const KitchenAmount(300, KitchenUnit.gram)),
        const KitchenAmount(500, KitchenUnit.gram),
      );
      expect(grams.plus(const KitchenAmount(1, KitchenUnit.piece)), isNull);
    });
  });

  test('Wochen beginnen am Montag', () {
    expect(weekStartOf(_now), _monday);
    expect(weekStartOf(DateTime(2026, 10, 4)), _monday);
    expect(weekStartOf(DateTime(2026, 10, 5)), DateTime(2026, 10, 5));
    expect(formatWeekRange(_monday), '28. Sep. – 4. Okt. 2026');
    expect(formatWeekRange(DateTime(2026, 10, 5)), '5.–11. Okt. 2026');
  });

  test('der gespeicherte Stand übersteht JSON und alte Pläne entfallen', () {
    final state = KitchenState(
      assumeBasics: false,
      pantry: [
        PantryItem(
          id: 'p1',
          name: 'Reis',
          amount: const KitchenAmount(500, KitchenUnit.gram),
          addedAt: _now,
        ),
        const PantryItem(id: 'p2', name: 'Salbei', note: 'etwas'),
      ],
      shopping: const [
        ShoppingItem(id: 's1', name: 'Milch', done: true, planKey: 'plan-x'),
      ],
      plan: [
        MealPlanEntry(
          id: 'e1',
          day: _now,
          slot: MealSlot.lunch,
          recipeId: 'r1',
          recipeTitle: 'Linsen-Dal',
          portions: 3,
        ),
        MealPlanEntry(
          id: 'old',
          day: DateTime(2026, 6, 1),
          slot: MealSlot.dinner,
          recipeId: 'r2',
          recipeTitle: 'Alt',
        ),
      ],
    );
    final restored = KitchenState.fromJson(
      jsonDecode(jsonEncode(state.toJson())),
    );
    expect(restored.assumeBasics, isFalse);
    expect(
      restored.pantry.first.amount,
      const KitchenAmount(500, KitchenUnit.gram),
    );
    expect(restored.pantry.last.note, 'etwas');
    expect(restored.shopping.single.done, isTrue);
    expect(restored.shopping.single.planKey, 'plan-x');
    expect(restored.plan.first.slot, MealSlot.lunch);
    expect(restored.plan.first.portions, 3);
    expect(restored.plan.first.day, DateTime(2026, 9, 30));
    expect(restored.withoutOldPlan(_now).plan.map((e) => e.id), ['e1']);

    expect(() => KitchenState.fromJson({'version': 99}), throwsFormatException);
    expect(() => KitchenState.fromJson('kaputt'), throwsFormatException);
    final partial = KitchenState.fromJson({
      'version': 1,
      'pantry': [
        {'id': 'ok', 'name': 'Mehl'},
        {'name': 'ohne id'},
        42,
      ],
    });
    expect(partial.pantry.map((item) => item.name), ['Mehl']);
  });

  group('Einkaufsliste aus dem Wochenplan', () {
    final curry = _recipe(
      'curry',
      {
        'Kartoffeln, festkochend': 400,
        'Zwiebel': 80,
        'Olivenöl': 10,
        'Salz': 2,
      },
      measures: ['', '1 Zwiebel'],
    );
    final soup = _recipe('suppe', {
      'Kartoffeln': 300,
      'Reis': 100,
      'Milch': 200,
    }, servings: 1);
    final recipes = {curry.id: curry, soup.id: soup};
    final entries = [
      MealPlanEntry(
        id: 'a',
        day: _monday,
        slot: MealSlot.dinner,
        recipeId: 'curry',
        recipeTitle: curry.title,
        portions: 4,
      ),
      MealPlanEntry(
        id: 'b',
        day: _monday,
        slot: MealSlot.lunch,
        recipeId: 'suppe',
        recipeTitle: soup.title,
      ),
      MealPlanEntry(
        id: 'c',
        day: _monday,
        slot: MealSlot.snack,
        recipeId: 'fehlt',
        recipeTitle: 'Nicht mehr da',
      ),
    ];

    test('Zutaten werden zusammengeführt, skaliert und abgezogen', () {
      final needs = shoppingNeedsForPlan(
        entries: entries,
        recipeFor: (id) => recipes[id],
        pantry: const [
          PantryItem(
            id: 'p',
            name: 'Reis',
            amount: KitchenAmount(40, KitchenUnit.gram),
          ),
          PantryItem(id: 'm', name: 'Milch'),
        ],
        assumeBasics: true,
        planKey: 'plan-2026-09-28',
      );
      final byName = {for (final draft in needs.drafts) draft.name: draft};
      // 400 g × 4/2 portions + 300 g soup.
      expect(
        byName['Kartoffeln']!.amount,
        const KitchenAmount(1100, KitchenUnit.gram),
      );
      expect(
        byName['Zwiebel']!.amount,
        const KitchenAmount(160, KitchenUnit.gram),
      );
      expect(byName['Zwiebel']!.note, '2 Zwiebeln');
      // 100 g needed, 40 g at home.
      expect(byName['Reis']!.amount, const KitchenAmount(60, KitchenUnit.gram));
      expect(byName.containsKey('Milch'), isFalse);
      expect(byName.containsKey('Olivenöl'), isFalse);
      expect(needs.coveredByPantry, ['Milch']);
      expect(needs.skippedBasics, containsAll(['Olivenöl', 'Salz']));
      expect(needs.unavailableRecipes, 1);
      expect(needs.plannedMeals, 3);
      expect(needs.drafts.every((d) => d.planKey == 'plan-2026-09-28'), isTrue);
    });

    test('ohne Grundzutaten-Annahme landen auch Öl und Salz auf der Liste', () {
      final needs = shoppingNeedsForPlan(
        entries: entries.take(1),
        recipeFor: (id) => recipes[id],
        pantry: const [],
        assumeBasics: false,
      );
      expect(
        needs.drafts.map((d) => d.name),
        containsAll(['Olivenöl', 'Salz']),
      );
    });

    test('erneutes Erstellen ersetzt statt zu verdoppeln', () {
      var id = 0;
      String newId() => 'id${id++}';
      final first = mergeShoppingDrafts(
        const [ShoppingItem(id: 'manual', name: 'Zwiebeln')],
        const [
          ShoppingDraft(name: 'Kartoffeln', planKey: 'w1'),
          ShoppingDraft(name: 'Zwiebel', planKey: 'w1'),
        ],
        newId: newId,
        now: _now,
        replacePlanKey: 'w1',
      );
      expect(first.added, ['Kartoffeln']);
      expect(first.alreadyOnList, ['Zwiebel']);
      final second = mergeShoppingDrafts(
        first.items,
        const [
          ShoppingDraft(
            name: 'Kartoffeln',
            amount: KitchenAmount(900, KitchenUnit.gram),
            planKey: 'w1',
          ),
        ],
        newId: newId,
        now: _now,
        replacePlanKey: 'w1',
      );
      final potatoes = second.items.where((i) => i.name == 'Kartoffeln');
      expect(potatoes, hasLength(1));
      expect(
        potatoes.single.amount,
        const KitchenAmount(900, KitchenUnit.gram),
      );
      expect(second.items.map((i) => i.name), contains('Zwiebeln'));
    });
  });

  group('PlanningController', () {
    test('ohne Konto: nur im Speicher, sofort nutzbar', () {
      final planning = PlanningController(now: () => _now);
      expect(planning.persistent, isFalse);
      expect(planning.ready, isTrue);
      expect(
        planning.addPantryItem('Kartoffeln', amountText: '1 kg').status,
        KitchenEditStatus.added,
      );
      expect(
        planning.addPantryItem('kartoffel', amountText: '500 g').status,
        KitchenEditStatus.merged,
      );
      expect(
        planning.pantry.single.amount,
        const KitchenAmount(1500, KitchenUnit.gram),
      );
      expect(
        planning.addPantryItem('Kartoffeln').status,
        KitchenEditStatus.duplicate,
      );
      planning.dispose();
    });

    test('Halal-Regel und leere Namen werden abgelehnt', () {
      final planning = PlanningController(now: () => _now);
      expect(
        planning.addPantryItem('Schweinebauch').status,
        KitchenEditStatus.invalid,
      );
      expect(
        planning.addShoppingItem('Weißwein').status,
        KitchenEditStatus.invalid,
      );
      expect(planning.addShoppingItem('   ').status, KitchenEditStatus.invalid);
      expect(
        planning.addShoppingItem('Hähnchenbrust').status,
        KitchenEditStatus.invalid,
      );
      expect(
        planning.addShoppingItem('Hähnchenbrust halal').status,
        KitchenEditStatus.added,
      );
      expect(planning.pantry, isEmpty);
      planning.dispose();
    });

    test(
      'Einkaufsliste: abhaken, in Vorräte übernehmen, Erledigte löschen',
      () {
        final planning = PlanningController(now: () => _now);
        planning.addShoppingItem('Reis', amountText: '500 g');
        planning.addShoppingItem('Eier', amountText: '6');
        planning.addShoppingItem('Milch');
        expect(
          planning.addShoppingItem('Milch').status,
          KitchenEditStatus.duplicate,
        );
        planning.addPantryItem('Reis', amountText: '200 g');
        final rice = planning.shopping.first;
        final eggs = planning.shopping[1];
        planning.toggleShoppingItem(rice.id);
        planning.toggleShoppingItem(eggs.id);
        expect(planning.openShoppingCount, 1);
        expect(planning.moveCheckedToPantryItems(), 2);
        expect(planning.shopping.map((i) => i.name), ['Milch']);
        expect(
          planning.pantryItemFor('Reis')!.amount,
          const KitchenAmount(700, KitchenUnit.gram),
        );
        expect(
          planning.pantryItemFor('Ei')!.amount,
          const KitchenAmount(6, KitchenUnit.piece),
        );
        planning.toggleShoppingItem(planning.shopping.single.id);
        expect(planning.clearCheckedShopping(), 1);
        expect(planning.shopping, isEmpty);
        planning.dispose();
      },
    );

    test('Wochenplan: planen, verschieben, entfernen, Liste erstellen', () {
      final planning = PlanningController(now: () => _now);
      final recipe = _recipe('dal', {
        'Rote Linsen': 200,
        'Zwiebel': 80,
        'Salz': 2,
      });
      expect(
        planning.addPlanEntry(
          recipe: recipe,
          day: _now,
          slot: MealSlot.dinner,
          portions: 2,
        ),
        isTrue,
      );
      final entry = planning.plan.single;
      planning.updatePlanEntry(
        entry.id,
        day: DateTime(2026, 10, 6, 18),
        slot: MealSlot.lunch,
        portions: 20,
      );
      final moved = planning.plan.single;
      expect(moved.day, DateTime(2026, 10, 6));
      expect(moved.slot, MealSlot.lunch);
      expect(moved.portions, maxPlanPortions);
      expect(planning.entriesForWeek(_monday), isEmpty);
      expect(planning.entriesForWeek(DateTime(2026, 10, 5)), hasLength(1));

      planning.addPantryItem('Zwiebeln');
      final summary = planning.createShoppingFromPlan(DateTime(2026, 10, 5), [
        recipe,
      ])!;
      expect(summary.added, ['Rote Linsen']);
      expect(summary.coveredByPantry, ['Zwiebel']);
      expect(summary.skippedBasics, ['Salz']);
      // 200 g × 12/2 portions.
      expect(
        planning.shopping.single.amount,
        const KitchenAmount(1200, KitchenUnit.gram),
      );
      // Again: replaced, not doubled.
      planning.createShoppingFromPlan(DateTime(2026, 10, 5), [recipe]);
      expect(planning.shopping, hasLength(1));

      planning.removePlanEntry(moved.id);
      expect(planning.plan, isEmpty);
      planning.dispose();
    });

    test(
      'mit Konto: lädt, speichert jede Änderung und trennt Konten',
      () async {
        final store = MemoryPlanningStore();
        final first = PlanningController(
          userId: 'user-a',
          store: store,
          now: () => _now,
        );
        expect(first.ready, isFalse);
        expect(first.addPantryItem('Reis').status, KitchenEditStatus.notReady);
        await first.load();
        expect(first.ready, isTrue);
        first.addPantryItem('Reis');
        first.setAssumeBasics(false);
        await first.pendingWrites;
        first.dispose();

        final again = PlanningController(
          userId: 'user-a',
          store: store,
          now: () => _now,
        );
        await again.load();
        expect(again.pantryNames, ['Reis']);
        expect(again.assumeBasics, isFalse);

        final other = PlanningController(
          userId: 'user-b',
          store: store,
          now: () => _now,
        );
        await other.load();
        expect(other.pantry, isEmpty);

        expect(await again.clearAll(), isTrue);
        expect(store.saved.containsKey('user-a'), isFalse);
        expect(again.pantry, isEmpty);
        again.dispose();
        other.dispose();
      },
    );

    test('unlesbare Daten werden nicht überschrieben', () async {
      final store = MemoryPlanningStore(failLoad: true);
      final planning = PlanningController(
        userId: 'user-a',
        store: store,
        now: () => _now,
      );
      await planning.load();
      expect(planning.ready, isFalse);
      expect(planning.loadError, isNotNull);
      expect(
        planning.addShoppingItem('Milch').status,
        KitchenEditStatus.notReady,
      );
      expect(store.saveCount, 0);
      planning.dispose();
    });

    test('Speicherfehler wird angezeigt', () async {
      final store = MemoryPlanningStore(failSave: true);
      final planning = PlanningController(
        userId: 'user-a',
        store: store,
        now: () => _now,
      );
      await planning.load();
      planning.addPantryItem('Mehl');
      await planning.pendingWrites;
      expect(planning.saveError, isNotNull);
      expect(planning.pantryNames, ['Mehl']);
      planning.dispose();
    });
  });

  test('DevicePlanningStore speichert pro Konto auf dem Gerät', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    const store = DevicePlanningStore();
    expect(await store.load('konto-1'), isNull);
    await store.save(
      'konto-1',
      const KitchenState(
        pantry: [PantryItem(id: 'a', name: 'Eier')],
      ),
    );
    expect((await store.load('konto-1'))!.pantry.single.name, 'Eier');
    expect(await store.load('konto-2'), isNull);
    expect(DevicePlanningStore.keyFor('a/b'), 'livo.kitchen.v1.a%2Fb');

    await SharedPreferencesAsync().setString(
      DevicePlanningStore.keyFor('konto-3'),
      '{"version": 7}',
    );
    expect(() => store.load('konto-3'), throwsFormatException);

    await store.clear('konto-1');
    expect(await store.load('konto-1'), isNull);
    expect(() => DevicePlanningStore.keyFor(' '), throwsArgumentError);
  });
}
