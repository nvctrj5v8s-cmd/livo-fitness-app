import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/introduction_page.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/personalization_page.dart';
import 'package:fitness_ai_app/features/profile/presentation/demo_replay.dart';
import 'package:fitness_ai_app/features/subscription/data/developer_repository.dart';
import 'package:fitness_ai_app/features/subscription/data/subscription_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/recipe_fixtures.dart';

class _Developer implements DeveloperRepository {
  _Developer({required this.developer});
  final bool developer;

  @override
  Future<bool> isDeveloper() async => developer;

  @override
  Future<void> setPremium(bool enabled) async {}
}

void main() {
  test('only the developer with premium switched on sees the replay', () async {
    Future<AppController> controller({
      required bool developer,
      required bool premium,
    }) async {
      final app = AppController(
        developerRepository: _Developer(developer: developer),
        subscriptionRepository: premium
            ? const PlusSubscriptionRepository()
            : const PreviewSubscriptionRepository(),
      );
      await app.loadDeveloperStatus();
      await app.subscription.load();
      return app;
    }

    final on = await controller(developer: true, premium: true);
    final off = await controller(developer: true, premium: false);
    final other = await controller(developer: false, premium: true);
    addTearDown(on.dispose);
    addTearDown(off.dispose);
    addTearDown(other.dispose);
    expect(on.showsDemoReplay, isTrue);
    expect(off.showsDemoReplay, isFalse);
    expect(other.showsDemoReplay, isFalse);
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
