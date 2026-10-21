import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/onboarding/data/age_store.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/age_gate.dart';
import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryAgeStore implements AgeStore {
  _MemoryAgeStore({this.confirmed = false});

  bool confirmed;

  @override
  Future<bool> isConfirmed() async => confirmed;

  @override
  Future<void> confirm() async => confirmed = true;
}

Future<void> _pump(
  WidgetTester tester,
  AgeStore store, {
  Locale locale = const Locale('de'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      locale: locale,
      supportedLocales: L10n.supported,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: AgeGate(
        store: store,
        child: const Scaffold(body: Center(child: Text('Weiter in der App'))),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => L10n.use(L10n.german));

  testWidgets('Ja öffnet die App und wird gemerkt', (tester) async {
    final store = _MemoryAgeStore();
    await _pump(tester, store);
    expect(find.text('Bist du mindestens 18 Jahre alt?'), findsOneWidget);
    expect(find.text('Weiter in der App'), findsNothing);

    await tester.tap(find.byKey(const Key('age-yes')));
    await tester.pumpAndSettle();
    expect(find.text('Weiter in der App'), findsOneWidget);
    expect(store.confirmed, isTrue);
  });

  testWidgets('Nein sperrt die App und speichert nichts', (tester) async {
    final store = _MemoryAgeStore();
    await _pump(tester, store);
    await tester.tap(find.byKey(const Key('age-no')));
    await tester.pumpAndSettle();
    expect(find.text('Lookin ist erst ab 18'), findsOneWidget);
    expect(find.text('Weiter in der App'), findsNothing);
    expect(find.byKey(const Key('age-yes')), findsNothing);
    expect(store.confirmed, isFalse);
  });

  testWidgets('bestätigtes Alter fragt nicht noch einmal', (tester) async {
    await _pump(tester, _MemoryAgeStore(confirmed: true));
    expect(find.text('Weiter in der App'), findsOneWidget);
    expect(find.byKey(const Key('age-yes')), findsNothing);
  });

  testWidgets('Englisch bei 320 px und großer Schrift ohne Überlauf', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pump(tester, _MemoryAgeStore(), locale: L10n.english);
    expect(find.text('Are you at least 18 years old?'), findsOneWidget);
    expect(find.text('Yes, I am at least 18'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
