import '../../../core/models/app_models.dart';
import 'personalization_profile.dart';

/// Transparent sorting, never an allergy/suitability guarantee. Keep all
/// recipes accessible; use explicit catalog tags rather than guessing foods.
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

int _score(Recipe recipe, PersonalizationProfile profile) {
  final tags = recipe.tags.map((tag) => tag.toLowerCase()).toSet();
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
  final minutes =
      profile.cookingMinutes ??
      (profile.focus == RoutineFocus.time ? 15 : null);
  if (minutes != null && recipe.minutes > 0 && recipe.minutes <= minutes) {
    score += 20;
  }
  if (profile.focus == RoutineFocus.budget && tags.contains('budget')) {
    score += 10;
  }
  return score;
}
