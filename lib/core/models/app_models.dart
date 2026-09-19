import 'custom_food.dart';

enum MealSlot { breakfast, lunch, dinner, snack }

extension MealSlotLabel on MealSlot {
  String get label => switch (this) {
    MealSlot.breakfast => 'Frühstück',
    MealSlot.lunch => 'Mittagessen',
    MealSlot.dinner => 'Abendessen',
    MealSlot.snack => 'Snack',
  };

  String get databaseValue => switch (this) {
    MealSlot.breakfast => 'breakfast',
    MealSlot.lunch => 'lunch',
    MealSlot.dinner => 'dinner',
    MealSlot.snack => 'snack',
  };
}

class MealEntry {
  const MealEntry({
    required this.id,
    required this.name,
    required this.slot,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.imageAsset,
    this.foodId,
    this.recipeId,
    this.remoteMealId,
    this.amountGrams,
    this.customNutrition,
  });

  final String id;
  final String name;
  final MealSlot slot;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String? imageAsset;
  final String? foodId;
  final String? recipeId;
  final String? remoteMealId;
  final double? amountGrams;
  final CustomFoodNutrition? customNutrition;
  double get exactCalories =>
      customNutrition?.totalCalories ?? calories.toDouble();
  double get exactProtein =>
      customNutrition?.totalProtein ?? protein.toDouble();
  double get exactCarbs =>
      customNutrition?.totalCarbohydrates ?? carbs.toDouble();
  double get exactFat => customNutrition?.totalFat ?? fat.toDouble();

  bool get isRecipe => recipeId != null;
  bool get isCustom => foodId == null && recipeId == null;

  MealEntry copyWith({
    String? name,
    MealSlot? slot,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    double? amountGrams,
    CustomFoodNutrition? customNutrition,
  }) => MealEntry(
    id: id,
    name: name ?? this.name,
    slot: slot ?? this.slot,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    carbs: carbs ?? this.carbs,
    fat: fat ?? this.fat,
    imageAsset: imageAsset,
    foodId: foodId,
    recipeId: recipeId,
    remoteMealId: remoteMealId,
    amountGrams: amountGrams ?? this.amountGrams,
    customNutrition: customNutrition ?? this.customNutrition,
  );
}

class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.servingGrams,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    this.brand,
    this.source = 'curated',
    this.dietTags = const [],
    this.barcode,
    this.ingredientsText,
    this.allergens = const [],
    this.nutriScore,
    this.novaGroup,
    this.quantity,
    this.saturatedFat,
    this.fiber,
    this.sugar,
    this.salt,
    this.sourceUrl,
    this.sourceLicense,
    this.sourceAttribution,
  });

  final String id;
  final String name;
  final double servingGrams;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final String? brand;
  final String source;
  final List<String> dietTags;
  final String? barcode;
  final String? ingredientsText;
  final List<String> allergens;
  final String? nutriScore;
  final int? novaGroup;
  final String? quantity;
  final double? saturatedFat;
  final double? fiber;
  final double? sugar;
  final double? salt;
  final String? sourceUrl;
  final String? sourceLicense;
  final String? sourceAttribution;

  bool get hasBarcodeDetails =>
      barcode != null ||
      ingredientsText != null ||
      allergens.isNotEmpty ||
      nutriScore != null ||
      novaGroup != null;

  factory FoodItem.fromMap(Map<String, dynamic> map) => FoodItem(
    id: map['id'].toString(),
    name: map['name'] as String? ?? 'Lebensmittel',
    servingGrams: (map['serving_grams'] as num?)?.toDouble() ?? 100,
    calories: (map['calories'] as num?)?.toDouble() ?? 0,
    protein: (map['protein'] as num?)?.toDouble() ?? 0,
    carbohydrates: (map['carbohydrates'] as num?)?.toDouble() ?? 0,
    fat: (map['fat'] as num?)?.toDouble() ?? 0,
    brand: map['brand'] as String?,
    source: map['source'] as String? ?? 'curated',
    dietTags:
        (map['diet_tags'] as List?)?.whereType<String>().toList() ?? const [],
    barcode: map['barcode'] as String?,
    ingredientsText: map['ingredients_text'] as String?,
    allergens:
        (map['allergens'] as List?)?.whereType<String>().toList() ?? const [],
    nutriScore: map['nutriscore_grade'] as String?,
    novaGroup: (map['nova_group'] as num?)?.toInt(),
    quantity: map['product_quantity'] as String?,
    saturatedFat: (map['saturated_fat'] as num?)?.toDouble(),
    fiber: (map['fiber'] as num?)?.toDouble(),
    sugar: (map['sugar'] as num?)?.toDouble(),
    salt: (map['salt'] as num?)?.toDouble(),
    sourceUrl: map['source_url'] as String?,
    sourceLicense: map['source_license'] as String?,
    sourceAttribution: map['source_attribution'] as String?,
  );
}

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.calories,
    required this.protein,
    required this.imageAsset,
    required this.tags,
    this.ingredients = const [],
    this.instructions = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final int minutes;
  final int calories;
  final int protein;
  final String imageAsset;
  final List<String> tags;
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
}

class RecipeIngredient {
  const RecipeIngredient({
    required this.foodId,
    required this.name,
    required this.amountGrams,
  });

  final String foodId;
  final String name;
  final double amountGrams;

  String get amountLabel {
    final rounded = amountGrams.round();
    return '${rounded == amountGrams ? rounded : amountGrams.toStringAsFixed(1)} g';
  }
}

class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.name,
    required this.amount,
    this.done = false,
  });

  final String id;
  final String name;
  final String amount;
  final bool done;

  ShoppingItem copyWith({bool? done}) =>
      ShoppingItem(id: id, name: name, amount: amount, done: done ?? this.done);
}

class PantryItem {
  const PantryItem({
    required this.id,
    required this.name,
    required this.amount,
  });

  final String id;
  final String name;
  final String amount;
}
