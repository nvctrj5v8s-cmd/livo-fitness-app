import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';
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
            key: ValueKey(signedIn),
            child: signedIn ? child : const AuthPage(),
          ),
        );
      },
    );
  }
}

class _AuthLoading extends StatelessWidget {
  const _AuthLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackdrop(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.82, end: 1),
            duration: const Duration(milliseconds: 620),
            curve: Curves.easeOutBack,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: Opacity(opacity: value.clamp(0, 1), child: child),
            ),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.mint],
                ),
                borderRadius: BorderRadius.circular(23),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: AppColors.black,
                size: 34,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
