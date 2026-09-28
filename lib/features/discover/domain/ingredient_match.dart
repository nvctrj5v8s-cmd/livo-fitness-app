import '../../../core/models/app_models.dart';

/// Tolerant matching between what someone has at home and the ingredients of
/// a recipe. Pure Dart without Flutter or I/O, so it works for every catalog
/// recipe (no recipe IDs are hard-coded) and is fully unit-testable.
///
/// The idea: every ingredient name is reduced to one or more *keys*.
/// "Kartoffeln, festkochend", "Kartoffel" and "Erdäpfel" all become
/// `kartoffel`; "Dosentomaten" becomes `dosentomat`, which still matches
/// `tomat` because German compounds name the kind of thing last
/// ("Kirschtomate" is a tomato). A short list keeps compounds apart that only
/// look similar ("Süßkartoffel" is not a potato, "Kokosmilch" is not milk).

/// Staples offered as quick picks in the pantry and in "Was kann ich
/// kochen?". Display names in the form people usually buy them.
const kitchenStaples = [
  'Kartoffeln',
  'Reis',
  'Nudeln',
  'Eier',
  'Zwiebeln',
  'Knoblauch',
  'Haferflocken',
  'Milch',
  'Mehl',
  'Dosentomaten',
  'Linsen',
  'Kichererbsen',
  'Butter',
  'Joghurt',
  'Käse',
  'Karotten',
  'Paprika',
  'Tomaten',
];

/// Human-readable description of the basics that count as available when
/// the corresponding switch is on.
const kitchenBasicsLabel =
    'Salz, Pfeffer, Öl, Wasser und gängige Gewürze wie Paprikapulver, '
    'Currypulver, Kreuzkümmel, Zimt oder Oregano';

/// Folds case, umlauts, their "ae/oe/ue" spellings and common accents so
/// "Käse", "Kaese" and "Kase" all become `kase`.
String foldIngredientText(String value) {
  final buffer = StringBuffer();
  for (final rune in value.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_foldedLetters[char] ?? char);
  }
  return buffer
      .toString()
      .replaceAll('ae', 'a')
      .replaceAll('oe', 'o')
      .replaceAll('ue', 'u');
}

const _foldedLetters = {
  'ä': 'a',
  'ö': 'o',
  'ü': 'u',
  'ß': 'ss',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ó': 'o',
  'ô': 'o',
  'ú': 'u',
  'û': 'u',
  'ç': 'c',
  'ñ': 'n',
};

/// Reduces one folded word to a singular-like stem. The same rules run on
/// both sides of a comparison, so the stems only have to be consistent, not
/// linguistically perfect: "tomaten"/"tomate" → `tomat`,
/// "kartoffeln" → `kartoffel`, "eier" → `ei`, "champignons" → `champignon`.
String ingredientStem(String word) {
  var w = word;
  if (w.length <= 3) return w;
  final irregular = _irregularStems[w];
  if (irregular != null) return irregular;
  if (w.endsWith('eier')) return w.substring(0, w.length - 2);
  final keepS =
      w.endsWith('ss') || w.endsWith('us') || _wordsEndingInS.any(w.endsWith);
  if (!keepS && w.length > 4 && w.endsWith('s')) {
    final previous = w[w.length - 2];
    if ('aoin'.contains(previous)) w = w.substring(0, w.length - 1);
  }
  if (w.length > 4 &&
      (w.endsWith('en') || w.endsWith('ln') || w.endsWith('rn'))) {
    w = w.substring(0, w.length - 1);
  }
  if (w.length > 3 && w.endsWith('e')) w = w.substring(0, w.length - 1);
  return w;
}

const _irregularStems = {'eier': 'ei', 'krauter': 'kraut', 'blatter': 'blatt'};

/// Singular words whose final "s" is not a plural ending.
const _wordsEndingInS = ['reis', 'mais', 'kurbis', 'ananas', 'anis', 'kakaos'];

/// Words that describe state, colour, size or packaging rather than the
/// ingredient itself. Folded spelling.
final _descriptorWords = {
  ...'rot rote roter rotes gelb gelbe gelber grun grune gruner grunes'.split(
    ' ',
  ),
  ...'frisch frische frischer frisches gehackt gehackte gehackter passiert '
          'passierte getrocknet getrocknete getrockneter getrocknetes gekocht '
          'gekochte gekochter roh rohe tk tiefgekuhlt tiefgekuhlte '
          'tiefgefroren tiefkuhl bio fein feine feiner grob grobe klein kleine '
          'kleiner gross grosse grosser festkochend festkochende '
          'mehligkochend mehligkochende vorwiegend geschalt geschalte '
          'ungeschalt gewurfelt gewurfelte gerieben geriebene geriebener '
          'gerauchert natur light fettarm fettarme mager vollfett griechisch '
          'griechischer griechische stuckig ganz ganze halb halbe jung junge '
          'junger reif reife weiss weisse weisser braun braune brauner '
          'schwarz schwarze schwarzer mild milde scharf scharfe eingelegt '
          'eingelegte abgetropft abgetropfte ungesalzen gesalzen extra nativ '
          'natives vegan vegane veganer vegetarisch halal zertifiziert'
      .split(' '),
  ...'und oder mit ohne von aus der die das dem den des ein eine einer etwas '
          'nach geschmack optional zum zur fur dose dosen glas packung tube '
          'beutel stuck prise bund el tl g kg ml l type typ'
      .split(' '),
  ...'kalt warm gegart gebraten gedampft blanchiert zimmerwarm weich hart '
          'gemischt gemischte bunt bunte hell helle heller dunkel dunkle zart '
          'zarte kernig kernige instant kornig edelsuss rosenscharf gemahlen '
          'gemahlene gemahlener selbst gemacht fertig reste rest'
      .split(' '),
};

/// Multi-word names that mean one thing. Applied to the folded text before
/// it is split into words.
const _phrases = {
  'saure sahne': 'schmand',
  'creme fraiche': 'cremefraiche',
  'garam masala': 'garammasala',
  'krauter der provence': 'provencekrauter',
  'italienische krauter': 'italienischekrauter',
  'tomaten aus der dose': 'dosentomaten',
};

/// Regional names, household cuts and a few English catalog words, mapped to
/// one canonical German word (alias → canonical).
const _synonyms = {
  'Erdäpfel': 'Kartoffel',
  'Drillinge': 'Kartoffel',
  'Potato': 'Kartoffel',
  'Potatoes': 'Kartoffel',
  'Paradeiser': 'Tomate',
  'Paradeis': 'Tomate',
  'Passata': 'Tomate',
  'Tomato': 'Tomate',
  'Tomatoes': 'Tomate',
  'Möhre': 'Karotte',
  'Mohrrübe': 'Karotte',
  'Rübli': 'Karotte',
  'Carrot': 'Karotte',
  'Carrots': 'Karotte',
  'Pasta': 'Nudel',
  'Spaghetti': 'Nudel',
  'Penne': 'Nudel',
  'Fusilli': 'Nudel',
  'Makkaroni': 'Nudel',
  'Maccheroni': 'Nudel',
  'Tagliatelle': 'Nudel',
  'Farfalle': 'Nudel',
  'Rigatoni': 'Nudel',
  'Linguine': 'Nudel',
  'Noodles': 'Nudel',
  'Porree': 'Lauch',
  'Karfiol': 'Blumenkohl',
  'Melanzani': 'Aubergine',
  'Zucchetti': 'Zucchini',
  'Topfen': 'Quark',
  'Rahm': 'Sahne',
  'Obers': 'Sahne',
  'Schlagobers': 'Sahne',
  'Sauerrahm': 'Schmand',
  'Jogurt': 'Joghurt',
  'Yoghurt': 'Joghurt',
  'Yogurt': 'Joghurt',
  'Eigelb': 'Ei',
  'Eiweiß': 'Ei',
  'Eiklar': 'Ei',
  'Egg': 'Ei',
  'Eggs': 'Ei',
  'Knoblauchzehe': 'Knoblauch',
  'Garlic': 'Knoblauch',
  'Paprikaschote': 'Paprika',
  'Chilischote': 'Chili',
  'Vanilleschote': 'Vanille',
  'Zimtstange': 'Zimt',
  'Ingwerknolle': 'Ingwer',
  'Ingwerwurzel': 'Ingwer',
  'Lorbeerblatt': 'Lorbeer',
  'Lorbeerblätter': 'Lorbeer',
  'Rosmarinzweig': 'Rosmarin',
  'Rosmarinzweige': 'Rosmarin',
  'Thymianzweig': 'Thymian',
  'Thymianzweige': 'Thymian',
  'Basilikumblätter': 'Basilikum',
  'Minzblätter': 'Minze',
  'Pfefferkörner': 'Pfeffer',
  'Hafer': 'Haferflocken',
  'Oats': 'Haferflocken',
  'Basmati': 'Reis',
  'Rice': 'Reis',
  'Onion': 'Zwiebel',
  'Onions': 'Zwiebel',
  'Milk': 'Milch',
  'Flour': 'Mehl',
  'Lentil': 'Linse',
  'Lentils': 'Linse',
  'Hühnchen': 'Hähnchen',
  'Huhn': 'Hähnchen',
  'Hendl': 'Hähnchen',
  'Hirtenkäse': 'Feta',
  'Schafskäse': 'Feta',
  'Bouillon': 'Brühe',
  'Brühwürfel': 'Brühe',
  'Garbanzo': 'Kichererbse',
  'Champignon': 'Pilz',
  'Champignons': 'Pilz',
  'Frühlingslauch': 'Frühlingszwiebel',
  'Lauchzwiebel': 'Frühlingszwiebel',
  'Zitronensaft': 'Zitrone',
  'Limettensaft': 'Limette',
};

/// Compounds that end like a more general ingredient but are something else.
const _independentWords = [
  'Süßkartoffel',
  'Kichererbse',
  'Zuckerschote',
  'Kokosmilch',
  'Hafermilch',
  'Sojamilch',
  'Mandelmilch',
  'Reismilch',
  'Buttermilch',
  'Kondensmilch',
  'Erdnussbutter',
  'Kakaobutter',
  'Muskatnuss',
  'Kokosnuss',
  'Frühlingszwiebel',
  'Frischkäse',
  'Hüttenkäse',
  'Sojasahne',
  'Hafersahne',
  'Kokossahne',
  'Sojajoghurt',
  'Kokosjoghurt',
  'Kokoswasser',
  'Rosenwasser',
  'Seelachs',
  'Paniermehl',
  'Mandelmehl',
  'Kokosmehl',
  'Reismehl',
  'Kichererbsenmehl',
  'Blumenkohl',
  'Rosenkohl',
  'Grünkohl',
  'Zitronengras',
];

/// Basics that count as available when the user allows it.
const _basicWords = [
  'Salz',
  'Pfeffer',
  'Öl',
  'Wasser',
  'Gewürze',
  'Gewürzmischung',
  'Paprikapulver',
  'Currypulver',
  'Chilipulver',
  'Chiliflocken',
  'Knoblauchpulver',
  'Zwiebelpulver',
  'Ingwerpulver',
  'Kreuzkümmel',
  'Kümmel',
  'Zimt',
  'Oregano',
  'Thymian',
  'Majoran',
  'Muskat',
  'Muskatnuss',
  'Kurkuma',
  'Lorbeer',
  'Piment',
  'Nelke',
  'Garam Masala',
  'Kräuter der Provence',
  'Italienische Kräuter',
];

/// Folded words that mark a spice even when the head noun is ambiguous
/// ("Paprika, edelsüß" is the powder, not the vegetable).
const _spiceMarkers = ['edelsuss', 'rosenscharf'];

/// Short keys that may still match as the end of a compound
/// ("Olivenöl" → öl, "Hühnerei" → ei), with known false friends.
const _shortSuffixKeys = {
  'ol': ['karfiol', 'alkohol', 'menthol'],
  'ei': ['brei', 'salbei'],
};

String _stemOf(String name) => ingredientStem(
  foldIngredientText(name).replaceAll(RegExp(r'[^a-z0-9]'), ''),
);

final Map<String, String> _synonymStems = {
  for (final entry in _synonyms.entries)
    _stemOf(entry.key): _stemOf(entry.value),
};

final Set<String> _independent = {
  for (final word in _independentWords) _canonicalizeKey(_stemOf(word)),
};

final Set<String> _basicKeys = {
  for (final word in _basicWords) ..._keysFor(word),
};

/// Maps a stem to its canonical key: synonyms, "…filet" cuts and regional
/// words at the end of compounds ("Vollkornspaghetti" → `vollkornnudel`).
String _canonicalizeKey(String stem) {
  final direct = _synonymStems[stem];
  if (direct != null) return direct;
  for (final cut in const ['filets', 'filet']) {
    if (stem.endsWith(cut) && stem.length - cut.length >= 3) {
      final base = ingredientStem(stem.substring(0, stem.length - cut.length));
      return _synonymStems[base] ?? base;
    }
  }
  for (final MapEntry(key: alias, value: canonical) in _synonymStems.entries) {
    if (alias.length >= 5 &&
        stem.length > alias.length &&
        stem.endsWith(alias)) {
      return stem.substring(0, stem.length - alias.length) + canonical;
    }
  }
  return stem;
}

/// The part of an ingredient name that names the ingredient:
/// "Kartoffeln, festkochend (mehlig)" → "Kartoffeln".
String ingredientDisplayName(String name) {
  final primary = name.split(RegExp(r'[,(;]')).first.trim();
  return primary.isEmpty ? name.trim() : primary;
}

/// Canonical keys for an ingredient or pantry name. Usually one key; names
/// such as "Salz und Pfeffer" or "Butter oder Öl" produce several.
Set<String> ingredientKeys(String name) {
  final cached = _keyCache[name];
  if (cached != null) return cached;
  final primary = _keysFor(ingredientDisplayName(name));
  final keys = Set<String>.unmodifiable(
    primary.isNotEmpty ? primary : _keysFor(name),
  );
  // Catalog names repeat constantly while typing; keep the cache bounded.
  if (_keyCache.length > 4000) _keyCache.clear();
  return _keyCache[name] = keys;
}

final _keyCache = <String, Set<String>>{};

Set<String> _keysFor(String text) {
  var folded = foldIngredientText(text);
  for (final MapEntry(key: phrase, value: word) in _phrases.entries) {
    folded = folded.replaceAll(phrase, word);
  }
  return {
    for (final word in folded.split(RegExp(r'[^a-z0-9]+')))
      if (word.isNotEmpty &&
          !_descriptorWords.contains(word) &&
          !RegExp(r'^\d+$').hasMatch(word))
        _canonicalizeKey(ingredientStem(word)),
  };
}

/// Whether two canonical keys name the same ingredient. Equal keys match;
/// otherwise one key has to end the other ("dosentomat" ↔ "tomat"), unless
/// the longer one is a known independent compound ("susskartoffel").
bool ingredientKeysMatch(String a, String b) {
  if (a == b) return true;
  final shorter = a.length <= b.length ? a : b;
  final longer = identical(shorter, a) ? b : a;
  if (!longer.endsWith(shorter)) return false;
  final falseFriends = _shortSuffixKeys[shorter];
  if (falseFriends != null) {
    if (falseFriends.any(longer.endsWith)) return false;
  } else if (shorter.length < 3) {
    return false;
  }
  for (final independent in _independent) {
    if (independent.length > shorter.length &&
        independent.endsWith(shorter) &&
        longer.endsWith(independent)) {
      return false;
    }
  }
  return true;
}

bool _anyKeysMatch(Set<String> first, Set<String> second) =>
    first.any((a) => second.any((b) => ingredientKeysMatch(a, b)));

/// Whether two free-text names describe the same ingredient.
bool ingredientNamesMatch(String first, String second) =>
    _anyKeysMatch(ingredientKeys(first), ingredientKeys(second));

/// Salt, pepper, oil, water and common spices.
bool isBasicIngredient(String name) {
  final cached = _basicCache[name];
  if (cached != null) return cached;
  final folded = foldIngredientText(name);
  final basic =
      _spiceMarkers.any(folded.contains) ||
      _anyKeysMatch(ingredientKeys(name), _basicKeys);
  if (_basicCache.length > 4000) _basicCache.clear();
  return _basicCache[name] = basic;
}

final _basicCache = <String, bool>{};

/// Precomputed keys for everything someone has at home.
class IngredientInventory {
  IngredientInventory(Iterable<String> names)
    : _entries = [
        for (final name in names)
          if (name.trim().isNotEmpty) (name.trim(), ingredientKeys(name)),
      ];

  final List<(String, Set<String>)> _entries;

  bool get isEmpty => _entries.isEmpty;

  /// The first inventory name matching [ingredientName], or `null`.
  String? matchFor(String ingredientName) {
    final keys = ingredientKeys(ingredientName);
    for (final (name, entryKeys) in _entries) {
      if (_anyKeysMatch(entryKeys, keys)) return name;
    }
    return null;
  }

  bool has(String ingredientName) => matchFor(ingredientName) != null;
}

/// How well one recipe fits what is at home.
class RecipeMatch {
  const RecipeMatch({
    required this.recipe,
    required this.available,
    required this.assumedBasics,
    required this.missing,
    required this.order,
  });

  final Recipe recipe;

  /// Ingredients covered by the user's own list.
  final List<RecipeIngredient> available;

  /// Basics (salt, oil, spices …) counted as available by default.
  final List<RecipeIngredient> assumedBasics;
  final List<RecipeIngredient> missing;

  /// Position in the incoming (personalised) recipe order; tie-breaker.
  final int order;

  int get total => recipe.ingredients.length;
  int get covered => available.length + assumedBasics.length;
  double get coverage => total == 0 ? 0 : covered / total;
  bool get canCookNow => missing.isEmpty;
}

/// Recipes that use at least one of [have] (basics alone never qualify),
/// ranked by the share of ingredients at home, then by the fewest missing
/// ingredients, then by how many of the user's items they use.
List<RecipeMatch> matchRecipesToInventory(
  List<Recipe> recipes,
  Iterable<String> have, {
  bool assumeBasics = true,
}) {
  final inventory = IngredientInventory(have);
  if (inventory.isEmpty) return const [];
  final matches = <RecipeMatch>[];
  for (final (index, recipe) in recipes.indexed) {
    if (recipe.ingredients.isEmpty) continue;
    final available = <RecipeIngredient>[];
    final basics = <RecipeIngredient>[];
    final missing = <RecipeIngredient>[];
    var usesOwnItem = false;
    for (final ingredient in recipe.ingredients) {
      final basic = isBasicIngredient(ingredient.name);
      if (inventory.has(ingredient.name)) {
        available.add(ingredient);
        if (!basic) usesOwnItem = true;
      } else if (basic && assumeBasics) {
        basics.add(ingredient);
      } else {
        missing.add(ingredient);
      }
    }
    if (!usesOwnItem) continue;
    matches.add(
      RecipeMatch(
        recipe: recipe,
        available: available,
        assumedBasics: basics,
        missing: missing,
        order: index,
      ),
    );
  }
  matches.sort((a, b) {
    final byCoverage = b.coverage.compareTo(a.coverage);
    if (byCoverage != 0) return byCoverage;
    final byMissing = a.missing.length.compareTo(b.missing.length);
    if (byMissing != 0) return byMissing;
    final byUsed = b.available.length.compareTo(a.available.length);
    if (byUsed != 0) return byUsed;
    return a.order.compareTo(b.order);
  });
  return matches;
}

/// Ingredient names for autocomplete: staples plus every ingredient in the
/// catalog, most frequent first. Names matching [exclude] are skipped.
List<String> ingredientSuggestions(
  Iterable<Recipe> recipes,
  String query, {
  Iterable<String> exclude = const [],
  int limit = 6,
}) {
  final folded = foldIngredientText(query.trim());
  if (folded.isEmpty) return const [];
  final counts = <String, int>{};
  final names = <String, String>{};
  void consider(String rawName, int weight) {
    final name = ingredientDisplayName(rawName);
    final keys = ingredientKeys(name);
    if (keys.isEmpty) return;
    final id = (keys.toList()..sort()).join('|');
    names.putIfAbsent(id, () => name);
    counts[id] = (counts[id] ?? 0) + weight;
  }

  for (final staple in kitchenStaples) {
    consider(staple, 2);
  }
  for (final recipe in recipes) {
    for (final ingredient in recipe.ingredients) {
      consider(ingredient.name, 1);
    }
  }
  final excluded = IngredientInventory(exclude);
  final wordStart = <String>[];
  final inside = <String>[];
  final ids = counts.keys.toList()
    ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
  for (final id in ids) {
    final name = names[id]!;
    if (excluded.has(name)) continue;
    final foldedName = foldIngredientText(name);
    final words = foldedName.split(RegExp(r'[^a-z0-9]+'));
    if (words.any((word) => word.startsWith(folded))) {
      wordStart.add(name);
    } else if (foldedName.contains(folded)) {
      inside.add(name);
    }
  }
  return [...wordStart, ...inside].take(limit).toList();
}
