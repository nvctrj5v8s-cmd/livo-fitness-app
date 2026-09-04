import 'package:fitness_ai_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('startet im dunklen Heute-Bereich mit persönlicher Übersicht', (
    tester,
  ) async {
    await _pumpApp(tester);

    final scaffoldContext = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(scaffoldContext).brightness, Brightness.dark);
    expect(find.text('Hallo, Alex'), findsOneWidget);
    expect(find.text('Heute gegessen'), findsOneWidget);
    expect(find.text('5/8 Wasser'), findsOneWidget);
  });

  testWidgets('alle Hauptbereiche sind über die Navigation erreichbar', (
    tester,
  ) async {
    await _pumpApp(tester);

    await _openTab(tester, 'Tagebuch');
    expect(
      find.text('Deine Mahlzeiten klar und ohne unnötigen Aufwand.'),
      findsOneWidget,
    );

    await _openTab(tester, 'Rezepte');
    expect(find.text('Planen & vorbereiten'), findsOneWidget);

    await _openTab(tester, 'Fortschritt');
    expect(find.text('Ernährungs-Balance'), findsOneWidget);

    await _openTab(tester, 'Profil');
    expect(find.text('Meine Ziele'), findsOneWidget);

    await _openTab(tester, 'Heute');
    expect(find.text('Hallo, Alex'), findsOneWidget);
  });

  testWidgets('Wasser-Tracking aktualisiert den lokalen Zustand', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('5/8 Wasser'));
    await tester.pumpAndSettle();

    expect(find.text('5/8 Wasser'), findsNothing);
    expect(find.text('6/8 Wasser'), findsOneWidget);

    await _openTab(tester, 'Tagebuch');
    expect(find.text('6 von 8 Gläsern'), findsOneWidget);
  });

  testWidgets('Mahlzeitensuche fügt einen Eintrag zum Tagebuch hinzu', (
    tester,
  ) async {
    await _pumpApp(tester);

    await _openTab(tester, 'Tagebuch');
    await tester.tap(find.byTooltip('Mahlzeit hinzufügen').first);
    await tester.pumpAndSettle();

    expect(
      find.text('Lokale Demo-Suche – funktioniert bereits ohne Konto.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField).last, 'Hähnchen-Reis-Bowl');
    await tester.pump();
    await tester.tap(find.widgetWithText(ListTile, 'Hähnchen-Reis-Bowl'));
    await tester.pumpAndSettle();

    expect(find.text('Hähnchen-Reis-Bowl'), findsOneWidget);
    expect(find.textContaining('1800'), findsOneWidget);
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
    await tester.tap(find.text('Vegetarisch'));
    await tester.tap(find.text('Ernährungsprofil speichern'));
    await tester.pumpAndSettle();
    expect(find.text('Vegetarisch'), findsOneWidget);
  });

  testWidgets('Desktop-Navigation rendert ohne Layoutfehler', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(const FitnessAiApp());
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

  await tester.pumpWidget(const FitnessAiApp());
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
