import 'package:fitness_ai_app/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starter page is visible', (tester) async {
    await tester.pumpWidget(const FitnessAiApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Bereit für deinen Tag?'), findsOneWidget);
    expect(find.text('Heute'), findsOneWidget);
  });
}
