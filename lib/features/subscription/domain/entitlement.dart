/// What the server granted in `public.entitlements`.
enum EntitlementKind { free, trial, subscription }

/// What the account may use at a given moment.
enum EntitlementAccess { free, trialing, premium }

/// Typed view of the `public.entitlements` row.
///
/// Mirrors the RLS rule in `0001_livo_schema.sql`: a premium row with status
/// `active` or `trialing` grants access until `expires_at` has passed;
/// `canceled` and `expired` rows grant nothing. A trial is the free phase of
/// a store subscription (status `trialing`), started with a payment method.
class Entitlement {
  const Entitlement({required this.kind, this.expiresAt});

  const Entitlement.free() : kind = EntitlementKind.free, expiresAt = null;

  const Entitlement.subscription({this.expiresAt})
    : kind = EntitlementKind.subscription;

  factory Entitlement.fromRow(Map<String, dynamic>? row) {
    if (row == null || row['plan'] != 'premium') {
      return const Entitlement.free();
    }
    final expiresAt = _parseDate(row['expires_at']);
    return switch (row['status']) {
      'trialing' => Entitlement(
        kind: EntitlementKind.trial,
        expiresAt: expiresAt,
      ),
      'active' => Entitlement(
        kind: EntitlementKind.subscription,
        expiresAt: expiresAt,
      ),
      _ => const Entitlement.free(),
    };
  }

  final EntitlementKind kind;

  /// End of the trial or current paid period; `null` means open-ended.
  final DateTime? expiresAt;

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

  Duration? remainingAt(DateTime now) {
    if (!hasPremiumAt(now) || expiresAt == null) return null;
    return expiresAt!.difference(now);
  }

  static DateTime? _parseDate(Object? value) {
    if (value is DateTime) return value.toUtc();
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toUtc();
  }
}
