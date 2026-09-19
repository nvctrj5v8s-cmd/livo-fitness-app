import 'package:fitness_ai_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('startet im ruhigen dunklen Tagebuch mit vier Mahlzeiten', (
    tester,
  ) async {
    await _pumpApp(tester);
    final scaffoldContext = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(scaffoldContext).brightness, Brightness.dark);
    expect(find.text('Hallo, Alex'), findsOneWidget);
    expect(find.text('Dein Tag'), findsOneWidget);
    for (final title in ['Frühstück', 'Mittagessen', 'Abendessen', 'Snacks']) {
      expect(find.text(title), findsOneWidget);
    }
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('Diese Woche'), findsNothing);
  });

  testWidgets('KI ist ein eigener Hauptbereich neben dem Tagebuch', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _openTab(tester, 'KI');
    expect(find.text('LIVO Coach'), findsOneWidget);
    await _openTab(tester, 'Rezepte');
    expect(find.text('Planen & vorbereiten'), findsOneWidget);
    await _openTab(tester, 'Fortschritt');
    expect(find.text('Ernährungs-Balance'), findsOneWidget);
    await _openTab(tester, 'Profil');
    expect(find.text('Meine Ziele'), findsOneWidget);
    await _openTab(tester, 'Tagebuch');
    expect(find.text('Hallo, Alex'), findsOneWidget);
  });

  testWidgets('Frühstück öffnet die Suche bereits richtig vorausgewählt', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('add-breakfast')));
    await tester.pumpAndSettle();
    final chip = tester.widget<ChoiceChip>(
      find.byKey(const ValueKey('add-slot-breakfast')),
    );
    expect(chip.selected, isTrue);
    expect(find.text('Selbst eintragen'), findsOneWidget);
    expect(find.text('Barcode scannen'), findsOneWidget);
  });

  testWidgets('eigener Eintrag zeigt vollständige deutsche Nährwertfelder', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('add-snack')));
    await tester.tap(find.byKey(const ValueKey('add-snack')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('open-custom-food')));
    await tester.pumpAndSettle();
    expect(find.text('Dein eigenes Lebensmittel'), findsOneWidget);
    for (final key in [
      'name',
      'calories',
      'fat',
      'saturated',
      'carbs',
      'sugar',
      'protein',
      'salt',
    ]) {
      expect(find.byKey(ValueKey('custom-$key')), findsOneWidget);
    }
  });

  testWidgets('Profilbild-Editor ist über das Profil erreichbar', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _openTab(tester, 'Profil');
    await tester.tap(find.bySemanticsLabel('Profilbild ändern'));
    await tester.pumpAndSettle();
    expect(find.text('Dein Profilbild'), findsOneWidget);
    expect(find.text('Bild auswählen'), findsOneWidget);
  });

  testWidgets('Profil und Ernährungseinstellungen sind lokal bearbeitbar', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _openTab(tester, 'Profil');
    await tester.tap(find.byTooltip('Profil bearbeiten'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Alex'), 'Mina');
    await tester.ensureVisible(find.text('Änderungen übernehmen'));
    await tester.tap(find.text('Änderungen übernehmen'));
    await tester.pumpAndSettle();
    expect(find.text('Mina'), findsOneWidget);
    await tester.ensureVisible(find.text('Ausgewogen'));
    await tester.tap(find.text('Ausgewogen'));
    await tester.pumpAndSettle();
    expect(find.text('Ernährungsprofil speichern'), findsOneWidget);
  });

  testWidgets('schmales Display und große Schrift bleiben ohne Layoutfehler', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(2)),
        child: FitnessAiApp(useAuth: false),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Tagebuch'), findsOneWidget);
  });

  testWidgets('Desktop-Navigation rendert ohne Layoutfehler', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(const FitnessAiApp(useAuth: false));
    await tester.pumpAndSettle();
    expect(find.text('LIVO'), findsOneWidget);
    await tester.tap(find.text('Fortschritt'));
    await tester.pumpAndSettle();
    expect(find.text('Ernährungs-Balance'), findsOneWidget);
  });
}

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
  await tester.pumpWidget(const FitnessAiApp(useAuth: false));
  await tester.pumpAndSettle();
}

Future<void> _openTab(WidgetTester tester, String label) async {
  final destination = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );
  expect(destination, findsOneWidget);
  await tester.tap(destination);
  await tester.pumpAndSettle();
}
