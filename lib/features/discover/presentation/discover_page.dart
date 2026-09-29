import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/config/feature_flags.dart';
import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_reveal.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../subscription/presentation/paywall_page.dart';
import '../../subscription/presentation/premium_widgets.dart';
import '../domain/kitchen_planning.dart' show weekStartOf;
import '../domain/recipe_filter.dart';
import 'cook_from_pantry_page.dart';
import 'kitchen_format.dart' show countText;
import 'planning_sheets.dart';
import 'recipe_card.dart';
import 'recipe_filters.dart';

export 'recipe_detail_page.dart' show RecipeDetailPage;

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  RecipeFilter _filter = const RecipeFilter();
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _setFilter(RecipeFilter next) => setState(() => _filter = next);

  void _resetAll() {
    _search.clear();
    _setFilter(const RecipeFilter());
  }

  Future<void> _openFilterSheet(
    List<Recipe> recipes,
    Set<String> favoriteIds,
  ) async {
    final next = await showRecipeFilterSheet(
      context,
      current: _filter,
      countFor: (filter) =>
          applyRecipeFilter(recipes, filter, favoriteIds: favoriteIds).length,
      difficulties: availableRecipeDifficulties(recipes),
    );
    if (next != null && mounted) _setFilter(next);
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final recipes = controller.personalizedRecipes;
    final favoriteIds = controller.favoriteRecipeIds;
    final results = applyRecipeFilter(
      recipes,
      _filter,
      favoriteIds: favoriteIds,
    );
    final mealTypes = availableRecipeTags(recipes, recipeMealTypes);
    final goalTags = availableRecipeTags(recipes, recipeGoalTags);
    final quick = [
      for (final recipe in recipes)
        if (recipe.minutes > 0 && recipe.minutes <= 15) recipe,
    ];
    final showQuick =
        _filter.isDefault && quick.length >= 3 && quick.length < recipes.length;
    final listTitle = !_filter.isDefault
        ? 'Passende Rezepte'
        : controller.personalization != null
        ? 'Für dich'
        : 'Alle Rezepte';

    return SingleChildScrollView(
      key: const PageStorageKey('discover-scroll'),
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AnimatedReveal(
                  child: PageHeader(
                    title: 'Rezepte',
                    subtitle:
                        'Ideen, die zu deinem Ziel und deinem Alltag passen.',
                  ),
                ),
                if (controller.personalization != null) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'Für dich sortiert nach deinen Vorlieben und deiner Kochzeit. Die Sortierung blendet keine Rezepte aus.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
                const SizedBox(height: 18),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 40),
                  child: CookFromPantryBanner(
                    pantryCount: kitchenPlanningEnabled
                        ? controller.planning.pantry.length
                        : 0,
                    onOpen: () => openCookFromPantry(context),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 70),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('recipe-search'),
                          controller: _search,
                          textInputAction: TextInputAction.search,
                          onChanged: (value) =>
                              _setFilter(_filter.copyWith(query: value)),
                          decoration: InputDecoration(
                            hintText: 'Rezepte oder Zutaten suchen',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _filter.query.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Suche löschen',
                                    onPressed: () {
                                      _search.clear();
                                      _setFilter(_filter.copyWith(query: ''));
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      RecipeFilterButton(
                        activeCount: _filter.sheetCount,
                        onPressed: () => _openFilterSheet(recipes, favoriteIds),
                      ),
                    ],
                  ),
                ),
                if (mealTypes.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 110),
                    child: MealTypeTabs(
                      options: mealTypes,
                      selected: _filter.mealType,
                      onSelected: (value) =>
                          _setFilter(_filter.copyWith(mealType: value)),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 140),
                  child: RecipeTagChips(
                    tags: goalTags,
                    selected: _filter.tags,
                    favoritesOnly: _filter.favoritesOnly,
                    onToggleTag: (tag) => _setFilter(_filter.toggleTag(tag)),
                    onToggleFavorites: () => _setFilter(
                      _filter.copyWith(favoritesOnly: !_filter.favoritesOnly),
                    ),
                  ),
                ),
                if (_filter.sheetCount > 0) ...[
                  const SizedBox(height: 12),
                  ActiveSheetFilters(filter: _filter, onChanged: _setFilter),
                ],
                if (showQuick) ...[
                  const SizedBox(height: 26),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 180),
                    child: _QuickRecipes(
                      recipes: quick.take(8).toList(),
                      favoriteIds: favoriteIds,
                      onFavorite: (recipe) =>
                          controller.toggleFavorite(recipe.id),
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 200),
                  child: _ListHeader(
                    title: listTitle,
                    count: results.length,
                    onReset: _filter.isDefault ? null : _resetAll,
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 230),
                  child: results.isEmpty
                      ? _EmptyResults(
                          noFavorites:
                              _filter.favoritesOnly && favoriteIds.isEmpty,
                          onReset: _resetAll,
                        )
                      : RecipeGrid(
                          recipes: results,
                          favoriteIds: favoriteIds,
                          onFavorite: (recipe) =>
                              controller.toggleFavorite(recipe.id),
                        ),
                ),
                // Free accounts only receive free recipes (RLS); point to the
                // rest honestly instead of showing locked placeholders.
                if (controller.subscription.hasLoaded &&
                    !controller.subscription.hasPremium) ...[
                  const SizedBox(height: 18),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 270),
                    child: PremiumRecipesCard(
                      onUnlock: () => unawaited(
                        showPaywall(context, source: PaywallSource.recipes),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                if (kitchenPlanningEnabled) ...[
                  const AnimatedReveal(
                    delay: Duration(milliseconds: 300),
                    child: SectionHeader(title: 'Planen & vorbereiten'),
                  ),
                  const SizedBox(height: 11),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 350),
                    child: _PlanningGrid(controller: controller),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.title, required this.count, this.onReset});

  final String title;
  final int count;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                count == 1 ? '1 Rezept' : '$count Rezepte',
                key: const Key('recipe-result-count'),
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (onReset != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt_rounded, size: 18),
              label: const Text('Alle Filter zurücksetzen'),
            ),
          ),
      ],
    );
  }
}

class _QuickRecipes extends StatelessWidget {
  const _QuickRecipes({
    required this.recipes,
    required this.favoriteIds,
    required this.onFavorite,
  });

  final List<Recipe> recipes;
  final Set<String> favoriteIds;
  final ValueChanged<Recipe> onFavorite;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth * 0.46).clamp(170.0, 240.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Schnell unter 15 Min.'),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0; index < recipes.length; index++) ...[
                      if (index > 0) const SizedBox(width: 12),
                      SizedBox(
                        width: cardWidth,
                        child: RecipeCard(
                          recipe: recipes[index],
                          favorite: favoriteIds.contains(recipes[index].id),
                          onFavorite: () => onFavorite(recipes[index]),
                          onOpen: () => openRecipeDetail(
                            context,
                            recipes[index],
                            heroTag: recipeHeroTag(recipes[index], 'quick'),
                          ),
                          heroTag: recipeHeroTag(recipes[index], 'quick'),
                          decodeWidth: cardWidth,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.noFavorites, required this.onReset});

  final bool noFavorites;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 32,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 10),
            const Text(
              'Kein Rezept passt zu deiner Auswahl.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              noFavorites
                  ? 'Du hast noch keine Favoriten. Tippe auf das Herz eines Rezepts, um es dir zu merken.'
                  : 'Probiere einen anderen Suchbegriff oder entferne einen Filter.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Alle Filter zurücksetzen'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanningGrid extends StatelessWidget {
  const _PlanningGrid({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final planning = controller.planning;
    final planned = planning.entriesForWeek(weekStartOf(DateTime.now())).length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 3 : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            _PlanningCard(
              width: width,
              icon: Icons.calendar_month_rounded,
              color: AppColors.mint,
              title: 'Wochenplan',
              subtitle: planned == 0
                  ? 'Rezepte auf Tage verteilen'
                  : '${countText(planned, 'Mahlzeit', 'Mahlzeiten')} diese Woche',
              onTap: () => showWeekPlanSheet(context, controller),
            ),
            _PlanningCard(
              width: width,
              icon: Icons.shopping_bag_outlined,
              color: AppColors.orange,
              title: 'Einkaufsliste',
              subtitle:
                  '${countText(planning.openShoppingCount, 'Artikel', 'Artikel')} offen',
              onTap: () => showShoppingSheet(context, controller),
            ),
            _PlanningCard(
              width: width,
              icon: Icons.kitchen_outlined,
              color: AppColors.purple,
              title: 'Vorräte',
              subtitle:
                  '${countText(planning.pantry.length, 'Zutat', 'Zutaten')} zu Hause',
              onTap: () => showPantrySheet(context, controller),
            ),
          ],
        );
      },
    );
  }
}

class _PlanningCard extends StatelessWidget {
  const _PlanningCard({
    required this.width,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final double width;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: PressableScale(
        onTap: onTap,
        child: SurfaceCard(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
