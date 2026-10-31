import { deleteRevenueCatCustomer } from './revenuecat_deletion.ts'

function assert(value: unknown, message = 'assertion failed'): asserts value {
  if (!value) throw new Error(message)
}

function fake(...statuses: number[]) {
  const calls: { url: string; method: string | undefined; auth: string | null }[] = []
  const fetcher: typeof fetch = async (input, init) => {
    calls.push({ url: String(input), method: init?.method,
      auth: new Headers(init?.headers).get('Authorization') })
    return new Response(null, { status: statuses.shift() ?? 500 })
  }
  return { calls, fetcher }
}
const noWait = () => Promise.resolve()

Deno.test('does not report queued deletion as completed', async () => {
  const f = fake(200, 200, 200)
  assert(await deleteRevenueCatCustomer('user', 'secret', f.fetcher, noWait) === 'pending')
  assert(f.calls.length === 3)
})

Deno.test('confirms the deletion only after 404 or a missing customer', async () => {
  const f = fake(200, 404)
  assert(await deleteRevenueCatCustomer('a/b', 'secret', f.fetcher, noWait) === 'confirmed')
  assert(f.calls.length === 2 && f.calls[0].url.endsWith('/a%2Fb'))
  assert(f.calls.every((call) => call.method === 'DELETE' && call.auth === 'Bearer secret'))
  const missing = fake(404)
  assert(await deleteRevenueCatCustomer('user', 'secret', missing.fetcher, noWait) === 'confirmed')
})

Deno.test('fails closed for missing credentials, API failures and timeouts', async () => {
  const f = fake(401)
  assert(await deleteRevenueCatCustomer('user', undefined, f.fetcher, noWait) === 'unavailable')
  assert(f.calls.length === 0)
  assert(await deleteRevenueCatCustomer('user', 'wrong', f.fetcher, noWait) === 'unavailable')
  const throwing: typeof fetch = () => Promise.reject(new Error('timeout'))
  assert(await deleteRevenueCatCustomer('user', 'secret', throwing, noWait) === 'unavailable')
})
