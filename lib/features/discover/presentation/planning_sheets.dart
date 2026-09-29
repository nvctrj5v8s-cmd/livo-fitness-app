import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';
import '../application/planning_controller.dart';
import '../domain/ingredient_match.dart';
import '../domain/kitchen_planning.dart';
import '../domain/recipe_filter.dart' show recipeMatchesQuery;
import '../domain/recipe_serving.dart';
import 'cook_from_pantry_page.dart';
import 'kitchen_format.dart';
import 'kitchen_widgets.dart';
import 'recipe_card.dart';
import 'recipe_format.dart';
import 'shopping_list_sheet.dart';

export 'shopping_list_sheet.dart' show showShoppingSheet;

Future<void> showWeekPlanSheet(BuildContext context, AppController controller) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _WeekPlanSheet(controller: controller),
  );
}

Future<void> showPantrySheet(BuildContext context, AppController controller) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PantrySheet(controller: controller),
  );
}

/// Where a planned recipe goes: day, meal and portions.
class PlanChoice {
  const PlanChoice({
    required this.day,
    required this.slot,
    required this.portions,
  });

  final DateTime day;
  final MealSlot slot;
  final int portions;
}

/// Asks for day, meal and portions. Used to plan a recipe and to move or
/// change an existing entry.
Future<PlanChoice?> showPlanEntrySheet(
  BuildContext context, {
  required String recipeTitle,
  required DateTime initialDay,
  required MealSlot initialSlot,
  required int initialPortions,
  bool editing = false,
}) {
  return showModalBottomSheet<PlanChoice>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PlanEntrySheet(
      recipeTitle: recipeTitle,
      initialDay: kitchenDay(initialDay),
      initialSlot: initialSlot,
      initialPortions: clampPlanPortions(initialPortions),
      editing: editing,
    ),
  );
}

/// Plans [recipe] after asking for day, meal and portions. Returns the
/// confirmation text, or `null` when nothing was planned.
Future<String?> planRecipeWithSheet(
  BuildContext context,
  AppController controller,
  Recipe recipe, {
  DateTime? day,
}) async {
  final planning = controller.planning;
  if (!planning.ready) {
    return planning.loadError ?? 'Deine Listen werden noch geladen.';
  }
  final choice = await showPlanEntrySheet(
    context,
    recipeTitle: recipe.title,
    initialDay: day ?? DateTime.now(),
    initialSlot: defaultPlanSlot(recipe),
    initialPortions: basePortions(recipe).round(),
  );
  if (choice == null) return null;
  final added = planning.addPlanEntry(
    recipe: recipe,
    day: choice.day,
    slot: choice.slot,
    portions: choice.portions,
  );
  if (!added) return 'Das Rezept konnte nicht eingeplant werden.';
  return '„${recipe.title}“ ist für ${formatShortDay(choice.day)} · '
      '${choice.slot.label} eingeplant.';
}

IconData _slotIcon(MealSlot slot) => switch (slot) {
  MealSlot.breakfast => Icons.wb_sunny_outlined,
  MealSlot.lunch => Icons.lunch_dining_outlined,
  MealSlot.dinner => Icons.dinner_dining_outlined,
  MealSlot.snack => Icons.cookie_outlined,
};

Recipe? _recipeById(AppController controller, String id) {
  for (final recipe in controller.recipes) {
    if (recipe.id == id) return recipe;
  }
  return null;
}

// --- Week plan ---------------------------------------------------------------

class _WeekPlanSheet extends StatefulWidget {
  const _WeekPlanSheet({required this.controller});
  final AppController controller;

  @override
  State<_WeekPlanSheet> createState() => _WeekPlanSheetState();
}

class _WeekPlanSheetState extends State<_WeekPlanSheet> {
  late DateTime _monday = weekStartOf(DateTime.now());

  PlanningController get _planning => widget.controller.planning;

  void _shiftWeek(int weeks) => setState(
    () => _monday = DateTime(
      _monday.year,
      _monday.month,
      _monday.day + 7 * weeks,
    ),
  );

  Future<void> _addTo(DateTime day) async {
    final recipe = await showModalBottomSheet<Recipe>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _RecipePickerSheet(controller: widget.controller),
    );
    if (recipe == null || !mounted) return;
    final message = await planRecipeWithSheet(
      context,
      widget.controller,
      recipe,
      day: day,
    );
    if (message != null && mounted) _setMessage(message);
  }

  String? _message;

  void _setMessage(String text) => setState(() => _message = text);

  Future<void> _edit(MealPlanEntry entry) async {
    final choice = await showPlanEntrySheet(
      context,
      recipeTitle: entry.recipeTitle,
      initialDay: entry.day,
      initialSlot: entry.slot,
      initialPortions: entry.portions,
      editing: true,
    );
    if (choice == null || !mounted) return;
    _planning.updatePlanEntry(
      entry.id,
      day: choice.day,
      slot: choice.slot,
      portions: choice.portions,
    );
    if (!sameKitchenDay(weekStartOf(choice.day), _monday)) {
      _monday = weekStartOf(choice.day);
    }
    _setMessage(
      '„${entry.recipeTitle}“ steht jetzt am ${formatShortDay(choice.day)} '
      '· ${choice.slot.label}.',
    );
  }

  void _open(MealPlanEntry entry) {
    final recipe = _recipeById(widget.controller, entry.recipeId);
    if (recipe == null) {
      _setMessage(
        'Dieses Rezept ist gerade nicht im Katalog verfügbar, zum Beispiel '
        'weil Premium nicht mehr aktiv ist.',
      );
      return;
    }
    unawaited(openRecipeDetail(context, recipe));
  }

  Future<void> _clearWeek() async {
    final confirmed = await confirmKitchenAction(
      context,
      title: 'Woche leeren?',
      body:
          'Alle geplanten Mahlzeiten vom ${formatWeekRange(_monday)} werden '
          'entfernt. Einkaufsliste und Vorräte bleiben unverändert.',
      action: 'Leeren',
    );
    if (!confirmed || !mounted) return;
    final removed = _planning.clearWeek(_monday);
    _setMessage('${countText(removed, 'Mahlzeit', 'Mahlzeiten')} entfernt.');
  }

  Future<void> _createShopping() async {
    final summary = _planning.createShoppingFromPlan(
      _monday,
      widget.controller.recipes,
    );
    if (summary == null || !mounted) return;
    final openList = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('plan-shopping-summary'),
        title: const Text('Einkaufsliste erstellt'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryLine(
                icon: Icons.add_shopping_cart_rounded,
                text: summary.added.isEmpty
                    ? 'Keine neuen Zutaten hinzugefügt.'
                    : '${countText(summary.added.length, 'Zutat', 'Zutaten')} '
                          'hinzugefügt.',
              ),
              if (summary.alreadyOnList.isNotEmpty)
                _SummaryLine(
                  icon: Icons.playlist_add_check_rounded,
                  text:
                      'Schon auf der Liste: '
                      '${summary.alreadyOnList.join(', ')}',
                ),
              if (summary.coveredByPantry.isNotEmpty)
                _SummaryLine(
                  icon: Icons.kitchen_outlined,
                  text:
                      'In deinen Vorräten: '
                      '${summary.coveredByPantry.join(', ')}',
                ),
              if (summary.skippedBasics.isNotEmpty)
                _SummaryLine(
                  icon: Icons.check_circle_outline_rounded,
                  text:
                      'Als Grundzutat vorausgesetzt: '
                      '${summary.skippedBasics.join(', ')}',
                ),
              if (summary.unavailableRecipes > 0)
                _SummaryLine(
                  icon: Icons.info_outline_rounded,
                  text:
                      '${countText(summary.unavailableRecipes, 'Rezept ist', 'Rezepte sind')} '
                      'gerade nicht im Katalog und wurde${summary.unavailableRecipes == 1 ? '' : 'n'} '
                      'übersprungen.',
                ),
              const SizedBox(height: 6),
              const Text(
                'Mengen sind aus den Rezepten berechnet. Bitte vor dem Einkauf '
                'kurz prüfen.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Schließen'),
          ),
          FilledButton(
            key: const Key('plan-summary-open-shopping'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Einkaufsliste öffnen'),
          ),
        ],
      ),
    );
    if (openList == true && mounted) {
      unawaited(showShoppingSheet(context, widget.controller));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _planning,
      builder: (context, _) {
        final entries = _planning.entriesForWeek(_monday);
        final today = kitchenDay(DateTime.now());
        final isCurrentWeek = sameKitchenDay(_monday, weekStartOf(today));
        return KitchenSheetFrame(
          title: 'Wochenplan',
          subtitle: entries.isEmpty
              ? 'Noch nichts geplant'
              : '${countText(entries.length, 'Mahlzeit', 'Mahlzeiten')} '
                    'in dieser Woche',
          top: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _WeekNavigator(
                label: formatWeekRange(_monday),
                onPrevious: () => _shiftWeek(-1),
                onNext: () => _shiftWeek(1),
                onToday: isCurrentWeek
                    ? null
                    : () => setState(() => _monday = weekStartOf(today)),
              ),
              if (_message != null) ...[
                const SizedBox(height: 8),
                KitchenFeedback(text: _message!),
              ],
            ],
          ),
          children: [
            KitchenStorageStatus(planning: _planning),
            if (_planning.ready) ...[
              for (final (index, day) in weekDays(_monday).indexed) ...[
                _DayCard(
                  index: index,
                  day: day,
                  today: sameKitchenDay(day, today),
                  entries: [
                    for (final entry in entries)
                      if (sameKitchenDay(entry.day, day)) entry,
                  ],
                  recipeAvailable: (entry) =>
                      _recipeById(widget.controller, entry.recipeId) != null,
                  onAdd: () => _addTo(day),
                  onOpen: _open,
                  onEdit: _edit,
                  onRemove: (entry) {
                    _planning.removePlanEntry(entry.id);
                    _setMessage('„${entry.recipeTitle}“ entfernt.');
                  },
                ),
                const SizedBox(height: 9),
              ],
              const SizedBox(height: 6),
              FilledButton.icon(
                key: const Key('plan-create-shopping'),
                onPressed: entries.isEmpty ? null : _createShopping,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Einkaufsliste aus Wochenplan erstellen'),
              ),
              const SizedBox(height: 6),
              Text(
                _planning.assumeBasics
                    ? 'Zutaten aus deinen Vorräten und Grundzutaten wie Salz, '
                          'Pfeffer und Öl werden ausgelassen.'
                    : 'Zutaten aus deinen Vorräten werden ausgelassen.',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              if (entries.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('plan-clear-week'),
                    onPressed: _clearWeek,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Woche leeren'),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _WeekNavigator extends StatelessWidget {
  const _WeekNavigator({
    required this.label,
    required this.onPrevious,
    required this.onNext,
    this.onToday,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onToday;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              key: const Key('plan-prev-week'),
              tooltip: 'Vorherige Woche',
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                label,
                key: const Key('plan-week-label'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            IconButton.filledTonal(
              key: const Key('plan-next-week'),
              tooltip: 'Nächste Woche',
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        if (onToday != null)
          Align(
            child: TextButton(
              key: const Key('plan-this-week'),
              onPressed: onToday,
              child: const Text('Zur aktuellen Woche'),
            ),
          ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.index,
    required this.day,
    required this.today,
    required this.entries,
    required this.recipeAvailable,
    required this.onAdd,
    required this.onOpen,
    required this.onEdit,
    required this.onRemove,
  });

  final int index;
  final DateTime day;
  final bool today;
  final List<MealPlanEntry> entries;
  final bool Function(MealPlanEntry entry) recipeAvailable;
  final VoidCallback onAdd;
  final ValueChanged<MealPlanEntry> onOpen;
  final ValueChanged<MealPlanEntry> onEdit;
  final ValueChanged<MealPlanEntry> onRemove;

  @override
  Widget build(BuildContext context) {
    final weekday = kitchenWeekdays[day.weekday - 1];
    return SurfaceCard(
      key: ValueKey('plan-day-card-$index'),
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 6),
      borderColor: today ? AppColors.primary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '$weekday, ${day.day}.${day.month}.',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (today)
                      const StatusPill(label: 'Heute', icon: Icons.today),
                  ],
                ),
              ),
              TextButton.icon(
                key: ValueKey('plan-add-$index'),
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 19),
                label: const Text('Planen'),
              ),
            ],
          ),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                'Noch keine Mahlzeit geplant',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
          for (final entry in entries)
            _PlanEntryRow(
              entry: entry,
              available: recipeAvailable(entry),
              onOpen: () => onOpen(entry),
              onEdit: () => onEdit(entry),
              onRemove: () => onRemove(entry),
            ),
        ],
      ),
    );
  }
}

class _PlanEntryRow extends StatelessWidget {
  const _PlanEntryRow({
    required this.entry,
    required this.available,
    required this.onOpen,
    required this.onEdit,
    required this.onRemove,
  });

  final MealPlanEntry entry;
  final bool available;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('plan-entry-${entry.id}'),
      onTap: onOpen,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(_slotIcon(entry.slot), size: 20, color: AppColors.mint),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.recipeTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.slot.label} · ${portionsText(entry.portions)}'
                    '${available ? '' : ' · derzeit nicht verfügbar'}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              key: ValueKey('plan-entry-menu-${entry.id}'),
              tooltip: 'Optionen für ${entry.recipeTitle}',
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: AppColors.textMuted,
              ),
              onSelected: (value) => switch (value) {
                'open' => onOpen(),
                'edit' => onEdit(),
                _ => onRemove(),
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'open', child: Text('Rezept öffnen')),
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Verschieben oder ändern'),
                ),
                PopupMenuItem(value: 'remove', child: Text('Entfernen')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanEntrySheet extends StatefulWidget {
  const _PlanEntrySheet({
    required this.recipeTitle,
    required this.initialDay,
    required this.initialSlot,
    required this.initialPortions,
    required this.editing,
  });

  final String recipeTitle;
  final DateTime initialDay;
  final MealSlot initialSlot;
  final int initialPortions;
  final bool editing;

  @override
  State<_PlanEntrySheet> createState() => _PlanEntrySheetState();
}

class _PlanEntrySheetState extends State<_PlanEntrySheet> {
  late DateTime _day = widget.initialDay;
  late MealSlot _slot = widget.initialSlot;
  late int _portions = widget.initialPortions;
  late DateTime _monday = weekStartOf(widget.initialDay);

  @override
  Widget build(BuildContext context) {
    final today = kitchenDay(DateTime.now());
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.editing ? 'Eintrag ändern' : 'Einplanen',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.recipeTitle,
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Schließen',
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _WeekNavigator(
                label: formatWeekRange(_monday),
                onPrevious: () => setState(
                  () => _monday = DateTime(
                    _monday.year,
                    _monday.month,
                    _monday.day - 7,
                  ),
                ),
                onNext: () => setState(
                  () => _monday = DateTime(
                    _monday.year,
                    _monday.month,
                    _monday.day + 7,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const _Label('Tag'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (index, day) in weekDays(_monday).indexed)
                    ChoiceChip(
                      key: ValueKey('plan-day-$index'),
                      label: Text(
                        sameKitchenDay(day, today)
                            ? 'Heute, ${day.day}.${day.month}.'
                            : formatShortDay(day),
                      ),
                      selected: sameKitchenDay(day, _day),
                      onSelected: (_) => setState(() => _day = day),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const _Label('Mahlzeit'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final slot in MealSlot.values)
                    ChoiceChip(
                      key: ValueKey('plan-slot-${slot.databaseValue}'),
                      avatar: Icon(_slotIcon(slot), size: 17),
                      label: Text(slot.label),
                      selected: slot == _slot,
                      onSelected: (_) => setState(() => _slot = slot),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const _Label('Portionen (für die Einkaufsliste)'),
              Row(
                children: [
                  IconButton.filledTonal(
                    key: const Key('plan-portions-minus'),
                    tooltip: 'Eine Portion weniger',
                    onPressed: _portions <= minPlanPortions
                        ? null
                        : () => setState(() => _portions--),
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  Expanded(
                    child: Text(
                      portionsText(_portions),
                      key: const Key('plan-portions-label'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    key: const Key('plan-portions-plus'),
                    tooltip: 'Eine Portion mehr',
                    onPressed: _portions >= maxPlanPortions
                        ? null
                        : () => setState(() => _portions++),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                key: const Key('plan-confirm'),
                onPressed: () => Navigator.pop(
                  context,
                  PlanChoice(day: _day, slot: _slot, portions: _portions),
                ),
                icon: const Icon(Icons.event_available_rounded),
                label: Text(
                  widget.editing
                      ? 'Änderung übernehmen'
                      : 'Für ${formatShortDay(_day)} einplanen',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _RecipePickerSheet extends StatefulWidget {
  const _RecipePickerSheet({required this.controller});

  final AppController controller;

  @override
  State<_RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends State<_RecipePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final recipes = [
      for (final recipe in widget.controller.personalizedRecipes)
        if (recipeMatchesQuery(recipe, _query)) recipe,
    ];
    return KitchenSheetFrame(
      title: 'Rezept wählen',
      subtitle: countText(recipes.length, 'Rezept', 'Rezepte'),
      top: TextField(
        key: const Key('plan-recipe-search'),
        autofocus: false,
        onChanged: (value) => setState(() => _query = value),
        decoration: const InputDecoration(
          hintText: 'Rezepte oder Zutaten suchen',
          prefixIcon: Icon(Icons.search_rounded),
        ),
      ),
      children: [
        if (recipes.isEmpty)
          const Text(
            'Kein Rezept gefunden.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        for (final recipe in recipes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                key: ValueKey('plan-pick-${recipe.id}'),
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.pop(context, recipe),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: RecipePhoto(recipe: recipe, decodeWidth: 56),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (recipe.isPremium) ...[
                              const RecipePlusBadge(),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              recipe.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              [
                                if (recipe.minutes > 0)
                                  formatMinutes(recipe.minutes),
                                '${recipe.calories} kcal pro Portion',
                              ].join(' · '),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// --- Pantry --------------------------------------------------------------------

class _PantrySheet extends StatefulWidget {
  const _PantrySheet({required this.controller});
  final AppController controller;

  @override
  State<_PantrySheet> createState() => _PantrySheetState();
}

class _PantrySheetState extends State<_PantrySheet> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  String? _message;

  PlanningController get _planning => widget.controller.planning;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _show(KitchenEdit result, String name) {
    setState(() {
      _message = switch (result.status) {
        KitchenEditStatus.added || KitchenEditStatus.removed => null,
        KitchenEditStatus.merged => 'Menge bei „$name“ ergänzt.',
        KitchenEditStatus.duplicate => '„$name“ ist schon in deinen Vorräten.',
        _ => result.message,
      };
    });
  }

  void _add() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final result = _planning.addPantryItem(name, amountText: _amount.text);
    _show(result, name);
    if (result.changed || result.status == KitchenEditStatus.duplicate) {
      _name.clear();
      _amount.clear();
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await confirmKitchenAction(
      context,
      title: 'Alle Vorräte entfernen?',
      body: 'Alle Zutaten in deinen Vorräten werden entfernt.',
      action: 'Entfernen',
    );
    if (!confirmed || !mounted) return;
    _planning.clearPantry();
    setState(() => _message = 'Deine Vorräte sind leer.');
  }

  void _openCook() {
    unawaited(
      Navigator.of(context).push(
        buildCookFromPantryRoute(
          context,
          const CookFromPantryPage(usePantry: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _planning,
      builder: (context, _) {
        final items = _planning.pantry;
        return KitchenSheetFrame(
          title: 'Meine Vorräte',
          subtitle: '${countText(items.length, 'Zutat', 'Zutaten')} zu Hause',
          top: _planning.ready
              ? _NameAmountInput(
                  nameController: _name,
                  amountController: _amount,
                  nameHint: 'Zutat eintragen',
                  nameIcon: Icons.kitchen_outlined,
                  keyPrefix: 'pantry',
                  onSubmit: _add,
                  message: _message,
                )
              : null,
          children: [
            KitchenStorageStatus(planning: _planning),
            if (_planning.ready) ...[
              FilledButton.icon(
                key: const Key('pantry-cook'),
                onPressed: _openCook,
                icon: const Icon(Icons.soup_kitchen_outlined),
                label: const Text('Was kann ich damit kochen?'),
              ),
              const SizedBox(height: 16),
              const _Label('Schnell hinzufügen'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final staple in kitchenStaples)
                    FilterChip(
                      key: ValueKey('pantry-staple-$staple'),
                      label: Text(staple),
                      selected: _planning.pantryItemFor(staple) != null,
                      showCheckmark: true,
                      checkmarkColor: AppColors.black,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _planning.pantryItemFor(staple) != null
                            ? AppColors.black
                            : AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                      tooltip: _planning.pantryItemFor(staple) != null
                          ? '$staple aus den Vorräten entfernen'
                          : '$staple zu den Vorräten hinzufügen',
                      onSelected: (_) =>
                          _show(_planning.togglePantryStaple(staple), staple),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              if (items.isEmpty)
                const _EmptyHint(
                  icon: Icons.kitchen_outlined,
                  text:
                      'Noch keine Vorräte. Trage ein, was du zu Hause hast – '
                      'eine Menge ist freiwillig, zum Beispiel „500 g“ oder '
                      '„2 Stück“.',
                ),
              for (final item in items) ...[
                SurfaceCard(
                  key: ValueKey('pantry-item-${item.id}'),
                  padding: const EdgeInsets.fromLTRB(15, 8, 6, 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.mint,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              kitchenAmountLabel(item.amount, item.note) ??
                                  'Vorrätig',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _planning.removePantryItem(item.id),
                        tooltip: '${item.name} entfernen',
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (items.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('pantry-clear-all'),
                    onPressed: _clearAll,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Alle entfernen'),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

// --- Shared ------------------------------------------------------------------

/// Name field plus optional amount; stacks on narrow screens.
class _NameAmountInput extends StatelessWidget {
  const _NameAmountInput({
    required this.nameController,
    required this.amountController,
    required this.nameHint,
    required this.nameIcon,
    required this.keyPrefix,
    required this.onSubmit,
    this.message,
  });

  /// Result of the last action, shown right below the fields.
  final String? message;
  final TextEditingController nameController;
  final TextEditingController amountController;
  final String nameHint;
  final IconData nameIcon;
  final String keyPrefix;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final name = TextField(
      key: ValueKey('$keyPrefix-name'),
      controller: nameController,
      maxLength: kitchenNameMaxLength,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => onSubmit(),
      decoration: InputDecoration(
        hintText: nameHint,
        counterText: '',
        prefixIcon: Icon(nameIcon),
      ),
    );
    final amount = TextField(
      key: ValueKey('$keyPrefix-amount'),
      controller: amountController,
      maxLength: 30,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSubmit(),
      decoration: const InputDecoration(
        hintText: 'Menge (optional)',
        counterText: '',
      ),
    );
    final add = IconButton.filled(
      key: ValueKey('$keyPrefix-add'),
      onPressed: onSubmit,
      tooltip: 'Hinzufügen',
      style: IconButton.styleFrom(minimumSize: const Size(52, 52)),
      icon: const Icon(Icons.add_rounded),
    );
    final fields = LayoutBuilder(
      builder: (context, constraints) {
        final wide =
            constraints.maxWidth >= 460 &&
            MediaQuery.textScalerOf(context).scale(14) <= 18;
        if (wide) {
          return Row(
            children: [
              Expanded(flex: 3, child: name),
              const SizedBox(width: 9),
              Expanded(flex: 2, child: amount),
              const SizedBox(width: 9),
              add,
            ],
          );
        }
        return Column(
          children: [
            name,
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: amount),
                const SizedBox(width: 9),
                add,
              ],
            ),
          ],
        );
      },
    );
    final text = message;
    if (text == null) return fields;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        fields,
        const SizedBox(height: 8),
        KitchenFeedback(text: text),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textMuted, height: 1.4),
          ),
        ),
      ],
    ),
  );
}
