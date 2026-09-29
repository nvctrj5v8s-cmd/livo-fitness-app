import 'package:fitness_ai_app/core/models/app_models.dart';
import 'package:fitness_ai_app/features/discover/domain/recipe_filter.dart';
import 'package:fitness_ai_app/features/discover/domain/recipe_serving.dart';
import 'package:flutter_test/flutter_test.dart';

Recipe _recipe(
  String id, {
  int minutes = 20,
  int calories = 500,
  int protein = 30,
  String difficulty = 'Einfach',
  List<String> tags = const [],
  List<String> ingredients = const [],
}) => Recipe(
  id: id,
  title: id,
  subtitle: '',
  minutes: minutes,
  calories: calories,
  protein: protein,
  difficulty: difficulty,
  imageAsset: '',
  tags: ['Für dich', ...tags],
  ingredients: [
    for (final name in ingredients)
      RecipeIngredient(foodId: name, name: name, amountGrams: 100),
  ],
);

void main() {
  group('Haushaltsmaße', () {
    test('werden sinnvoll umgerechnet', () {
      expect(scaleHouseholdMeasure('1 EL', 1), '1 EL');
      expect(scaleHouseholdMeasure('1 EL', 2), '2 EL');
      expect(scaleHouseholdMeasure('1 EL', 1.5), '1½ EL');
      expect(scaleHouseholdMeasure('½ Stück', 1.5), '¾ Stück');
      expect(scaleHouseholdMeasure('2 Zehen', 0.5), '1 Zehe');
      expect(scaleHouseholdMeasure('1 Filet', 2), '2 Filets');
      expect(scaleHouseholdMeasure('1/2 TL', 2), '1 TL');
      expect(scaleHouseholdMeasure('1 EL', 5 / 6), 'ca. ¾ EL');
    });

    test('werden ausgeblendet, wenn die Umrechnung irreführen würde', () {
      expect(scaleHouseholdMeasure('1 Dose (400 g)', 2), isNull);
      expect(scaleHouseholdMeasure('2–3 Zehen', 2), isNull);
      expect(scaleHouseholdMeasure('etwas', 2), isNull);
      expect(scaleHouseholdMeasure('1 Knubbel', 2), isNull);
      expect(scaleHouseholdMeasure('1 Prise', 0.1), isNull);
      expect(scaleHouseholdMeasure(null, 2), isNull);
    });

    test('Portionen werden mit Brüchen beschriftet', () {
      expect(formatFractionDe(1.5), '1½');
      expect(formatFractionDe(0.75), '¾');
      expect(formatFractionDe(2), '2');
      expect(portionsLabel(1), '1 Portion');
      expect(portionsLabel(0.5), '½ Portion');
      expect(portionsLabel(4), '4 Portionen');
    });

    test('Zutaten werden auf gewählte Portionen skaliert', () {
      const recipe = Recipe(
        id: 'r',
        title: 'R',
        subtitle: '',
        minutes: 10,
        calories: 300,
        protein: 20,
        imageAsset: '',
        tags: [],
        servings: 2,
        ingredients: [
          RecipeIngredient(
            foodId: 'a',
            name: 'Öl',
            amountGrams: 10,
            measure: '1 EL',
            nutrition: RecipeNutrition(calories: 88, protein: 0, fat: 10),
          ),
        ],
      );
      final scaled = scaleIngredients(recipe, 3).single;
      expect(scaled.grams, 15);
      expect(scaled.measure, '1½ EL');
      expect(scaled.nutrition!.calories, closeTo(132, 0.001));
    });
  });

  group('Rezeptfilter', () {
    final recipes = [
      _recipe(
        'bowl',
        minutes: 25,
        calories: 620,
        protein: 44,
        tags: ['Mittagessen', 'High Protein'],
        ingredients: ['Lachsfilet', 'Avocado'],
      ),
      _recipe(
        'oats',
        minutes: 8,
        calories: 430,
        protein: 31,
        tags: ['Frühstück', 'Vegetarisch'],
        ingredients: ['Haferflocken', 'Skyr'],
      ),
      _recipe(
        'tofu',
        minutes: 30,
        calories: 510,
        protein: 36,
        difficulty: 'Mittel',
        tags: ['Abendessen', 'Vegan'],
        ingredients: ['Tofu', 'Käse-Ersatz'],
      ),
    ];

    test('Suche findet Zutaten, Tags und ignoriert Umlaute', () {
      List<String> ids(String query) => [
        for (final recipe in applyRecipeFilter(
          recipes,
          RecipeFilter(query: query),
        ))
          recipe.id,
      ];
      expect(ids('avocado'), ['bowl']);
      expect(ids('kase'), ['tofu']);
      expect(ids('frühstück'), ['oats']);
      expect(ids('lachs avocado'), ['bowl']);
      expect(ids('lachs tofu'), isEmpty);
      expect(ids(''), ['bowl', 'oats', 'tofu']);
    });

    test('Vegetarisch schließt vegane Rezepte ein', () {
      final result = applyRecipeFilter(
        recipes,
        const RecipeFilter(tags: {'Vegetarisch'}),
      );
      expect(result.map((recipe) => recipe.id), ['oats', 'tofu']);
    });

    test('Mahlzeit, Zeit, Schwierigkeit und Favoriten filtern', () {
      expect(
        applyRecipeFilter(
          recipes,
          const RecipeFilter(mealType: 'Frühstück'),
        ).single.id,
        'oats',
      );
      expect(
        applyRecipeFilter(
          recipes,
          const RecipeFilter(maxMinutes: 15),
        ).single.id,
        'oats',
      );
      expect(
        applyRecipeFilter(
          recipes,
          const RecipeFilter(difficulty: 'Mittel'),
        ).single.id,
        'tofu',
      );
      expect(
        applyRecipeFilter(
          recipes,
          const RecipeFilter(favoritesOnly: true),
          favoriteIds: {'bowl'},
        ).single.id,
        'bowl',
      );
    });

    test('Sortierung behält die Für-dich-Reihenfolge als Gleichstand', () {
      List<String> sorted(RecipeSort sort) => [
        for (final recipe in applyRecipeFilter(
          recipes,
          RecipeFilter(sort: sort),
        ))
          recipe.id,
      ];
      expect(sorted(RecipeSort.forYou), ['bowl', 'oats', 'tofu']);
      expect(sorted(RecipeSort.quickest), ['oats', 'bowl', 'tofu']);
      expect(sorted(RecipeSort.mostProtein), ['bowl', 'tofu', 'oats']);
      expect(sorted(RecipeSort.fewestCalories), ['oats', 'tofu', 'bowl']);
    });

    test('nur vorhandene Tags werden angeboten', () {
      expect(availableRecipeTags(recipes, recipeMealTypes), [
        'Frühstück',
        'Mittagessen',
        'Abendessen',
      ]);
      expect(availableRecipeTags(recipes, recipeGoalTags), [
        'High Protein',
        'Vegetarisch',
        'Vegan',
      ]);
      expect(availableRecipeDifficulties(recipes), ['Einfach', 'Mittel']);
    });
  });

  group('Portionsvorschlag', () {
    test('teilt die offenen Kalorien auf die restlichen Mahlzeiten auf', () {
      final suggestion = suggestPortion(
        caloriesPerPortion: 480,
        calorieGoal: 2000,
        consumedCalories: 800,
        mealsPerDay: 3,
        mealsLogged: 1,
      )!;
      expect(suggestion.mealsLeft, 2);
      expect(suggestion.mealBudget, 600);
      expect(suggestion.factor, 1.25);
      expect(suggestion.goalReached, isFalse);
    });

    test('bleibt zwischen einer halben und zwei Portionen', () {
      expect(
        suggestPortion(
          caloriesPerPortion: 150,
          calorieGoal: 2000,
          consumedCalories: 0,
          mealsPerDay: 3,
          mealsLogged: 0,
        )!.factor,
        2,
      );
      final reached = suggestPortion(
        caloriesPerPortion: 500,
        calorieGoal: 2000,
        consumedCalories: 2100,
        mealsPerDay: 3,
        mealsLogged: 3,
      )!;
      expect(reached.factor, 0.5);
      expect(reached.goalReached, isTrue);
      expect(
        suggestPortion(
          caloriesPerPortion: 0,
          calorieGoal: 2000,
          consumedCalories: 0,
          mealsPerDay: 3,
          mealsLogged: 0,
        ),
        isNull,
      );
    });
  });

  test('Tagebuch-Mahlzeit folgt Rezept-Tag und Tageszeit', () {
    final breakfast = _recipe('b', tags: ['Frühstück']);
    final mains = _recipe('m', tags: ['Mittagessen', 'Abendessen']);
    final open = _recipe('o');
    expect(
      suggestedMealSlot(breakfast, DateTime(2026, 9, 27, 19)),
      MealSlot.breakfast,
    );
    expect(
      suggestedMealSlot(mains, DateTime(2026, 9, 27, 19)),
      MealSlot.dinner,
    );
    expect(suggestedMealSlot(mains, DateTime(2026, 9, 27, 8)), MealSlot.lunch);
    expect(
      suggestedMealSlot(open, DateTime(2026, 9, 27, 8)),
      MealSlot.breakfast,
    );
    expect(suggestedMealSlot(open, DateTime(2026, 9, 27, 15)), MealSlot.snack);
  });
}
