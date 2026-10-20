// Checks how the RevenueCat webhook reads events. No network, no secrets.
//
//   deno run tool/check_revenuecat_events.ts
import {
  decide,
  type StoreEvent,
} from '../supabase/functions/_shared/revenuecat_events.ts'

const user = '3f2c1d9e-4b6a-4f0e-9a1b-7c8d9e0f1a2b'
const other = '0a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d'
const base: StoreEvent = {
  type: 'INITIAL_PURCHASE',
  app_user_id: user,
  product_id: 'lookin_premium_yearly:yearly',
  event_timestamp_ms: 1_800_000_000_000,
  expiration_at_ms: 1_800_000_300_000,
  environment: 'PRODUCTION',
}
const live = { allowSandbox: false }
const testing = { allowSandbox: true }

let failures = 0
function check(name: string, ok: boolean, detail = '') {
  if (!ok) failures++
  console.log(`${ok ? 'ok  ' : 'FAIL'} ${name}${ok ? '' : ` ${detail}`}`)
}
function reason(event: StoreEvent, options = live): string {
  const d = decide(event, options)
  return d.action === 'ignore' ? d.reason : `apply:${d.status}`
}

check('real purchase applies', reason(base) === 'apply:active')
check(
  'another product of the project never unlocks Premium',
  reason({ ...base, product_id: 'other_pro:monthly' }) === 'unknown_product',
)
check(
  'an event without a product is ignored',
  reason({ ...base, product_id: undefined }) === 'unknown_product',
)
check('renewal applies', reason({ ...base, type: 'RENEWAL' }) === 'apply:active')
check(
  'trial period is trialing',
  reason({ ...base, period_type: 'TRIAL' }) === 'apply:trialing',
)
check(
  'test purchase is ignored when live',
  reason({ ...base, environment: 'SANDBOX' }) === 'sandbox_not_allowed',
)
check(
  'test purchase counts while testing',
  reason({ ...base, environment: 'SANDBOX' }, testing) === 'apply:active',
)
check(
  'sandbox expiry is ignored when live too',
  reason({ ...base, environment: 'SANDBOX', type: 'EXPIRATION' }) ===
    'sandbox_not_allowed',
)
check('test event is ignored', reason({ ...base, type: 'TEST' }) === 'test_event')
check(
  'transfer changes nothing',
  reason({ ...base, type: 'TRANSFER' }) === 'unhandled_transfer',
)
check(
  'billing issue changes nothing',
  reason({ ...base, type: 'BILLING_ISSUE' }) === 'unhandled_billing_issue',
)
check(
  'cancellation keeps access until expiry',
  reason({ ...base, type: 'CANCELLATION', cancel_reason: 'UNSUBSCRIBE' }) ===
    'apply:active',
)
check(
  'refund ends access at once',
  reason({ ...base, type: 'CANCELLATION', cancel_reason: 'CUSTOMER_SUPPORT' }) ===
    'apply:expired',
)
const refund = decide(
  { ...base, type: 'CANCELLATION', cancel_reason: 'CUSTOMER_SUPPORT' },
  live,
)
check(
  'refund expires at the event time',
  refund.action === 'apply' &&
    refund.expiresAt.getTime() === base.event_timestamp_ms,
)
check(
  'expiration expires',
  reason({ ...base, type: 'EXPIRATION' }) === 'apply:expired',
)
check(
  'no account id (anonymous) is ignored',
  reason({ ...base, app_user_id: '$RCAnonymousID:abc' }) === 'no_account_id',
)
check(
  'not a uuid is ignored',
  reason({ ...base, app_user_id: 'someone@example.com' }) === 'no_account_id',
)
check(
  'a uuid alias is used when the id is anonymous',
  (() => {
    const d = decide(
      { ...base, app_user_id: '$RCAnonymousID:abc', aliases: ['x', other] },
      live,
    )
    return d.action === 'apply' && d.userId === other
  })(),
)
check(
  'the app user id wins over aliases',
  (() => {
    const d = decide({ ...base, aliases: [other] }, live)
    return d.action === 'apply' && d.userId === user
  })(),
)
check(
  'purchase without expiry is ignored',
  reason({ ...base, expiration_at_ms: null }) === 'no_expiry',
)
check(
  'event without time is ignored',
  reason({ ...base, event_timestamp_ms: undefined }) === 'no_event_time',
)

if (failures > 0) {
  console.error(`${failures} check(s) failed`)
  Deno.exit(1)
}
console.log('All RevenueCat event checks passed.')
