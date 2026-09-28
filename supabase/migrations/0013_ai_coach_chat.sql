-- LIVO coach chat: complete stored answers and a fair daily limit.
--
-- NOT APPLIED AUTOMATICALLY. Review and run it in the Supabase SQL Editor
-- (or with `supabase db push --linked`) BEFORE deploying the matching
-- `ai-coach` Edge Function. The script can safely be run more than once.
--
-- * `ai_chat_messages.content` may now hold up to 4000 instead of 1200
--   characters. Longer coach answers were rejected by the old CHECK, so the
--   whole question/answer pair silently disappeared from the history. The
--   Edge Function still limits questions to 600 characters and shortens
--   answers to 4000 characters before storing them.
-- * `release_ai_chat_quota(user)` gives one request of today's AI limit back
--   when the AI service failed and no answer was produced. Only the Edge
--   Function (service_role) may call it.
--
-- Unchanged: signed-in users may only read their own messages (0005). Writing,
-- the retention (newest 100 messages, at most 90 days) and "Verlauf löschen"
-- are done by the Edge Function with the service role. Deleting the account
-- removes all messages through `on delete cascade`.

do $$
declare
  v_constraint record;
begin
  -- Drops the unnamed CHECK from 0005 (and this migration's own CHECK on a
  -- repeated run) without depending on the generated constraint name.
  for v_constraint in
    select c.conname
      from pg_catalog.pg_constraint as c
     where c.conrelid = 'public.ai_chat_messages'::regclass
       and c.contype = 'c'
       and pg_catalog.pg_get_constraintdef(c.oid) like '%char_length(content)%'
  loop
    execute pg_catalog.format(
      'alter table public.ai_chat_messages drop constraint %I',
      v_constraint.conname
    );
  end loop;
end;
$$;

alter table public.ai_chat_messages
  add constraint ai_chat_messages_content_length
  check (char_length(content) between 1 and 4000);

comment on table public.ai_chat_messages is
  'LIVO coach chat history per account. Written, pruned (100 messages / 90 days) and deleted only by the ai-coach Edge Function.';

create or replace function public.release_ai_chat_quota(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if p_user_id is null then
    return;
  end if;

  update public.ai_chat_usage
     set request_count = request_count - 1,
         updated_at = pg_catalog.timezone('utc', pg_catalog.now())
   where user_id = p_user_id
     and usage_date = (pg_catalog.timezone('utc', pg_catalog.now()))::date
     and request_count > 0;
end;
$$;

comment on function public.release_ai_chat_quota(uuid) is
  'Gives back one AI request of today when the AI produced no answer. Edge Function only.';

-- Supabase grants EXECUTE on new functions to anon/authenticated by default.
revoke all on function public.release_ai_chat_quota(uuid) from public;
revoke all on function public.release_ai_chat_quota(uuid) from anon;
revoke all on function public.release_ai_chat_quota(uuid) from authenticated;
grant execute on function public.release_ai_chat_quota(uuid) to service_role;
