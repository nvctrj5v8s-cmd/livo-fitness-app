import '../models/app_models.dart';

/// Conservative content gate for LIVO's halal-sensitive catalog.
///
/// It blocks known pork, alcohol and gelatin terms. Land-animal meat is only
/// accepted when the supplied product text explicitly contains a halal marker.
/// This is a safety filter, not a religious certification of a product.
class HalalContentPolicy {
  const HalalContentPolicy._();

  static const _hardForbiddenTerms = <String>[
    'pork',
    'pig',
    'swine',
    'schwein',
    'schweine',
    'wildschwein',
    'bacon',
    'ham',
    'prosciutto',
    'salami',
    'pepperoni',
    'lard',
    'speck',
    'gelatin',
    'gelatine',
    'blood',
    'blut',
    'alcohol',
    'alkohol',
    'ethanol',
    'beer',
    'bier',
    'wine',
    'wein',
    'rotwein',
    'weisswein',
    'redwine',
    'whitewine',
    'whisky',
    'whiskey',
    'vodka',
    'rum',
    'gin',
    'brandy',
    'cognac',
    'champagne',
    'schnapps',
    'liqueur',
    'liquor',
    'likoer',
    'sherry',
    'sake',
    'cider',
    'mead',
  ];

  static const _landAnimalMeatTerms = <String>[
    'meat',
    'fleisch',
    'chicken',
    'huhn',
    'haehnchen',
    'hen',
    'poultry',
    'turkey',
    'pute',
    'truthahn',
    'beef',
    'rind',
    'veal',
    'kalb',
    'lamb',
    'lamm',
    'mutton',
    'goat',
    'ziege',
    'duck',
    'ente',
    'venison',
    'wurst',
    'sausage',
  ];

  static const _halalMarkers = <String>['halal', 'zabiha', 'dhabiha'];

  // German and English catalogue names commonly join a meat type and cut into
  // one word (for example, "Hähnchenbrust" or "Schweinefleisch"). These safe
  // roots catch those compounds without treating short, unrelated words such
  // as "gin" or "ham" as prefixes.
  static const _compoundRoots = <String>{
    'schwein',
    'bacon',
    'prosciutto',
    'salami',
    'pepperoni',
    'gelatin',
    'alkohol',
    'alcohol',
    'ethanol',
    'beer',
    'whisky',
    'whiskey',
    'vodka',
    'brandy',
    'cognac',
    'champagne',
    'schnapps',
    'liqueur',
    'liquor',
    'haehnchen',
    'chicken',
    'fleisch',
    'meat',
    'rind',
    'beef',
    'kalb',
    'veal',
    'lamm',
    'lamb',
    'pute',
    'turkey',
    'ente',
    'duck',
    'sausage',
  };

  static bool isAllowedFood(FoodItem food) => isAllowedText(
    [
      food.name,
      food.brand ?? '',
      food.ingredientsText ?? '',
      ...food.dietTags,
      ...food.allergens,
    ].join(' '),
  );

  static bool isAllowedRecipe(Recipe recipe) => isAllowedText(
    [
      recipe.title,
      recipe.subtitle,
      ...recipe.tags,
      ...recipe.ingredients.map((ingredient) => ingredient.name),
      ...recipe.instructions,
    ].join(' '),
  );

  static bool isAllowedText(String value) => restrictionReason(value) == null;

  static String? restrictionReason(String value) {
    final normalized = normalize(value);
    if (normalized.isEmpty) return null;
    if (_hardForbiddenTerms.any((term) => _containsTerm(normalized, term))) {
      return 'Dieser Eintrag enthält einen in LIVO ausgeschlossenen Bestandteil.';
    }
    final hasLandAnimalMeat = _landAnimalMeatTerms.any(
      (term) => _containsTerm(normalized, term),
    );
    final explicitlyHalal = _halalMarkers.any(
      (marker) => _containsTerm(normalized, marker),
    );
    if (hasLandAnimalMeat && !explicitlyHalal) {
      return 'Fleisch von Landtieren wird nur mit eindeutiger Halal-Kennzeichnung aufgenommen.';
    }
    return null;
  }

  static String normalize(String value) => value
      .toLowerCase()
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('ß', 'ss')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();

  static bool _containsTerm(String normalizedValue, String term) {
    final normalizedTerm = normalize(term);
    return normalizedValue
        .split(' ')
        .any(
          (word) =>
              word == normalizedTerm ||
              (_compoundRoots.contains(normalizedTerm) &&
                  word.startsWith(normalizedTerm)),
        );
  }
}
