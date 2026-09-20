-- Persistent, account-scoped LIVO coach history. Only the trusted Edge
-- Function may write messages; signed-in users may only read their own.
create table if not exists public.ai_chat_messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('user', 'assistant')),
  content text not null check (char_length(content) between 1 and 1200),
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists ai_chat_messages_user_created_idx
  on public.ai_chat_messages (user_id, created_at asc);

alter table public.ai_chat_messages enable row level security;

create policy "Users can read their own AI chat history"
  on public.ai_chat_messages for select
  using (auth.uid() = user_id);

revoke all on table public.ai_chat_messages from public, anon, authenticated;
grant select on table public.ai_chat_messages to authenticated;
