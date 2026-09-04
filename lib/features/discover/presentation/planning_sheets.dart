import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';

Future<void> showWeekPlanSheet(BuildContext context, AppController controller) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _WeekPlanSheet(controller: controller),
  );
}

Future<void> showShoppingSheet(BuildContext context, AppController controller) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ShoppingSheet(controller: controller),
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

class _WeekPlanSheet extends StatefulWidget {
  const _WeekPlanSheet({required this.controller});
  final AppController controller;

  @override
  State<_WeekPlanSheet> createState() => _WeekPlanSheetState();
}

class _WeekPlanSheetState extends State<_WeekPlanSheet> {
  static const _days = [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag',
  ];

  @override
  Widget build(BuildContext context) {
    final planned = widget.controller.plannedRecipeIds
        .where((id) => id != null)
        .length;
    return _SheetFrame(
      title: 'Wochenplan',
      subtitle: '$planned von 7 Tagen geplant',
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: _days.length,
        separatorBuilder: (_, _) => const SizedBox(height: 9),
        itemBuilder: (context, index) {
          final recipeId = widget.controller.plannedRecipeIds[index];
          final recipe = recipeId == null
              ? null
              : widget.controller.recipes.firstWhere(
                  (candidate) => candidate.id == recipeId,
                );
          return SurfaceCard(
            padding: const EdgeInsets.fromLTRB(15, 12, 8, 12),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: recipe == null
                        ? AppColors.surfaceHigh
                        : AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _days[index].substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      color: recipe == null
                          ? AppColors.textMuted
                          : AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _days[index],
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        recipe?.title ?? 'Noch keine Mahlzeit geplant',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Rezept für ${_days[index]} auswählen',
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.textMuted,
                  ),
                  onSelected: (value) => setState(
                    () => widget.controller.planRecipe(
                      index,
                      value == '_empty' ? null : value,
                    ),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: '_empty',
                      child: Text('Tag freilassen'),
                    ),
                    for (final option in widget.controller.recipes)
                      PopupMenuItem(
                        value: option.id,
                        child: Text(option.title),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ShoppingSheet extends StatefulWidget {
  const _ShoppingSheet({required this.controller});
  final AppController controller;

  @override
  State<_ShoppingSheet> createState() => _ShoppingSheetState();
}

class _ShoppingSheetState extends State<_ShoppingSheet> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _add() {
    if (_textController.text.trim().isEmpty) return;
    widget.controller.addShoppingItem(_textController.text);
    _textController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final open = widget.controller.shoppingItems
        .where((item) => !item.done)
        .length;
    return _SheetFrame(
      title: 'Einkaufsliste',
      subtitle: '$open Artikel offen',
      top: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _add(),
              decoration: const InputDecoration(
                hintText: 'Artikel hinzufügen',
                prefixIcon: Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
          const SizedBox(width: 9),
          IconButton.filled(
            onPressed: _add,
            tooltip: 'Artikel hinzufügen',
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      child: ListView.separated(
        itemCount: widget.controller.shoppingItems.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = widget.controller.shoppingItems[index];
          return Dismissible(
            key: ValueKey(item.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) {
              widget.controller.removeShoppingItem(item.id);
              setState(() {});
            },
            background: const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 18),
                child: Icon(Icons.delete_outline, color: AppColors.error),
              ),
            ),
            child: CheckboxListTile(
              value: item.done,
              activeColor: AppColors.primary,
              checkColor: AppColors.black,
              contentPadding: const EdgeInsets.symmetric(horizontal: 3),
              title: Text(
                item.name,
                style: TextStyle(
                  decoration: item.done ? TextDecoration.lineThrough : null,
                  color: item.done ? AppColors.textMuted : AppColors.text,
                ),
              ),
              subtitle: Text(item.amount),
              onChanged: (_) {
                widget.controller.toggleShoppingItem(item.id);
                setState(() {});
              },
            ),
          );
        },
      ),
    );
  }
}

class _PantrySheet extends StatefulWidget {
  const _PantrySheet({required this.controller});
  final AppController controller;

  @override
  State<_PantrySheet> createState() => _PantrySheetState();
}

class _PantrySheetState extends State<_PantrySheet> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _add() {
    if (_textController.text.trim().isEmpty) return;
    widget.controller.addPantryItem(_textController.text);
    _textController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Meine Vorräte',
      subtitle: '${widget.controller.pantryItems.length} Zutaten verfügbar',
      top: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _add(),
              decoration: const InputDecoration(
                hintText: 'Zutat eintragen',
                prefixIcon: Icon(Icons.kitchen_outlined),
              ),
            ),
          ),
          const SizedBox(width: 9),
          IconButton.filled(
            onPressed: _add,
            tooltip: 'Zutat hinzufügen',
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      child: ListView.separated(
        itemCount: widget.controller.pantryItems.length,
        separatorBuilder: (_, _) => const SizedBox(height: 9),
        itemBuilder: (context, index) {
          final item = widget.controller.pantryItems[index];
          return SurfaceCard(
            padding: const EdgeInsets.fromLTRB(15, 8, 6, 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.mint),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        item.amount,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    widget.controller.removePantryItem(item.id);
                    setState(() {});
                  },
                  tooltip: '${item.name} entfernen',
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({
    required this.title,
    required this.subtitle,
    required this.child,
    this.top,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? top;

  @override
  Widget build(BuildContext context) {
    final height = math.min(MediaQuery.sizeOf(context).height * 0.84, 720.0);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              20 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 3),
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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Schließen',
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                if (top != null) ...[const SizedBox(height: 16), top!],
                const SizedBox(height: 16),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
