import 'dart:io';

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

    test('does not mistake berries for beer', () {
      expect(HalalContentPolicy.isAllowedText('Skyr mit Beeren'), isTrue);
      expect(HalalContentPolicy.isAllowedText('Beerenmix, TK'), isTrue);
      expect(HalalContentPolicy.isAllowedText('Heidelbeeren'), isTrue);
      expect(HalalContentPolicy.isAllowedText('Beer battered fish'), isFalse);
      expect(HalalContentPolicy.isAllowedText('Beers'), isFalse);
      expect(HalalContentPolicy.isAllowedText('Bier'), isFalse);
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

    test('checks steps, ingredient notes and premium tips', () {
      const base = Recipe(
        id: 'recipe',
        title: 'Gemüsepfanne',
        subtitle: 'Schnell gekocht',
        minutes: 20,
        calories: 460,
        protein: 18,
        imageAsset: '',
        tags: ['Vegetarisch'],
        steps: [RecipeStep(title: 'Anbraten', text: 'Gemüse kurz anbraten.')],
      );
      expect(HalalContentPolicy.isAllowedRecipe(base), isTrue);
      expect(
        HalalContentPolicy.isAllowedRecipe(
          base.withPremiumDetails(
            const RecipePremiumDetails(
              substitutions: ['Skyr durch griechischen Joghurt ersetzen'],
            ),
          ),
        ),
        isTrue,
      );
      expect(
        HalalContentPolicy.isAllowedRecipe(
          base.withPremiumDetails(
            const RecipePremiumDetails(variations: ['Mit Weißwein ablöschen']),
          ),
        ),
        isFalse,
      );
    });
  });

  group('Erweiterte Begriffe', _extendedTermTests);
}

void _extendedTermTests() {
  void blocked(List<String> names) {
    for (final name in names) {
      expect(HalalContentPolicy.isAllowedText(name), isFalse, reason: name);
    }
  }

  void allowed(List<String> names) {
    for (final name in names) {
      expect(HalalContentPolicy.isAllowedText(name), isTrue, reason: name);
    }
  }

  test('blockiert Cocktails, Spirituosen und Wein', () {
    blocked([
      'Daiquiri',
      'Frozen margarita',
      'Martini, flavored',
      'Mojito',
      'Mimosa',
      'Manhattan',
      'Soup, Manhattan clam chowder',
      'Tequila Sunrise',
      'Scotch',
      'Bourbon',
      'Rum',
      'Vodka',
      'Gin Tonic',
      'Brandy',
      'Cognac',
      'Eierlikör',
      'Screwdriver',
      'Bloody Mary',
      'Long Island iced tea',
      'Sangria, red',
      'Pina Colada',
      'Eggnog',
      'Rum punch',
      'Cocktail, NFS',
      'Glühwein',
      'Hard seltzer',
    ]);
  });

  test('blockiert Schwein, Wurst und verarbeitetes Fleisch', () {
    blocked([
      'Bologna',
      'Bratwurst',
      'Knockwurst',
      'Chorizo',
      'Spam, reduced sodium',
      'Scrapple, cooked',
      'Chitterlings',
      'Pastrami, NFS',
      'Liverwurst',
      'Leberwurst',
      'Hot dog, NFS',
      'Frankfurters or hot dogs and sauerkraut',
      'Beans and franks',
      'Mortadella',
      'Pancetta',
      'Kochschinken',
      'Griebenschmalz',
      'Rumpsteak',
      'Hackfleisch gemischt',
    ]);
  });

  test('blockiert Fleischgerichte ohne Halal-Kennzeichnung', () {
    blocked([
      'Hamburger, NFS',
      'Cheeseburger (McDonalds)',
      'Whopper (Burger King)',
      'Steak tartare',
      'Salisbury steak with gravy',
      'Sloppy joe, no bun',
      'Ribs, NFS',
      'Tongue',
      'Tripe',
      'Gizzard',
      'Sweetbreads',
      'Rabbit',
      'Bison',
      'Ostrich',
      'Quail, cooked',
      'Pheasant, cooked',
      'Goose, wild, roasted',
      'Venison',
      'Meatballs',
      'Meatloaf',
      'Frikadellen',
      'Liver, paste or pate',
      'Gyro sandwich',
      'Egg, Benedict',
    ]);
    allowed(['Halal Hamburger', 'Rindersteak, halal', 'Hähnchenbrust halal']);
  });

  test('blockiert Produkte, die meist Gelatine enthalten', () {
    blocked([
      'Candy, gummy',
      'Gummibärchen',
      'Fruchtgummi',
      'Candy, marshmallow',
      'Cereal, frosted oats with marshmallows',
      'Jelly candy',
      'Jelly beans',
      'Aspic',
      'Panna cotta',
    ]);
  });

  test('lässt harmlose Lebensmittel mit ähnlichen Wörtern zu', () {
    allowed([
      'Rice, white, cooked',
      'Potato, baked',
      'Eggs, Grade A, Large, egg whole',
      'Lachsfilet',
      'Salmon steak, grilled',
      'Ginger root, raw',
      'Ingwer',
      'Drumstick leaves, raw',
      'Drum fish, cooked',
      'Serum',
      'Fruit punch, made with fruit juice and soda',
      'Fruit cocktail, canned, in syrup',
      'Cocktail sauce',
      'Tomato juice cocktail',
      'Roll, white, hamburger bun',
      'Roll, white, hot dog bun',
      'Quail egg, canned',
      'Goose egg, cooked',
      'Duck egg, cooked',
      'Cheese, goat',
      'Goat milk',
      'Blood orange',
      'Steak sauce',
      'Cod liver oil',
      'Mango Fruchtfleisch',
      'Butterschmalz',
      'Beerenmix',
      'Jam or jelly, NFS',
      'Kokosmilch',
      'Weintrauben',
      'Speisestärke',
      'Rice, fried, meatless',
    ]);
  });

  group('Listen sind in App, Datenbank und Barcode-Funktion gleich', () {
    final sql = File(
      'supabase/migrations/0014_halal_terms_extended.sql',
    ).readAsStringSync();
    final ts = File(
      'supabase/functions/barcode-lookup/index.ts',
    ).readAsStringSync();

    Set<String> sqlTerms(String constant) {
      final start = sql.indexOf('$constant constant text :=');
      final end = sql.indexOf(';', start);
      final literal = RegExp(r"'([^']*)'")
          .allMatches(sql.substring(start, end))
          .map((match) => match.group(1)!)
          .join();
      return literal
          .replaceFirst(RegExp(r'^\(\^\| \)\(|^ \('), '')
          .replaceFirst(RegExp(r'\)\( \|\$\)$|\) $'), '')
          .split('|')
          .map(
            (term) => term
                .replaceAll('[a-z0-9]*', '')
                .replaceAll('[a-z0-9]+', '')
                .replaceAll(RegExp(r'\(\?!\w+\)'), ''),
          )
          .toSet();
    }

    Set<String> tsTerms(String constant) {
      final start = ts.indexOf('const $constant');
      final end = ts.indexOf(']', start);
      return RegExp(r"'([^']*)'")
          .allMatches(ts.substring(start, end))
          .map((match) => match.group(1)!)
          .toSet();
    }

    test('SQL-Migration 0014', () {
      expect(
        sqlTerms('hard_forbidden_pattern'),
        HalalContentPolicy.hardForbiddenTerms.toSet(),
      );
      expect(
        sqlTerms('land_animal_pattern'),
        HalalContentPolicy.landAnimalMeatTerms.toSet(),
      );
      expect(
        sqlTerms('halal_marker_pattern'),
        HalalContentPolicy.halalMarkers.toSet(),
      );
      expect(
        sqlTerms('harmless_pattern'),
        HalalContentPolicy.harmlessPhrases.toSet(),
      );
      for (final root in HalalContentPolicy.prefixRoots) {
        expect(
          RegExp("[(|']$root(\\(\\?!\\w+\\))?\\[a-z0-9\\]\\*").hasMatch(sql),
          isTrue,
          reason: 'Präfix $root',
        );
      }
      for (final root in HalalContentPolicy.suffixRoots) {
        expect(sql, contains('[a-z0-9]+$root'), reason: 'Suffix $root');
      }
    });

    test('Barcode-Edge-Function', () {
      expect(
        tsTerms('hardForbiddenTerms'),
        HalalContentPolicy.hardForbiddenTerms.toSet(),
      );
      expect(
        tsTerms('landAnimalMeatTerms'),
        HalalContentPolicy.landAnimalMeatTerms.toSet(),
      );
      expect(tsTerms('halalMarkers'), HalalContentPolicy.halalMarkers.toSet());
      expect(tsTerms('prefixRoots'), HalalContentPolicy.prefixRoots);
      expect(tsTerms('suffixRoots'), HalalContentPolicy.suffixRoots);
      expect(
        tsTerms('harmlessPhrases'),
        HalalContentPolicy.harmlessPhrases.toSet(),
      );
    });
  });
}
