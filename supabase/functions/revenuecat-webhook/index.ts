import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Receives RevenueCat webhooks and records the resulting premium state in
// public.entitlements. Only RevenueCat may call it: the request must carry the
// shared secret configured in the RevenueCat dashboard as the Authorization
// header. The service-role key stays inside this function.
//
// Secret (Supabase dashboard > Edge Functions > Secrets), never in the repo:
//   REVENUECAT_WEBHOOK_SECRET  any long random string, same value in RevenueCat
// SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are provided by Supabase.

const headers = {
  'Cache-Control': 'no-store',
  'Content-Type': 'application/json; charset=utf-8',
}
const uuidPattern =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers })
}

// Compares SHA-256 digests byte by byte so the comparison time does not
// reveal how many leading characters of the secret were right.
async function secretMatches(provided: string, expected: string): Promise<boolean> {
  const encoder = new TextEncoder()
  const [a, b] = await Promise.all([
    crypto.subtle.digest('SHA-256', encoder.encode(provided)),
    crypto.subtle.digest('SHA-256', encoder.encode(expected)),
  ])
  const left = new Uint8Array(a)
  const right = new Uint8Array(b)
  let difference = 0
  for (let i = 0; i < left.length; i++) difference |= left[i] ^ right[i]
  return difference === 0
}

type StoreEvent = {
  id?: string
  type?: string
  app_user_id?: string
  aliases?: string[]
  period_type?: string
  cancel_reason?: string
  expiration_at_ms?: number | null
  event_timestamp_ms?: number
  environment?: string
}

type Decision =
  | {
    action: 'apply'
    userId: string
    status: 'active' | 'trialing' | 'expired'
    expiresAt: Date
    eventAt: Date
  }
  | { action: 'ignore'; reason: string }

// Renewal-like events grant access until the store's expiry date. A
// cancellation only switches auto-renew off, so access continues until the
// EXPIRATION event; only a refund (support cancellation) ends it right away.
function decide(event: StoreEvent): Decision {
  const type = event.type ?? ''
  if (type === 'TEST') return { action: 'ignore', reason: 'test_event' }

  const candidates = [event.app_user_id, ...(event.aliases ?? [])]
  const userId = candidates.find((id) => typeof id === 'string' && uuidPattern.test(id))
  if (!userId) return { action: 'ignore', reason: 'no_account_id' }

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

Deno.serve(async (request) => {
  if (request.method !== 'POST') return json({ code: 'method_not_allowed' }, 405)

  const secret = Deno.env.get('REVENUECAT_WEBHOOK_SECRET')?.trim()
  const url = Deno.env.get('SUPABASE_URL')
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  if (!secret || !url || !serviceKey) {
    console.error('revenuecat-webhook configuration missing')
    return json({ code: 'unavailable' }, 503)
  }

  const provided = (request.headers.get('Authorization') ?? '')
    .replace(/^Bearer\s+/i, '')
    .trim()
  if (!provided || !(await secretMatches(provided, secret))) {
    return json({ code: 'unauthorized' }, 401)
  }

  let event: StoreEvent
  try {
    const body = await request.json()
    event = body?.event
    if (!event || typeof event !== 'object') throw new Error('no event')
  } catch (_) {
    return json({ code: 'bad_request' }, 400)
  }

  const decision = decide(event)
  if (decision.action === 'ignore') {
    console.log(`revenuecat-webhook ignored: ${decision.reason}`)
    return json({ result: 'ignored', reason: decision.reason })
  }

  const client = createClient(url, serviceKey, { auth: { persistSession: false } })
  const { data, error } = await client.rpc('apply_revenuecat_event', {
    p_user_id: decision.userId,
    p_status: decision.status,
    p_expires_at: decision.expiresAt.toISOString(),
    p_customer_id: decision.userId,
    p_event_at: decision.eventAt.toISOString(),
  })
  if (error) {
    // A 5xx makes RevenueCat retry the event later.
    console.error(`revenuecat-webhook database error: ${error.code ?? 'unknown'}`)
    return json({ code: 'database_error' }, 500)
  }
  console.log(`revenuecat-webhook ${event.type}: ${data}`)
  return json({ result: data })
})
