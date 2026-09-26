import 'package:fitness_ai_app/core/data/halal_content_policy.dart';
import 'package:fitness_ai_app/core/models/app_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HalalContentPolicy', () {
    test('allows plant-based and fish-based foods', () {
      expect(
        HalalContentPolicy.isAllowedText('Kichererbsen-Reis-Bowl'),
        isTrue,
      );
      expect(HalalContentPolicy.isAllowedText('Lachs mit Gemüse'), isTrue);
    });

    test('blocks pork, alcohol and gelatin terms', () {
      expect(HalalContentPolicy.isAllowedText('Schweinefleisch'), isFalse);
      expect(HalalContentPolicy.isAllowedText('Bacon sandwich'), isFalse);
      expect(HalalContentPolicy.isAllowedText('Rotwein'), isFalse);
      expect(HalalContentPolicy.isAllowedText('Gelatine'), isFalse);
    });

    test('requires an explicit halal marker for land-animal meat', () {
      expect(HalalContentPolicy.isAllowedText('Hähnchenbrust'), isFalse);
      expect(HalalContentPolicy.isAllowedText('Halal Hähnchenbrust'), isTrue);
    });

    test('checks food details beyond its visible name', () {
      const food = FoodItem(
        id: 'example',
        name: 'Fruchtgummi',
        servingGrams: 100,
        calories: 340,
        protein: 5,
        carbohydrates: 75,
        fat: 0,
        ingredientsText: 'Glukosesirup, Gelatine, Zucker',
      );

      expect(HalalContentPolicy.isAllowedFood(food), isFalse);
    });

    test('checks recipes and their ingredients', () {
      const recipe = Recipe(
        id: 'recipe',
        title: 'Gemüsepfanne',
        subtitle: 'Schnell gekocht',
        minutes: 20,
        calories: 460,
        protein: 18,
        imageAsset: '',
        tags: ['Vegetarisch'],
        ingredients: [
          RecipeIngredient(
            foodId: 'ingredient',
            name: 'Bier',
            amountGrams: 100,
          ),
        ],
      );

      expect(HalalContentPolicy.isAllowedRecipe(recipe), isFalse);
    });
  });
}
