/// Local recipe photos. Sources and licences: `assets/ASSET_SOURCES.md`.
abstract final class RecipeImages {
  static const _folder = 'assets/images/recipes';

  /// Slugs with a bundled photo in [_folder]. Keep in sync with the folder.
  static const _slugsWithPhoto = <String>{
    'livo-apfel-zimt-porridge',
    'livo-arme-ritter',
    'livo-bananen-hafer-pfannkuchen',
    'livo-bratkartoffeln-spiegelei',
    'livo-chili-sin-carne',
    'livo-gefuellte-paprika-tomaten',
    'livo-halal-haehnchen-paprika-reis',
    'livo-joghurt-gurken-dip',
    'livo-kartoffel-moehren-eintopf',
    'livo-kartoffel-tortilla',
    'livo-kartoffelpuffer-apfelmus',
    'livo-kichererbsen-curry',
    'livo-knusper-kichererbsen',
    'livo-milchreis-zimt',
    'livo-mujaddara',
    'livo-nudeln-tomatensauce',
    'livo-ofenkartoffeln-moehren',
    'livo-ofenlachs-kartoffeln',
    'livo-pellkartoffeln-kraeuterquark',
    'livo-pfannkuchen',
    'livo-rote-linsen-dal',
    'livo-ruehrei-vollkornbrot',
    'livo-spinat-feta-nudelauflauf',
    'livo-thunfisch-bohnen-salat',
    'livo-thunfisch-nudelsalat',
    'livo-avocado-egg-bowl',
    'livo-egg-avocado-breakfast',
    'livo-protein-oats',
    'livo-rice-egg-bowl',
    'livo-salmon-avocado-rice',
    'livo-salmon-tomato-bowl',
    'livo-skyr-berry-bowl',
    'livo-skyr-oat-cup',
    'livo-tomato-rice-pan',
    'livo-vegetable-egg-pan',
  };

  static String forSlug(String? slug) {
    final normalized = slug?.toLowerCase().trim() ?? '';
    if (_slugsWithPhoto.contains(normalized)) {
      return '$_folder/$normalized.webp';
    }
    if (normalized.contains('salmon') || normalized.contains('lachs')) {
      return 'assets/images/salmon_bowl.webp';
    }
    if (normalized.contains('pasta')) return 'assets/images/protein_pasta.webp';
    return 'assets/images/berry_oats.webp';
  }

  static Set<String> get slugsWithPhoto => _slugsWithPhoto;

  static bool hasPhoto(String? slug) =>
      _slugsWithPhoto.contains(slug?.toLowerCase().trim() ?? '');
}
