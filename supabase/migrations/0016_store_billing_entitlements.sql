-- Store billing (Google Play / App Store via RevenueCat) writes entitlements
-- only on the server. The app never writes `public.entitlements`; the
-- `revenuecat-webhook` Edge Function calls `apply_revenuecat_event` with the
-- service role after it verified the shared webhook secret.
--
-- Apply in the SQL Editor once, or via the linked Supabase CLI migrations.

alter table public.entitlements
  add column if not exists provider_event_at timestamptz;

comment on column public.entitlements.provider_event_at is
  'Timestamp of the last store event applied; older or duplicate events are ignored.';

create or replace function public.apply_revenuecat_event(
  p_user_id uuid,
  p_status text,
  p_expires_at timestamptz,
  p_customer_id text,
  p_event_at timestamptz
)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_current record;
  v_now timestamptz := pg_catalog.now();
begin
  if p_status not in ('active', 'trialing', 'expired') then
    raise exception 'invalid_status' using errcode = '22023';
  end if;

  -- The account may have been deleted while the store still reports events.
  perform 1 from auth.users as u where u.id = p_user_id;
  if not found then
    return 'unknown_user';
  end if;

  select e.status, e.expires_at, e.provider, e.provider_event_at
    into v_current
    from public.entitlements as e
   where e.user_id = p_user_id
   for update;

  -- Duplicate or out-of-order delivery: never move the state backwards.
  if found
     and v_current.provider = 'revenuecat'
     and v_current.provider_event_at is not null
     and v_current.provider_event_at >= p_event_at then
    return 'stale';
  end if;

  -- A late "expired" for an old store subscription must not cut off a
  -- running app trial or another provider's access.
  if found
     and p_status = 'expired'
     and v_current.provider is distinct from 'revenuecat'
     and v_current.status in ('active', 'trialing')
     and (v_current.expires_at is null or v_current.expires_at > v_now) then
    return 'ignored';
  end if;

  insert into public.entitlements (
    user_id, plan, status, expires_at, provider, provider_customer_id,
    provider_event_at, updated_at
  )
  values (
    p_user_id, 'premium', p_status, p_expires_at, 'revenuecat', p_customer_id,
    p_event_at, v_now
  )
  on conflict (user_id) do update
    set plan = excluded.plan,
        status = excluded.status,
        expires_at = excluded.expires_at,
        provider = excluded.provider,
        provider_customer_id = excluded.provider_customer_id,
        provider_event_at = excluded.provider_event_at,
        updated_at = excluded.updated_at;

  return 'applied';
end;
$$;

comment on function public.apply_revenuecat_event(uuid, text, timestamptz, text, timestamptz) is
  'Applies one verified store event to public.entitlements. Service role only.';

-- Supabase grants EXECUTE on new functions to anon and authenticated by
-- default. Nobody but the Edge Function (service role) may call this.
revoke all on function public.apply_revenuecat_event(uuid, text, timestamptz, text, timestamptz) from public;
revoke all on function public.apply_revenuecat_event(uuid, text, timestamptz, text, timestamptz) from anon;
revoke all on function public.apply_revenuecat_event(uuid, text, timestamptz, text, timestamptz) from authenticated;
grant execute on function public.apply_revenuecat_event(uuid, text, timestamptz, text, timestamptz) to service_role;
