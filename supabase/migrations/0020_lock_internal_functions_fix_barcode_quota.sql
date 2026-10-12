-- 1) Internal functions must only be callable by the Edge Functions (service
--    role). Supabase grants execute to anon and authenticated by default, and
--    "revoke ... from public" does not remove those explicit grants. Without
--    this, anyone with the public app key could burn another account's AI or
--    barcode quota by calling the function with that account's id.
-- 2) consume_barcode_lookup_quota declared a variable named current_time. In
--    SQL expressions that name is the keyword (time of day), so the first
--    insert failed with a type error and the barcode rate limit never worked
--    (the Edge Function ignores the error on purpose). The variable is renamed.

create or replace function public.consume_barcode_lookup_quota(p_user_id uuid)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  limit_row public.barcode_lookup_limits%rowtype;
  v_now timestamptz := pg_catalog.timezone('utc', pg_catalog.now());
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
    ) values (p_user_id, v_now, 1, v_now);
    return true;
  end if;

  if limit_row.window_started_at <= v_now - interval '1 minute' then
    update public.barcode_lookup_limits
    set window_started_at = v_now, request_count = 1, updated_at = v_now
    where user_id = p_user_id;
    return true;
  end if;

  if limit_row.request_count >= 12 then
    return false;
  end if;

  update public.barcode_lookup_limits
  set request_count = request_count + 1, updated_at = v_now
  where user_id = p_user_id;
  return true;
end;
$$;

revoke all on function public.consume_barcode_lookup_quota(uuid)
  from public, anon, authenticated;
grant execute on function public.consume_barcode_lookup_quota(uuid)
  to service_role;

revoke all on function public.consume_ai_chat_quota(uuid, integer)
  from public, anon, authenticated;
grant execute on function public.consume_ai_chat_quota(uuid, integer)
  to service_role;

-- Trigger function: it runs as a trigger and is never called directly.
revoke all on function public.handle_new_user()
  from public, anon, authenticated;
