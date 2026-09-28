import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../subscription/presentation/paywall_page.dart';
import '../../subscription/presentation/premium_widgets.dart';
import '../domain/ingredient_match.dart';
import '../domain/kitchen_planning.dart';
import 'kitchen_format.dart';
import 'planning_sheets.dart';
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

Future<void> openCookFromPantry(
  BuildContext context, {
  bool usePantry = true,
}) => Navigator.of(context).push(
  buildCookFromPantryRoute(context, CookFromPantryPage(usePantry: usePantry)),
);

/// Prominent entry in the recipe tab.
class CookFromPantryBanner extends StatelessWidget {
  const CookFromPantryBanner({
    required this.pantryCount,
    required this.onOpen,
    super.key,
  });

  final int pantryCount;
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
                  Text(
                    pantryCount == 0
                        ? 'Rezepte mit dem, was du zu Hause hast'
                        : 'Rezepte passend zu deinen Vorräten '
                              '(${countText(pantryCount, 'Zutat', 'Zutaten')})',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
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

/// "Was kann ich kochen?": pick what is at home (or use the pantry) and get
/// catalog recipes ranked by how much of them is already there.
class CookFromPantryPage extends StatefulWidget {
  const CookFromPantryPage({this.usePantry = true, super.key});

  /// Whether the pantry counts as "at home" when the page opens.
  final bool usePantry;

  @override
  State<CookFromPantryPage> createState() => _CookFromPantryPageState();
}

class _CookFromPantryPageState extends State<CookFromPantryPage> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  final List<String> _extra = [];
  late bool _usePantry = widget.usePantry;
  String _query = '';

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _addExtra(String raw) {
    final name = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty || name.length > kitchenNameMaxLength) return;
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

  void _showMessage(String text, {SnackBarAction? action}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(text), action: action));
  }

  void _addMissing(AppController controller, RecipeMatch match) {
    final merge = controller.planning.addShoppingDrafts(
      shoppingDraftsForIngredients(match.recipe, match.missing),
    );
    if (merge == null) {
      _showMessage(
        controller.planning.loadError ?? 'Deine Listen werden noch geladen.',
      );
      return;
    }
    final added = merge.added.length;
    _showMessage(
      added == 0
          ? 'Die fehlenden Zutaten stehen schon auf deiner Einkaufsliste.'
          : '${countText(added, 'Zutat', 'Zutaten')} auf die Einkaufsliste '
                'gesetzt.${controller.planning.persistent ? '' : ' Ohne Konto nur bis zum Neustart.'}',
      action: SnackBarAction(
        label: 'Ansehen',
        onPressed: () => unawaited(showShoppingSheet(context, controller)),
      ),
    );
  }

  void _saveExtrasToPantry(AppController controller) {
    var added = 0;
    for (final name in _extra) {
      if (controller.planning.addPantryItem(name).changed) added++;
    }
    setState(() {
      _extra.clear();
      _usePantry = true;
    });
    _showMessage(
      added == 0
          ? 'Diese Zutaten sind schon in deinen Vorräten.'
          : '${countText(added, 'Zutat', 'Zutaten')} in deine Vorräte '
                'übernommen.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final planning = controller.planning;
    final pantryNames = planning.pantryNames;
    final have = [if (_usePantry) ...pantryNames, ..._extra];
    final matches = matchRecipesToInventory(
      controller.personalizedRecipes,
      have,
      assumeBasics: planning.assumeBasics,
    );
    final cookNow = matches.where((match) => match.canCookNow).length;
    final suggestions = ingredientSuggestions(
      controller.recipes,
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
                    'Wähle, was du zu Hause hast. LIVO zeigt Rezepte mit diesen '
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
                                maxLength: kitchenNameMaxLength,
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
                        if (pantryNames.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          SwitchListTile(
                            key: const Key('cook-use-pantry'),
                            contentPadding: EdgeInsets.zero,
                            value: _usePantry,
                            onChanged: (value) =>
                                setState(() => _usePantry = value),
                            title: Text(
                              'Meine Vorräte verwenden (${pantryNames.length})',
                            ),
                            subtitle: Text(
                              pantryNames.join(', '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              key: const Key('cook-save-to-pantry'),
                              onPressed: planning.ready
                                  ? () => _saveExtrasToPantry(controller)
                                  : null,
                              icon: const Icon(
                                Icons.kitchen_outlined,
                                size: 18,
                              ),
                              label: const Text(
                                'Auswahl in Vorräte übernehmen',
                              ),
                            ),
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
                          value: planning.assumeBasics,
                          onChanged: planning.ready
                              ? planning.setAssumeBasics
                              : null,
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
                      _MatchList(
                        matches: matches,
                        onAddMissing: (match) => _addMissing(controller, match),
                      ),
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
  const _MatchList({required this.matches, required this.onAddMissing});

  final List<RecipeMatch> matches;
  final ValueChanged<RecipeMatch> onAddMissing;

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
                child: _MatchCard(
                  match: match,
                  onAddMissing: () => onAddMissing(match),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match, required this.onAddMissing});

  final RecipeMatch match;
  final VoidCallback onAddMissing;

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
            if (match.missing.isNotEmpty) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  key: ValueKey('cook-missing-to-shopping-${recipe.id}'),
                  onPressed: onAddMissing,
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                  label: const Text('Fehlende Zutaten auf die Einkaufsliste'),
                ),
              ),
            ],
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
