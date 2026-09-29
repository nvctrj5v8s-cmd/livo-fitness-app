import '../../../core/models/app_models.dart';

/// The 14 allergens that EU law (LMIV, Annex II) requires on labels, plus
/// lactose intolerance, which is kept separate from a milk allergy.
///
/// The check is a text screening of names, ingredient lists and allergen
/// tags. It errs on the side of warning, never confirms that something is
/// safe and is no medical assessment. Pure Dart, fully unit-testable.
abstract final class AllergySafety {
  static const allergens = <AllergenOption>[
    AllergenOption(
      'gluten',
      'Glutenhaltiges Getreide',
      aliases: ['gluten', 'getreide', 'weizen', 'wheat', 'zoeliakie'],
      terms: [
        'gluten', 'weizen', 'wheat', 'rye', 'roggen', 'gerste', 'barley', //
        'dinkel', 'spelt', 'hafer', 'oat', 'oats', 'kamut', 'gruenkern',
        'emmer', 'einkorn', 'triticale', 'malz', 'malt', 'mehl', 'flour',
        'brot', 'bread', 'semmel', 'toast', 'baguette', 'zwieback', 'nudel',
        'noodle', 'pasta', 'spaghetti', 'penne', 'fusilli', 'farfalle',
        'tagliatelle', 'lasagne', 'makkaroni', 'ravioli', 'tortellini',
        'gnocchi', 'couscous', 'bulgur', 'griess', 'semolina', 'panko',
        'paniermehl', 'panade', 'paniert', 'seitan', 'pizza', 'croissant',
        'keks', 'kuchen', 'cracker', 'waffel', 'wrap', 'pita', 'fladenbrot',
        'udon', 'ramen', 'graupen', 'muesli', 'musli', 'granola',
      ],
      except: [
        'buchweizen', 'glutenfrei', 'reisnudel', 'glasnudel', 'reismehl', //
        'maismehl', 'mandelmehl', 'kokosmehl', 'kartoffelmehl',
        'kichererbsenmehl', 'linsenmehl', 'johannisbrot', 'reiswaffel',
        'maiswaffel', 'maisgriess', 'mehlig', 'soba',
      ],
      freeFrom: ['glutenfrei'],
    ),
    AllergenOption(
      'crustaceans',
      'Krebstiere',
      aliases: ['krebstiere', 'schalentiere', 'meeresfruechte', 'shellfish'],
      terms: [
        'garnele', 'shrimp', 'prawn', 'krabbe', 'crab', 'hummer', 'lobster', //
        'languste', 'scampi', 'krebs', 'krill', 'crustacean', 'crevette',
      ],
    ),
    AllergenOption(
      'eggs',
      'Eier',
      aliases: ['eier', 'ei', 'egg', 'eggs', 'huehnerei', 'huehnereiweiss'],
      terms: [
        'ei', 'eier', 'egg', 'eggs', 'eigelb', 'eiweiss', 'eiklar', //
        'spiegelei', 'ruehrei', 'omelett', 'frittata', 'mayonnaise', 'mayo',
        'aioli', 'baiser', 'meringue', 'albumin',
      ],
    ),
    AllergenOption(
      'fish',
      'Fisch',
      aliases: ['fisch', 'fish'],
      terms: [
        'fisch', 'fish', 'lachs', 'salmon', 'tuna', 'forelle', 'trout', //
        'kabeljau', 'cod', 'dorsch', 'seelachs', 'hering', 'herring',
        'makrele', 'mackerel', 'sardine', 'sardelle', 'anchovis', 'anchovy',
        'scholle', 'zander', 'pangasius', 'tilapia', 'rotbarsch',
        'heilbutt', 'worcester',
      ],
      except: ['tintenfisch'],
    ),
    AllergenOption(
      'peanuts',
      'Erdnüsse',
      aliases: ['erdnuesse', 'erdnuss', 'peanut', 'peanuts'],
      terms: ['erdnuss', 'erdnuesse', 'peanut', 'groundnut', 'arachis'],
    ),
    AllergenOption(
      'soy',
      'Soja',
      aliases: ['soja', 'soy', 'soya'],
      terms: [
        'soja', 'soy', 'soya', 'tofu', 'edamame', 'tempeh', 'miso', 'natto', //
      ],
    ),
    AllergenOption(
      'milk',
      'Milch',
      aliases: ['milch', 'milk', 'milchprodukte', 'milcheiweiss', 'dairy'],
      terms: [
        'milch', 'milk', 'dairy', 'butter', 'kaese', 'cheese', 'joghurt', //
        'jogurt', 'yoghurt', 'yogurt', 'quark', 'sahne', 'rahm', 'cream',
        'schmand', 'skyr', 'kefir', 'molke', 'whey', 'kasein', 'casein',
        'laktose', 'lactose', 'feta', 'mozzarella', 'parmesan', 'ricotta',
        'mascarpone', 'halloumi', 'gouda', 'emmentaler', 'camembert',
        'cheddar', 'pecorino', 'burrata', 'paneer', 'labneh', 'ghee',
        'creme fraiche',
      ],
      except: _plantMilkWords,
      freeFrom: _plantMarkers,
    ),
    AllergenOption(
      'tree_nuts',
      'Schalenfrüchte',
      aliases: ['schalenfruechte', 'nuesse', 'nuss', 'nuts', 'tree nuts'],
      terms: [
        'nuss', 'nuesse', 'nut', 'nuts', 'mandel', 'almond', 'haselnuss', //
        'hazelnut', 'walnuss', 'walnut', 'cashew', 'pistazie', 'pistachio',
        'pekannuss', 'pecan', 'macadamia', 'paranuss', 'marzipan', 'nougat',
        'praline', 'gianduja',
      ],
      except: [
        'erdnuss', 'erdnuesse', 'peanut', 'groundnut', 'muskat', 'kokos', //
        'coconut', 'butternuss', 'erdmandel',
      ],
    ),
    AllergenOption(
      'celery',
      'Sellerie',
      aliases: ['sellerie', 'celery'],
      terms: ['sellerie', 'celery', 'celeriac'],
    ),
    AllergenOption(
      'mustard',
      'Senf',
      aliases: ['senf', 'mustard'],
      terms: ['senf', 'mustard'],
    ),
    AllergenOption(
      'sesame',
      'Sesam',
      aliases: ['sesam', 'sesame'],
      terms: [
        'sesam', 'sesame', 'tahin', 'tahini', 'hummus', 'gomasio', 'halva', //
        'halwa',
      ],
    ),
    AllergenOption(
      'sulphites',
      'Schwefeldioxid / Sulfite',
      aliases: ['sulfite', 'sulfit', 'schwefeldioxid', 'sulphites'],
      terms: [
        'sulfit', 'sulphit', 'schwefeldioxid', 'sulfur dioxide', //
        'sulphur dioxide', 'geschwefelt', 'e220', 'e221', 'e222', 'e223',
        'e224', 'e226', 'e227', 'e228',
      ],
    ),
    AllergenOption(
      'lupin',
      'Lupinen',
      aliases: ['lupinen', 'lupine', 'lupin'],
      terms: ['lupin', 'lupine', 'lupinen'],
    ),
    AllergenOption(
      'molluscs',
      'Weichtiere',
      aliases: ['weichtiere', 'meeresfruechte', 'molluscs'],
      terms: [
        'muschel', 'mussel', 'auster', 'oyster', 'tintenfisch', 'kalmar', //
        'calamari', 'squid', 'oktopus', 'octopus', 'krake', 'sepia', 'clam',
        'scallop', 'weinbergschnecke', 'escargot', 'mollusc', 'mollusk',
        'weichtier',
      ],
    ),
    AllergenOption(
      'lactose_intolerance',
      'Laktose (Unverträglichkeit)',
      aliases: [
        'laktose',
        'lactose',
        'laktoseintoleranz',
        'laktoseunvertraeglichkeit',
      ],
      terms: [
        'laktose', 'lactose', 'milch', 'milk', 'dairy', 'butter', 'kaese', //
        'cheese', 'joghurt', 'jogurt', 'yoghurt', 'yogurt', 'quark', 'sahne',
        'rahm', 'cream', 'schmand', 'skyr', 'kefir', 'molke', 'whey',
        'feta', 'mozzarella', 'ricotta', 'mascarpone', 'halloumi', 'paneer',
        'labneh', 'creme fraiche',
      ],
      except: [..._plantMilkWords, 'laktosefrei', 'lactosefree'],
      freeFrom: [..._plantMarkers, 'laktosefrei', 'lactosefree'],
    ),
  ];

  /// Plant drinks and spreads whose names contain a dairy word.
  static const _plantMilkWords = [
    'kokosmilch', 'hafermilch', 'sojamilch', 'reismilch', 'mandelmilch', //
    'cashewmilch', 'haselnussmilch', 'erbsenmilch', 'pflanzenmilch',
    'erdnussbutter', 'kakaobutter', 'nussbutter', 'mandelbutter',
    'cashewbutter', 'sheabutter', 'butternuss', 'kokosjoghurt',
    'sojajoghurt', 'kokossahne', 'hafersahne', 'sojasahne', 'kokoscreme',
  ];

  /// A word right before a dairy word that makes it a plant product
  /// ("veganer Käse", "coconut milk").
  static const _plantMarkers = [
    'vegan', 'pflanzlich', 'kokos', 'coconut', 'hafer', 'oat', 'soja', //
    'soy', 'mandel', 'almond', 'reis', 'rice', 'milchfrei',
  ];

  static const _none = 'keine angegeben';

  /// Whether [profile] names at least one allergy or intolerance.
  static bool hasEntries(String profile) => _split(profile).isNotEmpty;

  /// Listed allergens named in [profile], also for older free-text profiles
  /// ("Erdnüsse, Laktose").
  static Set<String> selectedIds(String profile) {
    final tokens = _split(profile).map(_normalize).toSet();
    return {
      for (final option in allergens)
        if (tokens.any(option.isNamedBy)) option.id,
    };
  }

  /// Readable label for an allergen tag such as "en:milk".
  static String displayTag(String tag) {
    final normalized = _normalize(tag);
    for (final option in allergens) {
      if (option.isNamedBy(normalized)) return option.label;
    }
    return tag.contains(':')
        ? tag.substring(tag.indexOf(':') + 1).replaceAll('-', ' ')
        : tag.replaceAll('-', ' ');
  }

  /// Entries in [profile] that are not one of the listed allergens.
  static List<String> otherEntries(String profile) => [
    for (final token in _split(profile))
      if (!allergens.any((option) => option.isNamedBy(_normalize(token))))
        token,
  ];

  /// Stores the selection as readable text: labels first, then own entries.
  static String encode(Set<String> selected, String other) {
    final values = <String>[
      for (final option in allergens)
        if (selected.contains(option.id)) option.label,
      ..._split(other),
    ];
    final seen = <String>{};
    return values.where((value) => seen.add(_normalize(value))).join(', ');
  }

  static AllergyAssessment assessFood(FoodItem food, String profile) => _assess(
    profile,
    [
      food.name,
      food.brand ?? '',
      ...food.allergens,
      food.ingredientsText ?? '',
    ].join(' '),
    hasData:
        food.allergens.isNotEmpty ||
        (food.ingredientsText?.trim().isNotEmpty ?? false),
  );

  static AllergyAssessment assessText(
    String evidence,
    String profile, {
    required bool hasData,
  }) => _assess(profile, evidence, hasData: hasData);

  static AllergyAssessment assessRecipe(Recipe recipe, String profile) =>
      _assess(
        profile,
        [
          recipe.title,
          ...recipe.ingredients.expand(
            (item) => [
              item.name,
              ...item.allergens,
              item.ingredientsText ?? '',
            ],
          ),
        ].join(' '),
        hasData: recipe.ingredients.isNotEmpty,
      );

  static AllergyAssessment _assess(
    String profile,
    String evidence, {
    required bool hasData,
  }) {
    final selected = selectedIds(profile);
    final custom = otherEntries(profile);
    if (selected.isEmpty && custom.isEmpty) {
      return const AllergyAssessment.none();
    }
    final words = _normalize(evidence).split(' ')
      ..removeWhere((word) => word.isEmpty);
    final conflicts = <String>[
      for (final option in allergens)
        if (selected.contains(option.id) && option.matches(words)) option.label,
      for (final entry in custom)
        if (AllergenOption(entry, entry, terms: [entry]).matches(words)) entry,
    ];
    return AllergyAssessment(
      conflicts: conflicts.toSet().toList(growable: false),
      hasData: hasData,
      hasProfile: true,
    );
  }

  static List<String> _split(String value) => value
      .split(RegExp(r'[,;\n]+'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty && _normalize(item) != _none)
      .toList();
}

/// Folds case and umlauts and turns everything else into single spaces:
/// "Käse (gerieben)" → "kaese gerieben", "en:milk" → "en milk".
String _normalize(String value) => value
    .toLowerCase()
    .replaceAll('ä', 'ae')
    .replaceAll('ö', 'oe')
    .replaceAll('ü', 'ue')
    .replaceAll('ß', 'ss')
    .replaceAll(RegExp(r'^[a-z]{2}:'), '')
    .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
    .trim();

class AllergenOption {
  const AllergenOption(
    this.id,
    this.label, {
    required this.terms,
    this.aliases = const [],
    this.except = const [],
    this.freeFrom = const [],
  });

  final String id;
  final String label;

  /// Names of the allergen itself, used to read a stored profile.
  final List<String> aliases;

  /// Words that point to the allergen in a name or ingredient list. Terms of
  /// four or more letters also count inside German compounds
  /// ("Erdnussbutter", "Vollkornnudeln"); shorter ones only as a whole word.
  final List<String> terms;

  /// Word parts that look like a term but are something else
  /// ("Buchweizen" is no wheat, "Kokosmilch" no milk).
  final List<String> except;

  /// Words that, directly before a term, mean the product is free of it
  /// ("veganer Käse").
  final List<String> freeFrom;

  bool isNamedBy(String normalized) =>
      normalized == id ||
      normalized == _normalize(label) ||
      aliases.any((alias) => _normalize(alias) == normalized);

  /// Whether the normalized [words] of a text point to this allergen.
  bool matches(List<String> words) {
    final text = ' ${words.join(' ')} ';
    for (final term in terms) {
      final needle = _normalize(term);
      if (needle.contains(' ') && text.contains(' $needle ')) return true;
    }
    for (var index = 0; index < words.length; index++) {
      final word = words[index];
      final next = index + 1 < words.length ? words[index + 1] : '';
      final previous = index > 0 ? words[index - 1] : '';
      // "gluten free", "laktosefrei", "veganer Käse"
      if (next == 'free' || next == 'frei' || word.endsWith('frei')) continue;
      if (freeFrom.any((marker) => previous.startsWith(marker))) continue;
      if (except.any(word.contains)) continue;
      for (final term in terms) {
        final needle = _normalize(term);
        if (needle.isEmpty || needle.contains(' ')) continue;
        if (word == needle || (needle.length >= 4 && word.contains(needle))) {
          return true;
        }
      }
    }
    return false;
  }
}

class AllergyAssessment {
  const AllergyAssessment({
    required this.conflicts,
    required this.hasData,
    required this.hasProfile,
  });
  const AllergyAssessment.none()
    : conflicts = const [],
      hasData = false,
      hasProfile = false;
  final List<String> conflicts;
  final bool hasData;
  final bool hasProfile;
  bool get hasConflict => conflicts.isNotEmpty;
  bool get dataUnknown => hasProfile && !hasData;
}
