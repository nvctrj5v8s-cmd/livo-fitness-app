-- 1. Daily retention run, so the periods promised in the privacy policy hold
--    without anyone having to remember them.
-- 2. Withdrawing the health-data consent deletes the health data in the
--    account on the server, even when the app could not do it itself (no
--    network) and the withdrawal only arrives later.
-- 3. Reports of AI answers made inside the app (Google Play requires in-app
--    reporting). Written only by the ai-coach Edge Function.

-- ── 3. Reports ────────────────────────────────────────────────────────────
create table if not exists public.ai_answer_reports (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade,
  reason text not null check (reason in ('wrong', 'unsafe', 'inappropriate', 'other')),
  answer text not null check (char_length(answer) between 1 and 2000),
  locale text check (locale in ('de', 'en')),
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists ai_answer_reports_user_created_idx
  on public.ai_answer_reports (user_id, created_at desc);

-- No policies: only the service role (Edge Function) reads or writes.
alter table public.ai_answer_reports enable row level security;
revoke all on table public.ai_answer_reports from anon, authenticated;

comment on table public.ai_answer_reports is
  'Reports of AI coach answers from inside the app. Kept 12 months, deleted with the account.';

-- ── 2. Health data follows the consent ────────────────────────────────────
create or replace function public.delete_health_data_on_withdrawal()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.kind = 'health_data' and new.granted = false then
    update public.profiles
       set allergies = '', target_weight = null, updated_at = pg_catalog.now()
     where user_id = new.user_id;
    delete from public.personalization_answers where user_id = new.user_id;
    delete from public.body_measurements where user_id = new.user_id;
  end if;
  return new;
end;
$$;

revoke all on function public.delete_health_data_on_withdrawal() from public, anon, authenticated;

drop trigger if exists user_consents_health_withdrawal on public.user_consents;
create trigger user_consents_health_withdrawal
  after insert on public.user_consents
  for each row execute function public.delete_health_data_on_withdrawal();

-- ── 1. Retention ──────────────────────────────────────────────────────────
create or replace function public.run_retention_cleanup()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- IP check value of website withdrawals: at most 24 hours.
  update public.withdrawal_requests
     set client_hash = null
   where client_hash is not null
     and created_at < pg_catalog.now() - interval '24 hours';

  -- Withdrawal declarations: until the limitation period has passed (three
  -- years from the end of the year of receipt).
  delete from public.withdrawal_requests
   where created_at < pg_catalog.date_trunc('year', pg_catalog.now()) - interval '3 years';

  -- Hash of the trial e-mail address: at most three years.
  delete from public.trial_claims
   where claimed_at < pg_catalog.now() - interval '3 years';

  -- Coach history: messages of the last 90 days only.
  delete from public.ai_chat_messages
   where created_at < pg_catalog.now() - interval '90 days';

  -- Reports of AI answers: at most 12 months.
  delete from public.ai_answer_reports
   where created_at < pg_catalog.now() - interval '12 months';
end;
$$;

revoke all on function public.run_retention_cleanup() from public, anon, authenticated;

create extension if not exists pg_cron with schema pg_catalog;

-- Every night at 03:17 UTC. Scheduling under the same name replaces it.
select cron.schedule(
  'lookin-retention-cleanup',
  '17 3 * * *',
  'select public.run_retention_cleanup()'
);
