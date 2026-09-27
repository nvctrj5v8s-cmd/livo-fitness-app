import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/recipe_filter.dart';

/// Meal-type switch shown as calm text tabs with an underline.
class MealTypeTabs extends StatelessWidget {
  const MealTypeTabs({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _MealTab(
            label: 'Alle',
            active: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final option in options)
            _MealTab(
              label: option,
              active: selected == option,
              onTap: () => onSelected(option),
            ),
        ],
      ),
    );
  }
}

class _MealTab extends StatelessWidget {
  const _MealTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Semantics(
      selected: active,
      button: true,
      child: InkWell(
        key: ValueKey('meal-type-$label'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 46),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: active ? AppColors.text : AppColors.textMuted,
                    fontSize: 15,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  height: 3,
                  width: active ? 24 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Filter chip in the LIVO style; selected chips show a check mark, so the
/// state is not conveyed by colour alone.
class RecipeChoiceChip extends StatelessWidget {
  const RecipeChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      showCheckmark: true,
      checkmarkColor: AppColors.black,
      avatar: icon == null || selected
          ? null
          : Icon(icon, size: 17, color: AppColors.textMuted),
      label: Text(label),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      labelStyle: TextStyle(
        color: selected ? AppColors.black : AppColors.text,
        fontWeight: FontWeight.w700,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}

/// Favourites plus diet/goal tags; several can be combined.
class RecipeTagChips extends StatelessWidget {
  const RecipeTagChips({
    required this.tags,
    required this.selected,
    required this.favoritesOnly,
    required this.onToggleTag,
    required this.onToggleFavorites,
    super.key,
  });

  final List<String> tags;
  final Set<String> selected;
  final bool favoritesOnly;
  final ValueChanged<String> onToggleTag;
  final VoidCallback onToggleFavorites;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          RecipeChoiceChip(
            key: const ValueKey('recipe-chip-favorites'),
            label: 'Favoriten',
            icon: Icons.favorite_border_rounded,
            selected: favoritesOnly,
            onSelected: onToggleFavorites,
          ),
          for (final tag in tags) ...[
            const SizedBox(width: 8),
            RecipeChoiceChip(
              key: ValueKey('recipe-chip-$tag'),
              label: tag,
              selected: selected.contains(tag),
              onSelected: () => onToggleTag(tag),
            ),
          ],
        ],
      ),
    );
  }
}

/// Opens the sort/filter sheet; shows how many sheet options are active.
class RecipeFilterButton extends StatelessWidget {
  const RecipeFilterButton({
    required this.activeCount,
    required this.onPressed,
    super.key,
  });

  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: activeCount > 0,
      backgroundColor: AppColors.primary,
      textColor: AppColors.black,
      label: Text('$activeCount'),
      child: IconButton.filledTonal(
        key: const Key('recipe-filter-button'),
        tooltip: activeCount > 0
            ? 'Filter und Sortierung, $activeCount aktiv'
            : 'Filter und Sortierung',
        onPressed: onPressed,
        style: IconButton.styleFrom(
          minimumSize: const Size(54, 54),
          backgroundColor: AppColors.surfaceHigh,
          foregroundColor: activeCount > 0 ? AppColors.primary : AppColors.text,
          side: BorderSide(
            color: activeCount > 0 ? AppColors.primary : AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: const Icon(Icons.tune_rounded),
      ),
    );
  }
}

/// Removable summary of the options chosen in the filter sheet.
class ActiveSheetFilters extends StatelessWidget {
  const ActiveSheetFilters({
    required this.filter,
    required this.onChanged,
    super.key,
  });

  final RecipeFilter filter;
  final ValueChanged<RecipeFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final chips = <(String, RecipeFilter)>[
      if (filter.sort != RecipeSort.forYou)
        (
          'Sortiert: ${filter.sort.label}',
          filter.copyWith(sort: RecipeSort.forYou),
        ),
      if (filter.maxMinutes != null)
        ('bis ${filter.maxMinutes} Min.', filter.copyWith(maxMinutes: null)),
      if (filter.difficulty != null)
        (filter.difficulty!, filter.copyWith(difficulty: null)),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (label, next) in chips)
          InputChip(
            label: Text(label),
            onPressed: () => onChanged(next),
            onDeleted: () => onChanged(next),
            deleteButtonTooltipMessage: '„$label“ entfernen',
            deleteIcon: const Icon(Icons.close_rounded, size: 17),
            backgroundColor: AppColors.surfaceHigh,
            side: const BorderSide(color: AppColors.borderBright),
            labelStyle: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

/// Sort and filter sheet. Returns the new filter or `null` when closed.
Future<RecipeFilter?> showRecipeFilterSheet(
  BuildContext context, {
  required RecipeFilter current,
  required int Function(RecipeFilter filter) countFor,
  required List<String> difficulties,
}) {
  return showModalBottomSheet<RecipeFilter>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _RecipeFilterSheet(
      initial: current,
      countFor: countFor,
      difficulties: difficulties,
    ),
  );
}

class _RecipeFilterSheet extends StatefulWidget {
  const _RecipeFilterSheet({
    required this.initial,
    required this.countFor,
    required this.difficulties,
  });

  final RecipeFilter initial;
  final int Function(RecipeFilter filter) countFor;
  final List<String> difficulties;

  @override
  State<_RecipeFilterSheet> createState() => _RecipeFilterSheetState();
}

class _RecipeFilterSheetState extends State<_RecipeFilterSheet> {
  late RecipeFilter _draft = widget.initial;

  void _set(RecipeFilter next) => setState(() => _draft = next);

  @override
  Widget build(BuildContext context) {
    final count = widget.countFor(_draft);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filter & Sortierung',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Schließen',
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SheetLabel('Sortieren nach'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final sort in RecipeSort.values)
                            RecipeChoiceChip(
                              key: ValueKey('recipe-sort-${sort.name}'),
                              label: sort.label,
                              selected: _draft.sort == sort,
                              onSelected: () =>
                                  _set(_draft.copyWith(sort: sort)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const _SheetLabel('Maximale Zubereitungszeit'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          RecipeChoiceChip(
                            label: 'Egal',
                            selected: _draft.maxMinutes == null,
                            onSelected: () =>
                                _set(_draft.copyWith(maxMinutes: null)),
                          ),
                          for (final minutes in recipeTimeLimits)
                            RecipeChoiceChip(
                              key: ValueKey('recipe-time-$minutes'),
                              label: 'bis $minutes Min.',
                              selected: _draft.maxMinutes == minutes,
                              onSelected: () =>
                                  _set(_draft.copyWith(maxMinutes: minutes)),
                            ),
                        ],
                      ),
                      if (widget.difficulties.length > 1) ...[
                        const SizedBox(height: 22),
                        const _SheetLabel('Schwierigkeit'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            RecipeChoiceChip(
                              label: 'Egal',
                              selected: _draft.difficulty == null,
                              onSelected: () =>
                                  _set(_draft.copyWith(difficulty: null)),
                            ),
                            for (final level in widget.difficulties)
                              RecipeChoiceChip(
                                label: level,
                                selected: _draft.difficulty == level,
                                onSelected: () =>
                                    _set(_draft.copyWith(difficulty: level)),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: _draft.sheetCount == 0
                        ? null
                        : () => _set(_draft.withoutSheetOptions()),
                    child: const Text('Zurücksetzen'),
                  ),
                  FilledButton(
                    key: const Key('recipe-filter-apply'),
                    onPressed: () => Navigator.pop(context, _draft),
                    child: Text(
                      count == 1
                          ? '1 Rezept anzeigen'
                          : '$count Rezepte anzeigen',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}
