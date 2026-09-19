-- Read-only check for the LIVO Supabase setup.
-- Paste this into the Supabase SQL Editor and click Run.

select tablename, rowsecurity
from pg_tables
where schemaname = 'public'
  and tablename in (
    'profiles', 'entitlements', 'foods', 'recipes', 'recipe_ingredients',
    'meals', 'meal_items', 'favorites'
  )
order by tablename;

select source, count(*) as anzahl
from public.foods
group by source
order by source;

select count(*) as anzahl_rezepte
from public.recipes;

select tablename, policyname
from pg_policies
where schemaname = 'public'
  and tablename in (
    'profiles', 'entitlements', 'foods', 'recipes', 'recipe_ingredients',
    'meals', 'meal_items', 'favorites'
  )
order by tablename, policyname;
