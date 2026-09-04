import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/status_pill.dart';

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

  static const _foods = [
    ('Hähnchen-Reis-Bowl', 540, 46, 58, 13, MealSlot.lunch),
    ('Vollkornbrot mit Ei', 360, 24, 34, 14, MealSlot.breakfast),
    ('Griechischer Joghurt', 220, 23, 18, 7, MealSlot.snack),
    ('Protein-Pasta', 570, 38, 72, 15, MealSlot.dinner),
    ('Gemüse-Omelett', 390, 32, 18, 21, MealSlot.dinner),
  ];

  @override
  Widget build(BuildContext context) {
    final results = _foods
        .where((food) => food.$1.toLowerCase().contains(_query.toLowerCase()))
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
            const Text('Lokale Demo-Suche – funktioniert bereits ohne Konto.'),
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
                    title: Text(food.$1),
                    subtitle: Text('${food.$2} kcal · ${food.$3} g Protein'),
                    trailing: const Icon(
                      Icons.add_circle_rounded,
                      color: AppColors.primary,
                    ),
                    onTap: () {
                      AppScope.of(context).addMeal(
                        MealEntry(
                          id: '${food.$1}-${DateTime.now().microsecondsSinceEpoch}',
                          name: food.$1,
                          calories: food.$2,
                          protein: food.$3,
                          carbs: food.$4,
                          fat: food.$5,
                          slot: food.$6,
                        ),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${food.$1} wurde hinzugefügt.'),
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
