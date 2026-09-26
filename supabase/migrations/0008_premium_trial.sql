-- LIVO Premium: app-controlled free trial without payment data.
--
-- NOT APPLIED AUTOMATICALLY. Review and run it in the Supabase SQL Editor.
--
-- * `start_premium_trial()` can be called by a signed-in user exactly once per
--   account. It sets `public.entitlements` to plan = 'premium',
--   status = 'trialing', expires_at = now() + 3 days, provider = 'livo_trial'.
-- * `public.premium_trials` remembers that the trial was used, so it cannot be
--   repeated. It stores only the account ID and two timestamps: no payment,
--   health or nutrition data.
-- * The trial ends by itself: RLS (`0001_livo_schema.sql`) and the `ai-coach`
--   Edge Function compare `expires_at` with the current time. There is no
--   automatic conversion, no payment method and no charge.

create table if not exists public.premium_trials (
  user_id uuid primary key references auth.users(id) on delete cascade,
  started_at timestamptz not null default timezone('utc', now()),
  ends_at timestamptz not null,
  constraint premium_trials_valid_period check (ends_at > started_at)
);

comment on table public.premium_trials is
  'One row per account that has used the free LIVO Premium trial. No payment or health data.';

alter table public.premium_trials enable row level security;

drop policy if exists "Users can read their premium trial" on public.premium_trials;
create policy "Users can read their premium trial"
  on public.premium_trials for select
  using (auth.uid() = user_id);

-- Rows are only written by the SECURITY DEFINER function below.
revoke all on table public.premium_trials from anon;
revoke insert, update, delete, truncate on table public.premium_trials from authenticated;
grant select on table public.premium_trials to authenticated;

create or replace function public.start_premium_trial()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_now timestamptz := pg_catalog.now();
  v_ends_at timestamptz := pg_catalog.now() + interval '3 days';
  v_entitlement record;
  v_has_entitlement boolean;
  v_inserted integer;
begin
  if v_user_id is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  -- Lock the account's entitlement row so parallel calls run one after another.
  select e.plan, e.status, e.expires_at, e.provider
    into v_entitlement
    from public.entitlements as e
   where e.user_id = v_user_id
   for update;
  v_has_entitlement := found;

  -- Never replace an active subscription or a running trial.
  if v_has_entitlement
     and v_entitlement.plan = 'premium'
     and v_entitlement.status in ('active', 'trialing')
     and (v_entitlement.expires_at is null or v_entitlement.expires_at > v_now) then
    return pg_catalog.jsonb_build_object(
      'result', 'already_premium',
      'status', v_entitlement.status,
      'expires_at', v_entitlement.expires_at
    );
  end if;

  -- A trial granted before this table existed also counts as used.
  if v_has_entitlement and v_entitlement.provider = 'livo_trial' then
    return pg_catalog.jsonb_build_object('result', 'trial_used');
  end if;

  insert into public.premium_trials (user_id, started_at, ends_at)
  values (v_user_id, v_now, v_ends_at)
  on conflict (user_id) do nothing;
  get diagnostics v_inserted = row_count;

  if v_inserted = 0 then
    return pg_catalog.jsonb_build_object('result', 'trial_used');
  end if;

  -- provider_customer_id is left untouched: a trial has no store customer.
  insert into public.entitlements (user_id, plan, status, expires_at, provider, updated_at)
  values (v_user_id, 'premium', 'trialing', v_ends_at, 'livo_trial', v_now)
  on conflict (user_id) do update
    set plan = excluded.plan,
        status = excluded.status,
        expires_at = excluded.expires_at,
        provider = excluded.provider,
        updated_at = excluded.updated_at;

  return pg_catalog.jsonb_build_object(
    'result', 'started',
    'status', 'trialing',
    'expires_at', v_ends_at
  );
end;
$$;

comment on function public.start_premium_trial() is
  'Starts the free 3-day LIVO Premium trial once per account. No payment data, ends automatically.';

-- Supabase grants EXECUTE on new functions to anon by default; only signed-in
-- users may start a trial.
revoke all on function public.start_premium_trial() from public;
revoke all on function public.start_premium_trial() from anon;
grant execute on function public.start_premium_trial() to authenticated;
