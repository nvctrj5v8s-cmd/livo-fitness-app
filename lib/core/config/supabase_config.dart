/// Public Supabase connection values for the Flutter client.
///
/// The publishable key is intentionally safe for frontend use when every
/// exposed table is protected by Row Level Security. Secret/service-role keys
/// must only live in Supabase Edge Functions or another trusted backend.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://kypxutvvpklkvekciuen.supabase.co',
  );

  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_tRpVVjcjTnUcNMnrcJzGXg_1enTAu7K',
  );
}
