import 'package:fitness_ai_app/features/auth/presentation/email_status_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  layoutTests();
  testWidgets(
    'Postfach-Seite: erneut senden erst nach Wartezeit, zurück geht',
    (tester) async {
      var back = 0;
      var resent = 0;
      Widget page(int cooldown) => MaterialApp(
        home: CheckInboxPage(
          email: 'max@beispiel.de',
          resendCooldown: cooldown,
          loading: false,
          onResend: () => resent++,
          onSignIn: () {},
          onBack: () => back++,
        ),
      );

      await tester.pumpWidget(page(42));
      expect(find.text('Schau in dein Postfach'), findsOneWidget);
      expect(find.text('Erneut senden in 42 s'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('inbox-resend')),
        warnIfMissed: false,
      );
      expect(resent, 0);

      await tester.pumpWidget(page(0));
      await tester.ensureVisible(find.byKey(const Key('inbox-resend')));
      await tester.tap(find.byKey(const Key('inbox-resend')));
      expect(resent, 1);

      await tester.tap(find.byKey(const Key('status-back')));
      expect(back, 1);
    },
  );

  testWidgets('Bestätigt-Seite führt zur Anmeldung', (tester) async {
    var signIn = 0;
    await tester.pumpWidget(
      MaterialApp(home: EmailConfirmedPage(onSignIn: () => signIn++)),
    );
    await tester.pumpAndSettle();
    expect(find.text('E-Mail bestätigt'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('confirmed-sign-in')));
    await tester.tap(find.byKey(const Key('confirmed-sign-in')));
    expect(signIn, 1);
  });
}

void layoutTests() {
  for (final scale in const [1.0, 2.0]) {
    testWidgets('Postfach-Seite ohne Überlauf bei 320 px, Schrift x$scale', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(320, 640)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: CheckInboxPage(
            email: 'ein.sehr.langer.name@beispiel-domain.de',
            resendCooldown: 30,
            loading: false,
            message:
                'Falls die Adresse noch nicht bestätigt ist, '
                'haben wir dir eine neue Bestätigungs-Mail geschickt.',
            onResend: () {},
            onSignIn: () {},
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
