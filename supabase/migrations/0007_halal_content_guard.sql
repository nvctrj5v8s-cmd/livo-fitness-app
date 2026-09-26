-- LIVO halal-sensitive catalog guard.
-- Existing disallowed content is hidden from app users, while new catalog rows
-- that fail this conservative rule are skipped during imports.

create or replace function public.livo_halal_text_allowed(p_value text)
returns boolean
language plpgsql
immutable
as $$
declare
  normalized text := lower(
    trim(regexp_replace(coalesce(p_value, ''), '[^[:alnum:]]+', ' ', 'g'))
  );
  hard_forbidden_pattern constant text :=
    '(^| )(pork|pig|swine|schwein[[:alnum:]]*|bacon[[:alnum:]]*|ham|prosciutto[[:alnum:]]*|salami[[:alnum:]]*|pepperoni[[:alnum:]]*|lard|speck|gelatin[[:alnum:]]*|blood|blut|alcohol[[:alnum:]]*|alkohol[[:alnum:]]*|ethanol[[:alnum:]]*|beer[[:alnum:]]*|bier|wine|wein|rotwein|weisswein|redwine|whitewine|whisky[[:alnum:]]*|whiskey[[:alnum:]]*|vodka[[:alnum:]]*|rum|gin|brandy[[:alnum:]]*|cognac[[:alnum:]]*|champagne[[:alnum:]]*|schnapps[[:alnum:]]*|liqueur[[:alnum:]]*|liquor[[:alnum:]]*|likör|sherry|sake|cider|mead)( |$)';
  land_animal_pattern constant text :=
    '(^| )(meat[[:alnum:]]*|fleisch[[:alnum:]]*|chicken[[:alnum:]]*|huhn|hähnchen[[:alnum:]]*|haehnchen[[:alnum:]]*|hen|poultry|turkey[[:alnum:]]*|pute[[:alnum:]]*|truthahn|beef[[:alnum:]]*|rind[[:alnum:]]*|veal[[:alnum:]]*|kalb[[:alnum:]]*|lamb[[:alnum:]]*|lamm[[:alnum:]]*|mutton|goat|ziege|duck[[:alnum:]]*|ente[[:alnum:]]*|venison|wurst|sausage[[:alnum:]]*)( |$)';
  halal_marker_pattern constant text :=
    '(^| )(halal|zabiha|dhabiha)( |$)';
begin
  if normalized = '' then
    return true;
  end if;
  if normalized ~ hard_forbidden_pattern then
    return false;
  end if;
  -- Fish, vegetarian and vegan foods are unaffected. Land-animal meat must
  -- carry an explicit halal marker in the imported product text or tags.
  if normalized ~ land_animal_pattern and normalized !~ halal_marker_pattern then
    return false;
  end if;
  return true;
end;
$$;

create or replace function public.livo_halal_food_allowed(
  p_name text,
  p_brand text,
  p_ingredients_text text,
  p_tags text[]
)
returns boolean
language sql
immutable
as $$
  select public.livo_halal_text_allowed(
    concat_ws(' ', p_name, p_brand, p_ingredients_text, array_to_string(p_tags, ' '))
  );
$$;

create or replace function public.livo_halal_recipe_allowed(
  p_title text,
  p_description text,
  p_tags text[],
  p_instructions text[]
)
returns boolean
language sql
immutable
as $$
  select public.livo_halal_text_allowed(
    concat_ws(' ', p_title, p_description, array_to_string(p_tags, ' '), array_to_string(p_instructions, ' '))
  );
$$;

create or replace function public.reject_non_halal_catalog_food()
returns trigger
language plpgsql
as $$
begin
  if not public.livo_halal_food_allowed(
    new.name, new.brand, new.ingredients_text, new.diet_tags
  ) then
    -- Returning null skips this individual row, including during bulk imports.
    return null;
  end if;
  return new;
end;
$$;

drop trigger if exists reject_non_halal_catalog_food on public.foods;
create trigger reject_non_halal_catalog_food
before insert or update of name, brand, ingredients_text, diet_tags
on public.foods
for each row execute procedure public.reject_non_halal_catalog_food();

create or replace function public.reject_non_halal_catalog_recipe()
returns trigger
language plpgsql
as $$
begin
  if not public.livo_halal_recipe_allowed(
    new.title, new.description, new.tags, new.instructions
  ) then
    return null;
  end if;
  return new;
end;
$$;

drop trigger if exists reject_non_halal_catalog_recipe on public.recipes;
create trigger reject_non_halal_catalog_recipe
before insert or update of title, description, tags, instructions
on public.recipes
for each row execute procedure public.reject_non_halal_catalog_recipe();

-- Restrictive policies are combined with the existing RLS policies. This makes
-- historical disallowed catalog rows invisible to app users without touching
-- personal diary history.
drop policy if exists "Halal-safe foods only" on public.foods;
create policy "Halal-safe foods only"
  on public.foods as restrictive for select
  using (
    public.livo_halal_food_allowed(name, brand, ingredients_text, diet_tags)
  );

drop policy if exists "Halal-safe recipes only" on public.recipes;
create policy "Halal-safe recipes only"
  on public.recipes as restrictive for select
  using (
    public.livo_halal_recipe_allowed(title, description, tags, instructions)
  );
