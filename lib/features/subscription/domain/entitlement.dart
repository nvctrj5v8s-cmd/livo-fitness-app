/// What the server granted in `public.entitlements`.
enum EntitlementKind { free, trial, subscription }

/// What the account may use at a given moment.
enum EntitlementAccess { free, trialing, premium }

/// Typed view of the `public.entitlements` row plus the trial marker.
///
/// Mirrors the RLS rule in `0001_livo_schema.sql`: a premium row with status
/// `active` or `trialing` grants access until `expires_at` has passed;
/// `canceled` and `expired` rows grant nothing.
class Entitlement {
  const Entitlement({required this.kind, this.expiresAt, this.trialUsed});

  const Entitlement.free({this.trialUsed})
    : kind = EntitlementKind.free,
      expiresAt = null;

  const Entitlement.trial({required DateTime endsAt})
    : kind = EntitlementKind.trial,
      expiresAt = endsAt,
      trialUsed = true;

  const Entitlement.subscription({this.expiresAt, this.trialUsed})
    : kind = EntitlementKind.subscription;

  /// Provider name written by `start_premium_trial()`.
  static const trialProvider = 'livo_trial';

  factory Entitlement.fromRow(Map<String, dynamic>? row, {bool? trialUsed}) {
    if (row == null) return Entitlement.free(trialUsed: trialUsed);
    final expiresAt = _parseDate(row['expires_at']);
    final usedTrial = row['provider'] == trialProvider ? true : trialUsed;
    if (row['plan'] != 'premium') return Entitlement.free(trialUsed: usedTrial);
    return switch (row['status']) {
      'trialing' => Entitlement(
        kind: EntitlementKind.trial,
        expiresAt: expiresAt,
        trialUsed: true,
      ),
      'active' => Entitlement(
        kind: EntitlementKind.subscription,
        expiresAt: expiresAt,
        trialUsed: usedTrial,
      ),
      _ => Entitlement.free(trialUsed: usedTrial),
    };
  }

  final EntitlementKind kind;

  /// End of the trial or current paid period; `null` means open-ended.
  final DateTime? expiresAt;

  /// Whether the free trial was already used. `null` = unknown, e.g. while
  /// migration 0008 is not applied; the server then decides.
  final bool? trialUsed;

  bool isExpiredAt(DateTime now) =>
      kind != EntitlementKind.free &&
      expiresAt != null &&
      !expiresAt!.isAfter(now);

  EntitlementAccess accessAt(DateTime now) {
    if (kind == EntitlementKind.free || isExpiredAt(now)) {
      return EntitlementAccess.free;
    }
    return kind == EntitlementKind.trial
        ? EntitlementAccess.trialing
        : EntitlementAccess.premium;
  }

  bool hasPremiumAt(DateTime now) => accessAt(now) != EntitlementAccess.free;

  /// A trial can be offered while the account has no premium and has not
  /// used it (or the app does not know yet).
  bool trialAvailableAt(DateTime now) =>
      !hasPremiumAt(now) && trialUsed != true;

  Duration? remainingAt(DateTime now) {
    if (!hasPremiumAt(now) || expiresAt == null) return null;
    return expiresAt!.difference(now);
  }

  Entitlement copyWith({bool? trialUsed}) => Entitlement(
    kind: kind,
    expiresAt: expiresAt,
    trialUsed: trialUsed ?? this.trialUsed,
  );

  static DateTime? _parseDate(Object? value) {
    if (value is DateTime) return value.toUtc();
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toUtc();
  }
}

enum TrialStartStatus {
  /// The trial runs now; [TrialStartResult.entitlement] holds its end.
  started,

  /// The account already has an active subscription or running trial.
  alreadyPremium,

  /// The trial was used before; it is available once per account.
  alreadyUsed,

  /// The server RPC is missing (migration 0008 not applied yet).
  notConfigured,

  /// No signed-in account.
  signedOut,

  /// Demo mode without account and without backend.
  previewOnly,

  /// Network or server problem; nothing changed.
  unavailable,
}

class TrialStartResult {
  const TrialStartResult(this.status, {this.entitlement});

  final TrialStartStatus status;
  final Entitlement? entitlement;
}
