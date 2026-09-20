-- Server-side cost protection for the LIVO AI coach.
create table if not exists public.ai_chat_usage (
  user_id uuid not null references auth.users(id) on delete cascade,
  usage_date date not null,
  request_count integer not null default 0 check (request_count >= 0),
  updated_at timestamptz not null default timezone('utc', now()),
  primary key (user_id, usage_date)
);

alter table public.ai_chat_usage enable row level security;

create or replace function public.consume_ai_chat_quota(
  p_user_id uuid,
  p_daily_limit integer
)
returns table (allowed boolean, used integer, remaining integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  usage_day date := (timezone('utc', now()))::date;
  current_count integer;
begin
  if p_user_id is null or p_daily_limit < 1 then
    return query select false, 0, 0;
    return;
  end if;

  insert into public.ai_chat_usage (user_id, usage_date, request_count)
  values (p_user_id, usage_day, 1)
  on conflict (user_id, usage_date) do update
    set request_count = public.ai_chat_usage.request_count + 1,
        updated_at = timezone('utc', now())
    where public.ai_chat_usage.request_count < p_daily_limit
  returning request_count into current_count;

  if current_count is null then
    select request_count into current_count
    from public.ai_chat_usage
    where user_id = p_user_id and usage_date = usage_day;
    return query select false, coalesce(current_count, 0), 0;
    return;
  end if;

  return query select true, current_count, greatest(p_daily_limit - current_count, 0);
end;
$$;

revoke all on table public.ai_chat_usage from public, anon, authenticated;
revoke all on function public.consume_ai_chat_quota(uuid, integer) from public;
grant execute on function public.consume_ai_chat_quota(uuid, integer) to service_role;
