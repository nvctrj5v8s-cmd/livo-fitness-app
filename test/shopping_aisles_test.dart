import 'package:fitness_ai_app/features/discover/domain/kitchen_planning.dart';
import 'package:fitness_ai_app/features/discover/domain/shopping_aisles.dart';
import 'package:fitness_ai_app/features/discover/presentation/kitchen_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('splitShoppingInput', () {
    for (final (input, name, amount) in [
      ('500 g Reis', 'Reis', const KitchenAmount(500, KitchenUnit.gram)),
      ('500g Reis', 'Reis', const KitchenAmount(500, KitchenUnit.gram)),
      ('Reis 500g', 'Reis', const KitchenAmount(500, KitchenUnit.gram)),
      (
        'Milch, 1 l',
        'Milch',
        const KitchenAmount(1000, KitchenUnit.milliliter),
      ),
      (
        '1,5 kg Kartoffeln',
        'Kartoffeln',
        const KitchenAmount(1500, KitchenUnit.gram),
      ),
      ('2 Eier', 'Eier', const KitchenAmount(2, KitchenUnit.piece)),
      ('3x Joghurt', 'Joghurt', const KitchenAmount(3, KitchenUnit.piece)),
      ('Joghurt 3x', 'Joghurt', const KitchenAmount(3, KitchenUnit.piece)),
      ('2 Dosen Tomaten', 'Tomaten', const KitchenAmount(2, KitchenUnit.can)),
      (
        '½ Bund Petersilie',
        'Petersilie',
        const KitchenAmount(0.5, KitchenUnit.bunch),
      ),
      (
        '2 rote Paprika',
        'rote Paprika',
        const KitchenAmount(2, KitchenUnit.piece),
      ),
    ]) {
      test('„$input“', () {
        final parsed = splitShoppingInput(input);
        expect(parsed.name, name);
        expect(parsed.amount, amount);
      });
    }

    for (final input in ['7-Korn Brot', 'Mehl Type 405', 'Milch', '  ']) {
      test('„$input“ bleibt ohne Menge', () {
        final parsed = splitShoppingInput(input);
        expect(parsed.name, input.trim());
        expect(parsed.amountText, isEmpty);
      });
    }
  });

  group('shoppingAisleFor', () {
    for (final (name, aisle) in [
      ('Kartoffeln, festkochend', ShoppingAisle.produce),
      ('Wassermelone', ShoppingAisle.produce),
      ('Orangensaft', ShoppingAisle.drinks),
      ('Mineralwasser', ShoppingAisle.drinks),
      ('Paprikapulver, edelsüß', ShoppingAisle.oilsSpices),
      ('Paprika', ShoppingAisle.produce),
      ('Olivenöl', ShoppingAisle.oilsSpices),
      ('Vollkornbrot', ShoppingAisle.bakery),
      ('Eier', ShoppingAisle.dairy),
      ('Freilandeier', ShoppingAisle.dairy),
      ('Kokosmilch', ShoppingAisle.canned),
      ('Dosentomaten', ShoppingAisle.canned),
      ('TK-Erbsen', ShoppingAisle.frozen),
      ('Reis', ShoppingAisle.dryGoods),
      ('Preiselbeeren', ShoppingAisle.produce),
      ('Hähnchenbrust, halal', ShoppingAisle.meatFish),
      ('Thunfisch', ShoppingAisle.canned),
      ('Erdnussbutter', ShoppingAisle.dryGoods),
      ('Spülmittel', ShoppingAisle.other),
    ]) {
      test('$name → ${aisle.name}', () {
        expect(shoppingAisleFor(name), aisle);
      });
    }

    test('Dosen zählen als Konserven, Reihenfolge wie im Laden', () {
      const items = [
        ShoppingItem(id: '1', name: 'Milch'),
        ShoppingItem(
          id: '2',
          name: 'Kichererbsen',
          amount: KitchenAmount(1, KitchenUnit.can),
        ),
        ShoppingItem(id: '3', name: 'Äpfel'),
        ShoppingItem(id: '4', name: 'Joghurt'),
      ];
      final groups = groupShoppingByAisle(items);
      expect(
        [for (final (aisle, _) in groups) aisle],
        [ShoppingAisle.produce, ShoppingAisle.dairy, ShoppingAisle.canned],
      );
      expect(
        [for (final item in groups[1].$2) item.name],
        ['Milch', 'Joghurt'],
      );
    });
  });

  test('Liste als Text: nur offene Artikel, nach Abteilung', () {
    const items = [
      ShoppingItem(
        id: '1',
        name: 'Reis',
        amount: KitchenAmount(500, KitchenUnit.gram),
      ),
      ShoppingItem(id: '2', name: 'Tomaten'),
      ShoppingItem(id: '3', name: 'Milch', done: true),
    ];
    expect(
      shoppingListAsText(items),
      'Einkaufsliste\n\nObst & Gemüse\n• Tomaten\n\n'
      'Nudeln, Reis & Vorrat\n• Reis – 500 g',
    );
  });
}
