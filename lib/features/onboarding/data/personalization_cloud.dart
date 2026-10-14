import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/personalization_profile.dart';

/// The copy of the personal set-up answers that lives in the account.
///
/// It exists so a new phone, a reinstall or another browser does not ask
/// every question again. The app only writes it after the health-data consent
/// and deletes it when that consent is withdrawn. Every method fails quietly:
/// the device copy always works on its own.
abstract interface class PersonalizationCloud {
  /// The stored answers, or `null` when there are none (or no connection).
  Future<PersonalizationProfile?> load();

  /// Returns whether the answers were stored.
  Future<bool> save(PersonalizationProfile profile);

  Future<void> delete();
}

/// Demo mode and tests: nothing leaves the device.
final class NoPersonalizationCloud implements PersonalizationCloud {
  const NoPersonalizationCloud();

  @override
  Future<PersonalizationProfile?> load() async => null;

  @override
  Future<bool> save(PersonalizationProfile profile) async => false;

  @override
  Future<void> delete() async {}
}

/// Stored in `public.personalization_answers` (migration 0022). Row level
/// security limits it to the signed-in account.
final class SupabasePersonalizationCloud implements PersonalizationCloud {
  SupabasePersonalizationCloud({SupabaseClient? client})
    : _providedClient = client;

  final SupabaseClient? _providedClient;

  SupabaseClient get _client => _providedClient ?? Supabase.instance.client;

  String? get _userId {
    try {
      return _client.auth.currentUser?.id;
    } catch (_) {
      // Supabase is not initialised (demo mode, tests).
      return null;
    }
  }

  @override
  Future<PersonalizationProfile?> load() async {
    final userId = _userId;
    if (userId == null) return null;
    try {
      final row = await _client
          .from('personalization_answers')
          .select('answers')
          .eq('user_id', userId)
          .maybeSingle();
      final answers = row?['answers'];
      if (answers is! Map<String, dynamic> || answers['version'] != 1) {
        return null;
      }
      if (answers['deferred'] == true) return null;
      return PersonalizationProfile.fromJson(answers);
    } catch (_) {
      // No connection, or migration 0022 not applied yet.
      return null;
    }
  }

  @override
  Future<bool> save(PersonalizationProfile profile) async {
    final userId = _userId;
    if (userId == null) return false;
    try {
      await _client.from('personalization_answers').upsert({
        'user_id': userId,
        'answers': profile.toJson(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id');
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> delete() async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await _client
          .from('personalization_answers')
          .delete()
          .eq('user_id', userId);
    } catch (_) {
      // Retried the next time the consent is withdrawn.
    }
  }
}
