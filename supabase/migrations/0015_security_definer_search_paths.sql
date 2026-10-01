-- Reduce object-shadowing risk in older SECURITY DEFINER functions.
-- All application table references in these functions are schema-qualified.
-- Apply in the SQL Editor once, or via the linked Supabase CLI migrations.
alter function public.handle_new_user() set search_path = '';
alter function public.consume_barcode_lookup_quota(uuid) set search_path = '';
alter function public.consume_ai_chat_quota(uuid, integer) set search_path = '';
