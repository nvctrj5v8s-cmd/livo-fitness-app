-- LIVO recipe depth: detailed cooking guidance for everyone plus
-- Premium-only extras.
--
-- * recipes: prep/cook minutes, equipment and per-step titles and timers.
--   Step texts stay in `instructions`, so the existing halal RLS policy keeps
--   checking them.
-- * recipe_ingredients: household measure ("1 EL") and preparation note.
-- * recipe_premium_details: step tips, common mistakes, substitutions, meal
--   prep, variations and a serving tip. RLS returns rows only to accounts
--   with an active Premium entitlement (paid or trial), so free accounts
--   cannot read the extras through the API either.
-- * Halal guard fix: "Beeren" (berries) was blocked as a "beer" compound.
--
-- Recipe catalog content only: no personal, health or payment data.

alter table public.recipes
  add column if not exists prep_minutes integer
    check (prep_minutes is null or prep_minutes >= 0);
alter table public.recipes
  add column if not exists cook_minutes integer
    check (cook_minutes is null or cook_minutes >= 0);
alter table public.recipes
  add column if not exists equipment text[] not null default '{}';
alter table public.recipes
  add column if not exists step_titles text[] not null default '{}';
alter table public.recipes
  add column if not exists step_minutes integer[] not null default '{}';

alter table public.recipe_ingredients add column if not exists measure text;
alter table public.recipe_ingredients add column if not exists note text;

create table if not exists public.recipe_premium_details (
  recipe_id uuid primary key references public.recipes(id) on delete cascade,
  step_tips text[] not null default '{}',
  common_mistakes text[] not null default '{}',
  substitutions text[] not null default '{}',
  meal_prep text not null default '',
  variations text[] not null default '{}',
  serving_tip text not null default '',
  updated_at timestamptz not null default timezone('utc', now())
);

comment on table public.recipe_premium_details is
  'Premium-only cooking extras per recipe. Catalog content, no user data.';

alter table public.recipe_premium_details enable row level security;

drop policy if exists "Premium members read recipe extras"
  on public.recipe_premium_details;
create policy "Premium members read recipe extras"
  on public.recipe_premium_details for select
  using (
    exists (
      select 1 from public.entitlements e
      where e.user_id = auth.uid()
        and e.plan = 'premium'
        and e.status in ('active', 'trialing')
        and (e.expires_at is null or e.expires_at > now())
    )
    -- Evaluated with the caller's RLS, so hidden recipes stay hidden.
    and exists (select 1 from public.recipes r where r.id = recipe_id)
  );

revoke all on table public.recipe_premium_details from anon;
revoke insert, update, delete, truncate
  on table public.recipe_premium_details from authenticated;
grant select on table public.recipe_premium_details to authenticated;

-- Same rule as 0007, except that words starting with "beere" (Beere, Beeren,
-- Beerenmix) no longer count as "beer".
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
    '(^| )(pork|pig|swine|schwein[[:alnum:]]*|bacon[[:alnum:]]*|ham|prosciutto[[:alnum:]]*|salami[[:alnum:]]*|pepperoni[[:alnum:]]*|lard|speck|gelatin[[:alnum:]]*|blood|blut|alcohol[[:alnum:]]*|alkohol[[:alnum:]]*|ethanol[[:alnum:]]*|beer(?!e)[[:alnum:]]*|bier|wine|wein|rotwein|weisswein|redwine|whitewine|whisky[[:alnum:]]*|whiskey[[:alnum:]]*|vodka[[:alnum:]]*|rum|gin|brandy[[:alnum:]]*|cognac[[:alnum:]]*|champagne[[:alnum:]]*|schnapps[[:alnum:]]*|liqueur[[:alnum:]]*|liquor[[:alnum:]]*|likör|sherry|sake|cider|mead)( |$)';
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
  if normalized ~ land_animal_pattern and normalized !~ halal_marker_pattern then
    return false;
  end if;
  return true;
end;
$$;

-- Recipe rows: also check the new step titles and equipment. The whole
-- recipe text counts, so a halal marker in the title covers the steps.
create or replace function public.reject_non_halal_catalog_recipe()
returns trigger
language plpgsql
as $$
begin
  if not public.livo_halal_text_allowed(
    concat_ws(
      ' ',
      new.title,
      new.description,
      array_to_string(new.tags, ' '),
      array_to_string(new.instructions, ' '),
      array_to_string(new.step_titles, ' '),
      array_to_string(new.equipment, ' ')
    )
  ) then
    return null;
  end if;
  return new;
end;
$$;

drop trigger if exists reject_non_halal_catalog_recipe on public.recipes;
create trigger reject_non_halal_catalog_recipe
before insert or update of title, description, tags, instructions, step_titles, equipment
on public.recipes
for each row execute procedure public.reject_non_halal_catalog_recipe();

-- Ingredient notes and measures are free text as well.
create or replace function public.reject_non_halal_recipe_ingredient_text()
returns trigger
language plpgsql
as $$
begin
  if not public.livo_halal_text_allowed(concat_ws(' ', new.measure, new.note)) then
    return null;
  end if;
  return new;
end;
$$;

drop trigger if exists reject_non_halal_recipe_ingredient_text
  on public.recipe_ingredients;
create trigger reject_non_halal_recipe_ingredient_text
before insert or update of measure, note
on public.recipe_ingredients
for each row execute procedure public.reject_non_halal_recipe_ingredient_text();

-- Premium extras must follow the same rule. The recipe title is included so
-- a clearly halal-labelled meat recipe may mention its meat in the tips.
create or replace function public.reject_non_halal_recipe_premium_details()
returns trigger
language plpgsql
as $$
declare
  recipe_title text;
begin
  select r.title into recipe_title from public.recipes r where r.id = new.recipe_id;
  if not public.livo_halal_text_allowed(
    concat_ws(
      ' ',
      recipe_title,
      array_to_string(new.step_tips, ' '),
      array_to_string(new.common_mistakes, ' '),
      array_to_string(new.substitutions, ' '),
      new.meal_prep,
      array_to_string(new.variations, ' '),
      new.serving_tip
    )
  ) then
    return null;
  end if;
  new.updated_at := timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists reject_non_halal_recipe_premium_details
  on public.recipe_premium_details;
create trigger reject_non_halal_recipe_premium_details
before insert or update
on public.recipe_premium_details
for each row execute procedure public.reject_non_halal_recipe_premium_details();
