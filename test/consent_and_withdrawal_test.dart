import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/coach/presentation/coach_page.dart';
import 'package:fitness_ai_app/features/consent/application/consent_controller.dart';
import 'package:fitness_ai_app/features/consent/data/consent_repository.dart';
import 'package:fitness_ai_app/features/consent/domain/consent.dart';
import 'package:fitness_ai_app/features/consent/presentation/consent_dialogs.dart';
import 'package:fitness_ai_app/features/consent/presentation/consent_gate.dart';
import 'package:fitness_ai_app/features/subscription/data/withdrawal_repository.dart';
import 'package:fitness_ai_app/features/subscription/presentation/withdrawal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'coach_chat_test.dart' show FakeCoachService;
import 'support/recipe_fixtures.dart';

class _FakeWithdrawals implements WithdrawalRepository {
  _FakeWithdrawals({this.fail = false});

  final bool fail;
  final calls = <(String, String, String?)>[];

  @override
  String? get currentEmail => 'kunde@beispiel.de';

  @override
  Future<WithdrawalReceipt> withdraw({
    required String name,
    required String email,
    String? note,
  }) async {
    calls.add((name, email, note));
    if (fail) throw StateError('offline');
    return WithdrawalReceipt(
      receivedAt: DateTime(2026, 10, 10, 14, 32),
      emailSent: false,
      reference: 'abc-123',
    );
  }
}

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: Scaffold(body: child),
);

void main() {
  group('ConsentController', () {
    test('asks once until both decisions are recorded', () async {
      final repository = MemoryConsentRepository();
      final consent = ConsentController(repository: repository);
      addTearDown(consent.dispose);
      await consent.load();

      expect(consent.needsInitialDecision, isTrue);
      await consent.set(ConsentKind.healthData, false);
      expect(consent.needsInitialDecision, isTrue);
      await consent.set(ConsentKind.aiProcessing, true);

      expect(consent.needsInitialDecision, isFalse);
      expect(consent.healthGranted, isFalse);
      expect(consent.aiGranted, isTrue);
      expect(repository.records, [
        (ConsentKind.healthData, false, null),
        (ConsentKind.aiProcessing, true, null),
      ]);
    });

    test('texts carry a version for proof', () {
      expect(ConsentTexts.version, isNotEmpty);
      expect(ConsentTexts.ai, contains('OpenAI'));
      expect(ConsentTexts.immediateStart, contains('Widerrufsfrist'));
    });
  });

  group('consent gate', () {
    testWidgets('both boxes start unticked; declining still continues', (
      tester,
    ) async {
      final repository = MemoryConsentRepository();
      final app = AppController(consentRepository: repository);
      addTearDown(app.dispose);
      setTestScreen(tester, const Size(390, 1400));
      await tester.pumpWidget(
        AppScope(
          controller: app,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const ConsentGate(child: Text('App-Inhalt')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Deine Einwilligungen'), findsOneWidget);
      for (final key in ['consent-health', 'consent-ai']) {
        final tile = tester.widget<CheckboxListTile>(
          find.descendant(
            of: find.byKey(Key(key)),
            matching: find.byType(CheckboxListTile),
          ),
        );
        expect(tile.value, isFalse, reason: key);
      }

      await tester.ensureVisible(find.byKey(const Key('consent-continue')));
      await tester.tap(find.byKey(const Key('consent-continue')));
      await tester.pumpAndSettle();

      expect(find.text('App-Inhalt'), findsOneWidget);
      expect(app.consent.healthGranted, isFalse);
      expect(app.consent.aiGranted, isFalse);
      expect(repository.records.length, 2);
    });
  });

  group('AI consent', () {
    testWidgets('the confirm button stays disabled until the box is ticked', (
      tester,
    ) async {
      final consent = ConsentController(repository: MemoryConsentRepository());
      addTearDown(consent.dispose);
      await consent.load();
      bool? result;
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async =>
                  result = await ensureAiConsent(context, consent),
              child: const Text('KI nutzen'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('KI nutzen'));
      await tester.pumpAndSettle();

      final confirm = find.byKey(const Key('consent-dialog-confirm'));
      expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
      await tester.tap(find.byKey(const Key('consent-dialog-checkbox')));
      await tester.pumpAndSettle();
      await tester.tap(confirm);
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(consent.aiGranted, isTrue);
    });

    testWidgets('without consent the coach sends nothing', (tester) async {
      final service = FakeCoachService();
      final app = await recipeTestController(plus: true, consented: false);
      addTearDown(app.dispose);
      setTestScreen(tester, const Size(390, 844));
      await tester.pumpWidget(
        recipeTestApp(app, Scaffold(body: CoachPage(service: service))),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('coach-input')), 'Idee?');
      await tester.pump();
      await tester.tap(find.byKey(const Key('coach-send')));
      await tester.pumpAndSettle();

      expect(find.text(ConsentTexts.aiTitle), findsOneWidget);
      await tester.tap(find.text('Nicht jetzt'));
      await tester.pumpAndSettle();
      expect(service.sent, isEmpty);
    });
  });

  group('withdrawal', () {
    testWidgets('confirms receipt with date and time, no reason needed', (
      tester,
    ) async {
      final repository = _FakeWithdrawals();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: WithdrawalPage(repository: repository, initialName: 'Max'),
        ),
      );

      expect(find.text('Vertrag widerrufen'), findsOneWidget);
      expect(find.text('Widerruf bestätigen'), findsOneWidget);
      await tester.tap(find.byKey(const Key('withdrawal-confirm')));
      await tester.pumpAndSettle();

      expect(repository.calls.single.$1, 'Max');
      expect(repository.calls.single.$2, 'kunde@beispiel.de');
      expect(
        find.text('Dein Widerruf ist am 10.10.2026 um 14:32 Uhr eingegangen.'),
        findsOneWidget,
      );
      expect(find.textContaining('Screenshot'), findsOneWidget);
    });

    testWidgets('needs a name and a valid e-mail', (tester) async {
      final repository = _FakeWithdrawals();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: WithdrawalPage(repository: repository),
        ),
      );
      final confirm = find.byKey(const Key('withdrawal-confirm'));
      expect(tester.widget<FilledButton>(confirm).onPressed, isNull);

      await tester.enterText(find.byKey(const Key('withdrawal-name')), 'Max');
      await tester.enterText(
        find.byKey(const Key('withdrawal-email')),
        'kaputt',
      );
      await tester.pump();
      expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
    });

    testWidgets('a failure names the e-mail way and keeps the form', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: WithdrawalPage(
            repository: _FakeWithdrawals(fail: true),
            initialName: 'Max',
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('withdrawal-confirm')));
      await tester.pumpAndSettle();

      expect(find.textContaining('lookinsupport@gmail.com'), findsOneWidget);
      expect(find.byKey(const Key('withdrawal-done')), findsNothing);
    });
  });
}
