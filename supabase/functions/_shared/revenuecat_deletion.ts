export type RevenueCatDeletion = 'confirmed' | 'pending' | 'unavailable'

// 200 only queues deletion; a subsequent DELETE returning 404 confirms it.
// Never call the GET-or-create endpoint, which can recreate a deleted user.
export async function deleteRevenueCatCustomer(
  userId: string,
  secret: string | undefined,
  fetcher: typeof fetch = fetch,
  pause: (ms: number) => Promise<void> = (ms) => new Promise((r) => setTimeout(r, ms)),
): Promise<RevenueCatDeletion> {
  if (!userId || !secret?.trim()) return 'unavailable'
  const url = `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(userId)}`
  let queued = false
  for (let attempt = 0; attempt < 3; attempt++) {
    let response: Response
    try {
      response = await fetcher(url, {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${secret.trim()}` },
        signal: AbortSignal.timeout(5000),
      })
    } catch {
      return 'unavailable'
    }
    if (response.status === 404) return 'confirmed'
    if (response.status !== 200) return 'unavailable'
    queued = true
    if (attempt < 2) await pause(1000)
  }
  return queued ? 'pending' : 'unavailable'
}
