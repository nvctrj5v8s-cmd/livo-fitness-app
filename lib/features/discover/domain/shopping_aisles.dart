import 'ingredient_match.dart';
import 'kitchen_planning.dart';

/// Supermarket sections for the shopping list, in the order most shops are
/// walked through. Labels and icons live in the UI (`kitchen_format.dart`).
enum ShoppingAisle {
  produce,
  bakery,
  dairy,
  meatFish,
  dryGoods,
  canned,
  oilsSpices,
  frozen,
  drinks,
  other,
}

/// Word parts that decide the section no matter what else the name says:
/// "Dosentomaten" are canned.
const _modifiers = <String, ShoppingAisle>{
  'dose': ShoppingAisle.canned,
  'konserv': ShoppingAisle.canned,
  'passiert': ShoppingAisle.canned,
  'tiefkuhl': ShoppingAisle.frozen,
  'gefror': ShoppingAisle.frozen,
};

/// Folded word parts per section. German compounds name the kind of thing
/// last, so the part that ends furthest right in a word wins
/// ("Orangensaft" is a drink, "Wassermelone" is fruit).
final _aisleWords = <ShoppingAisle, List<String>>{
  ShoppingAisle.produce:
      'kartoffel zwiebel knoblauch tomat paprika karott mohre gurke '
              'salat spinat brokkoli zucchini aubergine avocado ingwer '
              'petersilie koriander basilikum minze schnittlauch dill lauch '
              'porree pilz champignon kohl sellerie kurbis bete radieschen '
              'rucola apfel birne banane zitrone limette orange mandarine '
              'beere traube mango melone ananas kiwi pfirsich obst gemuse '
              'frucht erbse fenchel mais chili'
          .split(' '),
  ShoppingAisle.bakery:
      'brot brotchen toast baguette wrap tortilla fladen croissant '
              'bagel knackebrot zwieback'
          .split(' '),
  ShoppingAisle.dairy:
      'milch joghurt jogurt quark kase feta mozzarella parmesan '
              'butter sahne schmand skyr kefir buttermilch frischkase '
              'halloumi tofu hummus'
          .split(' '),
  ShoppingAisle.meatFish:
      'hahnchen huhn pute rind lamm kalb hack fleisch steak wurst '
              'fisch lachs forelle kabeljau garnele seelachs'
          .split(' '),
  ShoppingAisle.dryGoods:
      'reis nudel spaghetti pasta penne fusilli mehl zucker hafer '
              'flocke musli linse kichererbse bohne couscous bulgur quinoa '
              'grie nuss mandel samen kerne kakao backpulver natron hefe '
              'honig marmelade aufstrich schokolade keks cracker rosine '
              'dattel erdnussbutter nussmus'
          .split(' '),
  ShoppingAisle.canned:
      'kokosmilch tomatenmark oliven thunfisch gewurzgurke glas'.split(' '),
  ShoppingAisle.oilsSpices:
      'salz pfeffer gewurz pulver curry kreuzkummel zimt oregano '
              'thymian rosmarin kurkuma muskat bruh senf ketchup mayonnaise '
              'sauce sosse dressing tahin harissa'
          .split(' '),
  ShoppingAisle.frozen: 'eis pommes'.split(' '),
  ShoppingAisle.drinks:
      'wasser saft schorle limo tee kaffee sprudel cola smoothie'.split(' '),
};

/// Keywords that only count at the end of a word, because they hide inside
/// many other words ("eis" in "Reis", "tee" in "Steak").
const _suffixOnly = {'eis', 'tee', 'glas', 'kerne', 'rind', 'hack', 'dill'};

/// Supermarket section for a free-text shopping entry. Unknown names go to
/// [ShoppingAisle.other] instead of being guessed.
ShoppingAisle shoppingAisleFor(String name) {
  final folded = foldIngredientText(ingredientDisplayName(name));
  final words = [
    for (final word in folded.split(RegExp(r'[^a-z0-9]+')))
      if (word.isNotEmpty) word,
  ];
  if (words.isEmpty) return ShoppingAisle.other;
  if (words.contains('tk')) return ShoppingAisle.frozen;
  for (final MapEntry(key: marker, value: aisle) in _modifiers.entries) {
    if (folded.contains(marker)) return aisle;
  }
  for (final word in words) {
    if (word == 'ei' || word.endsWith('eier') || word == 'eiern') {
      return ShoppingAisle.dairy;
    }
    final match = _bestMatch(word);
    // "Rapsöl", "Olivenöl": oil unless another word part ends later.
    if (word.length > 2 &&
        word.endsWith('ol') &&
        (match == null || match.$2 <= word.length - 2)) {
      return ShoppingAisle.oilsSpices;
    }
    if (match != null) return match.$1;
  }
  return ShoppingAisle.other;
}

/// Section for an entry: its name decides, cans count as canned.
ShoppingAisle shoppingAisleForItem(ShoppingItem item) {
  if (item.amount?.unit == KitchenUnit.can) return ShoppingAisle.canned;
  return shoppingAisleFor(item.name);
}

/// The section whose keyword ends furthest right in [word]; ties go to the
/// longer keyword. Returns the section and that end position.
(ShoppingAisle, int)? _bestMatch(String word) {
  (ShoppingAisle, int, int)? best;
  for (final MapEntry(key: aisle, value: keywords) in _aisleWords.entries) {
    for (final keyword in keywords) {
      final int end;
      if (_suffixOnly.contains(keyword)) {
        if (!_endsWithWord(word, keyword)) continue;
        end = word.length;
      } else {
        final start = word.lastIndexOf(keyword);
        if (start < 0) continue;
        end = start + keyword.length;
      }
      final current = best;
      if (current == null ||
          end > current.$2 ||
          (end == current.$2 && keyword.length > current.$3)) {
        best = (aisle, end, keyword.length);
      }
    }
  }
  if (best == null) return null;
  return (best.$1, best.$2);
}

bool _endsWithWord(String word, String keyword) {
  for (final ending in const ['', 'e', 'n', 'en', 's', 'er']) {
    if (word.endsWith('$keyword$ending')) return true;
  }
  return false;
}

/// Open entries grouped by section in shop order; sections without entries
/// are left out. Entries keep their list order inside a section.
List<(ShoppingAisle, List<ShoppingItem>)> groupShoppingByAisle(
  Iterable<ShoppingItem> items,
) {
  final groups = <ShoppingAisle, List<ShoppingItem>>{};
  for (final item in items) {
    groups.putIfAbsent(shoppingAisleForItem(item), () => []).add(item);
  }
  return [
    for (final aisle in ShoppingAisle.values)
      if (groups[aisle] case final entries?) (aisle, entries),
  ];
}

/// What someone typed into the shopping field, split into name and amount.
class ShoppingInput {
  const ShoppingInput(this.name, [this.amountText = '']);

  final String name;

  /// Amount as typed ("500 g"), empty when none was recognised.
  final String amountText;

  KitchenAmount? get amount =>
      amountText.isEmpty ? null : parseKitchenAmount(amountText);
}

const _number = r'(\d+(?:[.,]\d+)?(?:\s*[½¼¾⅓⅔])?|[½¼¾⅓⅔])';
const _unit = r'([A-Za-zÄÖÜäöüß]+\.?)';
final _withUnit = RegExp('^$_number\\s*$_unit\\s+(.+)\$');
final _plainNumber = RegExp('^$_number(?:\\s*[xX])?\\s+(.+)\$');
final _trailingAmount = RegExp('^(.+?)[,\\s]\\s*$_number\\s*$_unit\$');
final _letter = RegExp(r'[A-Za-zÄÖÜäöüß]');

/// Splits "500 g Reis", "Reis 500g", "2 Eier", "3x Joghurt" or
/// "Milch, 1 l" into name and amount. Text that does not clearly contain an
/// amount stays the name ("7-Korn Brot", "Mehl Type 405"), so nothing is
/// guessed.
ShoppingInput splitShoppingInput(String text) {
  final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (cleaned.isEmpty) return const ShoppingInput('');

  ShoppingInput? parts(String number, String? unit, String name) {
    final trimmedName = name.trim().replaceAll(RegExp(r'^[,;:]\s*'), '');
    if (!_letter.hasMatch(trimmedName)) return null;
    final word = unit == null || unit.toLowerCase() == 'x' ? null : unit;
    final amountText = [number.trim(), ?word].join(' ');
    if (parseKitchenAmount(amountText) == null) return null;
    return ShoppingInput(trimmedName, amountText);
  }

  // "500 g Reis", "2 Dosen Tomaten", "½ Bund Petersilie"
  if (_withUnit.firstMatch(cleaned) case final m?) {
    if (parts(m[1]!, m[2], m[3]!) case final parsed?) return parsed;
  }
  // "2 Eier", "3x Joghurt", "3 x Joghurt"
  if (_plainNumber.firstMatch(cleaned) case final m?) {
    if (parts(m[1]!, null, m[2]!) case final parsed?) return parsed;
  }
  // "Reis 500g", "Milch, 1 l", "Joghurt 3x" – only with a unit word.
  if (_trailingAmount.firstMatch(cleaned) case final m?) {
    if (parts(m[2]!, m[3], m[1]!) case final parsed?) return parsed;
  }
  return ShoppingInput(cleaned);
}
