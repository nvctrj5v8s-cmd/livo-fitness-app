import 'package:fitness_ai_app/l10n/l10n.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/recipe_serving.dart';
import 'recipe_card.dart';
import 'recipe_format.dart';

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle(this.title, {this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
      IconButton(
        onPressed: () => Navigator.pop(context),
        tooltip: context.l10n.discoverClose,
        icon: const Icon(Icons.close_rounded),
      ),
    ],
  );
}

IconData _slotIcon(MealSlot slot) => switch (slot) {
  MealSlot.breakfast => Icons.wb_sunny_outlined,
  MealSlot.lunch => Icons.lunch_dining_outlined,
  MealSlot.dinner => Icons.dinner_dining_outlined,
  MealSlot.snack => Icons.cookie_outlined,
};

/// Asks for the diary meal; the suggestion is marked with text.
Future<MealSlot?> showMealSlotSheet(
  BuildContext context, {
  required Recipe recipe,
  required MealSlot suggested,
}) {
  return showModalBottomSheet<MealSlot>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => _SheetBody(
      children: [
        _SheetTitle(
          context.l10n.discoverWhichMeal,
          subtitle: context.l10n.discover1ServingValueKcalValueGProtein(
            (recipe.calories).toString(),
            (recipe.protein).toString(),
          ),
        ),
        const SizedBox(height: 14),
        for (final slot in [
          suggested,
          ...MealSlot.values.where((slot) => slot != suggested),
        ]) ...[
          _SlotTile(
            slot: slot,
            suggested: slot == suggested,
            onTap: () => Navigator.pop(sheetContext, slot),
          ),
          const SizedBox(height: 8),
        ],
      ],
    ),
  );
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.suggested,
    required this.onTap,
  });

  final MealSlot slot;
  final bool suggested;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: suggested ? AppColors.surfaceSoft : AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: ValueKey('meal-slot-${slot.databaseValue}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: suggested ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _slotIcon(slot),
                color: suggested ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  slot.label,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (suggested)
                Text(
                  context.l10n.discoverSuggestion,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalcRow extends StatelessWidget {
  const _CalcRow(this.label, this.value, {this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: strong ? AppColors.text : AppColors.textMuted,
                fontSize: 14,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Plus: explains the portion suggestion. Returns `true` to apply it.
Future<bool?> showGoalSuggestionSheet(
  BuildContext context, {
  required Recipe recipe,
  required PortionSuggestion suggestion,
}) {
  final perPortion = recipe.nutrition;
  final factor = suggestion.factor;
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => _SheetBody(
      children: [
        _SheetTitle(context.l10n.discoverAdaptToMyTarget),
        const SizedBox(height: 10),
        Text(
          suggestion.goalReached
              ? context.l10n.discoverYourDiaryShowsYouHaveAlreadyReached
              : context.l10n.discoverThisServingSizeIsASuggestionTo,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 15,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          key: const Key('goal-suggestion-result'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.discoverSuggestionEstimate,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                portionsLabel(factor),
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.discoverApproxValueValueProtein(
                  (formatKcal(perPortion.calories * factor)).toString(),
                  (formatNutrientGrams(perPortion.protein * factor)).toString(),
                ),
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          context.l10n.discoverHowThisSuggestionWasCalculated,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        _CalcRow(
          context.l10n.discoverYourDailyTarget,
          '${formatThousandsDe(suggestion.calorieGoal)} kcal',
        ),
        _CalcRow(
          context.l10n.discoverLoggedToday,
          '${formatThousandsDe(suggestion.consumedCalories)} kcal',
        ),
        _CalcRow(
          context.l10n.discoverRemaining,
          '${formatThousandsDe(math.max(0, suggestion.remainingCalories))} kcal',
        ),
        _CalcRow(
          context.l10n.discoverMealsStillToComeToday,
          context.l10n.discoverApproxValue((suggestion.mealsLeft).toString()),
        ),
        _CalcRow(
          context.l10n.discoverForThisMeal,
          context.l10n.discoverApproxValueKcal(
            (formatThousandsDe(suggestion.mealBudget)).toString(),
          ),
          strong: true,
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.discoverBasedOnValueMealsADayWith(
            (suggestion.mealsPerDay).toString(),
            (suggestion.mealsLogged).toString(),
          ),
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(sheetContext, false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(52, 54),
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: AppColors.borderBright),
                ),
                child: Text(context.l10n.discoverClose),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                key: const Key('goal-suggestion-apply'),
                onPressed: () => Navigator.pop(sheetContext, true),
                child: Text(context.l10n.discoverApply),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Free accounts: explains the Plus goal feature. "Jetzt nicht" is as large
/// as the Plus button. Returns `true` when the paywall should open.
Future<bool?> showGoalLockedSheet(
  BuildContext context, {
  required bool trialAvailable,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => _SheetBody(
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RecipePlusBadge(),
                  SizedBox(height: 6),
                  Text(
                    context.l10n.discoverAdaptToMyTarget,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.discoverWithValueLookinSuggestsAServingSize(
            (recipePlusLabel).toString(),
          ),
          style: TextStyle(color: AppColors.text, fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.discoverTheServingCalculatorAndAllNutritionValues,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                key: const Key('goal-locked-dismiss'),
                onPressed: () => Navigator.pop(sheetContext, false),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.surfaceSoft,
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: AppColors.borderBright),
                ),
                child: Text(context.l10n.discoverNotNow),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                key: const Key('goal-locked-open'),
                onPressed: () => Navigator.pop(sheetContext, true),
                child: Text(
                  trialAvailable
                      ? context.l10n.discoverTryValue(
                          (recipePlusLabel).toString(),
                        )
                      : context.l10n.discoverViewValue(
                          (recipePlusLabel).toString(),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
