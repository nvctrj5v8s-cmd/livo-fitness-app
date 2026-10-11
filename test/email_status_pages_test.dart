import 'package:fitness_ai_app/features/auth/presentation/email_status_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
