import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/state/app_controller.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../features/navigation/presentation/app_shell.dart';
import '../features/onboarding/presentation/introduction_gate.dart';
import '../features/onboarding/presentation/personalization_gate.dart';

class FitnessAiApp extends StatefulWidget {
  const FitnessAiApp({this.useAuth = true, super.key});

  final bool useAuth;

  @override
  State<FitnessAiApp> createState() => _FitnessAiAppState();
}

class _FitnessAiAppState extends State<FitnessAiApp> {
  late AppController _controller;
  StreamSubscription<AuthState>? _authSubscription;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = widget.useAuth
        ? Supabase.instance.client.auth.currentUser?.id
        : null;
    _controller = AppController(personalizationUserId: _userId);
    if (widget.useAuth) {
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange
          .listen((event) {
            final nextUserId = event.session?.user.id;
            if (!mounted || nextUserId == _userId) return;
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
        home: widget.useAuth
            ? const IntroductionGate(
                child: AuthGate(child: PersonalizationGate(child: AppShell())),
              )
            : const AppShell(),
      ),
    );
  }
}
