-- The developer switch is only available to a developer account whose e-mail
-- address is confirmed. Without this check, an unconfirmed sign-up with a
-- Gmail variant of the owner's address (dots or "+tag") would map to the
-- same hash and could switch premium on.

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
       and u.email_confirmed_at is not null
  );
$$;

revoke all on function public.is_developer() from public, anon;
grant execute on function public.is_developer() to authenticated;
