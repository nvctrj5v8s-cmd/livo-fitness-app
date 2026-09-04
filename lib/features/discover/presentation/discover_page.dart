import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_reveal.dart';
import '../../../shared/widgets/ui_components.dart';
import 'planning_sheets.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  String _category = 'Für dich';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final recipes = controller.recipes.where((recipe) {
      final matchesCategory =
          _category == 'Für dich' || recipe.tags.contains(_category);
      final matchesQuery = recipe.title.toLowerCase().contains(
        _query.toLowerCase(),
      );
      return matchesCategory && matchesQuery;
    }).toList();

    return SingleChildScrollView(
      key: const PageStorageKey('discover-scroll'),
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
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
                const SizedBox(height: 22),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 70),
                  child: TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: const InputDecoration(
                      hintText: 'Rezepte oder Zutaten suchen',
                      prefixIcon: Icon(Icons.search_rounded),
                      suffixIcon: Icon(Icons.tune_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 120),
                  child: _CategoryBar(
                    selected: _category,
                    onSelected: (value) => setState(() => _category = value),
                  ),
                ),
                const SizedBox(height: 25),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 180),
                  child: SectionHeader(
                    title: _category,
                    action: '${recipes.length} Rezepte',
                  ),
                ),
                const SizedBox(height: 11),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 230),
                  child: _RecipeGrid(recipes: recipes, controller: controller),
                ),
                const SizedBox(height: 30),
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
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.selected, required this.onSelected});
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const categories = [
      'Für dich',
      'High Protein',
      'Schnell',
      'Vegetarisch',
      'Budget',
    ];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = categories[index];
          final active = selected == label;
          return ChoiceChip(
            selected: active,
            showCheckmark: false,
            label: Text(label),
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: active ? AppColors.primary : AppColors.border,
            ),
            labelStyle: TextStyle(
              color: active ? AppColors.black : AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
            onSelected: (_) => onSelected(label),
          );
        },
      ),
    );
  }
}

class _RecipeGrid extends StatelessWidget {
  const _RecipeGrid({required this.recipes, required this.controller});
  final List<Recipe> recipes;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return const SurfaceCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Kein Demo-Rezept passt zu dieser Suche.'),
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 820
            ? 3
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        const gap = 13.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: recipes
              .map(
                (recipe) => SizedBox(
                  width: width,
                  child: _RecipeCard(
                    recipe: recipe,
                    favorite: controller.favoriteRecipeIds.contains(recipe.id),
                    onFavorite: () => controller.toggleFavorite(recipe.id),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.favorite,
    required this.onFavorite,
  });
  final Recipe recipe;
  final bool favorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => RecipeDetailPage(recipe: recipe),
        ),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'recipe-${recipe.id}',
              child: AspectRatio(
                aspectRatio: 1.45,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(recipe.imageAsset, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xC0000000)],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton.filledTonal(
                        onPressed: onFavorite,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.black.withValues(
                            alpha: 0.64,
                          ),
                          foregroundColor: favorite
                              ? AppColors.error
                              : AppColors.white,
                        ),
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            favorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey(favorite),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 12,
                      child: StatusPill(label: '${recipe.protein} G PROTEIN'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    recipe.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: AppColors.textMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${recipe.minutes} Min.',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${recipe.calories} kcal',
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
              subtitle: '7 Tage vorbereiten',
              onTap: () => showWeekPlanSheet(context, controller),
            ),
            _PlanningCard(
              width: width,
              icon: Icons.shopping_bag_outlined,
              color: AppColors.orange,
              title: 'Einkaufsliste',
              subtitle:
                  '${controller.shoppingItems.where((item) => !item.done).length} Artikel offen',
              onTap: () => showShoppingSheet(context, controller),
            ),
            _PlanningCard(
              width: width,
              icon: Icons.kitchen_outlined,
              color: AppColors.purple,
              title: 'Vorräte',
              subtitle: '${controller.pantryItems.length} Zutaten verfügbar',
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

class RecipeDetailPage extends StatelessWidget {
  const RecipeDetailPage({required this.recipe, super.key});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 310,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'recipe-${recipe.id}',
                child: Image.asset(recipe.imageAsset, fit: BoxFit.cover),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(recipe.subtitle),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          StatusPill(
                            label: '${recipe.minutes} MIN.',
                            icon: Icons.schedule_rounded,
                          ),
                          StatusPill(
                            label: '${recipe.calories} KCAL',
                            icon: Icons.local_fire_department_rounded,
                            color: AppColors.orange,
                          ),
                          StatusPill(
                            label: '${recipe.protein} G PROTEIN',
                            icon: Icons.fitness_center_rounded,
                            color: AppColors.mint,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const SectionHeader(title: 'Zutaten'),
                      const SizedBox(height: 8),
                      const SurfaceCard(
                        child: Column(
                          children: [
                            _Ingredient('Proteinquelle', '180 g'),
                            Divider(),
                            _Ingredient('Vollkorn-Beilage', '80 g'),
                            Divider(),
                            _Ingredient('Gemüse nach Wahl', '250 g'),
                            Divider(),
                            _Ingredient('Joghurt-Kräuter-Dip', '100 g'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const SectionHeader(title: 'Zubereitung'),
                      const SizedBox(height: 8),
                      const SurfaceCard(
                        child: Text(
                          '1. Zutaten vorbereiten und die Proteinquelle garen.\n\n2. Gemüse schonend anbraten oder rösten.\n\n3. Alles anrichten, würzen und mit dem Dip servieren.',
                          style: TextStyle(height: 1.55),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            controller.addRecipeToDiary(recipe);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${recipe.title} wurde zum Tagebuch hinzugefügt.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Zum Tagesplan hinzufügen'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Ingredient extends StatelessWidget {
  const _Ingredient(this.name, this.amount);
  final String name;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(name)),
          Text(amount, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
