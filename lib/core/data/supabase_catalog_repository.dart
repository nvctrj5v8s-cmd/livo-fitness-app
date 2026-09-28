import 'package:supabase_flutter/supabase_flutter.dart';

import 'halal_content_policy.dart';
import 'recipe_images.dart';
import '../models/app_models.dart';

class SupabaseCatalogRepository {
  SupabaseCatalogRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Supabase answers at most "Max rows" (1000 by default) per request, so
  /// the catalog with several thousand foods is read page by page. Every page
  /// is ordered by a unique key; otherwise rows could repeat or go missing.
  static const catalogPageSize = 1000;

  Future<List<Map<String, dynamic>>> _selectAll(
    String table,
    List<(String, bool)> order,
  ) async {
    final rows = <Map<String, dynamic>>[];
    while (true) {
      PostgrestTransformBuilder<PostgrestList> query = _client
          .from(table)
          .select();
      for (final (column, ascending) in order) {
        query = query.order(column, ascending: ascending);
      }
      final page = await query.range(
        rows.length,
        rows.length + catalogPageSize - 1,
      );
      // The next page starts after the rows really received, so a server
      // limit below [catalogPageSize] cannot skip rows either.
      if (page.isEmpty) break;
      rows.addAll(
        page.whereType<Map>().map((row) => Map<String, dynamic>.from(row)),
      );
    }
    return rows;
  }

  Future<CatalogData> loadCatalog() async {
    final foodRows = await _selectAll('foods', const [('id', true)]);
    final recipeRows = await _selectAll('recipes', const [
      ('created_at', false),
      ('id', true),
    ]);
    // Ingredients are shown in the recipe's own order (position 1, 2, 3 …).
    final ingredientRows = await _selectAll('recipe_ingredients', const [
      ('recipe_id', true),
      ('position', true),
      ('food_id', true),
    ]);
    final premiumRows = await _loadPremiumDetails();
    final allFoods = foodRows
        .whereType<Map>()
        .map((row) => FoodItem.fromMap(Map<String, dynamic>.from(row)))
        .toList();
    final blockedFoodIds = allFoods
        .where((food) => !HalalContentPolicy.isAllowedFood(food))
        .map((food) => food.id)
        .toSet();
    final foods = allFoods.where(HalalContentPolicy.isAllowedFood).toList();
    final foodsById = {for (final food in foods) food.id: food};
    final ingredientsByRecipe = <String, List<Map<String, dynamic>>>{};
    for (final raw in ingredientRows.whereType<Map>()) {
      final row = Map<String, dynamic>.from(raw);
      final recipeId = row['recipe_id']?.toString();
      if (recipeId == null) continue;
      ingredientsByRecipe.putIfAbsent(recipeId, () => []).add(row);
    }
    final recipes = <Recipe>[];
    for (final rawRecipe in recipeRows.whereType<Map>()) {
      final row = Map<String, dynamic>.from(rawRecipe);
      final recipeId = row['id']?.toString();
      final ingredientRows = ingredientsByRecipe[recipeId] ?? const [];
      final hasBlockedIngredient = ingredientRows.any(
        (ingredient) =>
            blockedFoodIds.contains(ingredient['food_id']?.toString()),
      );
      if (hasBlockedIngredient) continue;
      final recipe = recipeFromMap(
        row,
        ingredientRows,
        foodsById,
        premiumRow: premiumRows[recipeId],
      );
      if (HalalContentPolicy.isAllowedRecipe(recipe)) recipes.add(recipe);
    }
    return CatalogData(foods: foods, recipes: recipes);
  }

  /// RLS only returns rows to Premium members. Free accounts, signed-out
  /// visitors and databases without the table simply get no extras.
  Future<Map<String, Map<String, dynamic>>> _loadPremiumDetails() async {
    try {
      final rows = await _client.from('recipe_premium_details').select();
      return {
        for (final raw in rows.whereType<Map>())
          raw['recipe_id'].toString(): Map<String, dynamic>.from(raw),
      };
    } on PostgrestException {
      return const {};
    }
  }

  static Recipe recipeFromMap(
    Map<String, dynamic> row,
    List<Map<String, dynamic>> ingredients,
    Map<String, FoodItem> foodsById, {
    Map<String, dynamic>? premiumRow,
  }) {
    var total = RecipeNutrition.zero;
    final recipeIngredients = <RecipeIngredient>[];
    for (final raw in ingredients) {
      final amount = (raw['amount_grams'] as num?)?.toDouble() ?? 0;
      final food = foodsById[raw['food_id']?.toString()];
      if (food == null) continue;
      final nutrition = _nutritionFor(food, amount);
      total += nutrition;
      recipeIngredients.add(
        RecipeIngredient(
          foodId: food.id,
          name: food.name,
          amountGrams: amount,
          measure: _text(raw['measure']),
          note: _text(raw['note']),
          nutrition: nutrition,
        ),
      );
    }
    final servings = ((row['servings'] as num?)?.toInt() ?? 1).clamp(1, 24);
    final perServing = total.scaled(1 / servings);
    final slug = row['slug'] as String? ?? '';
    final texts = _strings(row['instructions']);
    final titles = _strings(row['step_titles']);
    final timers = (row['step_minutes'] as List?) ?? const [];
    return Recipe(
      id: row['id'].toString(),
      slug: slug,
      title: row['title'] as String? ?? 'Rezept',
      subtitle: row['description'] as String? ?? '',
      minutes: (row['preparation_minutes'] as num?)?.toInt() ?? 15,
      prepMinutes: (row['prep_minutes'] as num?)?.toInt(),
      cookMinutes: (row['cook_minutes'] as num?)?.toInt(),
      difficulty: _text(row['difficulty']) ?? 'Einfach',
      servings: servings,
      isPremium: row['access_level'] == 'premium',
      calories: perServing.calories.round(),
      protein: perServing.protein.round(),
      nutritionPerServing: perServing,
      imageAsset: RecipeImages.forSlug(slug),
      tags: ['Für dich', ..._strings(row['tags'])],
      equipment: _strings(row['equipment']),
      ingredients: recipeIngredients,
      steps: [
        for (var index = 0; index < texts.length; index++)
          RecipeStep(
            text: texts[index],
            title: index < titles.length ? _text(titles[index]) : null,
            minutes: index < timers.length
                ? (timers[index] as num?)?.toInt() ?? 0
                : 0,
          ),
      ],
      premiumDetails: premiumRow == null ? null : _premiumFromMap(premiumRow),
    );
  }

  static RecipePremiumDetails? _premiumFromMap(Map<String, dynamic> row) {
    final details = RecipePremiumDetails(
      stepTips: _strings(row['step_tips'], keepEmpty: true),
      commonMistakes: _strings(row['common_mistakes']),
      substitutions: _strings(row['substitutions']),
      mealPrep: _text(row['meal_prep']) ?? '',
      variations: _strings(row['variations']),
      servingTip: _text(row['serving_tip']) ?? '',
    );
    return details.isEmpty ? null : details;
  }

  static RecipeNutrition _nutritionFor(FoodItem food, double grams) {
    final base = food.servingGrams <= 0 ? 100 : food.servingGrams;
    final factor = grams / base;
    return RecipeNutrition(
      calories: food.calories * factor,
      protein: food.protein * factor,
      carbohydrates: food.carbohydrates * factor,
      fat: food.fat * factor,
      fiber: (food.fiber ?? 0) * factor,
      sugar: (food.sugar ?? 0) * factor,
      salt: (food.salt ?? 0) * factor,
    );
  }

  static List<String> _strings(Object? value, {bool keepEmpty = false}) => [
    for (final item in (value as List?) ?? const [])
      if (item is String && (keepEmpty || item.trim().isNotEmpty)) item.trim(),
  ];

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class CatalogData {
  const CatalogData({required this.foods, required this.recipes});

  final List<FoodItem> foods;
  final List<Recipe> recipes;
}
