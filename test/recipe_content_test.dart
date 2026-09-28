import 'dart:convert';
import 'dart:io';

import 'package:fitness_ai_app/core/data/halal_content_policy.dart';
import 'package:fitness_ai_app/core/data/recipe_images.dart';
import 'package:fitness_ai_app/core/models/app_models.dart';
import 'package:fitness_ai_app/features/discover/domain/ingredient_match.dart';
import 'package:flutter_test/flutter_test.dart';

/// Checks the reviewed recipe source (`supabase/content/livo_recipes.json`)
/// that generates migration 0010. The generator validates the same rules;
/// this test keeps them from silently drifting.
void main() {
  final document =
      jsonDecode(File('supabase/content/livo_recipes.json').readAsStringSync())
          as Map<String, dynamic>;
  final recipes = [
    for (final raw in document['recipes'] as List)
      Map<String, dynamic>.from(raw as Map),
  ];
  final foods = [
    for (final raw in document['foods'] as List)
      Map<String, dynamic>.from(raw as Map),
  ];
  const seedFoods = {
    'oats',
    'skyr',
    'salmon',
    'rice',
    'wholegrain-pasta',
    'egg',
    'avocado',
    'tomato',
    'berries',
  };
  final foodSlugs = {...seedFoods, for (final food in foods) food['slug']};

  test('about 30 % of all recipes are free, including staple recipes', () {
    final free = recipes.where((r) => r['access_level'] == 'free').toList();
    final share = free.length / recipes.length;
    expect(share, closeTo(0.3, 0.03));
    final freeSlugs = free.map((r) => r['slug']).toSet();
    expect(
      freeSlugs,
      containsAll([
        'livo-pellkartoffeln-kraeuterquark',
        'livo-rote-linsen-dal',
        'livo-nudeln-tomatensauce',
      ]),
    );
  });

  test('every ingredient uses a known food and every text is halal-safe', () {
    for (final food in foods) {
      expect(
        HalalContentPolicy.isAllowedText(
          '${food['name']} ${(food['diet_tags'] as List).join(' ')}',
        ),
        isTrue,
        reason: food['slug'] as String,
      );
    }
    for (final recipe in recipes) {
      final slug = recipe['slug'] as String;
      final premium = Map<String, dynamic>.from(recipe['premium'] as Map);
      final text = [
        recipe['title'],
        recipe['description'],
        ...recipe['tags'] as List,
        ...recipe['equipment'] as List,
        for (final ingredient in recipe['ingredients'] as List) ...[
          ingredient['measure'] ?? '',
          ingredient['note'] ?? '',
        ],
        for (final step in recipe['steps'] as List) ...[
          step['title'] ?? '',
          step['text'],
        ],
        ...premium.values.expand((v) => v is List ? v : [v]),
      ].join(' ');
      expect(HalalContentPolicy.restrictionReason(text), isNull, reason: slug);
      for (final ingredient in recipe['ingredients'] as List) {
        expect(foodSlugs, contains(ingredient['food_slug']), reason: slug);
      }
    }
  });

  test('meat only appears with an explicit halal label', () {
    final meatFoods = foods.where(
      (food) => (food['diet_tags'] as List).contains('halal'),
    );
    for (final food in meatFoods) {
      expect((food['name'] as String).toLowerCase(), contains('halal'));
    }
    for (final recipe in recipes) {
      final usesMeat = (recipe['ingredients'] as List).any(
        (i) => meatFoods.any((food) => food['slug'] == i['food_slug']),
      );
      if (usesMeat) {
        expect((recipe['title'] as String).toLowerCase(), contains('halal'));
      }
    }
  });

  test('every recipe photo belongs to a recipe in the catalog', () {
    final slugs = recipes.map((r) => r['slug']).toSet();
    for (final slug in RecipeImages.slugsWithPhoto) {
      expect(slugs, contains(slug));
    }
  });

  group('"Was habe ich zu Hause?" findet die Alltagsrezepte', () {
    final catalog = catalogRecipesFromContent();
    Set<String> found(List<String> have) => {
      for (final match in matchRecipesToInventory(catalog, have))
        match.recipe.slug,
    };

    test('Kartoffeln', () {
      expect(
        found(['Kartoffeln']),
        containsAll([
          'livo-pellkartoffeln-kraeuterquark',
          'livo-bratkartoffeln-spiegelei',
          'livo-kartoffel-moehren-eintopf',
          'livo-kartoffel-tortilla',
          'livo-kartoffelpuffer-apfelmus',
          'livo-ofenlachs-kartoffeln',
        ]),
      );
    });

    test('Reis', () {
      expect(
        found(['Reis']),
        containsAll([
          'livo-rote-linsen-dal',
          'livo-mujaddara',
          'livo-bohnen-chili',
          'livo-thunfisch-reis-bowl',
          'livo-rice-egg-bowl',
          'livo-tomato-rice-pan',
        ]),
      );
    });

    test('Nudeln', () {
      expect(
        found(['Nudeln']),
        containsAll([
          'livo-nudeln-tomatensauce',
          'livo-thunfisch-nudelsalat',
          'livo-spinat-feta-nudelauflauf',
          'livo-linsen-ragout',
        ]),
      );
    });

    test('Eier', () {
      expect(
        found(['Eier']),
        containsAll([
          'livo-ruehrei-vollkornbrot',
          'livo-kartoffel-tortilla',
          'livo-pfannkuchen',
          'livo-arme-ritter',
          'livo-bratkartoffeln-spiegelei',
        ]),
      );
    });

    test('Eier, Kartoffeln, Zwiebeln und Öl reichen für die Tortilla', () {
      final tortilla = matchRecipesToInventory(catalog, [
        'Eier',
        'Kartoffeln',
        'Zwiebeln',
      ]).firstWhere((m) => m.recipe.slug == 'livo-kartoffel-tortilla');
      expect(tortilla.canCookNow, isTrue);
    });

    test('Gemüsepaprika ist kein Paprikapulver', () {
      final inventory = IngredientInventory(['Paprika']);
      expect(inventory.has('Paprika, rot'), isTrue);
      expect(inventory.has('Paprikapulver, edelsüß'), isFalse);
    });
  });
}

const _seedFoodNames = {
  'oats': 'Haferflocken',
  'skyr': 'Skyr natur',
  'salmon': 'Lachsfilet',
  'rice': 'Reis, gekocht',
  'wholegrain-pasta': 'Vollkornpasta, gekocht',
  'egg': 'Ei',
  'avocado': 'Avocado',
  'tomato': 'Tomate',
  'berries': 'Beeren-Mix',
};

/// The catalog recipes as the app builds them: ingredient names are the
/// catalog food names.
List<Recipe> catalogRecipesFromContent() {
  final document =
      jsonDecode(File('supabase/content/livo_recipes.json').readAsStringSync())
          as Map<String, dynamic>;
  final names = {
    ..._seedFoodNames,
    for (final food in document['foods'] as List)
      food['slug'] as String: food['name'] as String,
  };
  return [
    for (final raw in document['recipes'] as List)
      Recipe(
        id: raw['slug'] as String,
        slug: raw['slug'] as String,
        title: raw['title'] as String,
        subtitle: raw['description'] as String,
        minutes: raw['preparation_minutes'] as int,
        calories: 0,
        protein: 0,
        imageAsset: RecipeImages.forSlug(raw['slug'] as String),
        tags: [for (final tag in raw['tags'] as List) tag as String],
        isPremium: raw['access_level'] == 'premium',
        ingredients: [
          for (final ingredient in raw['ingredients'] as List)
            RecipeIngredient(
              foodId: ingredient['food_slug'] as String,
              name: names[ingredient['food_slug']]!,
              amountGrams: (ingredient['grams'] as num).toDouble(),
            ),
        ],
      ),
  ];
}
