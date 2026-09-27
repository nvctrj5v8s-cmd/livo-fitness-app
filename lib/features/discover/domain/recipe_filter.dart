import '../../../core/models/app_models.dart';

/// Meal-type tags as they appear in the catalog.
const recipeMealTypes = ['Frühstück', 'Mittagessen', 'Abendessen', 'Snack'];

/// Diet and goal tags offered as quick filters, in display order.
const recipeGoalTags = [
  'High Protein',
  'Schnell',
  'Vegetarisch',
  'Vegan',
  'Pescetarisch',
  'Low Carb',
  'Budget',
  'Meal Prep',
];

/// Upper time limits offered in the filter sheet, in minutes.
const recipeTimeLimits = [15, 30, 45];

/// Difficulty levels in ascending order.
const recipeDifficulties = ['Einfach', 'Mittel', 'Anspruchsvoll'];

/// The first catalog tag marks personalised sorting, not a real category.
const recipeForYouTag = 'Für dich';

enum RecipeSort {
  forYou('Für dich'),
  quickest('Wenig Zeit'),
  mostProtein('Meiste Protein'),
  fewestCalories('Wenigste kcal');

  const RecipeSort(this.label);
  final String label;
}

const _unset = Object();

/// Immutable description of what the recipe overview shows.
class RecipeFilter {
  const RecipeFilter({
    this.query = '',
    this.mealType,
    this.tags = const {},
    this.favoritesOnly = false,
    this.maxMinutes,
    this.difficulty,
    this.sort = RecipeSort.forYou,
  });

  final String query;
  final String? mealType;
  final Set<String> tags;
  final bool favoritesOnly;
  final int? maxMinutes;
  final String? difficulty;
  final RecipeSort sort;

  bool get isDefault =>
      query.trim().isEmpty &&
      mealType == null &&
      tags.isEmpty &&
      !favoritesOnly &&
      sheetCount == 0;

  /// Number of options set in the filter sheet (sort, time, difficulty).
  int get sheetCount =>
      (maxMinutes == null ? 0 : 1) +
      (difficulty == null ? 0 : 1) +
      (sort == RecipeSort.forYou ? 0 : 1);

  RecipeFilter copyWith({
    String? query,
    Object? mealType = _unset,
    Set<String>? tags,
    bool? favoritesOnly,
    Object? maxMinutes = _unset,
    Object? difficulty = _unset,
    RecipeSort? sort,
  }) => RecipeFilter(
    query: query ?? this.query,
    mealType: identical(mealType, _unset) ? this.mealType : mealType as String?,
    tags: tags ?? this.tags,
    favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    maxMinutes: identical(maxMinutes, _unset)
        ? this.maxMinutes
        : maxMinutes as int?,
    difficulty: identical(difficulty, _unset)
        ? this.difficulty
        : difficulty as String?,
    sort: sort ?? this.sort,
  );

  RecipeFilter toggleTag(String tag) {
    final next = {...tags};
    if (!next.remove(tag)) next.add(tag);
    return copyWith(tags: next);
  }

  RecipeFilter withoutSheetOptions() =>
      copyWith(maxMinutes: null, difficulty: null, sort: RecipeSort.forYou);
}

/// Lower-case text without umlaut differences, so "kase" finds "Käse".
String normalizeRecipeSearch(String value) => value
    .toLowerCase()
    .replaceAll('ä', 'a')
    .replaceAll('ö', 'o')
    .replaceAll('ü', 'u')
    .replaceAll('ß', 'ss')
    .trim();

/// Every word of [query] must appear in the title, description, tags or an
/// ingredient name.
bool recipeMatchesQuery(Recipe recipe, String query) {
  final tokens = normalizeRecipeSearch(
    query,
  ).split(RegExp(r'\s+')).where((token) => token.isNotEmpty).toList();
  if (tokens.isEmpty) return true;
  final haystack = normalizeRecipeSearch(
    [
      recipe.title,
      recipe.subtitle,
      ...recipe.tags.where((tag) => tag != recipeForYouTag),
      for (final ingredient in recipe.ingredients) ingredient.name,
    ].join(' '),
  );
  return tokens.every(haystack.contains);
}

/// Vegan recipes are vegetarian as well.
bool recipeHasTag(Recipe recipe, String tag) {
  if (tag == 'Vegetarisch') {
    return recipe.tags.contains('Vegetarisch') || recipe.tags.contains('Vegan');
  }
  return recipe.tags.contains(tag);
}

/// Only tags that at least one recipe carries, to avoid empty filters.
List<String> availableRecipeTags(
  Iterable<Recipe> recipes,
  List<String> candidates,
) => [
  for (final tag in candidates)
    if (recipes.any((recipe) => recipeHasTag(recipe, tag))) tag,
];

List<String> availableRecipeDifficulties(Iterable<Recipe> recipes) => [
  for (final level in recipeDifficulties)
    if (recipes.any((recipe) => recipe.difficulty == level)) level,
];

/// Filters and sorts [recipes]. The incoming order is the "Für dich" order
/// and stays the tie-breaker for every other sort.
List<Recipe> applyRecipeFilter(
  List<Recipe> recipes,
  RecipeFilter filter, {
  Set<String> favoriteIds = const {},
}) {
  final matches = <(int, Recipe)>[];
  for (final (index, recipe) in recipes.indexed) {
    final mealType = filter.mealType;
    if (mealType != null && !recipe.tags.contains(mealType)) continue;
    if (!filter.tags.every((tag) => recipeHasTag(recipe, tag))) continue;
    if (filter.favoritesOnly && !favoriteIds.contains(recipe.id)) continue;
    final maxMinutes = filter.maxMinutes;
    if (maxMinutes != null &&
        (recipe.minutes <= 0 || recipe.minutes > maxMinutes)) {
      continue;
    }
    final difficulty = filter.difficulty;
    if (difficulty != null && recipe.difficulty != difficulty) continue;
    if (!recipeMatchesQuery(recipe, filter.query)) continue;
    matches.add((index, recipe));
  }
  int minutesKey(Recipe recipe) =>
      recipe.minutes > 0 ? recipe.minutes : 1 << 20;
  matches.sort((a, b) {
    final primary = switch (filter.sort) {
      RecipeSort.forYou => 0,
      RecipeSort.quickest => minutesKey(a.$2).compareTo(minutesKey(b.$2)),
      RecipeSort.mostProtein => b.$2.nutrition.protein.compareTo(
        a.$2.nutrition.protein,
      ),
      RecipeSort.fewestCalories => a.$2.nutrition.calories.compareTo(
        b.$2.nutrition.calories,
      ),
    };
    return primary != 0 ? primary : a.$1.compareTo(b.$1);
  });
  return [for (final match in matches) match.$2];
}
