import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { germanDateTime, ownerEmail, sendMail, withdrawalPolicyText } from '../_shared/mail.ts'

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
  if (event.type === 'INITIAL_PURCHASE' && data === 'applied') {
    await sendPurchaseConfirmation(client, decision.userId, event)
  }
  return json({ result: data })
})

// Contract confirmation on a durable medium (§ 312f Abs. 2 BGB): plan, price,
// renewal and cancellation, the customer's request to start immediately and
// the withdrawal policy. Failures are logged only; the purchase stays valid.
// deno-lint-ignore no-explicit-any
async function sendPurchaseConfirmation(client: any, userId: string, event: StoreEvent) {
  try {
    const { data: userData } = await client.auth.admin.getUserById(userId)
    const to = userData?.user?.email
    if (!to) return
    const yearly = (event.product_id ?? '').includes('yearly')
    const plan = yearly ? 'Lookin Premium – Jahresabo' : 'Lookin Premium – Monatsabo'
    const price = typeof event.price_in_purchased_currency === 'number' && event.currency
      ? `${event.price_in_purchased_currency.toFixed(2).replace('.', ',')} ${event.currency}`
      : (yearly ? '49,99 EUR' : '6,99 EUR')
    const purchasedAt = germanDateTime(new Date(Number(event.purchased_at_ms) || Date.now()))
    const { data: consents } = await client
      .from('user_consents')
      .select('granted, created_at')
      .eq('user_id', userId)
      .eq('kind', 'immediate_start')
      .order('created_at', { ascending: false })
      .limit(1)
    const consent = Array.isArray(consents) && consents[0]?.granted
      ? `Du hast am ${germanDateTime(new Date(consents[0].created_at))} ausdrücklich verlangt, dass Lookin Premium sofort, also vor Ablauf der Widerrufsfrist, beginnt, und bestätigt, dass dir bekannt ist: Bei einem Widerruf zahlst du einen anteiligen Betrag für die bis dahin erbrachte Leistung, und dein Widerrufsrecht erlischt bei vollständiger Vertragserfüllung.`
      : 'Zur Zustimmung zum sofortigen Beginn liegt uns keine Erklärung vor.'
    const renewal = yearly
      ? 'Laufzeit: 12 Monate ab Kaufdatum. Das Jahresabo verlängert sich nach dem ersten Jahr automatisch. Ab dann kannst du jederzeit kündigen. Wählst du in Google Play „Sofort kündigen“, endet Premium sofort und du bekommst den nicht genutzten Teil anteilig zurück. Geht das dort nicht, schreib an lookinsupport@gmail.com; wir beenden das Abo dann spätestens nach einem Monat und erstatten den Rest anteilig.'
      : 'Laufzeit: 1 Monat ab Kaufdatum. Das Abo verlängert sich jeweils um einen Monat, bis du es kündigst.'
    const result = await sendMail({
      to,
      subject: 'Deine Bestellung: Lookin Premium',
      text: `Vielen Dank für deinen Kauf!\n\nVertrag: ${plan}\nLeistung: KI-Foto-Erkennung und Lookin Coach (zusammen bis zu 50 Anfragen pro Tag) sowie alle Rezepte, zusätzlich zu den kostenlosen Funktionen.\nPreis: ${price} (inkl. gegebenenfalls anfallender Umsatzsteuer)\nKaufdatum: ${purchasedAt}\n` +
        `Anbieter: Mhd Khair Shikho, Am Grübchen 18, 56203 Höhr-Grenzhausen, ${ownerEmail}, +49 15510 338501\n\n` +
        `${renewal} Kündigen kannst du jederzeit zum Ende des Abrechnungszeitraums in den Abo-Einstellungen von Google Play oder per E-Mail an ${ownerEmail}.\n\n` +
        `${consent}\n\nEs gelten die gesetzlichen Mängelrechte für digitale Produkte. Allgemeine Geschäftsbedingungen: https://nvctrj5v8s-cmd.github.io/livo-fitness-app/legal/agb.html\n\n${withdrawalPolicyText}`,
    })
    console.log(`purchase confirmation: ${result}`)
  } catch (_) {
    console.error('purchase confirmation failed')
  }
}
