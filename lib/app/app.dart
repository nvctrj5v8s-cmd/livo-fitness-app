import 'package:flutter/material.dart';

import '../features/home/presentation/home_page.dart';

class FitnessAiApp extends StatelessWidget {
  const FitnessAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF356859)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
