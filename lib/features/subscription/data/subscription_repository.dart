import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entitlement.dart';

/// Replaceable boundary for Lookin Premium. Store billing (Apple, Google or
/// Stripe) will later be added behind this interface; widgets never talk to
/// Supabase or a store directly.
abstract interface class SubscriptionRepository {
  Future<Entitlement> loadEntitlement();

  /// Starts the free, server-controlled trial once per account.
  Future<TrialStartResult> startTrial();
}

/// Demo mode without account: always free, no trial and no network access.
final class PreviewSubscriptionRepository implements SubscriptionRepository {
  const PreviewSubscriptionRepository();

  @override
  Future<Entitlement> loadEntitlement() async => const Entitlement.free();

  @override
  Future<TrialStartResult> startTrial() async =>
      const TrialStartResult(TrialStartStatus.previewOnly);
}

/// Reads `public.entitlements` / `public.premium_trials` (own rows via RLS)
/// and calls the `start_premium_trial()` RPC from migration 0008 (7-day
/// trial since migration 0011).
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
    bool? trialUsed;
    try {
      final trial = await client
          .from('premium_trials')
          .select('user_id')
          .eq('user_id', user.id)
          .maybeSingle();
      trialUsed = trial != null;
    } on PostgrestException {
      // Migration 0008 is not applied yet; the RPC will say so honestly.
      trialUsed = null;
    }
    return Entitlement.fromRow(row, trialUsed: trialUsed);
  }

  @override
  Future<TrialStartResult> startTrial() async {
    final client = _client;
    if (client.auth.currentUser == null) {
      return const TrialStartResult(TrialStartStatus.signedOut);
    }
    try {
      final data = await client.rpc<dynamic>('start_premium_trial');
      return trialResultFromRpc(data);
    } on PostgrestException catch (error) {
      return TrialStartResult(trialStatusForError(error.code, error.message));
    }
  }
}

/// Maps the JSON returned by `start_premium_trial()`.
TrialStartResult trialResultFromRpc(Object? data) {
  final map = switch (data) {
    final Map<dynamic, dynamic> value => value,
    final List<dynamic> list when list.isNotEmpty && list.first is Map =>
      list.first as Map<dynamic, dynamic>,
    _ => const <dynamic, dynamic>{},
  };
  final expiresAt = DateTime.tryParse('${map['expires_at'] ?? ''}')?.toUtc();
  return switch (map['result']) {
    'started' when expiresAt != null => TrialStartResult(
      TrialStartStatus.started,
      entitlement: Entitlement.trial(endsAt: expiresAt),
    ),
    'already_premium' => const TrialStartResult(
      TrialStartStatus.alreadyPremium,
    ),
    'trial_used' => const TrialStartResult(TrialStartStatus.alreadyUsed),
    _ => const TrialStartResult(TrialStartStatus.unavailable),
  };
}

/// PostgREST reports a missing RPC as PGRST202 (Postgres: 42883).
TrialStartStatus trialStatusForError(String? code, String message) {
  if (code == 'PGRST202' ||
      code == '42883' ||
      code == '42P01' ||
      message.contains('start_premium_trial')) {
    return TrialStartStatus.notConfigured;
  }
  if (code == '28000' || message.contains('not_authenticated')) {
    return TrialStartStatus.signedOut;
  }
  return TrialStartStatus.unavailable;
}
