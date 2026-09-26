-- Original LIVO starter recipes. Ingredients use the small seed catalog.
-- Run after 0001/0002 and seed.sql. No external recipe text or images.
begin;

insert into public.recipes
  (slug, title, description, preparation_minutes, difficulty, servings, tags,
   instructions, source, source_license, source_attribution, access_level)
values
  ('livo-protein-oats', 'Protein-Beeren-Oats', 'Cremiges Frühstück mit Skyr und Beeren.', 8, 'Einfach', 1,
   array['Frühstück', 'High Protein', 'Schnell'],
   array['Haferflocken mit Skyr verrühren.', 'Beeren darauf verteilen.', 'Kurz ziehen lassen und servieren.'],
   'livo_original', 'LIVO original', 'LIVO recipe team', 'free'),
  ('livo-vegetable-egg-pan', 'Gemüse-Ei-Pfanne', 'Warme Pfanne mit Ei und frischer Tomate.', 15, 'Einfach', 1,
   array['Abendessen', 'Vegetarisch', 'Schnell'],
   array['Tomate schneiden.', 'Tomate kurz anbraten.', 'Ei dazugeben und stocken lassen.'],
   'livo_original', 'LIVO original', 'LIVO recipe team', 'free'),
  ('livo-salmon-avocado-rice', 'Lachs-Avocado-Reis', 'Lachs mit Reis und Avocado.', 24, 'Mittel', 2,
   array['Abendessen', 'High Protein'],
   array['Reis vorbereiten.', 'Lachs vollständig garen.', 'Avocado schneiden und alles anrichten.'],
   'livo_original', 'LIVO original', 'LIVO recipe team', 'premium'),
  ('livo-avocado-egg-bowl', 'Avocado-Ei-Bowl', 'Einfache Bowl mit Ei und Avocado.', 12, 'Einfach', 1,
   array['Frühstück', 'Vegetarisch'],
   array['Ei garen und schneiden.', 'Avocado würfeln.', 'Beides mit Tomate in einer Bowl servieren.'],
   'livo_original', 'LIVO original', 'LIVO recipe team', 'free'),
  ('livo-tomato-rice-pan', 'Tomaten-Reis-Pfanne', 'Schnelle warme Mahlzeit mit Reis und Tomate.', 15, 'Einfach', 2,
   array['Mittagessen', 'Vegan', 'Budget'],
   array['Tomate schneiden.', 'Reis in einer Pfanne erwärmen.', 'Tomate unterheben und abschmecken.'],
   'livo_original', 'LIVO original', 'LIVO recipe team', 'free'),
  ('livo-skyr-berry-bowl', 'Skyr-Beeren-Bowl', 'Schneller proteinreicher Snack.', 5, 'Einfach', 1,
   array['Snack', 'High Protein', 'Schnell'],
   array['Skyr in eine Schüssel geben.', 'Beeren darüber verteilen.', 'Direkt servieren.'],
   'livo_original', 'LIVO original', 'LIVO recipe team', 'free'),
  ('livo-salmon-tomato-bowl', 'Lachs-Tomaten-Bowl', 'Lachs mit Reis und frischer Tomate.', 22, 'Mittel', 2,
   array['Abendessen', 'High Protein'],
   array['Reis vorbereiten.', 'Lachs vollständig garen.', 'Tomate schneiden und alles anrichten.'],
   'livo_original', 'LIVO original', 'LIVO recipe team', 'premium'),
  ('livo-egg-avocado-breakfast', 'Ei-Avocado-Frühstück', 'Schnelles Frühstück mit Ei und Avocado.', 10, 'Einfach', 1,
   array['Frühstück', 'Vegetarisch', 'Schnell'],
   array['Ei garen.', 'Avocado schneiden.', 'Zusammen mit Tomate servieren.'],
   'livo_original', 'LIVO original', 'LIVO recipe team', 'free'),
  ('livo-skyr-oat-cup', 'Skyr-Hafer-Cup', 'Haferflocken mit Skyr für den Morgen.', 7, 'Einfach', 1,
   array['Frühstück', 'High Protein'],
   array['Haferflocken und Skyr verrühren.', 'Kurz quellen lassen.', 'Beeren darübergeben.'],
   'livo_original', 'LIVO original', 'LIVO recipe team', 'free'),
  ('livo-rice-egg-bowl', 'Reis-Ei-Bowl', 'Warme Bowl mit Reis, Ei und Gemüse.', 14, 'Einfach', 1,
   array['Mittagessen', 'Vegetarisch'],
   array['Reis erwärmen.', 'Ei garen und schneiden.', 'Mit Tomate in einer Bowl kombinieren.'],
   'livo_original', 'LIVO original', 'LIVO recipe team', 'premium')
on conflict (slug) do update set
  title = excluded.title,
  description = excluded.description,
  preparation_minutes = excluded.preparation_minutes,
  difficulty = excluded.difficulty,
  servings = excluded.servings,
  tags = excluded.tags,
  instructions = excluded.instructions,
  source = excluded.source,
  source_license = excluded.source_license,
  source_attribution = excluded.source_attribution,
  access_level = excluded.access_level,
  updated_at = timezone('utc', now());

insert into public.recipe_ingredients (recipe_id, food_id, amount_grams, position)
select r.id, f.id, x.amount_grams, x.position
from (values
  ('livo-protein-oats', 'oats', 50::numeric, 1),
  ('livo-protein-oats', 'skyr', 200::numeric, 2),
  ('livo-protein-oats', 'berries', 100::numeric, 3),
  ('livo-vegetable-egg-pan', 'egg', 120::numeric, 1),
  ('livo-vegetable-egg-pan', 'tomato', 180::numeric, 2),
  ('livo-salmon-avocado-rice', 'salmon', 180::numeric, 1),
  ('livo-salmon-avocado-rice', 'rice', 180::numeric, 2),
  ('livo-salmon-avocado-rice', 'avocado', 70::numeric, 3),
  ('livo-avocado-egg-bowl', 'egg', 120::numeric, 1),
  ('livo-avocado-egg-bowl', 'avocado', 80::numeric, 2),
  ('livo-avocado-egg-bowl', 'tomato', 100::numeric, 3),
  ('livo-tomato-rice-pan', 'rice', 220::numeric, 1),
  ('livo-tomato-rice-pan', 'tomato', 200::numeric, 2),
  ('livo-skyr-berry-bowl', 'skyr', 250::numeric, 1),
  ('livo-skyr-berry-bowl', 'berries', 120::numeric, 2),
  ('livo-salmon-tomato-bowl', 'salmon', 180::numeric, 1),
  ('livo-salmon-tomato-bowl', 'rice', 180::numeric, 2),
  ('livo-salmon-tomato-bowl', 'tomato', 140::numeric, 3),
  ('livo-egg-avocado-breakfast', 'egg', 120::numeric, 1),
  ('livo-egg-avocado-breakfast', 'avocado', 80::numeric, 2),
  ('livo-egg-avocado-breakfast', 'tomato', 100::numeric, 3),
  ('livo-skyr-oat-cup', 'skyr', 200::numeric, 1),
  ('livo-skyr-oat-cup', 'oats', 45::numeric, 2),
  ('livo-skyr-oat-cup', 'berries', 80::numeric, 3),
  ('livo-rice-egg-bowl', 'rice', 180::numeric, 1),
  ('livo-rice-egg-bowl', 'egg', 120::numeric, 2),
  ('livo-rice-egg-bowl', 'tomato', 140::numeric, 3)
) as x(recipe_slug, food_slug, amount_grams, position)
join public.recipes r on r.slug = x.recipe_slug
join public.foods f on f.slug = x.food_slug
on conflict (recipe_id, food_id) do update set
  amount_grams = excluded.amount_grams,
  position = excluded.position;

commit;
