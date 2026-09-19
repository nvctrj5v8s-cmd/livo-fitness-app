import 'package:fitness_ai_app/core/models/custom_food.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomFoodNutrition', () {
    test('berechnet gegessene Menge ohne Zwischenrundung', () {
      const value = CustomFoodNutrition(
        basis: NutritionBasis.per100g,
        amount: 35,
        calories: 530,
        protein: 7.2,
        carbohydrates: 61.5,
        fat: 28.4,
        sugar: 42,
        saturatedFat: 12,
        salt: .3,
      );
      expect(value.validate(requireLabelValues: true), isNull);
      expect(value.totalCalories, closeTo(185.5, .001));
      expect(value.totalProtein, closeTo(2.52, .001));
      expect(value.totalCarbohydrates, closeTo(21.525, .001));
      expect(value.totalFat, closeTo(9.94, .001));
    });

    test('JSON-Runde erhält Basis, Menge und optionale Werte', () {
      const original = CustomFoodNutrition(
        basis: NutritionBasis.per100ml,
        amount: 250,
        calories: 46,
        protein: 3.4,
        carbohydrates: 4.8,
        fat: 1.5,
        sugar: 4.8,
        saturatedFat: 1,
        salt: .1,
        fiber: .2,
      );
      final restored = CustomFoodNutrition.fromJson(original.toJson());
      expect(restored.basis, NutritionBasis.per100ml);
      expect(restored.amount, 250);
      expect(restored.totalCalories, 115);
      expect(restored.fiber, .2);
    });

    test('weist unmögliche Werte zurück und akzeptiert Dezimalkomma', () {
      const value = CustomFoodNutrition(
        basis: NutritionBasis.portion,
        amount: 1,
        calories: 200,
        protein: 5,
        carbohydrates: 10,
        fat: 4,
        sugar: 11,
        saturatedFat: 5,
        salt: 1,
      );
      expect(value.validate(requireLabelValues: true), isNotNull);
      expect(parseNutritionNumber('12,5'), 12.5);
      expect(parseNutritionNumber('-2'), isNull);
      expect(parseNutritionNumber('NaN'), isNull);
    });
  });
}
