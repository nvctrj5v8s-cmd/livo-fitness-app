enum ProgressPeriod {
  sevenDays('7 Tage', 7),
  thirtyDays('30 Tage', 30),
  threeMonths('3 Monate', 90),
  sixMonths('6 Monate', 180),
  oneYear('1 Jahr', 365),
  all('Alles', null);

  const ProgressPeriod(this.label, this.days);
  final String label;
  final int? days;

  DateTime start(DateTime end) {
    final count = days;
    if (count == null) return DateTime(2020);
    return DateTime(end.year, end.month, end.day - count + 1);
  }
}

class NutritionDay {
  const NutritionDay({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealCount,
  });

  final DateTime date;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final int mealCount;
  bool get tracked => mealCount > 0;
}

class WeightRecord {
  const WeightRecord({
    required this.id,
    required this.date,
    required this.weightKg,
    this.waistCm,
  });

  final String id;
  final DateTime date;
  final double weightKg;
  final double? waistCm;
}

class ProgressSnapshot {
  const ProgressSnapshot({required this.nutrition, required this.weights});

  final List<NutritionDay> nutrition;
  final List<WeightRecord> weights;

  List<NutritionDay> get trackedDays =>
      nutrition.where((day) => day.tracked).toList(growable: false);

  int get trackedDayCount => trackedDays.length;
  int get mealCount => trackedDays.fold(0, (sum, day) => sum + day.mealCount);

  double average(double Function(NutritionDay day) value) {
    final days = trackedDays;
    if (days.isEmpty) return 0;
    return days.fold<double>(0, (sum, day) => sum + value(day)) / days.length;
  }

  double adherence({required int calorieGoal, required int proteinGoal}) {
    final days = trackedDays;
    if (days.isEmpty) return 0;
    var points = 0.0;
    for (final day in days) {
      final calorieDistance = (day.calories - calorieGoal).abs() / calorieGoal;
      final calorieScore = (1 - calorieDistance).clamp(0.0, 1.0);
      final proteinScore = (day.protein / proteinGoal).clamp(0.0, 1.0);
      points += calorieScore * 0.6 + proteinScore * 0.4;
    }
    return points / days.length;
  }

  int calorieGoalDays(int goal) => trackedDays
      .where((day) => (day.calories - goal).abs() <= goal * 0.1)
      .length;

  int proteinGoalDays(int goal) =>
      trackedDays.where((day) => day.protein >= goal * 0.9).length;
}
