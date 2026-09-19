import 'package:supabase_flutter/supabase_flutter.dart';

/// Persists only the signed-in user's recipe IDs. Recipe data stays in the
/// shared catalog; this table therefore contains no duplicated nutrition data.
class SupabaseFavoritesRepository {
  SupabaseFavoritesRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Set<String>> loadCurrentUserFavorites() async {
    final user = _client.auth.currentUser;
    if (user == null) return const {};
    final rows = await _client
        .from('favorites')
        .select('recipe_id')
        .eq('user_id', user.id);
    return {
      for (final row in rows.whereType<Map>()) row['recipe_id'].toString(),
    };
  }

  Future<void> setFavorite({
    required String recipeId,
    required bool favorite,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    if (favorite) {
      await _client.from('favorites').upsert({
        'user_id': user.id,
        'recipe_id': recipeId,
      });
      return;
    }
    await _client
        .from('favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('recipe_id', recipeId);
  }
}
