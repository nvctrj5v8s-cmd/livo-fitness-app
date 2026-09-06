-- Small development seed. The full licensed food import will be added later.
insert into public.foods (slug, name, calories, protein, carbohydrates, fat, fiber, diet_tags)
values
  ('oats', 'Haferflocken', 372, 13.5, 58.7, 7.0, 10.0, array['vegetarisch', 'vegan']),
  ('berries', 'Beeren-Mix', 50, 1.0, 8.0, 0.4, 4.0, array['vegetarisch', 'vegan']),
  ('skyr', 'Skyr natur', 63, 11.0, 4.0, 0.2, 0.0, array['vegetarisch']),
  ('chicken-breast', 'Hähnchenbrust', 165, 31.0, 0.0, 3.6, 0.0, array[]::text[]),
  ('salmon', 'Lachsfilet', 208, 20.0, 0.0, 13.0, 0.0, array[]::text[]),
  ('rice', 'Reis, gekocht', 130, 2.7, 28.0, 0.3, 0.4, array['vegetarisch', 'vegan']),
  ('wholegrain-pasta', 'Vollkornpasta, gekocht', 149, 5.8, 27.0, 1.3, 4.0, array['vegetarisch', 'vegan']),
  ('egg', 'Ei', 143, 12.6, 0.7, 9.5, 0.0, array['vegetarisch']),
  ('avocado', 'Avocado', 160, 2.0, 1.8, 14.7, 6.7, array['vegetarisch', 'vegan']),
  ('tomato', 'Tomate', 18, 0.9, 3.9, 0.2, 1.2, array['vegetarisch', 'vegan'])
on conflict (slug) do update set
  name = excluded.name,
  calories = excluded.calories,
  protein = excluded.protein,
  carbohydrates = excluded.carbohydrates,
  fat = excluded.fat,
  fiber = excluded.fiber,
  diet_tags = excluded.diet_tags,
  updated_at = timezone('utc', now());

insert into public.recipes (slug, title, description, preparation_minutes, servings, tags, access_level)
values
  ('berry-protein-oats', 'Protein-Beeren-Oats', 'Schnelles Frühstück mit Skyr und Beeren.', 8, 1, array['Schnell', 'High Protein'], 'free'),
  ('salmon-power-bowl', 'Lachs Power Bowl', 'Sättigende Bowl mit Reis, Lachs und Avocado.', 24, 2, array['High Protein'], 'premium'),
  ('vegetable-egg-pan', 'Gemüse-Ei-Pfanne', 'Warme Gemüsepfanne mit Ei.', 15, 1, array['Schnell', 'Vegetarisch'], 'free')
on conflict (slug) do update set
  title = excluded.title,
  description = excluded.description,
  preparation_minutes = excluded.preparation_minutes,
  servings = excluded.servings,
  tags = excluded.tags,
  access_level = excluded.access_level,
  updated_at = timezone('utc', now());

insert into public.recipe_ingredients (recipe_id, food_id, amount_grams, position)
select r.id, f.id, x.amount_grams, x.position
from (values
  ('berry-protein-oats', 'oats', 50::numeric, 1),
  ('berry-protein-oats', 'skyr', 200::numeric, 2),
  ('berry-protein-oats', 'berries', 100::numeric, 3),
  ('salmon-power-bowl', 'salmon', 180::numeric, 1),
  ('salmon-power-bowl', 'rice', 180::numeric, 2),
  ('salmon-power-bowl', 'avocado', 70::numeric, 3),
  ('vegetable-egg-pan', 'egg', 120::numeric, 1),
  ('vegetable-egg-pan', 'tomato', 180::numeric, 2)
) as x(recipe_slug, food_slug, amount_grams, position)
join public.recipes r on r.slug = x.recipe_slug
join public.foods f on f.slug = x.food_slug
on conflict (recipe_id, food_id) do update set
  amount_grams = excluded.amount_grams,
  position = excluded.position;
