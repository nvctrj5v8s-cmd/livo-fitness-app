import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../subscription/presentation/premium_widgets.dart';
import 'recipe_detail_page.dart';
import 'recipe_format.dart';

/// Name of the paid tier inside the recipe screens. Kept in one place so the
/// wording can follow the rest of the app.
const recipePlusLabel = 'Plus';

/// Premium marker with icon and text (never colour alone).
class RecipePlusBadge extends StatelessWidget {
  const RecipePlusBadge({super.key});

  @override
  Widget build(BuildContext context) =>
      const PremiumBadge(label: recipePlusLabel);
}

String recipeHeroTag(Recipe recipe, [String scope = 'grid']) =>
    'recipe-$scope-${recipe.id}';

/// Opens the recipe detail page; without motion when the system asks for it.
Future<void> openRecipeDetail(
  BuildContext context,
  Recipe recipe, {
  String? heroTag,
}) {
  final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  final page = RecipeDetailPage(recipe: recipe, heroTag: heroTag);
  return Navigator.of(context).push<void>(
    reduceMotion
        ? PageRouteBuilder<void>(
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (_, _, _) => page,
          )
        : MaterialPageRoute<void>(builder: (_) => page),
  );
}

/// Always flies the already decoded card photo, in both directions.
Widget recipeHeroShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromContext,
  BuildContext toContext,
) {
  final hero =
      (direction == HeroFlightDirection.push
              ? fromContext.widget
              : toContext.widget)
          as Hero;
  return hero.child;
}

/// Local recipe photo with a stable gradient fallback when the asset is
/// missing or still loading.
class RecipePhoto extends StatelessWidget {
  const RecipePhoto({required this.recipe, this.decodeWidth, super.key});

  final Recipe recipe;

  /// Logical width the photo is shown at; limits decoding memory.
  final double? decodeWidth;

  @override
  Widget build(BuildContext context) {
    final path = recipe.imageAsset.trim();
    if (path.isEmpty) return RecipeArtwork(recipe: recipe);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2;
    final width = decodeWidth;
    return ColoredBox(
      color: AppColors.surfaceHigh,
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        cacheWidth: width == null
            ? null
            : (width * ratio).round().clamp(96, 2048),
        frameBuilder: (context, child, frame, synchronous) {
          if (synchronous || reduceMotion) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (_, _, _) => RecipeArtwork(recipe: recipe),
      ),
    );
  }
}

/// Calm gradient illustration used when no photo is available.
class RecipeArtwork extends StatelessWidget {
  const RecipeArtwork({required this.recipe, super.key});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final tags = recipe.tags;
    final accent = tags.contains('Vegetarisch') || tags.contains('Vegan')
        ? AppColors.mint
        : tags.contains('High Protein')
        ? AppColors.primary
        : AppColors.orange;
    final icon = tags.contains('Frühstück')
        ? Icons.egg_alt_rounded
        : tags.contains('Snack')
        ? Icons.cookie_outlined
        : Icons.restaurant_rounded;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.42),
              AppColors.surfaceHigh,
              AppColors.background,
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -36,
              top: -44,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withValues(alpha: 0.24),
                    width: 22,
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: accent.withValues(alpha: 0.32)),
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small icon + text pair used in cards and fact rows.
class RecipeMeta extends StatelessWidget {
  const RecipeMeta({
    required this.icon,
    required this.text,
    this.color = AppColors.textMuted,
    this.textColor = AppColors.text,
    super.key,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

IconData difficultyIcon(String difficulty) => switch (difficulty) {
  'Anspruchsvoll' => Icons.signal_cellular_alt_rounded,
  'Mittel' => Icons.signal_cellular_alt_2_bar_rounded,
  _ => Icons.signal_cellular_alt_1_bar_rounded,
};

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.favorite, required this.onPressed});

  final bool favorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return IconButton.filled(
      tooltip: favorite ? 'Aus Favoriten entfernen' : 'Zu Favoriten hinzufügen',
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        backgroundColor: AppColors.black.withValues(alpha: 0.6),
        foregroundColor: favorite ? AppColors.error : AppColors.white,
      ),
      icon: AnimatedSwitcher(
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 200),
        child: Icon(
          favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey(favorite),
          size: 21,
        ),
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.black.withValues(alpha: 0.66),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.schedule_rounded, size: 14, color: AppColors.white),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            formatMinutes(minutes),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Photo card for grids and the quick row.
class RecipeCard extends StatelessWidget {
  const RecipeCard({
    required this.recipe,
    required this.favorite,
    required this.onFavorite,
    required this.onOpen,
    required this.heroTag,
    this.decodeWidth,
    super.key,
  });

  final Recipe recipe;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onOpen;
  final String heroTag;
  final double? decodeWidth;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onOpen,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag,
                    flightShuttleBuilder: recipeHeroShuttle,
                    child: RecipePhoto(
                      recipe: recipe,
                      decodeWidth: decodeWidth,
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
                            Color(0x66000000),
                            Color(0x00000000),
                            Color(0x00000000),
                            Color(0xB3000000),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (recipe.isPremium)
                    const Positioned(
                      left: 10,
                      top: 10,
                      child: RecipePlusBadge(),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _FavoriteButton(
                      favorite: favorite,
                      onPressed: onFavorite,
                    ),
                  ),
                  if (recipe.minutes > 0)
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: _TimePill(minutes: recipe.minutes),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        height: 1.22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Spacer(),
                    Wrap(
                      spacing: 10,
                      runSpacing: 5,
                      children: [
                        RecipeMeta(
                          icon: Icons.local_fire_department_rounded,
                          color: AppColors.orange,
                          text: '${recipe.calories} kcal',
                        ),
                        RecipeMeta(
                          icon: Icons.egg_alt_rounded,
                          color: AppColors.mint,
                          text: '${recipe.protein} g Protein',
                        ),
                        RecipeMeta(
                          icon: difficultyIcon(recipe.difficulty),
                          text: recipe.difficulty,
                          textColor: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact row for narrow screens or very large text.
class RecipeListCard extends StatelessWidget {
  const RecipeListCard({
    required this.recipe,
    required this.favorite,
    required this.onFavorite,
    required this.onOpen,
    required this.heroTag,
    super.key,
  });

  final Recipe recipe;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onOpen;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 96,
                height: 96,
                child: Hero(
                  tag: heroTag,
                  flightShuttleBuilder: recipeHeroShuttle,
                  child: RecipePhoto(recipe: recipe, decodeWidth: 96),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recipe.isPremium) ...[
                      const RecipePlusBadge(),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      recipe.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        height: 1.22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 5,
                      children: [
                        if (recipe.minutes > 0)
                          RecipeMeta(
                            icon: Icons.schedule_rounded,
                            text: formatMinutes(recipe.minutes),
                          ),
                        RecipeMeta(
                          icon: Icons.local_fire_department_rounded,
                          color: AppColors.orange,
                          text: '${recipe.calories} kcal',
                        ),
                        RecipeMeta(
                          icon: Icons.egg_alt_rounded,
                          color: AppColors.mint,
                          text: '${recipe.protein} g Protein',
                        ),
                        RecipeMeta(
                          icon: difficultyIcon(recipe.difficulty),
                          text: recipe.difficulty,
                          textColor: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _FavoriteButton(favorite: favorite, onPressed: onFavorite),
          ],
        ),
      ),
    );
  }
}

/// Responsive grid: rows of equally high photo cards, or a list of compact
/// cards on narrow screens and with very large text.
class RecipeGrid extends StatelessWidget {
  const RecipeGrid({
    required this.recipes,
    required this.favoriteIds,
    required this.onFavorite,
    super.key,
  });

  final List<Recipe> recipes;
  final Set<String> favoriteIds;
  final ValueChanged<Recipe> onFavorite;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1000
            ? 4
            : width >= 700
            ? 3
            : width >= 300 && textScale <= 1.35
            ? 2
            : 1;
        if (columns == 1) {
          return Column(
            children: [
              for (final recipe in recipes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RecipeListCard(
                    key: ValueKey('recipe-card-${recipe.id}'),
                    recipe: recipe,
                    favorite: favoriteIds.contains(recipe.id),
                    onFavorite: () => onFavorite(recipe),
                    onOpen: () => openRecipeDetail(
                      context,
                      recipe,
                      heroTag: recipeHeroTag(recipe),
                    ),
                    heroTag: recipeHeroTag(recipe),
                  ),
                ),
            ],
          );
        }
        const gap = 12.0;
        final cardWidth = (width - gap * (columns - 1)) / columns;
        return Column(
          children: [
            for (var start = 0; start < recipes.length; start += columns)
              Padding(
                padding: const EdgeInsets.only(bottom: gap),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var column = 0; column < columns; column++) ...[
                        if (column > 0) const SizedBox(width: gap),
                        Expanded(
                          child: start + column < recipes.length
                              ? _gridCard(
                                  context,
                                  recipes[start + column],
                                  cardWidth,
                                )
                              : const SizedBox.shrink(),
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

  Widget _gridCard(BuildContext context, Recipe recipe, double width) {
    final tag = recipeHeroTag(recipe);
    return RecipeCard(
      key: ValueKey('recipe-card-${recipe.id}'),
      recipe: recipe,
      favorite: favoriteIds.contains(recipe.id),
      onFavorite: () => onFavorite(recipe),
      onOpen: () => openRecipeDetail(context, recipe, heroTag: tag),
      heroTag: tag,
      decodeWidth: width,
    );
  }
}
