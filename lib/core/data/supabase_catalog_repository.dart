import 'package:supabase_flutter/supabase_flutter.dart';

import 'halal_content_policy.dart';
import '../models/app_models.dart';

class SupabaseCatalogRepository {
  SupabaseCatalogRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<CatalogData> loadCatalog() async {
    final foodRows = await _client.from('foods').select();
    final recipeRows = await _client
        .from('recipes')
        .select()
        .order('created_at');
    final ingredientRows = await _client
        .from('recipe_ingredients')
        .select('recipe_id, food_id, amount_grams, position')
        .order('position');
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
      final ingredientRows =
          ingredientsByRecipe[row['id']?.toString()] ?? const [];
      final hasBlockedIngredient = ingredientRows.any(
        (ingredient) =>
            blockedFoodIds.contains(ingredient['food_id']?.toString()),
      );
      if (hasBlockedIngredient) continue;
      final recipe = _recipeFromMap(row, ingredientRows, foodsById);
      if (HalalContentPolicy.isAllowedRecipe(recipe)) recipes.add(recipe);
    }
    return CatalogData(foods: foods, recipes: recipes);
  }

  Recipe _recipeFromMap(
    Map<String, dynamic> row,
    List<Map<String, dynamic>> ingredients,
    Map<String, FoodItem> foodsById,
  ) {
    var calories = 0.0;
    var protein = 0.0;
    final recipeIngredients = <RecipeIngredient>[];
    for (final raw in ingredients) {
      final amount = (raw['amount_grams'] as num?)?.toDouble() ?? 0;
      final food = foodsById[raw['food_id']?.toString()];
      if (food != null) {
        final factor = amount / food.servingGrams;
        calories += food.calories * factor;
        protein += food.protein * factor;
        recipeIngredients.add(
          RecipeIngredient(
            foodId: food.id,
            name: food.name,
            amountGrams: amount,
          ),
        );
      }
    }
    final slug = row['slug'] as String? ?? '';
    return Recipe(
      id: row['id'].toString(),
      title: row['title'] as String? ?? 'Rezept',
      subtitle: row['description'] as String? ?? '',
      minutes: (row['preparation_minutes'] as num?)?.toInt() ?? 15,
      calories: calories.round(),
      protein: protein.round(),
      imageAsset: _imageForSlug(slug),
      tags: [
        'Für dich',
        ...((row['tags'] as List?)?.whereType<String>() ?? const <String>[]),
      ],
      ingredients: recipeIngredients,
      instructions:
          (row['instructions'] as List?)?.whereType<String>().toList() ??
          const [],
    );
  }

  String _imageForSlug(String slug) {
    if (slug.contains('salmon')) return 'assets/images/salmon_bowl.webp';
    if (slug.contains('berry') || slug.contains('oat')) {
      return 'assets/images/berry_oats.webp';
    }
    if (slug.contains('pasta')) return 'assets/images/protein_pasta.webp';
    return 'assets/images/berry_oats.webp';
  }
}

class CatalogData {
  const CatalogData({required this.foods, required this.recipes});

  final List<FoodItem> foods;
  final List<Recipe> recipes;
}
