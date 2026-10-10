-- Records of consent decisions and of withdrawals from the premium contract.
--
-- * user_consents: append-only log of explicit consent decisions
--   (health data, AI processing, immediate start of the paid service before
--   the withdrawal period ends). Users may add and read their own rows but
--   never change or delete them, so the log stays a reliable record
--   (Art. 7 Abs. 1 DSGVO). A revocation is a new row with granted = false.
-- * withdrawal_requests: written only by the `legal-actions` Edge Function
--   (§ 356a BGB withdrawal function). Kept when the account is deleted
--   (user_id set to null) as proof of receipt.
--
-- Apply in the SQL Editor once, or via the linked Supabase CLI migrations.

create table if not exists public.user_consents (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null check (kind in ('health_data', 'ai_processing', 'immediate_start')),
  granted boolean not null,
  text_version text not null check (char_length(text_version) between 1 and 40),
  context text check (context is null or char_length(context) <= 120),
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists user_consents_user_kind_idx
  on public.user_consents (user_id, kind, created_at desc);

-- The server clock decides the time of a decision, never the client.
create or replace function public.user_consents_set_created_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.created_at := pg_catalog.timezone('utc', pg_catalog.now());
  return new;
end;
$$;

drop trigger if exists user_consents_created_at on public.user_consents;
create trigger user_consents_created_at
  before insert on public.user_consents
  for each row execute function public.user_consents_set_created_at();

alter table public.user_consents enable row level security;

drop policy if exists "Users read their consents" on public.user_consents;
create policy "Users read their consents"
  on public.user_consents for select using (auth.uid() = user_id);

drop policy if exists "Users record their consents" on public.user_consents;
create policy "Users record their consents"
  on public.user_consents for insert with check (auth.uid() = user_id);

create table if not exists public.withdrawal_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  name text not null check (char_length(name) between 1 and 120),
  email text not null check (char_length(email) between 3 and 254),
  contract_note text check (contract_note is null or char_length(contract_note) <= 300),
  -- Salted hash of the sender IP, only to limit abuse of the public form.
  client_hash text check (client_hash is null or char_length(client_hash) = 64),
  user_confirmation_sent boolean not null default false,
  owner_notification_sent boolean not null default false,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists withdrawal_requests_user_idx
  on public.withdrawal_requests (user_id, created_at desc);

create index if not exists withdrawal_requests_client_idx
  on public.withdrawal_requests (client_hash, created_at desc);

create index if not exists withdrawal_requests_email_idx
  on public.withdrawal_requests (email, created_at desc);

alter table public.withdrawal_requests enable row level security;

drop policy if exists "Users read their withdrawals" on public.withdrawal_requests;
create policy "Users read their withdrawals"
  on public.withdrawal_requests for select using (auth.uid() = user_id);
