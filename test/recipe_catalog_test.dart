import 'dart:io';

import 'package:fitness_ai_app/core/data/recipe_images.dart';
import 'package:fitness_ai_app/core/data/supabase_catalog_repository.dart';
import 'package:fitness_ai_app/core/models/app_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rice = FoodItem(
    id: 'rice-id',
    name: 'Reis, gekocht',
    servingGrams: 100,
    calories: 130,
    protein: 2.7,
    carbohydrates: 28,
    fat: 0.3,
    fiber: 0.4,
    salt: 0,
  );
  const salmon = FoodItem(
    id: 'salmon-id',
    name: 'Lachsfilet',
    servingGrams: 100,
    calories: 208,
    protein: 20,
    carbohydrates: 0,
    fat: 13,
  );
  final foodsById = {rice.id: rice, salmon.id: salmon};

  Map<String, dynamic> recipeRow({int servings = 2}) => {
    'id': 'recipe-id',
    'slug': 'livo-salmon-avocado-rice',
    'title': 'Lachs-Avocado-Reis',
    'description': 'Lachs mit Reis.',
    'preparation_minutes': 25,
    'prep_minutes': 5,
    'cook_minutes': 20,
    'difficulty': 'Mittel',
    'servings': servings,
    'tags': ['Abendessen', 'High Protein'],
    'equipment': ['Topf', 'Pfanne'],
    'instructions': [
      'Reis in einem Topf mit Deckel erwärmen.',
      'Lachs bei mittlerer Hitze braten.',
    ],
    'step_titles': ['Reis', ''],
    'step_minutes': [4, 8],
    'access_level': 'premium',
  };

  final ingredients = [
    {
      'food_id': 'salmon-id',
      'amount_grams': 300,
      'measure': '2 Filets',
      'note': 'mit Haut',
    },
    {'food_id': 'rice-id', 'amount_grams': 200, 'measure': null},
    {'food_id': 'unknown-id', 'amount_grams': 50},
  ];

  test('maps detailed steps, equipment and ingredient notes', () {
    final recipe = SupabaseCatalogRepository.recipeFromMap(
      recipeRow(),
      ingredients,
      foodsById,
    );

    expect(recipe.slug, 'livo-salmon-avocado-rice');
    expect(recipe.isPremium, isTrue);
    expect(recipe.prepMinutes, 5);
    expect(recipe.cookMinutes, 20);
    expect(recipe.difficulty, 'Mittel');
    expect(recipe.equipment, ['Topf', 'Pfanne']);
    expect(recipe.steps, hasLength(2));
    expect(recipe.steps.first.title, 'Reis');
    expect(recipe.steps.first.minutes, 4);
    expect(recipe.steps.last.title, isNull);
    expect(recipe.instructions.last, 'Lachs bei mittlerer Hitze braten.');
    expect(recipe.ingredients, hasLength(2), reason: 'unknown food skipped');
    expect(recipe.ingredients.first.measure, '2 Filets');
    expect(recipe.ingredients.first.note, 'mit Haut');
    expect(recipe.premiumDetails, isNull);
  });

  test('reports nutrition per serving, amounts for the whole recipe', () {
    final recipe = SupabaseCatalogRepository.recipeFromMap(
      recipeRow(servings: 2),
      ingredients,
      foodsById,
    );

    // 300 g salmon + 200 g rice = 624 + 260 kcal for two servings.
    expect(recipe.calories, 442);
    expect(recipe.protein, 33);
    expect(recipe.nutrition.carbohydrates, closeTo(28, 0.01));
    expect(recipe.nutrition.fat, closeTo(19.8, 0.01));
    expect(recipe.nutrition.fiber, closeTo(0.4, 0.01));
    expect(recipe.ingredients.first.amountGrams, 300);
    expect(recipe.ingredients.first.nutrition!.calories, closeTo(624, 0.01));
  });

  test('reads premium extras only when a row is returned', () {
    final recipe = SupabaseCatalogRepository.recipeFromMap(
      recipeRow(),
      ingredients,
      foodsById,
      premiumRow: {
        'recipe_id': 'recipe-id',
        'step_tips': ['Reis nicht umrühren.', ''],
        'common_mistakes': ['Lachs zu früh wenden'],
        'substitutions': [],
        'meal_prep': 'Bis zu 2 Tage im Kühlschrank.',
        'variations': ['Mit Sesam'],
        'serving_tip': '',
      },
    );

    final details = recipe.premiumDetails!;
    expect(details.tipForStep(0), 'Reis nicht umrühren.');
    expect(details.tipForStep(1), isEmpty);
    expect(details.tipForStep(5), isEmpty);
    expect(details.commonMistakes, ['Lachs zu früh wenden']);
    expect(details.mealPrep, 'Bis zu 2 Tage im Kühlschrank.');
  });

  test('empty premium rows count as no extras', () {
    final recipe = SupabaseCatalogRepository.recipeFromMap(
      recipeRow(),
      ingredients,
      foodsById,
      premiumRow: {
        'recipe_id': 'recipe-id',
        'step_tips': ['', ''],
      },
    );

    expect(recipe.premiumDetails, isNull);
  });

  test(
    'every registered recipe photo exists and every photo is registered',
    () {
      final files = Directory('assets/images/recipes')
          .listSync()
          .whereType<File>()
          .map((file) => file.uri.pathSegments.last)
          .where((name) => name.endsWith('.webp'))
          .map((name) => name.substring(0, name.length - 5))
          .toSet();
      expect(files, RecipeImages.slugsWithPhoto);
      expect(
        RecipeImages.forSlug('livo-protein-oats'),
        'assets/images/recipes/livo-protein-oats.webp',
      );
      expect(RecipeImages.forSlug('unknown'), 'assets/images/berry_oats.webp');
    },
  );

  test('formats small gram amounts with a German decimal comma', () {
    expect(RecipeIngredient.formatGrams(0.5), '0,5 g');
    expect(RecipeIngredient.formatGrams(2), '2 g');
    expect(RecipeIngredient.formatGrams(152.4), '152 g');
  });
}
