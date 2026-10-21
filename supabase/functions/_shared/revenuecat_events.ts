// Decides what a RevenueCat webhook event means for Lookin Premium. Pure
// functions, no network: tool/check_revenuecat_events.ts tests them.

export type StoreEvent = {
  product_id?: string
  price_in_purchased_currency?: number | null
  currency?: string | null
  purchased_at_ms?: number | null
  id?: string
  type?: string
  app_user_id?: string
  aliases?: string[]
  period_type?: string
  cancel_reason?: string
  expiration_at_ms?: number | null
  event_timestamp_ms?: number
  environment?: string
  /// PLAY_STORE or APP_STORE (RevenueCat event field).
  store?: string
}

export type Decision =
  | {
    action: 'apply'
    userId: string
    status: 'active' | 'trialing' | 'expired'
    expiresAt: Date
    eventAt: Date
  }
  | { action: 'ignore'; reason: string }

const uuidPattern =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

export type DecideOptions = {
  /// Test purchases (Google licence testers, Apple sandbox and TestFlight,
  /// App Review, RevenueCat Test Store) arrive
  /// with environment SANDBOX. They only count while this is on, so nobody
  /// can unlock Premium with a test purchase once Lookin is live.
  allowSandbox: boolean
}

// Renewal-like events grant access until the store's expiry date. A
// cancellation only switches auto-renew off, so access continues until the
// EXPIRATION event; only a refund (support cancellation) ends it right away.
//
// TRANSFER (a store purchase moved to another Lookin account) is ignored on
// purpose: it must never happen. In RevenueCat the project setting "Restore
// behavior" is "Keep with original App User ID", so a purchase stays with the
// account that bought it. See docs/BILLING_SETUP.md.
export function decide(event: StoreEvent, options: DecideOptions): Decision {
  const type = event.type ?? ''
  if (type === 'TEST') return { action: 'ignore', reason: 'test_event' }
  if (event.environment === 'SANDBOX' && !options.allowSandbox) {
    return { action: 'ignore', reason: 'sandbox_not_allowed' }
  }

  const candidates = [event.app_user_id, ...(event.aliases ?? [])]
  const userId = candidates.find((id) => typeof id === 'string' && uuidPattern.test(id))
  if (!userId) return { action: 'ignore', reason: 'no_account_id' }

  // Only the Lookin Premium products count; any other product of the
  // RevenueCat project must never unlock Premium.
  if (typeof event.product_id !== 'string' || !event.product_id.startsWith('lookin_premium_')) {
    return { action: 'ignore', reason: 'unknown_product' }
  }

  const eventMs = Number(event.event_timestamp_ms)
  if (!Number.isFinite(eventMs) || eventMs <= 0) {
    return { action: 'ignore', reason: 'no_event_time' }
  }
  const eventAt = new Date(eventMs)
  const expiryMs = Number(event.expiration_at_ms)
  const hasExpiry = Number.isFinite(expiryMs) && expiryMs > 0
  const periodStatus = event.period_type === 'TRIAL' ? 'trialing' : 'active'

  switch (type) {
    case 'INITIAL_PURCHASE':
    case 'RENEWAL':
    case 'PRODUCT_CHANGE':
    case 'UNCANCELLATION':
    case 'SUBSCRIPTION_EXTENDED':
    case 'NON_RENEWING_PURCHASE':
      if (!hasExpiry) return { action: 'ignore', reason: 'no_expiry' }
      return {
        action: 'apply',
        userId,
        status: periodStatus,
        expiresAt: new Date(expiryMs),
        eventAt,
      }
    case 'CANCELLATION':
      if (event.cancel_reason === 'CUSTOMER_SUPPORT') {
        return { action: 'apply', userId, status: 'expired', expiresAt: eventAt, eventAt }
      }
      if (!hasExpiry) return { action: 'ignore', reason: 'no_expiry' }
      return {
        action: 'apply',
        userId,
        status: periodStatus,
        expiresAt: new Date(expiryMs),
        eventAt,
      }
    case 'EXPIRATION':
      return {
        action: 'apply',
        userId,
        status: 'expired',
        expiresAt: hasExpiry ? new Date(expiryMs) : eventAt,
        eventAt,
      }
    default:
      // BILLING_ISSUE, SUBSCRIPTION_PAUSED, TRANSFER and others change no
      // access by themselves; the following RENEWAL or EXPIRATION does.
      return { action: 'ignore', reason: `unhandled_${type.toLowerCase() || 'type'}` }
  }
}
