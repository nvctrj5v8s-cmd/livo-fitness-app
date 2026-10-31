import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/core/theme/app_colors.dart';
import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/features/diary/presentation/add_meal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Knopftexte nennen die Schrift ausdrücklich (keine leeren Kästchen)',
    () {
      final style = AppTheme.dark.filledButtonTheme.style!.textStyle!.resolve(
        <WidgetState>{},
      )!;
      expect(style.fontFamily, isNotNull);
      expect(style.fontFamily, isNotEmpty);
      expect(style.fontWeight, FontWeight.w800);
    },
  );

  testWidgets('Lebensmittelauswahl verwendet grüne Filter und Plusknöpfe', (
    tester,
  ) async {
    final app = AppController();
    addTearDown(app.dispose);
    await tester.pumpWidget(
      AppScope(
        controller: app,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAddMealSheet(context),
                child: const Text('Öffnen'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Öffnen'));
    await tester.pumpAndSettle();
    final selectedFilter = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .singleWhere((chip) => chip.selected);
    expect(selectedFilter.selectedColor, AppColors.primary);
    final add = tester.widget<IconButton>(
      find.byKey(const ValueKey('add-food-demo-chickpeas')),
    );
    expect(add.style!.backgroundColor!.resolve({}), AppColors.primary);
    expect(add.style!.foregroundColor!.resolve({}), AppColors.black);
    expect(tester.takeException(), isNull);
  });
}
