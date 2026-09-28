import 'package:fitness_ai_app/core/models/app_models.dart';
import 'package:fitness_ai_app/features/discover/domain/ingredient_match.dart';
import 'package:flutter_test/flutter_test.dart';

Recipe _recipe(String id, List<String> ingredients, {bool premium = false}) =>
    Recipe(
      id: id,
      title: id,
      subtitle: '',
      minutes: 20,
      calories: 400,
      protein: 20,
      imageAsset: '',
      tags: const ['Für dich'],
      isPremium: premium,
      ingredients: [
        for (final name in ingredients)
          RecipeIngredient(foodId: name, name: name, amountGrams: 100),
      ],
    );

void main() {
  group('Zutaten-Namen werden tolerant verglichen', () {
    void same(String a, String b) => expect(
      ingredientNamesMatch(a, b),
      isTrue,
      reason: '„$a“ sollte zu „$b“ passen',
    );
    void different(String a, String b) => expect(
      ingredientNamesMatch(a, b),
      isFalse,
      reason: '„$a“ darf nicht zu „$b“ passen',
    );

    test('Groß-/Kleinschreibung, Umlaute und ae/oe/ue', () {
      same('kartoffeln', 'KARTOFFELN');
      same('Käse', 'Kaese');
      same('Käse', 'kase');
      same('Möhren', 'Moehren');
      same('Grießbrei', 'Griessbrei');
    });

    test('Einzahl und Mehrzahl', () {
      same('Kartoffel', 'Kartoffeln');
      same('Tomate', 'Tomaten');
      same('Zwiebel', 'Zwiebeln');
      same('Ei', 'Eier');
      same('Linse', 'Linsen');
      same('Nudel', 'Nudeln');
      same('Champignon', 'Champignons');
      same('Nuss', 'Nüsse');
      same('Apfel', 'Äpfel');
      same('Avocado', 'Avocados');
      same('Reis', 'Reis');
    });

    test('Beschreibungen nach Komma, in Klammern oder als Adjektiv', () {
      same('Kartoffeln', 'Kartoffeln, festkochend');
      same('Reis', 'Reis, gekocht');
      same('Tomaten', 'Tomaten, gehackt (Dose)');
      same('Linsen', 'Rote Linsen');
      same('Joghurt', 'Griechischer Joghurt');
      same('Zwiebel', 'rote Zwiebel, fein gewürfelt');
      same('Tomaten', 'Passierte Tomaten');
    });

    test('Synonyme und regionale Namen', () {
      same('Erdäpfel', 'Kartoffeln');
      same('Paradeiser', 'Tomaten');
      same('Möhren', 'Karotten');
      same('Nudeln', 'Spaghetti');
      same('Nudeln', 'Vollkornpasta');
      same('Porree', 'Lauch');
      same('Topfen', 'Quark');
      same('Knoblauch', 'Knoblauchzehen');
      same('Paprika', 'Paprikaschote, rot');
      same('Lachs', 'Lachsfilet');
      same('Potatoes, raw', 'Kartoffeln');
      same('Eier', 'Eigelb');
    });

    test('Zusammengesetzte Wörter benennen die Art zuletzt', () {
      same('Tomaten', 'Kirschtomaten');
      same('Tomaten', 'Dosentomaten');
      same('Öl', 'Olivenöl');
      same('Reis', 'Basmatireis');
      same('Mehl', 'Weizenmehl');
      same('Eier', 'Hühnereier');
    });

    test('ähnlich klingende, aber andere Zutaten bleiben getrennt', () {
      different('Kartoffeln', 'Süßkartoffeln');
      different('Milch', 'Kokosmilch');
      different('Erbsen', 'Kichererbsen');
      different('Erbsen', 'Dosenkichererbsen');
      different('Zwiebeln', 'Frühlingszwiebeln');
      different('Tomaten', 'Tomatenmark');
      different('Käse', 'Frischkäse');
      different('Butter', 'Erdnussbutter');
      different('Eier', 'Salbei');
      different('Äpfel', 'Erdäpfel');
      different('Reis', 'Mais');
      different('Lachs', 'Seelachsfilet');
      different('Paprika', 'Paprikapulver');
    });

    test('dagegen passt die eigene Sorte wieder zu sich selbst', () {
      same('Süßkartoffeln', 'Süßkartoffel');
      same('Kichererbsen', 'Kichererbsen, abgetropft');
      same('Kokosmilch', 'Kokosmilch (Dose)');
    });
  });

  group('Grundzutaten', () {
    test('Salz, Pfeffer, Öl, Wasser und Gewürze zählen als Grundzutat', () {
      for (final name in [
        'Salz',
        'Meersalz',
        'Pfeffer, schwarz',
        'Olivenöl',
        'Rapsöl',
        'Wasser',
        'Paprikapulver, edelsüß',
        'Paprika, edelsüß',
        'Currypulver',
        'Kreuzkümmel, gemahlen',
        'Zimt',
        'Oregano, getrocknet',
        'Muskatnuss',
        'Salz und Pfeffer',
      ]) {
        expect(isBasicIngredient(name), isTrue, reason: name);
      }
    });

    test('echte Zutaten sind keine Grundzutat', () {
      for (final name in [
        'Kartoffeln',
        'Paprika, rot',
        'Kokoswasser',
        'Karfiol',
        'Eier',
        'Butter',
      ]) {
        expect(isBasicIngredient(name), isFalse, reason: name);
      }
    });
  });

  group('Rezepte aus Vorhandenem', () {
    final potatoes = _recipe('bratkartoffeln', [
      'Kartoffeln, festkochend',
      'Zwiebel',
      'Rapsöl',
      'Salz',
    ]);
    final soup = _recipe('kartoffelsuppe', [
      'Kartoffeln',
      'Karotten',
      'Lauch',
      'Gemüsebrühe',
      'Sahne',
      'Salz',
      'Pfeffer',
    ]);
    final boiled = _recipe('salzkartoffeln', ['Kartoffeln', 'Salz', 'Wasser']);
    final pasta = _recipe('tomatennudeln', [
      'Spaghetti',
      'Dosentomaten',
      'Knoblauch',
      'Olivenöl',
    ]);
    final sweet = _recipe('suesskartoffel-curry', [
      'Süßkartoffeln',
      'Kokosmilch',
      'Currypulver',
    ]);
    final noIngredients = _recipe('ohne-zutaten', const []);
    final recipes = [pasta, soup, potatoes, sweet, boiled, noIngredients];

    test('nur Kartoffeln: Rezepte mit Kartoffeln, bestes zuerst', () {
      final matches = matchRecipesToInventory(recipes, ['Kartoffeln']);

      expect(matches.map((match) => match.recipe.id), [
        'salzkartoffeln',
        'bratkartoffeln',
        'kartoffelsuppe',
      ]);
      final best = matches.first;
      expect(best.canCookNow, isTrue);
      expect(best.coverage, 1);
      expect(best.available.single.name, 'Kartoffeln');
      expect(best.assumedBasics.map((i) => i.name), ['Salz', 'Wasser']);

      final fried = matches[1];
      expect(fried.missing.map((i) => i.name), ['Zwiebel']);
      expect(fried.covered, 3);
      expect(fried.total, 4);
    });

    test('Süßkartoffel-Rezepte erscheinen nicht für Kartoffeln', () {
      final ids = matchRecipesToInventory(recipes, [
        'Erdäpfel',
      ]).map((match) => match.recipe.id);
      expect(ids, isNot(contains('suesskartoffel-curry')));
      expect(ids, contains('salzkartoffeln'));
    });

    test('Grundzutaten lassen sich abschalten', () {
      final matches = matchRecipesToInventory(recipes, [
        'Kartoffeln',
      ], assumeBasics: false);
      final boiledMatch = matches.firstWhere(
        (match) => match.recipe.id == 'salzkartoffeln',
      );
      expect(boiledMatch.assumedBasics, isEmpty);
      expect(boiledMatch.missing.map((i) => i.name), ['Salz', 'Wasser']);
      expect(boiledMatch.canCookNow, isFalse);
    });

    test('Grundzutaten allein machen kein Rezept passend', () {
      expect(matchRecipesToInventory(recipes, ['Salz', 'Öl']), isEmpty);
    });

    test('mehrere Zutaten: weniger fehlende Zutaten gewinnen', () {
      final matches = matchRecipesToInventory(recipes, [
        'Nudeln',
        'Tomaten aus der Dose',
        'Knoblauch',
        'Kartoffeln',
        'Zwiebeln',
      ]);
      final ids = matches.map((match) => match.recipe.id).toList();
      expect(ids.take(3), containsAll(['tomatennudeln', 'bratkartoffeln']));
      expect(ids.last, 'kartoffelsuppe');
      expect(matches.where((match) => match.canCookNow).length, 3);
    });

    test('leere Auswahl und Rezepte ohne Zutatenliste liefern nichts', () {
      expect(matchRecipesToInventory(recipes, const []), isEmpty);
      expect(matchRecipesToInventory(recipes, ['  ']), isEmpty);
      final ids = matchRecipesToInventory(recipes, [
        'Kartoffeln',
      ]).map((match) => match.recipe.id);
      expect(ids, isNot(contains('ohne-zutaten')));
    });

    test('gleiche Abdeckung: die ursprüngliche Reihenfolge bleibt', () {
      final a = _recipe('a', ['Reis', 'Eier']);
      final b = _recipe('b', ['Reis', 'Eier']);
      expect(
        matchRecipesToInventory(
          [a, b],
          ['Reis'],
        ).map((match) => match.recipe.id),
        ['a', 'b'],
      );
    });
  });

  test('Vorschläge ergänzen Zutaten aus Katalog und Grundvorrat', () {
    final recipes = [
      _recipe('x', ['Kartoffeln, festkochend', 'Karotten']),
      _recipe('y', ['Kartoffeln', 'Kräuterquark']),
    ];
    final suggestions = ingredientSuggestions(recipes, 'kar');
    expect(suggestions.first, 'Kartoffeln');
    expect(suggestions, contains('Karotten'));
    expect(
      ingredientSuggestions(recipes, 'kar', exclude: ['Kartoffel']),
      isNot(contains('Kartoffeln')),
    );
    expect(ingredientSuggestions(recipes, '   '), isEmpty);
  });
}
