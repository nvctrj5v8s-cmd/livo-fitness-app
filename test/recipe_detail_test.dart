import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/discover/domain/recipe_serving.dart';
import 'package:fitness_ai_app/features/discover/presentation/cook_mode_page.dart';
import 'package:fitness_ai_app/features/discover/presentation/kitchen_format.dart';
import 'package:fitness_ai_app/features/discover/presentation/recipe_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/recipe_fixtures.dart';

Future<void> _pumpDetail(
  WidgetTester tester,
  AppController controller, {
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  setTestScreen(tester, size, textScale: textScale);
  await tester.pumpWidget(
    recipeTestApp(controller, const RecipeDetailPage(recipe: curryRecipe)),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Freies Konto: ausführliche Schritte, volle Nährwerte, '
      'ein Hinweis statt Plus-Inhalten', (tester) async {
    final controller = await recipeTestController(plus: false);
    await _pumpDetail(tester, controller);

    expect(find.text('Kichererbsen-Curry mit Spinat'), findsWidgets);
    for (final step in curryRecipe.steps) {
      expect(find.text(step.title!), findsOneWidget);
      expect(find.text(step.text), findsOneWidget);
    }
    expect(find.text('Gesamtzeit'), findsOneWidget);
    expect(find.text('Vorbereitung'), findsOneWidget);
    expect(find.text('Großer Topf mit Deckel'), findsOneWidget);
    expect(find.text('fein gewürfelt'), findsOneWidget);
    expect(find.text('Ballaststoffe'), findsOneWidget);
    expect(find.text('12 g'), findsOneWidget);
    expect(find.text('1,4 g'), findsOneWidget);

    expect(find.byKey(const Key('recipe-plus-teaser')), findsOneWidget);
    expect(find.byKey(const Key('recipe-plus-area')), findsNothing);
    expect(find.byKey(const Key('cook-mode-start')), findsNothing);
    expect(find.byKey(const Key('goal-open')), findsNothing);
    // The teaser may name the benefit, but no actual step tip is shown.
    expect(find.textContaining('Profi-Tipp:'), findsNothing);
    expect(find.text('Darauf achten'), findsNothing);
    expect(find.textContaining(curryTips.first), findsNothing);
    expect(find.text('Woher kommen die Nährwerte?'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Freies Konto: Portionsrechner rechnet Mengen um', (
    tester,
  ) async {
    final controller = await recipeTestController(plus: false);
    await _pumpDetail(tester, controller);

    expect(find.text('240 g'), findsOneWidget);
    expect(find.text('1 EL'), findsOneWidget);
    await _tapVisible(tester, find.byTooltip('Eine Portion mehr'));
    expect(find.text('360 g'), findsOneWidget);
    expect(find.text('1½ EL'), findsOneWidget);
    expect(find.text('1½ Dosen'), findsOneWidget);
    expect(find.text('Original: 2 Portionen'), findsOneWidget);

    await _tapVisible(tester, find.byKey(const Key('nutrition-total')));
    expect(find.text('1.620 kcal'), findsOneWidget);

    await _tapVisible(tester, find.text('Originalmenge'));
    expect(find.text('240 g'), findsOneWidget);
    expect(find.text('540 kcal'), findsOneWidget);
  });

  testWidgets('Freies Konto: Ziel-Funktion erklärt Plus ohne Druck', (
    tester,
  ) async {
    final controller = await recipeTestController(plus: false);
    await _pumpDetail(tester, controller);

    await _tapVisible(tester, find.byKey(const Key('goal-locked')));
    expect(find.byKey(const Key('goal-locked-dismiss')), findsOneWidget);
    expect(find.byKey(const Key('goal-locked-open')), findsOneWidget);
    final dismiss = tester.getSize(
      find.byKey(const Key('goal-locked-dismiss')),
    );
    final open = tester.getSize(find.byKey(const Key('goal-locked-open')));
    expect(dismiss.width, closeTo(open.width, 1));
    expect(dismiss.height, closeTo(open.height, 1));

    await tester.tap(find.byKey(const Key('goal-locked-dismiss')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('goal-locked-dismiss')), findsNothing);
    expect(find.byType(RecipeDetailPage), findsOneWidget);
  });

  testWidgets('Plus-Konto: Profi-Tipps, Wissensblöcke und Ziel-Vorschlag', (
    tester,
  ) async {
    final controller = await recipeTestController(plus: true);
    await _pumpDetail(tester, controller);

    expect(find.byKey(const Key('recipe-plus-teaser')), findsNothing);
    expect(find.byKey(const Key('goal-locked')), findsNothing);
    expect(find.byKey(const Key('recipe-plus-area')), findsOneWidget);
    for (final tip in curryTips.where((tip) => tip.isNotEmpty)) {
      expect(find.textContaining(tip), findsOneWidget);
    }
    expect(find.text('Darauf achten'), findsOneWidget);
    expect(find.text('Die Kokosmilch sprudelnd kochen lassen.'), findsOneWidget);

    expect(find.text('Spinat durch Grünkohl ersetzen.'), findsNothing);
    await _tapVisible(tester, find.text('Austausch-Möglichkeiten'));
    expect(find.text('Spinat durch Grünkohl ersetzen.'), findsOneWidget);
    expect(find.text('Meal-Prep & Aufbewahrung'), findsOneWidget);
    expect(find.text('Variationen'), findsOneWidget);
    expect(find.text('Serviervorschlag'), findsOneWidget);
    await _tapVisible(tester, find.text('Woher kommen die Nährwerte?'));
    expect(find.textContaining('Zutat hat keine Katalogwerte'), findsNothing);
    expect(find.textContaining('2 Zutaten haben'), findsOneWidget);

    await _tapVisible(tester, find.byTooltip('Eine Portion mehr'));
    expect(find.text('360 g'), findsOneWidget);

    final expected = suggestPortion(
      caloriesPerPortion: curryRecipe.nutrition.calories,
      calorieGoal: controller.calorieGoal,
      consumedCalories: controller.consumedCalories,
      mealsPerDay: 3,
      mealsLogged: {for (final meal in controller.meals) meal.slot}.length,
    )!;
    await _tapVisible(tester, find.byKey(const Key('goal-open')));
    expect(find.text('VORSCHLAG · SCHÄTZUNG'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('goal-suggestion-apply')));
    await tester.tap(find.byKey(const Key('goal-suggestion-apply')));
    await tester.pumpAndSettle();
    final value = tester.widget<Text>(
      find.byKey(const Key('recipe-portions-value')),
    );
    expect(value.data, formatFractionDe(expected.factor));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kochmodus öffnet bei Schritt 1 und stoppt Timer beim Verlassen', (
    tester,
  ) async {
    final controller = await recipeTestController(plus: true);
    await _pumpDetail(tester, controller);

    await _tapVisible(tester, find.byKey(const Key('cook-mode-start')));
    expect(find.text('Schritt 1 von 6'), findsOneWidget);
    expect(find.text('Zwiebel anschwitzen'), findsOneWidget);
    expect(find.textContaining(curryTips.first), findsOneWidget);
    expect(find.text('Timer starten'), findsOneWidget);

    await tester.tap(find.byKey(const Key('cook-timer-toggle')));
    await tester.pump();
    expect(find.text('Pausieren'), findsOneWidget);
    expect(find.text('Läuft'), findsOneWidget);

    await tester.tap(find.byKey(const Key('cook-next')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Schritt 2 von 6'), findsOneWidget);
    expect(find.text('Gewürze rösten'), findsOneWidget);
    expect(find.textContaining('Schritt 1 ·'), findsOneWidget);

    await tester.tap(find.byKey(const Key('cook-close')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Kochmodus beenden?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cook-leave-confirm')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(CookModePage), findsNothing);
    expect(find.byType(RecipeDetailPage), findsOneWidget);
  });

  testWidgets('Kochmodus-Timer zählt herunter, pausiert und meldet das Ende', (
    tester,
  ) async {
    setTestScreen(tester, const Size(390, 844));
    var now = DateTime(2026, 9, 27, 18);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: CookModePage(
          recipe: curryRecipe,
          details: curryRecipe.premiumDetails,
          clock: () => now,
        ),
      ),
    );
    await tester.pumpAndSettle();
    Text timerValue() =>
        tester.widget<Text>(find.byKey(const Key('cook-timer-value')));
    expect(timerValue().data, '04:00');

    await tester.tap(find.byKey(const Key('cook-timer-toggle')));
    await tester.pump();
    now = now.add(const Duration(minutes: 1, seconds: 30));
    await tester.pump(const Duration(milliseconds: 600));
    expect(timerValue().data, '02:30');

    await tester.tap(find.byKey(const Key('cook-timer-toggle')));
    await tester.pump();
    expect(find.text('Pausiert'), findsOneWidget);
    now = now.add(const Duration(minutes: 5));
    await tester.pump(const Duration(milliseconds: 600));
    expect(timerValue().data, '02:30');

    await tester.tap(find.byKey(const Key('cook-timer-toggle')));
    await tester.pump();
    now = now.add(const Duration(minutes: 3));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Zeit ist um!'), findsOneWidget);
    expect(timerValue().data, '00:00');
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Die Zeit für Schritt 1 ist um.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('cook-timer-reset')));
    await tester.pump();
    expect(timerValue().data, '04:00');
    expect(find.text('Timer starten'), findsOneWidget);
  });

  for (final (label, size, textScale, plus) in [
    ('360 px frei', const Size(360, 780), 1.0, false),
    ('360 px Plus', const Size(360, 780), 1.0, true),
    ('360 px große Schrift', const Size(360, 780), 1.8, true),
    ('1280 px Plus', const Size(1280, 900), 1.0, true),
    ('1280 px frei', const Size(1280, 900), 1.0, false),
  ]) {
    testWidgets('Rezeptdetail ohne Layoutfehler: $label', (tester) async {
      final controller = await recipeTestController(plus: plus);
      await _pumpDetail(tester, controller, size: size, textScale: textScale);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -4000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('recipe-add-diary')), findsOneWidget);
      if (plus) {
        await _tapVisible(tester, find.byKey(const Key('cook-mode-start')));
        expect(tester.takeException(), isNull);
        expect(find.text('Schritt 1 von 6'), findsOneWidget);
      }
    });
  }

  testWidgets('1 Portion wird mit gewählter Mahlzeit eingetragen', (
    tester,
  ) async {
    final controller = await recipeTestController(plus: false);
    await _pumpDetail(tester, controller);
    final before = controller.meals.length;

    expect(find.text('1 Portion zum Tagebuch'), findsOneWidget);
    await tester.tap(find.byKey(const Key('recipe-add-diary')));
    await tester.pumpAndSettle();
    expect(find.text('Zu welcher Mahlzeit?'), findsOneWidget);
    expect(find.text('Vorschlag'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('meal-slot-lunch')));
    await tester.pumpAndSettle();

    expect(controller.meals.length, before + 1);
    expect(controller.meals.last.name, curryRecipe.title);
    expect(controller.meals.last.calories, 540);
    expect(find.textContaining('Mittagessen'), findsOneWidget);
  });

  testWidgets('Fehlende Zutaten landen auf der lokalen Einkaufsliste', (
    tester,
  ) async {
    final controller = await recipeTestController(plus: false);
    await _pumpDetail(tester, controller);
    final before = controller.planning.shopping.length;

    await _tapVisible(tester, find.byKey(const ValueKey('ingredient-0')));
    expect(find.text('3 fehlende Zutaten auf die Einkaufsliste'), findsOneWidget);
    await _tapVisible(tester, find.byKey(const Key('recipe-add-shopping')));

    final added = controller.planning.shopping.skip(before).toList();
    expect(added.map((item) => item.name), [
      'Olivenöl',
      'Zwiebel',
      'Babyspinat',
    ]);
    expect(
      kitchenAmountLabel(added.first.amount, added.first.note),
      '1 EL · 10 g',
    );
    expect(added.first.source, curryRecipe.title);
    expect(find.textContaining('bis zum Neustart'), findsOneWidget);
  });
}
