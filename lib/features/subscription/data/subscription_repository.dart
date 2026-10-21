import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entitlement.dart';

/// Replaceable boundary for Lookin Premium. Store billing (Apple, Google or
/// Stripe) is added behind this interface; widgets never talk to Supabase or a
/// store directly.
abstract interface class SubscriptionRepository {
  Future<Entitlement> loadEntitlement();
}

/// Demo mode without account: always free and no network access.
final class PreviewSubscriptionRepository implements SubscriptionRepository {
  const PreviewSubscriptionRepository();

  @override
  Future<Entitlement> loadEntitlement() async => const Entitlement.free();
}

/// Reads `public.entitlements` (own row via RLS). The server writes it from
/// the store webhook; the free trial is a store offer, not a server function.
final class SupabaseSubscriptionRepository implements SubscriptionRepository {
  SupabaseSubscriptionRepository({SupabaseClient? client})
    : _providedClient = client;

  final SupabaseClient? _providedClient;

  // Resolved lazily so constructing the repository never needs Supabase.
  SupabaseClient get _client => _providedClient ?? Supabase.instance.client;

  @override
  Future<Entitlement> loadEntitlement() async {
    final client = _client;
    final user = client.auth.currentUser;
    if (user == null) return const Entitlement.free();
    final row = await client
        .from('entitlements')
        .select('plan,status,expires_at,provider')
        .eq('user_id', user.id)
        .maybeSingle();
    return Entitlement.fromRow(row);
  }
}
