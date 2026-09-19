import 'package:fitness_ai_app/core/models/app_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Barcode-Produktdaten werden typisiert und optional gelesen', () {
    final food = FoodItem.fromMap({
      'id': 'barcode-4008400403227',
      'name': 'Beispielprodukt',
      'brand': 'Beispielmarke',
      'barcode': '4008400403227',
      'serving_grams': 100,
      'calories': 539,
      'protein': 6.3,
      'carbohydrates': 56.3,
      'fat': 30.9,
      'fiber': 3.4,
      'sugar': 55.4,
      'salt': .1,
      'saturated_fat': 10.6,
      'allergens': ['en:milk', 'en:soybeans'],
      'ingredients_text': 'Zucker, Milchpulver',
      'nutriscore_grade': 'e',
      'nova_group': 4,
      'product_quantity': '400 g',
      'source': 'open_food_facts',
      'source_url': 'https://world.openfoodfacts.org',
      'source_license': 'Open Database License (ODbL)',
      'source_attribution': 'Open Food Facts contributors',
    });

    expect(food.hasBarcodeDetails, isTrue);
    expect(food.barcode, '4008400403227');
    expect(food.allergens, ['en:milk', 'en:soybeans']);
    expect(food.nutriScore, 'e');
    expect(food.novaGroup, 4);
    expect(food.saturatedFat, 10.6);
    expect(food.ingredientsText, 'Zucker, Milchpulver');
  });

  test('Katalog-Lebensmittel bleiben ohne Barcode-Details kompatibel', () {
    final food = FoodItem.fromMap({
      'id': 'catalog-oats',
      'name': 'Haferflocken',
      'serving_grams': 100,
      'calories': 372,
      'protein': 13,
      'carbohydrates': 60,
      'fat': 7,
    });

    expect(food.hasBarcodeDetails, isFalse);
    expect(food.allergens, isEmpty);
    expect(food.barcode, isNull);
  });
}
