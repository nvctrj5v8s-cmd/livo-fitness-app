import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/startup_splash.dart';
import 'core/config/supabase_config.dart';
import 'features/auth/data/browser_url.dart';
import 'features/auth/data/email_link.dart';
import 'features/auth/data/recovery_marker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Supabase may consume and clear the web recovery URL during initialize,
  // before the first widget can subscribe to auth events.
  final recoveryInUrl =
      Uri.base.queryParameters['type'] == 'recovery' ||
      Uri.base.fragment.contains('type=recovery');
  final emailLink = EmailLink.fromUri(Uri.base);

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  final auth = Supabase.instance.client.auth;
  String? initialNotice;
  String? confirmedEmail;
  var recovering = false;
  if (emailLink != null) {
    final verified = await emailLink
        .verify(auth)
        .timeout(const Duration(seconds: 12), onTimeout: () => false);
    final userId = auth.currentUser?.id;
    if (verified && emailLink.isPasswordRecovery && userId != null) {
      recovering = true;
      await _markRecovery(userId);
    }
    if (verified && emailLink.isSignUpConfirmation) {
      // Show a clear "E-Mail bestätigt" page and let the person sign in on
      // purpose, the same in the browser as for app users.
      confirmedEmail = auth.currentUser?.email ?? '';
      try {
        await auth.signOut(scope: SignOutScope.local);
      } catch (_) {
        // Still show the page; the sign-in form works with a session too.
      }
    }
    if (verified && emailLink.type == OtpType.emailChange) {
      initialNotice =
          'Bestätigt. Hast du auch an deine andere Adresse eine E-Mail '
          'bekommen, bestätige die Änderung dort ebenfalls.';
    }
    if (!verified && auth.currentSession == null) {
      initialNotice = emailLink.isPasswordRecovery
          ? 'Der Link zum Zurücksetzen ist abgelaufen oder wurde schon '
                'benutzt. Fordere unter „Passwort vergessen?“ einen neuen an.'
          : 'Der Bestätigungslink ist abgelaufen oder wurde schon benutzt. '
                'Melde dich an. Ist deine Adresse noch nicht bestätigt, '
                'kannst du dort eine neue Bestätigungs-Mail anfordern.';
    }
    // A reload must not try the spent link again.
    replaceBrowserUrlWithoutQuery();
  } else if (recoveryInUrl && auth.currentUser != null) {
    recovering = true;
    await _markRecovery(auth.currentUser!.id);
  }

  // A session from a reset link stays limited to the new-password page, also
  // after a reload, until a new password is saved or the user cancels.
  final userId = auth.currentUser?.id;
  var initialPasswordRecovery = recovering;
  if (userId != null && !recovering) {
    try {
      initialPasswordRecovery = await RecoveryMarker.isSetFor(userId);
    } catch (_) {
      // No local storage: only the link itself opens the page.
    }
  }

  runApp(
    StartupSplash(
      child: FitnessAiApp(
        initialPasswordRecovery: initialPasswordRecovery,
        initialNotice: initialNotice,
        initialConfirmedEmail: confirmedEmail,
      ),
    ),
  );
}

Future<void> _markRecovery(String userId) async {
  try {
    await RecoveryMarker.set(userId);
  } catch (_) {
    // Without local storage the page still opens for this start.
  }
}
