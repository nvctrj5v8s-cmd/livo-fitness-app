import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/state/app_controller.dart';
import '../core/theme/app_theme.dart';
import '../features/consent/presentation/consent_gate.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../features/auth/presentation/auth_page.dart';
import '../features/auth/presentation/email_status_pages.dart';
import '../features/auth/data/account_locale.dart';
import '../features/auth/data/recovery_marker.dart';
import '../features/auth/presentation/password_recovery_page.dart';
import '../features/language/presentation/language_page.dart';
import '../features/navigation/presentation/app_shell.dart';
import '../features/onboarding/data/introduction_store.dart';
import '../features/onboarding/data/personalization_store.dart';
import '../features/onboarding/presentation/introduction_gate.dart';
import '../features/onboarding/presentation/personalization_gate.dart';
import '../features/onboarding/presentation/questions_first_gate.dart';
import '../features/subscription/presentation/paywall_gate.dart';
import '../l10n/l10n.dart';
import '../l10n/locale_controller.dart';

class FitnessAiApp extends StatefulWidget {
  const FitnessAiApp({
    this.useAuth = true,
    this.initialPasswordRecovery = false,
    this.initialNotice,
    this.initialConfirmedEmail,
    this.localeController,
    super.key,
  });

  final bool useAuth;

  /// The app language. Without it (tests, previews) the app stays German and
  /// the language page is skipped.
  final LocaleController? localeController;
  final bool initialPasswordRecovery;

  /// Set when the app was opened from a confirmation link: shows
  /// „E-Mail bestätigt“ and then the sign-in with this address.
  final String? initialConfirmedEmail;

  /// Shown once after start, for example when an e-mail link has expired.
  final String? initialNotice;

  @override
  State<FitnessAiApp> createState() => _FitnessAiAppState();
}

class _FitnessAiAppState extends State<FitnessAiApp> {
  late AppController _controller;
  StreamSubscription<AuthState>? _authSubscription;
  String? _userId;
  bool _passwordRecovery = false;
  String? _confirmedEmail;
  String? _directSignInEmail;
  final _messenger = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _userId = widget.useAuth
        ? Supabase.instance.client.auth.currentUser?.id
        : null;
    _passwordRecovery =
        widget.useAuth && widget.initialPasswordRecovery && _userId != null;
    _controller = AppController(personalizationUserId: _userId);
    final locales = widget.localeController;
    if (locales != null) {
      locales.onChanged = (locale) {
        unawaited(syncLocaleToAccount(locale.languageCode));
        _rebuildForLanguage();
      };
      if (_userId != null && locales.hasChoice) {
        unawaited(syncLocaleToAccount(locales.locale.languageCode));
      }
    }
    if (widget.useAuth && _userId == null) {
      _confirmedEmail = widget.initialConfirmedEmail;
    }
    final notice = widget.initialNotice;
    if (notice != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _messenger.currentState?.showSnackBar(
          SnackBar(content: Text(notice), duration: const Duration(seconds: 8)),
        ),
      );
    }
    if (widget.useAuth) {
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange
          .listen((event) {
            final nextUserId = event.session?.user.id;
            if (!mounted) return;
            if (event.event == AuthChangeEvent.passwordRecovery) {
              if (nextUserId != null) unawaited(_remember(nextUserId));
              setState(() => _passwordRecovery = nextUserId != null);
            } else if (event.event == AuthChangeEvent.signedOut) {
              unawaited(_forgetRecovery());
              setState(() => _passwordRecovery = false);
              final saved = passwordSavedNotice.value;
              if (saved != null) {
                passwordSavedNotice.value = null;
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _messenger.currentState?.showSnackBar(
                    SnackBar(
                      content: Text(saved),
                      duration: const Duration(seconds: 6),
                    ),
                  ),
                );
              }
            }
            if (nextUserId == _userId) return;
            final previous = _controller;
            setState(() {
              _userId = nextUserId;
              if (nextUserId != null) {
                _confirmedEmail = null;
                _directSignInEmail = null;
              }
              _controller = AppController(personalizationUserId: nextUserId);
            });
            previous.dispose();
            final language = widget.localeController;
            if (nextUserId != null && language != null && language.hasChoice) {
              unawaited(syncLocaleToAccount(language.locale.languageCode));
            }
          });
    }
  }

  Future<void> _remember(String userId) async {
    try {
      await RecoveryMarker.set(userId);
    } catch (_) {}
  }

  Future<void> _forgetRecovery() async {
    try {
      await RecoveryMarker.clear();
    } catch (_) {}
  }

  /// Texts that were built outside the localization lookup (for example in
  /// helper functions) follow the new language too: every widget rebuilds
  /// once, without losing its state or the open screens.
  void _rebuildForLanguage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      void rebuild(Element element) {
        element.markNeedsBuild();
        element.visitChildren(rebuild);
      }

      (context as Element).visitChildren(rebuild);
    });
  }

  @override
  void dispose() {
    widget.localeController?.onChanged = null;
    _authSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locales = widget.localeController;
    if (locales == null) return _app(L10n.german);
    return LocaleScope(
      controller: locales,
      child: ListenableBuilder(
        listenable: locales,
        builder: (context, _) => _app(locales.locale),
      ),
    );
  }

  Widget _app(Locale locale) {
    final locales = widget.localeController;
    return AppScope(
      controller: _controller,
      child: MaterialApp(
        key: ValueKey(_userId ?? 'signed-out-preview'),
        scaffoldMessengerKey: _messenger,
        onGenerateTitle: (context) => context.l10n.commonAppTitle,
        locale: locale,
        supportedLocales: L10n.supported,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.dark,
        // First start: the language comes before everything else.
        home: locales != null && !locales.hasChoice
            ? LanguagePage(initial: locales.suggested, onChosen: locales.choose)
            // The demo/test mode without account skips all gates, including
            // the paywall; premium features stay locked there.
            : widget.useAuth
            ? _authHome()
            : const AppShell(),
      ),
    );
  }

  Widget _authHome() {
    if (_passwordRecovery && _userId != null) {
      return const PasswordRecoveryPage();
    }
    if (_userId == null && _confirmedEmail != null) {
      return EmailConfirmedPage(
        onSignIn: () async {
          // This browser window did not see the introduction or the questions
          // (they were answered in the window of the sign-up). Skip the
          // introduction and go straight to the sign-in.
          try {
            await const DeviceIntroductionStore().complete();
            await const DevicePendingPersonalizationStore().markAccountSeen();
          } catch (_) {}
          if (!mounted) return;
          setState(() {
            _directSignInEmail = _confirmedEmail;
            _confirmedEmail = null;
          });
        },
      );
    }
    final signInEmail = _directSignInEmail;
    if (_userId == null && signInEmail != null) {
      return AuthPage(initialEmail: signInEmail);
    }
    return const IntroductionGate(
      child: QuestionsFirstGate(
        child: AuthGate(
          child: PersonalizationGate(
            child: ConsentGate(child: PaywallGate(child: AppShell())),
          ),
        ),
      ),
    );
  }
}
