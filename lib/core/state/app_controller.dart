import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/onboarding/data/personalization_store.dart';
import '../../features/onboarding/domain/personalization_profile.dart';
import '../../features/onboarding/domain/recipe_preferences.dart';
import '../../features/profile/domain/daily_targets.dart';
import '../data/avatar_repository.dart';
import '../data/food_preferences_store.dart';
import '../data/halal_content_policy.dart';
import '../data/supabase_catalog_repository.dart';
import '../data/supabase_diary_repository.dart';
import '../data/supabase_favorites_repository.dart';
import '../data/supabase_profile_repository.dart';
import '../models/app_models.dart';
import '../models/custom_food.dart';
import '../models/tracking_streak.dart';

class AppController extends ChangeNotifier {
  AppController({
    this.personalizationUserId,
    this.personalizationStore = const DevicePersonalizationStore(),
    this.diaryRepository,
    this.avatarRepository,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now {
    if (personalizationUserId != null) meals.clear();
  }

  final String? personalizationUserId;
  final PersonalizationStore personalizationStore;
  final SupabaseDiaryRepository? diaryRepository;
  final AvatarRepository? avatarRepository;
  final DateTime Function() _now;
  SupabaseDiaryRepository get _diary =>
      diaryRepository ?? SupabaseDiaryRepository();
  AvatarRepository get _avatars =>
      avatarRepository ?? const LocalAvatarRepository();
  final Set<DateTime> _trackedDays = {};
  bool streakLoading = false;
  String? streakError;
  bool _hasTrackingDays = false;
  int _streakRevision = 0;
  Future<void>? _trackingLoad;
  int get streakDays => calculateTrackingStreak(_trackedDays, _now());
  Uint8List? avatarBytes;
  bool avatarSaving = false;
  String? avatarError;
  int _avatarRevision = 0;
  String? reminderError;

  Future<void> loadTrackingStreak() {
    if (_trackingLoad != null) return _trackingLoad!;
    return _trackingLoad = _readTrackingStreak().whenComplete(
      () => _trackingLoad = null,
    );
  }

  Future<void> _readTrackingStreak() async {
    if (personalizationUserId == null) return;
    final revision = _streakRevision;
    streakLoading = true;
    streakError = null;
    notifyListeners();
    try {
      final dates = await _diary
          .loadTrackingDays(_now())
          .timeout(const Duration(seconds: 12));
      if (_disposed || revision != _streakRevision) return;
      _trackedDays
        ..clear()
        ..addAll(dates.map(trackingDay));
      _hasTrackingDays = true;
    } catch (_) {
      if (!_disposed) streakError = 'Deine Serie konnte nicht geladen werden.';
    } finally {
      streakLoading = false;
      notifyListeners();
    }
  }

  Future<void> _prepareTracking() async {
    if (!_hasTrackingDays) await loadTrackingStreak();
  }

  Future<void> _recordSavedTrackingDay(DateTime date) async {
    if (_disposed || personalizationUserId == null) return;
    final day = trackingDay(date);
    if (day.isAfter(trackingDay(_now()))) return;
    if (!_hasTrackingDays) {
      await loadTrackingStreak();
      return; // No confirmed before-state: never invent a celebration.
    }
    ++_streakRevision;
    _trackedDays.add(day);
  }

  Future<void> _refreshTrackingAfterRemoval() async {
    if (personalizationUserId == null) return;
    try {
      final dates = await _diary
          .loadTrackingDays(_now())
          .timeout(const Duration(seconds: 12));
      if (_disposed) return;
      ++_streakRevision;
      _trackedDays
        ..clear()
        ..addAll(dates.map(trackingDay));
      _hasTrackingDays = true;
    } catch (_) {
      if (!_disposed) {
        streakError = 'Deine Serie konnte nicht aktualisiert werden.';
      }
    }
  }

  Future<void> loadReminderPreferences() async {
    if (personalizationUserId == null) return;
    try {
      final raw = await SharedPreferencesAsync().getString(
        'livo.reminders.$personalizationUserId',
      );
      if (_disposed || raw == null) return;
      final values = jsonDecode(raw) as Map;
      mealReminders = values['meals'] == true;
      waterReminders = values['water'] == true;
      weeklySummary = values['weekly'] == true;
      notifyListeners();
    } catch (_) {
      /* Keep defaults and allow the next edit to retry. */
    }
  }

  Future<void> _saveReminders() async {
    if (personalizationUserId == null) return;
    try {
      await SharedPreferencesAsync().setString(
        'livo.reminders.$personalizationUserId',
        jsonEncode({
          'meals': mealReminders,
          'water': waterReminders,
          'weekly': weeklySummary,
        }),
      );
      reminderError = null;
    } catch (_) {
      reminderError = 'Die Auswahl konnte nicht dauerhaft gespeichert werden.';
    }
    notifyListeners();
  }

  Future<bool> updateAvatar(Uint8List jpeg) async {
    final userId = personalizationUserId;
    if (avatarSaving || userId == null) return false;
    avatarSaving = true;
    avatarError = null;
    ++_avatarRevision;
    notifyListeners();
    try {
      await _avatars.save(userId, jpeg);
      if (_disposed) throw StateError('Konto geändert.');
      avatarBytes = jpeg;
      return true;
    } catch (_) {
      avatarError =
          'Dein Bild konnte nur auf diesem Gerät nicht gespeichert werden. Bitte versuche es erneut.';
      return false;
    } finally {
      avatarSaving = false;
      notifyListeners();
    }
  }

  Future<bool> removeAvatar() async {
    final userId = personalizationUserId;
    if (avatarSaving || userId == null) return false;
    avatarSaving = true;
    avatarError = null;
    ++_avatarRevision;
    notifyListeners();
    try {
      await _avatars.remove(userId);
      avatarBytes = null;
      return true;
    } catch (_) {
      avatarError =
          'Dein Bild konnte nicht entfernt werden. Bitte versuche es erneut.';
      return false;
    } finally {
      avatarSaving = false;
      notifyListeners();
    }
  }

  PersonalizationProfile? personalization;
  bool _disposed = false;
  int _personalizationRevision = 0;

  // Optional onboarding answers are a separate, device-local preference layer.
  // Loading the existing cloud profile must not overwrite this layer.
  String get greetingName => personalization?.displayName.isNotEmpty == true
      ? personalization!.displayName
      : name;
  List<Recipe> get personalizedRecipes =>
      prioritizeRecipes(recipes, personalization);

  DailyTargets get dailyTargets => DailyTargets.fromProfile(personalization);

  // Calculated targets win over stored defaults so diary and profile agree.
  void _syncGoalsWithTargets() {
    final targets = dailyTargets;
    if (!targets.isReady) return;
    calorieGoal = targets.calories!;
    proteinGoal = targets.protein!;
  }

  Future<PersonalizationRecord> loadPersonalization() async {
    final revision = ++_personalizationRevision;
    final userId = personalizationUserId;
    if (userId == null) return const PersonalizationRecord();
    final record = await personalizationStore
        .load(userId)
        .timeout(const Duration(seconds: 4));
    if (!_disposed && revision == _personalizationRevision) {
      personalization = record.profile;
      _syncGoalsWithTargets();
      notifyListeners();
    }
    return record;
  }

  Future<void> savePersonalization(PersonalizationProfile profile) async {
    final revision = ++_personalizationRevision;
    final userId = personalizationUserId;
    if (userId == null) throw StateError('Bitte zuerst anmelden.');
    await personalizationStore.save(userId, profile);
    if (_disposed || revision != _personalizationRevision) return;
    personalization = profile;
    _applyPersonalizationToProfile(profile);
    notifyListeners();
    try {
      await SupabaseProfileRepository().saveCurrentProfile(
        _personalizationProfileValues(profile),
        expectedUserId: personalizationUserId,
      );
    } catch (error) {
      profileError = error.toString();
      notifyListeners();
    }
  }

  void _applyPersonalizationToProfile(PersonalizationProfile profile) {
    if (profile.displayName.trim().isNotEmpty) {
      name = profile.displayName.trim();
    }
    goal = switch (profile.goal) {
      PersonalGoal.loseWeight => 'Fett verlieren',
      PersonalGoal.maintain => 'Gewicht halten',
      PersonalGoal.buildStrength => 'Muskeln aufbauen',
      PersonalGoal.balanced => 'Gesünder ernähren',
      null => goal,
    };
    nutritionStyle = switch (profile.nutrition) {
      NutritionPreference.vegetarian => 'Vegetarisch',
      NutritionPreference.vegan => 'Vegan',
      NutritionPreference.pescatarian => 'Pescetarisch',
      NutritionPreference.mixed => 'Ausgewogen',
      null => nutritionStyle,
    };
    activityLevel = switch (profile.activity) {
      ActivityPattern.mostlySeated => 'Wenig aktiv',
      ActivityPattern.mixed => 'Moderat aktiv',
      ActivityPattern.oftenMoving => 'Aktiv',
      ActivityPattern.veryActive => 'Sehr aktiv',
      null => activityLevel,
    };
    if (profile.allergies.trim().isNotEmpty) {
      allergies = profile.allergies.trim();
    }
    _syncGoalsWithTargets();
  }

  Map<String, dynamic> _personalizationProfileValues(
    PersonalizationProfile profile,
  ) {
    final values = <String, dynamic>{
      'goal': goal,
      'nutrition_style': nutritionStyle,
      'allergies': allergies,
      'activity_level': activityLevel,
    };
    if (profile.displayName.trim().isNotEmpty) {
      values['display_name'] = profile.displayName.trim();
    }
    return values;
  }

  Future<void> deferPersonalization() async {
    ++_personalizationRevision;
    final userId = personalizationUserId;
    if (userId != null) await personalizationStore.defer(userId);
  }

  Future<void> clearPersonalization() async {
    final revision = ++_personalizationRevision;
    final userId = personalizationUserId;
    if (userId != null) await personalizationStore.clear(userId);
    if (_disposed || revision != _personalizationRevision) return;
    personalization = null;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  final List<FoodItem> foods = [];
  bool catalogLoading = false;
  String? catalogError;
  bool profileLoading = false;
  String? profileError;
  bool diaryLoading = false;
  bool diarySaving = false;
  String? diaryError;
  bool favoritesLoading = false;
  String? favoritesError;
  bool foodPreferencesLoading = false;
  String? foodPreferencesError;

  String name = 'Alex';
  String goal = 'Fett verlieren';
  int calorieGoal = 2100;
  int proteinGoal = 140;
  int waterGlasses = 5;
  double currentWeight = 78.4;
  double targetWeight = 74;
  String nutritionStyle = 'Ausgewogen';
  String allergies = 'Keine angegeben';
  String activityLevel = 'Moderat aktiv';
  bool mealReminders = true;
  bool waterReminders = true;
  bool weeklySummary = false;

  final List<double> weightHistory = [81.2, 80.7, 80.2, 79.8, 79.4, 78.9, 78.4];

  /// Offline preview values are replaced with the signed-in user's real diary
  /// as soon as [loadRemoteDiary] completes.
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
  final List<MealEntry> diaryMeals = [];
  final Set<String> foodFavoriteIds = {};
  List<String> recentFoodIds = const [];
  DateTime diaryDate = DateTime.now();
  int _diaryRequestId = 0;
  bool _hasLoadedRemoteDiary = false;

  List<Recipe> recipes = [
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

  Future<void> loadRemoteCatalog() async {
    if (catalogLoading) return;
    catalogLoading = true;
    catalogError = null;
    notifyListeners();
    try {
      final catalog = await SupabaseCatalogRepository().loadCatalog();
      if (catalog.foods.isNotEmpty) {
        foods
          ..clear()
          ..addAll(catalog.foods);
      }
      if (catalog.recipes.isNotEmpty) {
        recipes = catalog.recipes;
      }
    } on PostgrestException catch (error) {
      catalogError = error.message;
    } catch (error) {
      catalogError = error.toString();
    } finally {
      catalogLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRemoteProfile() async {
    if (profileLoading) return;
    profileLoading = true;
    profileError = null;
    notifyListeners();
    final avatarRevision = _avatarRevision;
    try {
      final userId = personalizationUserId;
      if (userId != null) {
        try {
          final bytes = await _avatars.load(userId);
          if (!_disposed && avatarRevision == _avatarRevision) {
            avatarBytes = bytes;
          }
        } catch (_) {
          avatarError = 'Dein lokales Profilbild konnte nicht geladen werden.';
        }
      }
      final row = await SupabaseProfileRepository().loadCurrentProfile();
      if (row != null) {
        final remoteName = row['display_name'] as String?;
        if (remoteName != null && remoteName.trim().isNotEmpty) {
          name = remoteName.trim();
        }
        final remoteGoal = row['goal'] as String?;
        if (remoteGoal != null && remoteGoal.trim().isNotEmpty) {
          goal = remoteGoal;
        }
        final remoteCalories = (row['calorie_goal'] as num?)?.toInt();
        if (remoteCalories != null && remoteCalories > 0) {
          calorieGoal = remoteCalories;
        }
        final remoteTargetWeight = (row['target_weight'] as num?)?.toDouble();
        if (remoteTargetWeight != null && remoteTargetWeight > 0) {
          targetWeight = remoteTargetWeight;
        }
        final remoteProtein = (row['protein_goal'] as num?)?.toInt();
        if (remoteProtein != null && remoteProtein > 0) {
          proteinGoal = remoteProtein;
        }
        final remoteStyle = row['nutrition_style'] as String?;
        if (remoteStyle != null && remoteStyle.trim().isNotEmpty) {
          nutritionStyle = remoteStyle;
        }
        final remoteAllergies = row['allergies'] as String?;
        if (remoteAllergies != null && remoteAllergies.trim().isNotEmpty) {
          allergies = remoteAllergies;
        }
        final remoteActivity = row['activity_level'] as String?;
        if (remoteActivity != null && remoteActivity.trim().isNotEmpty) {
          activityLevel = remoteActivity;
        }
      }
    } on PostgrestException catch (error) {
      profileError = error.message;
    } catch (error) {
      profileError = error.toString();
    } finally {
      _syncGoalsWithTargets();
      profileLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRemoteDiary([DateTime? date]) async {
    final targetDate = _dateOnly(date ?? DateTime.now());
    final requestId = ++_diaryRequestId;
    diaryDate = targetDate;
    diaryMeals.clear();
    if (_isToday(targetDate)) meals.clear();
    diaryLoading = true;
    diaryError = null;
    notifyListeners();
    try {
      final remoteMeals = await _diary.loadMealsForDate(targetDate);
      if (requestId != _diaryRequestId) return;
      final allowedMeals = remoteMeals
          .where((meal) => HalalContentPolicy.isAllowedText(meal.name))
          .toList();
      diaryDate = targetDate;
      diaryMeals
        ..clear()
        ..addAll(allowedMeals);
      if (_isToday(targetDate)) {
        meals
          ..clear()
          ..addAll(allowedMeals);
      }
      _hasLoadedRemoteDiary = true;
    } on PostgrestException catch (error) {
      if (requestId != _diaryRequestId) return;
      diaryError = error.message;
      _restoreOfflineDiaryPreview(targetDate);
    } catch (error) {
      if (requestId != _diaryRequestId) return;
      diaryError = error.toString();
      _restoreOfflineDiaryPreview(targetDate);
    } finally {
      if (requestId == _diaryRequestId) {
        diaryLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadRemoteFavorites() async {
    if (favoritesLoading) return;
    favoritesLoading = true;
    favoritesError = null;
    notifyListeners();
    try {
      final remoteIds = await SupabaseFavoritesRepository()
          .loadCurrentUserFavorites();
      favoriteRecipeIds
        ..clear()
        ..addAll(remoteIds);
    } on PostgrestException catch (error) {
      favoritesError = error.message;
    } catch (error) {
      favoritesError = error.toString();
    } finally {
      favoritesLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFoodPreferences() async {
    if (foodPreferencesLoading) return;
    foodPreferencesLoading = true;
    foodPreferencesError = null;
    notifyListeners();
    try {
      final values = await FoodPreferencesStore().load();
      foodFavoriteIds
        ..clear()
        ..addAll(values.favoriteIds);
      recentFoodIds = values.recentIds;
    } catch (error) {
      foodPreferencesError = error.toString();
    } finally {
      foodPreferencesLoading = false;
      notifyListeners();
    }
  }

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
  int get diaryConsumedCalories =>
      diaryMeals.fold(0, (sum, meal) => sum + meal.calories);
  int get diaryConsumedProtein =>
      diaryMeals.fold(0, (sum, meal) => sum + meal.protein);
  int get diaryConsumedCarbs =>
      diaryMeals.fold(0, (sum, meal) => sum + meal.carbs);
  int get diaryConsumedFat => diaryMeals.fold(0, (sum, meal) => sum + meal.fat);
  int get diaryRemainingCalories => calorieGoal - diaryConsumedCalories;
  double get diaryCalorieProgress =>
      (diaryConsumedCalories / calorieGoal).clamp(0, 1);
  int get diaryCarbohydrateGoal => (calorieGoal * 0.5 / 4).round();
  int get diaryFatGoal => (calorieGoal * 0.3 / 9).round();
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
    if (!HalalContentPolicy.isAllowedText(meal.name)) {
      diaryError =
          'Dieser Eintrag entspricht nicht den Halal-Inhaltsregeln von LIVO.';
      notifyListeners();
      return;
    }
    meals.add(meal);
    if (_isToday(diaryDate)) diaryMeals.add(meal);
    notifyListeners();
  }

  Future<bool> removeMeal(String id) async {
    MealEntry? entry;
    for (final candidate in diaryMeals) {
      if (candidate.id == id) {
        entry = candidate;
        break;
      }
    }
    if (entry == null) return false;
    if (entry.remoteMealId == null) {
      diaryMeals.remove(entry);
      if (_isToday(diaryDate)) meals.remove(entry);
      notifyListeners();
      return true;
    }
    diarySaving = true;
    diaryError = null;
    notifyListeners();
    try {
      await _diary.deleteEntry(entry);
      diaryMeals.remove(entry);
      if (_isToday(diaryDate)) meals.remove(entry);
      await _refreshTrackingAfterRemoval();
      return true;
    } on PostgrestException catch (error) {
      diaryError = error.message;
      return false;
    } catch (error) {
      diaryError = error.toString();
      return false;
    } finally {
      diarySaving = false;
      notifyListeners();
    }
  }

  Future<bool> addFoodToDiary({
    required FoodItem food,
    required MealSlot slot,
    required double amountGrams,
    required DateTime date,
  }) async {
    if (!HalalContentPolicy.isAllowedFood(food)) {
      diaryError =
          'Dieses Lebensmittel entspricht nicht den Halal-Inhaltsregeln von LIVO.';
      notifyListeners();
      return false;
    }
    if (diarySaving) return false;
    await _prepareTracking();
    diarySaving = true;
    diaryError = null;
    notifyListeners();
    try {
      final entry = food.isExternalBarcodeFallback
          ? await _diary.addCustomMeal(
              name: food.name,
              slot: slot,
              calories: (food.calories * amountGrams / 100).round(),
              protein: (food.protein * amountGrams / 100).round(),
              carbs: (food.carbohydrates * amountGrams / 100).round(),
              fat: (food.fat * amountGrams / 100).round(),
              nutrition: CustomFoodNutrition(
                basis: NutritionBasis.per100g,
                amount: amountGrams,
                calories: food.calories,
                protein: food.protein,
                carbohydrates: food.carbohydrates,
                fat: food.fat,
                sugar: food.sugar,
                saturatedFat: food.saturatedFat,
                salt: food.salt,
                fiber: food.fiber,
              ),
              date: date,
            )
          : await _diary.addFood(
              food: food,
              slot: slot,
              amountGrams: amountGrams,
              date: date,
            );
      if (_sameDay(date, diaryDate)) diaryMeals.add(entry);
      if (_isToday(date)) meals.add(entry);
      recordFoodUse(food.id);
      await _recordSavedTrackingDay(date);
      return true;
    } on PostgrestException catch (error) {
      diaryError = error.message;
      return false;
    } catch (error) {
      diaryError = error.toString();
      return false;
    } finally {
      diarySaving = false;
      notifyListeners();
    }
  }

  Future<bool> addCustomMealToDiary({
    required String name,
    required MealSlot slot,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    required DateTime date,
  }) async {
    final contentError = HalalContentPolicy.restrictionReason(name);
    if (contentError != null) {
      diaryError = contentError;
      notifyListeners();
      return false;
    }
    if (diarySaving) return false;
    await _prepareTracking();
    diarySaving = true;
    diaryError = null;
    notifyListeners();
    try {
      final entry = await _diary.addCustomMeal(
        name: name,
        slot: slot,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        date: date,
      );
      if (_sameDay(date, diaryDate)) diaryMeals.add(entry);
      if (_isToday(date)) meals.add(entry);
      await _recordSavedTrackingDay(date);
      return true;
    } on PostgrestException catch (error) {
      diaryError = error.message;
      return false;
    } catch (error) {
      diaryError = error.toString();
      return false;
    } finally {
      diarySaving = false;
      notifyListeners();
    }
  }

  Future<bool> addCustomFoodToDiary({
    required String name,
    required MealSlot slot,
    required CustomFoodNutrition nutrition,
    required DateTime date,
    bool requireLabelValues = true,
  }) async {
    final validationError = nutrition.validate(
      requireLabelValues: requireLabelValues,
    );
    final contentError = HalalContentPolicy.restrictionReason(name);
    if (name.trim().isEmpty ||
        validationError != null ||
        contentError != null) {
      diaryError =
          validationError ??
          contentError ??
          'Bitte gib deinem Lebensmittel einen Namen.';
      notifyListeners();
      return false;
    }
    if (diarySaving) return false;
    await _prepareTracking();
    diarySaving = true;
    diaryError = null;
    notifyListeners();
    try {
      final entry = await _diary.addCustomMeal(
        name: name.trim(),
        slot: slot,
        calories: nutrition.totalCalories.round(),
        protein: nutrition.totalProtein.round(),
        carbs: nutrition.totalCarbohydrates.round(),
        fat: nutrition.totalFat.round(),
        nutrition: nutrition,
        date: date,
      );
      if (_sameDay(date, diaryDate)) diaryMeals.add(entry);
      if (_isToday(date)) meals.add(entry);
      await _recordSavedTrackingDay(date);
      return true;
    } on PostgrestException catch (error) {
      diaryError = error.message;
      return false;
    } catch (error) {
      diaryError = error.toString();
      return false;
    } finally {
      diarySaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateDiaryEntry(
    MealEntry entry, {
    required MealSlot slot,
    double? amountGrams,
    String? name,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    CustomFoodNutrition? customNutrition,
    DateTime? date,
  }) async {
    final targetDate = date ?? diaryDate;
    final contentError = name == null
        ? null
        : HalalContentPolicy.restrictionReason(name);
    if (contentError != null) {
      diaryError = contentError;
      notifyListeners();
      return false;
    }
    if (diarySaving) return false;
    final isLocalPreview = entry.remoteMealId == null;
    if (isLocalPreview) {
      final updated = entry.copyWith(
        name: name,
        slot: slot,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        amountGrams: amountGrams,
        customNutrition: customNutrition,
      );
      _replaceDiaryEntry(entry, updated, targetDate: targetDate);
      notifyListeners();
      return true;
    }

    diarySaving = true;
    diaryError = null;
    notifyListeners();
    try {
      final MealEntry updated;
      if (entry.foodId != null) {
        final food = _foodForId(entry.foodId!);
        if (food == null || amountGrams == null) {
          throw StateError(
            'Das Lebensmittel konnte nicht mehr gefunden werden.',
          );
        }
        updated = await _diary.updateFoodEntry(
          entry: entry,
          food: food,
          slot: slot,
          amountGrams: amountGrams,
          date: targetDate,
        );
      } else if (entry.recipeId != null) {
        updated = await _diary.updateMealSlot(
          entry: entry,
          slot: slot,
          date: targetDate,
        );
      } else {
        final nutrition = customNutrition ?? entry.customNutrition;
        updated = await _diary.updateCustomMeal(
          entry: entry,
          name: name?.trim().isEmpty ?? true ? entry.name : name!.trim(),
          slot: slot,
          calories:
              nutrition?.totalCalories.round() ?? calories ?? entry.calories,
          protein: nutrition?.totalProtein.round() ?? protein ?? entry.protein,
          carbs: nutrition?.totalCarbohydrates.round() ?? carbs ?? entry.carbs,
          fat: nutrition?.totalFat.round() ?? fat ?? entry.fat,
          nutrition: nutrition,
          date: targetDate,
        );
      }
      _replaceDiaryEntry(entry, updated, targetDate: targetDate);
      await _refreshTrackingAfterRemoval();
      return true;
    } on PostgrestException catch (error) {
      diaryError = error.message;
      return false;
    } catch (error) {
      diaryError = error.toString();
      return false;
    } finally {
      diarySaving = false;
      notifyListeners();
    }
  }

  Future<bool> duplicateDiaryEntry(MealEntry entry, {DateTime? date}) async {
    if (!HalalContentPolicy.isAllowedText(entry.name)) {
      diaryError =
          'Dieser Eintrag entspricht nicht den Halal-Inhaltsregeln von LIVO.';
      notifyListeners();
      return false;
    }
    final targetDate = date ?? diaryDate;
    if (entry.remoteMealId == null) {
      final duplicate = entry.copyWith();
      final localCopy = MealEntry(
        id: '${entry.id}-${DateTime.now().microsecondsSinceEpoch}',
        name: duplicate.name,
        slot: duplicate.slot,
        calories: duplicate.calories,
        protein: duplicate.protein,
        carbs: duplicate.carbs,
        fat: duplicate.fat,
        imageAsset: duplicate.imageAsset,
        foodId: duplicate.foodId,
        recipeId: duplicate.recipeId,
        amountGrams: duplicate.amountGrams,
        customNutrition: duplicate.customNutrition,
      );
      diaryMeals.add(localCopy);
      if (_isToday(targetDate)) meals.add(localCopy);
      notifyListeners();
      return true;
    }
    if (entry.foodId != null) {
      final food = _foodForId(entry.foodId!);
      if (food == null) {
        diaryError = 'Das Lebensmittel konnte nicht mehr gefunden werden.';
        notifyListeners();
        return false;
      }
      return addFoodToDiary(
        food: food,
        slot: entry.slot,
        amountGrams: entry.amountGrams ?? food.servingGrams,
        date: targetDate,
      );
    }
    if (entry.recipeId != null) {
      final recipe = _recipeForId(entry.recipeId!);
      if (recipe == null) {
        diaryError = 'Das Rezept konnte nicht mehr gefunden werden.';
        notifyListeners();
        return false;
      }
      return addRecipeToDiary(recipe, date: targetDate, slot: entry.slot);
    }
    if (entry.customNutrition case final nutrition?) {
      return addCustomFoodToDiary(
        name: entry.name,
        slot: entry.slot,
        nutrition: nutrition,
        date: targetDate,
      );
    }
    return addCustomMealToDiary(
      name: entry.name,
      slot: entry.slot,
      calories: entry.calories,
      protein: entry.protein,
      carbs: entry.carbs,
      fat: entry.fat,
      date: targetDate,
    );
  }

  Future<void> toggleFavorite(String id) async {
    final wasFavorite = favoriteRecipeIds.contains(id);
    if (wasFavorite) {
      favoriteRecipeIds.remove(id);
    } else {
      favoriteRecipeIds.add(id);
    }
    notifyListeners();
    if (!_isUuid(id)) return;
    try {
      await SupabaseFavoritesRepository().setFavorite(
        recipeId: id,
        favorite: !wasFavorite,
      );
    } catch (error) {
      if (wasFavorite) {
        favoriteRecipeIds.add(id);
      } else {
        favoriteRecipeIds.remove(id);
      }
      favoritesError = error.toString();
      notifyListeners();
    }
  }

  void toggleFoodFavorite(String id) {
    if (!foodFavoriteIds.add(id)) foodFavoriteIds.remove(id);
    notifyListeners();
    unawaited(FoodPreferencesStore().saveFavoriteIds(foodFavoriteIds));
  }

  void recordFoodUse(String id) {
    recentFoodIds = [
      id,
      ...recentFoodIds.where((item) => item != id),
    ].take(18).toList();
    notifyListeners();
    unawaited(FoodPreferencesStore().saveRecentIds(recentFoodIds));
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

  Future<bool> addRecipeToDiary(
    Recipe recipe, {
    DateTime? date,
    MealSlot slot = MealSlot.dinner,
  }) async {
    if (!HalalContentPolicy.isAllowedRecipe(recipe)) {
      diaryError =
          'Dieses Rezept entspricht nicht den Halal-Inhaltsregeln von LIVO.';
      notifyListeners();
      return false;
    }
    final targetDate = date ?? _now();

    // Bundled preview recipes use illustrative IDs. They remain available in
    // offline/widget previews; Supabase recipes always have a UUID below.
    if (!_isUuid(recipe.id)) {
      addMeal(
        MealEntry(
          id: 'recipe-${recipe.id}-${DateTime.now().microsecondsSinceEpoch}',
          recipeId: recipe.id,
          name: recipe.title,
          slot: slot,
          calories: recipe.calories,
          protein: recipe.protein,
          carbs: ((recipe.calories - recipe.protein * 4) * 0.55 / 4).round(),
          fat: ((recipe.calories - recipe.protein * 4) * 0.45 / 9).round(),
          imageAsset: recipe.imageAsset,
        ),
      );
      return true;
    }
    if (diarySaving) return false;
    await _prepareTracking();
    diarySaving = true;
    diaryError = null;
    notifyListeners();
    try {
      final entry = await _diary.addRecipe(
        recipe: recipe,
        slot: slot,
        date: targetDate,
      );
      if (_sameDay(targetDate, diaryDate)) diaryMeals.add(entry);
      if (_isToday(targetDate)) meals.add(entry);
      await _recordSavedTrackingDay(targetDate);
      return true;
    } on PostgrestException catch (error) {
      diaryError = error.message;
      return false;
    } catch (error) {
      diaryError = error.toString();
      return false;
    } finally {
      diarySaving = false;
      notifyListeners();
    }
  }

  bool _isUuid(String value) => RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  ).hasMatch(value);

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
    unawaited(
      _saveProfileSilently({
        'nutrition_style': nutritionStyle,
        'allergies': allergies,
        'activity_level': activityLevel,
      }),
    );
  }

  void setMealReminders(bool enabled) {
    mealReminders = enabled;
    notifyListeners();
    unawaited(_saveReminders());
  }

  void setWaterReminders(bool enabled) {
    waterReminders = enabled;
    notifyListeners();
    unawaited(_saveReminders());
  }

  void setWeeklySummary(bool enabled) {
    weeklySummary = enabled;
    notifyListeners();
    unawaited(_saveReminders());
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
    unawaited(
      _saveProfileSilently({
        'display_name': name,
        'goal': goal,
        'calorie_goal': calorieGoal,
        'target_weight': targetWeight,
        'protein_goal': proteinGoal,
      }),
    );
  }

  Future<void> _saveProfileSilently(Map<String, dynamic> values) async {
    try {
      await SupabaseProfileRepository().saveCurrentProfile(
        values,
        expectedUserId: personalizationUserId,
      );
    } catch (error) {
      profileError = error.toString();
      notifyListeners();
    }
  }

  FoodItem? _foodForId(String id) {
    for (final food in foods) {
      if (food.id == id) return food;
    }
    return null;
  }

  Recipe? _recipeForId(String id) {
    for (final recipe in recipes) {
      if (recipe.id == id) return recipe;
    }
    return null;
  }

  void _replaceDiaryEntry(
    MealEntry previous,
    MealEntry updated, {
    required DateTime targetDate,
  }) {
    final diaryIndex = diaryMeals.indexWhere((meal) => meal.id == previous.id);
    if (_sameDay(targetDate, diaryDate)) {
      if (diaryIndex >= 0) diaryMeals[diaryIndex] = updated;
    } else if (diaryIndex >= 0) {
      diaryMeals.removeAt(diaryIndex);
    }

    final homeIndex = meals.indexWhere((meal) => meal.id == previous.id);
    final fromToday = _isToday(diaryDate);
    final toToday = _isToday(targetDate);
    if (fromToday && toToday && homeIndex >= 0) {
      meals[homeIndex] = updated;
    } else if (fromToday && homeIndex >= 0) {
      meals.removeAt(homeIndex);
    } else if (toToday) {
      meals.add(updated);
    }
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  bool _isToday(DateTime value) => _sameDay(value, _now());

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  void _restoreOfflineDiaryPreview(DateTime date) {
    if (personalizationUserId != null) return;
    if (_hasLoadedRemoteDiary || !_isToday(date)) return;
    diaryMeals
      ..clear()
      ..addAll(meals);
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
