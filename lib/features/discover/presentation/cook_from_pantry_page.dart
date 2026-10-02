import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../subscription/presentation/paywall_page.dart';
import '../../subscription/presentation/premium_widgets.dart';
import '../domain/ingredient_match.dart';
import 'recipe_card.dart';
import 'recipe_format.dart';

/// Opens [page]; without a transition when the system asks for reduced
/// motion.
Route<void> buildCookFromPantryRoute(BuildContext context, Widget page) {
  final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  return reduceMotion
      ? PageRouteBuilder<void>(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, _, _) => page,
        )
      : MaterialPageRoute<void>(builder: (_) => page);
}

/// Longest ingredient name that can be typed in.
const _maxNameLength = 60;

Future<void> openCookFromPantry(BuildContext context) => Navigator.of(
  context,
).push(buildCookFromPantryRoute(context, const CookFromPantryPage()));

/// Prominent entry in the recipe tab.
class CookFromPantryBanner extends StatelessWidget {
  const CookFromPantryBanner({required this.onOpen, super.key});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      key: const Key('cook-from-pantry-banner'),
      onTap: onOpen,
      child: SurfaceCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
        borderColor: AppColors.primary.withValues(alpha: 0.6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(AppColors.surfaceHigh, AppColors.primary, 0.1)!,
            AppColors.surface,
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.soup_kitchen_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Was kann ich kochen?',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Rezepte mit dem, was du zu Hause hast',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

/// "Was kann ich kochen?": pick what is at home and get
/// catalog recipes ranked by how much of them is already there.
class CookFromPantryPage extends StatefulWidget {
  const CookFromPantryPage({super.key});

  @override
  State<CookFromPantryPage> createState() => _CookFromPantryPageState();
}

class _CookFromPantryPageState extends State<CookFromPantryPage> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  final List<String> _extra = [];

  /// Whether salt, pepper, oil, water and common spices count as available.
  bool _assumeBasics = true;
  String _query = '';

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _addExtra(String raw) {
    final name = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty || name.length > _maxNameLength) return;
    setState(() {
      if (!IngredientInventory(_extra).has(name)) _extra.add(name);
      _input.clear();
      _query = '';
    });
  }

  void _toggleStaple(String staple, List<String> have) {
    final existing = [
      for (final name in _extra)
        if (ingredientNamesMatch(name, staple)) name,
    ];
    setState(() {
      if (existing.isNotEmpty) {
        _extra.removeWhere(existing.contains);
      } else if (!IngredientInventory(have).has(staple)) {
        _extra.add(staple);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final have = _extra;
    final matches = matchRecipesToInventory(
      controller.personalizedRecipes,
      have,
      assumeBasics: _assumeBasics,
    );
    final cookNow = matches.where((match) => match.canCookNow).length;
    final suggestions = ingredientSuggestions(
      controller.personalizedRecipes,
      _query,
      exclude: have,
    );
    final subscription = controller.subscription;
    final showPremium = subscription.hasLoaded && !subscription.hasPremium;
    final inventory = IngredientInventory(have);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Zurück',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Was kann ich kochen?'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Wähle, was du zu Hause hast. Lookin zeigt Rezepte mit diesen '
                    'Zutaten – die mit den wenigsten fehlenden zuerst.',
                    style: TextStyle(color: AppColors.textMuted, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Das habe ich da',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                key: const Key('cook-input'),
                                controller: _input,
                                focusNode: _focus,
                                maxLength: _maxNameLength,
                                textInputAction: TextInputAction.done,
                                onChanged: (value) =>
                                    setState(() => _query = value),
                                onSubmitted: (value) {
                                  _addExtra(value);
                                  _focus.requestFocus();
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Zutat eingeben, z. B. Kartoffeln',
                                  counterText: '',
                                  prefixIcon: Icon(Icons.search_rounded),
                                ),
                              ),
                            ),
                            const SizedBox(width: 9),
                            IconButton.filled(
                              key: const Key('cook-add'),
                              tooltip: 'Zutat hinzufügen',
                              style: IconButton.styleFrom(
                                minimumSize: const Size(52, 52),
                              ),
                              onPressed: () => _addExtra(_input.text),
                              icon: const Icon(Icons.add_rounded),
                            ),
                          ],
                        ),
                        if (suggestions.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final suggestion in suggestions)
                                ActionChip(
                                  key: ValueKey('cook-suggestion-$suggestion'),
                                  avatar: const Icon(
                                    Icons.add_rounded,
                                    size: 17,
                                  ),
                                  label: Text(suggestion),
                                  onPressed: () => _addExtra(suggestion),
                                ),
                            ],
                          ),
                        ],
                        if (_extra.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final name in _extra)
                                InputChip(
                                  key: ValueKey('cook-chip-$name'),
                                  label: Text(name),
                                  deleteButtonTooltipMessage: '$name entfernen',
                                  onDeleted: () =>
                                      setState(() => _extra.remove(name)),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        const Text(
                          'Häufige Zutaten',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final staple in kitchenStaples)
                              FilterChip(
                                key: ValueKey('cook-staple-$staple'),
                                label: Text(staple),
                                selected: inventory.has(staple),
                                showCheckmark: true,
                                checkmarkColor: AppColors.black,
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: inventory.has(staple)
                                      ? AppColors.black
                                      : AppColors.text,
                                  fontWeight: FontWeight.w700,
                                ),
                                onSelected: (_) => _toggleStaple(staple, have),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SwitchListTile(
                          key: const Key('cook-basics'),
                          contentPadding: EdgeInsets.zero,
                          value: _assumeBasics,
                          onChanged: (value) =>
                              setState(() => _assumeBasics = value),
                          title: const Text('Grundzutaten sind vorhanden'),
                          subtitle: const Text(kitchenBasicsLabel),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (have.isEmpty)
                    const _Hint(
                      icon: Icons.touch_app_outlined,
                      title: 'Was hast du zu Hause?',
                      text:
                          'Tippe auf eine häufige Zutat oder gib selbst etwas '
                          'ein, zum Beispiel „Kartoffeln“.',
                    )
                  else ...[
                    Text(
                      matches.isEmpty
                          ? 'Keine passenden Rezepte'
                          : '${countText(matches.length, 'passendes Rezept', 'passende Rezepte')}'
                                '${cookNow > 0 ? ' · $cookNow sofort kochbar' : ''}',
                      key: const Key('cook-result-count'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (matches.isEmpty)
                      const _Hint(
                        icon: Icons.search_off_rounded,
                        title: 'Kein Rezept mit diesen Zutaten gefunden.',
                        text:
                            'Probiere eine weitere Zutat oder einen anderen '
                            'Namen, zum Beispiel „Nudeln“ statt „Spaghetti“.',
                      )
                    else
                      _MatchList(matches: matches),
                  ],
                  if (showPremium) ...[
                    const SizedBox(height: 18),
                    PremiumRecipesCard(
                      onUnlock: () => unawaited(
                        showPaywall(context, source: PaywallSource.recipes),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textMuted, size: 28),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(color: AppColors.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MatchList extends StatelessWidget {
  const _MatchList({required this.matches});

  final List<RecipeMatch> matches;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final columns = constraints.maxWidth >= 760 && textScale <= 1.4 ? 2 : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final match in matches)
              SizedBox(
                width: width,
                child: _MatchCard(match: match),
              ),
          ],
        );
      },
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});

  final RecipeMatch match;

  String _names(List<RecipeIngredient> ingredients) => [
    for (final ingredient in ingredients)
      ingredientDisplayName(ingredient.name),
  ].join(', ');

  @override
  Widget build(BuildContext context) {
    final recipe = match.recipe;
    final missing = match.missing.length;
    final status = missing == 0
        ? 'Alles da'
        : missing == 1
        ? '1 Zutat fehlt'
        : '$missing Zutaten fehlen';
    final tag = recipeHeroTag(recipe, 'cook');
    return PressableScale(
      key: ValueKey('cook-result-${recipe.id}'),
      onTap: () => openRecipeDetail(context, recipe, heroTag: tag),
      child: SurfaceCard(
        padding: const EdgeInsets.all(12),
        borderColor: missing == 0 ? AppColors.primary : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 84,
                    height: 84,
                    child: Hero(
                      tag: tag,
                      flightShuttleBuilder: recipeHeroShuttle,
                      child: RecipePhoto(recipe: recipe, decodeWidth: 84),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (recipe.isPremium) ...[
                        const RecipePlusBadge(),
                        const SizedBox(height: 5),
                      ],
                      Text(
                        recipe.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            missing == 0
                                ? Icons.check_circle_rounded
                                : Icons.shopping_basket_outlined,
                            size: 17,
                            color: missing == 0
                                ? AppColors.primary
                                : AppColors.orange,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              status,
                              style: TextStyle(
                                color: missing == 0
                                    ? AppColors.primary
                                    : AppColors.orange,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (recipe.minutes > 0) ...[
                        const SizedBox(height: 4),
                        RecipeMeta(
                          icon: Icons.schedule_rounded,
                          text: formatMinutes(recipe.minutes),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Semantics(
              label: '${match.covered} von ${match.total} Zutaten vorhanden',
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: match.coverage,
                          minHeight: 7,
                          backgroundColor: AppColors.surfaceHigh,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${match.covered} von ${match.total} da',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            _IngredientLine(
              label: 'Hast du',
              text: _names(match.available),
              color: AppColors.mint,
            ),
            if (match.missing.isNotEmpty)
              _IngredientLine(
                label: 'Fehlt',
                text: _names(match.missing),
                color: AppColors.orange,
              ),
            if (match.assumedBasics.isNotEmpty)
              _IngredientLine(
                label: 'Grundzutaten',
                text: _names(match.assumedBasics),
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}

class _IngredientLine extends StatelessWidget {
  const _IngredientLine({
    required this.label,
    required this.text,
    required this.color,
  });

  final String label;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
          TextSpan(text: text),
        ],
      ),
      style: const TextStyle(fontSize: 13, height: 1.35),
    ),
  );
}
