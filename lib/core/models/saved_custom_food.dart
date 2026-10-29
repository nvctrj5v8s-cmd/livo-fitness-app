import 'custom_food.dart';

/// A private, unverified copy of label values entered by the user.
class SavedCustomFood {
  const SavedCustomFood({
    required this.id,
    required this.name,
    required this.nutrition,
  });
  final String id;
  final String name;
  final CustomFoodNutrition nutrition;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'nutrition': nutrition.toJson(),
    'source': 'user_entered',
  };

  factory SavedCustomFood.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! String ||
        id.isEmpty ||
        name is! String ||
        name.trim().isEmpty ||
        name.length > 100 ||
        json['nutrition'] is! Map) {
      throw const FormatException('Invalid saved custom food');
    }
    return SavedCustomFood(
      id: id,
      name: name,
      nutrition: CustomFoodNutrition.fromJson(
        Map<String, dynamic>.from(json['nutrition'] as Map),
      ),
    );
  }
}
