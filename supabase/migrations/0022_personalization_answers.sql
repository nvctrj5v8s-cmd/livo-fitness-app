-- The answers of the personal set-up ("Fragen") are kept in the account, so a
-- new phone, a reinstall or another browser does not ask everything again.
--
-- They contain health-related details (birth date, height, weight, sex, health
-- note, allergies). The app only writes them after the explicit health-data
-- consent (Art. 9 GDPR), reads them for the signed-in account only, and deletes
-- them when the consent is withdrawn. Deleting the account removes them too.

create table if not exists public.personalization_answers (
  user_id uuid primary key references auth.users (id) on delete cascade,
  answers jsonb not null,
  updated_at timestamptz not null default timezone('utc', now()),
  constraint personalization_answers_size
    check (pg_catalog.pg_column_size(answers) <= 16384)
);

comment on table public.personalization_answers is
  'Answers of the personal set-up for the signed-in account. Written only after the health-data consent; deleted on withdrawal and with the account.';

alter table public.personalization_answers enable row level security;

drop policy if exists "personalization_answers_select_own" on public.personalization_answers;
create policy "personalization_answers_select_own"
  on public.personalization_answers for select
  to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "personalization_answers_insert_own" on public.personalization_answers;
create policy "personalization_answers_insert_own"
  on public.personalization_answers for insert
  to authenticated
  with check (user_id = (select auth.uid()));

drop policy if exists "personalization_answers_update_own" on public.personalization_answers;
create policy "personalization_answers_update_own"
  on public.personalization_answers for update
  to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

drop policy if exists "personalization_answers_delete_own" on public.personalization_answers;
create policy "personalization_answers_delete_own"
  on public.personalization_answers for delete
  to authenticated
  using (user_id = (select auth.uid()));

-- Only signed-in people use this table; no access without an account.
revoke all on public.personalization_answers from anon, public;
grant select, insert, update, delete on public.personalization_answers to authenticated;
