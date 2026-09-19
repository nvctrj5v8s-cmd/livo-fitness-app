import 'package:flutter/material.dart';

import '../../../core/data/food_search_service.dart';
import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import 'barcode_scanner_page.dart';
import 'custom_food_sheet.dart';
import 'food_detail_page.dart';

export 'custom_food_sheet.dart' show showCustomMealSheet;

Future<void> showAddMealSheet(
  BuildContext context, {
  DateTime? date,
  MealSlot initialSlot = MealSlot.snack,
}) async {
  final selectedDate = date ?? DateTime.now();
  final customSlot = await showModalBottomSheet<MealSlot>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _AddMealSheet(date: selectedDate, initialSlot: initialSlot),
  );
  if (customSlot != null && context.mounted) {
    await showCustomMealSheet(
      context,
      date: selectedDate,
      initialSlot: customSlot,
    );
  }
}

class _AddMealSheet extends StatefulWidget {
  const _AddMealSheet({required this.date, required this.initialSlot});

  final DateTime date;
  final MealSlot initialSlot;

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  String _query = '';
  late MealSlot _slot;
  double _amountGrams = 100;
  String? _savingFoodId;
  String? _error;
  FoodCatalogFilter _filter = FoodCatalogFilter.all;

  @override
  void initState() {
    super.initState();
    _slot = widget.initialSlot;
  }

  static const _demoFoods = [
    FoodItem(
      id: 'demo-chicken',
      name: 'Hähnchen-Reis-Bowl',
      servingGrams: 100,
      calories: 540,
      protein: 46,
      carbohydrates: 58,
      fat: 13,
    ),
    FoodItem(
      id: 'demo-bread',
      name: 'Vollkornbrot mit Ei',
      servingGrams: 100,
      calories: 360,
      protein: 24,
      carbohydrates: 34,
      fat: 14,
    ),
    FoodItem(
      id: 'demo-yogurt',
      name: 'Griechischer Joghurt',
      servingGrams: 100,
      calories: 220,
      protein: 23,
      carbohydrates: 18,
      fat: 7,
    ),
    FoodItem(
      id: 'demo-pasta',
      name: 'Protein-Pasta',
      servingGrams: 100,
      calories: 570,
      protein: 38,
      carbohydrates: 72,
      fat: 15,
    ),
    FoodItem(
      id: 'demo-omelet',
      name: 'Gemüse-Omelett',
      servingGrams: 100,
      calories: 390,
      protein: 32,
      carbohydrates: 18,
      fat: 21,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final demo =
        controller.foods.isEmpty && controller.personalizationUserId == null;
    final sourceFoods = demo ? _demoFoods : controller.foods;
    final filtered =
        sourceFoods
            .where(
              (food) =>
                  FoodSearchService.matches(food, _query) &&
                  _matchesFilter(food, controller),
            )
            .toList()
          ..sort((first, second) => _sortFoods(first, second, controller));
    final results = filtered.take(_query.trim().isEmpty ? 8 : 30).toList();
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Was hast du gegessen?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 7),
              Text(
                controller.catalogLoading
                    ? 'Lebensmittel werden geladen …'
                    : demo
                    ? 'Lokale Demo-Suche – funktioniert bereits ohne Konto.'
                    : 'Suche dein Lebensmittel oder trage eigene Werte ein.',
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MealSlot.values
                    .map(
                      (slot) => ChoiceChip(
                        key: ValueKey('add-slot-${slot.name}'),
                        label: Text(
                          slot == MealSlot.snack ? 'Snacks' : slot.label,
                        ),
                        selected: _slot == slot,
                        onSelected: _savingFoodId == null
                            ? (_) => setState(() => _slot = slot)
                            : null,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('food-search'),
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Lebensmittel oder Gericht suchen',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 12),
              _FoodFilterBar(
                selected: _filter,
                onSelected: (value) => setState(() => _filter = value),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const Key('open-custom-food'),
                    onPressed: _savingFoodId == null
                        ? () => Navigator.pop(context, _slot)
                        : null,
                    icon: const Icon(Icons.edit_note_rounded),
                    label: const Text('Selbst eintragen'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _savingFoodId == null ? _scan : null,
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('Barcode scannen'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  Text(
                    'Gegessene Menge',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  DropdownButton<double>(
                    value: _amountGrams,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(16),
                    items:
                        const [
                              25.0,
                              50.0,
                              100.0,
                              150.0,
                              200.0,
                              250.0,
                              300.0,
                              500.0,
                            ]
                            .map(
                              (grams) => DropdownMenuItem(
                                value: grams,
                                child: Text('${grams.toInt()} g'),
                              ),
                            )
                            .toList(),
                    onChanged: _savingFoodId == null
                        ? (value) {
                            if (value != null) {
                              setState(() => _amountGrams = value);
                            }
                          }
                        : null,
                  ),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              if (results.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Noch kein Treffer. Suche auch auf Englisch oder trage dein Lebensmittel selbst ein.',
                  ),
                ),
              ...results.map(
                (food) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Material(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: _savingFoodId == null
                          ? () => _openDetails(food)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    food.name,
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${(food.calories * _amountGrams / food.servingGrams).round()} kcal · ${_amountGrams.toInt()} g',
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Details anzeigen',
                              onPressed: _savingFoodId == null
                                  ? () => _openDetails(food)
                                  : null,
                              icon: const Icon(Icons.info_outline_rounded),
                            ),
                            IconButton(
                              tooltip: 'Zu ${_slot.label} hinzufügen',
                              onPressed: _savingFoodId == null
                                  ? () => _saveFood(food)
                                  : null,
                              icon: _savingFoodId == food.id
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.add_circle_rounded,
                                      color: AppColors.primary,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scan() async {
    final food = await Navigator.of(context).push<FoodItem>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );
    if (!mounted || food == null) return;
    await _openDetails(food);
  }

  Future<void> _openDetails(FoodItem food) async {
    if (food.id.startsWith('demo-')) {
      await _saveFood(food);
      return;
    }
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FoodDetailPage(
          food: food,
          date: widget.date,
          initialSlot: _slot,
          initialAmountGrams: _amountGrams,
        ),
      ),
    );
    if (mounted && saved == true) Navigator.pop(context);
  }

  Future<void> _saveFood(FoodItem food) async {
    if (_savingFoodId != null) return;
    if (food.id.startsWith('demo-')) {
      final factor = _amountGrams / food.servingGrams;
      AppScope.of(context).addMeal(
        MealEntry(
          id: '${food.id}-${DateTime.now().microsecondsSinceEpoch}',
          name: food.name,
          slot: _slot,
          calories: (food.calories * factor).round(),
          protein: (food.protein * factor).round(),
          carbs: (food.carbohydrates * factor).round(),
          fat: (food.fat * factor).round(),
          amountGrams: _amountGrams,
        ),
      );
      AppScope.of(context).recordFoodUse(food.id);
      Navigator.pop(context);
      return;
    }
    setState(() {
      _savingFoodId = food.id;
      _error = null;
    });
    try {
      final saved = await AppScope.of(context).addFoodToDiary(
        food: food,
        slot: _slot,
        amountGrams: _amountGrams,
        date: widget.date,
      );
      if (!mounted) return;
      setState(() => _savingFoodId = null);
      if (saved) {
        Navigator.pop(context);
      } else {
        setState(
          () => _error =
              AppScope.of(context).diaryError ??
              'Das Lebensmittel konnte nicht gespeichert werden.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _savingFoodId = null;
          _error = 'Speichern fehlgeschlagen. Bitte erneut versuchen.';
        });
      }
    }
  }

  bool _matchesFilter(FoodItem food, AppController controller) =>
      switch (_filter) {
        FoodCatalogFilter.all => true,
        FoodCatalogFilter.recent => controller.recentFoodIds.contains(food.id),
        FoodCatalogFilter.saved => controller.foodFavoriteIds.contains(food.id),
        FoodCatalogFilter.highProtein => food.protein >= 15,
        FoodCatalogFilter.light => food.calories <= 100,
      };

  int _sortFoods(FoodItem first, FoodItem second, AppController controller) {
    if (_filter == FoodCatalogFilter.recent) {
      return controller.recentFoodIds
          .indexOf(first.id)
          .compareTo(controller.recentFoodIds.indexOf(second.id));
    }
    if (_filter == FoodCatalogFilter.highProtein) {
      return second.protein.compareTo(first.protein);
    }
    return first.name.compareTo(second.name);
  }
}

class _FoodFilterBar extends StatelessWidget {
  const _FoodFilterBar({required this.selected, required this.onSelected});
  final FoodCatalogFilter selected;
  final ValueChanged<FoodCatalogFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    const labels = {
      FoodCatalogFilter.all: 'Alle',
      FoodCatalogFilter.recent: 'Zuletzt',
      FoodCatalogFilter.saved: 'Gemerkte',
      FoodCatalogFilter.highProtein: 'Proteinreich',
      FoodCatalogFilter.light: 'Leicht',
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: FoodCatalogFilter.values
            .map(
              (filter) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(labels[filter]!),
                  selected: selected == filter,
                  showCheckmark: false,
                  onSelected: (_) => onSelected(filter),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
