enum NutritionBasis { per100g, per100ml, portion }

/// Label values remain unrounded. [amount] is consumed g, ml or portions.
class CustomFoodNutrition {
  const CustomFoodNutrition({
    required this.basis,
    required this.amount,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    this.sugar,
    this.saturatedFat,
    this.salt,
    this.fiber,
  });

  final NutritionBasis basis;
  final double amount;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double? sugar;
  final double? saturatedFat;
  final double? salt;
  final double? fiber;

  double get factor => basis == NutritionBasis.portion ? amount : amount / 100;
  double get totalCalories => calories * factor;
  double get totalProtein => protein * factor;
  double get totalCarbohydrates => carbohydrates * factor;
  double get totalFat => fat * factor;
  double? get totalSugar => sugar == null ? null : sugar! * factor;
  double? get totalSaturatedFat =>
      saturatedFat == null ? null : saturatedFat! * factor;
  double? get totalSalt => salt == null ? null : salt! * factor;
  double? get totalFiber => fiber == null ? null : fiber! * factor;

  String? validate({bool requireLabelValues = false}) {
    if (!amount.isFinite || amount <= 0) {
      return 'Bitte eine Menge größer als 0 eingeben.';
    }
    if (requireLabelValues &&
        (sugar == null || saturatedFat == null || salt == null)) {
      return 'Bitte Zucker, gesättigte Fettsäuren und Salz vom Etikett ergänzen.';
    }
    final values = [
      calories,
      protein,
      carbohydrates,
      fat,
      sugar,
      saturatedFat,
      salt,
      fiber,
    ];
    if (values.any(
      (value) => value != null && (!value.isFinite || value < 0),
    )) {
      return 'Nährwerte müssen gültige Zahlen ab 0 sein.';
    }
    if (values.any((value) => value != null && !(value * factor).isFinite)) {
      return 'Die Menge oder ein Nährwert ist zu groß.';
    }
    if (sugar != null && sugar! > carbohydrates) {
      return 'Zucker darf nicht höher als die Kohlenhydrate sein.';
    }
    if (saturatedFat != null && saturatedFat! > fat) {
      return 'Gesättigte Fettsäuren dürfen nicht höher als Fett sein.';
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'version': 1,
    'basis': basis.name,
    'amount': amount,
    'calories': calories,
    'protein': protein,
    'carbohydrates': carbohydrates,
    'fat': fat,
    'sugar': sugar,
    'saturated_fat': saturatedFat,
    'salt': salt,
    'fiber': fiber,
  };

  factory CustomFoodNutrition.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1) {
      throw const FormatException('Unbekannte Nährwert-Version.');
    }
    final basis = NutritionBasis.values
        .where((value) => value.name == json['basis'])
        .firstOrNull;
    if (basis == null) {
      throw const FormatException('Unbekannte Nährwert-Basis.');
    }
    double requiredValue(String key) {
      final value = json[key];
      if (value is! num) throw FormatException('Nährwert fehlt: $key');
      return value.toDouble();
    }

    double? optionalValue(String key) {
      if (json[key] == null) return null;
      return requiredValue(key);
    }

    final nutrition = CustomFoodNutrition(
      basis: basis,
      amount: requiredValue('amount'),
      calories: requiredValue('calories'),
      protein: requiredValue('protein'),
      carbohydrates: requiredValue('carbohydrates'),
      fat: requiredValue('fat'),
      sugar: optionalValue('sugar'),
      saturatedFat: optionalValue('saturated_fat'),
      salt: optionalValue('salt'),
      fiber: optionalValue('fiber'),
    );
    final error = nutrition.validate();
    if (error != null) throw FormatException(error);
    return nutrition;
  }

  CustomFoodNutrition copyWith({double? amount}) => CustomFoodNutrition(
    basis: basis,
    amount: amount ?? this.amount,
    calories: calories,
    protein: protein,
    carbohydrates: carbohydrates,
    fat: fat,
    sugar: sugar,
    saturatedFat: saturatedFat,
    salt: salt,
    fiber: fiber,
  );
}

/// Decimal commas are accepted; empty, infinity and NaN are never zero.
double? parseNutritionNumber(String text) {
  final cleaned = text.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d+(?:\.\d+)?$').hasMatch(cleaned)) return null;
  final value = double.tryParse(cleaned);
  return value != null && value.isFinite ? value : null;
}
