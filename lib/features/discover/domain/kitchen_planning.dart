import '../../../core/models/app_models.dart';
import 'ingredient_match.dart';
import 'recipe_serving.dart';

/// Pantry, shopping list and week plan as typed, immutable data plus the pure
/// rules that combine them. Formatting for people happens in the UI
/// (`kitchen_format.dart`); storage lives in `data/planning_store.dart`.

/// Units for amounts in the pantry and on the shopping list.
enum KitchenUnit {
  gram,
  milliliter,
  piece,
  tablespoon,
  teaspoon,
  can,
  pack,
  bunch,
  jar,
  cup,
  bottle,
  bag,
  clove,
  pinch,
}

/// A numeric amount with its unit. Kilograms and litres are stored as grams
/// and millilitres so that amounts can be added safely.
class KitchenAmount {
  const KitchenAmount(this.value, this.unit);

  final double value;
  final KitchenUnit unit;

  /// Sum of both amounts, or `null` when the units differ.
  KitchenAmount? plus(KitchenAmount other) =>
      other.unit == unit ? KitchenAmount(value + other.value, unit) : null;

  Map<String, Object> toJson() => {'value': value, 'unit': unit.name};

  static KitchenAmount? fromJson(Object? json) {
    if (json is! Map) return null;
    final value = json['value'];
    final unitName = json['unit'];
    if (value is! num || value <= 0 || unitName is! String) return null;
    for (final unit in KitchenUnit.values) {
      if (unit.name == unitName) return KitchenAmount(value.toDouble(), unit);
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is KitchenAmount && other.value == value && other.unit == unit;

  @override
  int get hashCode => Object.hash(value, unit);

  @override
  String toString() => 'KitchenAmount($value ${unit.name})';
}

/// Unit words people type, folded (see [foldIngredientText]) and without
/// dots, with the factor to the stored unit.
const _unitWords = <String, (KitchenUnit, double)>{
  '': (KitchenUnit.piece, 1),
  'stk': (KitchenUnit.piece, 1),
  'st': (KitchenUnit.piece, 1),
  'stuck': (KitchenUnit.piece, 1),
  'g': (KitchenUnit.gram, 1),
  'gr': (KitchenUnit.gram, 1),
  'gramm': (KitchenUnit.gram, 1),
  'kg': (KitchenUnit.gram, 1000),
  'kilo': (KitchenUnit.gram, 1000),
  'kilogramm': (KitchenUnit.gram, 1000),
  'ml': (KitchenUnit.milliliter, 1),
  'l': (KitchenUnit.milliliter, 1000),
  'ltr': (KitchenUnit.milliliter, 1000),
  'liter': (KitchenUnit.milliliter, 1000),
  'el': (KitchenUnit.tablespoon, 1),
  'tl': (KitchenUnit.teaspoon, 1),
  'dose': (KitchenUnit.can, 1),
  'dosen': (KitchenUnit.can, 1),
  'packung': (KitchenUnit.pack, 1),
  'packungen': (KitchenUnit.pack, 1),
  'pck': (KitchenUnit.pack, 1),
  'pkg': (KitchenUnit.pack, 1),
  'pack': (KitchenUnit.pack, 1),
  'packchen': (KitchenUnit.pack, 1),
  'bund': (KitchenUnit.bunch, 1),
  'glas': (KitchenUnit.jar, 1),
  'glaser': (KitchenUnit.jar, 1),
  'becher': (KitchenUnit.cup, 1),
  'flasche': (KitchenUnit.bottle, 1),
  'flaschen': (KitchenUnit.bottle, 1),
  'beutel': (KitchenUnit.bag, 1),
  'tute': (KitchenUnit.bag, 1),
  'tuten': (KitchenUnit.bag, 1),
  'zehe': (KitchenUnit.clove, 1),
  'zehen': (KitchenUnit.clove, 1),
  'prise': (KitchenUnit.pinch, 1),
  'prisen': (KitchenUnit.pinch, 1),
};

const _fractions = {'½': 0.5, '¼': 0.25, '¾': 0.75, '⅓': 1 / 3, '⅔': 2 / 3};

/// Parses what people type as an amount: "500 g", "1,5 kg", "2 Stück",
/// "½ Packung" or just "3" (pieces). Returns `null` for anything else, so the
/// text can be kept as a note instead of being guessed.
KitchenAmount? parseKitchenAmount(String text) {
  final match = RegExp(
    r'^\s*(\d+(?:[.,]\d+)?)?\s*([½¼¾⅓⅔])?\s*([^\d\s][^\d]*)?$',
  ).firstMatch(text);
  if (match == null) return null;
  final number = match.group(1);
  final fraction = match.group(2);
  if (number == null && fraction == null) return null;
  var value = number == null ? 0.0 : double.parse(number.replaceAll(',', '.'));
  if (fraction != null) value += _fractions[fraction]!;
  if (value <= 0 || value > 100000) return null;
  final unitText = foldIngredientText(
    (match.group(3) ?? '').trim(),
  ).replaceAll('.', '');
  final unit = _unitWords[unitText];
  if (unit == null) return null;
  return KitchenAmount(value * unit.$2, unit.$1);
}

/// Longest name kept for pantry and shopping entries.
const kitchenNameMaxLength = 60;

/// Upper limit per list; keeps local storage small.
const kitchenListMaxItems = 300;

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

String? _text(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

class PantryItem {
  const PantryItem({
    required this.id,
    required this.name,
    this.amount,
    this.note,
    this.addedAt,
  });

  final String id;
  final String name;
  final KitchenAmount? amount;

  /// Free text when the amount could not be read as a number ("etwas").
  final String? note;
  final DateTime? addedAt;

  PantryItem copyWith({KitchenAmount? amount}) => PantryItem(
    id: id,
    name: name,
    amount: amount ?? this.amount,
    note: note,
    addedAt: addedAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    if (amount != null) 'amount': amount!.toJson(),
    if (note != null) 'note': note,
    if (addedAt != null) 'added_at': addedAt!.toIso8601String(),
  };

  static PantryItem? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = _text(json['id']);
    final name = _text(json['name']);
    if (id == null || name == null) return null;
    return PantryItem(
      id: id,
      name: name,
      amount: KitchenAmount.fromJson(json['amount']),
      note: _text(json['note']),
      addedAt: _date(json['added_at']),
    );
  }
}

class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.name,
    this.amount,
    this.note,
    this.done = false,
    this.source,
    this.planKey,
    this.addedAt,
  });

  final String id;
  final String name;
  final KitchenAmount? amount;

  /// Household measure or free text, for example "1 Dose".
  final String? note;
  final bool done;

  /// Where the entry came from, for example the recipe title.
  final String? source;

  /// Set for entries created from one week of the plan, so creating the
  /// list again replaces them instead of adding duplicates.
  final String? planKey;
  final DateTime? addedAt;

  ShoppingItem copyWith({bool? done}) => ShoppingItem(
    id: id,
    name: name,
    amount: amount,
    note: note,
    done: done ?? this.done,
    source: source,
    planKey: planKey,
    addedAt: addedAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    if (amount != null) 'amount': amount!.toJson(),
    if (note != null) 'note': note,
    'done': done,
    if (source != null) 'source': source,
    if (planKey != null) 'plan_key': planKey,
    if (addedAt != null) 'added_at': addedAt!.toIso8601String(),
  };

  static ShoppingItem? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = _text(json['id']);
    final name = _text(json['name']);
    if (id == null || name == null) return null;
    return ShoppingItem(
      id: id,
      name: name,
      amount: KitchenAmount.fromJson(json['amount']),
      note: _text(json['note']),
      done: json['done'] == true,
      source: _text(json['source']),
      planKey: _text(json['plan_key']),
      addedAt: _date(json['added_at']),
    );
  }
}

/// One planned recipe on a day and meal. The title is kept so the plan stays
/// readable when the recipe is (temporarily) not in the catalog.
class MealPlanEntry {
  const MealPlanEntry({
    required this.id,
    required this.day,
    required this.slot,
    required this.recipeId,
    required this.recipeTitle,
    this.portions = 1,
  });

  final String id;

  /// Calendar day without time.
  final DateTime day;
  final MealSlot slot;
  final String recipeId;
  final String recipeTitle;
  final int portions;

  MealPlanEntry copyWith({DateTime? day, MealSlot? slot, int? portions}) =>
      MealPlanEntry(
        id: id,
        day: day == null ? this.day : kitchenDay(day),
        slot: slot ?? this.slot,
        recipeId: recipeId,
        recipeTitle: recipeTitle,
        portions: portions ?? this.portions,
      );

  Map<String, Object> toJson() => {
    'id': id,
    'day': _isoDay(day),
    'slot': slot.databaseValue,
    'recipe_id': recipeId,
    'recipe_title': recipeTitle,
    'portions': portions,
  };

  static MealPlanEntry? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = _text(json['id']);
    final day = _date(json['day']);
    final recipeId = _text(json['recipe_id']);
    final title = _text(json['recipe_title']);
    MealSlot? slot;
    for (final candidate in MealSlot.values) {
      if (candidate.databaseValue == json['slot']) slot = candidate;
    }
    final portions = json['portions'];
    if (id == null ||
        day == null ||
        recipeId == null ||
        title == null ||
        slot == null) {
      return null;
    }
    return MealPlanEntry(
      id: id,
      day: kitchenDay(day),
      slot: slot,
      recipeId: recipeId,
      recipeTitle: title,
      portions: portions is num ? clampPlanPortions(portions.round()) : 1,
    );
  }
}

const minPlanPortions = 1;
const maxPlanPortions = 12;

int clampPlanPortions(int value) =>
    value.clamp(minPlanPortions, maxPlanPortions);

/// Everything the planning feature stores for one account.
class KitchenState {
  const KitchenState({
    this.pantry = const [],
    this.shopping = const [],
    this.plan = const [],
    this.assumeBasics = true,
  });

  static const version = 1;

  final List<PantryItem> pantry;
  final List<ShoppingItem> shopping;
  final List<MealPlanEntry> plan;

  /// Whether salt, pepper, oil, water and common spices count as available.
  final bool assumeBasics;

  bool get isEmpty => pantry.isEmpty && shopping.isEmpty && plan.isEmpty;

  KitchenState copyWith({
    List<PantryItem>? pantry,
    List<ShoppingItem>? shopping,
    List<MealPlanEntry>? plan,
    bool? assumeBasics,
  }) => KitchenState(
    pantry: pantry ?? this.pantry,
    shopping: shopping ?? this.shopping,
    plan: plan ?? this.plan,
    assumeBasics: assumeBasics ?? this.assumeBasics,
  );

  /// Drops plan entries older than [keepWeeks] weeks (data minimisation).
  KitchenState withoutOldPlan(DateTime now, {int keepWeeks = 8}) {
    final start = weekStartOf(now);
    final limit = DateTime(start.year, start.month, start.day - 7 * keepWeeks);
    return copyWith(
      plan: [
        for (final entry in plan)
          if (!entry.day.isBefore(limit)) entry,
      ],
    );
  }

  Map<String, Object> toJson() => {
    'version': version,
    'assume_basics': assumeBasics,
    'pantry': [for (final item in pantry) item.toJson()],
    'shopping': [for (final item in shopping) item.toJson()],
    'plan': [for (final entry in plan) entry.toJson()],
  };

  /// Throws [FormatException] for data that is not a LIVO kitchen record, so
  /// callers never overwrite something they could not read. Single broken
  /// entries inside a valid record are skipped.
  static KitchenState fromJson(Object? json) {
    if (json is! Map || json['version'] != version) {
      throw const FormatException('Unbekanntes Format der Küchenlisten.');
    }
    List<T> read<T>(Object? raw, T? Function(Object?) parse) => [
      if (raw is List)
        for (final item in raw)
          if (parse(item) case final T value) value,
    ];
    return KitchenState(
      assumeBasics: json['assume_basics'] != false,
      pantry: read(json['pantry'], PantryItem.fromJson),
      shopping: read(json['shopping'], ShoppingItem.fromJson),
      plan: read(json['plan'], MealPlanEntry.fromJson),
    );
  }
}

/// Calendar day without time.
DateTime kitchenDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// Monday of the week that contains [value].
DateTime weekStartOf(DateTime value) =>
    DateTime(value.year, value.month, value.day - (value.weekday - 1));

/// The seven days starting at [monday].
List<DateTime> weekDays(DateTime monday) => [
  for (var offset = 0; offset < 7; offset++)
    DateTime(monday.year, monday.month, monday.day + offset),
];

bool sameKitchenDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _isoDay(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

/// Marks shopping entries created from the week starting at [monday].
String planWeekKey(DateTime monday) => 'plan-${_isoDay(weekStartOf(monday))}';

/// Entries of one week, ordered by day and meal.
List<MealPlanEntry> planEntriesForWeek(
  List<MealPlanEntry> plan,
  DateTime monday,
) {
  final start = weekStartOf(monday);
  final end = DateTime(start.year, start.month, start.day + 7);
  final entries = [
    for (final (index, entry) in plan.indexed)
      if (!entry.day.isBefore(start) && entry.day.isBefore(end)) (index, entry),
  ];
  entries.sort((a, b) {
    final byDay = a.$2.day.compareTo(b.$2.day);
    if (byDay != 0) return byDay;
    final bySlot = a.$2.slot.index.compareTo(b.$2.slot.index);
    return bySlot != 0 ? bySlot : a.$1.compareTo(b.$1);
  });
  return [for (final entry in entries) entry.$2];
}

/// Default meal for planning a recipe: the first meal tag of the recipe,
/// otherwise dinner.
MealSlot defaultPlanSlot(Recipe recipe) {
  for (final slot in MealSlot.values) {
    if (recipe.tags.contains(slot.label)) return slot;
  }
  return MealSlot.dinner;
}

/// Something that should go on the shopping list.
class ShoppingDraft {
  const ShoppingDraft({
    required this.name,
    this.amount,
    this.note,
    this.source,
    this.planKey,
  });

  final String name;
  final KitchenAmount? amount;
  final String? note;
  final String? source;
  final String? planKey;
}

/// Shopping drafts for the missing ingredients of [recipe] at [portions]
/// (the recipe's own portions by default).
List<ShoppingDraft> shoppingDraftsForIngredients(
  Recipe recipe,
  Iterable<RecipeIngredient> ingredients, {
  double? portions,
}) {
  final factor = (portions ?? basePortions(recipe)) / basePortions(recipe);
  return [
    for (final ingredient in ingredients)
      ShoppingDraft(
        name: ingredientDisplayName(ingredient.name),
        amount: ingredient.amountGrams > 0
            ? KitchenAmount(
                (ingredient.amountGrams * factor).ceilToDouble(),
                KitchenUnit.gram,
              )
            : null,
        note: scaleHouseholdMeasure(ingredient.measure, factor),
        source: recipe.title,
      ),
  ];
}

/// Result of adding drafts to the shopping list.
class ShoppingMerge {
  const ShoppingMerge({
    required this.items,
    required this.added,
    required this.alreadyOnList,
  });

  final List<ShoppingItem> items;
  final List<String> added;
  final List<String> alreadyOnList;
}

/// Adds [drafts] to [current] without duplicates: a draft whose ingredient is
/// already open on the list is skipped (tolerant name matching). Open entries
/// created earlier for [replacePlanKey] are replaced, so creating the list
/// from the same week again updates it instead of doubling amounts.
ShoppingMerge mergeShoppingDrafts(
  List<ShoppingItem> current,
  List<ShoppingDraft> drafts, {
  required String Function() newId,
  required DateTime now,
  String? replacePlanKey,
}) {
  final items = [
    for (final item in current)
      if (replacePlanKey == null || item.done || item.planKey != replacePlanKey)
        item,
  ];
  final added = <String>[];
  final already = <String>[];
  for (final draft in drafts) {
    final name = draft.name.trim();
    if (name.isEmpty) continue;
    final onList = items.any(
      (item) => !item.done && ingredientNamesMatch(item.name, name),
    );
    if (onList) {
      already.add(name);
      continue;
    }
    if (items.length >= kitchenListMaxItems) break;
    items.add(
      ShoppingItem(
        id: newId(),
        name: name,
        amount: draft.amount,
        note: draft.note,
        source: draft.source,
        planKey: draft.planKey,
        addedAt: now,
      ),
    );
    added.add(name);
  }
  return ShoppingMerge(items: items, added: added, alreadyOnList: already);
}

/// What the week plan needs, after basics and the pantry are taken off.
class PlanShoppingNeeds {
  const PlanShoppingNeeds({
    required this.drafts,
    required this.coveredByPantry,
    required this.skippedBasics,
    required this.unavailableRecipes,
    required this.plannedMeals,
  });

  final List<ShoppingDraft> drafts;
  final List<String> coveredByPantry;
  final List<String> skippedBasics;

  /// Planned recipes that are not in the catalog right now.
  final int unavailableRecipes;
  final int plannedMeals;
}

class _NeedGroup {
  _NeedGroup(this.name);

  final String name;
  double grams = 0;
  final measures = <String?>[];
  final recipes = <String>{};
}

/// Ingredients of all [entries] merged by ingredient (only identical
/// ingredient keys are merged, amounts in grams are summed). Basics are left
/// out when [assumeBasics] is set. Pantry items cover an ingredient; a pantry
/// amount in grams is subtracted, other or missing amounts count as enough.
PlanShoppingNeeds shoppingNeedsForPlan({
  required Iterable<MealPlanEntry> entries,
  required Recipe? Function(String recipeId) recipeFor,
  required List<PantryItem> pantry,
  required bool assumeBasics,
  String? planKey,
  String? source,
}) {
  final groups = <String, _NeedGroup>{};
  final basics = <String>{};
  var unavailable = 0;
  var planned = 0;
  for (final entry in entries) {
    planned++;
    final recipe = recipeFor(entry.recipeId);
    if (recipe == null) {
      unavailable++;
      continue;
    }
    final factor = entry.portions / basePortions(recipe);
    for (final ingredient in recipe.ingredients) {
      final name = ingredientDisplayName(ingredient.name);
      if (assumeBasics && isBasicIngredient(ingredient.name)) {
        basics.add(name);
        continue;
      }
      final keys = ingredientKeys(ingredient.name).toList()..sort();
      final id = keys.isEmpty ? foldIngredientText(name) : keys.join('|');
      final group = groups.putIfAbsent(id, () => _NeedGroup(name));
      group.grams += ingredient.amountGrams * factor;
      group.measures.add(scaleHouseholdMeasure(ingredient.measure, factor));
      group.recipes.add(recipe.title);
    }
  }
  final covered = <String>[];
  final drafts = <ShoppingDraft>[];
  for (final group in groups.values) {
    var grams = group.grams;
    PantryItem? stock;
    for (final item in pantry) {
      if (ingredientNamesMatch(item.name, group.name)) {
        stock = item;
        break;
      }
    }
    var partial = false;
    if (stock != null) {
      final amount = stock.amount;
      if (amount == null || amount.unit != KitchenUnit.gram) {
        covered.add(group.name);
        continue;
      }
      grams -= amount.value;
      if (grams <= 0) {
        covered.add(group.name);
        continue;
      }
      partial = true;
    }
    final singleMeasure = !partial && group.measures.length == 1
        ? group.measures.single
        : null;
    drafts.add(
      ShoppingDraft(
        name: group.name,
        amount: grams > 0
            ? KitchenAmount(grams.ceilToDouble(), KitchenUnit.gram)
            : null,
        note: singleMeasure,
        source: source ?? group.recipes.join(', '),
        planKey: planKey,
      ),
    );
  }
  return PlanShoppingNeeds(
    drafts: drafts,
    coveredByPantry: covered,
    skippedBasics: basics.toList(),
    unavailableRecipes: unavailable,
    plannedMeals: planned,
  );
}

enum PantryAddOutcome { added, merged, alreadyThere }

/// Adds [name] to the pantry. An existing matching item keeps its place;
/// amounts with the same unit are summed.
({List<PantryItem> pantry, PantryAddOutcome outcome}) addToPantry(
  List<PantryItem> pantry,
  String name, {
  KitchenAmount? amount,
  String? note,
  required String Function() newId,
  required DateTime now,
}) {
  for (final (index, item) in pantry.indexed) {
    if (!ingredientNamesMatch(item.name, name)) continue;
    final existing = item.amount;
    if (amount != null && existing == null && item.note == null) {
      return (
        pantry: [...pantry]..[index] = item.copyWith(amount: amount),
        outcome: PantryAddOutcome.merged,
      );
    }
    final sum = amount == null ? null : existing?.plus(amount);
    if (sum != null) {
      return (
        pantry: [...pantry]..[index] = item.copyWith(amount: sum),
        outcome: PantryAddOutcome.merged,
      );
    }
    return (pantry: pantry, outcome: PantryAddOutcome.alreadyThere);
  }
  return (
    pantry: [
      ...pantry,
      PantryItem(
        id: newId(),
        name: name,
        amount: amount,
        note: note,
        addedAt: now,
      ),
    ],
    outcome: PantryAddOutcome.added,
  );
}

/// Moves checked shopping entries into the pantry (merging with matching
/// pantry items) and removes them from the list.
({List<ShoppingItem> shopping, List<PantryItem> pantry, int moved})
moveCheckedToPantry(
  List<ShoppingItem> shopping,
  List<PantryItem> pantry, {
  required String Function() newId,
  required DateTime now,
}) {
  var nextPantry = pantry;
  var moved = 0;
  for (final item in shopping) {
    if (!item.done) continue;
    moved++;
    nextPantry = addToPantry(
      nextPantry,
      ingredientDisplayName(item.name),
      amount: item.amount,
      note: item.amount == null ? item.note : null,
      newId: newId,
      now: now,
    ).pantry;
  }
  return (
    shopping: [
      for (final item in shopping)
        if (!item.done) item,
    ],
    pantry: nextPantry,
    moved: moved,
  );
}
