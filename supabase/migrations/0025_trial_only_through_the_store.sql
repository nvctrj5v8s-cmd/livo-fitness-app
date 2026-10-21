-- The free trial is now a Google Play offer: the store asks for a payment
-- method and allows it once per store account, and the webhook books it as
-- status 'trialing'. The old e-mail-only trial can no longer be started.

revoke execute on function public.start_premium_trial() from authenticated;

-- The hashes only served the old rule "one trial per e-mail address".
delete from public.trial_claims;

comment on table public.trial_claims is
  'Unused since migration 0025 (the trial is a store offer). Kept empty.';
