import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import 'custom_food_sheet.dart';
import 'delete_entry_dialog.dart';

Future<void> showEditMealSheet(BuildContext context, MealEntry entry) {
  if (entry.isCustom) {
    return showCustomMealSheet(
      context,
      date: AppScope.of(context).diaryDate,
      initialSlot: entry.slot,
      entry: entry,
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _EditMealSheet(entry: entry),
  );
}

class _EditMealSheet extends StatefulWidget {
  const _EditMealSheet({required this.entry});

  final MealEntry entry;

  @override
  State<_EditMealSheet> createState() => _EditMealSheetState();
}

class _EditMealSheetState extends State<_EditMealSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _calorieController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbController;
  late final TextEditingController _fatController;
  late MealSlot _slot;
  late double _amountGrams;
  DateTime? _selectedDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _nameController = TextEditingController(text: entry.name);
    _calorieController = TextEditingController(text: entry.calories.toString());
    _proteinController = TextEditingController(text: entry.protein.toString());
    _carbController = TextEditingController(text: entry.carbs.toString());
    _fatController = TextEditingController(text: entry.fat.toString());
    _slot = entry.slot;
    _amountGrams = entry.amountGrams ?? 100;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _calorieController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final selectedDate = _selectedDate ?? AppScope.of(context).diaryDate;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.isRecipe
                  ? context.l10n.diaryEditRecipe
                  : context.l10n.diaryEditMeal,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              entry.isRecipe
                  ? context.l10n.diaryYouCanChangeTheMealTypeIngredients
                  : context.l10n.diaryChangesAreSavedDirectlyToYourDiary,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            if (entry.isCustom) ...[
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: context.l10n.diaryMealName,
                ),
              ),
              const SizedBox(height: 16),
            ] else
              _ReadOnlyName(name: entry.displayName, isRecipe: entry.isRecipe),
            Text(
              context.l10n.diaryMeal,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            _EditSlotPicker(
              selected: _slot,
              onSelected: (value) => setState(() => _slot = value),
            ),
            const SizedBox(height: 18),
            Text(
              context.l10n.diaryDay,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _saving ? null : _pickDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(AppFormat.date(selectedDate)),
            ),
            if (entry.foodId != null) ...[
              const SizedBox(height: 18),
              Text(
                context.l10n.diaryAmount,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _amountOptions(entry.amountGrams).map((grams) {
                  final selected = grams == _amountGrams;
                  return ChoiceChip(
                    label: Text('${grams.toInt()} g'),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _amountGrams = grams),
                  );
                }).toList(),
              ),
            ],
            if (entry.isCustom) ...[
              const SizedBox(height: 18),
              Text(
                context.l10n.diaryNutrition,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      controller: _calorieController,
                      label: 'kcal',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _NumberField(
                      controller: _proteinController,
                      label: 'Protein g',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      controller: _carbController,
                      label: context.l10n.diaryCarbsG,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _NumberField(
                      controller: _fatController,
                      label: context.l10n.diaryFatG,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : _duplicate,
                    icon: const Icon(Icons.copy_rounded),
                    label: Text(context.l10n.diaryDuplicate),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(context.l10n.diarySave),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DeleteEntryButton(onPressed: _saving ? null : _delete),
          ],
        ),
      ),
    );
  }

  Future<void> _delete() async {
    setState(() => _saving = true);
    final deleted = await confirmDeleteDiaryEntry(context, widget.entry);
    if (!mounted) return;
    setState(() => _saving = false);
    if (!deleted) {
      final error = AppScope.of(context).diaryError;
      if (error != null) _showError(error);
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(L10n.current.diaryEntryDeleted)));
  }

  List<double> _amountOptions(double? current) {
    final options = <double>[25, 50, 75, 100, 150, 200, 250, 300, 400, 500];
    if (current != null && !options.contains(current)) options.add(current);
    options.sort();
    return options;
  }

  Future<void> _save() async {
    final entry = widget.entry;
    final calories = int.tryParse(_calorieController.text.trim());
    final protein = int.tryParse(_proteinController.text.trim());
    final carbs = int.tryParse(_carbController.text.trim());
    final fat = int.tryParse(_fatController.text.trim());
    if (entry.isCustom &&
        (_nameController.text.trim().isEmpty ||
            calories == null ||
            protein == null ||
            carbs == null ||
            fat == null ||
            calories < 0 ||
            protein < 0 ||
            carbs < 0 ||
            fat < 0)) {
      _showError(L10n.current.diaryPleaseEnterANameAndValidPositive);
      return;
    }
    setState(() => _saving = true);
    final saved = await AppScope.of(context).updateDiaryEntry(
      entry,
      slot: _slot,
      amountGrams: entry.foodId == null ? null : _amountGrams,
      name: entry.isCustom ? _nameController.text : null,
      calories: entry.isCustom ? calories : null,
      protein: entry.isCustom ? protein : null,
      carbs: entry.isCustom ? carbs : null,
      fat: entry.isCustom ? fat : null,
      date: _selectedDate ?? AppScope.of(context).diaryDate,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (!saved) {
      _showError(
        AppScope.of(context).diaryError ??
            L10n.current.diaryTheMealCouldNotBeSaved,
      );
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(L10n.current.diaryMealUpdated)));
  }

  Future<void> _duplicate() async {
    setState(() => _saving = true);
    final copied = await AppScope.of(
      context,
    ).duplicateDiaryEntry(widget.entry, date: _selectedDate);
    if (!mounted) return;
    setState(() => _saving = false);
    if (!copied) {
      _showError(
        AppScope.of(context).diaryError ??
            L10n.current.diaryTheMealCouldNotBeDuplicated,
      );
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(L10n.current.diaryMealDuplicated)));
  }

  Future<void> _pickDate() async {
    final initialDate = _selectedDate ?? AppScope.of(context).diaryDate;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: L10n.current.diaryMoveMeal,
    );
    if (date != null && mounted) setState(() => _selectedDate = date);
  }

  void _showError(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

class _ReadOnlyName extends StatelessWidget {
  const _ReadOnlyName({required this.name, required this.isRecipe});

  final String name;
  final bool isRecipe;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Icon(
          isRecipe ? Icons.menu_book_rounded : Icons.restaurant_rounded,
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(labelText: label),
  );
}

class _EditSlotPicker extends StatelessWidget {
  const _EditSlotPicker({required this.selected, required this.onSelected});

  final MealSlot selected;
  final ValueChanged<MealSlot> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: MealSlot.values
          .map(
            (slot) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(slot.label),
                selected: selected == slot,
                showCheckmark: false,
                onSelected: (_) => onSelected(slot),
              ),
            ),
          )
          .toList(),
    ),
  );
}
