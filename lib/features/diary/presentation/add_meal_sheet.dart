import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/status_pill.dart';
import 'barcode_scanner_page.dart';

Future<void> showAddMealSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _AddMealSheet(),
  );
}

class _AddMealSheet extends StatefulWidget {
  const _AddMealSheet();

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  String _query = '';

  static const _demoFoods = [
    FoodItem(
      id: 'demo-chicken',
      name: 'H\u00e4hnchen-Reis-Bowl',
      servingGrams: 1,
      calories: 540,
      protein: 46,
      carbohydrates: 58,
      fat: 13,
    ),
    FoodItem(
      id: 'demo-bread',
      name: 'Vollkornbrot mit Ei',
      servingGrams: 1,
      calories: 360,
      protein: 24,
      carbohydrates: 34,
      fat: 14,
    ),
    FoodItem(
      id: 'demo-yogurt',
      name: 'Griechischer Joghurt',
      servingGrams: 1,
      calories: 220,
      protein: 23,
      carbohydrates: 18,
      fat: 7,
    ),
    FoodItem(
      id: 'demo-pasta',
      name: 'Protein-Pasta',
      servingGrams: 1,
      calories: 570,
      protein: 38,
      carbohydrates: 72,
      fat: 15,
    ),
    FoodItem(
      id: 'demo-omelet',
      name: 'Gem\u00fcse-Omelett',
      servingGrams: 1,
      calories: 390,
      protein: 32,
      carbohydrates: 18,
      fat: 21,
    ),
  ];

  // Kept for backwards-compatible demo copy in older builds.
  // ignore: unused_field
  static const _foods = [
    ('Hähnchen-Reis-Bowl', 540, 46, 58, 13, MealSlot.lunch),
    ('Vollkornbrot mit Ei', 360, 24, 34, 14, MealSlot.breakfast),
    ('Griechischer Joghurt', 220, 23, 18, 7, MealSlot.snack),
    ('Protein-Pasta', 570, 38, 72, 15, MealSlot.dinner),
    ('Gemüse-Omelett', 390, 32, 18, 21, MealSlot.dinner),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final sourceFoods = controller.foods.isEmpty ? _demoFoods : controller.foods;
    final results = sourceFoods
        .where((food) => food.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mahlzeit hinzufügen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 7),
            Text(controller.catalogLoading
                ? 'Lebensmittel werden aus deiner Datenbank geladen ...'
                : controller.foods.isEmpty
                    ? 'Lokale Demo-Suche \u2013 funktioniert bereits ohne Konto.'
                    : 'Lebensmittel aus deiner LIVO-Datenbank'),
            const SizedBox(height: 18),
            TextField(
              autofocus: false,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Lebensmittel oder Gericht suchen',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final food = await Navigator.of(context).push<FoodItem>(
                  MaterialPageRoute(
                    builder: (_) => const BarcodeScannerPage(),
                  ),
                );
                if (!context.mounted || food == null) return;
                AppScope.of(context).addMeal(
                  MealEntry(
                    id: '${food.id}-${DateTime.now().microsecondsSinceEpoch}',
                    name: food.name,
                    calories: food.calories.round(),
                    protein: food.protein.round(),
                    carbs: food.carbohydrates.round(),
                    fat: food.fat.round(),
                    slot: MealSlot.snack,
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Barcode scannen'),
            ),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusPill(
                  label: 'BARCODE · SPÄTER',
                  icon: Icons.qr_code_scanner_rounded,
                  color: AppColors.blue,
                ),
                StatusPill(
                  label: 'KI-FOTO · SPÄTER',
                  icon: Icons.camera_alt_outlined,
                  color: AppColors.purple,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: results.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final food = results[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    leading: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(food.name),
                    subtitle: Text(
                      '${food.calories.round()} kcal · ${food.protein.round()} g Protein',
                    ),
                    trailing: const Icon(
                      Icons.add_circle_rounded,
                      color: AppColors.primary,
                    ),
                    onTap: () {
                      AppScope.of(context).addMeal(
                        MealEntry(
                          id: '${food.id}-${DateTime.now().microsecondsSinceEpoch}',
                          name: food.name,
                          calories: food.calories.round(),
                          protein: food.protein.round(),
                          carbs: food.carbohydrates.round(),
                          fat: food.fat.round(),
                          slot: MealSlot.snack,
                        ),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${food.name} wurde hinzugefügt.'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
