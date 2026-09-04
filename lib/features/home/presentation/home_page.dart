import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitness AI')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dein persönlicher Ernährungsbegleiter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'Das neue Projekt ist eingerichtet. Als Nächstes bauen wir '
                'Onboarding, Ziele und das Ernährungstagebuch.',
              ),
              const Spacer(),
              const SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: null,
                  child: Text('Einrichtung folgt'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
