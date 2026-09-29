import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/config/feature_flags.dart';
import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/domain/daily_targets.dart';
import '../../subscription/presentation/paywall_page.dart';
import '../domain/ingredient_match.dart' show ingredientDisplayName;
import '../domain/kitchen_planning.dart';
import '../domain/recipe_serving.dart';
import 'cook_mode_page.dart';
import 'planning_sheets.dart';
import 'recipe_card.dart';
import 'recipe_detail_sections.dart';
import 'recipe_sheets.dart';

/// Full recipe: facts, nutrition, portion calculator, ingredients and
/// detailed steps are free. Plus members additionally get tips, the cook
/// mode and the goal suggestion.
class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({required this.recipe, this.heroTag, super.key});

  final Recipe recipe;

  /// Tag of the photo this page was opened from, for the Hero animation.
  final String? heroTag;

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final _scroll = ScrollController();
  final Set<int> _checked = {};
  double _headerHeight = 300;
  bool _titleVisible = false;

  /// Chosen portions; `null` means the recipe's own portions.
  double? _portions;
  bool _showTotal = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final visible =
        _scroll.hasClients &&
        _scroll.offset > _headerHeight - kToolbarHeight - 40;
    if (visible != _titleVisible) setState(() => _titleVisible = visible);
  }

  /// The catalog may reload (for example after a trial starts); always show
  /// the freshest copy of this recipe.
  Recipe _current(AppController controller) {
    for (final recipe in controller.recipes) {
      if (recipe.id == widget.recipe.id) return recipe;
    }
    return widget.recipe;
  }

  void _setPortions(Recipe recipe, double value) {
    setState(() {
      _portions = value;
      if (value == basePortions(recipe)) _showTotal = false;
    });
  }

  void _toggleIngredient(int index) {
    setState(() {
      if (!_checked.remove(index)) _checked.add(index);
    });
  }

  void _showMessage(String text, {SnackBarAction? action}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(text), action: action));
  }

  Future<void> _addToDiary(AppController controller, Recipe recipe) async {
    final slot = await showMealSlotSheet(
      context,
      recipe: recipe,
      suggested: suggestedMealSlot(recipe, DateTime.now()),
    );
    if (slot == null || !mounted) return;
    final saved = await controller.addRecipeToDiary(recipe, slot: slot);
    if (!mounted) return;
    _showMessage(
      saved
          ? '1 Portion steht jetzt unter „${slot.label}“ im Tagebuch.'
          : controller.diaryError ??
                'Das Rezept konnte nicht eingetragen werden.',
    );
  }

  void _addToShopping(
    AppController controller,
    Recipe recipe,
    List<ScaledIngredient> ingredients,
  ) {
    final merge = controller.planning.addShoppingDrafts([
      for (final (index, item) in ingredients.indexed)
        if (!_checked.contains(index))
          ShoppingDraft(
            name: ingredientDisplayName(item.name),
            amount: item.grams > 0
                ? KitchenAmount(item.grams.ceilToDouble(), KitchenUnit.gram)
                : null,
            note: item.measure,
            source: recipe.title,
          ),
    ]);
    if (merge == null) {
      _showMessage(
        controller.planning.loadError ?? 'Deine Listen werden noch geladen.',
      );
      return;
    }
    final added = merge.added.length;
    _showMessage(
      added == 0
          ? 'Diese Zutaten stehen schon auf deiner Einkaufsliste.'
          : '${added == 1 ? '1 Zutat' : '$added Zutaten'} auf die '
                'Einkaufsliste gesetzt.'
                '${controller.planning.persistent ? ' Gespeichert nur auf diesem Gerät.' : ' Ohne Konto bleibt die Liste nur bis zum Neustart der App erhalten.'}',
      action: SnackBarAction(
        label: 'Ansehen',
        onPressed: () => showShoppingSheet(context, controller),
      ),
    );
  }

  Future<void> _addToPlan(AppController controller, Recipe recipe) async {
    final message = await planRecipeWithSheet(context, controller, recipe);
    if (message == null || !mounted) return;
    _showMessage(
      message,
      action: SnackBarAction(
        label: 'Wochenplan',
        onPressed: () => showWeekPlanSheet(context, controller),
      ),
    );
  }

  Future<void> _openGoal(AppController controller, Recipe recipe) async {
    final profile = controller.personalization;
    final suggestion = suggestPortion(
      caloriesPerPortion: recipe.nutrition.calories,
      calorieGoal: controller.calorieGoal,
      consumedCalories: controller.consumedCalories,
      mealsPerDay: profile?.desiredMeals ?? profile?.usualMeals ?? 3,
      mealsLogged: {for (final meal in controller.meals) meal.slot}.length,
    );
    if (suggestion == null) return;
    final apply = await showGoalSuggestionSheet(
      context,
      recipe: recipe,
      suggestion: suggestion,
    );
    if (apply == true && mounted) _setPortions(recipe, suggestion.factor);
  }

  Future<void> _openGoalLocked(bool trialAvailable) async {
    final open = await showGoalLockedSheet(
      context,
      trialAvailable: trialAvailable,
    );
    if (open == true && mounted) {
      await showPaywall(context, source: PaywallSource.recipes);
    }
  }

  Future<void> _openCookMode(
    AppController controller,
    Recipe recipe,
    RecipePremiumDetails? details,
    double portions,
    int step,
  ) async {
    final finished = await openCookMode(
      context,
      recipe: recipe,
      details: details,
      portions: portions,
      initialStep: step,
    );
    if (finished != true || !mounted) return;
    _showMessage(
      'Guten Appetit!',
      action: SnackBarAction(
        label: 'Eintragen',
        onPressed: () => unawaited(_addToDiary(controller, recipe)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final recipe = _current(controller);
    final subscription = controller.subscription;
    final plus = subscription.hasPremium;
    final showUpsell = subscription.hasLoaded && !plus;
    final details = plus ? recipe.premiumDetails : null;
    final base = basePortions(recipe);
    final portions = _portions ?? base;
    final ingredients = scaleIngredients(recipe, portions);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final size = MediaQuery.sizeOf(context);
    _headerHeight = (size.width * 0.72).clamp(260.0, 420.0);

    final goalAllowed =
        controller.dailyTargets.status != DailyTargetsStatus.underage &&
        controller.calorieGoal > 0 &&
        recipe.nutrition.calories > 0;
    final Widget? goalAction = !goalAllowed
        ? null
        : plus
        ? TextButton.icon(
            key: const Key('goal-open'),
            onPressed: () => _openGoal(controller, recipe),
            icon: const Icon(Icons.track_changes_rounded, size: 19),
            label: const Text('An mein Ziel anpassen'),
          )
        : showUpsell
        ? TextButton.icon(
            key: const Key('goal-locked'),
            onPressed: () => _openGoalLocked(subscription.canStartTrial),
            icon: const Icon(Icons.lock_outline_rounded, size: 18),
            label: const Text('An mein Ziel anpassen · $recipePlusLabel'),
          )
        : null;

    final equipment = [
      for (final item in recipe.equipment)
        if (item.trim().isNotEmpty) item.trim(),
    ];
    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecipeIntro(recipe: recipe),
        const SizedBox(height: 18),
        RecipeFactsCard(recipe: recipe),
      ],
    );
    final nutrition = RecipeNutritionCard(
      recipe: recipe,
      portions: portions,
      showTotal: _showTotal,
      onShowTotal: (value) => setState(() => _showTotal = value),
    );
    final ingredientsSection = RecipeIngredientsSection(
      ingredients: ingredients,
      calculator: PortionCalculator(
        portions: portions,
        basePortions: base,
        onChanged: (value) => _setPortions(recipe, value),
        goalAction: goalAction,
      ),
      checked: _checked,
      onToggle: _toggleIngredient,
      onClearChecks: () => setState(_checked.clear),
      onAddToShopping: kitchenPlanningEnabled
          ? () => _addToShopping(controller, recipe, ingredients)
          : null,
    );
    final steps = RecipeStepsSection(
      recipe: recipe,
      details: details,
      onCookMode: plus
          ? (step) => _openCookMode(controller, recipe, details, portions, step)
          : null,
    );
    final Widget? extras = plus
        ? RecipePlusArea(recipe: recipe, details: details)
        : showUpsell
        ? RecipePlusTeaser(
            trialAvailable: subscription.canStartTrial,
            onOpen: () =>
                unawaited(showPaywall(context, source: PaywallSource.recipes)),
          )
        : null;

    final content = LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 960) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              intro,
              const SizedBox(height: 24),
              nutrition,
              if (equipment.isNotEmpty) ...[
                const SizedBox(height: 28),
                RecipeEquipmentSection(equipment: equipment),
              ],
              const SizedBox(height: 28),
              ingredientsSection,
              const SizedBox(height: 30),
              steps,
              if (extras != null) ...[const SizedBox(height: 30), extras],
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            intro,
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 390,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      nutrition,
                      if (equipment.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        RecipeEquipmentSection(equipment: equipment),
                      ],
                      const SizedBox(height: 28),
                      ingredientsSection,
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      steps,
                      if (extras != null) ...[
                        const SizedBox(height: 30),
                        extras,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    final favorite = controller.favoriteRecipeIds.contains(recipe.id);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: _headerHeight,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leadingWidth: 64,
            leading: Center(
              child: _OverlayButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Zurück',
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
            title: AnimatedOpacity(
              opacity: _titleVisible ? 1 : 0,
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              child: Text(
                recipe.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            actions: [
              if (kitchenPlanningEnabled) ...[
                _OverlayButton(
                  key: const Key('recipe-add-plan'),
                  icon: Icons.calendar_month_rounded,
                  tooltip: 'Zum Wochenplan hinzufügen',
                  onPressed: () => _addToPlan(controller, recipe),
                ),
                const SizedBox(width: 8),
              ],
              _OverlayButton(
                icon: favorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                tooltip: favorite
                    ? 'Aus Favoriten entfernen'
                    : 'Zu Favoriten hinzufügen',
                color: favorite ? AppColors.error : AppColors.white,
                onPressed: () => controller.toggleFavorite(recipe.id),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: widget.heroTag ?? recipeHeroTag(recipe),
                    flightShuttleBuilder: recipeHeroShuttle,
                    child: RecipePhoto(
                      recipe: recipe,
                      decodeWidth: math.min(size.width, 1400),
                    ),
                  ),
                  const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0, 0.3, 0.62, 1],
                          colors: [
                            Color(0x8C000000),
                            Color(0x00000000),
                            Color(0x00000000),
                            AppColors.background,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: content,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _DiaryBar(
        recipe: recipe,
        saving: controller.diarySaving,
        onAdd: () => _addToDiary(controller, recipe),
      ),
    );
  }
}

/// Round icon button that stays readable on top of photos.
class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color = AppColors.white,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) => IconButton.filled(
    tooltip: tooltip,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      minimumSize: const Size(44, 44),
      backgroundColor: AppColors.black.withValues(alpha: 0.58),
      foregroundColor: color,
    ),
    icon: Icon(icon),
  );
}

/// Always visible action: adds exactly one portion to the diary.
class _DiaryBar extends StatelessWidget {
  const _DiaryBar({
    required this.recipe,
    required this.saving,
    required this.onAdd,
  });

  final Recipe recipe;
  final bool saving;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('recipe-add-diary'),
                  onPressed: saving ? null : onAdd,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(52, 58),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        saving
                            ? Icons.hourglass_top_rounded
                            : Icons.add_circle_outline_rounded,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              saving
                                  ? 'Wird gespeichert …'
                                  : '1 Portion zum Tagebuch',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Opacity(
                              opacity: 0.78,
                              child: Text(
                                '${recipe.calories} kcal · '
                                '${recipe.protein} g Protein',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
