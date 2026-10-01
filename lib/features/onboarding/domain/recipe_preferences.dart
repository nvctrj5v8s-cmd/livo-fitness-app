import '../../../core/models/app_models.dart';
import 'personalization_profile.dart';

/// Transparent sorting, never an allergy/suitability guarantee. Keep all
/// recipes accessible; use explicit catalog tags and the recipe's own
/// nutrition values rather than guessing foods.
List<Recipe> prioritizeRecipes(
  List<Recipe> recipes,
  PersonalizationProfile? profile,
) {
  if (profile == null) return List.of(recipes);
  final indexed = recipes.indexed.toList();
  indexed.sort((a, b) {
    final difference = _score(b.$2, profile) - _score(a.$2, profile);
    return difference != 0 ? difference : a.$1.compareTo(b.$1);
  });
  return indexed.map((item) => item.$2).toList();
}

/// What the recipe order is based on, in words for the plan summary. Empty
/// when the answers change nothing about the order – then the app must not
/// claim to sort for the person.
List<String> recipeSortingReasons(PersonalizationProfile? profile) {
  if (profile == null) return const [];
  return [
    if (_goalPreference(profile) != null) 'deinem Ziel',
    if (profile.nutrition != null &&
        profile.nutrition != NutritionPreference.mixed)
      'deiner Ernährungsweise',
    if (_maxMinutes(profile) != null) 'deiner Zeit zum Kochen',
    if (_prefersMealPrep(profile)) 'Vorkochen für deinen Alltag',
    if (profile.focus == RoutineFocus.budget) 'deinem Budget',
  ];
}

enum _GoalPreference { protein, lighter }

/// Losing weight: protein-rich and lighter dishes first. Building muscle:
/// protein-rich first. Other goals do not change the order.
_GoalPreference? _goalPreference(PersonalizationProfile profile) =>
    switch (profile.goal) {
      PersonalGoal.loseWeight => _GoalPreference.lighter,
      PersonalGoal.buildStrength => _GoalPreference.protein,
      _ => null,
    };

int? _maxMinutes(PersonalizationProfile profile) =>
    profile.cookingMinutes ??
    (profile.focus == RoutineFocus.time ||
            profile.obstacles.contains(Obstacle.time)
        ? 15
        : null);

bool _prefersMealPrep(PersonalizationProfile profile) =>
    profile.obstacles.contains(Obstacle.irregular) ||
    profile.obstacles.contains(Obstacle.eatingOut);

bool _isProteinRich(Recipe recipe, Set<String> tags) =>
    tags.contains('highprotein') ||
    (recipe.calories > 0 && recipe.protein * 4 / recipe.calories >= .25);

int _score(Recipe recipe, PersonalizationProfile profile) {
  final tags = {
    for (final tag in recipe.tags) tag.toLowerCase().replaceAll(' ', ''),
  };
  var score = 0;
  final styleMatch = switch (profile.nutrition) {
    NutritionPreference.vegan => tags.contains('vegan'),
    NutritionPreference.vegetarian =>
      tags.contains('vegetarisch') ||
          tags.contains('vegetarian') ||
          tags.contains('vegan'),
    NutritionPreference.pescatarian =>
      tags.contains('pescatarian') ||
          tags.contains('pescetarisch') ||
          tags.contains('vegetarisch') ||
          tags.contains('vegan'),
    _ => false,
  };
  if (styleMatch) score += 100;
  switch (_goalPreference(profile)) {
    case _GoalPreference.protein:
      if (_isProteinRich(recipe, tags)) score += 30;
    case _GoalPreference.lighter:
      if (_isProteinRich(recipe, tags)) score += 15;
      if (recipe.calories > 0 && recipe.calories <= 500) score += 15;
    case null:
      break;
  }
  final minutes = _maxMinutes(profile);
  if (minutes != null && recipe.minutes > 0 && recipe.minutes <= minutes) {
    score += 20;
  }
  if (_prefersMealPrep(profile) && tags.contains('mealprep')) score += 10;
  if (profile.focus == RoutineFocus.budget && tags.contains('budget')) {
    score += 10;
  }
  return score;
}

/// "a, b und c" for the reasons above.
String joinGerman(List<String> parts) => parts.length < 2
    ? parts.join()
    : '${parts.sublist(0, parts.length - 1).join(', ')} und ${parts.last}';
