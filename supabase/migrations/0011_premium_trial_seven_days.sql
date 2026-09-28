-- LIVO Premium: extend the free trial from 3 to 7 days (decided 2026-09-27).
--
-- NOT APPLIED AUTOMATICALLY. Requires `0008_premium_trial.sql`. Review and run
-- it in the Supabase SQL Editor or with `supabase db push --linked`.
--
-- * Repeatable: it only replaces `public.start_premium_trial()` and re-applies
--   its comment and grants. The function body is identical to 0008 except for
--   `interval '7 days'`.
-- * Affects only trials started after it was applied. Running trials and
--   `public.premium_trials` rows keep their stored `ends_at` / `expires_at`;
--   no table, policy or data is changed.
-- * The app shows the trial length from `SubscriptionPlans.trialDays`; keep
--   both values in sync.

create or replace function public.start_premium_trial()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_now timestamptz := pg_catalog.now();
  v_ends_at timestamptz := pg_catalog.now() + interval '7 days';
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
  'Starts the free 7-day LIVO Premium trial once per account. No payment data, ends automatically.';

-- Supabase grants EXECUTE on new functions to anon by default; only signed-in
-- users may start a trial.
revoke all on function public.start_premium_trial() from public;
revoke all on function public.start_premium_trial() from anon;
grant execute on function public.start_premium_trial() to authenticated;
