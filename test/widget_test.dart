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
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Fortschritt'),
      ),
      findsNothing,
    );
    await _openTab(tester, 'Profil');
    expect(find.text('Meine täglichen Ziele'), findsOneWidget);
    await _openTab(tester, 'Tagebuch');
    expect(find.text('Hallo, Alex'), findsOneWidget);
  });

  testWidgets('Plus zwischen KI und Rezepte zeigt drei Eintragsoptionen', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.byKey(const Key('nav-quick-add')));
    await tester.pumpAndSettle();
    expect(find.text('Mahlzeit hinzufügen'), findsOneWidget);
    expect(find.byKey(const Key('quick-add-photo')), findsOneWidget);
    expect(find.byKey(const Key('quick-add-barcode')), findsOneWidget);
    expect(find.byKey(const Key('quick-add-manual')), findsOneWidget);
    expect(find.text('Hallo, Alex'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quick-add-manual')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('food-search')), findsOneWidget);
    expect(find.text('Selbst eintragen'), findsOneWidget);
  });

  testWidgets('Frühstück öffnet die Suche bereits richtig vorausgewählt', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('add-breakfast')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('add-slot-breakfast')), findsOneWidget);
    expect(find.text('Frühstück'), findsWidgets);
    expect(find.text('Selbst eintragen'), findsOneWidget);
    expect(find.text('Barcode scannen'), findsOneWidget);
    expect(find.text('Schnell hinzufügen'), findsNothing);
    expect(find.text('Zuletzt'), findsOneWidget);
    expect(find.text('Gemerkte'), findsOneWidget);
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

  testWidgets('Profil zeigt neuen Kopfbereich mit Serie und Tageswerten', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _openTab(tester, 'Profil');
    expect(find.text('Einträge heute'), findsOneWidget);
    expect(find.text('Tage Serie'), findsOneWidget);
    expect(find.text('kcal heute'), findsOneWidget);
    expect(find.text('Meine täglichen Ziele'), findsOneWidget);
    expect(find.byKey(const Key('daily-goals-answer')), findsOneWidget);
    expect(find.text('Dein Weg zum Ziel'), findsNothing);
  });

  testWidgets('Profil bleibt auf kleinem Display mit großer Schrift stabil', (
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
        data: MediaQueryData(textScaler: TextScaler.linear(1.6)),
        child: FitnessAiApp(useAuth: false),
      ),
    );
    await tester.pumpAndSettle();
    await _openTab(tester, 'Profil');
    expect(tester.takeException(), isNull);
    expect(find.text('Meine täglichen Ziele'), findsOneWidget);
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
    expect(find.text('Fortschritt'), findsNothing);
    await tester.tap(find.byKey(const Key('desktop-quick-add')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('quick-add-photo')), findsOneWidget);
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
