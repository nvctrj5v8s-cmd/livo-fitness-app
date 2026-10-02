import '../models/app_models.dart';

/// Conservative content gate for Lookin's halal-sensitive catalog.
///
/// It blocks known pork, alcohol and gelatin terms. Land-animal meat is only
/// accepted when the supplied product text explicitly contains a halal marker.
/// This is a safety filter, not a religious certification of a product.
///
/// The same lists and matching rules exist in
/// `supabase/migrations/0014_halal_terms_extended.sql` and
/// `supabase/functions/barcode-lookup/index.ts`; `halal_content_policy_test`
/// checks that every term below also appears there.
///
/// Matching works on normalized text (lower case, ä → ae, ö → oe, ü → ue,
/// ß → ss, everything except a–z and 0–9 becomes a space):
/// 1. [harmlessPhrases] are removed first ("blood orange", "goat cheese").
/// 2. A term with a space is a phrase and must appear as whole words.
/// 3. A single-word term matches the whole word only ("gin" ≠ "ginger",
///    "rum" ≠ "drum"), unless it is in [prefixRoots] (word starts with it,
///    "schweinefleisch") or in [suffixRoots] (a longer word ends with it,
///    "leberwurst").
class HalalContentPolicy {
  const HalalContentPolicy._();

  /// Always excluded, even with a halal marker.
  static const hardForbiddenTerms = <String>[
    // Pork and pork products.
    'pork', 'pig', 'swine', 'boar', 'schwein', 'schweine', 'wildschwein',
    'bacon', 'ham', 'prosciutto', 'salami', 'pepperoni', 'lard', 'lardo',
    'lardon', 'speck', 'spam', 'scrapple', 'chitterling', 'chitterlings',
    'mortadella', 'pancetta', 'guanciale', 'capicola', 'liverwurst',
    'schinken', 'schmalz', 'kassler', 'kasseler', 'eisbein', 'saumagen',
    'leberkaese', 'blutwurst', 'black pudding', 'eggs benedict', 'egg benedict',
    // Blood.
    'blood', 'blut',
    // Gelatin and products that usually contain it.
    'gelatin', 'gelatine', 'collagen', 'kollagen', 'aspic', 'aspik',
    'suelze', 'gummy', 'gummies', 'gummi', 'fruchtgummi', 'weingummi',
    'marshmallow', 'jellybean', 'jelly bean', 'jelly beans', 'jelly candy',
    'jelly candies', 'jello', 'jell o', 'panna cotta',
    // Alcohol, spirits, wine, beer and cocktails.
    'alcohol', 'alkohol', 'ethanol', 'beer', 'bier', 'radler', 'wine', 'wein',
    'rotwein', 'weisswein', 'redwine', 'whitewine', 'gluehwein', 'weinbrand',
    'sekt', 'prosecco', 'champagne', 'vermouth', 'wermut', 'sherry', 'sake',
    'cider', 'hard seltzer', 'mead', 'whisky', 'whiskey', 'bourbon',
    'scotch', 'vodka', 'rum', 'rumtopf', 'rumkugel', 'rumkugeln', 'gin',
    'brandy', 'cognac', 'armagnac', 'calvados', 'grappa', 'ouzo', 'raki',
    'absinth', 'absinthe', 'pisco', 'mezcal', 'tequila', 'kirschwasser',
    'obstler', 'schnapps', 'schnaps', 'liqueur', 'liquor', 'likoer',
    'amaretto', 'kahlua', 'baileys', 'aperol', 'campari', 'daiquiri',
    'margarita', 'martini', 'mojito', 'mimosa', 'manhattan', 'negroni',
    'cosmopolitan', 'caipirinha', 'screwdriver', 'sangria', 'eggnog',
    'punsch', 'bowle', 'bloody mary', 'long island', 'pina colada',
    'irish coffee', 'white russian', 'black russian', 'mai tai', 'hot toddy',
    'rum punch', 'mint julep', 'tom collins', 'cuba libre', 'cocktail',
  ];

  /// Land-animal meat: allowed only together with a [halalMarkers] word.
  static const landAnimalMeatTerms = <String>[
    'meat', 'fleisch', 'chicken', 'huhn', 'haehnchen', 'hen', 'poultry',
    'turkey', 'pute', 'truthahn', 'beef', 'rind', 'veal', 'kalb', 'lamb',
    'lamm', 'mutton', 'goat', 'ziege', 'duck', 'ente', 'goose', 'gans',
    'gaense', 'quail', 'wachtel', 'pheasant', 'fasan', 'venison', 'deer',
    'elk', 'moose', 'hirsch', 'reh', 'bison', 'ostrich', 'rabbit', 'hare',
    'kaninchen', 'frog', 'froschschenkel',
    // Sausages and processed meat.
    'wurst', 'sausage', 'bratwurst', 'knockwurst', 'knackwurst', 'bologna',
    'frankfurter', 'frankfurters', 'franks', 'hot dog', 'hot dogs', 'hotdog',
    'chorizo', 'kielbasa', 'andouille', 'pastrami', 'jerky', 'mett',
    // Cuts, offal and meat dishes.
    'steak', 'steaks', 'ribeye', 'sirloin', 'tenderloin', 'porterhouse',
    'brisket', 'rib', 'ribs', 'sparerib', 'oxtail', 'ochsenschwanz',
    'tongue', 'tripe', 'kutteln', 'pansen', 'gizzard', 'sweetbread',
    'giblet', 'offal', 'innereien', 'liver', 'livers', 'leber', 'hamburger',
    'cheeseburger', 'chiliburger', 'whopper', 'big mac', 'salisbury',
    'sloppy joe', 'pot roast', 'meatball', 'meatloaf', 'frikadelle',
    'bulette', 'buletten', 'hackfleisch', 'gehacktes', 'kotelett',
    'schnitzel', 'gulasch', 'goulash', 'bolognese', 'gyro', 'gyros',
    'doener', 'doner', 'kebab', 'kebap', 'shawarma', 'schawarma', 'carne',
    'carnitas', 'barbacoa', 'birria', 'pozole', 'menudo', 'tamale',
    'tamales', 'reuben', 'club sandwich', 'italian sandwich',
    'cuban sandwich', 'french dip', 'shepherd s pie', 'shepherds pie',
    'wonton soup', 'soup wonton', 'wonton dumpling', 'pot sticker',
    'pot stickers', 'barbecue sandwich', 'frito pie',
  ];

  static const halalMarkers = <String>['halal', 'zabiha', 'dhabiha'];

  /// Words that start with these roots also match ("Hähnchenbrust",
  /// "Schweinefleisch", "Tequila-Sunrise", "Gummibärchen").
  static const prefixRoots = <String>{
    'schwein',
    'bacon',
    'prosciutto',
    'salami',
    'pepperoni',
    'lardon',
    'mortadella',
    'pancetta',
    'chitterling',
    'liverwurst',
    'schinken',
    'schmalz',
    'gelatin',
    'gummi',
    'gummy',
    'fruchtgummi',
    'marshmallow',
    'jellybean',
    'alkohol',
    'alcohol',
    'ethanol',
    'beer',
    'whisky',
    'whiskey',
    'bourbon',
    'vodka',
    'brandy',
    'cognac',
    'champagne',
    'prosecco',
    'vermouth',
    'tequila',
    'schnapps',
    'liqueur',
    'liquor',
    'amaretto',
    'daiquiri',
    'margarita',
    'martini',
    'mojito',
    'sangria',
    'eggnog',
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
    'bratwurst',
    'frankfurter',
    'hotdog',
    'chorizo',
    'pastrami',
    'kielbasa',
    'hamburger',
    'cheeseburger',
    'sparerib',
    'gizzard',
    'sweetbread',
    'giblet',
    'liver',
    'leber',
    'kaninchen',
    'frikadelle',
    'hackfleisch',
    'kotelett',
    'schnitzel',
    'gulasch',
    'goulash',
  };

  /// Longer words that end with these roots also match (German compounds
  /// such as "Leberwurst", "Hackfleisch", "Rumpsteak", "Eierlikör").
  static const suffixRoots = <String>{
    'fleisch',
    'wurst',
    'schinken',
    'schmalz',
    'steak',
    'schnitzel',
    'kotelett',
    'gulasch',
    'likoer',
  };

  /// Harmless words that merely start with a root: "Beeren" is not "beer".
  static const prefixExceptions = <String, List<String>>{
    'beer': ['beere'],
  };

  /// Removed before any check. Whole words or phrases that contain a listed
  /// term but describe a permitted food.
  static const harmlessPhrases = <String>[
    'blood orange',
    'blood oranges',
    'hamburger bun',
    'hamburger buns',
    'hamburger roll',
    'hamburger rolls',
    'hot dog bun',
    'hot dog buns',
    'hot dog roll',
    'hot dog rolls',
    'quail egg',
    'quail eggs',
    'goose egg',
    'goose eggs',
    'duck egg',
    'duck eggs',
    'goat cheese',
    'cheese goat',
    'goat milk',
    'goats milk',
    'goat s milk',
    'milk goat',
    'cod liver',
    'steak sauce',
    'salmon steak',
    'tuna steak',
    'fish steak',
    'swordfish steak',
    'halibut steak',
    'cauliflower steak',
    'sweet tamale',
    'tamale sweet',
    'fruchtfleisch',
    'kokosfleisch',
    'butterschmalz',
    'lebertran',
    'lachssteak',
    'thunfischsteak',
    'fischsteak',
    'blumenkohlsteak',
    'tofusteak',
    'sellerieschnitzel',
    'tofuschnitzel',
    'fruit cocktail',
    'cocktail sauce',
    'shrimp cocktail',
    'prawn cocktail',
    'juice cocktail',
    'cocktail tomato',
    'cocktail tomatoes',
    'meatless',
  ];

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
      ...recipe.equipment,
      for (final ingredient in recipe.ingredients) ...[
        ingredient.name,
        ingredient.measure ?? '',
        ingredient.note ?? '',
      ],
      for (final step in recipe.steps) ...[step.title ?? '', step.text],
      ...?recipe.premiumDetails?.allTexts,
    ].join(' '),
  );

  static bool isAllowedText(String value) => restrictionReason(value) == null;

  static String? restrictionReason(String value) {
    final text = _withoutHarmlessPhrases(normalize(value));
    if (text.isEmpty) return null;
    if (hardForbiddenTerms.any((term) => _containsTerm(text, term))) {
      return 'Dieser Eintrag enthält einen in Lookin ausgeschlossenen Bestandteil.';
    }
    final hasLandAnimalMeat = landAnimalMeatTerms.any(
      (term) => _containsTerm(text, term),
    );
    final explicitlyHalal = halalMarkers.any(
      (marker) => _containsTerm(text, marker),
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

  static String _withoutHarmlessPhrases(String normalized) {
    var padded = ' $normalized ';
    for (final phrase in harmlessPhrases) {
      // Replace repeatedly: adjacent matches share their separating space.
      while (padded.contains(' $phrase ')) {
        padded = padded.replaceAll(' $phrase ', ' ');
      }
    }
    return padded.trim();
  }

  static bool _containsTerm(String normalizedValue, String term) {
    if (term.contains(' ')) return ' $normalizedValue '.contains(' $term ');
    final exceptions = prefixExceptions[term] ?? const [];
    final prefix = prefixRoots.contains(term);
    final suffix = suffixRoots.contains(term);
    return normalizedValue
        .split(' ')
        .any(
          (word) =>
              word == term ||
              (prefix &&
                  word.startsWith(term) &&
                  !exceptions.any(word.startsWith)) ||
              (suffix && word.length > term.length && word.endsWith(term)),
        );
  }
}
