import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../application/planning_controller.dart';
import '../domain/ingredient_match.dart';
import '../domain/kitchen_planning.dart';
import '../domain/shopping_aisles.dart';
import 'kitchen_format.dart';
import 'kitchen_widgets.dart';
import 'planning_sheets.dart' show showWeekPlanSheet;

Future<void> showShoppingSheet(BuildContext context, AppController controller) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ShoppingSheet(controller: controller),
  );
}

IconData shoppingAisleIcon(ShoppingAisle aisle) => switch (aisle) {
  ShoppingAisle.produce => Icons.eco_outlined,
  ShoppingAisle.bakery => Icons.bakery_dining_outlined,
  ShoppingAisle.dairy => Icons.egg_outlined,
  ShoppingAisle.meatFish => Icons.set_meal_outlined,
  ShoppingAisle.dryGoods => Icons.rice_bowl_outlined,
  ShoppingAisle.canned => Icons.inventory_2_outlined,
  ShoppingAisle.oilsSpices => Icons.water_drop_outlined,
  ShoppingAisle.frozen => Icons.ac_unit_rounded,
  ShoppingAisle.drinks => Icons.local_drink_outlined,
  ShoppingAisle.other => Icons.shopping_basket_outlined,
};

Color shoppingAisleColor(ShoppingAisle aisle) => switch (aisle) {
  ShoppingAisle.produce => AppColors.mint,
  ShoppingAisle.bakery => AppColors.orange,
  ShoppingAisle.dairy => AppColors.blue,
  ShoppingAisle.meatFish => AppColors.purple,
  ShoppingAisle.dryGoods => AppColors.primary,
  ShoppingAisle.canned => AppColors.cyan,
  ShoppingAisle.oilsSpices => AppColors.orange,
  ShoppingAisle.frozen => AppColors.blue,
  ShoppingAisle.drinks => AppColors.cyan,
  ShoppingAisle.other => AppColors.textMuted,
};

/// Short message at the bottom of the sheet, optionally with "Rückgängig".
class _Toast {
  const _Toast(this.id, this.text, [this.undo]);

  final int id;
  final String text;
  final VoidCallback? undo;
}

class _ShoppingSheet extends StatefulWidget {
  const _ShoppingSheet({required this.controller});
  final AppController controller;

  @override
  State<_ShoppingSheet> createState() => _ShoppingSheetState();
}

class _ShoppingSheetState extends State<_ShoppingSheet>
    with SingleTickerProviderStateMixin {
  final _input = TextEditingController();
  final _focus = FocusNode();
  late final AnimationController _toastTimer =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() => _toast = null);
          }
        });

  /// Problem with the last input, shown under the field until the next try.
  String? _inputProblem;
  _Toast? _toast;
  int _toastCount = 0;
  bool _cartOpen = true;

  /// Tiles already shown once; only new ones animate in.
  final _shown = <String>{};
  bool _firstFrame = true;

  PlanningController get _planning => widget.controller.planning;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _firstFrame = false);
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    _toastTimer.dispose();
    super.dispose();
  }

  void _showToast(String text, {VoidCallback? undo}) {
    setState(() => _toast = _Toast(_toastCount++, text, undo));
    unawaited(_toastTimer.forward(from: 0));
  }

  void _hideToast() {
    _toastTimer.stop();
    setState(() => _toast = null);
  }

  void _add(String name, String amountText) {
    if (name.trim().isEmpty) return;
    final result = _planning.addShoppingItem(name, amountText: amountText);
    setState(() {
      _inputProblem = switch (result.status) {
        KitchenEditStatus.added || KitchenEditStatus.merged => null,
        KitchenEditStatus.duplicate =>
          '„${name.trim()}“ steht schon auf der Liste.',
        _ => result.message,
      };
    });
    if (result.changed) _input.clear();
  }

  void _submit() {
    final parsed = splitShoppingInput(_input.text);
    _add(parsed.name, parsed.amountText);
  }

  void _forget(String id) => _shown.removeWhere((key) => key.endsWith('-$id'));

  void _toggle(ShoppingItem item) {
    _forget(item.id);
    unawaited(HapticFeedback.selectionClick());
    _planning.toggleShoppingItem(item.id);
  }

  void _remove(ShoppingItem item) {
    final index = _planning.shopping.indexWhere((e) => e.id == item.id);
    if (index < 0) return;
    _forget(item.id);
    _planning.removeShoppingItem(item.id);
    _showToast(
      '„${item.name}“ entfernt.',
      undo: () {
        _planning.restoreShoppingItem(item, index);
        _hideToast();
      },
    );
  }

  void _moveToPantry() {
    final moved = _planning.moveCheckedToPantryItems();
    if (moved == 0) return;
    _showToast(
      '${countText(moved, 'Artikel', 'Artikel')} in deine Vorräte übernommen.',
    );
  }

  void _clearChecked() {
    final removed = _planning.clearCheckedShopping();
    if (removed == 0) return;
    _showToast(
      '${countText(removed, 'erledigter Artikel', 'erledigte Artikel')} '
      'entfernt.',
    );
  }

  Future<void> _clearAll() async {
    final confirmed = await confirmKitchenAction(
      context,
      title: 'Einkaufsliste leeren?',
      body: 'Alle Einträge werden entfernt, auch noch offene.',
      action: 'Leeren',
    );
    if (!confirmed || !mounted) return;
    _planning.clearShopping();
    _showToast('Die Einkaufsliste ist leer.');
  }

  Future<void> _copy() async {
    await Clipboard.setData(
      ClipboardData(text: shoppingListAsText(_planning.shopping)),
    );
    if (!mounted) return;
    _showToast('Liste kopiert – du kannst sie jetzt in einen Chat einfügen.');
  }

  Future<void> _edit(ShoppingItem item) async {
    final delete = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ShoppingEditSheet(item: item, planning: _planning),
    );
    if (delete == true && mounted) _remove(item);
  }

  Widget _tile(ShoppingItem item, int index) {
    final key = '${item.done ? 'done' : 'open'}-${item.id}';
    final animate = !_shown.contains(key);
    _shown.add(key);
    return KitchenAppear(
      key: ValueKey('appear-$key'),
      animate: animate,
      delay: _firstFrame
          ? Duration(milliseconds: 40 * math.min(index, 8))
          : Duration.zero,
      child: _ShoppingTile(
        item: item,
        onToggle: () => _toggle(item),
        onRemove: () => _remove(item),
        onEdit: () => unawaited(_edit(item)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _planning,
      builder: (context, _) {
        final items = _planning.shopping;
        final open = [
          for (final item in items)
            if (!item.done) item,
        ];
        final done = [
          for (final item in items)
            if (item.done) item,
        ];
        final groups = groupShoppingByAisle(open);
        final ready = _planning.ready;
        var index = 0;
        return KitchenSheetFrame(
          title: 'Einkaufsliste',
          subtitle: items.isEmpty
              ? 'Noch nichts auf der Liste'
              : open.isEmpty
              ? 'Alles im Wagen'
              : '${countText(open.length, 'Artikel', 'Artikel')} offen'
                    '${done.isEmpty ? '' : ' · ${done.length} im Wagen'}',
          headerTrailing: ready && items.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ProgressRing(done: done.length, total: items.length),
                    _ShoppingMenu(
                      canCopy: open.isNotEmpty,
                      canClearChecked: done.isNotEmpty,
                      onCopy: () => unawaited(_copy()),
                      onClearChecked: _clearChecked,
                      onClearAll: () => unawaited(_clearAll()),
                    ),
                  ],
                )
              : null,
          top: ready
              ? _SmartInput(
                  controller: _input,
                  focusNode: _focus,
                  recipes: widget.controller.recipes,
                  onList: open,
                  problem: _inputProblem,
                  onSubmit: _submit,
                  onAdd: _add,
                )
              : null,
          bottom: _BottomArea(
            toast: _toast,
            timer: _toastTimer,
            checked: ready ? done.length : 0,
            onMove: _moveToPantry,
            onClearChecked: _clearChecked,
          ),
          children: [
            KitchenStorageStatus(planning: _planning, showNote: false),
            if (ready) ...[
              if (items.isEmpty)
                _EmptyShopping(
                  onOpenPlan: () =>
                      unawaited(showWeekPlanSheet(context, widget.controller)),
                )
              else if (open.isEmpty)
                _AllInCart(count: done.length),
              for (final (aisle, entries) in groups) ...[
                _AisleHeader(aisle: aisle, count: entries.length),
                for (final item in entries) _tile(item, index++),
                const SizedBox(height: 8),
              ],
              if (done.isNotEmpty) ...[
                _CartHeader(
                  count: done.length,
                  expanded: _cartOpen,
                  onTap: () => setState(() => _cartOpen = !_cartOpen),
                ),
                if (_cartOpen)
                  for (final item in done) _tile(item, index++),
              ],
            ],
            const SizedBox(height: 18),
            KitchenStorageNote(planning: _planning),
          ],
        );
      },
    );
  }
}

// --- Header --------------------------------------------------------------------

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : done / total;
    final complete = total > 0 && done == total;
    return Semantics(
      label: '$done von $total im Wagen',
      excludeSemantics: true,
      child: SizedBox(
        key: const Key('shopping-progress'),
        width: 46,
        height: 46,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: fraction),
          duration: kitchenMotion(context, const Duration(milliseconds: 520)),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 4.5,
                strokeCap: StrokeCap.round,
                backgroundColor: AppColors.border,
                color: complete ? AppColors.mint : AppColors.primary,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: FittedBox(
                    child: complete
                        ? const Icon(Icons.check_rounded, color: AppColors.mint)
                        : Text(
                            '$done/$total',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShoppingMenu extends StatelessWidget {
  const _ShoppingMenu({
    required this.canCopy,
    required this.canClearChecked,
    required this.onCopy,
    required this.onClearChecked,
    required this.onClearAll,
  });

  final bool canCopy;
  final bool canClearChecked;
  final VoidCallback onCopy;
  final VoidCallback onClearChecked;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      key: const Key('shopping-menu'),
      tooltip: 'Weitere Aktionen',
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (value) => switch (value) {
        'copy' => onCopy(),
        'checked' => onClearChecked(),
        _ => onClearAll(),
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          key: const Key('shopping-copy'),
          value: 'copy',
          enabled: canCopy,
          child: const ListTile(
            leading: Icon(Icons.copy_rounded),
            title: Text('Liste als Text kopieren'),
          ),
        ),
        PopupMenuItem(
          value: 'checked',
          enabled: canClearChecked,
          child: const ListTile(
            leading: Icon(Icons.remove_done_rounded),
            title: Text('Erledigte löschen'),
          ),
        ),
        const PopupMenuItem(
          key: Key('shopping-clear-all'),
          value: 'all',
          child: ListTile(
            leading: Icon(Icons.delete_outline_rounded, color: AppColors.error),
            title: Text('Liste leeren'),
          ),
        ),
      ],
    );
  }
}

// --- Input -----------------------------------------------------------------------

/// One field for name and amount: "500 g Reis", "Milch 1 l" or "2 Eier".
/// Shows how the input is read, and quick picks while it is empty.
class _SmartInput extends StatelessWidget {
  const _SmartInput({
    required this.controller,
    required this.focusNode,
    required this.recipes,
    required this.onList,
    required this.problem,
    required this.onSubmit,
    required this.onAdd,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<Recipe> recipes;
  final List<ShoppingItem> onList;
  final String? problem;
  final VoidCallback onSubmit;
  final void Function(String name, String amountText) onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('shopping-input'),
          controller: controller,
          focusNode: focusNode,
          maxLength: kitchenNameMaxLength + 20,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => onSubmit(),
          // Keeps the keyboard open for the next item.
          onEditingComplete: () {},
          decoration: InputDecoration(
            hintText: 'z. B. 500 g Reis oder 2 Eier',
            counterText: '',
            prefixIcon: const Icon(Icons.add_shopping_cart_rounded),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(6),
              child: IconButton.filled(
                key: const Key('shopping-add'),
                onPressed: onSubmit,
                tooltip: 'Hinzufügen',
                icon: const Icon(Icons.add_rounded),
              ),
            ),
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final text = value.text.trim();
            return AnimatedSwitcher(
              duration: kitchenMotion(
                context,
                const Duration(milliseconds: 200),
              ),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              ),
              child: text.isEmpty
                  ? _QuickPicks(
                      key: const ValueKey('quick'),
                      onList: onList,
                      onPick: (name) => onAdd(name, ''),
                    )
                  : _InputPreview(
                      key: const ValueKey('preview'),
                      input: splitShoppingInput(text),
                      suggestions: ingredientSuggestions(
                        recipes,
                        splitShoppingInput(text).name,
                        exclude: [for (final item in onList) item.name],
                        limit: 4,
                      ),
                      onPick: onAdd,
                    ),
            );
          },
        ),
        if (problem != null) ...[
          const SizedBox(height: 6),
          KitchenFeedback(text: problem!, color: AppColors.orange),
        ],
      ],
    );
  }
}

class _QuickPicks extends StatelessWidget {
  const _QuickPicks({required this.onList, required this.onPick, super.key});

  final List<ShoppingItem> onList;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final picks = [
      for (final staple in kitchenStaples)
        if (!onList.any((item) => ingredientNamesMatch(item.name, staple)))
          staple,
    ];
    if (picks.isEmpty) return const SizedBox(width: double.infinity);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: picks.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final name = picks[index];
            final aisle = shoppingAisleFor(name);
            return ActionChip(
              key: ValueKey('shopping-quick-$name'),
              avatar: Icon(
                shoppingAisleIcon(aisle),
                size: 16,
                color: shoppingAisleColor(aisle),
              ),
              label: Text(name),
              tooltip: '$name hinzufügen',
              onPressed: () => onPick(name),
              backgroundColor: AppColors.surfaceHigh,
              side: const BorderSide(color: AppColors.border),
              shape: const StadiumBorder(),
              labelStyle: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InputPreview extends StatelessWidget {
  const _InputPreview({
    required this.input,
    required this.suggestions,
    required this.onPick,
    super.key,
  });

  final ShoppingInput input;
  final List<String> suggestions;
  final void Function(String name, String amountText) onPick;

  @override
  Widget build(BuildContext context) {
    final aisle = shoppingAisleFor(input.name);
    final color = shoppingAisleColor(aisle);
    final amount = input.amount;
    final others = [
      for (final name in suggestions)
        if (name.toLowerCase() != input.name.toLowerCase()) name,
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(shoppingAisleIcon(aisle), size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  key: const Key('shopping-preview'),
                  TextSpan(
                    children: [
                      TextSpan(
                        text: input.name,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (amount != null)
                        TextSpan(text: ' · ${formatKitchenAmount(amount)}'),
                      TextSpan(text: ' · ${shoppingAisleLabel(aisle)}'),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          if (others.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final name in others)
                  ActionChip(
                    key: ValueKey('shopping-suggestion-$name'),
                    avatar: const Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      amount == null
                          ? name
                          : '$name · ${formatKitchenAmount(amount)}',
                    ),
                    onPressed: () => onPick(name, input.amountText),
                    backgroundColor: AppColors.surfaceHigh,
                    side: const BorderSide(color: AppColors.border),
                    shape: const StadiumBorder(),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// --- List ------------------------------------------------------------------------

class _AisleHeader extends StatelessWidget {
  const _AisleHeader({required this.aisle, required this.count});

  final ShoppingAisle aisle;
  final int count;

  @override
  Widget build(BuildContext context) {
    final color = shoppingAisleColor(aisle);
    return Padding(
      key: ValueKey('shopping-aisle-${aisle.name}'),
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 8),
      child: Semantics(
        header: true,
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(shoppingAisleIcon(aisle), size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                shoppingAisleLabel(aisle),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({
    required this.count,
    required this.expanded,
    required this.onTap,
  });

  final int count;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: InkWell(
        key: const Key('shopping-cart-toggle'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.shopping_cart_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Im Wagen · $count',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: kitchenMotion(
                  context,
                  const Duration(milliseconds: 220),
                ),
                child: Icon(
                  Icons.expand_more_rounded,
                  color: AppColors.textMuted,
                  semanticLabel: expanded ? 'Einklappen' : 'Ausklappen',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One entry. Checking plays a short animation, then the entry moves to
/// "Im Wagen"; with reduced motion it moves right away.
class _ShoppingTile extends StatefulWidget {
  const _ShoppingTile({
    required this.item,
    required this.onToggle,
    required this.onRemove,
    required this.onEdit,
  });

  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  @override
  State<_ShoppingTile> createState() => _ShoppingTileState();
}

class _ShoppingTileState extends State<_ShoppingTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
  );
  late final Animation<double> _check = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.42, curve: Curves.easeOutBack),
  );
  late final Animation<double> _leave = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.58, 1, curve: Curves.easeInCubic),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tap() {
    if (_controller.isAnimating) return;
    if (widget.item.done || kitchenReduceMotion(context)) {
      widget.onToggle();
      return;
    }
    unawaited(
      _controller.forward().then((_) {
        if (mounted) widget.onToggle();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final amount = kitchenAmountLabel(item.amount, item.note);
    final aisleColor = shoppingAisleColor(shoppingAisleForItem(item));
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => SizeTransition(
        sizeFactor: ReverseAnimation(_leave),
        alignment: Alignment.topCenter,
        child: Opacity(opacity: 1 - _leave.value, child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Dismissible(
          key: ValueKey('shopping-dismiss-${item.id}'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => widget.onRemove(),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 18),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Löschen',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.delete_outline_rounded, color: AppColors.error),
              ],
            ),
          ),
          child: Material(
            color: item.done ? AppColors.surface : AppColors.surfaceHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: item.done
                    ? AppColors.border.withValues(alpha: 0.5)
                    : AppColors.border,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Semantics(
              checked: item.done,
              child: InkWell(
                key: ValueKey('shopping-item-${item.id}'),
                onTap: _tap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 2, 8),
                  child: Row(
                    children: [
                      AnimatedBuilder(
                        animation: _check,
                        builder: (context, _) =>
                            _CheckCircle(value: item.done ? 1 : _check.value),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedBuilder(
                              animation: _check,
                              builder: (context, _) {
                                final struck = item.done || _check.value > 0.5;
                                return Text(
                                  item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: struck
                                        ? AppColors.textMuted
                                        : AppColors.text,
                                    decoration: struck
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: AppColors.textMuted,
                                  ),
                                );
                              },
                            ),
                            if (item.source != null) ...[
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.menu_book_rounded,
                                    size: 12,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'für ${item.source}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (amount != null) ...[
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 130),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (item.done ? AppColors.textMuted : aisleColor)
                                      .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              amount,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: item.done
                                    ? AppColors.textMuted
                                    : aisleColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                      IconButton(
                        onPressed: widget.onEdit,
                        tooltip: '${item.name} bearbeiten',
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          color: AppColors.textMuted,
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

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.value});

  /// 0 = open, 1 = checked; may overshoot slightly while animating.
  final double value;

  @override
  Widget build(BuildContext context) {
    final t = value.clamp(0.0, 1.0);
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.lerp(Colors.transparent, AppColors.primary, t),
        border: Border.all(
          color: Color.lerp(AppColors.borderBright, AppColors.primary, t)!,
          width: 2,
        ),
      ),
      child: Transform.scale(
        scale: value.clamp(0.0, 1.3),
        child: const Icon(
          Icons.check_rounded,
          size: 17,
          color: AppColors.black,
        ),
      ),
    );
  }
}

class _EmptyShopping extends StatelessWidget {
  const _EmptyShopping({required this.onOpenPlan});

  final VoidCallback onOpenPlan;

  @override
  Widget build(BuildContext context) {
    return KitchenAppear(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.orange.withValues(alpha: 0.22),
                    AppColors.orange.withValues(alpha: 0.04),
                  ],
                ),
                border: Border.all(
                  color: AppColors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 38,
                color: AppColors.orange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Deine Einkaufsliste ist leer',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tippe oben einfach „500 g Reis“ oder „2 Eier“ – LIVO sortiert '
              'alles nach Supermarkt-Abteilung. Fehlende Zutaten kannst du '
              'auch direkt aus Rezepten oder dem Wochenplan übernehmen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, height: 1.45),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              key: const Key('shopping-open-plan'),
              onPressed: onOpenPlan,
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text('Wochenplan öffnen'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllInCart extends StatelessWidget {
  const _AllInCart({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final reduce = kitchenReduceMotion(context);
    return Container(
      key: const Key('shopping-all-done'),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.mint.withValues(alpha: 0.16),
            AppColors.primary.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: AppColors.mint.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: reduce ? 1 : 0.4, end: 1),
            duration: reduce
                ? Duration.zero
                : const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.black,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alles im Wagen!',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Übernimm ${count == 1 ? 'den Artikel' : 'die $count Artikel'} '
                  'unten in deine Vorräte – dann weißt du beim Kochen, was da '
                  'ist.',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Bottom bar --------------------------------------------------------------------

class _BottomArea extends StatelessWidget {
  const _BottomArea({
    required this.toast,
    required this.timer,
    required this.checked,
    required this.onMove,
    required this.onClearChecked,
  });

  final _Toast? toast;
  final Animation<double> timer;
  final int checked;
  final VoidCallback onMove;
  final VoidCallback onClearChecked;

  @override
  Widget build(BuildContext context) {
    final current = toast;
    final Widget child;
    if (current != null) {
      child = _ToastBar(
        key: ValueKey('toast-${current.id}'),
        toast: current,
        timer: timer,
      );
    } else if (checked > 0) {
      child = _CartBar(
        key: const ValueKey('cart-bar'),
        checked: checked,
        onMove: onMove,
        onClearChecked: onClearChecked,
      );
    } else {
      child = const SizedBox(key: ValueKey('none'), width: double.infinity);
    }
    // AnimatedSize does not accept a zero duration, so skip it entirely.
    if (kitchenReduceMotion(context)) return child;
    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.35),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({
    required this.checked,
    required this.onMove,
    required this.onClearChecked,
    super.key,
  });

  final int checked;
  final VoidCallback onMove;
  final VoidCallback onClearChecked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              key: const Key('shopping-move-to-pantry'),
              onPressed: onMove,
              icon: const Icon(Icons.kitchen_outlined, size: 20),
              label: Text(
                '$checked in Vorräte übernehmen',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            key: const Key('shopping-clear-checked'),
            onPressed: onClearChecked,
            tooltip: 'Erledigte löschen',
            style: IconButton.styleFrom(minimumSize: const Size(54, 54)),
            icon: const Icon(Icons.remove_done_rounded),
          ),
        ],
      ),
    );
  }
}

class _ToastBar extends StatelessWidget {
  const _ToastBar({required this.toast, required this.timer, super.key});

  final _Toast toast;
  final Animation<double> timer;

  @override
  Widget build(BuildContext context) {
    final undo = toast.undo;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Material(
        color: AppColors.surfaceSoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.borderBright),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14, 6, undo == null ? 14 : 4, 6),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Row(
                  children: [
                    Icon(
                      undo == null
                          ? Icons.check_circle_rounded
                          : Icons.delete_outline_rounded,
                      size: 19,
                      color: undo == null
                          ? AppColors.mint
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          toast.text,
                          key: const Key('shopping-toast'),
                          style: const TextStyle(fontSize: 13.5),
                        ),
                      ),
                    ),
                    if (undo != null)
                      TextButton(
                        key: const Key('shopping-undo'),
                        onPressed: undo,
                        child: const Text('Rückgängig'),
                      ),
                  ],
                ),
              ),
            ),
            if (!kitchenReduceMotion(context))
              AnimatedBuilder(
                animation: timer,
                builder: (context, _) => LinearProgressIndicator(
                  value: 1 - timer.value,
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Edit ----------------------------------------------------------------------------

/// Change name or amount, or delete. Returns `true` when the entry should be
/// deleted (the list then offers "Rückgängig").
class _ShoppingEditSheet extends StatefulWidget {
  const _ShoppingEditSheet({required this.item, required this.planning});

  final ShoppingItem item;
  final PlanningController planning;

  @override
  State<_ShoppingEditSheet> createState() => _ShoppingEditSheetState();
}

class _ShoppingEditSheetState extends State<_ShoppingEditSheet> {
  late final String _initialAmount =
      kitchenAmountLabel(widget.item.amount, widget.item.note) ?? '';
  late final _name = TextEditingController(text: widget.item.name);
  late final _amount = TextEditingController(text: _initialAmount);
  String? _problem;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    final result = widget.planning.updateShoppingItem(
      widget.item.id,
      name: _name.text,
      amountText: _amount.text,
      keepAmount: _amount.text.trim() == _initialAmount,
    );
    if (result.changed) {
      Navigator.pop(context);
      return;
    }
    setState(
      () => _problem = result.status == KitchenEditStatus.duplicate
          ? '„${_name.text.trim()}“ steht schon auf der Liste.'
          : result.message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Artikel bearbeiten',
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
              if (widget.item.source != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Für ${widget.item.source}',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                key: const Key('shopping-edit-name'),
                controller: _name,
                maxLength: kitchenNameMaxLength,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Artikel',
                  counterText: '',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                key: const Key('shopping-edit-amount'),
                controller: _amount,
                maxLength: 30,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                decoration: const InputDecoration(
                  labelText: 'Menge (optional)',
                  hintText: 'z. B. 500 g, 2 Stück, 1 Packung',
                  counterText: '',
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
              ),
              if (_problem != null) ...[
                const SizedBox(height: 8),
                KitchenFeedback(text: _problem!, color: AppColors.orange),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  OutlinedButton.icon(
                    key: const Key('shopping-edit-delete'),
                    onPressed: () => Navigator.pop(context, true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.5),
                      ),
                      minimumSize: const Size(52, 54),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Löschen'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      key: const Key('shopping-edit-save'),
                      onPressed: _save,
                      child: const Text('Speichern'),
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
