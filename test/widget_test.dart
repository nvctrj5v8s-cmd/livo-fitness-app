import 'package:fitness_ai_app/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starter page is visible', (tester) async {
    await tester.pumpWidget(const FitnessAiApp());

    expect(find.text('Fitness AI'), findsOneWidget);
    expect(find.text('Dein persönlicher Ernährungsbegleiter'), findsOneWidget);
  });
}
