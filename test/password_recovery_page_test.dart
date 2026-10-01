import 'package:fitness_ai_app/features/auth/presentation/password_recovery_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('new password form rejects short and mismatching passwords', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PasswordRecoveryPage()));
    await tester.tap(find.byKey(const Key('recovery-save')));
    await tester.pump();
    expect(find.text('Mindestens acht Zeichen.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('recovery-password')),
      'secure-password-123',
    );
    await tester.enterText(
      find.byKey(const Key('recovery-confirmation')),
      'different-password',
    );
    await tester.tap(find.byKey(const Key('recovery-save')));
    await tester.pump();
    expect(find.text('Die Passwörter stimmen nicht überein.'), findsOneWidget);
  });
}
