import '../models/app_models.dart';

/// German query expansion for the mostly English USDA catalog. The original
/// source name is deliberately kept visible; this avoids presenting an
/// unverified automatic translation as if it were source data. A future app
/// locale can replace this compact synonym catalog with vetted translations.
class FoodSearchService {
  const FoodSearchService._();

  static const _aliases = <String, List<String>>{
    'haehnchen': ['chicken', 'poultry'],
    'huhn': ['chicken', 'poultry'],
    'pute': ['turkey'],
    'truthahn': ['turkey'],
    'rind': ['beef', 'veal'],
    'schwein': ['pork', 'ham', 'bacon'],
    'fisch': ['fish', 'salmon', 'tuna', 'cod'],
    'lachs': ['salmon'],
    'thunfisch': ['tuna'],
    'ei': ['egg'],
    'eier': ['egg'],
    'milch': ['milk'],
    'joghurt': ['yogurt', 'yoghurt'],
    'skyr': ['skyr'],
    'quark': ['quark', 'curd'],
    'kaese': ['cheese'],
    'butter': ['butter'],
    'reis': ['rice'],
    'nudel': ['pasta', 'noodle', 'spaghetti'],
    'nudeln': ['pasta', 'noodle', 'spaghetti'],
    'brot': ['bread'],
    'vollkorn': ['whole grain', 'whole wheat'],
    'hafer': ['oat', 'oatmeal'],
    'haferflocken': ['oat', 'oatmeal'],
    'kartoffel': ['potato'],
    'susskartoffel': ['sweet potato'],
    'bohne': ['bean'],
    'bohnen': ['bean'],
    'linse': ['lentil'],
    'linsen': ['lentil'],
    'tofu': ['tofu'],
    'apfel': ['apple'],
    'banane': ['banana'],
    'beere': ['berry'],
    'beeren': ['berry'],
    'erdbeere': ['strawberry'],
    'tomate': ['tomato'],
    'gurke': ['cucumber'],
    'paprika': ['pepper'],
    'brokkoli': ['broccoli'],
    'spinat': ['spinach'],
    'salat': ['lettuce', 'salad'],
    'karotte': ['carrot'],
    'avocado': ['avocado'],
    'nuss': ['nut'],
    'nuesse': ['nut'],
    'mandel': ['almond'],
    'schokolade': ['chocolate'],
    'wasser': ['water'],
  };

  static bool matches(FoodItem food, String query) {
    final normalizedQuery = normalize(query);
    if (normalizedQuery.isEmpty) return true;
    final haystack = normalize(
      [food.name, food.brand ?? '', food.source, ...food.dietTags].join(' '),
    );
    if (haystack.contains(normalizedQuery)) return true;
    return normalizedQuery
        .split(' ')
        .where((term) => term.isNotEmpty)
        .every(
          (term) =>
              haystack.contains(term) ||
              (_aliases[term]?.any(haystack.contains) ?? false),
        );
  }

  static String? germanHint(FoodItem food) {
    final haystack = normalize(food.name);
    for (final entry in _aliases.entries) {
      if (entry.value.any(haystack.contains)) {
        return _displayGermanTerm(entry.key);
      }
    }
    return null;
  }

  static String sourceLabel(FoodItem food) => switch (food.source) {
    'usda_fndds' || 'usda_foundation' => 'USDA-Lebensmitteldaten',
    'curated' => 'LIVO-Katalog',
    _ => 'Katalogquelle: ${food.source}',
  };

  static String normalize(String value) => value
      .toLowerCase()
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('ß', 'ss')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();

  static String _displayGermanTerm(String term) => switch (term) {
    'haehnchen' || 'huhn' => 'Hähnchen',
    'pute' || 'truthahn' => 'Pute',
    'rind' => 'Rind',
    'schwein' => 'Schwein',
    'fisch' => 'Fisch',
    'ei' || 'eier' => 'Ei',
    'kaese' => 'Käse',
    'susskartoffel' => 'Süßkartoffel',
    'nuesse' => 'Nüsse',
    _ => term.isEmpty ? term : '${term[0].toUpperCase()}${term.substring(1)}',
  };
}

enum FoodCatalogFilter { all, recent, saved, highProtein, light }
