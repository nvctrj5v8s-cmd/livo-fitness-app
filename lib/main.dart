import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/supabase_config.dart';
import 'features/auth/data/email_link.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Supabase may consume and clear the web recovery URL during initialize,
  // before the first widget can subscribe to auth events.
  var initialPasswordRecovery =
      Uri.base.queryParameters['type'] == 'recovery' ||
      Uri.base.fragment.contains('type=recovery');
  final emailLink = EmailLink.fromUri(Uri.base);

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  String? initialNotice;
  if (emailLink != null) {
    final auth = Supabase.instance.client.auth;
    final verified = await emailLink
        .verify(auth)
        .timeout(const Duration(seconds: 12), onTimeout: () => false);
    initialPasswordRecovery = verified && emailLink.isPasswordRecovery;
    // After a reload the used link fails again; a session means it worked.
    if (!verified && auth.currentSession == null) {
      initialNotice = emailLink.isPasswordRecovery
          ? 'Der Link zum Zurücksetzen ist abgelaufen oder wurde schon '
                'benutzt. Fordere unter „Passwort vergessen?“ einen neuen an.'
          : 'Der Bestätigungslink ist abgelaufen oder wurde schon benutzt. '
                'Melde dich an oder fordere einen neuen Link an.';
    }
  }

  runApp(
    FitnessAiApp(
      initialPasswordRecovery: initialPasswordRecovery,
      initialNotice: initialNotice,
    ),
  );
}
