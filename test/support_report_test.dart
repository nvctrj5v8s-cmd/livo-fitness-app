import 'package:fitness_ai_app/core/config/support_contact.dart';
import 'package:fitness_ai_app/core/data/ai_coach_service.dart';
import 'package:fitness_ai_app/features/coach/presentation/report_answer_sheet.dart';
import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host({
  required String answer,
  required SubmitAnswerReport submit,
  Locale locale = const Locale('de'),
}) => MaterialApp(
  locale: locale,
  supportedLocales: L10n.supported,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () =>
              showReportAnswerSheet(context, answer: answer, submit: submit),
          child: const Text('open'),
        ),
      ),
    ),
  ),
);

Future<void> _openAndSend(WidgetTester tester, {String? reason}) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  if (reason != null) {
    await tester.tap(find.byKey(Key('report-reason-$reason')));
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(find.byKey(const Key('report-send')));
  await tester.tap(find.byKey(const Key('report-send')));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => L10n.use(L10n.german));

  test(
    'mailto-Link: Leerzeichen als %20, Umlaute und Zeilenumbrüche kodiert',
    () {
      final uri = SupportContact.mailto(
        subject: 'Lookin Hilfe',
        body: 'Frage\n\nÜberprüfung & mehr',
      );
      expect(uri.scheme, 'mailto');
      expect(uri.path, SupportContact.email);
      final text = uri.toString();
      expect(text, contains('subject=Lookin%20Hilfe'));
      expect(text, contains('%0A%0A'));
      expect(text, isNot(contains('+')));
      expect(uri.queryParameters['body'], 'Frage\n\nÜberprüfung & mehr');
    },
  );

  test('ohne Betreff und Text bleibt es ein einfacher mailto-Link', () {
    expect(
      SupportContact.mailto().toString(),
      'mailto:lookinsupport@gmail.com',
    );
  });

  test('wenn keine Mail-App da ist, kommt false statt eines Fehlers', () async {
    expect(
      await SupportContact.open(opener: (_) async => throw StateError('none')),
      isFalse,
    );
    expect(await SupportContact.open(opener: (_) async => false), isFalse);
  });

  testWidgets('Antwort melden: direkt in der App, ohne Mail-App', (
    tester,
  ) async {
    ReportReason? sentReason;
    String? sentAnswer;
    await tester.pumpWidget(
      _host(
        answer: 'Iss täglich 5 g Kreatin.',
        submit: (reason, answer) async {
          sentReason = reason;
          sentAnswer = answer;
          return AnswerReportResult.sent;
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Antwort melden'), findsOneWidget);
    expect(find.textContaining('E-Mail'), findsNothing);
    expect(find.textContaining('12 Monate'), findsOneWidget);
    await tester.tap(find.byKey(const Key('report-reason-unsafe')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('report-send')));
    await tester.tap(find.byKey(const Key('report-send')));
    await tester.pumpAndSettle();

    expect(sentReason, ReportReason.unsafe);
    expect(sentAnswer, 'Iss täglich 5 g Kreatin.');
    // The sheet closes and thanks the person.
    expect(find.byKey(const Key('report-send')), findsNothing);
    expect(find.textContaining('Danke!'), findsOneWidget);
  });

  testWidgets('Fehler: Hinweis, Blatt bleibt offen, erneuter Versuch klappt', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      _host(
        answer: 'x',
        submit: (_, _) async =>
            ++calls == 1 ? AnswerReportResult.failed : AnswerReportResult.sent,
      ),
    );
    await _openAndSend(tester);
    expect(find.byKey(const Key('report-error')), findsOneWidget);
    expect(find.byKey(const Key('report-send')), findsOneWidget);

    await tester.tap(find.byKey(const Key('report-send')));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byKey(const Key('report-send')), findsNothing);
  });

  testWidgets('Tageslimit: eigener Hinweis', (tester) async {
    await tester.pumpWidget(
      _host(answer: 'x', submit: (_, _) async => AnswerReportResult.limit),
    );
    await _openAndSend(tester);
    expect(find.textContaining('morgen'), findsOneWidget);
  });

  testWidgets('Englisch: Texte auf Englisch, bei 320 px ohne Überlauf', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    ReportReason? sentReason;
    await tester.pumpWidget(
      _host(
        locale: L10n.english,
        answer: 'Try oats with yoghurt.',
        submit: (reason, _) async {
          sentReason = reason;
          return AnswerReportResult.sent;
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Report this answer'), findsOneWidget);
    expect(find.text('Wrong or misleading'), findsOneWidget);
    expect(find.text('Send report'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('report-send')));
    await tester.tap(find.byKey(const Key('report-send')));
    await tester.pumpAndSettle();
    expect(sentReason, ReportReason.wrong);
    expect(tester.takeException(), isNull);
  });
}
