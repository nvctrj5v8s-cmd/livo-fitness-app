import 'package:supabase_flutter/supabase_flutter.dart';

/// Stores the chosen language in the account (`user_metadata.locale`), so the
/// sign-up, password and purchase e-mails come in the same language. Fails
/// quietly: the app language itself lives on the device.
Future<void> syncLocaleToAccount(String code) async {
  try {
    final auth = Supabase.instance.client.auth;
    final user = auth.currentUser;
    if (user == null || user.userMetadata?['locale'] == code) return;
    await auth.updateUser(UserAttributes(data: {'locale': code}));
  } catch (_) {
    // Not signed in, offline or no backend (tests): try again next time.
  }
}
