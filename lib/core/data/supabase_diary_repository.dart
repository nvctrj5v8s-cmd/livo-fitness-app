import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';
import '../models/custom_food.dart';
import '../models/tracking_streak.dart';

/// Stores food and recipe diary entries independently from the widgets.
class SupabaseDiaryRepository {
  SupabaseDiaryRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _recipeNotePrefix = 'livo:recipe:';
  static const _customNotePrefix = 'livo:custom:';

  /// Paginated, user-scoped history. Empty partially-created meals do not count.
  Future<Set<DateTime>> loadTrackingDays(DateTime now) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return {};
    final days = <DateTime>{};
    const pageSize = 500;
    for (var offset = 0; ; offset += pageSize) {
      if (_client.auth.currentUser?.id != userId) {
        throw StateError('Konto geändert.');
      }
      final rows = await _client
          .from('meals')
          .select('id, meal_date, note, meal_items(id)')
          .eq('user_id', userId)
          .lte('meal_date', _dateOnly(now))
          .order('meal_date', ascending: false)
          .order('id')
          .range(offset, offset + pageSize - 1);
      for (final row in rows) {
        final items = row['meal_items'];
        if ((items is List && items.isNotEmpty) ||
            _customMealFromNote(row['note']) != null) {
          final date = DateTime.tryParse(row['meal_date'].toString());
          if (date != null) days.add(trackingDay(date));
        }
      }
      if (rows.length < pageSize) break;
    }
    return days;
  }

  Future<List<MealEntry>> loadMealsForDate(DateTime date) async {
    final user = _client.auth.currentUser;
    if (user == null) return const [];

    final day = _dateOnly(date);
    final mealRows = await _client
        .from('meals')
        .select('id, meal_type, created_at, note')
        .eq('user_id', user.id)
        .eq('meal_date', day)
        .order('created_at');
    final meals = mealRows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    if (meals.isEmpty) return const [];

    final mealIds = meals.map((meal) => meal['id'].toString()).toList();
    final itemRows = await _client
        .from('meal_items')
        .select('id, meal_id, food_id, amount_grams')
        .inFilter('meal_id', mealIds);
    final items = itemRows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    final foodIds = items.map((item) => item['food_id'].toString()).toSet();
    final foodRows = foodIds.isEmpty
        ? const <dynamic>[]
        : await _client
              .from('foods')
              .select(
                'id, name, serving_grams, calories, protein, carbohydrates, fat',
              )
              .inFilter('id', foodIds.toList());
    final foodsById = {
      for (final raw in foodRows.whereType<Map>())
        raw['id'].toString(): FoodItem.fromMap(Map<String, dynamic>.from(raw)),
    };
    final itemsByMealId = <String, List<Map<String, dynamic>>>{};
    for (final item in items) {
      itemsByMealId.putIfAbsent(item['meal_id'].toString(), () => []).add(item);
    }

    final recipeIds = meals
        .map((meal) => _recipeIdFromNote(meal['note']))
        .whereType<String>()
        .toSet();
    final recipeRows = recipeIds.isEmpty
        ? const <dynamic>[]
        : await _client
              .from('recipes')
              .select('id, title, slug')
              .inFilter('id', recipeIds.toList());
    final recipesById = {
      for (final raw in recipeRows.whereType<Map>())
        raw['id'].toString(): Map<String, dynamic>.from(raw),
    };

    final entries = <MealEntry>[];
    for (final meal in meals) {
      final mealId = meal['id'].toString();
      final slot = _mealSlotFromDatabase(meal['meal_type'] as String?);
      final mealItems = itemsByMealId[mealId] ?? const <Map<String, dynamic>>[];
      final customMeal = _customMealFromNote(meal['note']);
      if (customMeal != null) {
        entries.add(
          MealEntry(
            id: 'custom-$mealId',
            remoteMealId: mealId,
            name: customMeal.name,
            slot: slot,
            calories: customMeal.calories,
            protein: customMeal.protein,
            carbs: customMeal.carbs,
            fat: customMeal.fat,
            customNutrition: customMeal.nutrition,
          ),
        );
        continue;
      }
      final recipeId = _recipeIdFromNote(meal['note']);
      if (recipeId != null) {
        final recipe = recipesById[recipeId];
        final totals = _nutritionForItems(mealItems, foodsById);
        entries.add(
          MealEntry(
            id: 'recipe-$mealId',
            remoteMealId: mealId,
            recipeId: recipeId,
            name: recipe?['title'] as String? ?? 'Gespeichertes Rezept',
            slot: slot,
            calories: totals.calories.round(),
            protein: totals.protein.round(),
            carbs: totals.carbohydrates.round(),
            fat: totals.fat.round(),
            imageAsset: _imageForRecipeSlug(recipe?['slug'] as String?),
          ),
        );
        continue;
      }

      for (final item in mealItems) {
        final food = foodsById[item['food_id'].toString()];
        if (food == null) continue;
        final grams =
            (item['amount_grams'] as num?)?.toDouble() ?? food.servingGrams;
        entries.add(
          _entryFromFood(
            id: item['id'].toString(),
            remoteMealId: mealId,
            food: food,
            slot: slot,
            amountGrams: grams,
          ),
        );
      }
    }
    return entries;
  }

  Future<MealEntry> addFood({
    required FoodItem food,
    required MealSlot slot,
    required double amountGrams,
    required DateTime date,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Bitte melde dich an, bevor du etwas speicherst.');
    }
    if (amountGrams <= 0) {
      throw ArgumentError.value(
        amountGrams,
        'amountGrams',
        'Muss größer als 0 sein.',
      );
    }

    final meal = await _client
        .from('meals')
        .insert({
          'user_id': user.id,
          'meal_date': _dateOnly(date),
          'meal_type': slot.databaseValue,
        })
        .select('id')
        .single();
    try {
      final item = await _client
          .from('meal_items')
          .insert({
            'meal_id': meal['id'],
            'food_id': food.id,
            'amount_grams': amountGrams,
          })
          .select('id')
          .single();
      return _entryFromFood(
        id: item['id'].toString(),
        remoteMealId: meal['id'].toString(),
        food: food,
        slot: slot,
        amountGrams: amountGrams,
      );
    } catch (_) {
      await _client.from('meals').delete().eq('id', meal['id']);
      rethrow;
    }
  }

  Future<MealEntry> addCustomMeal({
    required String name,
    required MealSlot slot,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    required DateTime date,
    CustomFoodNutrition? nutrition,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Bitte melde dich an, bevor du etwas speicherst.');
    }
    final custom = _CustomMeal(
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      nutrition: nutrition,
    );
    final meal = await _client
        .from('meals')
        .insert({
          'user_id': user.id,
          'meal_date': _dateOnly(date),
          'meal_type': slot.databaseValue,
          'note': _noteForCustomMeal(custom),
        })
        .select('id')
        .single();
    return MealEntry(
      id: 'custom-${meal['id']}',
      remoteMealId: meal['id'].toString(),
      name: custom.name,
      slot: slot,
      calories: custom.calories,
      protein: custom.protein,
      carbs: custom.carbs,
      fat: custom.fat,
      customNutrition: custom.nutrition,
    );
  }

  Future<MealEntry> updateFoodEntry({
    required MealEntry entry,
    required FoodItem food,
    required MealSlot slot,
    required double amountGrams,
    required DateTime date,
  }) async {
    final mealId = entry.remoteMealId;
    if (mealId == null || entry.foodId == null || amountGrams <= 0) {
      throw ArgumentError('Der Lebensmitteleintrag ist unvollstaendig.');
    }
    await _client
        .from('meals')
        .update({'meal_type': slot.databaseValue, 'meal_date': _dateOnly(date)})
        .eq('id', mealId);
    await _client
        .from('meal_items')
        .update({'amount_grams': amountGrams})
        .eq('id', entry.id);
    return _entryFromFood(
      id: entry.id,
      remoteMealId: mealId,
      food: food,
      slot: slot,
      amountGrams: amountGrams,
    );
  }

  Future<MealEntry> updateMealSlot({
    required MealEntry entry,
    required MealSlot slot,
    required DateTime date,
  }) async {
    final mealId = entry.remoteMealId;
    if (mealId == null) {
      throw ArgumentError('Der Mahlzeiteneintrag ist nicht gespeichert.');
    }
    await _client
        .from('meals')
        .update({'meal_type': slot.databaseValue, 'meal_date': _dateOnly(date)})
        .eq('id', mealId);
    return entry.copyWith(slot: slot);
  }

  Future<MealEntry> updateCustomMeal({
    required MealEntry entry,
    required String name,
    required MealSlot slot,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    required DateTime date,
    CustomFoodNutrition? nutrition,
  }) async {
    final mealId = entry.remoteMealId;
    if (mealId == null) {
      throw ArgumentError('Der eigene Eintrag ist nicht gespeichert.');
    }
    final custom = _CustomMeal(
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      nutrition: nutrition,
    );
    await _client
        .from('meals')
        .update({
          'meal_type': slot.databaseValue,
          'meal_date': _dateOnly(date),
          'note': _noteForCustomMeal(custom),
        })
        .eq('id', mealId);
    return MealEntry(
      id: entry.id,
      remoteMealId: mealId,
      name: custom.name,
      slot: slot,
      calories: custom.calories,
      protein: custom.protein,
      carbs: custom.carbs,
      fat: custom.fat,
      customNutrition: custom.nutrition,
    );
  }

  Future<MealEntry> addRecipe({
    required Recipe recipe,
    required MealSlot slot,
    required DateTime date,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Bitte melde dich an, bevor du etwas speicherst.');
    }

    final ingredientRows = await _client
        .from('recipe_ingredients')
        .select('food_id, amount_grams, position')
        .eq('recipe_id', recipe.id)
        .order('position');
    final ingredients = ingredientRows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    if (ingredients.isEmpty) {
      throw StateError('Dieses Rezept hat noch keine gespeicherten Zutaten.');
    }

    final foodIds = ingredients
        .map((ingredient) => ingredient['food_id'].toString())
        .toSet()
        .toList();
    final foodRows = await _client
        .from('foods')
        .select(
          'id, name, serving_grams, calories, protein, carbohydrates, fat',
        )
        .inFilter('id', foodIds);
    final foodsById = {
      for (final raw in foodRows.whereType<Map>())
        raw['id'].toString(): FoodItem.fromMap(Map<String, dynamic>.from(raw)),
    };
    final totals = _nutritionForItems(ingredients, foodsById);

    final meal = await _client
        .from('meals')
        .insert({
          'user_id': user.id,
          'meal_date': _dateOnly(date),
          'meal_type': slot.databaseValue,
          'note': '$_recipeNotePrefix${recipe.id}',
        })
        .select('id')
        .single();
    try {
      await _client.from('meal_items').insert([
        for (final ingredient in ingredients)
          {
            'meal_id': meal['id'],
            'food_id': ingredient['food_id'],
            'amount_grams': ingredient['amount_grams'],
          },
      ]);
      return MealEntry(
        id: 'recipe-${meal['id']}',
        remoteMealId: meal['id'].toString(),
        recipeId: recipe.id,
        name: recipe.title,
        slot: slot,
        calories: totals.calories.round(),
        protein: totals.protein.round(),
        carbs: totals.carbohydrates.round(),
        fat: totals.fat.round(),
        imageAsset: recipe.imageAsset,
      );
    } catch (_) {
      await _client.from('meals').delete().eq('id', meal['id']);
      rethrow;
    }
  }

  Future<void> deleteEntry(MealEntry entry) async {
    final mealId = entry.remoteMealId;
    if (mealId == null) return;
    await _client.from('meals').delete().eq('id', mealId);
  }

  MealEntry _entryFromFood({
    required String id,
    required String remoteMealId,
    required FoodItem food,
    required MealSlot slot,
    required double amountGrams,
  }) {
    final factor = amountGrams / food.servingGrams;
    return MealEntry(
      id: id,
      remoteMealId: remoteMealId,
      foodId: food.id,
      amountGrams: amountGrams,
      name: food.name,
      slot: slot,
      calories: (food.calories * factor).round(),
      protein: (food.protein * factor).round(),
      carbs: (food.carbohydrates * factor).round(),
      fat: (food.fat * factor).round(),
    );
  }

  _NutritionTotals _nutritionForItems(
    List<Map<String, dynamic>> items,
    Map<String, FoodItem> foodsById,
  ) {
    var calories = 0.0;
    var protein = 0.0;
    var carbohydrates = 0.0;
    var fat = 0.0;
    for (final item in items) {
      final food = foodsById[item['food_id'].toString()];
      if (food == null) continue;
      final grams =
          (item['amount_grams'] as num?)?.toDouble() ?? food.servingGrams;
      final factor = grams / food.servingGrams;
      calories += food.calories * factor;
      protein += food.protein * factor;
      carbohydrates += food.carbohydrates * factor;
      fat += food.fat * factor;
    }
    return _NutritionTotals(
      calories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fat: fat,
    );
  }

  String? _recipeIdFromNote(Object? value) {
    if (value is! String || !value.startsWith(_recipeNotePrefix)) return null;
    final recipeId = value.substring(_recipeNotePrefix.length);
    return recipeId.isEmpty ? null : recipeId;
  }

  _CustomMeal? _customMealFromNote(Object? value) {
    if (value is! String || !value.startsWith(_customNotePrefix)) return null;
    try {
      final decoded = jsonDecode(value.substring(_customNotePrefix.length));
      if (decoded is! Map) return null;
      final name = decoded['name'] as String?;
      if (name == null || name.trim().isEmpty) return null;
      final nutritionJson = decoded['nutrition'];
      final nutrition = nutritionJson is Map
          ? CustomFoodNutrition.fromJson(
              Map<String, dynamic>.from(nutritionJson),
            )
          : null;
      if (nutrition != null && nutrition.validate() != null) return null;
      return _CustomMeal(
        name: name.trim(),
        calories:
            nutrition?.totalCalories.round() ??
            _nonNegativeInt(decoded['calories']),
        protein:
            nutrition?.totalProtein.round() ??
            _nonNegativeInt(decoded['protein']),
        carbs:
            nutrition?.totalCarbohydrates.round() ??
            _nonNegativeInt(decoded['carbs']),
        fat: nutrition?.totalFat.round() ?? _nonNegativeInt(decoded['fat']),
        nutrition: nutrition,
      );
    } catch (_) {
      return null;
    }
  }

  String _noteForCustomMeal(_CustomMeal meal) =>
      '$_customNotePrefix${jsonEncode({'version': 2, 'name': meal.name, 'calories': meal.calories, 'protein': meal.protein, 'carbs': meal.carbs, 'fat': meal.fat, if (meal.nutrition != null) 'nutrition': meal.nutrition!.toJson()})}';

  int _nonNegativeInt(Object? value) => switch (value) {
    num number when number >= 0 => number.round(),
    _ => 0,
  };

  String _imageForRecipeSlug(String? slug) {
    final normalized = slug?.toLowerCase() ?? '';
    if (normalized.contains('salmon')) return 'assets/images/salmon_bowl.webp';
    if (normalized.contains('pasta')) return 'assets/images/protein_pasta.webp';
    return 'assets/images/berry_oats.webp';
  }

  String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  MealSlot _mealSlotFromDatabase(String? value) => switch (value) {
    'breakfast' => MealSlot.breakfast,
    'lunch' => MealSlot.lunch,
    'dinner' => MealSlot.dinner,
    _ => MealSlot.snack,
  };
}

class _NutritionTotals {
  const _NutritionTotals({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
  });

  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
}

class _CustomMeal {
  const _CustomMeal({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.nutrition,
  });

  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final CustomFoodNutrition? nutrition;
}
