import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/models/custom_food.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';

Future<void> showCustomMealSheet(
  BuildContext context, {
  DateTime? date,
  MealSlot initialSlot = MealSlot.snack,
  MealEntry? entry,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => CustomFoodSheet(
    date: date ?? DateTime.now(),
    initialSlot: initialSlot,
    entry: entry,
  ),
);

/// The same editor creates and updates custom foods, preserving label values.
class CustomFoodSheet extends StatefulWidget {
  const CustomFoodSheet({
    required this.date,
    this.initialSlot = MealSlot.snack,
    this.entry,
    super.key,
  });

  final DateTime date;
  final MealSlot initialSlot;
  final MealEntry? entry;

  @override
  State<CustomFoodSheet> createState() => _CustomFoodSheetState();
}

class _CustomFoodSheetState extends State<CustomFoodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _fields = <String, TextEditingController>{
    for (final name in [
      'calories',
      'fat',
      'saturated',
      'carbs',
      'sugar',
      'protein',
      'salt',
      'fiber',
    ])
      name: TextEditingController(),
  };
  late MealSlot _slot;
  NutritionBasis _basis = NutritionBasis.per100g;
  bool _saving = false;
  String? _error;

  bool get _legacy =>
      widget.entry != null && widget.entry!.customNutrition == null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _slot = entry?.slot ?? widget.initialSlot;
    _name.text = entry?.name ?? '';
    final nutrition =
        entry?.customNutrition ??
        (entry == null
            ? null
            : CustomFoodNutrition(
                basis: NutritionBasis.portion,
                amount: 1,
                calories: entry.calories.toDouble(),
                protein: entry.protein.toDouble(),
                carbohydrates: entry.carbs.toDouble(),
                fat: entry.fat.toDouble(),
              ));
    _basis = nutrition?.basis ?? NutritionBasis.per100g;
    _amount.text = _number(nutrition?.amount ?? 100);
    if (nutrition != null) {
      final values = <String, double?>{
        'calories': nutrition.calories,
        'fat': nutrition.fat,
        'saturated': nutrition.saturatedFat,
        'carbs': nutrition.carbohydrates,
        'sugar': nutrition.sugar,
        'protein': nutrition.protein,
        'salt': nutrition.salt,
        'fiber': nutrition.fiber,
      };
      for (final item in values.entries) {
        _fields[item.key]!.text = item.value == null
            ? ''
            : _number(item.value!);
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _scrollController.dispose();
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _number(double value) {
    // Keep the entire stored decimal value when opening an existing entry.
    return (value == value.truncateToDouble()
            ? value.toInt().toString()
            : value.toString())
        .replaceAll('.', ',');
  }

  String _display(double value) => value
      .toStringAsFixed(value == value.roundToDouble() ? 0 : 1)
      .replaceAll('.', ',');

  CustomFoodNutrition? _readNutrition() {
    final amount = parseNutritionNumber(_amount.text);
    final calories = parseNutritionNumber(_fields['calories']!.text);
    final protein = parseNutritionNumber(_fields['protein']!.text);
    final carbs = parseNutritionNumber(_fields['carbs']!.text);
    final fat = parseNutritionNumber(_fields['fat']!.text);
    if (amount == null ||
        calories == null ||
        protein == null ||
        carbs == null ||
        fat == null) {
      return null;
    }
    return CustomFoodNutrition(
      basis: _basis,
      amount: amount,
      calories: calories,
      protein: protein,
      carbohydrates: carbs,
      fat: fat,
      sugar: parseNutritionNumber(_fields['sugar']!.text),
      saturatedFat: parseNutritionNumber(_fields['saturated']!.text),
      salt: parseNutritionNumber(_fields['salt']!.text),
      fiber: parseNutritionNumber(_fields['fiber']!.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = _readNutrition();
    final previewValid = preview != null && preview.validate() == null;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return PopScope(
      canPop: !_saving,
      child: SingleChildScrollView(
        controller: _scrollController,
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.entry == null
                        ? 'Dein eigenes Lebensmittel'
                        : 'Deinen Eintrag bearbeiten',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _legacy
                        ? 'Deine bisherigen Werte gelten für eine Portion. Fehlende Etikettwerte kannst du ergänzen.'
                        : 'Übernimm die Nährwerte vom Etikett. Wir rechnen deine gegessene Menge automatisch aus.',
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    key: const Key('custom-name'),
                    controller: _name,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Zum Beispiel: Mein Schoko-Müsli',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Bitte deinem Lebensmittel einen Namen geben.'
                        : value.trim().length > 100
                        ? 'Bitte höchstens 100 Zeichen verwenden.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Für welche Mahlzeit?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MealSlot.values
                        .map(
                          (slot) => ChoiceChip(
                            key: ValueKey('custom-slot-${slot.name}'),
                            label: Text(
                              slot == MealSlot.snack ? 'Snacks' : slot.label,
                            ),
                            selected: _slot == slot,
                            showCheckmark: true,
                            onSelected: _saving
                                ? null
                                : (_) => setState(() => _slot = slot),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Worauf beziehen sich die Werte?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: NutritionBasis.values
                        .map(
                          (basis) => ChoiceChip(
                            key: ValueKey('custom-basis-${basis.name}'),
                            label: Text(switch (basis) {
                              NutritionBasis.per100g => 'Pro 100 g',
                              NutritionBasis.per100ml => 'Pro 100 ml',
                              NutritionBasis.portion => 'Pro Portion',
                            }),
                            selected: basis == _basis,
                            onSelected: _saving
                                ? null
                                : (_) => setState(() {
                                    if (basis == _basis) return;
                                    // A portion count and a gram amount are not interchangeable.
                                    if (basis == NutritionBasis.portion) {
                                      _amount.text = '1';
                                    }
                                    if (_basis == NutritionBasis.portion &&
                                        basis != NutritionBasis.portion) {
                                      _amount.text = '100';
                                    }
                                    _basis = basis;
                                  }),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  Text(switch (_basis) {
                    NutritionBasis.per100g =>
                      'Unten stehen die Etikettwerte pro 100 g.',
                    NutritionBasis.per100ml =>
                      'Unten stehen die Etikettwerte pro 100 ml.',
                    NutritionBasis.portion =>
                      'Unten stehen die Werte für eine ganze Portion. Eine halbe Portion ist 0,5.',
                  }),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('custom-amount'),
                    controller: _amount,
                    enabled: !_saving,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: _basis == NutritionBasis.portion
                          ? 'Gegessene Portionen'
                          : 'Gegessene Menge',
                      suffixText: switch (_basis) {
                        NutritionBasis.per100g => 'g',
                        NutritionBasis.per100ml => 'ml',
                        NutritionBasis.portion => 'Portionen',
                      },
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      final number = parseNutritionNumber(value ?? '');
                      return number == null || number <= 0
                          ? 'Bitte eine Menge größer als 0 eingeben.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Nährwerte ${switch (_basis) {
                      NutritionBasis.per100g => 'pro 100 g',
                      NutritionBasis.per100ml => 'pro 100 ml',
                      NutritionBasis.portion => 'pro Portion',
                    }}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _legacy
                        ? 'Unbekannte Zusatzwerte bleiben leer.'
                        : 'Alle Etikettwerte sind erforderlich. Ballaststoffe sind freiwillig.',
                  ),
                  const SizedBox(height: 16),
                  _nutrient('calories', 'Energie', 'kcal'),
                  _nutrient('fat', 'Fett', 'g'),
                  _nutrient(
                    'saturated',
                    'davon gesättigte Fettsäuren',
                    'g',
                    optional: _legacy,
                  ),
                  _nutrient('carbs', 'Kohlenhydrate', 'g'),
                  _nutrient('sugar', 'davon Zucker', 'g', optional: _legacy),
                  _nutrient('protein', 'Eiweiß / Protein', 'g'),
                  _nutrient('salt', 'Salz', 'g', optional: _legacy),
                  _nutrient(
                    'fiber',
                    'Ballaststoffe (optional)',
                    'g',
                    optional: true,
                  ),
                  const SizedBox(height: 8),
                  AnimatedSize(
                    duration: reducedMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    alignment: Alignment.topCenter,
                    child: Container(
                      key: const Key('custom-preview'),
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .08),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: .22),
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Für deine gegessene Menge',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (previewValid) ...[
                            Text(
                              '${_display(preview.totalCalories)} kcal',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: AppColors.primary),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 14,
                              runSpacing: 6,
                              children: [
                                Text(
                                  '${_display(preview.totalProtein)} g Protein',
                                ),
                                Text(
                                  '${_display(preview.totalCarbohydrates)} g Kohlenhydrate',
                                ),
                                Text('${_display(preview.totalFat)} g Fett'),
                              ],
                            ),
                          ] else
                            const Text(
                              'Sobald Menge, Energie und Makros eingetragen sind, siehst du hier die Berechnung.',
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('custom-save'),
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(
                        _saving
                            ? 'Wird gespeichert …'
                            : widget.entry == null
                            ? 'Ins Tagebuch eintragen'
                            : 'Änderungen speichern',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nutrient(
    String key,
    String label,
    String unit, {
    bool optional = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.text)),
        const SizedBox(height: 6),
        TextFormField(
          key: ValueKey('custom-$key'),
          controller: _fields[key],
          enabled: !_saving,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: optional ? 'Nicht bekannt' : 'z. B. 0,5',
            suffixText: unit,
            errorMaxLines: 3,
          ),
          onChanged: (_) => setState(() {}),
          validator: (text) {
            if (optional && (text ?? '').trim().isEmpty) return null;
            final value = parseNutritionNumber(text ?? '');
            if (value == null) {
              return 'Bitte einen gültigen Wert ab 0 eingeben.';
            }
            if (key == 'sugar') {
              final carbs = parseNutritionNumber(_fields['carbs']!.text);
              if (carbs != null && value > carbs) {
                return 'Zucker darf die Kohlenhydrate nicht überschreiten.';
              }
            }
            if (key == 'saturated') {
              final fat = parseNutritionNumber(_fields['fat']!.text);
              if (fat != null && value > fat) {
                return 'Gesättigte Fettsäuren dürfen Fett nicht überschreiten.';
              }
            }
            return null;
          },
        ),
      ],
    ),
  );

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) {
      setState(() => _error = 'Bitte prüfe die markierten Felder weiter oben.');
      return;
    }
    final nutrition = _readNutrition()!;
    final error = nutrition.validate(requireLabelValues: !_legacy);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    final controller = AppScope.of(context);
    try {
      final saved = widget.entry == null
          ? await controller.addCustomFoodToDiary(
              name: _name.text.trim(),
              slot: _slot,
              nutrition: nutrition,
              date: widget.date,
            )
          : await controller.updateDiaryEntry(
              widget.entry!,
              name: _name.text.trim(),
              slot: _slot,
              customNutrition: nutrition,
              date: widget.date,
            );
      if (!mounted) return;
      if (saved) {
        // No extra confirmation overlay: the diary entry itself is the result.
        setState(() => _saving = false);
        Navigator.pop(context);
      } else {
        setState(() {
          _saving = false;
          _error =
              controller.diaryError ??
              'Das Speichern hat nicht geklappt. Deine Angaben bleiben hier erhalten.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error =
              'Das Speichern hat nicht geklappt. Bitte versuche es erneut.';
        });
      }
    }
  }
}
