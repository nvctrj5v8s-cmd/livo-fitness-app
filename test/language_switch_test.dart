import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/auth/presentation/auth_page.dart';
import 'package:fitness_ai_app/features/language/presentation/language_switch.dart';
import 'package:fitness_ai_app/features/onboarding/data/introduction_store.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/introduction_gate.dart';
import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:fitness_ai_app/l10n/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _OpenStore implements IntroductionStore {
  @override
  Future<bool> isComplete() async => false;

  @override
  Future<void> complete() async {}
}

Widget _app(LocaleController locales, Widget home) => LocaleScope(
  controller: locales,
  child: ListenableBuilder(
    listenable: locales,
    builder: (context, _) {
      L10n.use(locales.locale);
      return MaterialApp(
        theme: AppTheme.dark,
        locale: locales.locale,
        supportedLocales: L10n.supported,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: home,
      );
    },
  ),
);

void main() {
  tearDown(() => L10n.use(L10n.german));

  testWidgets('ohne Sprach-Steuerung zeigt der Schalter nichts', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LanguageSwitch())),
    );
    expect(find.byKey(const Key('language-switch-en')), findsNothing);
  });

  for (final width in [320.0, 390.0]) {
    testWidgets('Einführung bei ${width.toInt()} px: Sprache per Schalter '
        'wechseln, ohne Überlauf', (tester) async {
      tester.view
        ..physicalSize = Size(width, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final store = MemoryLocaleStore('de');
      final locales = LocaleController(store: store);
      addTearDown(locales.dispose);
      await locales.load();
      await tester.pumpWidget(
        _app(
          locales,
          IntroductionGate(
            store: _OpenStore(),
            child: const Scaffold(body: Text('app')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Überspringen'), findsOneWidget);
      await tester.tap(find.byKey(const Key('language-switch-en')));
      await tester.pumpAndSettle();
      expect(locales.locale, L10n.english);
      expect(store.code, 'en');
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Überspringen'), findsNothing);

      await tester.tap(find.byKey(const Key('language-switch-de')));
      await tester.pumpAndSettle();
      expect(locales.locale, L10n.german);
      expect(find.text('Überspringen'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(1280, 800),
  ]) {
    testWidgets('Anmeldung bei ${size.width.toInt()} px: Schalter sichtbar, '
        'Sprache wechselt sofort', (tester) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final locales = LocaleController(store: MemoryLocaleStore('de'));
      addTearDown(locales.dispose);
      await locales.load();
      await tester.pumpWidget(
        _app(locales, const AuthPage(startWithSignUp: true)),
      );
      await tester.pumpAndSettle();

      final switchBox = tester.getRect(find.byType(LanguageSwitch));
      expect(
        Rect.fromLTWH(0, 0, size.width, size.height).contains(switchBox.center),
        isTrue,
      );
      expect(find.text('Kostenlos starten'), findsWidgets);
      await tester.tap(find.byKey(const Key('language-switch-en')));
      await tester.pumpAndSettle();
      expect(find.text('Get started for free'), findsWidgets);
      expect(find.text('Kostenlos starten'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
