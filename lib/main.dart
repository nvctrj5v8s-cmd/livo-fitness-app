import 'package:fitness_ai_app/l10n/l10n.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/startup_splash.dart';
import 'core/config/supabase_config.dart';
import 'features/auth/data/browser_url.dart';
import 'features/auth/data/email_link.dart';
import 'features/auth/data/recovery_marker.dart';
import 'l10n/locale_controller.dart';
import 'l10n/catalog_text.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The language is known before the first frame, also for the texts below.
  final localeController = LocaleController();
  await localeController.load();
  await CatalogText.load();
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
    final result = await emailLink
        .verify(auth)
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () => EmailLinkResult.offline,
        );
    final verified = result == EmailLinkResult.verified;
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
      initialNotice = L10n.current.appConfirmedIfYouAlsoReceivedAnEmail;
    }
    if (result == EmailLinkResult.offline) {
      initialNotice = L10n.current.appNoConnectionToTheServerYourLink;
    } else if (!verified) {
      initialNotice = emailLink.isPasswordRecovery
          ? L10n.current.appYourResetLinkHasExpiredOrHas
          : L10n.current.appYourConfirmationLinkHasExpiredOrHas;
    }
    // A reload must not try the spent link again; after a network error the
    // link may still be valid and stays in the address bar.
    if (result != EmailLinkResult.offline) replaceBrowserUrlWithoutQuery();
  }

  // A session from a reset link stays limited to the new-password page, also
  // after a reload, until a new password is saved or the user cancels.
  final userId = auth.currentUser?.id;
  var initialPasswordRecovery = recovering;
  if (userId == null) {
    // No session: an old mark (for example from an expired session) is stale.
    try {
      await RecoveryMarker.clear();
    } catch (_) {}
  } else if (!recovering) {
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
        localeController: localeController,
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
