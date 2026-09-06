import 'package:flutter/material.dart';

import '../core/state/app_controller.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../features/navigation/presentation/app_shell.dart';

class FitnessAiApp extends StatefulWidget {
  const FitnessAiApp({this.useAuth = true, super.key});

  final bool useAuth;

  @override
  State<FitnessAiApp> createState() => _FitnessAiAppState();
}

class _FitnessAiAppState extends State<FitnessAiApp> {
  final AppController _controller = AppController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: _controller,
      child: MaterialApp(
        title: 'LIVO – Ernährung',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.dark,
        home: widget.useAuth
            ? const AuthGate(child: AppShell())
            : const AppShell(),
      ),
    );
  }
}
