-- Barcode products are shared catalog data, never private diary data.
-- Run after 0001 and 0002, before deploying barcode-lookup.

alter table public.foods add column if not exists ingredients_text text;
alter table public.foods add column if not exists nutriscore_grade text;
alter table public.foods add column if not exists nova_group integer;
alter table public.foods add column if not exists product_quantity text;
alter table public.foods add column if not exists saturated_fat numeric(8, 2) not null default 0;

alter table public.foods drop constraint if exists foods_nutriscore_grade_check;
alter table public.foods add constraint foods_nutriscore_grade_check
  check (nutriscore_grade is null or nutriscore_grade in ('a', 'b', 'c', 'd', 'e'));
alter table public.foods drop constraint if exists foods_nova_group_check;
alter table public.foods add constraint foods_nova_group_check
  check (nova_group is null or nova_group between 1 and 4);

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.foods'::regclass
      and conname = 'foods_barcode_unique'
  ) then
    alter table public.foods add constraint foods_barcode_unique unique (barcode);
  end if;
end;
$$;

create table if not exists public.barcode_lookup_limits (
  user_id uuid primary key references auth.users(id) on delete cascade,
  window_started_at timestamptz not null default timezone('utc', now()),
  request_count integer not null default 0 check (request_count >= 0),
  updated_at timestamptz not null default timezone('utc', now())
);

alter table public.barcode_lookup_limits enable row level security;

-- Only the server-side function may use this table. It allows at most twelve
-- external product requests per account in a one-minute window.
create or replace function public.consume_barcode_lookup_quota(p_user_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  limit_row public.barcode_lookup_limits%rowtype;
  current_time timestamptz := timezone('utc', now());
begin
  if p_user_id is null then
    return false;
  end if;

  select * into limit_row
  from public.barcode_lookup_limits
  where user_id = p_user_id
  for update;

  if not found then
    insert into public.barcode_lookup_limits (
      user_id, window_started_at, request_count, updated_at
    ) values (p_user_id, current_time, 1, current_time);
    return true;
  end if;

  if limit_row.window_started_at <= current_time - interval '1 minute' then
    update public.barcode_lookup_limits
    set window_started_at = current_time, request_count = 1, updated_at = current_time
    where user_id = p_user_id;
    return true;
  end if;

  if limit_row.request_count >= 12 then
    return false;
  end if;

  update public.barcode_lookup_limits
  set request_count = request_count + 1, updated_at = current_time
  where user_id = p_user_id;
  return true;
end;
$$;

revoke all on function public.consume_barcode_lookup_quota(uuid) from public;
grant execute on function public.consume_barcode_lookup_quota(uuid) to service_role;
