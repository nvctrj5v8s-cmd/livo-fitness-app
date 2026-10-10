import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/consent.dart';

/// Replaceable boundary for consent decisions.
abstract interface class ConsentRepository {
  /// Latest known decision per kind; missing kinds are undecided.
  Future<Map<ConsentKind, bool>> load();

  /// Stores one decision and returns whether the server copy (the proof)
  /// was written. Must not throw; the local copy is enough for the app to
  /// respect the decision.
  Future<bool> record(ConsentKind kind, bool granted, {String? context});
}

/// Demo mode and tests: decisions live only in memory.
final class MemoryConsentRepository implements ConsentRepository {
  MemoryConsentRepository([Map<ConsentKind, bool>? initial])
    : _decisions = {...?initial};

  final Map<ConsentKind, bool> _decisions;
  final records = <(ConsentKind, bool, String?)>[];

  @override
  Future<Map<ConsentKind, bool>> load() async => {..._decisions};

  @override
  Future<bool> record(ConsentKind kind, bool granted, {String? context}) async {
    _decisions[kind] = granted;
    records.add((kind, granted, context));
    return true;
  }
}

/// Keeps a copy on the device (so the app works offline and before
/// migration 0017 is applied) and writes an append-only record to
/// `public.user_consents` as proof of the decision.
final class SupabaseConsentRepository implements ConsentRepository {
  SupabaseConsentRepository({required this.userId, SupabaseClient? client})
    : _providedClient = client;

  final String userId;
  final SupabaseClient? _providedClient;

  SupabaseClient get _client => _providedClient ?? Supabase.instance.client;

  String _key(ConsentKind kind) =>
      'lookin.consent.v1.${kind.wire}.${Uri.encodeComponent(userId)}';

  @override
  Future<Map<ConsentKind, bool>> load() async {
    final result = <ConsentKind, bool>{};
    final preferences = SharedPreferencesAsync();
    for (final kind in ConsentKind.values) {
      final local = await preferences.getBool(_key(kind));
      if (local != null) result[kind] = local;
    }
    try {
      final rows = await _client
          .from('user_consents')
          .select('kind,granted,created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      final seen = <String>{};
      for (final row in rows) {
        final wire = row['kind'];
        final granted = row['granted'];
        if (wire is! String || granted is! bool || !seen.add(wire)) continue;
        for (final kind in ConsentKind.values) {
          if (kind.wire == wire) {
            result[kind] = granted;
            await preferences.setBool(_key(kind), granted);
          }
        }
      }
    } catch (error) {
      // Offline or table not created yet: the device copy decides.
      debugPrint('Consent load from server failed: ${error.runtimeType}');
    }
    return result;
  }

  @override
  Future<bool> record(ConsentKind kind, bool granted, {String? context}) async {
    await SharedPreferencesAsync().setBool(_key(kind), granted);
    try {
      await _client.from('user_consents').insert({
        'user_id': userId,
        'kind': kind.wire,
        'granted': granted,
        'text_version': ConsentTexts.version,
        'context': ?context,
      });
      return true;
    } catch (error) {
      debugPrint('Consent record on server failed: ${error.runtimeType}');
      return false;
    }
  }
}
