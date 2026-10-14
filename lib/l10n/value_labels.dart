// l10n-ignore-file: the German strings here are stored values, not UI texts.
import 'l10n.dart';

/// Display names for values that are stored or compared in German (recipe
/// tags and difficulty in the database, profile goal/nutrition/activity in
/// `public.profiles`). The stored value never changes; only what people see
/// follows the app language. Unknown values are shown as they are.
abstract final class ValueLabels {
  static String recipeTag(AppLocalizations l10n, String tag) => switch (tag) {
    'Abendessen' => l10n.valuesTagDinner,
    'Budget' => l10n.valuesTagBudget,
    'Frühstück' => l10n.valuesTagBreakfast,
    'High Protein' => l10n.valuesTagHighProtein,
    'Meal Prep' => l10n.valuesTagMealPrep,
    'Mittagessen' => l10n.valuesTagLunch,
    'Pescetarisch' => l10n.valuesTagPescatarian,
    'Schnell' => l10n.valuesTagQuick,
    'Snack' => l10n.valuesTagSnack,
    'Vegan' => l10n.valuesTagVegan,
    'Vegetarisch' => l10n.valuesTagVegetarian,
    'Für dich' => l10n.valuesTagForYou,
    _ => tag,
  };

  static String difficulty(AppLocalizations l10n, String value) =>
      switch (value) {
        'Einfach' => l10n.valuesDifficultyEasy,
        'Mittel' => l10n.valuesDifficultyMedium,
        'Anspruchsvoll' => l10n.valuesDifficultyHard,
        _ => value,
      };

  static String goal(AppLocalizations l10n, String value) => switch (value) {
    'Fett verlieren' => l10n.valuesGoalLoseFat,
    'Gewicht halten' => l10n.valuesGoalMaintain,
    'Muskeln aufbauen' => l10n.valuesGoalBuildMuscle,
    'Gesünder ernähren' => l10n.valuesGoalEatHealthier,
    _ => value,
  };

  static String nutritionStyle(AppLocalizations l10n, String value) =>
      switch (value) {
        'Vegetarisch' => l10n.valuesNutritionVegetarian,
        'Vegan' => l10n.valuesNutritionVegan,
        'Pescetarisch' => l10n.valuesNutritionPescatarian,
        'Ausgewogen' => l10n.valuesNutritionBalanced,
        _ => value,
      };

  static String activity(AppLocalizations l10n, String value) =>
      switch (value) {
        'Wenig aktiv' => l10n.valuesActivityLow,
        'Moderat aktiv' => l10n.valuesActivityModerate,
        'Aktiv' => l10n.valuesActivityActive,
        'Sehr aktiv' => l10n.valuesActivityVeryActive,
        _ => value,
      };

  /// Allergies are free text; only the stored placeholder is translated.
  static String allergies(AppLocalizations l10n, String value) =>
      value == 'Keine angegeben' ? l10n.valuesAllergiesNone : value;
}
