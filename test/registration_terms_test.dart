import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/auth/presentation/auth_page.dart';
import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => L10n.use(L10n.german));
  for (final size in [const Size(320, 700), const Size(834, 1194)]) {
    testWidgets('registration requires deliberate terms acceptance at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const AuthPage(startWithSignUp: true),
        ),
      );
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Mina');
      await tester.enterText(fields.at(1), 'mina@example.com');
      await tester.enterText(fields.at(2), 'A-long-password-123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      final acceptance = find.byKey(const Key('auth-terms-acceptance'));
      final checkbox = find.descendant(
        of: acceptance,
        matching: find.byType(Checkbox),
      );
      expect(tester.widget<Checkbox>(checkbox).value, isFalse);
      final submit = find.widgetWithText(
        FilledButton,
        L10n.current.authGetStartedForFree,
      );
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text(L10n.current.authPleaseAcceptTerms), findsOneWidget);
      // Invalid acceptance stops before any authentication/network request.
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pump();
      expect(tester.widget<Checkbox>(checkbox).value, isTrue);
      expect(tester.state<FormState>(find.byType(Form)).validate(), isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
