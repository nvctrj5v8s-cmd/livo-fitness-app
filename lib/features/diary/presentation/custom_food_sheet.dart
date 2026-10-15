import 'package:fitness_ai_app/l10n/display_text.dart';
import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

import '../../../core/data/halal_content_policy.dart';
import '../../../core/models/app_models.dart';
import '../../../core/models/custom_food.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../allergies/domain/allergy_safety.dart';
import '../../allergies/presentation/allergy_profile_field.dart';
import 'delete_entry_dialog.dart';

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
    final number = (value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toString());
    return L10n.isEnglish ? number : number.replaceAll('.', ',');
  }

  String _display(double value) => AppFormat.decimal(value, maxDecimals: 1);

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
    final controller = AppScope.of(context);
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
                        ? context.l10n.diaryYourCustomFood
                        : context.l10n.diaryEditYourEntry,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _legacy
                        ? context.l10n.diaryYourPreviousValuesApplyToOneServing
                        : context.l10n.diaryCopyTheNutritionValuesFromTheLabel,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    key: const Key('custom-name'),
                    controller: _name,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 100,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: context.l10n.diaryForExampleMyChocolateCereal,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? context.l10n.diaryPleaseGiveYourFoodAName
                        : value.trim().length > 100
                        ? context.l10n.diaryPleaseUseNoMoreThan100Characters
                        : HalalContentPolicy.restrictionReason(value.trim()),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (controller.hasAllergyProfile) ...[
                    const SizedBox(height: 10),
                    AllergySafetyNotice(
                      assessment: AllergySafety.assessText(
                        _name.text,
                        controller.allergies,
                        hasData: false,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    context.l10n.diaryForWhichMeal,
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
                    context.l10n.diaryWhatDoTheValuesReferTo,
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
                              NutritionBasis.per100g =>
                                context.l10n.diaryPer100G,
                              NutritionBasis.per100ml =>
                                context.l10n.diaryPer100Ml,
                              NutritionBasis.portion =>
                                context.l10n.diaryPerServing,
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
                      context.l10n.diaryTheLabelValuesBelowArePer100,
                    NutritionBasis.per100ml =>
                      context.l10n.diaryTheLabelValuesBelowArePer1002,
                    NutritionBasis.portion =>
                      context.l10n.diaryTheValuesBelowAreForAWhole,
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
                          ? context.l10n.diaryServingsEaten
                          : context.l10n.diaryAmountEaten,
                      suffixText: switch (_basis) {
                        NutritionBasis.per100g => 'g',
                        NutritionBasis.per100ml => 'ml',
                        NutritionBasis.portion => context.l10n.diaryServings,
                      },
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      final number = parseNutritionNumber(value ?? '');
                      return number == null || number <= 0
                          ? context.l10n.diaryPleaseEnterAnAmountGreaterThan0
                          : null;
                    },
                  ),
                  const SizedBox(height: 26),
                  Text(
                    context.l10n.diaryNutritionValuesValue(switch (_basis) {
                      NutritionBasis.per100g => context.l10n.diaryPer100G,
                      NutritionBasis.per100ml => context.l10n.diaryPer100Ml,
                      NutritionBasis.portion => context.l10n.diaryPerServing,
                    }),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _legacy
                        ? context.l10n.diaryLeaveUnknownAdditionalValuesBlank
                        : context.l10n.diaryAllLabelValuesAreRequiredFibreIs,
                  ),
                  const SizedBox(height: 16),
                  _nutrient('calories', context.l10n.diaryEnergy, 'kcal'),
                  _nutrient('fat', context.l10n.diaryFat, 'g'),
                  _nutrient(
                    'saturated',
                    context.l10n.diaryOfWhichSaturates,
                    'g',
                    optional: _legacy,
                  ),
                  _nutrient('carbs', context.l10n.diaryCarbohydrates, 'g'),
                  _nutrient(
                    'sugar',
                    context.l10n.diaryOfWhichSugars,
                    'g',
                    optional: _legacy,
                  ),
                  _nutrient('protein', context.l10n.diaryProtein, 'g'),
                  _nutrient(
                    'salt',
                    context.l10n.diarySalt,
                    'g',
                    optional: _legacy,
                  ),
                  _nutrient(
                    'fiber',
                    context.l10n.diaryFibreOptional,
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
                            context.l10n.diaryForTheAmountYouAte,
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
                                  context.l10n.diaryValueGProtein(
                                    (_display(preview.totalProtein)).toString(),
                                  ),
                                ),
                                Text(
                                  context.l10n.diaryValueGCarbs(
                                    (_display(
                                      preview.totalCarbohydrates,
                                    )).toString(),
                                  ),
                                ),
                                Text(
                                  context.l10n.diaryValueGFat(
                                    (_display(preview.totalFat)).toString(),
                                  ),
                                ),
                              ],
                            ),
                          ] else
                            Text(
                              context.l10n.diaryOnceYouEnterTheAmountEnergyAnd,
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
                            ? context.l10n.diarySaving
                            : widget.entry == null
                            ? context.l10n.diaryLogInDiary
                            : context.l10n.diarySaveChanges,
                      ),
                    ),
                  ),
                  if (widget.entry != null) ...[
                    const SizedBox(height: 8),
                    DeleteEntryButton(onPressed: _saving ? null : _delete),
                  ],
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
            hintText: optional
                ? L10n.current.diaryUnknown
                : L10n.current.diaryEG05,
            suffixText: unit,
            errorMaxLines: 3,
          ),
          onChanged: (_) => setState(() {}),
          validator: (text) {
            if (optional && (text ?? '').trim().isEmpty) return null;
            final value = parseNutritionNumber(text ?? '');
            if (value == null) {
              return L10n.current.diaryPleaseEnterAValidValueOf0;
            }
            if (key == 'sugar') {
              final carbs = parseNutritionNumber(_fields['carbs']!.text);
              if (carbs != null && value > carbs) {
                return L10n.current.diarySugarCannotExceedCarbohydrates;
              }
            }
            if (key == 'saturated') {
              final fat = parseNutritionNumber(_fields['fat']!.text);
              if (fat != null && value > fat) {
                return L10n.current.diarySaturatedFatCannotExceedTotalFat;
              }
            }
            return null;
          },
        ),
      ],
    ),
  );

  Future<void> _delete() async {
    final entry = widget.entry;
    if (_saving || entry == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final deleted = await confirmDeleteDiaryEntry(context, entry);
    if (!mounted) return;
    if (deleted) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _saving = false;
      _error = AppScope.of(context).diaryError;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) {
      setState(
        () => _error = L10n.current.diaryPleaseCheckTheHighlightedFieldsAbove,
      );
      return;
    }
    final nutrition = _readNutrition()!;
    final error = nutrition.validate(requireLabelValues: !_legacy);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final controller = AppScope.of(context);
    final assessment = AllergySafety.assessText(
      _name.text,
      controller.allergies,
      hasData: false,
    );
    if (assessment.hasConflict) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(L10n.current.diaryAllergyNotice),
          content: Text(
            L10n.current.diaryTheNameYouEnteredSuggestsAPossible(
              (assessment.conflicts.map(DisplayText.of).join(', ')).toString(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(L10n.current.diaryCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(L10n.current.diaryLogAnyway),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
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
              L10n.current.diarySavingDidNotWorkYourInformationStays;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = L10n.current.diarySavingDidNotWorkPleaseTryAgain;
        });
      }
    }
  }
}
