import 'package:fitness_ai_app/core/data/food_preferences_store.dart';
import 'package:fitness_ai_app/core/models/custom_food.dart';
import 'package:fitness_ai_app/core/models/saved_custom_food.dart';
import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/diary/presentation/custom_food_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const nutrition = CustomFoodNutrition(
  basis: NutritionBasis.per100g,
  amount: 35,
  calories: 380,
  protein: 12,
  carbohydrates: 62,
  fat: 7,
  sugar: 1,
  saturatedFat: 1,
  salt: .1,
);
const food = SavedCustomFood(
  id: 'oats',
  name: 'Meine Haferflocken',
  nutrition: nutrition,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'templates retain typed label values and are isolated and deletable by account',
    () async {
      final alice = FoodPreferencesStore(userId: 'alice');
      final bob = FoodPreferencesStore(userId: 'bob');
      await alice.saveCustomFoods([food]);
      final restored = (await alice.load()).customFoods.single;
      expect(restored.nutrition.toJson(), nutrition.toJson());
      expect(restored.toJson()['source'], 'user_entered');
      expect((await bob.load()).customFoods, isEmpty);
      expect((await FoodPreferencesStore().load()).customFoods, isEmpty);
      await alice.clear();
      expect((await alice.load()).customFoods, isEmpty);
    },
  );

  test('demo templates are memory only and replace existing names', () async {
    final app = AppController();
    addTearDown(app.dispose);
    expect(
      await app.saveCustomFoodTemplate(name: food.name, nutrition: nutrition),
      isTrue,
    );
    expect(
      await app.saveCustomFoodTemplate(
        name: food.name,
        nutrition: nutrition.copyWith(amount: 60),
      ),
      isTrue,
    );
    expect(app.savedCustomFoods, hasLength(1));
    expect(app.savedCustomFoods.single.nutrition.amount, 60);
    expect((await FoodPreferencesStore().load()).customFoods, isEmpty);
    expect(
      await app.removeCustomFoodTemplate(app.savedCustomFoods.single.id),
      isTrue,
    );
    expect(app.savedCustomFoods, isEmpty);
  });

  testWidgets('a remembered food fills editable values and can be deleted', (
    tester,
  ) async {
    final app = AppController();
    addTearDown(app.dispose);
    await app.saveCustomFoodTemplate(name: food.name, nutrition: nutrition);
    tester.view.physicalSize = const Size(834, 1194);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      AppScope(
        controller: app,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: CustomFoodSheet(date: DateTime(2026, 10, 29))),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(food.name).last);
    await tester.pumpAndSettle();
    final name = tester.widget<TextFormField>(
      find.byKey(const Key('custom-name')),
    );
    expect(name.controller!.text, food.name);
    final amount = tester.widget<TextFormField>(
      find.byKey(const Key('custom-amount')),
    );
    expect(amount.controller!.text, '35');
    expect(
      tester
          .widget<CheckboxListTile>(find.byKey(const Key('custom-remember')))
          .value,
      isTrue,
    );
    await tester.tap(find.byKey(const Key('custom-template-delete')));
    await tester.pumpAndSettle();
    expect(app.savedCustomFoods, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
