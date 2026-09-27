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

  bool get isExternalBarcodeFallback => id.startsWith('external-barcode-');

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
    this.slug = '',
    this.nutritionPerServing,
    this.servings = 1,
    this.prepMinutes,
    this.cookMinutes,
    this.difficulty = 'Einfach',
    this.isPremium = false,
    this.equipment = const [],
    this.ingredients = const [],
    this.steps = const [],
    this.premiumDetails,
  });

  final String id;
  final String slug;
  final String title;
  final String subtitle;

  /// Total time in minutes, including cooking and resting.
  final int minutes;

  /// Rounded energy and protein for one serving.
  final int calories;
  final int protein;

  /// Full catalog nutrition for one serving, when ingredients are known.
  final RecipeNutrition? nutritionPerServing;
  final String imageAsset;
  final List<String> tags;

  /// Ingredient amounts are for all [servings] together.
  final int servings;
  final int? prepMinutes;
  final int? cookMinutes;
  final String difficulty;
  final bool isPremium;
  final List<String> equipment;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;

  /// Extra guidance for Premium members. `null` when the account may not read
  /// it (RLS returns no row) or the recipe has none.
  final RecipePremiumDetails? premiumDetails;

  RecipeNutrition get nutrition =>
      nutritionPerServing ??
      RecipeNutrition(
        calories: calories.toDouble(),
        protein: protein.toDouble(),
      );

  List<String> get instructions => [for (final step in steps) step.text];

  Recipe withPremiumDetails(RecipePremiumDetails? details) => Recipe(
    id: id,
    slug: slug,
    title: title,
    subtitle: subtitle,
    minutes: minutes,
    calories: calories,
    protein: protein,
    nutritionPerServing: nutritionPerServing,
    imageAsset: imageAsset,
    tags: tags,
    servings: servings,
    prepMinutes: prepMinutes,
    cookMinutes: cookMinutes,
    difficulty: difficulty,
    isPremium: isPremium,
    equipment: equipment,
    ingredients: ingredients,
    steps: steps,
    premiumDetails: details,
  );
}

/// Nutrition values as numbers; format them only in the UI.
class RecipeNutrition {
  const RecipeNutrition({
    required this.calories,
    required this.protein,
    this.carbohydrates = 0,
    this.fat = 0,
    this.fiber = 0,
    this.sugar = 0,
    this.salt = 0,
  });

  static const zero = RecipeNutrition(calories: 0, protein: 0);

  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
  final double sugar;
  final double salt;

  RecipeNutrition operator +(RecipeNutrition other) => RecipeNutrition(
    calories: calories + other.calories,
    protein: protein + other.protein,
    carbohydrates: carbohydrates + other.carbohydrates,
    fat: fat + other.fat,
    fiber: fiber + other.fiber,
    sugar: sugar + other.sugar,
    salt: salt + other.salt,
  );

  RecipeNutrition scaled(double factor) => RecipeNutrition(
    calories: calories * factor,
    protein: protein * factor,
    carbohydrates: carbohydrates * factor,
    fat: fat * factor,
    fiber: fiber * factor,
    sugar: sugar * factor,
    salt: salt * factor,
  );
}

class RecipeIngredient {
  const RecipeIngredient({
    required this.foodId,
    required this.name,
    required this.amountGrams,
    this.measure,
    this.note,
    this.nutrition,
  });

  final String foodId;
  final String name;

  /// Amount for the whole recipe (all servings).
  final double amountGrams;

  /// Household unit for the base recipe, for example "1 EL" or "2 Zehen".
  final String? measure;

  /// Preparation state, for example "gewürfelt".
  final String? note;

  /// Nutrition of [amountGrams], when the catalog food is known.
  final RecipeNutrition? nutrition;

  String get amountLabel => formatGrams(amountGrams);

  static String formatGrams(double grams) {
    final rounded = grams.round();
    if (rounded == grams || grams >= 20) return '$rounded g';
    return '${grams.toStringAsFixed(1).replaceAll('.', ',')} g';
  }
}

class RecipeStep {
  const RecipeStep({required this.text, this.title, this.minutes = 0});

  final String? title;
  final String text;

  /// Suggested timer for this step; 0 when the step needs no timer.
  final int minutes;
}

/// Premium-only depth. Loaded from `recipe_premium_details`, which RLS only
/// returns to accounts with an active Premium entitlement.
class RecipePremiumDetails {
  const RecipePremiumDetails({
    this.stepTips = const [],
    this.commonMistakes = const [],
    this.substitutions = const [],
    this.mealPrep = '',
    this.variations = const [],
    this.servingTip = '',
  });

  /// One tip per step, aligned with [Recipe.steps]; empty strings mean none.
  final List<String> stepTips;
  final List<String> commonMistakes;
  final List<String> substitutions;
  final String mealPrep;
  final List<String> variations;
  final String servingTip;

  String tipForStep(int index) =>
      index >= 0 && index < stepTips.length ? stepTips[index].trim() : '';

  bool get isEmpty =>
      stepTips.every((tip) => tip.trim().isEmpty) &&
      commonMistakes.isEmpty &&
      substitutions.isEmpty &&
      mealPrep.trim().isEmpty &&
      variations.isEmpty &&
      servingTip.trim().isEmpty;

  /// Every text, for content checks.
  Iterable<String> get allTexts => [
    ...stepTips,
    ...commonMistakes,
    ...substitutions,
    mealPrep,
    ...variations,
    servingTip,
  ];
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
