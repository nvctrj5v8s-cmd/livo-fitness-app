import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.117.0'
import { englishDateTime, germanDateTime, ownerEmail, sendMail, withdrawalPolicyText, withdrawalPolicyTextEn } from '../_shared/mail.ts'
import { decide, type StoreEvent } from '../_shared/revenuecat_events.ts'

// Receives RevenueCat webhooks and records the resulting premium state in
// public.entitlements. Only RevenueCat may call it: the request must carry the
// shared secret configured in the RevenueCat dashboard as the Authorization
// header. The service-role key stays inside this function.
//
// Secret (Supabase dashboard > Edge Functions > Secrets), never in the repo:
//   REVENUECAT_WEBHOOK_SECRET  any long random string, same value in RevenueCat
// SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are provided by Supabase.
//
// Test purchases (environment SANDBOX) only count while this secret is
// "true"; remove it before Lookin goes live:
//   ALLOW_SANDBOX_PURCHASES  true while testing with licence testers

const headers = {
  'Cache-Control': 'no-store',
  'Content-Type': 'application/json; charset=utf-8',
}
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

  const decision = decide(event, {
    allowSandbox: Deno.env.get('ALLOW_SANDBOX_PURCHASES')?.trim() === 'true',
  })
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

// Version of the terms that applies to new purchases. Change it together
// with the "Stand" line in web/legal/agb.html.
const termsVersion = '2026-10'

// Contract confirmation on a durable medium (§ 312f Abs. 2 BGB): plan, price,
// renewal and cancellation, the customer's request to start immediately and
// the withdrawal policy. Failures are logged only; the purchase stays valid.
// deno-lint-ignore no-explicit-any
async function sendPurchaseConfirmation(client: any, userId: string, event: StoreEvent) {
  try {
    const { data: userData } = await client.auth.admin.getUserById(userId)
    const to = userData?.user?.email
    if (!to) return
    const english = userData?.user?.user_metadata?.locale === 'en'
    const yearly = (event.product_id ?? '').includes('yearly')
    const plan = yearly ? 'Lookin Premium – Jahresabo' : 'Lookin Premium – Monatsabo'
    // A store trial is booked at 0: the confirmation names the price that follows.
    const trial = event.period_type === 'TRIAL'
    const price = typeof event.price_in_purchased_currency === 'number' && event.currency && !trial
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
      ? 'Laufzeit: zunächst 12 Monate ab Kaufdatum. Das Jahresabo läuft zunächst ein Jahr. Danach verlängert es sich automatisch auf unbestimmte Zeit, wenn du es nicht vorher kündigst; der Preis wird weiterhin jährlich im Voraus berechnet. Ab dann kannst du jederzeit mit einer Frist von höchstens einem Monat kündigen. Das gilt nur für diesen einen Fall, das Jahresabo nach dem ersten Jahr: Schreib dazu an lookinsupport@gmail.com; wir beenden das Abo dann spätestens nach einem Monat und erstatten den Rest anteilig. In allen anderen Fällen kündigst du selbst in Google Play.'
      : 'Laufzeit: 1 Monat ab Kaufdatum. Das Abo verlängert sich jeweils um einen Monat, bis du es kündigst.'
    const trialEnd = germanDateTime(new Date(Number(event.expiration_at_ms) || Date.now()))
    const trialNote = trial
      ? `\n\nTestphase: Dein Abo beginnt mit einer kostenlosen Testphase bis ${trialEnd}. Kündigst du nicht vorher in den Abo-Einstellungen von Google Play, beginnt danach das kostenpflichtige Abo zum oben genannten Preis.`
      : ''
    const trialNoteEn = trial
      ? `\n\nTrial: Your subscription starts with a free trial until ${englishDateTime(new Date(Number(event.expiration_at_ms) || Date.now()))}. Unless you cancel in the Google Play subscription settings before then, the paid subscription starts afterwards at the price above.`
      : ''
    const planEn = yearly ? 'Lookin Premium — yearly subscription' : 'Lookin Premium — monthly subscription'
    const priceEn = typeof event.price_in_purchased_currency === 'number' && event.currency && !trial
      ? `${event.price_in_purchased_currency.toFixed(2)} ${event.currency}`
      : (yearly ? '49.99 EUR' : '6.99 EUR')
    const renewalEn = yearly
      ? 'Term: initially 12 months from purchase. The yearly subscription initially runs for one year. It then renews automatically for an indefinite period unless cancelled beforehand; the price continues to be charged annually in advance. From then on, you may cancel at any time with no more than one month\'s notice. This applies only to this one case, a yearly subscription after its first year: email lookinsupport@gmail.com and we will end the subscription within one month and refund the remaining period proportionately. In all other cases you cancel yourself in Google Play.'
      : 'Term: 1 month from purchase. The subscription renews for one month at a time until cancelled.'
    const consentEn = Array.isArray(consents) && consents[0]?.granted
      ? `On ${englishDateTime(new Date(consents[0].created_at))}, you expressly requested that Lookin Premium begin immediately, before the withdrawal period ends, and acknowledged that withdrawal requires proportionate payment for the service already provided and that your right of withdrawal expires upon full performance of the contract.`
      : 'We have no declaration of consent to immediate service commencement.'
    const content = {
      to,
      subject: english ? 'Your order: Lookin Premium' : 'Deine Bestellung: Lookin Premium',
      text: english
        ? `Thank you for your purchase!\n\nContract: ${planEn}\nService: AI photo recognition and Lookin Coach (up to 100 requests per day combined), plus all recipes, in addition to the free features.\nPrice: ${priceEn} (including any applicable VAT)\nPurchased: ${englishDateTime(new Date(Number(event.purchased_at_ms) || Date.now()))}\n` +
          `Provider: Mhd Khair Shikho, Am Grübchen 18, 56203 Höhr-Grenzhausen, ${ownerEmail}, +49 15510 338501\n\n` +
          `${renewalEn}${trialNoteEn}\n\nYou may cancel at any time effective at the end of the billing period in the Google Play subscription settings.\n\n` +
          `${consentEn}\n\nStatutory rights concerning defects in digital products apply. Terms (version ${termsVersion}): https://app.lookin-foodtracker.de/legal/en/agb.html\n\n${withdrawalPolicyTextEn}`
        : `Vielen Dank für deinen Kauf!\n\nVertrag: ${plan}\nLeistung: KI-Foto-Erkennung und Lookin Coach (zusammen bis zu 100 Anfragen pro Tag) sowie alle Rezepte, zusätzlich zu den kostenlosen Funktionen.\nPreis: ${price} (inkl. gegebenenfalls anfallender Umsatzsteuer)\nKaufdatum: ${purchasedAt}\n` +
        `Anbieter: Mhd Khair Shikho, Am Grübchen 18, 56203 Höhr-Grenzhausen, ${ownerEmail}, +49 15510 338501\n\n` +
        `${renewal}${trialNote}\n\nKündigen kannst du jederzeit zum Ende des Abrechnungszeitraums in den Abo-Einstellungen von Google Play.\n\n` +
        `${consent}\n\nEs gelten die gesetzlichen Mängelrechte für digitale Produkte. Allgemeine Geschäftsbedingungen (Fassung ${termsVersion}): https://app.lookin-foodtracker.de/legal/agb.html\n\n${withdrawalPolicyText}`,
    }
    let result = await sendMail(content)
    if (result !== 'sent') {
      await new Promise((resolve) => setTimeout(resolve, 1500))
      result = await sendMail(content)
    }
    console.log(`purchase confirmation: ${result}`)
    if (result !== 'sent') {
      // The confirmation is required by law (§ 312f BGB): the owner sends it
      // by hand.
      await sendMail({
        to: ownerEmail,
        subject: 'Kaufbestätigung NICHT zugestellt – bitte manuell senden',
        text: `Die Kaufbestätigung an ${to} konnte nicht zugestellt werden (Konto-ID ${userId}, Produkt ${event.product_id ?? '–'}, Kauf ${purchasedAt}). Bitte die Bestätigung mit Tarif, Preis, Laufzeit, AGB-Fassung und Widerrufsbelehrung manuell senden.`,
      })
    }
  } catch (_) {
    console.error('purchase confirmation failed')
  }
}
