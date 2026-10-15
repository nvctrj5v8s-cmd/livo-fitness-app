import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:fitness_ai_app/l10n/catalog_text.dart';
import 'package:fitness_ai_app/l10n/display_text.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../subscription/domain/subscription_plans.dart';
import '../domain/recipe_filter.dart' show recipeForYouTag;
import '../domain/recipe_serving.dart';
import 'recipe_card.dart';
import 'recipe_filters.dart' show RecipeChoiceChip;
import 'recipe_format.dart';

bool _reduceMotion(BuildContext context) =>
    MediaQuery.maybeOf(context)?.disableAnimations ?? false;

double _textScale(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(14) / 14;

/// Section title in the style of `SectionHeader`, with optional count.
class DetailSectionTitle extends StatelessWidget {
  const DetailSectionTitle(this.title, {this.trailing, super.key});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              trailing!,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, {this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Tags, title and description.
class RecipeIntro extends StatelessWidget {
  const RecipeIntro({required this.recipe, super.key});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final tags = [
      for (final tag in recipe.tags)
        if (tag != recipeForYouTag) DisplayText.of(tag),
    ];
    final compact = MediaQuery.sizeOf(context).width < 600;
    final description = recipe.displaySubtitle.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recipe.isPremium || tags.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (recipe.isPremium) const RecipePlusBadge(),
              for (final tag in tags) _Pill(tag),
            ],
          ),
          const SizedBox(height: 14),
        ],
        Semantics(
          header: true,
          child: Text(
            recipe.displayTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontSize: compact ? 30 : 38),
          ),
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

/// Times, difficulty and base portions at a glance.
class RecipeFactsCard extends StatelessWidget {
  const RecipeFactsCard({required this.recipe, super.key});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final prep = recipe.prepMinutes ?? 0;
    final cook = recipe.cookMinutes ?? 0;
    final servings = math.max(1, recipe.servings);
    final facts = <(IconData, String, String)>[
      if (recipe.minutes > 0)
        (
          Icons.schedule_rounded,
          formatMinutes(recipe.minutes),
          context.l10n.discoverTotalTime,
        ),
      if (prep > 0)
        (
          Icons.content_cut_rounded,
          formatMinutes(prep),
          context.l10n.discoverPreparation,
        ),
      if (cook > 0)
        (
          Icons.soup_kitchen_outlined,
          formatMinutes(cook),
          context.l10n.discoverCooking,
        ),
      (
        difficultyIcon(recipe.difficulty),
        recipe.displayDifficulty,
        context.l10n.discoverDifficulty,
      ),
      (
        Icons.people_outline_rounded,
        '$servings',
        servings == 1
            ? context.l10n.discoverServing
            : context.l10n.discoverServings,
      ),
    ];
    final textScale = _textScale(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        var columns = width >= 560
            ? facts.length
            : width / textScale < 300
            ? 2
            : facts.length == 4
            ? 2
            : 3;
        columns = math.min(columns, facts.length);
        const gap = 8.0;
        final tileWidth = (width - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (icon, value, label) in facts)
              SizedBox(
                width: tileWidth,
                child: _FactTile(icon: icon, value: value, label: label),
              ),
          ],
        );
      },
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 19, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full nutrition for everyone: per portion or for the chosen portions.
class RecipeNutritionCard extends StatelessWidget {
  const RecipeNutritionCard({
    required this.recipe,
    required this.portions,
    required this.showTotal,
    required this.onShowTotal,
    super.key,
  });

  final Recipe recipe;
  final double portions;
  final bool showTotal;
  final ValueChanged<bool> onShowTotal;

  @override
  Widget build(BuildContext context) {
    final perPortion = recipe.nutrition;
    final known = recipe.nutritionPerServing != null;
    final total = showTotal && portions != 1;
    final values = total ? perPortion.scaled(portions) : perPortion;
    final hasDetails =
        known && (perPortion.fiber + perPortion.sugar + perPortion.salt) > 0;
    return SurfaceCard(
      key: const Key('recipe-nutrition'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.discoverNutrition,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _Pill(
                context.l10n.discoverGuidelineValues,
                icon: Icons.info_outline_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (portions != 1)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                RecipeChoiceChip(
                  key: const Key('nutrition-per-portion'),
                  label: context.l10n.discoverPerServing,
                  selected: !total,
                  onSelected: () => onShowTotal(false),
                ),
                RecipeChoiceChip(
                  key: const Key('nutrition-total'),
                  label: context.l10n.discoverForValue(
                    (portionsLabel(portions)).toString(),
                  ),
                  selected: total,
                  onSelected: () => onShowTotal(true),
                ),
              ],
            )
          else
            Text(
              context.l10n.discoverPerServing,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          const SizedBox(height: 14),
          _MacroTiles(values: values, known: known),
          if (known) ...[
            const SizedBox(height: 16),
            _MacroSplit(nutrition: perPortion),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 6),
          _NutrientRow(
            label: context.l10n.discoverFibre,
            value: hasDetails ? formatNutrientGrams(values.fiber) : '–',
          ),
          _NutrientRow(
            label: context.l10n.discoverSugar,
            value: hasDetails ? formatNutrientGrams(values.sugar) : '–',
          ),
          _NutrientRow(
            label: context.l10n.discoverSalt,
            value: hasDetails ? formatSaltGrams(values.salt) : '–',
          ),
          const SizedBox(height: 10),
          Text(
            known
                ? context.l10n.discoverCalculatedFromTheIngredientsValuesMayVary
                : context
                      .l10n
                      .discoverRoughGuidelineValuesACompleteCalculationBased,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroTiles extends StatelessWidget {
  const _MacroTiles({required this.values, required this.known});

  final RecipeNutrition values;
  final bool known;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      (
        Icons.local_fire_department_rounded,
        AppColors.orange,
        context.l10n.discoverEnergy,
        formatKcal(values.calories),
      ),
      (
        Icons.egg_alt_rounded,
        AppColors.mint,
        'Protein',
        formatNutrientGrams(values.protein),
      ),
      (
        Icons.grain_rounded,
        AppColors.blue,
        context.l10n.discoverCarbohydrates,
        known ? formatNutrientGrams(values.carbohydrates) : '–',
      ),
      (
        Icons.water_drop_outlined,
        AppColors.purple,
        context.l10n.discoverFat,
        known ? formatNutrientGrams(values.fat) : '–',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 440 ? 4 : 2;
        const gap = 8.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (icon, color, label, value) in tiles)
              SizedBox(
                width: width,
                child: MergeSemantics(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 11, 10, 12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withValues(alpha: 0.24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(icon, size: 16, color: color),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          value,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MacroSplit extends StatelessWidget {
  const _MacroSplit({required this.nutrition});

  final RecipeNutrition nutrition;

  @override
  Widget build(BuildContext context) {
    final parts = [
      ('Protein', AppColors.mint, nutrition.protein * 4),
      (
        context.l10n.discoverCarbohydrates,
        AppColors.blue,
        nutrition.carbohydrates * 4,
      ),
      (context.l10n.discoverFat, AppColors.purple, nutrition.fat * 9),
    ];
    final total = parts.fold<double>(0, (sum, part) => sum + part.$3);
    if (total <= 0) return const SizedBox.shrink();
    int percent(double value) => (value / total * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.discoverEnergyShare,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ExcludeSemantics(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  for (final (index, part) in parts.indexed)
                    if (part.$3 > 0) ...[
                      if (index > 0) const SizedBox(width: 2),
                      Expanded(
                        flex: math.max(1, (part.$3 / total * 1000).round()),
                        child: ColoredBox(color: part.$2),
                      ),
                    ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            for (final (label, color, energy) in parts)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Large system fonts must wrap instead of overflowing.
                  Flexible(
                    child: Text(
                      '$label ${percent(energy)} %',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.text, fontSize: 14),
            ),
          ),
          Text(
            value,
            semanticsLabel: value == '–'
                ? context.l10n.discoverNotSpecified
                : null,
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

/// Kitchen tools needed for the recipe.
class RecipeEquipmentSection extends StatelessWidget {
  const RecipeEquipmentSection({required this.equipment, super.key});

  final List<String> equipment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailSectionTitle(context.l10n.discoverEquipment),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in equipment)
              _Pill(item, icon: Icons.flatware_rounded),
          ],
        ),
      ],
    );
  }
}

/// Free portion calculator with an optional goal action below.
class PortionCalculator extends StatelessWidget {
  const PortionCalculator({
    required this.portions,
    required this.basePortions,
    required this.onChanged,
    this.goalAction,
    super.key,
  });

  final double portions;
  final double basePortions;
  final ValueChanged<double> onChanged;
  final Widget? goalAction;

  @override
  Widget build(BuildContext context) {
    final whole = portions == portions.roundToDouble();
    final less = whole ? portions - 1 : portions.floorToDouble();
    final more = whole ? portions + 1 : portions.ceilToDouble();
    final canLess = less >= minRecipePortions;
    final canMore = more <= maxRecipePortions;
    final changed = portions != basePortions;
    return SurfaceCard(
      key: const Key('portion-calculator'),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.discoverServings,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    changed
                        ? 'Original: ${portionsLabel(basePortions)}'
                        : context.l10n.discoverAsInTheOriginalRecipe,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepButton(
                    icon: Icons.remove_rounded,
                    tooltip: context.l10n.discoverOneServingLess,
                    onPressed: canLess ? () => onChanged(less) : null,
                  ),
                  SizedBox(
                    width: 62,
                    child: Semantics(
                      liveRegion: true,
                      label: portionsLabel(portions),
                      child: ExcludeSemantics(
                        child: Text(
                          formatFractionDe(portions),
                          key: const Key('recipe-portions-value'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _StepButton(
                    icon: Icons.add_rounded,
                    tooltip: context.l10n.discoverOneServingMore,
                    onPressed: canMore ? () => onChanged(more) : null,
                  ),
                ],
              ),
            ],
          ),
          if (changed)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => onChanged(basePortions),
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: Text(context.l10n.discoverOriginalAmount),
              ),
            ),
          if (goalAction != null) ...[
            const SizedBox(height: 4),
            const Divider(height: 1),
            const SizedBox(height: 4),
            Align(alignment: Alignment.centerLeft, child: goalAction),
          ],
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    tooltip: tooltip,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      minimumSize: const Size(46, 46),
      backgroundColor: AppColors.surfaceSoft,
      foregroundColor: AppColors.text,
      disabledBackgroundColor: AppColors.surfaceHigh,
      disabledForegroundColor: AppColors.textMuted.withValues(alpha: 0.5),
    ),
    icon: Icon(icon),
  );
}

/// Ingredient list with local check marks.
class RecipeIngredientsSection extends StatelessWidget {
  const RecipeIngredientsSection({
    required this.ingredients,
    required this.calculator,
    required this.checked,
    required this.onToggle,
    required this.onClearChecks,
    super.key,
  });

  final List<ScaledIngredient> ingredients;
  final Widget calculator;
  final Set<int> checked;
  final ValueChanged<int> onToggle;
  final VoidCallback onClearChecks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailSectionTitle(
          context.l10n.discoverIngredients,
          trailing: ingredients.isEmpty
              ? null
              : ingredients.length == 1
              ? context.l10n.discover1Ingredient
              : context.l10n.discoverValueIngredients(
                  (ingredients.length).toString(),
                ),
        ),
        const SizedBox(height: 12),
        calculator,
        const SizedBox(height: 12),
        if (ingredients.isEmpty)
          SurfaceCard(
            child: Text(
              context.l10n.discoverIngredientAmountsHaveNotBeenAddedFor,
              style: TextStyle(color: AppColors.textMuted, height: 1.45),
            ),
          )
        else ...[
          SurfaceCard(
            key: const Key('recipe-ingredients'),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (var index = 0; index < ingredients.length; index++) ...[
                  _IngredientRow(
                    key: ValueKey('ingredient-$index'),
                    ingredient: ingredients[index],
                    checked: checked.contains(index),
                    onTap: () => onToggle(index),
                  ),
                  if (index < ingredients.length - 1)
                    const Divider(height: 1, indent: 52, endIndent: 16),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.touch_app_outlined,
                  size: 17,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.discoverTickWhatYouAlreadyHaveTicksOnly,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ),
              if (checked.isNotEmpty)
                TextButton(
                  onPressed: onClearChecks,
                  child: Text(context.l10n.discoverReset),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.ingredient,
    required this.checked,
    required this.onTap,
    super.key,
  });

  final ScaledIngredient ingredient;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final measure = ingredient.displayMeasure;
    final grams = ingredient.gramsLabel;
    final note = ingredient.displayNote;
    return MergeSemantics(
      child: Semantics(
        checked: checked,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 54),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Icon(
                    checked
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 24,
                    color: checked ? AppColors.primary : AppColors.textMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ingredient.displayName,
                          style: TextStyle(
                            color: checked
                                ? AppColors.textMuted
                                : AppColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration: checked
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: AppColors.textMuted,
                          ),
                        ),
                        if (note != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            note,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // With large system fonts the amount may wrap, but must
                  // never push the row beyond the screen edge.
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.38,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          measure ?? grams,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: checked
                                ? AppColors.textMuted
                                : AppColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (measure != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            grams,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ],
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
}

/// Numbered preparation steps; Plus adds a tip under each step and the
/// cook mode.
class RecipeStepsSection extends StatelessWidget {
  const RecipeStepsSection({
    required this.recipe,
    required this.details,
    required this.onCookMode,
    super.key,
  });

  final Recipe recipe;

  /// Only passed for Plus members.
  final RecipePremiumDetails? details;

  /// `null` when the cook mode is not available (free accounts).
  final ValueChanged<int>? onCookMode;

  @override
  Widget build(BuildContext context) {
    final steps = recipe.steps;
    final cookMode = onCookMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailSectionTitle(
          context.l10n.discoverMethod,
          trailing: steps.isEmpty
              ? null
              : steps.length == 1
              ? context.l10n.discover1Step
              : context.l10n.discoverValueSteps((steps.length).toString()),
        ),
        if (cookMode != null && steps.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('cook-mode-start'),
              onPressed: () => cookMode(0),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(context.l10n.discoverStartCookingMode),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.discoverOneStepPerPageLargeTextAnd,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
          ),
        ],
        const SizedBox(height: 12),
        if (steps.isEmpty)
          SurfaceCard(
            child: Text(
              context.l10n.discoverNoInstructionsHaveBeenAddedForThis,
              style: TextStyle(color: AppColors.textMuted, height: 1.45),
            ),
          )
        else
          for (var index = 0; index < steps.length; index++) ...[
            if (index > 0) const SizedBox(height: 10),
            RecipeStepCard(
              key: ValueKey('recipe-step-$index'),
              index: index,
              step: steps[index],
              tip: details?.tipForStep(index) ?? '',
              onTimerTap: cookMode == null ? null : () => cookMode(index),
            ),
          ],
      ],
    );
  }
}

class RecipeStepCard extends StatelessWidget {
  const RecipeStepCard({
    required this.index,
    required this.step,
    required this.tip,
    this.onTimerTap,
    super.key,
  });

  final int index;
  final RecipeStep step;
  final String tip;
  final VoidCallback? onTimerTap;

  @override
  Widget build(BuildContext context) {
    final title = step.displayTitle?.trim() ?? '';
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepNumber(number: index + 1),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      title.isEmpty
                          ? context.l10n.discoverStepValue(
                              (index + 1).toString(),
                            )
                          : title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (step.minutes > 0)
                      _TimerChip(minutes: step.minutes, onTap: onTimerTap),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  step.displayText,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15.5,
                    height: 1.55,
                  ),
                ),
                if (tip.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ProTipBox(tip: tip),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StepNumber extends StatelessWidget {
  const StepNumber({required this.number, this.size = 34, super.key});

  final int number;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.discoverStepValue((number).toString()),
    child: ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.14),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.45)),
        ),
        child: Text(
          '$number',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: size * 0.44,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ),
  );
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.minutes, this.onTap});

  final int minutes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 14, color: AppColors.orange),
          const SizedBox(width: 4),
          Text(
            formatMinutes(minutes),
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
    final tap = onTap;
    if (tap == null) {
      return Semantics(
        label: context.l10n.discoverDurationValue(
          (formatMinutes(minutes)).toString(),
        ),
        child: chip,
      );
    }
    return Tooltip(
      message: context.l10n.discoverOpenTimerInCookingMode,
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(99),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Align(widthFactor: 1, child: chip),
        ),
      ),
    );
  }
}

/// Highlighted Plus tip for a step.
class ProTipBox extends StatelessWidget {
  const ProTipBox({required this.tip, this.large = false, super.key});

  final String tip;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 18.0 : 14.5;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: large ? 22 : 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: context.l10n.discoverProTip,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: CatalogText.of(tip)),
                ],
              ),
              style: TextStyle(
                color: AppColors.text,
                fontSize: size,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plus area with collapsible knowledge blocks. Only built for Plus members.
class RecipePlusArea extends StatelessWidget {
  const RecipePlusArea({
    required this.recipe,
    required this.details,
    super.key,
  });

  final Recipe recipe;
  final RecipePremiumDetails? details;

  @override
  Widget build(BuildContext context) {
    final data = details;
    final blocks = <Widget>[
      if (data != null && data.displayCommonMistakes.isNotEmpty)
        _PlusBlock(
          key: const Key('plus-block-mistakes'),
          icon: Icons.report_gmailerrorred_rounded,
          color: AppColors.orange,
          title: context.l10n.discoverThingsToWatch,
          initiallyExpanded: true,
          child: _BulletList(items: data.displayCommonMistakes),
        ),
      if (data != null && data.displaySubstitutions.isNotEmpty)
        _PlusBlock(
          key: const Key('plus-block-substitutions'),
          icon: Icons.swap_horiz_rounded,
          color: AppColors.mint,
          title: context.l10n.discoverSubstitutions,
          child: _BulletList(items: data.displaySubstitutions),
        ),
      if (data != null && data.displayMealPrep.trim().isNotEmpty)
        _PlusBlock(
          key: const Key('plus-block-meal-prep'),
          icon: Icons.inventory_2_outlined,
          color: AppColors.blue,
          title: context.l10n.discoverMealPrepStorage,
          child: _Paragraph(data.displayMealPrep.trim()),
        ),
      if (data != null && data.displayVariations.isNotEmpty)
        _PlusBlock(
          key: const Key('plus-block-variations'),
          icon: Icons.auto_awesome_outlined,
          color: AppColors.purple,
          title: context.l10n.discoverVariations,
          child: _BulletList(items: data.displayVariations),
        ),
      if (data != null && data.displayServingTip.trim().isNotEmpty)
        _PlusBlock(
          key: const Key('plus-block-serving'),
          icon: Icons.restaurant_menu_rounded,
          color: AppColors.primary,
          title: context.l10n.discoverServingSuggestion,
          child: _Paragraph(data.displayServingTip.trim()),
        ),
      if (recipe.ingredients.any((ingredient) => ingredient.nutrition != null))
        _PlusBlock(
          key: const Key('plus-block-breakdown'),
          icon: Icons.donut_small_outlined,
          color: AppColors.cyan,
          title: context.l10n.discoverWhereDoTheNutritionValuesComeFrom,
          child: _NutritionBreakdown(recipe: recipe),
        ),
    ];
    if (blocks.isEmpty) return const SizedBox.shrink();
    return Column(
      key: const Key('recipe-plus-area'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DetailSectionTitle('Lookin $recipePlusLabel'),
        const SizedBox(height: 4),
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            context.l10n.discoverExtraKnowledgeAboutThisRecipe,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),
        for (final (index, block) in blocks.indexed) ...[
          if (index > 0) const SizedBox(height: 10),
          block,
        ],
      ],
    );
  }
}

class _PlusBlock extends StatefulWidget {
  const _PlusBlock({
    required this.icon,
    required this.color,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<_PlusBlock> createState() => _PlusBlockState();
}

class _PlusBlockState extends State<_PlusBlock> {
  late bool _open = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = _reduceMotion(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 220);
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: _open,
            child: InkWell(
              onTap: () => setState(() => _open = !_open),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 58),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.icon, size: 20, color: widget.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _open ? 0.5 : 0,
                        duration: duration,
                        child: const Icon(
                          Icons.expand_more_rounded,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: duration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: AppColors.text, fontSize: 15, height: 1.55),
  );
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final visible = [
      for (final item in items)
        if (item.trim().isNotEmpty) item.trim(),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, item) in visible.indexed)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 9),
                  decoration: const BoxDecoration(
                    color: AppColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _Paragraph(item)),
              ],
            ),
          ),
      ],
    );
  }
}

class _NutritionBreakdown extends StatelessWidget {
  const _NutritionBreakdown({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final servings = basePortions(recipe);
    final rows = [
      for (final ingredient in recipe.ingredients)
        if (ingredient.nutrition case final nutrition?)
          (
            ingredient.displayName,
            ingredient.amountGrams / servings,
            nutrition.scaled(1 / servings),
          ),
    ]..sort((a, b) => b.$3.calories.compareTo(a.$3.calories));
    final total = rows.fold<double>(0, (sum, row) => sum + row.$3.calories);
    final missing = recipe.ingredients.length - rows.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          missing > 0
              ? context.l10n.discoverMissingNutrition(missing)
              : context
                    .l10n
                    .discoverPerServingBasedOnIngredientCatalogueValues2,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        for (final (name, grams, nutrition) in rows)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        formatKcal(nutrition.calories),
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.discoverValueValueProtein(
                            (RecipeIngredient.formatGrams(grams)).toString(),
                            (formatNutrientGrams(nutrition.protein)).toString(),
                          ),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      Text(
                        total <= 0
                            ? ''
                            : '${(nutrition.calories / total * 100).round()} %',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ExcludeSemantics(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: total <= 0
                            ? 0
                            : (nutrition.calories / total).clamp(0.0, 1.0),
                        minHeight: 5,
                        color: AppColors.cyan,
                        backgroundColor: AppColors.surfaceHigh,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// The single, calm hint for free accounts at the end of a recipe.
class RecipePlusTeaser extends StatelessWidget {
  const RecipePlusTeaser({
    required this.onOpen,
    required this.trialAvailable,
    super.key,
  });

  final VoidCallback onOpen;
  final bool trialAvailable;

  static List<String> get benefits => [
    L10n.current.discoverProTipsForEveryStep,
    L10n.current.discoverCommonMistakes,
    L10n.current.discoverIngredientSubstitutions,
    L10n.current.discoverMealPrepStorage,
    L10n.current.discoverCookingModeWithTimers,
    L10n.current.discoverAdaptToMyTarget,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('recipe-plus-teaser'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(AppColors.surfaceHigh, AppColors.primary, 0.1)!,
            AppColors.surface,
          ],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    const RecipePlusBadge(),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.discoverMoreKnowledgeForEveryRecipe,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.discoverYouCanCookThisEntireRecipeFor(
              (recipePlusLabel).toString(),
            ),
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          for (final benefit in benefits)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      benefit,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('recipe-plus-teaser-open'),
              onPressed: onOpen,
              icon: const Icon(Icons.workspace_premium_rounded),
              label: Text(
                trialAvailable
                    ? context.l10n.discoverTryValueFreeForValueDays(
                        (recipePlusLabel).toString(),
                        (SubscriptionPlans.trialDays).toString(),
                      )
                    : context.l10n.discoverViewValue(
                        (recipePlusLabel).toString(),
                      ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
