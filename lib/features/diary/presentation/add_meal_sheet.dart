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
    backgroundColor: AppColors.background,
    barrierColor: Colors.black.withValues(alpha: .68),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    clipBehavior: Clip.antiAlias,
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
  final TextEditingController _searchController = TextEditingController();
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const _demoFoods = [
    FoodItem(
      id: 'demo-chickpeas',
      name: 'Kichererbsen-Reis-Bowl',
      servingGrams: 100,
      calories: 410,
      protein: 17,
      carbohydrates: 62,
      fat: 11,
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
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final sheetHeight = MediaQuery.sizeOf(context).height * .94;
    final sectionTitle = _query.trim().isNotEmpty
        ? 'Suchergebnisse'
        : switch (_filter) {
            FoodCatalogFilter.all => 'Lebensmittel',
            FoodCatalogFilter.recent => 'Zuletzt verwendet',
            FoodCatalogFilter.saved => 'Gemerkte Lebensmittel',
            FoodCatalogFilter.highProtein => 'Proteinreich',
            FoodCatalogFilter.light => 'Leichte Lebensmittel',
          };

    return SizedBox(
      height: sheetHeight,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                _MealSheetHeader(
                  slot: _slot,
                  enabled: _savingFoodId == null,
                  onClose: () => Navigator.pop(context),
                  onSlotChanged: (slot) => setState(() => _slot = slot),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                  child: TextField(
                    key: const Key('food-search'),
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Lebensmittel suchen',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Suche löschen',
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MealActionCard(
                          key: const Key('scan-barcode'),
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'Barcode scannen',
                          onTap: _savingFoodId == null ? _scan : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MealActionCard(
                          key: const Key('open-custom-food'),
                          icon: Icons.edit_note_rounded,
                          label: 'Selbst eintragen',
                          onTap: _savingFoodId == null
                              ? () => Navigator.pop(context, _slot)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 15, 0, 0),
                  child: _FoodFilterBar(
                    selected: _filter,
                    onSelected: (value) => setState(() => _filter = value),
                  ),
                ),
                if (controller.catalogLoading)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 10, 18, 0),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 18, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          sectionTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      _AmountSelector(
                        value: _amountGrams,
                        enabled: _savingFoodId == null,
                        onChanged: (value) =>
                            setState(() => _amountGrams = value),
                      ),
                    ],
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _error!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                Expanded(
                  child: results.isEmpty
                      ? _EmptyFoodResults(filter: _filter, query: _query)
                      : ListView.separated(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                          itemCount: results.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final food = results[index];
                            final factor = _amountGrams / food.servingGrams;
                            return _FoodResultTile(
                              food: food,
                              calories: (food.calories * factor).round(),
                              protein: food.protein * factor,
                              amountGrams: _amountGrams,
                              saved: controller.foodFavoriteIds.contains(
                                food.id,
                              ),
                              loading: _savingFoodId == food.id,
                              enabled: _savingFoodId == null,
                              slot: _slot,
                              onOpen: () => _openDetails(food),
                              onAdd: () => _saveFood(food),
                            );
                          },
                        ),
                ),
              ],
            ),
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

class _MealSheetHeader extends StatelessWidget {
  const _MealSheetHeader({
    required this.slot,
    required this.enabled,
    required this.onClose,
    required this.onSlotChanged,
  });

  final MealSlot slot;
  final bool enabled;
  final VoidCallback onClose;
  final ValueChanged<MealSlot> onSlotChanged;

  String _label(MealSlot value) =>
      value == MealSlot.snack ? 'Snacks' : value.label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 9, 12, 0),
    child: Column(
      children: [
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.borderBright,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            IconButton.outlined(
              key: const Key('close-add-meal'),
              tooltip: 'Schließen',
              onPressed: enabled ? onClose : null,
              icon: const Icon(Icons.close_rounded),
            ),
            Expanded(
              child: Center(
                child: PopupMenuButton<MealSlot>(
                  key: ValueKey('add-slot-${slot.name}'),
                  enabled: enabled,
                  tooltip: 'Mahlzeit auswählen',
                  initialValue: slot,
                  onSelected: onSlotChanged,
                  itemBuilder: (context) => MealSlot.values
                      .map(
                        (value) => PopupMenuItem(
                          value: value,
                          child: Row(
                            children: [
                              Icon(
                                value == slot
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                size: 19,
                                color: value == slot
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 10),
                              Text(_label(value)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _label(slot),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary,
                          size: 19,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ],
    ),
  );
}

class _MealActionCard extends StatelessWidget {
  const _MealActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surfaceHigh,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        height: 76,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: onTap == null ? AppColors.textMuted : AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _AmountSelector extends StatelessWidget {
  const _AmountSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(left: 11, right: 5),
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<double>(
        key: const Key('meal-amount'),
        value: value,
        isDense: true,
        borderRadius: BorderRadius.circular(16),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 19),
        items: const [25.0, 50.0, 100.0, 150.0, 200.0, 250.0, 300.0, 500.0]
            .map(
              (grams) => DropdownMenuItem(
                value: grams,
                child: Text(
                  '${grams.toInt()} g',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            )
            .toList(),
        onChanged: enabled
            ? (next) {
                if (next != null) onChanged(next);
              }
            : null,
      ),
    ),
  );
}

class _EmptyFoodResults extends StatelessWidget {
  const _EmptyFoodResults({required this.filter, required this.query});

  final FoodCatalogFilter filter;
  final String query;

  @override
  Widget build(BuildContext context) {
    final message = query.trim().isNotEmpty
        ? 'Kein Treffer. Prüfe die Schreibweise oder trage das Lebensmittel selbst ein.'
        : switch (filter) {
            FoodCatalogFilter.recent =>
              'Noch nichts verwendet. Hinzugefügte Lebensmittel erscheinen später hier.',
            FoodCatalogFilter.saved =>
              'Noch nichts gemerkt. Speichere Lebensmittel über die Detailansicht.',
            _ => 'In diesem Bereich wurden noch keine Lebensmittel gefunden.',
          };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: AppColors.textMuted,
              size: 34,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodResultTile extends StatelessWidget {
  const _FoodResultTile({
    required this.food,
    required this.calories,
    required this.protein,
    required this.amountGrams,
    required this.saved,
    required this.loading,
    required this.enabled,
    required this.slot,
    required this.onOpen,
    required this.onAdd,
  });

  final FoodItem food;
  final int calories;
  final double protein;
  final double amountGrams;
  final bool saved;
  final bool loading;
  final bool enabled;
  final MealSlot slot;
  final VoidCallback onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surfaceHigh,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: enabled ? onOpen : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 7, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          food.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (saved) ...[
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.bookmark_rounded,
                          color: AppColors.primary,
                          size: 15,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$calories kcal · ${amountGrams.toInt()} g · ${protein.toStringAsFixed(0)} g Protein',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              key: ValueKey('add-food-${food.id}'),
              tooltip: 'Zu ${slot.label} hinzufügen',
              onPressed: enabled ? onAdd : null,
              icon: loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_rounded),
            ),
          ],
        ),
      ),
    ),
  );
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
