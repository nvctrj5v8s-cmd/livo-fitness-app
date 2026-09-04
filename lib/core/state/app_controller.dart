import 'package:flutter/widgets.dart';

import '../models/app_models.dart';

class AppController extends ChangeNotifier {
  String name = 'Alex';
  String goal = 'Fett verlieren';
  int calorieGoal = 2100;
  int proteinGoal = 140;
  int waterGlasses = 5;
  double currentWeight = 78.4;
  double targetWeight = 74;
  int streakDays = 8;
  String nutritionStyle = 'Ausgewogen';
  String allergies = 'Keine angegeben';
  String activityLevel = 'Moderat aktiv';
  bool mealReminders = true;
  bool waterReminders = true;
  bool weeklySummary = false;

  final List<double> weightHistory = [81.2, 80.7, 80.2, 79.8, 79.4, 78.9, 78.4];

  final List<MealEntry> meals = [
    const MealEntry(
      id: 'breakfast-oats',
      name: 'Protein-Beeren-Oats',
      slot: MealSlot.breakfast,
      calories: 430,
      protein: 31,
      carbs: 52,
      fat: 11,
      imageAsset: 'assets/images/berry_oats.webp',
    ),
    const MealEntry(
      id: 'lunch-salmon',
      name: 'Lachs Power Bowl',
      slot: MealSlot.lunch,
      calories: 620,
      protein: 44,
      carbs: 58,
      fat: 22,
      imageAsset: 'assets/images/salmon_bowl.webp',
    ),
    const MealEntry(
      id: 'snack-yogurt',
      name: 'Skyr mit Mandeln',
      slot: MealSlot.snack,
      calories: 210,
      protein: 22,
      carbs: 16,
      fat: 7,
    ),
  ];

  final List<Recipe> recipes = const [
    Recipe(
      id: 'salmon-bowl',
      title: 'Lachs Power Bowl',
      subtitle: 'Sättigend, frisch und proteinreich',
      minutes: 24,
      calories: 620,
      protein: 44,
      imageAsset: 'assets/images/salmon_bowl.webp',
      tags: ['Für dich', 'High Protein'],
    ),
    Recipe(
      id: 'protein-pasta',
      title: 'Cremige Protein-Pasta',
      subtitle: 'Schnelles Feierabendgericht',
      minutes: 20,
      calories: 570,
      protein: 38,
      imageAsset: 'assets/images/protein_pasta.webp',
      tags: ['Für dich', 'Schnell', 'Vegetarisch'],
    ),
    Recipe(
      id: 'berry-oats',
      title: 'Protein-Beeren-Oats',
      subtitle: 'Frühstück in acht Minuten',
      minutes: 8,
      calories: 430,
      protein: 31,
      imageAsset: 'assets/images/berry_oats.webp',
      tags: ['Für dich', 'High Protein', 'Schnell', 'Budget'],
    ),
  ];

  final Set<String> favoriteRecipeIds = {'berry-oats'};

  List<ShoppingItem> shoppingItems = const [
    ShoppingItem(id: '1', name: 'Skyr', amount: '500 g'),
    ShoppingItem(id: '2', name: 'Beeren', amount: '300 g'),
    ShoppingItem(id: '3', name: 'Lachsfilet', amount: '2 Stück'),
    ShoppingItem(id: '4', name: 'Avocado', amount: '2 Stück'),
    ShoppingItem(id: '5', name: 'Vollkornpasta', amount: '1 Packung'),
  ];

  List<PantryItem> pantryItems = const [
    PantryItem(id: 'oats', name: 'Haferflocken', amount: '450 g'),
    PantryItem(id: 'skyr', name: 'Skyr', amount: '500 g'),
    PantryItem(id: 'pasta', name: 'Vollkornpasta', amount: '1 Packung'),
    PantryItem(id: 'tomatoes', name: 'Tomaten', amount: '5 Stück'),
  ];

  List<String?> plannedRecipeIds = const [
    'berry-oats',
    'protein-pasta',
    null,
    'salmon-bowl',
    null,
    null,
    null,
  ];

  int get consumedCalories => meals.fold(0, (sum, meal) => sum + meal.calories);
  int get consumedProtein => meals.fold(0, (sum, meal) => sum + meal.protein);
  int get consumedCarbs => meals.fold(0, (sum, meal) => sum + meal.carbs);
  int get consumedFat => meals.fold(0, (sum, meal) => sum + meal.fat);
  int get remainingCalories => calorieGoal - consumedCalories;
  double get calorieProgress => (consumedCalories / calorieGoal).clamp(0, 1);
  double get goalProgress {
    const startWeight = 81.2;
    final total = startWeight - targetWeight;
    if (total <= 0) return 0;
    return ((startWeight - currentWeight) / total).clamp(0, 1);
  }

  void addWater() {
    if (waterGlasses >= 8) return;
    waterGlasses++;
    notifyListeners();
  }

  void removeWater() {
    if (waterGlasses <= 0) return;
    waterGlasses--;
    notifyListeners();
  }

  void addMeal(MealEntry meal) {
    meals.add(meal);
    notifyListeners();
  }

  void removeMeal(String id) {
    meals.removeWhere((meal) => meal.id == id);
    notifyListeners();
  }

  void toggleFavorite(String id) {
    if (!favoriteRecipeIds.add(id)) favoriteRecipeIds.remove(id);
    notifyListeners();
  }

  void toggleShoppingItem(String id) {
    shoppingItems = shoppingItems
        .map((item) => item.id == id ? item.copyWith(done: !item.done) : item)
        .toList();
    notifyListeners();
  }

  void addShoppingItem(String name, {String amount = '1 Stück'}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    shoppingItems = [
      ...shoppingItems,
      ShoppingItem(
        id: 'shopping-${DateTime.now().microsecondsSinceEpoch}',
        name: trimmed,
        amount: amount,
      ),
    ];
    notifyListeners();
  }

  void removeShoppingItem(String id) {
    shoppingItems = shoppingItems.where((item) => item.id != id).toList();
    notifyListeners();
  }

  void addPantryItem(String name, {String amount = 'Vorrätig'}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    pantryItems = [
      ...pantryItems,
      PantryItem(
        id: 'pantry-${DateTime.now().microsecondsSinceEpoch}',
        name: trimmed,
        amount: amount,
      ),
    ];
    notifyListeners();
  }

  void removePantryItem(String id) {
    pantryItems = pantryItems.where((item) => item.id != id).toList();
    notifyListeners();
  }

  void planRecipe(int dayIndex, String? recipeId) {
    if (dayIndex < 0 || dayIndex >= plannedRecipeIds.length) return;
    plannedRecipeIds = [...plannedRecipeIds]..[dayIndex] = recipeId;
    notifyListeners();
  }

  void addRecipeToDiary(Recipe recipe) {
    addMeal(
      MealEntry(
        id: 'recipe-${recipe.id}-${DateTime.now().microsecondsSinceEpoch}',
        name: recipe.title,
        slot: MealSlot.dinner,
        calories: recipe.calories,
        protein: recipe.protein,
        carbs: ((recipe.calories - recipe.protein * 4) * 0.55 / 4).round(),
        fat: ((recipe.calories - recipe.protein * 4) * 0.45 / 9).round(),
        imageAsset: recipe.imageAsset,
      ),
    );
  }

  void updateNutritionProfile({
    required String newNutritionStyle,
    required String newAllergies,
    required String newActivityLevel,
  }) {
    nutritionStyle = newNutritionStyle;
    allergies = newAllergies.trim().isEmpty
        ? 'Keine angegeben'
        : newAllergies.trim();
    activityLevel = newActivityLevel;
    notifyListeners();
  }

  void setMealReminders(bool enabled) {
    mealReminders = enabled;
    notifyListeners();
  }

  void setWaterReminders(bool enabled) {
    waterReminders = enabled;
    notifyListeners();
  }

  void setWeeklySummary(bool enabled) {
    weeklySummary = enabled;
    notifyListeners();
  }

  void clearLocalDemoData() {
    meals.clear();
    waterGlasses = 0;
    favoriteRecipeIds.clear();
    shoppingItems = [];
    pantryItems = [];
    plannedRecipeIds = List<String?>.filled(7, null);
    notifyListeners();
  }

  void updateProfile({
    required String newName,
    required String newGoal,
    required int newCalorieGoal,
    required double newTargetWeight,
  }) {
    name = newName.trim().isEmpty ? name : newName.trim();
    goal = newGoal;
    calorieGoal = newCalorieGoal;
    targetWeight = newTargetWeight;
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    required AppController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing above this context.');
    return scope!.notifier!;
  }
}
