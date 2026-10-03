import 'dart:io';

import 'package:fitness_ai_app/core/config/legal_links.dart';
import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/profile/presentation/account_data_actions.dart';
import 'package:fitness_ai_app/shared/widgets/legal_links_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: Scaffold(body: child),
);

void main() {
  group('legal pages', () {
    const pages = ['datenschutz', 'agb', 'widerruf', 'impressum'];

    test('every linked page exists in web/legal and the links are https', () {
      final links = {
        'datenschutz': LegalLinks.privacy,
        'agb': LegalLinks.terms,
        'widerruf': LegalLinks.withdrawal,
        'impressum': LegalLinks.imprint,
      };
      for (final entry in links.entries) {
        expect(entry.value.scheme, 'https');
        expect(entry.value.path, endsWith('/legal/${entry.key}.html'));
        expect(
          File('web/legal/${entry.key}.html').existsSync(),
          isTrue,
          reason: '${entry.key}.html fehlt',
        );
      }
      expect(File('web/legal/legal.css').existsSync(), isTrue);
    });

    test('pages are German, named Lookin and link to each other', () {
      for (final name in pages) {
        final html = File('web/legal/$name.html').readAsStringSync();
        expect(html, contains('<html lang="de">'));
        expect(html, contains('Lookin'));
        expect(html, isNot(contains('LIVO')));
        for (final other in pages) {
          expect(
            html,
            contains('href="$other.html"'),
            reason: '$name -> $other',
          );
        }
      }
    });

    test('draft pages stay marked until the placeholders are filled', () {
      for (final name in pages) {
        final html = File('web/legal/$name.html').readAsStringSync();
        final hasPlaceholder = html.contains('BITTE AUSFÜLLEN');
        final hasBanner = html.contains('class="draft"');
        // A page may only drop its draft banner once nothing is left to fill.
        if (hasPlaceholder) expect(hasBanner, isTrue, reason: name);
      }
    });

    test('the privacy page names the real data flows', () {
      final html = File('web/legal/datenschutz.html').readAsStringSync();
      for (final term in ['OpenAI', 'RevenueCat', 'Supabase', 'Google Play']) {
        expect(html, contains(term));
      }
      expect(html, contains('ab 18 Jahren'));
    });
  });

  group('LegalLinksRow', () {
    testWidgets('opens the tapped page through the opener', (tester) async {
      final opened = <Uri>[];
      await tester.pumpWidget(
        _host(
          LegalLinksRow(
            opener: (uri) async {
              opened.add(uri);
              return true;
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('legal-link-privacy')));
      await tester.tap(find.byKey(const Key('legal-link-imprint')));

      expect(opened, [LegalLinks.privacy, LegalLinks.imprint]);
    });

    testWidgets('says so when a link cannot be opened', (tester) async {
      await tester.pumpWidget(
        _host(LegalLinksRow(opener: (uri) async => false)),
      );

      await tester.tap(find.byKey(const Key('legal-link-terms')));
      await tester.pump();

      expect(find.textContaining('Link konnte nicht geöffnet'), findsOneWidget);
    });

    testWidgets('shows only the requested pages', (tester) async {
      await tester.pumpWidget(
        _host(const LegalLinksRow(pages: [LegalPage.privacy, LegalPage.terms])),
      );

      expect(find.text('Datenschutz'), findsOneWidget);
      expect(find.text('AGB'), findsOneWidget);
      expect(find.text('Widerruf'), findsNothing);
      expect(find.text('Impressum'), findsNothing);
    });
  });

  group('account deletion dialog', () {
    testWidgets('warns that a store subscription keeps running', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DeleteAccountDialog(
            email: 'a@b.de',
            storeSubscription: true,
            managementUri: Uri.https('play.google.com', '/store/account'),
          ),
        ),
      );

      expect(
        find.byKey(const Key('delete-subscription-warning')),
        findsOneWidget,
      );
      expect(find.textContaining('kündigt dein Abo nicht'), findsOneWidget);
      expect(
        find.byKey(const Key('delete-open-subscriptions')),
        findsOneWidget,
      );
    });

    testWidgets('shows no warning without a store subscription', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const DeleteAccountDialog(email: null)));

      expect(
        find.byKey(const Key('delete-subscription-warning')),
        findsNothing,
      );
      expect(find.textContaining('Konto endgültig löschen'), findsOneWidget);
    });
  });
}
