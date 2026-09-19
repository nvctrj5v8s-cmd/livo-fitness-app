-- LIVO foundation schema.
-- Run this file in the Supabase SQL Editor or through Supabase migrations.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  avatar_url text,
  goal text not null default 'Fett verlieren',
  target_weight numeric(5, 1),
  calorie_goal integer,
  protein_goal integer,
  nutrition_style text not null default 'Ausgewogen',
  allergies text not null default '',
  activity_level text not null default 'Moderat aktiv',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.entitlements (
  user_id uuid primary key references auth.users(id) on delete cascade,
  plan text not null default 'free' check (plan in ('free', 'premium')),
  status text not null default 'active' check (status in ('active', 'trialing', 'canceled', 'expired')),
  expires_at timestamptz,
  provider text,
  provider_customer_id text,
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.foods (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  brand text,
  barcode text,
  serving_grams numeric(8, 2) not null default 100,
  calories numeric(8, 2) not null default 0,
  protein numeric(8, 2) not null default 0,
  carbohydrates numeric(8, 2) not null default 0,
  fat numeric(8, 2) not null default 0,
  fiber numeric(8, 2) not null default 0,
  sugar numeric(8, 2) not null default 0,
  salt numeric(8, 2) not null default 0,
  allergens text[] not null default '{}',
  diet_tags text[] not null default '{}',
  image_url text,
  source text not null default 'curated',
  source_url text,
  source_license text,
  source_attribution text,
  data_quality text not null default 'unreviewed' check (data_quality in ('unreviewed', 'imported', 'reviewed')),
  verified_at timestamptz,
  is_premium boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists foods_name_search_idx on public.foods using gin (to_tsvector('simple', name));
create index if not exists foods_barcode_idx on public.foods (barcode) where barcode is not null;
create index if not exists foods_premium_idx on public.foods (is_premium);

create table if not exists public.recipes (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  description text not null default '',
  preparation_minutes integer not null default 15,
  difficulty text not null default 'Einfach',
  servings integer not null default 1,
  tags text[] not null default '{}',
  image_url text,
  instructions text[] not null default '{}',
  source text not null default 'curated',
  source_url text,
  source_license text,
  source_attribution text,
  access_level text not null default 'free' check (access_level in ('free', 'premium')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists recipes_title_search_idx on public.recipes using gin (to_tsvector('simple', title));
create index if not exists recipes_access_level_idx on public.recipes (access_level);

create table if not exists public.recipe_ingredients (
  recipe_id uuid not null references public.recipes(id) on delete cascade,
  food_id uuid not null references public.foods(id) on delete restrict,
  amount_grams numeric(8, 2) not null check (amount_grams > 0),
  position integer not null default 0,
  primary key (recipe_id, food_id)
);

create table if not exists public.meals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  meal_date date not null default current_date,
  meal_type text not null check (meal_type in ('breakfast', 'lunch', 'dinner', 'snack')),
  note text,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists meals_user_date_idx on public.meals (user_id, meal_date desc);

create table if not exists public.meal_items (
  id uuid primary key default gen_random_uuid(),
  meal_id uuid not null references public.meals(id) on delete cascade,
  food_id uuid not null references public.foods(id) on delete restrict,
  amount_grams numeric(8, 2) not null check (amount_grams > 0),
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.favorites (
  user_id uuid not null references auth.users(id) on delete cascade,
  recipe_id uuid not null references public.recipes(id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  primary key (user_id, recipe_id)
);

alter table public.profiles enable row level security;
alter table public.entitlements enable row level security;
alter table public.foods enable row level security;
alter table public.recipes enable row level security;
alter table public.recipe_ingredients enable row level security;
alter table public.meals enable row level security;
alter table public.meal_items enable row level security;
alter table public.favorites enable row level security;

create policy "Public can read free foods"
  on public.foods for select
  using (
    not is_premium
    or exists (
      select 1 from public.entitlements e
      where e.user_id = auth.uid()
        and e.plan = 'premium'
        and e.status in ('active', 'trialing')
        and (e.expires_at is null or e.expires_at > now())
    )
  );

create policy "Public can read free recipes"
  on public.recipes for select
  using (
    access_level = 'free'
    or exists (
      select 1 from public.entitlements e
      where e.user_id = auth.uid()
        and e.plan = 'premium'
        and e.status in ('active', 'trialing')
        and (e.expires_at is null or e.expires_at > now())
    )
  );

create policy "Recipe ingredients follow recipe access"
  on public.recipe_ingredients for select
  using (
    exists (
      select 1 from public.recipes r
      where r.id = recipe_id
        and (
          r.access_level = 'free'
          or exists (
            select 1 from public.entitlements e
            where e.user_id = auth.uid()
              and e.plan = 'premium'
              and e.status in ('active', 'trialing')
              and (e.expires_at is null or e.expires_at > now())
          )
        )
    )
  );

create policy "Users can read their profile"
  on public.profiles for select using (auth.uid() = user_id);
create policy "Users can create their profile"
  on public.profiles for insert with check (auth.uid() = user_id);
create policy "Users can update their profile"
  on public.profiles for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Users can read their entitlement"
  on public.entitlements for select using (auth.uid() = user_id);

create policy "Users can manage their meals"
  on public.meals for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users can manage meal items"
  on public.meal_items for all using (
    exists (select 1 from public.meals m where m.id = meal_id and m.user_id = auth.uid())
  ) with check (
    exists (select 1 from public.meals m where m.id = meal_id and m.user_id = auth.uid())
  );
create policy "Users can manage favorites"
  on public.favorites for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (user_id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', ''))
  on conflict (user_id) do nothing;
  insert into public.entitlements (user_id)
  values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
