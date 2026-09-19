import 'package:supabase_flutter/supabase_flutter.dart';

/// Reads and writes the signed-in user's nutrition profile.
///
/// The publishable client key is sufficient here because the `profiles` table
/// is protected by the user-owned Row Level Security policies.
class SupabaseProfileRepository {
  SupabaseProfileRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>?> loadCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('profiles')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
    return row;
  }

  Future<void> saveCurrentProfile(
    Map<String, dynamic> values, {
    String? expectedUserId,
  }) async {
    final user = _client.auth.currentUser;
    if (expectedUserId != null && user?.id != expectedUserId) {
      throw StateError('Bitte erneut anmelden.');
    }
    if (user == null) return;
    await _client.from('profiles').upsert({
      'user_id': user.id,
      ...values,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
