import 'package:fitness_ai_app/core/models/progress_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Fortschritt berechnet nur wirklich getrackte Tage', () {
    final snapshot = ProgressSnapshot(
      nutrition: [
        NutritionDay(
          date: DateTime(2026, 9, 20),
          calories: 2000,
          protein: 140,
          carbs: 210,
          fat: 65,
          mealCount: 4,
        ),
        NutritionDay(
          date: DateTime(2026, 9, 21),
          calories: 0,
          protein: 0,
          carbs: 0,
          fat: 0,
          mealCount: 0,
        ),
      ],
      weights: const [],
    );

    expect(snapshot.trackedDayCount, 1);
    expect(snapshot.mealCount, 4);
    expect(snapshot.average((day) => day.protein), 140);
    expect(snapshot.calorieGoalDays(2100), 1);
    expect(snapshot.proteinGoalDays(140), 1);
  });

  test('Zeiträume enthalten kurze und langfristige Auswahl', () {
    expect(ProgressPeriod.values.map((value) => value.label), [
      '7 Tage',
      '30 Tage',
      '3 Monate',
      '6 Monate',
      '1 Jahr',
      'Alles',
    ]);
    expect(
      ProgressPeriod.sevenDays.start(DateTime(2026, 9, 22)),
      DateTime(2026, 9, 16),
    );
  });
}
