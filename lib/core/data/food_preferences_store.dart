import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_custom_food.dart';
import 'halal_content_policy.dart';

/// Device-local shortcuts for food discovery. They are never sent to a third
/// party. Custom food templates contain user-entered nutrition, never verified
/// catalogue records; they remain on this device and are isolated by account.
class FoodPreferencesStore {
  FoodPreferencesStore({this.userId});

  /// Null is reserved for the account-free preview. Never reuse its values
  /// for a signed-in account on the same device.
  final String? userId;
  static const _legacyFavoritesKey = 'livo_food_favorite_ids_v1';
  static const _legacyRecentKey = 'livo_recent_food_ids_v1';
  static const _maximumRecentItems = 18;

  String get _scope =>
      userId == null ? 'preview' : Uri.encodeComponent(userId!);
  String get _favoritesKey => 'livo.food.favorites.v2.$_scope';
  String get _recentKey => 'livo.food.recent.v2.$_scope';
  String get _customKey => 'lookin.food.custom.v1.$_scope';

  Future<FoodPreferences> load() async {
    final preferences = await SharedPreferences.getInstance();
    return FoodPreferences(
      favoriteIds:
          preferences.getStringList(_favoritesKey)?.toSet() ?? const {},
      recentIds: preferences.getStringList(_recentKey) ?? const [],
      customFoods: _readCustomFoods(preferences.getString(_customKey)),
    );
  }

  List<SavedCustomFood> _readCustomFoods(String? encoded) {
    if (encoded == null) return const [];
    try {
      final rows = jsonDecode(encoded);
      if (rows is! List) return const [];
      return rows.take(100).whereType<Map>().expand((row) {
        try {
          final value = SavedCustomFood.fromJson(
            Map<String, dynamic>.from(row),
          );
          return HalalContentPolicy.restrictionReason(value.name) == null
              ? [value]
              : <SavedCustomFood>[];
        } catch (_) {
          return <SavedCustomFood>[];
        }
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveCustomFoods(List<SavedCustomFood> foods) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _customKey,
      jsonEncode(foods.take(100).map((food) => food.toJson()).toList()),
    );
    if (!saved) throw StateError('Custom food templates could not be saved');
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

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_favoritesKey);
    await preferences.remove(_recentKey);
    await preferences.remove(_customKey);
  }

  /// Earlier versions stored shortcuts without an account ID. They cannot
  /// be attributed to one user and must not be shown to another account.
  static Future<void> clearUnscopedLegacyValues() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_legacyFavoritesKey);
    await preferences.remove(_legacyRecentKey);
  }
}

class FoodPreferences {
  const FoodPreferences({
    required this.favoriteIds,
    required this.recentIds,
    this.customFoods = const [],
  });

  final Set<String> favoriteIds;
  final List<String> recentIds;
  final List<SavedCustomFood> customFoods;
}
