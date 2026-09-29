import 'package:fitness_ai_app/core/models/app_models.dart';
import 'package:fitness_ai_app/features/allergies/domain/allergy_safety.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _conflicts(String text, String profile) =>
    AllergySafety.assessText(text, profile, hasData: true).conflicts;

void main() {
  group('Profil lesen und speichern', () {
    test('Auswahl und eigene Angaben werden getrennt gespeichert', () {
      final stored = AllergySafety.encode({
        'peanuts',
        'lactose_intolerance',
      }, 'Kiwi, Histamin');
      expect(stored, 'Erdnüsse, Laktose (Unverträglichkeit), Kiwi, Histamin');
      expect(AllergySafety.selectedIds(stored), {
        'peanuts',
        'lactose_intolerance',
      });
      expect(AllergySafety.otherEntries(stored), ['Kiwi', 'Histamin']);
    });

    test('ältere Freitext-Profile werden erkannt', () {
      expect(AllergySafety.selectedIds('Erdnüsse, Nüsse, Laktose, gluten'), {
        'peanuts',
        'tree_nuts',
        'lactose_intolerance',
        'gluten',
      });
      expect(AllergySafety.selectedIds('Meeresfrüchte'), {
        'crustaceans',
        'molluscs',
      });
    });

    test('„Keine angegeben“ und leere Texte zählen nicht', () {
      expect(AllergySafety.hasEntries('Keine angegeben'), isFalse);
      expect(AllergySafety.hasEntries(' , '), isFalse);
      expect(AllergySafety.hasEntries('Senf'), isTrue);
      expect(
        AllergySafety.assessText('Senf', 'Keine angegeben', hasData: true),
        isA<AllergyAssessment>().having((a) => a.hasProfile, 'profil', false),
      );
    });

    test('Allergen-Tags werden lesbar', () {
      expect(AllergySafety.displayTag('en:milk'), 'Milch');
      expect(AllergySafety.displayTag('en:peanuts'), 'Erdnüsse');
      expect(AllergySafety.displayTag('en:kiwi-fruit'), 'kiwi fruit');
    });
  });

  group('typische Auslöser werden erkannt', () {
    for (final (text, profile, expected) in [
      ('Käse, gerieben', 'Milch', 'Milch'),
      ('Sahne', 'Milch', 'Milch'),
      ('Naturjoghurt', 'Milch', 'Milch'),
      ('Butterschmalz', 'Milch', 'Milch'),
      ('Vollkornnudeln', 'Gluten', 'Glutenhaltiges Getreide'),
      ('Haferflocken', 'Gluten', 'Glutenhaltiges Getreide'),
      ('Toastbrot', 'Gluten', 'Glutenhaltiges Getreide'),
      ('Erdnussbutter', 'Erdnüsse', 'Erdnüsse'),
      ('Rührei mit Spinat', 'Eier', 'Eier'),
      ('Reis-Ei-Bowl', 'Eier', 'Eier'),
      ('Freilandeier', 'Eier', 'Eier'),
      ('Thunfisch in Wasser', 'Fisch', 'Fisch'),
      ('Hummus', 'Sesam', 'Sesam'),
      ('Haselnusskerne', 'Schalenfrüchte', 'Schalenfrüchte'),
      ('Tofu natur', 'Soja', 'Soja'),
      ('Garnelen', 'Krebstiere', 'Krebstiere'),
      ('Tintenfischringe', 'Weichtiere', 'Weichtiere'),
      ('Frischkäse', 'Laktose', 'Laktose (Unverträglichkeit)'),
      ('en:milk, en:soybeans', 'Milch', 'Milch'),
    ]) {
      test('„$text“ bei $profile', () {
        expect(_conflicts(text, profile), [expected]);
      });
    }

    test('eigene Angaben auch in zusammengesetzten Wörtern', () {
      expect(_conflicts('Kiwisaft', 'Kiwi'), ['Kiwi']);
      expect(_conflicts('Dosentomaten', 'Tomate'), ['Tomate']);
    });
  });

  group('keine falschen Treffer', () {
    for (final (text, profile) in [
      ('Kokosmilch', 'Milch'),
      ('Hafermilch', 'Milch'),
      ('Erdnussbutter', 'Milch'),
      ('veganer Käse', 'Milch'),
      ('Buchweizen', 'Gluten'),
      ('glutenfreie Nudeln', 'Gluten'),
      ('Reisnudeln', 'Gluten'),
      ('Kartoffeln, mehligkochend', 'Gluten'),
      ('Reis', 'Eier'),
      ('Haferbrei', 'Eier'),
      ('Muskatnuss', 'Schalenfrüchte'),
      ('Kokosnuss', 'Schalenfrüchte'),
      ('Erdnüsse', 'Schalenfrüchte'),
      ('Tintenfisch', 'Fisch'),
      ('laktosefreie Milch', 'Laktose'),
      ('Salzkartoffeln', 'Milch, Gluten, Eier, Soja, Senf'),
    ]) {
      test('„$text“ bei $profile', () {
        expect(_conflicts(text, profile), isEmpty);
      });
    }

    test('laktosefreie Milch bleibt bei Milchallergie ein Treffer', () {
      expect(_conflicts('laktosefreie Milch', 'Milch'), ['Milch']);
    });
  });

  test('Rezepte: Zutaten, Titel und Allergen-Tags zählen', () {
    const recipe = Recipe(
      id: 'r',
      title: 'Kartoffelgratin',
      subtitle: '',
      minutes: 40,
      calories: 500,
      protein: 12,
      servings: 2,
      imageAsset: '',
      tags: [],
      ingredients: [
        RecipeIngredient(foodId: 'a', name: 'Kartoffeln', amountGrams: 500),
        RecipeIngredient(
          foodId: 'b',
          name: 'Soße',
          amountGrams: 100,
          allergens: ['en:mustard'],
        ),
      ],
      steps: [],
    );
    final assessment = AllergySafety.assessRecipe(recipe, 'Senf, Milch');
    expect(assessment.conflicts, ['Senf']);
    expect(assessment.hasData, isTrue);
  });

  test('Lebensmittel ohne Zutatenangaben gelten als unbekannt', () {
    const food = FoodItem(
      id: 'x',
      name: 'Müsliriegel',
      calories: 100,
      protein: 2,
      carbohydrates: 15,
      fat: 3,
      servingGrams: 25,
    );
    final assessment = AllergySafety.assessFood(food, 'Senf');
    expect(assessment.hasConflict, isFalse);
    expect(assessment.dataUnknown, isTrue);
  });
}
