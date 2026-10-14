import 'package:fitness_ai_app/app/app.dart';
import 'package:fitness_ai_app/features/language/presentation/language_page.dart';
import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:fitness_ai_app/l10n/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => L10n.use(L10n.german));

  testWidgets('Sprachseite zeigt die Auswahl sofort in der gewählten Sprache', (
    tester,
  ) async {
    Locale? chosen;
    await tester.pumpWidget(
      MaterialApp(
        home: LanguagePage(
          initial: L10n.german,
          onChosen: (locale) async => chosen = locale,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Wähle deine Sprache'), findsOneWidget);
    expect(find.text('Weiter auf Deutsch'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-en')));
    await tester.pumpAndSettle();
    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.text('Continue in English'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-continue')));
    await tester.pumpAndSettle();
    expect(chosen, L10n.english);
  });

  testWidgets('erster Start: Sprachseite, danach die App in der Sprache', (
    tester,
  ) async {
    final store = MemoryLocaleStore();
    final locales = LocaleController(store: store, device: const Locale('fr'));
    await locales.load();
    await tester.pumpWidget(
      FitnessAiApp(useAuth: false, localeController: locales),
    );
    await tester.pumpAndSettle();
    // Not German on the device: English is suggested.
    expect(find.text('Continue in English'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-continue')));
    await tester.pumpAndSettle();
    expect(store.code, 'en');
    expect(locales.hasChoice, isTrue);
    expect(find.byType(LanguagePage), findsNothing);
    final context = tester.element(find.byType(Scaffold).first);
    expect(context.l10n.commonSave, 'Save');
    expect(MaterialLocalizations.of(context).okButtonLabel, 'OK');
    expect(L10n.code, 'en');
  });

  testWidgets('gespeicherte Sprache: keine Sprachseite beim nächsten Start', (
    tester,
  ) async {
    final locales = LocaleController(store: MemoryLocaleStore('de'));
    await locales.load();
    await tester.pumpWidget(
      FitnessAiApp(useAuth: false, localeController: locales),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LanguagePage), findsNothing);
    final context = tester.element(find.byType(Scaffold).first);
    expect(context.l10n.commonSave, 'Speichern');
  });

  testWidgets('Sprache im Profil-Blatt wechseln', (tester) async {
    final locales = LocaleController(store: MemoryLocaleStore('de'));
    await locales.load();
    await tester.pumpWidget(
      LocaleScope(
        controller: locales,
        child: ListenableBuilder(
          listenable: locales,
          builder: (context, _) => MaterialApp(
            locale: locales.locale,
            supportedLocales: L10n.supported,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Builder(
              builder: (context) => Scaffold(
                body: Column(
                  children: [
                    Text(context.l10n.languageSettingsTitle),
                    TextButton(
                      onPressed: () => showLanguageSheet(context),
                      child: const Text('open'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Sprache'), findsOneWidget);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-sheet-en')));
    await tester.pumpAndSettle();
    expect(locales.locale, L10n.english);
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('Sprachseite ohne Überlauf auf kleinem Display', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 560)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.6)),
          child: child!,
        ),
        home: LanguagePage(initial: L10n.english, onChosen: (_) async {}),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
