import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Developer accounts can switch premium on and off for testing. The server
/// decides who is a developer (migration 0018); the app only asks.
abstract interface class DeveloperRepository {
  Future<bool> isDeveloper();
  Future<void> setPremium(bool enabled);
}

/// Demo mode and tests: never a developer.
final class NoDeveloperRepository implements DeveloperRepository {
  const NoDeveloperRepository();

  @override
  Future<bool> isDeveloper() async => false;

  @override
  Future<void> setPremium(bool enabled) async =>
      throw StateError(L10n.current.subscriptionNotADeveloperAccount);
}

final class SupabaseDeveloperRepository implements DeveloperRepository {
  SupabaseDeveloperRepository({SupabaseClient? client})
    : _providedClient = client;

  final SupabaseClient? _providedClient;
  SupabaseClient get _client => _providedClient ?? Supabase.instance.client;

  @override
  Future<bool> isDeveloper() async {
    final result = await _client.rpc<dynamic>('is_developer');
    return result == true;
  }

  @override
  Future<void> setPremium(bool enabled) async {
    await _client.rpc<dynamic>(
      'developer_set_premium',
      params: {'p_enabled': enabled},
    );
  }
}
