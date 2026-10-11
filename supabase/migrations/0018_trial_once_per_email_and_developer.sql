-- 1) The free trial is available once per e-mail address, not only once per
--    account. Deleting the account and signing up again with the same address
--    (also Gmail variants with dots or "+tag") no longer gives a new trial.
--    The trial also needs a confirmed e-mail address.
-- 2) Developer accounts (identified by the hash of their e-mail address, never
--    the address itself) can switch premium on and off for testing.
--
-- Apply in the SQL Editor once, or via the linked Supabase CLI migrations.

-- Normalised e-mail hash: lower case, "+tag" removed, for Gmail also the
-- dots, googlemail.com treated as gmail.com. Returns null for no address.
create or replace function public.email_identity_hash(p_email text)
returns text
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_email text := pg_catalog.lower(pg_catalog.btrim(coalesce(p_email, '')));
  v_local text;
  v_domain text;
begin
  if v_email = '' or pg_catalog.strpos(v_email, '@') = 0 then
    return null;
  end if;
  v_local := pg_catalog.split_part(v_email, '@', 1);
  v_domain := pg_catalog.split_part(v_email, '@', 2);
  v_local := pg_catalog.split_part(v_local, '+', 1);
  if v_domain in ('gmail.com', 'googlemail.com') then
    v_local := pg_catalog.replace(v_local, '.', '');
    v_domain := 'gmail.com';
  end if;
  return pg_catalog.encode(
    pg_catalog.sha256(pg_catalog.convert_to(v_local || '@' || v_domain, 'UTF8')),
    'hex'
  );
end;
$$;

revoke all on function public.email_identity_hash(text) from public, anon, authenticated;

-- One row per e-mail address that has used the trial. No foreign key, so the
-- row survives an account deletion. Only the hash and the time are stored.
create table if not exists public.trial_claims (
  email_hash text primary key check (char_length(email_hash) = 64),
  claimed_at timestamptz not null default timezone('utc', now())
);

comment on table public.trial_claims is
  'Hash of each normalised e-mail address that used the free trial. Kept after account deletion to prevent repeated trials.';

alter table public.trial_claims enable row level security;
-- No policies: only security-definer functions read or write this table.

-- Earlier trials count too.
insert into public.trial_claims (email_hash, claimed_at)
select public.email_identity_hash(u.email), pt.started_at
  from public.premium_trials as pt
  join auth.users as u on u.id = pt.user_id
 where public.email_identity_hash(u.email) is not null
on conflict (email_hash) do nothing;

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
  v_email text;
  v_confirmed timestamptz;
  v_hash text;
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

  -- Claims are kept for at most three years (privacy policy).
  delete from public.trial_claims
   where claimed_at < v_now - interval '3 years';

  -- Only a confirmed address can claim the trial, and only once per address.
  select u.email, u.email_confirmed_at into v_email, v_confirmed
    from auth.users as u
   where u.id = v_user_id;
  v_hash := public.email_identity_hash(v_email);
  if v_hash is null or v_confirmed is null then
    return pg_catalog.jsonb_build_object('result', 'email_unconfirmed');
  end if;
  insert into public.trial_claims (email_hash, claimed_at)
  values (v_hash, v_now)
  on conflict (email_hash) do nothing;
  get diagnostics v_inserted = row_count;
  if v_inserted = 0 then
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
  'Starts the free 7-day Lookin Premium trial once per confirmed e-mail address. No payment data, ends automatically.';

revoke all on function public.start_premium_trial() from public;
revoke all on function public.start_premium_trial() from anon;
grant execute on function public.start_premium_trial() to authenticated;

-- Developer accounts, stored as hashes of their normalised e-mail address.
create table if not exists public.developer_accounts (
  email_hash text primary key check (char_length(email_hash) = 64),
  note text,
  created_at timestamptz not null default timezone('utc', now())
);

alter table public.developer_accounts enable row level security;
-- No policies: only the functions below read this table.

insert into public.developer_accounts (email_hash, note)
values ('1b820be568325ccda57a24d507a139a9c07cd49afd87699adf73fa63ea3415ab', 'Inhaber')
on conflict (email_hash) do nothing;

create or replace function public.is_developer()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
      from auth.users as u
      join public.developer_accounts as d
        on d.email_hash = public.email_identity_hash(u.email)
     where u.id = auth.uid()
  );
$$;

-- Switches premium on or off for the calling developer account only.
create or replace function public.developer_set_premium(p_enabled boolean)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_now timestamptz := pg_catalog.now();
begin
  if v_user_id is null or not public.is_developer() then
    raise exception 'not_developer' using errcode = '42501';
  end if;
  insert into public.entitlements (user_id, plan, status, expires_at, provider, updated_at)
  values (
    v_user_id,
    case when p_enabled then 'premium' else 'free' end,
    'active',
    case when p_enabled then timestamptz '2100-01-01 00:00:00+00' else null end,
    'developer',
    v_now
  )
  on conflict (user_id) do update
    set plan = excluded.plan,
        status = excluded.status,
        expires_at = excluded.expires_at,
        provider = excluded.provider,
        updated_at = excluded.updated_at;
  return pg_catalog.jsonb_build_object('premium', p_enabled);
end;
$$;

revoke all on function public.is_developer() from public, anon;
grant execute on function public.is_developer() to authenticated;
revoke all on function public.developer_set_premium(boolean) from public, anon;
grant execute on function public.developer_set_premium(boolean) to authenticated;

-- The owner's account starts with premium switched on.
insert into public.entitlements (user_id, plan, status, expires_at, provider, updated_at)
select u.id, 'premium', 'active', timestamptz '2100-01-01 00:00:00+00', 'developer', pg_catalog.now()
  from auth.users as u
  join public.developer_accounts as d on d.email_hash = public.email_identity_hash(u.email)
on conflict (user_id) do update
  set plan = excluded.plan,
      status = excluded.status,
      expires_at = excluded.expires_at,
      provider = excluded.provider,
      updated_at = excluded.updated_at;
