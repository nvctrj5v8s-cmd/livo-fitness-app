import 'package:flutter/material.dart';

import '../../../core/data/food_search_service.dart';
import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';

class FoodDetailPage extends StatefulWidget {
  const FoodDetailPage({
    required this.food,
    required this.date,
    this.initialSlot = MealSlot.snack,
    this.initialAmountGrams = 100,
    super.key,
  });

  final FoodItem food;
  final DateTime date;
  final MealSlot initialSlot;
  final double initialAmountGrams;

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  late MealSlot _slot;
  late double _amountGrams;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _slot = widget.initialSlot;
    _amountGrams = widget.initialAmountGrams > 0
        ? widget.initialAmountGrams
        : widget.food.servingGrams;
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final food = widget.food;
    final factor = _amountGrams / food.servingGrams;
    final germanHint = FoodSearchService.germanHint(food);
    final isSaved = controller.foodFavoriteIds.contains(food.id);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lebensmittel'),
        actions: [
          IconButton(
            tooltip: isSaved ? 'Von Merkliste entfernen' : 'Merken',
            onPressed: () => controller.toggleFoodFavorite(food.id),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                key: ValueKey(isSaved),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SurfaceCard(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.surfaceHigh,
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.restaurant_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (germanHint != null) ...[
                                Text(
                                  germanHint,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                              ],
                              Text(
                                food.name,
                                style: TextStyle(
                                  color: germanHint == null
                                      ? AppColors.text
                                      : AppColors.textMuted,
                                  fontSize: germanHint == null ? 17 : 12,
                                  fontWeight: germanHint == null
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                ),
                              ),
                              if (food.brand != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  food.brand!,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusPill(
                        label: FoodSearchService.sourceLabel(
                          food,
                        ).toUpperCase(),
                        icon: Icons.verified_outlined,
                        color: AppColors.blue,
                      ),
                      StatusPill(
                        label: 'BASIS: ${food.servingGrams.round()} G',
                        icon: Icons.scale_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const SectionHeader(title: 'Nährwerte'),
                  const SizedBox(height: 9),
                  _NutrientGrid(food: food, factor: factor),
                  if (food.hasBarcodeDetails) ...[
                    const SizedBox(height: 26),
                    _BarcodeProductFacts(food: food),
                  ],
                  const SizedBox(height: 26),
                  Text('Menge', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _amountOptions(food.servingGrams).map((grams) {
                      return ChoiceChip(
                        label: Text('${grams.toInt()} g'),
                        selected: _amountGrams == grams,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _amountGrams = grams),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Mahlzeit',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 9),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: MealSlot.values
                          .map(
                            (slot) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(slot.label),
                                selected: _slot == slot,
                                showCheckmark: false,
                                onSelected: (_) => setState(() => _slot = slot),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_rounded),
                      label: Text(
                        _saving
                            ? 'Wird gespeichert ...'
                            : 'Zum Tagebuch hinzufügen',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<double> _amountOptions(double servingGrams) {
    final options = <double>[25, 50, 75, 100, 150, 200, 250, 300];
    if (!options.contains(servingGrams)) options.add(servingGrams);
    options.sort();
    return options;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final saved = await AppScope.of(context).addFoodToDiary(
      food: widget.food,
      slot: _slot,
      amountGrams: _amountGrams,
      date: widget.date,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppScope.of(context).diaryError ??
                'Das Lebensmittel konnte nicht gespeichert werden.',
          ),
        ),
      );
      return;
    }
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.food.name} wurde hinzugefügt.')),
    );
  }
}

class _NutrientGrid extends StatelessWidget {
  const _NutrientGrid({required this.food, required this.factor});

  final FoodItem food;
  final double factor;

  @override
  Widget build(BuildContext context) {
    final values = <(String, String, Color)>[
      (
        'Kalorien',
        '${(food.calories * factor).round()} kcal',
        AppColors.orange,
      ),
      ('Protein', '${(food.protein * factor).round()} g', AppColors.mint),
      (
        'Kohlenhydrate',
        '${(food.carbohydrates * factor).round()} g',
        AppColors.blue,
      ),
      ('Fett', '${(food.fat * factor).round()} g', AppColors.purple),
    ];
    if (food.saturatedFat != null) {
      values.add((
        'gesättigte Fettsäuren',
        '${(food.saturatedFat! * factor).toStringAsFixed(1)} g',
        AppColors.orange,
      ));
    }
    if (food.sugar != null) {
      values.add((
        'Zucker',
        '${(food.sugar! * factor).toStringAsFixed(1)} g',
        AppColors.purple,
      ));
    }
    if (food.fiber != null) {
      values.add((
        'Ballaststoffe',
        '${(food.fiber! * factor).toStringAsFixed(1)} g',
        AppColors.mint,
      ));
    }
    if (food.salt != null) {
      values.add((
        'Salz',
        '${(food.salt! * factor).toStringAsFixed(2)} g',
        AppColors.blue,
      ));
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: values
          .map(
            (value) => SizedBox(
              width: (MediaQuery.sizeOf(context).width - 50) / 2,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: value.$3.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: value.$3.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value.$1,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value.$2,
                      style: TextStyle(
                        color: value.$3,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BarcodeProductFacts extends StatelessWidget {
  const _BarcodeProductFacts({required this.food});

  final FoodItem food;

  String _cleanTag(String value) => value.contains(':')
      ? value.substring(value.indexOf(':') + 1).replaceAll('-', ' ')
      : value.replaceAll('-', ' ');

  @override
  Widget build(BuildContext context) {
    final hasIngredients = food.ingredientsText?.trim().isNotEmpty == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Produktinfos'),
        const SizedBox(height: 9),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (food.nutriScore != null)
                    StatusPill(
                      label: 'NUTRI-SCORE ${food.nutriScore!.toUpperCase()}',
                      icon: Icons.info_outline_rounded,
                      color: AppColors.primary,
                    ),
                  if (food.novaGroup != null)
                    StatusPill(
                      label: 'NOVA ${food.novaGroup}',
                      icon: Icons.category_outlined,
                      color: AppColors.orange,
                    ),
                  if (food.quantity != null && food.quantity!.trim().isNotEmpty)
                    StatusPill(
                      label: food.quantity!.toUpperCase(),
                      icon: Icons.inventory_2_outlined,
                    ),
                ],
              ),
              if (food.barcode != null) ...[
                const SizedBox(height: 14),
                Text(
                  'Barcode: ${food.barcode}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
              if (food.allergens.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Allergene laut Produktdaten',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: food.allergens
                      .map(
                        (allergen) => Chip(
                          avatar: const Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: AppColors.orange,
                          ),
                          label: Text(_cleanTag(allergen)),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (hasIngredients) ...[
                const SizedBox(height: 14),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text(
                    'Zutatenliste',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SelectableText(food.ingredientsText!),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Quelle: Open Food Facts. Angaben können fehlen oder sich ändern – bei Allergien und Unverträglichkeiten immer das Verpackungsetikett prüfen.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
