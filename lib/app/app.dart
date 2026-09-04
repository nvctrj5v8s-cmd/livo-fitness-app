import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/navigation/presentation/app_shell.dart';

class FitnessAiApp extends StatelessWidget {
  const FitnessAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIVO – Ernährung & Fitness',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}
