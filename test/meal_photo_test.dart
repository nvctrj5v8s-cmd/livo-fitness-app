import 'package:fitness_ai_app/core/data/ai_coach_service.dart';
import 'package:fitness_ai_app/core/models/app_models.dart';
import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/diary/presentation/meal_photo_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image_lib;

const _rice = AiMealPhotoItem(
  name: 'Reis',
  amountGrams: 100,
  calories: 130,
  protein: 2.7,
  carbohydrates: 28,
  fat: 0.3,
  confidence: 'medium',
);

void main() {
  group('MealItemDraft', () {
    test('Menge ändern rechnet Kalorien und Makros mit', () {
      final item = MealItemDraft.fromAi(_rice);
      item.amount.text = '200';
      item.amountEdited();
      expect(item.value(item.calories), 260);
      expect(item.value(item.carbohydrates), 56);
      expect(item.value(item.protein), 5.4);
      item.changeAmountBy(-10);
      expect(item.grams, 190);
      expect(item.value(item.calories), 247);
      item.dispose();
    });

    test('eigene Nährwerte gelten danach als neue Basis', () {
      final item = MealItemDraft.empty();
      item.calories.text = '50';
      item.nutrientEdited();
      item.amount.text = '50';
      item.amountEdited();
      expect(item.value(item.calories), 25);
      item.dispose();
    });

    test('ohne Namen oder mit ungültiger Menge wird nicht gespeichert', () {
      final item = MealItemDraft.empty();
      expect(item.problem(), isNotNull);
      item.name.text = 'Apfel';
      item.amount.text = '0';
      expect(item.problem(), contains('Menge'));
      item.amount.text = '120';
      expect(item.problem(), isNull);
      item.dispose();
    });
  });

  testWidgets('Ergebnisseite: Menge, Mahlzeit und eigener Eintrag', (
    tester,
  ) async {
    await _pumpPage(tester, const Size(390, 844));
    expect(find.text('Deine Mahlzeit'), findsOneWidget);
    expect(find.text('KI-Schätzung'), findsOneWidget);
    expect(find.text('Reis'), findsOneWidget);
    expect(find.text('Bitte kurz prüfen'), findsOneWidget);
    expect(
      find.textContaining('Zu Mittagessen hinzufügen · 130 kcal'),
      findsOneWidget,
    );

    await _center(tester, find.byTooltip('10 g mehr'));
    await tester.tap(find.byTooltip('10 g mehr'));
    await tester.pump();
    expect(find.textContaining('· 143 kcal'), findsOneWidget);

    await _center(tester, find.byKey(const ValueKey('photo-slot-breakfast')));
    await tester.tap(find.byKey(const ValueKey('photo-slot-breakfast')));
    await tester.pump();
    expect(find.textContaining('Zu Frühstück hinzufügen'), findsOneWidget);

    await _center(tester, find.byKey(const Key('photo-add-food')));
    await tester.tap(find.byKey(const Key('photo-add-food')));
    await tester.pump();
    expect(find.text('Neues Lebensmittel'), findsOneWidget);
    expect(find.text('Eigener Eintrag'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ergebnisseite bleibt auf kleinem Display stabil', (
    tester,
  ) async {
    await _pumpPage(tester, const Size(320, 568), textScale: 1.5);
    await _center(tester, find.text('Reis'));
    await tester.tap(find.text('Reis'));
    await tester.pump();
    expect(find.text('Entfernen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  Size size, {
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final photo = Uint8List.fromList(
    image_lib.encodePng(image_lib.Image(width: 4, height: 4)),
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: MealPhotoPage(
          initialSlot: MealSlot.lunch,
          initialPhoto: photo,
          initialItems: const [_rice],
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _center(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pump();
}
