import 'package:shared_preferences/shared_preferences.dart';

/// Device-local shortcuts for food discovery. They are never sent to a third
/// party and contain IDs only; nutrition records remain in the Supabase diary.
class FoodPreferencesStore {
  static const _favoritesKey = 'livo_food_favorite_ids_v1';
  static const _recentKey = 'livo_recent_food_ids_v1';
  static const _maximumRecentItems = 18;

  Future<FoodPreferences> load() async {
    final preferences = await SharedPreferences.getInstance();
    return FoodPreferences(
      favoriteIds:
          preferences.getStringList(_favoritesKey)?.toSet() ?? const {},
      recentIds: preferences.getStringList(_recentKey) ?? const [],
    );
  }

  Future<void> saveFavoriteIds(Set<String> ids) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_favoritesKey, ids.toList());
  }

  Future<void> saveRecentIds(List<String> ids) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _recentKey,
      ids.take(_maximumRecentItems).toList(),
    );
  }
}

class FoodPreferences {
  const FoodPreferences({required this.favoriteIds, required this.recentIds});

  final Set<String> favoriteIds;
  final List<String> recentIds;
}
