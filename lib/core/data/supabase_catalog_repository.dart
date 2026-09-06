import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

class SupabaseCatalogRepository {
  SupabaseCatalogRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<CatalogData> loadCatalog() async {
    final foodRows = await _client.from('foods').select();
    final recipeRows = await _client.from('recipes').select().order('created_at');
    final ingredientRows = await _client.from('recipe_ingredients').select();
    final foods = foodRows
        .whereType<Map>()
        .map((row) => FoodItem.fromMap(Map<String, dynamic>.from(row)))
        .toList();
    final foodsById = {for (final food in foods) food.id: food};
    final ingredientsByRecipe = <String, List<Map<String, dynamic>>>{};
    for (final raw in ingredientRows.whereType<Map>()) {
      final row = Map<String, dynamic>.from(raw);
      final recipeId = row['recipe_id']?.toString();
      if (recipeId == null) continue;
      ingredientsByRecipe.putIfAbsent(recipeId, () => []).add(row);
    }
    final recipes = recipeRows
        .whereType<Map>()
        .map((row) {
          final recipe = Map<String, dynamic>.from(row);
          return _recipeFromMap(
            recipe,
            ingredientsByRecipe[recipe['id']?.toString()] ?? const [],
            foodsById,
          );
        })
        .toList();
    return CatalogData(foods: foods, recipes: recipes);
  }

  Recipe _recipeFromMap(
    Map<String, dynamic> row,
    List<Map<String, dynamic>> ingredients,
    Map<String, FoodItem> foodsById,
  ) {
    var calories = 0.0;
    var protein = 0.0;
    for (final raw in ingredients) {
      final amount = (raw['amount_grams'] as num?)?.toDouble() ?? 0;
      final food = foodsById[raw['food_id']?.toString()];
      if (food != null) {
        final factor = amount / food.servingGrams;
        calories += food.calories * factor;
        protein += food.protein * factor;
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
