import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/state/app_controller.dart';
import '../core/theme/app_theme.dart';
import '../features/consent/presentation/consent_gate.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../features/auth/presentation/auth_page.dart';
import '../features/auth/presentation/email_status_pages.dart';
import '../features/auth/data/recovery_marker.dart';
import '../features/auth/presentation/password_recovery_page.dart';
import '../features/navigation/presentation/app_shell.dart';
import '../features/onboarding/data/introduction_store.dart';
import '../features/onboarding/data/personalization_store.dart';
import '../features/onboarding/presentation/introduction_gate.dart';
import '../features/onboarding/presentation/personalization_gate.dart';
import '../features/onboarding/presentation/questions_first_gate.dart';
import '../features/subscription/presentation/paywall_gate.dart';

class FitnessAiApp extends StatefulWidget {
  const FitnessAiApp({
    this.useAuth = true,
    this.initialPasswordRecovery = false,
    this.initialNotice,
    this.initialConfirmedEmail,
    super.key,
  });

  final bool useAuth;
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

  @override
  void dispose() {
    _authSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: _controller,
      child: MaterialApp(
        key: ValueKey(_userId ?? 'signed-out-preview'),
        scaffoldMessengerKey: _messenger,
        title: 'Lookin – Ernährung',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.dark,
        // The demo/test mode without account skips all gates, including the
        // paywall; premium features stay locked there.
        home: widget.useAuth ? _authHome() : const AppShell(),
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
