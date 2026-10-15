import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import 'auth_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            auth.currentSession == null) {
          return const _AuthLoading();
        }
        final signedIn = auth.currentSession != null;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 430),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.985, end: 1.0).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(auth.currentUser?.id ?? 'signed-out'),
            child: signedIn ? child : const AuthPage(),
          ),
        );
      },
    );
  }
}

class _AuthLoading extends StatelessWidget {
  const _AuthLoading();

  // Only the dark background, so nothing flashes after the start animation
  // while the session is restored.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('auth-loading'),
      backgroundColor: AppColors.background,
      body: Semantics(
        label: context.l10n.authCheckingYourSignIn,
        child: const SizedBox.expand(),
      ),
    );
  }
}
