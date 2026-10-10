import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { germanDateTime, ownerEmail, sendMail } from '../_shared/mail.ts'

// Withdrawal function for the premium contract (§ 356a BGB). Only a signed-in
// user can withdraw, and only for their own account. The request is stored
// first; e-mails are a second step, so a missing mail setup never loses a
// withdrawal. The service-role key stays inside this function.
const headers = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Cache-Control': 'no-store',
  'Content-Type': 'application/json; charset=utf-8',
}
const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers })
}

function field(value: unknown, max: number): string | null {
  if (typeof value !== 'string') return null
  const clean = value.replace(/[\u0000-\u001F\u007F]+/g, ' ').replace(/\s{2,}/g, ' ').trim()
  return clean && clean.length <= max ? clean : null
}

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers })
  if (request.method !== 'POST') return json({ code: 'method_not_allowed' }, 405)

  const url = Deno.env.get('SUPABASE_URL')
  const publicKey = Deno.env.get('SUPABASE_ANON_KEY')
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  if (!url || !publicKey || !serviceKey) {
    console.error('legal-actions configuration missing')
    return json({ code: 'unavailable' }, 503)
  }
  const authorization = request.headers.get('Authorization')
  const token = authorization?.startsWith('Bearer ') ? authorization.slice(7).trim() : null
  if (!token) return json({ code: 'unauthorized' }, 401)
  const authClient = createClient(url, publicKey)
  const { data: { user }, error: authError } = await authClient.auth.getUser(token)
  if (authError || !user) return json({ code: 'unauthorized' }, 401)

  let body: Record<string, unknown>
  try {
    const parsed = await request.json()
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) throw new Error()
    body = parsed as Record<string, unknown>
  } catch (_) {
    return json({ code: 'bad_request' }, 400)
  }
  if (body.action !== 'withdraw') return json({ code: 'unknown_action' }, 400)

  const name = field(body.name, 120)
  const email = field(body.email, 254)
  const note = body.note == null || body.note === '' ? null : field(body.note, 300)
  if (!name) return json({ code: 'invalid_name' }, 400)
  if (!email || !emailPattern.test(email)) return json({ code: 'invalid_email' }, 400)
  if (body.note != null && body.note !== '' && note == null) {
    return json({ code: 'invalid_note' }, 400)
  }

  const admin = createClient(url, serviceKey, { auth: { persistSession: false } })
  const { data: row, error: insertError } = await admin
    .from('withdrawal_requests')
    .insert({ user_id: user.id, name, email, contract_note: note })
    .select('id, created_at')
    .single()
  if (insertError || !row) {
    console.error(`withdrawal insert failed: ${insertError?.code ?? 'unknown'}`)
    return json({ code: 'unavailable' }, 503)
  }

  const receivedAt = new Date(row.created_at as string)
  const when = germanDateTime(receivedAt)
  const details = [
    `Name: ${name}`,
    `E-Mail: ${email}`,
    `Konto: ${user.email ?? user.id}`,
    note ? `Hinweis: ${note}` : null,
    `Eingang: ${when}`,
    `Vorgangsnummer: ${row.id}`,
  ].filter(Boolean).join('\n')

  const userMail = await sendMail({
    to: email,
    subject: 'Eingangsbestätigung deines Widerrufs – Lookin Premium',
    text: `Hallo ${name},\n\nwir haben deinen Widerruf des Vertrags über Lookin Premium erhalten.\n\n${details}\n\n` +
      'Wir erstatten dir alle Zahlungen nach den Regeln der Widerrufsbelehrung, spätestens binnen vierzehn Tagen. ' +
      'Bei einem Kauf über Google Play erfolgt die Rückzahlung über Google Play.\n\n' +
      `Bei Fragen erreichst du uns unter ${ownerEmail}.\n\nMhd Khair Shikho\nAm Grübchen 18, 56203 Höhr-Grenzhausen`,
  })
  const ownerMail = await sendMail({
    to: ownerEmail,
    subject: `Neuer Widerruf: ${name}`,
    text: `Ein Widerruf ist eingegangen. Bitte die Zahlung in der Play Console erstatten und das Abo beenden.\n\n${details}`,
    replyTo: email,
  })
  await admin
    .from('withdrawal_requests')
    .update({
      user_confirmation_sent: userMail === 'sent',
      owner_notification_sent: ownerMail === 'sent',
    })
    .eq('id', row.id)

  return json({
    id: row.id,
    received_at: receivedAt.toISOString(),
    confirmation_email: userMail,
  })
})
