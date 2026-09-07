import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { barcode } = await request.json()
    const normalized = String(barcode ?? '').replace(/\D/g, '')
    if (normalized.length < 8 || normalized.length > 14) {
      return json({ error: 'Ungültiger Barcode.' }, 400)
    }

    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const { data: cached, error: cacheError } = await admin
      .from('foods')
      .select('*')
      .eq('barcode', normalized)
      .maybeSingle()
    if (cacheError) throw cacheError
    if (cached) return json({ food: cached, cached: true })

    const response = await fetch(
      `https://world.openfoodfacts.org/api/v2/product/${normalized}.json?fields=code,product_name,brands,nutriments,serving_size,allergens_tags,categories_tags`,
      { headers: { 'User-Agent': 'LIVO-Fitness/1.0 (contact@livo.app)' } },
    )
    if (!response.ok) return json({ error: 'Produktdienst nicht erreichbar.' }, 502)
    const payload = await response.json()
    if (payload.status !== 1 || !payload.product) {
      return json({ error: 'Produkt nicht gefunden.' }, 404)
    }

    const product = payload.product
    const nutrients = product.nutriments ?? {}
    const row = {
      slug: `barcode-${normalized}`,
      name: product.product_name || `Produkt ${normalized}`,
      brand: product.brands || null,
      barcode: normalized,
      serving_grams: 100,
      calories: Number(nutrients['energy-kcal_100g'] ?? 0),
      protein: Number(nutrients['proteins_100g'] ?? 0),
      carbohydrates: Number(nutrients['carbohydrates_100g'] ?? 0),
      fat: Number(nutrients['fat_100g'] ?? 0),
      fiber: Number(nutrients['fiber_100g'] ?? 0),
      sugar: Number(nutrients['sugars_100g'] ?? 0),
      salt: Number(nutrients['salt_100g'] ?? 0),
      allergens: product.allergens_tags ?? [],
      diet_tags: product.categories_tags ?? [],
      source: 'open_food_facts',
      is_premium: false,
    }
    const { data: inserted, error: insertError } = await admin
      .from('foods')
      .upsert(row, { onConflict: 'barcode' })
      .select()
      .single()
    if (insertError) throw insertError
    return json({ food: inserted, cached: false })
  } catch (error) {
    console.error(error)
    return json({ error: 'Barcode konnte nicht verarbeitet werden.' }, 500)
  }
})

function json(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}
