import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Only an authenticated user may export or delete their own account.
// The service-role key stays in the Edge Function and is never sent to Flutter.
const headers = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Cache-Control': 'no-store',
  'Content-Type': 'application/json; charset=utf-8',
}
const pageSize = 200
const sections = {
  profiles: { table: 'profiles', order: 'user_id' },
  entitlements: { table: 'entitlements', order: 'user_id' },
  premium_trials: { table: 'premium_trials', order: 'user_id' },
  meals: { table: 'meals', order: 'id' },
  favorites: { table: 'favorites', order: 'recipe_id' },
  body_measurements: { table: 'body_measurements', order: 'id' },
  ai_chat_messages: { table: 'ai_chat_messages', order: 'id' },
  ai_chat_usage: { table: 'ai_chat_usage', order: 'usage_date' },
  barcode_lookup_limits: { table: 'barcode_lookup_limits', order: 'user_id' },
} as const
type Section = keyof typeof sections | 'auth' | 'meal_items'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers })
}

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers })
  }
  if (request.method !== 'POST') {
    return json({ code: 'method_not_allowed' }, 405)
  }

  const url = Deno.env.get('SUPABASE_URL')
  const publicKey = Deno.env.get('SUPABASE_ANON_KEY')
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  const authorization = request.headers.get('Authorization')
  const token = authorization?.startsWith('Bearer ')
    ? authorization.slice(7).trim()
    : null
  if (!url || !publicKey || !serviceKey) {
    console.error('account-data configuration missing')
    return json({ code: 'unavailable' }, 503)
  }
  if (!token) return json({ code: 'unauthorized' }, 401)

  // getUser(token) asks Auth to validate the caller. A user id in the body is
  // never accepted, even though the queries below use a privileged client.
  const authClient = createClient(url, publicKey)
  const { data: { user }, error: authError } = await authClient.auth.getUser(token)
  if (authError || !user) return json({ code: 'unauthorized' }, 401)

  let body: Record<string, unknown>
  try {
    const parsed = await request.json()
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
      return json({ code: 'invalid_request' }, 400)
    }
    body = parsed as Record<string, unknown>
  } catch (_) {
    return json({ code: 'invalid_request' }, 400)
  }

  const admin = createClient(url, serviceKey)
  if (body.action === 'delete') {
    if (body.confirmation !== 'DELETE' || typeof body.password !== 'string') {
      return json({ code: 'confirmation_required' }, 400)
    }
    // A stolen but still-valid access token alone must not delete an account.
    const email = user.email
    if (!email) return json({ code: 'reauth_unavailable' }, 409)
    const { data: verified, error: passwordError } =
      await authClient.auth.signInWithPassword({
        email,
        password: body.password,
      })
    if (passwordError || verified.user?.id !== user.id) {
      return json({ code: 'reauth_failed' }, 403)
    }
    const { error } = await admin.auth.admin.deleteUser(user.id)
    if (error) {
      console.error('account delete failed', error.status)
      return json({ code: 'delete_failed' }, 500)
    }
    return json({ deleted: true })
  }

  if (body.action !== 'export') {
    return json({ code: 'invalid_action' }, 400)
  }
  const section = body.section
  const page = body.page
  if (
    typeof section !== 'string' ||
    typeof page !== 'number' ||
    !Number.isInteger(page) ||
    page < 0 ||
    page > 100000
  ) {
    return json({ code: 'invalid_request' }, 400)
  }
  if (section === 'auth') {
    return json({
      rows: page === 0 ? [{
        id: user.id,
        email: user.email,
        created_at: user.created_at,
        updated_at: user.updated_at,
        user_metadata: user.user_metadata,
      }] : [],
      next_page: null,
    })
  }

  const start = page * pageSize
  let rows: Record<string, unknown>[]
  if (section === 'meal_items') {
    // The foreign-key join restricts items to meals owned by the caller.
    const { data, error } = await admin
      .from('meal_items')
      .select('id,meal_id,food_id,amount_grams,created_at,meals!inner(user_id)')
      .eq('meals.user_id', user.id)
      .order('id')
      .range(start, start + pageSize - 1)
    if (error) {
      console.error('account export failed', section, error.code)
      return json({ code: 'export_failed' }, 500)
    }
    rows = (data ?? []).map(({ meals: _owner, ...item }) => item)
  } else if (Object.hasOwn(sections, section)) {
    const definition = sections[section as keyof typeof sections]
    const { data, error } = await admin
      .from(definition.table)
      .select('*')
      .eq('user_id', user.id)
      .order(definition.order)
      .range(start, start + pageSize - 1)
    if (error) {
      console.error('account export failed', section, error.code)
      return json({ code: 'export_failed' }, 500)
    }
    rows = data ?? []
  } else {
    return json({ code: 'invalid_section' }, 400)
  }
  return json({
    rows,
    next_page: rows.length === pageSize ? page + 1 : null,
  })
})
