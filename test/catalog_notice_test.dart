import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/consent/data/consent_repository.dart';
import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:fitness_ai_app/shared/widgets/catalog_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/recipe_fixtures.dart';

Widget _host(AppController controller, Locale locale) => AppScope(
  controller: controller,
  child: MaterialApp(
    theme: AppTheme.dark,
    locale: locale,
    supportedLocales: L10n.supported,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: const Scaffold(body: Center(child: CatalogUnavailableNotice())),
  ),
);

AppController _signedIn() {
  final controller = AppController(
    personalizationUserId: 'user-a',
    consentRepository: MemoryConsentRepository(),
  );
  addTearDown(controller.dispose);
  return controller;
}

void main() {
  tearDown(() => L10n.use(L10n.german));

  testWidgets('Katalog nicht erreichbar: Hinweis und Erneut laden', (
    tester,
  ) async {
    final controller = _signedIn();
    // Supabase is not initialised in tests, so the load fails like offline.
    await controller.loadRemoteCatalog();
    expect(controller.catalogFailed, isTrue);
    expect(controller.catalogLoading, isFalse);

    await tester.pumpWidget(_host(controller, L10n.german));
    expect(find.byKey(const Key('catalog-notice')), findsOneWidget);
    expect(find.textContaining('Katalog konnte nicht geladen'), findsOneWidget);
    expect(find.text('Erneut laden'), findsOneWidget);

    await tester.tap(find.byKey(const Key('catalog-reload')));
    await tester.pumpAndSettle();
    // The reload fails again here; the button is usable again afterwards.
    expect(controller.catalogLoading, isFalse);
    expect(find.byKey(const Key('catalog-reload')), findsOneWidget);
  });

  testWidgets('Demo ohne Konto: kein Hinweis', (tester) async {
    final controller = await recipeTestController(plus: false);
    addTearDown(controller.dispose);
    await controller.loadRemoteCatalog();
    expect(controller.catalogFailed, isFalse);
    await tester.pumpWidget(_host(controller, L10n.german));
    expect(find.byKey(const Key('catalog-notice')), findsNothing);
  });

  testWidgets('Englisch bei 320 px und großer Schrift ohne Überlauf', (
    tester,
  ) async {
    setTestScreen(tester, const Size(320, 568), textScale: 1.6);
    final controller = _signedIn();
    await controller.loadRemoteCatalog();
    await tester.pumpWidget(_host(controller, L10n.english));
    expect(find.textContaining('catalog could not be loaded'), findsOneWidget);
    expect(find.text('Reload'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
