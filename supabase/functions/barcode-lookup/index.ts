import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Content-Type': 'application/json; charset=utf-8',
}

const sourceUrl = 'https://world.openfoodfacts.org'
const sourceLicense = 'Open Database License (ODbL)'
const sourceAttribution = 'Open Food Facts contributors'

// Same lists and rules as lib/core/data/halal_content_policy.dart and
// supabase/migrations/0014_halal_terms_extended.sql; keep all three in sync.
const hardForbiddenTerms = [
  'pork', 'pig', 'swine', 'boar', 'schwein', 'schweine', 'wildschwein',
  'bacon', 'ham', 'prosciutto', 'salami', 'pepperoni', 'lard', 'lardo',
  'lardon', 'speck', 'spam', 'scrapple', 'chitterling', 'chitterlings',
  'mortadella', 'pancetta', 'guanciale', 'capicola', 'liverwurst',
  'schinken', 'schmalz', 'kassler', 'kasseler', 'eisbein', 'saumagen',
  'leberkaese', 'blutwurst', 'black pudding', 'eggs benedict',
  'egg benedict', 'blood', 'blut', 'gelatin',
  'gelatine', 'collagen', 'kollagen', 'aspic', 'aspik', 'suelze', 'gummy',
  'gummies', 'gummi', 'fruchtgummi', 'weingummi', 'marshmallow', 'jellybean',
  'jelly bean', 'jelly beans', 'jelly candy', 'jelly candies', 'jello',
  'jell o', 'panna cotta', 'alcohol', 'alkohol', 'ethanol', 'beer', 'bier',
  'radler', 'wine', 'wein', 'rotwein', 'weisswein', 'redwine', 'whitewine',
  'gluehwein', 'weinbrand', 'sekt', 'prosecco', 'champagne', 'vermouth',
  'wermut', 'sherry', 'sake', 'cider', 'hard seltzer', 'mead', 'whisky',
  'whiskey', 'bourbon', 'scotch', 'vodka', 'rum', 'rumtopf', 'rumkugel',
  'rumkugeln', 'gin', 'brandy', 'cognac', 'armagnac', 'calvados', 'grappa',
  'ouzo', 'raki', 'absinth', 'absinthe', 'pisco', 'mezcal', 'tequila',
  'kirschwasser', 'obstler', 'schnapps', 'schnaps', 'liqueur', 'liquor',
  'likoer', 'amaretto', 'kahlua', 'baileys', 'aperol', 'campari', 'daiquiri',
  'margarita', 'martini', 'mojito', 'mimosa', 'manhattan', 'negroni',
  'cosmopolitan', 'caipirinha', 'screwdriver', 'sangria', 'eggnog', 'punsch',
  'bowle', 'bloody mary', 'long island', 'pina colada', 'irish coffee',
  'white russian', 'black russian', 'mai tai', 'hot toddy', 'rum punch',
  'mint julep', 'tom collins', 'cuba libre', 'cocktail',
]
const landAnimalMeatTerms = [
  'meat', 'fleisch', 'chicken', 'huhn', 'haehnchen', 'hen', 'poultry',
  'turkey', 'pute', 'truthahn', 'beef', 'rind', 'veal', 'kalb', 'lamb',
  'lamm', 'mutton', 'goat', 'ziege', 'duck', 'ente', 'goose', 'gans',
  'gaense', 'quail', 'wachtel', 'pheasant', 'fasan', 'venison', 'deer',
  'elk', 'moose', 'hirsch', 'reh', 'bison', 'ostrich', 'rabbit', 'hare',
  'kaninchen', 'frog', 'froschschenkel', 'wurst', 'sausage', 'bratwurst',
  'knockwurst', 'knackwurst', 'bologna', 'frankfurter', 'frankfurters',
  'franks', 'hot dog', 'hot dogs', 'hotdog', 'chorizo', 'kielbasa',
  'andouille', 'pastrami', 'jerky', 'mett', 'steak', 'steaks', 'ribeye',
  'sirloin', 'tenderloin', 'porterhouse', 'brisket', 'rib', 'ribs',
  'sparerib', 'oxtail', 'ochsenschwanz', 'tongue', 'tripe', 'kutteln',
  'pansen', 'gizzard', 'sweetbread', 'giblet', 'offal', 'innereien', 'liver',
  'livers', 'leber', 'hamburger', 'cheeseburger', 'chiliburger', 'whopper',
  'big mac', 'salisbury', 'sloppy joe', 'pot roast', 'meatball', 'meatloaf',
  'frikadelle', 'bulette', 'buletten', 'hackfleisch', 'gehacktes',
  'kotelett', 'schnitzel', 'gulasch', 'goulash', 'bolognese', 'gyro',
  'gyros', 'doener', 'doner', 'kebab', 'kebap', 'shawarma', 'schawarma',
  'carne', 'carnitas', 'barbacoa', 'birria', 'pozole', 'menudo', 'tamale',
  'tamales', 'reuben', 'club sandwich', 'italian sandwich', 'cuban sandwich',
  'french dip', 'shepherd s pie', 'shepherds pie', 'wonton soup',
  'soup wonton', 'wonton dumpling', 'pot sticker', 'pot stickers',
  'barbecue sandwich', 'frito pie',
]
const halalMarkers = ['halal', 'zabiha', 'dhabiha']
// Words starting with these roots match ("schweinefleisch").
const prefixRoots = new Set([
  'schwein', 'bacon', 'prosciutto', 'salami', 'pepperoni', 'lardon',
  'mortadella', 'pancetta', 'chitterling', 'liverwurst', 'schinken',
  'schmalz', 'gelatin', 'gummi', 'gummy', 'fruchtgummi', 'marshmallow',
  'jellybean', 'alkohol', 'alcohol', 'ethanol', 'beer', 'whisky', 'whiskey',
  'bourbon', 'vodka', 'brandy', 'cognac', 'champagne', 'prosecco',
  'vermouth', 'tequila', 'schnapps', 'liqueur', 'liquor', 'amaretto',
  'daiquiri', 'margarita', 'martini', 'mojito', 'sangria', 'eggnog',
  'haehnchen', 'chicken', 'fleisch', 'meat', 'rind', 'beef', 'kalb', 'veal',
  'lamm', 'lamb', 'pute', 'turkey', 'ente', 'duck', 'sausage', 'bratwurst',
  'frankfurter', 'hotdog', 'chorizo', 'pastrami', 'kielbasa', 'hamburger',
  'cheeseburger', 'sparerib', 'gizzard', 'sweetbread', 'giblet', 'liver',
  'leber', 'kaninchen', 'frikadelle', 'hackfleisch', 'kotelett', 'schnitzel',
  'gulasch', 'goulash',
])
// Longer words ending with these roots match ("leberwurst").
const suffixRoots = new Set([
  'fleisch', 'wurst', 'schinken', 'schmalz', 'steak', 'schnitzel',
  'kotelett', 'gulasch', 'likoer',
])
// "Beeren" (berries) is not "beer".
const prefixExceptions: Record<string, string[]> = { beer: ['beere'] }
// Removed before any check: harmless foods containing a listed word.
const harmlessPhrases = [
  'blood orange', 'blood oranges', 'hamburger bun', 'hamburger buns',
  'hamburger roll', 'hamburger rolls', 'hot dog bun', 'hot dog buns',
  'hot dog roll', 'hot dog rolls', 'quail egg', 'quail eggs', 'goose egg',
  'goose eggs', 'duck egg', 'duck eggs', 'goat cheese', 'cheese goat',
  'goat milk', 'goats milk', 'goat s milk', 'milk goat', 'cod liver',
  'steak sauce', 'salmon steak', 'tuna steak', 'fish steak',
  'swordfish steak', 'halibut steak', 'cauliflower steak', 'sweet tamale',
  'tamale sweet', 'fruchtfleisch', 'kokosfleisch', 'butterschmalz',
  'lebertran', 'lachssteak', 'thunfischsteak', 'fischsteak',
  'blumenkohlsteak', 'tofusteak', 'sellerieschnitzel', 'tofuschnitzel',
  'fruit cocktail', 'cocktail sauce', 'shrimp cocktail', 'prawn cocktail',
  'juice cocktail', 'cocktail tomato', 'cocktail tomatoes',
  'meatless',
]

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }
  if (request.method !== 'POST') {
    return json({ error: 'Nur POST ist erlaubt.', code: 'method_not_allowed' }, 405)
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY')
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  const authorization = request.headers.get('Authorization')
  if (!supabaseUrl || !anonKey || !serviceRoleKey || !authorization) {
    return json({ error: 'Nicht angemeldet.', code: 'unauthorized' }, 401)
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
  })
  const { data: { user } } = await userClient.auth.getUser()
  if (!user) {
    return json({ error: 'Nicht angemeldet.', code: 'unauthorized' }, 401)
  }

  try {
    const body = await request.json()
    const barcode = normalizeBarcode(body?.barcode)
    if (!barcode) {
      return json({ error: 'Dieser Barcode ist ungültig.', code: 'invalid_barcode' })
    }

    const admin = createClient(supabaseUrl, serviceRoleKey)
    const { data: cached, error: cacheError } = await admin
      .from('foods')
      .select('*')
      .eq('barcode', barcode)
      .maybeSingle()
    if (cacheError) {
      console.error('barcode cache read failed', cacheError.code, cacheError.message)
    } else if (cached) {
      if (halalRestriction(catalogText(cached))) {
        return notHalal()
      }
      // Cache reads use the service role. Never let a barcode bypass the
      // premium food RLS policy that applies to normal catalog reads.
      if (cached.is_premium === true) {
        const { data: entitlement, error: entitlementError } = await userClient
          .from('entitlements')
          .select('plan,status,expires_at')
          .eq('user_id', user.id)
          .maybeSingle()
        if (entitlementError) {
          console.error('barcode entitlement read failed', entitlementError.code)
          return json({ error: 'Zugriff konnte nicht geprüft werden.', code: 'unavailable' }, 503)
        }
        const allowed = entitlement?.plan === 'premium' &&
          ['active', 'trialing'].includes(entitlement.status) &&
          (entitlement.expires_at == null ||
            new Date(entitlement.expires_at).getTime() > Date.now())
        if (!allowed) {
          return json({ error: 'Dieses Produkt gehört zu LIVO Premium.', code: 'premium_required' }, 403)
        }
      }
      return json({ food: cached, cache: 'catalog' })
    }

    // Only uncached lookups reach the external source and consume the quota.
    const { data: allowed, error: quotaError } = await admin.rpc(
      'consume_barcode_lookup_quota',
      { p_user_id: user.id },
    )
    if (quotaError) {
      // Product lookup must remain usable while the optional quota table is
      // temporarily unavailable. Open Food Facts still applies its own limit.
      console.error('barcode quota check failed', quotaError.code, quotaError.message)
    } else if (allowed !== true) {
      return json({
        error: 'Bitte kurz warten, bevor du den nächsten Barcode suchst.',
        code: 'rate_limited',
      })
    }

    const userAgent = Deno.env.get('OFF_USER_AGENT')
    if (!userAgent) {
      console.error('OFF_USER_AGENT secret is missing')
      return json({
        error: 'Die Barcode-Suche wird noch eingerichtet.',
        code: 'upstream_unavailable',
      })
    }

    const fields = [
      'code', 'product_name', 'product_name_de', 'brands', 'nutriments',
      'serving_size', 'quantity', 'allergens_tags', 'ingredients_text',
      'ingredients_text_de', 'nutrition_grades', 'nova_group', 'labels',
      'labels_tags',
    ].join(',')
    let response: Response
    try {
      response = await fetch(
        `${sourceUrl}/api/v3/product/${encodeURIComponent(barcode)}?fields=${encodeURIComponent(fields)}`,
        { headers: { 'User-Agent': userAgent, Accept: 'application/json' } },
      )
    } catch (error) {
      console.error('Open Food Facts request failed', error)
      return json({
        error: 'Die Produktdatenquelle ist gerade nicht erreichbar.',
        code: 'upstream_unavailable',
      })
    }
    if (response.status === 404) {
      return json({ error: 'Dieses Produkt wurde nicht gefunden.', code: 'not_found' })
    }
    if (!response.ok) {
      console.error('Open Food Facts response', response.status)
      return json({
        error: 'Die Produktdatenquelle ist gerade nicht erreichbar.',
        code: 'upstream_unavailable',
      })
    }

    const payload = await response.json()
    // API v3 uses `result.id` instead of the older `status: 1` flag.
    // Checking the old flag made every valid v3 product look "not found".
    if (!payload.product || payload.result?.id === 'product_not_found') {
      return json({ error: 'Dieses Produkt wurde nicht gefunden.', code: 'not_found' })
    }

    const product = payload.product
    const nutrients = product.nutriments ?? {}
    const productCode = normalizeBarcode(product.code) ?? barcode
    const row = {
      slug: `barcode-${productCode}`,
      name: text(product.product_name_de) ?? text(product.product_name) ?? `Produkt ${productCode}`,
      brand: text(product.brands),
      barcode: productCode,
      // Every selected nutrient field ends in `_100g`, so the calculation
      // basis must always be 100 g even when the package lists a serving size.
      serving_grams: 100,
      calories: nutrient(nutrients, 'energy-kcal_100g'),
      protein: nutrient(nutrients, 'proteins_100g'),
      carbohydrates: nutrient(nutrients, 'carbohydrates_100g'),
      fat: nutrient(nutrients, 'fat_100g'),
      fiber: nutrient(nutrients, 'fiber_100g'),
      sugar: nutrient(nutrients, 'sugars_100g'),
      salt: nutrient(nutrients, 'salt_100g'),
      saturated_fat: nutrient(nutrients, 'saturated-fat_100g'),
      allergens: textList(product.allergens_tags),
      diet_tags: textList(product.labels_tags),
      ingredients_text: text(product.ingredients_text_de) ?? text(product.ingredients_text),
      nutriscore_grade: grade(product.nutrition_grades),
      nova_group: novaGroup(product.nova_group),
      product_quantity: text(product.quantity),
      source: 'open_food_facts',
      source_url: sourceUrl,
      source_license: sourceLicense,
      source_attribution: sourceAttribution,
      data_quality: 'imported',
      verified_at: new Date().toISOString(),
      is_premium: false,
    }
    if (halalRestriction(catalogText(row, product.labels))) {
      return notHalal()
    }
    const { data: inserted, error: insertError } = await admin
      .from('foods')
      .upsert(row, { onConflict: 'barcode' })
      .select()
      .single()
    if (insertError) {
      // Showing a valid product must not fail only because the shared cache
      // could not be written. The Flutter client stores this entry as a
      // custom diary item when the id has this prefix.
      console.error('barcode cache write failed', insertError.code, insertError.message)
      return json({
        food: { id: `external-barcode-${productCode}`, ...row },
        cache: 'external_fallback',
      })
    }
    return json({ food: inserted, cache: 'open_food_facts' })
  } catch (error) {
    console.error('barcode-lookup failed', error)
    return json({
      error: 'Barcode konnte gerade nicht verarbeitet werden.',
      code: 'upstream_unavailable',
    })
  }
})

function normalizeBarcode(value: unknown): string | null {
  let code = String(value ?? '').replace(/\D/g, '')
  if (code.length >= 9 && code.length <= 12) code = code.padStart(13, '0')
  if (code.length <= 7) code = code.padStart(8, '0')
  return code.length >= 8 && code.length <= 14 ? code : null
}

function nutrient(values: Record<string, unknown>, key: string): number {
  const value = Number(values[key])
  return Number.isFinite(value) && value >= 0 ? value : 0
}

function servingGrams(value: unknown): number {
  const match = String(value ?? '').replace(',', '.').match(/\d+(?:\.\d+)?/)
  const parsed = match ? Number(match[0]) : 100
  return Number.isFinite(parsed) && parsed > 0 && parsed <= 5000 ? parsed : 100
}

function text(value: unknown): string | null {
  const result = typeof value === 'string' ? value.trim() : ''
  return result.length > 0 ? result.slice(0, 4000) : null
}

function textList(value: unknown): string[] {
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === 'string')
      .map((item) => item.trim()).filter(Boolean).slice(0, 32)
    : []
}

function catalogText(row: Record<string, unknown>, labels?: unknown): string {
  const tags = Array.isArray(row.diet_tags) ? row.diet_tags.join(' ') : ''
  return [row.name, row.brand, row.ingredients_text, tags, labels]
    .filter((value) => typeof value === 'string' && value.trim().length > 0)
    .join(' ')
}

function halalRestriction(value: string): string | null {
  const normalized = withoutHarmlessPhrases(normalizeForHalal(value))
  if (!normalized) return null
  if (hardForbiddenTerms.some((term) => containsTerm(normalized, term))) {
    return 'forbidden'
  }
  const hasLandAnimalMeat = landAnimalMeatTerms.some((term) =>
    containsTerm(normalized, term)
  )
  const explicitlyHalal = halalMarkers.some((term) => containsTerm(normalized, term))
  return hasLandAnimalMeat && !explicitlyHalal ? 'unverified_meat' : null
}

function normalizeForHalal(value: string): string {
  return value.toLowerCase()
    .replaceAll('ä', 'ae')
    .replaceAll('ö', 'oe')
    .replaceAll('ü', 'ue')
    .replaceAll('ß', 'ss')
    .replace(/[^a-z0-9]+/g, ' ')
    .trim()
}

function withoutHarmlessPhrases(normalized: string): string {
  let padded = ` ${normalized} `
  for (const phrase of harmlessPhrases) {
    // Repeat: adjacent matches share their separating space.
    while (padded.includes(` ${phrase} `)) {
      padded = padded.replaceAll(` ${phrase} `, ' ')
    }
  }
  return padded.trim()
}

// Phrases match as whole words; single words match exactly, or as prefix /
// suffix of a compound for the listed roots ("gin" never matches "ginger").
function containsTerm(normalizedValue: string, term: string): boolean {
  if (term.includes(' ')) return ` ${normalizedValue} `.includes(` ${term} `)
  const exceptions = prefixExceptions[term] ?? []
  const prefix = prefixRoots.has(term)
  const suffix = suffixRoots.has(term)
  return normalizedValue.split(' ').some((word) =>
    word === term ||
    (prefix && word.startsWith(term) &&
      !exceptions.some((exception) => word.startsWith(exception))) ||
    (suffix && word.length > term.length && word.endsWith(term))
  )
}

function notHalal(): Response {
  return json({
    error: 'Dieses Produkt entspricht nicht den Halal-Inhaltsregeln von LIVO.',
    code: 'not_halal',
  }, 422)
}

function grade(value: unknown): string | null {
  const result = text(value)?.toLowerCase()
  return result && /^[a-e]$/.test(result) ? result : null
}

function novaGroup(value: unknown): number | null {
  const result = Number(value)
  return Number.isInteger(result) && result >= 1 && result <= 4 ? result : null
}

function json(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: corsHeaders })
}
