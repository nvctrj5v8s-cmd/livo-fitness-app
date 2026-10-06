import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/introduction_page.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/personalization_page.dart';
import 'package:fitness_ai_app/features/profile/presentation/demo_replay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nur das Demo-Konto wird erkannt', () {
    expect(isDemoAccountEmail('mohammad.shikho999@icloud.com'), isTrue);
    expect(isDemoAccountEmail('  Mohammad.Shikho999@iCloud.com '), isTrue);
    expect(isDemoAccountEmail('anderer@icloud.com'), isFalse);
    expect(isDemoAccountEmail(''), isFalse);
    expect(isDemoAccountEmail(null), isFalse);
  });

  test('ohne Backend ist der Demo-Knopf aus', () {
    expect(isDemoAccountSignedIn(), isFalse);
  });

  testWidgets('Replay zeigt Einführung, Fragen und Premium und schließt', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 900);
    addTearDown(tester.view.reset);
    final controller = AppController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDemoReplay(context),
                child: const Text('start'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('start'));
    await tester.pumpAndSettle();
    expect(find.byType(IntroductionPage), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('intro-skip')));
    await tester.pumpAndSettle();
    expect(find.byType(PersonalizationPage), findsOneWidget);
    expect(find.byType(IntroductionPage), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
