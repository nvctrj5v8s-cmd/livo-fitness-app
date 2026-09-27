/// Local recipe photos. Sources and licences: `assets/ASSET_SOURCES.md`.
abstract final class RecipeImages {
  static const _folder = 'assets/images/recipes';

  /// Slugs with a bundled photo in [_folder]. Keep in sync with the folder.
  static const _slugsWithPhoto = <String>{
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
