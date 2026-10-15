import 'package:fitness_ai_app/core/config/support_contact.dart';
import 'package:fitness_ai_app/features/coach/presentation/report_answer_sheet.dart';
import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host({
  required String answer,
  required Future<bool> Function(Uri) opener,
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
              showReportAnswerSheet(context, answer: answer, opener: opener),
          child: const Text('open'),
        ),
      ),
    ),
  ),
);

void main() {
  tearDown(() => L10n.use(L10n.german));

  test(
    'mailto-Link: Leerzeichen als %20, Umlaute und Zeilenumbrüche kodiert',
    () {
      final uri = SupportContact.mailto(
        subject: 'Lookin Coach: Antwort melden',
        body: 'Grund: Falsch\n\nÜberprüfung & mehr',
      );
      expect(uri.scheme, 'mailto');
      expect(uri.path, SupportContact.email);
      final text = uri.toString();
      expect(text, contains('subject=Lookin%20Coach%3A%20Antwort%20melden'));
      expect(text, contains('%0A%0A'));
      expect(text, isNot(contains('+')));
      expect(
        uri.queryParameters['body'],
        'Grund: Falsch\n\nÜberprüfung & mehr',
      );
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

  testWidgets('Antwort melden: Grund wählen, E-Mail mit der Antwort', (
    tester,
  ) async {
    Uri? opened;
    await tester.pumpWidget(
      _host(
        answer: 'Iss täglich 5 g Kreatin.',
        opener: (uri) async {
          opened = uri;
          return true;
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Antwort melden'), findsOneWidget);

    await tester.tap(find.byKey(const Key('report-reason-unsafe')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('report-send')));
    await tester.tap(find.byKey(const Key('report-send')));
    await tester.pumpAndSettle();

    expect(opened, isNotNull);
    final body = opened!.queryParameters['body']!;
    expect(body, contains('Unsicher oder gesundheitlich bedenklich'));
    expect(body, contains('Iss täglich 5 g Kreatin.'));
    expect(opened!.queryParameters['subject'], 'Lookin Coach: Antwort melden');
    // The sheet closes after the mail app opened.
    expect(find.byKey(const Key('report-send')), findsNothing);
  });

  testWidgets(
    'Englisch: Texte und Mail auf Englisch, bei 320 px ohne Überlauf',
    (tester) async {
      tester.view
        ..physicalSize = const Size(320, 640)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      Uri? opened;
      await tester.pumpWidget(
        _host(
          locale: L10n.english,
          answer: 'Try oats with yoghurt.',
          opener: (uri) async {
            opened = uri;
            return true;
          },
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Report this answer'), findsOneWidget);
      expect(find.text('Wrong or misleading'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('report-send')));
      await tester.tap(find.byKey(const Key('report-send')));
      await tester.pumpAndSettle();
      expect(
        opened!.queryParameters['subject'],
        'Lookin Coach: report an answer',
      );
      expect(
        opened!.queryParameters['body'],
        contains('Reason: Wrong or misleading'),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('keine Mail-App: Hinweis mit der Adresse, Blatt bleibt offen', (
    tester,
  ) async {
    await tester.pumpWidget(_host(answer: 'x', opener: (_) async => false));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('report-send')));
    await tester.tap(find.byKey(const Key('report-send')));
    await tester.pumpAndSettle();
    expect(find.textContaining(SupportContact.email), findsWidgets);
    expect(find.byKey(const Key('report-send')), findsOneWidget);
  });
}
