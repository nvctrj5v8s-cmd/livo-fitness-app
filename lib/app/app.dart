import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/state/app_controller.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../features/auth/presentation/password_recovery_page.dart';
import '../features/navigation/presentation/app_shell.dart';
import '../features/onboarding/presentation/introduction_gate.dart';
import '../features/onboarding/presentation/personalization_gate.dart';
import '../features/subscription/presentation/paywall_gate.dart';

class FitnessAiApp extends StatefulWidget {
  const FitnessAiApp({
    this.useAuth = true,
    this.initialPasswordRecovery = false,
    super.key,
  });

  final bool useAuth;
  final bool initialPasswordRecovery;

  @override
  State<FitnessAiApp> createState() => _FitnessAiAppState();
}

class _FitnessAiAppState extends State<FitnessAiApp> {
  late AppController _controller;
  StreamSubscription<AuthState>? _authSubscription;
  String? _userId;
  bool _passwordRecovery = false;

  @override
  void initState() {
    super.initState();
    _userId = widget.useAuth
        ? Supabase.instance.client.auth.currentUser?.id
        : null;
    _passwordRecovery =
        widget.useAuth && widget.initialPasswordRecovery && _userId != null;
    _controller = AppController(personalizationUserId: _userId);
    if (widget.useAuth) {
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange
          .listen((event) {
            final nextUserId = event.session?.user.id;
            if (!mounted) return;
            if (event.event == AuthChangeEvent.passwordRecovery) {
              setState(() => _passwordRecovery = nextUserId != null);
            } else if (event.event == AuthChangeEvent.signedOut) {
              setState(() => _passwordRecovery = false);
            }
            if (nextUserId == _userId) return;
            final previous = _controller;
            setState(() {
              _userId = nextUserId;
              _controller = AppController(personalizationUserId: nextUserId);
            });
            previous.dispose();
          });
    }
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
        title: 'LIVO – Ernährung',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.dark,
        // The demo/test mode without account skips all gates, including the
        // paywall; premium features stay locked there.
        home: widget.useAuth
            ? _passwordRecovery && _userId != null
                  ? const PasswordRecoveryPage()
                  : const IntroductionGate(
                      child: AuthGate(
                        child: PersonalizationGate(
                          child: PaywallGate(child: AppShell()),
                        ),
                      ),
                    )
            : const AppShell(),
      ),
    );
  }
}
