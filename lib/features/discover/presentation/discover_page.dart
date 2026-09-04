import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_reveal.dart';
import '../../../shared/widgets/feature_badge.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  int _selectedCategory = 0;
  final Set<int> _favorites = {1};

  static const _categories = [
    'Für dich',
    'High Protein',
    'Schnell',
    'Vegetarisch',
    'Budget',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedReveal(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Entdecken',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      const FeatureBadge(label: 'INHALTE · DEMO'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 50),
                  child: Text(
                    'Rezepte, Wissen und Planung passend zu deinem Alltag.',
                  ),
                ),
                const SizedBox(height: 22),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 100),
                  child: _FoodSearch(),
                ),
                const SizedBox(height: 18),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 150),
                  child: SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final selected = index == _selectedCategory;
                        return ChoiceChip(
                          label: Text(_categories[index]),
                          selected: selected,
                          showCheckmark: false,
                          selectedColor: AppColors.forest,
                          backgroundColor: AppColors.white,
                          labelStyle: TextStyle(
                            color: selected ? AppColors.white : AppColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                          side: BorderSide(
                            color: selected ? AppColors.forest : AppColors.line,
                          ),
                          onSelected: (_) =>
                              setState(() => _selectedCategory = index),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 210),
                  child: _Heading(
                    title: 'Heute für dich',
                    action: 'Alle Rezepte',
                  ),
                ),
                const SizedBox(height: 14),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 260),
                  child: _RecipeRail(
                    favorites: _favorites,
                    onFavorite: (index) => setState(() {
                      if (!_favorites.add(index)) _favorites.remove(index);
                    }),
                  ),
                ),
                const SizedBox(height: 30),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 320),
                  child: _Heading(title: 'Deine Küchenzentrale'),
                ),
                const SizedBox(height: 14),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 370),
                  child: _KitchenGrid(),
                ),
                const SizedBox(height: 30),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 430),
                  child: _LearnCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FoodSearch extends StatelessWidget {
  const _FoodSearch();

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Die echte Lebensmittel- und Rezeptsuche wird später angebunden.',
          ),
        ),
      ),
      decoration: InputDecoration(
        hintText: 'Lebensmittel, Rezept oder Zutat suchen',
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.forest),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.lime,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppColors.darkForest,
              size: 20,
            ),
          ),
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(20),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.line),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.forest, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.title, this.action});
  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (action != null)
          Text(
            action!,
            style: const TextStyle(
              color: AppColors.forest,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}

class _RecipeRail extends StatelessWidget {
  const _RecipeRail({required this.favorites, required this.onFavorite});
  final Set<int> favorites;
  final ValueChanged<int> onFavorite;

  @override
  Widget build(BuildContext context) {
    const recipes = [
      (
        'Green Power Bowl',
        '24 min',
        '610 kcal',
        '38 g Protein',
        AppColors.lime,
        Icons.rice_bowl_rounded,
      ),
      (
        'Berry Protein Oats',
        '8 min',
        '420 kcal',
        '31 g Protein',
        AppColors.lilac,
        Icons.breakfast_dining_rounded,
      ),
      (
        'Mediterrane Pasta',
        '20 min',
        '570 kcal',
        '27 g Protein',
        AppColors.peach,
        Icons.dinner_dining_rounded,
      ),
      (
        'Crunchy Wrap',
        '15 min',
        '490 kcal',
        '34 g Protein',
        AppColors.sky,
        Icons.lunch_dining_rounded,
      ),
    ];
    return SizedBox(
      height: 276,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: recipes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 13),
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return _RecipeCard(
            title: recipe.$1,
            time: recipe.$2,
            calories: recipe.$3,
            protein: recipe.$4,
            color: recipe.$5,
            icon: recipe.$6,
            favorite: favorites.contains(index),
            onFavorite: () => onFavorite(index),
          );
        },
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.title,
    required this.time,
    required this.calories,
    required this.protein,
    required this.color,
    required this.icon,
    required this.favorite,
    required this.onFavorite,
  });
  final String title;
  final String time;
  final String calories;
  final String protein;
  final Color color;
  final IconData icon;
  final bool favorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 235,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 132,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(21),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    size: 58,
                    color: AppColors.ink.withValues(alpha: 0.82),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Material(
                    color: AppColors.white.withValues(alpha: 0.86),
                    shape: const CircleBorder(),
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: onFavorite,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Icon(
                          favorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          key: ValueKey(favorite),
                          color: favorite ? AppColors.coral : AppColors.ink,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 14,
                color: AppColors.muted,
              ),
              const SizedBox(width: 4),
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              const Spacer(),
              Text(
                calories,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.coral,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                protein,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.forest,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KitchenGrid extends StatelessWidget {
  const _KitchenGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 780
            ? 3
            : constraints.maxWidth >= 480
            ? 2
            : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            _KitchenTile(
              width: width,
              color: AppColors.darkForest,
              foreground: AppColors.white,
              icon: Icons.calendar_view_week_rounded,
              title: 'Wochenplan',
              subtitle: 'Mahlzeiten planen und tauschen',
              badge: '7 TAGE',
            ),
            _KitchenTile(
              width: width,
              color: AppColors.peach,
              foreground: AppColors.ink,
              icon: Icons.shopping_cart_outlined,
              title: 'Einkaufsliste',
              subtitle: 'Automatisch aus deinem Plan',
              badge: '12 OFFEN',
            ),
            _KitchenTile(
              width: width,
              color: AppColors.lilac,
              foreground: AppColors.ink,
              icon: Icons.kitchen_outlined,
              title: 'Vorratsküche',
              subtitle: 'Kochen mit vorhandenen Zutaten',
              badge: 'KI SPÄTER',
            ),
          ],
        );
      },
    );
  }
}

class _KitchenTile extends StatelessWidget {
  const _KitchenTile({
    required this.width,
    required this.color,
    required this.foreground,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
  });
  final double width;
  final Color color;
  final Color foreground;
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title ist im Produktplan vorgemerkt.')),
      ),
      child: Container(
        width: width,
        height: 168,
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: foreground, size: 27),
                const Spacer(),
                Text(
                  badge,
                  style: TextStyle(
                    color: foreground.withValues(alpha: 0.72),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: foreground,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                color: foreground.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnCard extends StatelessWidget {
  const _LearnCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.lime,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: AppColors.darkForest,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ernährung einfach verstehen',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                ),
                SizedBox(height: 5),
                Text(
                  'Kurze, geprüfte Lektionen über Kalorien, Protein, Hunger und Gewohnheiten.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: AppColors.forest),
        ],
      ),
    );
  }
}
