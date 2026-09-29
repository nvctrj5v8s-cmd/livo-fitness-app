import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/data/halal_content_policy.dart';
import '../../../core/models/app_models.dart';
import '../data/planning_store.dart';
import '../domain/ingredient_match.dart';
import '../domain/kitchen_planning.dart';

/// Result of adding something to the pantry or the shopping list.
enum KitchenEditStatus { added, merged, removed, duplicate, invalid, notReady }

class KitchenEdit {
  const KitchenEdit(this.status, [this.message]);

  final KitchenEditStatus status;

  /// German explanation for [KitchenEditStatus.invalid] and
  /// [KitchenEditStatus.notReady].
  final String? message;

  bool get changed =>
      status == KitchenEditStatus.added || status == KitchenEditStatus.merged;
}

/// Summary after creating the shopping list from one week of the plan.
class PlanShoppingSummary {
  const PlanShoppingSummary({
    required this.added,
    required this.alreadyOnList,
    required this.coveredByPantry,
    required this.skippedBasics,
    required this.unavailableRecipes,
    required this.plannedMeals,
  });

  final List<String> added;
  final List<String> alreadyOnList;
  final List<String> coveredByPantry;
  final List<String> skippedBasics;
  final int unavailableRecipes;
  final int plannedMeals;
}

/// State of the week plan, shopping list and pantry for one account.
///
/// Signed-in accounts keep the lists on this device through [PlanningStore];
/// every change is written right away. Without an account (preview/tests)
/// the lists live only in memory, which the UI says explicitly.
class PlanningController extends ChangeNotifier {
  PlanningController({
    this.userId,
    PlanningStore? store,
    DateTime Function()? now,
  }) : _store = store ?? const DevicePlanningStore(),
       _now = now ?? DateTime.now,
       _loaded = userId == null;

  final String? userId;
  final PlanningStore _store;
  final DateTime Function() _now;

  KitchenState _state = const KitchenState();
  bool _loaded;
  bool _loading = false;
  bool _disposed = false;
  Future<void>? _loadFuture;
  Future<void> _writes = Future.value();
  int _idCounter = 0;

  /// Set when stored lists exist but could not be read. Changes are blocked
  /// until a retry works or the user resets the stored lists.
  String? loadError;

  /// Set when the last change could not be written to this device.
  String? saveError;

  /// Whether changes survive a restart (only with an account).
  bool get persistent => userId != null;
  bool get ready => _loaded;
  bool get loading => _loading;

  List<PantryItem> get pantry => _state.pantry;
  List<ShoppingItem> get shopping => _state.shopping;
  List<MealPlanEntry> get plan => _state.plan;
  bool get assumeBasics => _state.assumeBasics;
  int get openShoppingCount => shopping.where((item) => !item.done).length;
  int get checkedShoppingCount => shopping.where((item) => item.done).length;

  /// Names in the pantry, for "Was kann ich kochen?".
  List<String> get pantryNames => [for (final item in pantry) item.name];

  List<MealPlanEntry> entriesForWeek(DateTime monday) =>
      planEntriesForWeek(plan, monday);

  /// Waits for all queued writes; used by tests and before a reset.
  Future<void> get pendingWrites => _writes;

  Future<void> load() {
    if (!persistent || _loaded) return Future.value();
    return _loadFuture ??= _read().whenComplete(() => _loadFuture = null);
  }

  Future<void> _read() async {
    _loading = true;
    loadError = null;
    _notify();
    try {
      final stored = await _store
          .load(userId!)
          .timeout(const Duration(seconds: 6));
      if (_disposed) return;
      _state = (stored ?? const KitchenState()).withoutOldPlan(_now());
      _loaded = true;
    } catch (_) {
      if (_disposed) return;
      loadError =
          'Deine Listen konnten auf diesem Gerät nicht gelesen werden. '
          'Änderungen sind gesperrt, damit nichts überschrieben wird.';
    } finally {
      _loading = false;
      _notify();
    }
  }

  /// Deletes the stored lists of this account on this device and starts
  /// empty. Also the way out when stored data could not be read.
  Future<bool> clearAll() async {
    final assumeBasics = _state.assumeBasics;
    _state = KitchenState(assumeBasics: assumeBasics);
    if (!persistent) {
      _notify();
      return true;
    }
    try {
      await _writes;
      await _store.clear(userId!);
      if (_disposed) return false;
      _loaded = true;
      loadError = null;
      saveError = null;
      return true;
    } catch (_) {
      if (!_disposed) {
        saveError =
            'Die Listen konnten nicht von diesem Gerät gelöscht werden.';
      }
      return false;
    } finally {
      _notify();
    }
  }

  // --- Pantry --------------------------------------------------------------

  KitchenEdit addPantryItem(String name, {String amountText = ''}) {
    final problem = _checkName(name) ?? _checkReady();
    if (problem != null) return problem;
    if (pantry.length >= kitchenListMaxItems) {
      return const KitchenEdit(
        KitchenEditStatus.invalid,
        'Deine Vorräte sind voll. Entferne zuerst ältere Einträge.',
      );
    }
    final (amount, note) = _amountFrom(amountText);
    final result = addToPantry(
      pantry,
      _cleanName(name),
      amount: amount,
      note: note,
      newId: _newId,
      now: _now(),
    );
    if (result.outcome == PantryAddOutcome.alreadyThere) {
      return const KitchenEdit(KitchenEditStatus.duplicate);
    }
    _commit(_state.copyWith(pantry: result.pantry));
    return KitchenEdit(
      result.outcome == PantryAddOutcome.added
          ? KitchenEditStatus.added
          : KitchenEditStatus.merged,
    );
  }

  void removePantryItem(String id) {
    if (!_loaded) return;
    _commit(
      _state.copyWith(pantry: [...pantry.where((item) => item.id != id)]),
    );
  }

  /// The pantry item matching a staple such as "Kartoffeln", if any.
  PantryItem? pantryItemFor(String name) {
    for (final item in pantry) {
      if (ingredientNamesMatch(item.name, name)) return item;
    }
    return null;
  }

  /// Quick chips: adds the staple, or removes the matching pantry item.
  KitchenEdit togglePantryStaple(String name) {
    final existing = pantryItemFor(name);
    if (existing == null) return addPantryItem(name);
    if (!_loaded) return _checkReady()!;
    removePantryItem(existing.id);
    return const KitchenEdit(KitchenEditStatus.removed);
  }

  void clearPantry() {
    if (!_loaded) return;
    _commit(_state.copyWith(pantry: const []));
  }

  void setAssumeBasics(bool value) {
    if (!_loaded || value == assumeBasics) return;
    _commit(_state.copyWith(assumeBasics: value));
  }

  // --- Shopping list -------------------------------------------------------

  KitchenEdit addShoppingItem(String name, {String amountText = ''}) {
    final problem = _checkName(name) ?? _checkReady();
    if (problem != null) return problem;
    final (amount, note) = _amountFrom(amountText);
    final merge = mergeShoppingDrafts(
      shopping,
      [ShoppingDraft(name: _cleanName(name), amount: amount, note: note)],
      newId: _newId,
      now: _now(),
    );
    if (merge.added.isEmpty) {
      return merge.alreadyOnList.isEmpty
          ? const KitchenEdit(
              KitchenEditStatus.invalid,
              'Deine Einkaufsliste ist voll. Entferne zuerst Erledigtes.',
            )
          : const KitchenEdit(KitchenEditStatus.duplicate);
    }
    _commit(_state.copyWith(shopping: merge.items));
    return const KitchenEdit(KitchenEditStatus.added);
  }

  /// Adds recipe ingredients; returns `null` when the lists are not ready.
  ShoppingMerge? addShoppingDrafts(List<ShoppingDraft> drafts) {
    if (!_loaded) return null;
    final allowed = [
      for (final draft in drafts)
        if (HalalContentPolicy.isAllowedText(draft.name)) draft,
    ];
    final merge = mergeShoppingDrafts(
      shopping,
      allowed,
      newId: _newId,
      now: _now(),
    );
    if (merge.added.isNotEmpty) _commit(_state.copyWith(shopping: merge.items));
    return merge;
  }

  /// Renames an entry or changes its amount. An empty [amountText] removes
  /// the amount; [keepAmount] leaves amount and note as they are. The entry
  /// keeps its place, check mark and recipe source.
  KitchenEdit updateShoppingItem(
    String id, {
    required String name,
    String amountText = '',
    bool keepAmount = false,
  }) {
    final problem = _checkName(name) ?? _checkReady();
    if (problem != null) return problem;
    final index = shopping.indexWhere((item) => item.id == id);
    if (index < 0) {
      return const KitchenEdit(
        KitchenEditStatus.invalid,
        'Dieser Artikel ist nicht mehr auf der Liste.',
      );
    }
    final cleaned = _cleanName(name);
    final clash = shopping.any(
      (item) =>
          item.id != id &&
          !item.done &&
          ingredientNamesMatch(item.name, cleaned),
    );
    if (clash && !ingredientNamesMatch(shopping[index].name, cleaned)) {
      return const KitchenEdit(KitchenEditStatus.duplicate);
    }
    final current = shopping[index];
    final (amount, note) = keepAmount
        ? (current.amount, current.note)
        : _amountFrom(amountText);
    final next = [...shopping]
      ..[index] = shopping[index].withDetails(
        name: cleaned,
        amount: amount,
        note: note,
      );
    _commit(_state.copyWith(shopping: next));
    return const KitchenEdit(KitchenEditStatus.merged);
  }

  void toggleShoppingItem(String id) {
    if (!_loaded) return;
    _commit(
      _state.copyWith(
        shopping: [
          for (final item in shopping)
            item.id == id ? item.copyWith(done: !item.done) : item,
        ],
      ),
    );
  }

  void removeShoppingItem(String id) {
    if (!_loaded) return;
    _commit(
      _state.copyWith(shopping: [...shopping.where((item) => item.id != id)]),
    );
  }

  /// Re-inserts an entry removed by mistake (snackbar "Rückgängig").
  void restoreShoppingItem(ShoppingItem item, int index) {
    if (!_loaded || shopping.any((existing) => existing.id == item.id)) return;
    final next = [...shopping]..insert(index.clamp(0, shopping.length), item);
    _commit(_state.copyWith(shopping: next));
  }

  int clearCheckedShopping() {
    if (!_loaded) return 0;
    final removed = checkedShoppingCount;
    if (removed == 0) return 0;
    _commit(
      _state.copyWith(shopping: [...shopping.where((item) => !item.done)]),
    );
    return removed;
  }

  /// Moves checked entries into the pantry; returns how many moved.
  int moveCheckedToPantryItems() {
    if (!_loaded) return 0;
    final result = moveCheckedToPantry(
      shopping,
      pantry,
      newId: _newId,
      now: _now(),
    );
    if (result.moved == 0) return 0;
    _commit(
      _state.copyWith(
        shopping: result.shopping,
        pantry: result.pantry.take(kitchenListMaxItems).toList(),
      ),
    );
    return result.moved;
  }

  void clearShopping() {
    if (!_loaded) return;
    _commit(_state.copyWith(shopping: const []));
  }

  // --- Week plan -----------------------------------------------------------

  bool addPlanEntry({
    required Recipe recipe,
    required DateTime day,
    required MealSlot slot,
    int portions = 1,
  }) {
    if (!_loaded || plan.length >= kitchenListMaxItems) return false;
    if (!HalalContentPolicy.isAllowedRecipe(recipe)) return false;
    _commit(
      _state.copyWith(
        plan: [
          ...plan,
          MealPlanEntry(
            id: _newId(),
            day: kitchenDay(day),
            slot: slot,
            recipeId: recipe.id,
            recipeTitle: recipe.title,
            portions: clampPlanPortions(portions),
          ),
        ],
      ),
    );
    return true;
  }

  /// Moves an entry to another day/meal or changes its portions.
  void updatePlanEntry(
    String id, {
    DateTime? day,
    MealSlot? slot,
    int? portions,
  }) {
    if (!_loaded) return;
    _commit(
      _state.copyWith(
        plan: [
          for (final entry in plan)
            entry.id == id
                ? entry.copyWith(
                    day: day,
                    slot: slot,
                    portions: portions == null
                        ? null
                        : clampPlanPortions(portions),
                  )
                : entry,
        ],
      ),
    );
  }

  void removePlanEntry(String id) {
    if (!_loaded) return;
    _commit(_state.copyWith(plan: [...plan.where((entry) => entry.id != id)]));
  }

  void restorePlanEntry(MealPlanEntry entry) {
    if (!_loaded || plan.any((existing) => existing.id == entry.id)) return;
    _commit(_state.copyWith(plan: [...plan, entry]));
  }

  int clearWeek(DateTime monday) {
    if (!_loaded) return 0;
    final week = {for (final entry in entriesForWeek(monday)) entry.id};
    if (week.isEmpty) return 0;
    _commit(
      _state.copyWith(
        plan: [...plan.where((entry) => !week.contains(entry.id))],
      ),
    );
    return week.length;
  }

  /// Puts the ingredients of the week's planned recipes on the shopping list,
  /// minus pantry and (optionally) basics. Running it again for the same
  /// week replaces the entries it created before. `null` when not ready.
  PlanShoppingSummary? createShoppingFromPlan(
    DateTime monday,
    List<Recipe> recipes,
  ) {
    if (!_loaded) return null;
    final byId = {for (final recipe in recipes) recipe.id: recipe};
    final key = planWeekKey(monday);
    final needs = shoppingNeedsForPlan(
      entries: entriesForWeek(monday),
      recipeFor: (id) => byId[id],
      pantry: pantry,
      assumeBasics: assumeBasics,
      planKey: key,
    );
    final merge = mergeShoppingDrafts(
      shopping,
      needs.drafts,
      newId: _newId,
      now: _now(),
      replacePlanKey: key,
    );
    _commit(_state.copyWith(shopping: merge.items));
    return PlanShoppingSummary(
      added: merge.added,
      alreadyOnList: merge.alreadyOnList,
      coveredByPantry: needs.coveredByPantry,
      skippedBasics: needs.skippedBasics,
      unavailableRecipes: needs.unavailableRecipes,
      plannedMeals: needs.plannedMeals,
    );
  }

  // --- Internals -----------------------------------------------------------

  String _newId() =>
      'k${_now().microsecondsSinceEpoch.toRadixString(36)}'
      '${(_idCounter++).toRadixString(36)}';

  String _cleanName(String name) => name.trim().replaceAll(RegExp(r'\s+'), ' ');

  (KitchenAmount?, String?) _amountFrom(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return (null, null);
    final amount = parseKitchenAmount(trimmed);
    if (amount != null) return (amount, null);
    return (
      null,
      trimmed.length > 30 ? trimmed.substring(0, 30).trim() : trimmed,
    );
  }

  KitchenEdit? _checkName(String name) {
    final cleaned = _cleanName(name);
    if (cleaned.isEmpty) {
      return const KitchenEdit(
        KitchenEditStatus.invalid,
        'Bitte gib einen Namen ein.',
      );
    }
    if (cleaned.length > kitchenNameMaxLength) {
      return const KitchenEdit(
        KitchenEditStatus.invalid,
        'Bitte höchstens $kitchenNameMaxLength Zeichen verwenden.',
      );
    }
    final restriction = HalalContentPolicy.restrictionReason(cleaned);
    if (restriction != null) {
      return KitchenEdit(KitchenEditStatus.invalid, restriction);
    }
    return null;
  }

  KitchenEdit? _checkReady() {
    if (_loaded) return null;
    return KitchenEdit(
      KitchenEditStatus.notReady,
      loadError ?? 'Deine Listen werden noch geladen.',
    );
  }

  void _commit(KitchenState next) {
    _state = next;
    _notify();
    final id = userId;
    if (id == null) return;
    _writes = _writes.then((_) async {
      try {
        await _store.save(id, next);
        if (!_disposed && saveError != null) {
          saveError = null;
          _notify();
        }
      } catch (_) {
        if (_disposed) return;
        saveError =
            'Die letzte Änderung konnte nicht auf diesem Gerät gespeichert '
            'werden. Sie gilt nur bis zum Schließen der App.';
        _notify();
      }
    });
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
