import 'package:fitness_ai_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starter page is visible', (tester) async {
    await tester.pumpWidget(const FitnessAiApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('LIVO'), findsOneWidget);
    expect(find.text('Guten Morgen 👋'), findsOneWidget);
    expect(find.text('Heute'), findsOneWidget);
  });

  testWidgets('all main areas can be opened', (tester) async {
    await tester.pumpWidget(const FitnessAiApp());
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Tagebuch'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Ernährung'), findsOneWidget);

    await tester.tap(find.text('Entdecken'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Heute für dich'), findsOneWidget);

    await tester.tap(find.text('Coach'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('LIVO Coach'), findsOneWidget);

    await tester.tap(find.text('Fortschritt'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Gewichtstrend'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
