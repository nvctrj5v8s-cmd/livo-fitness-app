import 'dart:math' as math;

import '../../../core/models/app_models.dart';

/// Range of the free portion calculator (whole portions).
const minRecipePortions = 1;
const maxRecipePortions = 6;

/// Range of the goal-based portion suggestion, relative to one portion.
const minSuggestedPortion = 0.5;
const maxSuggestedPortion = 2.0;

/// Base number of portions the ingredient amounts are written for.
double basePortions(Recipe recipe) => math.max(1, recipe.servings).toDouble();

/// One ingredient converted to a chosen number of portions.
class ScaledIngredient {
  const ScaledIngredient({
    required this.source,
    required this.grams,
    required this.measure,
    this.nutrition,
  });

  final RecipeIngredient source;

  /// Grams for the chosen portions.
  final double grams;

  /// Household measure for the chosen portions, or `null` when it cannot be
  /// converted sensibly (then only grams are shown).
  final String? measure;

  /// Nutrition of [grams], when the catalog food is known.
  final RecipeNutrition? nutrition;

  String get name => source.name;
  String? get note {
    final value = source.note?.trim() ?? '';
    return value.isEmpty ? null : value;
  }

  String get gramsLabel => RecipeIngredient.formatGrams(grams);
}

ScaledIngredient scaleIngredient(RecipeIngredient ingredient, double factor) =>
    ScaledIngredient(
      source: ingredient,
      grams: ingredient.amountGrams * factor,
      measure: scaleHouseholdMeasure(ingredient.measure, factor),
      nutrition: ingredient.nutrition?.scaled(factor),
    );

List<ScaledIngredient> scaleIngredients(Recipe recipe, double portions) {
  final factor = portions / basePortions(recipe);
  return [
    for (final ingredient in recipe.ingredients)
      scaleIngredient(ingredient, factor),
  ];
}

const _fractionGlyphs = {
  '½': 0.5,
  '⅓': 1 / 3,
  '⅔': 2 / 3,
  '¼': 0.25,
  '¾': 0.75,
};

/// Units that read the same in singular and plural.
const _invariantUnits = {
  'EL',
  'TL',
  'g',
  'kg',
  'ml',
  'l',
  'cl',
  'Msp.',
  'Pck.',
  'Pkg.',
  'Stk.',
  'Stück',
  'Bund',
  'Handvoll',
  'Becher',
  'Spritzer',
  'Beutel',
  'Würfel',
  'Brötchen',
  'Paprika',
};

/// Common singular → plural pairs for household measures.
const _plurals = {
  'Prise': 'Prisen',
  'Zehe': 'Zehen',
  'Filet': 'Filets',
  'Dose': 'Dosen',
  'Scheibe': 'Scheiben',
  'Tasse': 'Tassen',
  'Packung': 'Packungen',
  'Knolle': 'Knollen',
  'Zwiebel': 'Zwiebeln',
  'Stange': 'Stangen',
  'Zweig': 'Zweige',
  'Blatt': 'Blätter',
  'Ei': 'Eier',
  'Tomate': 'Tomaten',
  'Kugel': 'Kugeln',
  'Schote': 'Schoten',
  'Tube': 'Tuben',
  'Messerspitze': 'Messerspitzen',
  'Glas': 'Gläser',
  'Banane': 'Bananen',
  'Zitrone': 'Zitronen',
  'Limette': 'Limetten',
  'Karotte': 'Karotten',
  'Möhre': 'Möhren',
  'Gurke': 'Gurken',
  'Avocado': 'Avocados',
  'Apfel': 'Äpfel',
  'Kartoffel': 'Kartoffeln',
  'Süßkartoffel': 'Süßkartoffeln',
  'Frühlingszwiebel': 'Frühlingszwiebeln',
  'Chilischote': 'Chilischoten',
  'Fladenbrot': 'Fladenbrote',
  'Tortilla': 'Tortillas',
  'Wrap': 'Wraps',
  'Portion': 'Portionen',
};

/// Converts a household measure such as "1 EL", "½ Stück" or "2 Zehen" by
/// [factor]. Returns `null` when that would be misleading (ranges, numbers
/// inside the text, unknown plural forms, tiny amounts); grams stay the
/// reliable amount in that case.
String? scaleHouseholdMeasure(String? measure, double factor) {
  final text = measure?.trim() ?? '';
  if (text.isEmpty) return null;
  if ((factor - 1).abs() < 0.001) return text;
  final parsed = _parseLeadingAmount(text);
  if (parsed == null) return null;
  final (amount, rest) = parsed;
  if (amount <= 0 || RegExp(r'^[-–]').hasMatch(rest)) return null;
  if (RegExp(r'\d').hasMatch(rest)) return null;

  final scaled = amount * factor;
  if (scaled < 0.2) return null;
  final nice = _niceAmount(scaled);
  final approximate = (nice - scaled).abs() > 0.02;

  var unitText = rest;
  if (rest.isNotEmpty) {
    final words = rest.split(RegExp(r'\s+'));
    final unit = words.first;
    final plural = nice > 1;
    String? nextUnit;
    if (_invariantUnits.contains(unit)) {
      nextUnit = unit;
    } else if (_plurals.containsKey(unit)) {
      nextUnit = plural ? _plurals[unit] : unit;
    } else if (_plurals.containsValue(unit)) {
      nextUnit = plural
          ? unit
          : _plurals.entries.firstWhere((entry) => entry.value == unit).key;
    } else if ((amount > 1) == plural) {
      nextUnit = unit;
    }
    if (nextUnit == null) return null;
    unitText = [nextUnit, ...words.skip(1)].join(' ');
  }
  final number = formatFractionDe(nice);
  return '${approximate ? 'ca. ' : ''}$number'
      '${unitText.isEmpty ? '' : ' $unitText'}';
}

(double, String)? _parseLeadingAmount(String text) {
  final slash = RegExp(r'^(\d+)\s*/\s*(\d+)\s*(.*)$').firstMatch(text);
  if (slash != null) {
    final top = int.parse(slash.group(1)!);
    final bottom = int.parse(slash.group(2)!);
    if (bottom == 0) return null;
    return (top / bottom, slash.group(3)!.trim());
  }
  final match = RegExp(
    r'^(\d+(?:[.,]\d+)?)?\s*([½⅓⅔¼¾])?\s*(.*)$',
  ).firstMatch(text);
  if (match == null) return null;
  final whole = match.group(1);
  final glyph = match.group(2);
  if (whole == null && glyph == null) return null;
  final double value =
      (whole == null ? 0.0 : double.parse(whole.replaceAll(',', '.'))) +
      (glyph == null ? 0.0 : _fractionGlyphs[glyph]!);
  return (value, match.group(3)!.trim());
}

/// Nearest quarter or third; whole numbers from 5 upwards.
double _niceAmount(double value) {
  if (value >= 5) return value.roundToDouble();
  final quarter = (value * 4).round() / 4;
  final third = (value * 3).round() / 3;
  return (quarter - value).abs() <= (third - value).abs() ? quarter : third;
}

/// German number with fraction glyphs: `1½`, `¾`, `2`, `1,2`.
String formatFractionDe(double value) {
  final whole = value.floor();
  final fraction = value - whole;
  if (fraction < 0.01) return '$whole';
  if (fraction > 0.99) return '${whole + 1}';
  String? glyph;
  for (final entry in _fractionGlyphs.entries) {
    if ((entry.value - fraction).abs() < 0.01) glyph = entry.key;
  }
  if (glyph == null) {
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }
  return whole == 0 ? glyph : '$whole$glyph';
}

/// "1 Portion", "½ Portion", "4 Portionen".
String portionsLabel(double portions) =>
    '${formatFractionDe(portions)} ${portions <= 1 ? 'Portion' : 'Portionen'}';

/// Result of the goal-based portion suggestion. It is an estimate for
/// orientation only and never a diet prescription.
class PortionSuggestion {
  const PortionSuggestion({
    required this.factor,
    required this.calorieGoal,
    required this.consumedCalories,
    required this.mealsPerDay,
    required this.mealsLogged,
    required this.mealBudget,
  });

  /// Suggested share of one portion, 0.5 to 2 in quarter steps.
  final double factor;
  final int calorieGoal;
  final int consumedCalories;
  final int mealsPerDay;
  final int mealsLogged;

  /// Calories estimated for this meal.
  final int mealBudget;

  int get remainingCalories => calorieGoal - consumedCalories;
  bool get goalReached => remainingCalories <= 0;
  int get mealsLeft => math.max(1, mealsPerDay - mealsLogged);
}

/// Splits today's remaining calories over the meals still expected and
/// picks the largest quarter step of one portion that fits, clamped to
/// 0.5–2 portions. Returns `null` without usable numbers.
PortionSuggestion? suggestPortion({
  required double caloriesPerPortion,
  required int calorieGoal,
  required int consumedCalories,
  required int mealsPerDay,
  required int mealsLogged,
}) {
  if (caloriesPerPortion <= 0 || calorieGoal <= 0) return null;
  final meals = mealsPerDay.clamp(1, 8);
  final logged = math.max(0, mealsLogged);
  final remaining = calorieGoal - consumedCalories;
  final mealsLeft = math.max(1, meals - logged);
  final budget = remaining <= 0 ? 0 : (remaining / mealsLeft).round();
  final raw = budget / caloriesPerPortion;
  final stepped = ((raw + 1e-9) * 4).floorToDouble() / 4;
  return PortionSuggestion(
    factor: stepped.clamp(minSuggestedPortion, maxSuggestedPortion),
    calorieGoal: calorieGoal,
    consumedCalories: consumedCalories,
    mealsPerDay: meals,
    mealsLogged: logged,
    mealBudget: budget,
  );
}

/// Picks the diary meal for a recipe: its meal-type tag, preferring the one
/// that matches the time of day, otherwise the time of day alone.
MealSlot suggestedMealSlot(Recipe recipe, DateTime now) {
  final minutes = now.hour * 60 + now.minute;
  final byTime = minutes < 10 * 60 + 30
      ? MealSlot.breakfast
      : minutes < 14 * 60 + 30
      ? MealSlot.lunch
      : minutes < 17 * 60
      ? MealSlot.snack
      : MealSlot.dinner;
  final tagged = [
    for (final slot in MealSlot.values)
      if (recipe.tags.contains(slot.label)) slot,
  ];
  if (tagged.isEmpty || tagged.contains(byTime)) return byTime;
  return tagged.first;
}
