import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/theme/app_colors.dart';
import 'add_meal_sheet.dart';
import 'barcode_scanner_page.dart';
import 'food_detail_page.dart';
import 'meal_photo_page.dart';

enum QuickAddOption { photo, barcode, manual }

MealSlot mealSlotForTime(DateTime time) {
  final hour = time.hour;
  if (hour >= 5 && hour < 11) return MealSlot.breakfast;
  if (hour >= 11 && hour < 16) return MealSlot.lunch;
  if (hour >= 17 && hour < 22) return MealSlot.dinner;
  return MealSlot.snack;
}

Future<void> showQuickAddSheet(BuildContext context) async {
  final option = await showModalBottomSheet<QuickAddOption>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    barrierColor: Colors.black.withValues(alpha: .68),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _QuickAddSheet(),
  );
  if (option == null || !context.mounted) return;

  final now = DateTime.now();
  final slot = mealSlotForTime(now);
  final navigator = Navigator.of(context);
  switch (option) {
    case QuickAddOption.photo:
      await navigator.push<bool>(
        MaterialPageRoute(
          builder: (_) => MealPhotoPage(initialSlot: slot, date: now),
        ),
      );
    case QuickAddOption.barcode:
      final food = await navigator.push<FoodItem>(
        MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
      );
      if (food == null || !context.mounted) return;
      await navigator.push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              FoodDetailPage(food: food, date: now, initialSlot: slot),
        ),
      );
    case QuickAddOption.manual:
      await showAddMealSheet(context, date: now, initialSlot: slot);
  }
}

class _QuickAddSheet extends StatelessWidget {
  const _QuickAddSheet();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderBright,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mahlzeit hinzufügen',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          const _QuickAddTile(
            key: Key('quick-add-photo'),
            option: QuickAddOption.photo,
            icon: Icons.photo_camera_rounded,
            title: 'KI-Foto',
            subtitle: 'Foto machen, KI schätzt Lebensmittel und Mengen',
          ),
          const SizedBox(height: 10),
          const _QuickAddTile(
            key: Key('quick-add-barcode'),
            option: QuickAddOption.barcode,
            icon: Icons.qr_code_scanner_rounded,
            title: 'Barcode scannen',
            subtitle: 'Verpacktes Produkt über den Barcode finden',
          ),
          const SizedBox(height: 10),
          const _QuickAddTile(
            key: Key('quick-add-manual'),
            option: QuickAddOption.manual,
            icon: Icons.edit_note_rounded,
            title: 'Manuell eintragen',
            subtitle: 'Lebensmittel suchen oder selbst eintragen',
          ),
        ],
      ),
    );
  }
}

class _QuickAddTile extends StatelessWidget {
  const _QuickAddTile({
    required this.option,
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final QuickAddOption option;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surfaceHigh,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.pop(context, option),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: SizedBox.square(
                dimension: 46,
                child: Icon(icon, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    ),
  );
}
