import 'dart:convert';
import 'dart:io';

import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/core/theme/app_colors.dart';
import 'package:fitness_ai_app/features/coach/domain/coach_sources.dart';
import 'package:fitness_ai_app/features/coach/presentation/coach_sources_view.dart';
import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => L10n.use(L10n.german));

  String cited(String locale) =>
      'Eine abwechslungsreiche Ernährung [1].\n\n'
      '${locale == 'de' ? 'Quellen' : 'Sources'}:\n'
      '[1] [${coachSources.first.title}](${coachSources.first.url})';

  test(
    'app allowlist and generated legal pages match the backend catalogue',
    () {
      final rows =
          jsonDecode(
                File(
                  'supabase/functions/_shared/coach_sources.json',
                ).readAsStringSync(),
              )
              as List;
      expect(coachSources, hasLength(rows.length));
      for (final (index, source) in coachSources.indexed) {
        expect(source.id, rows[index]['id']);
        expect(source.url, rows[index]['url']);
        expect(source.summaryDe, rows[index]['summary_de']);
        expect(source.summaryEn, rows[index]['summary_en']);
        expect(source.uri.scheme, 'https');
        expect(source.uri.query, isEmpty);
        for (final path in [
          'web/legal/gesundheit-quellen.html',
          'web/legal/en/gesundheit-quellen.html',
        ]) {
          expect(File(path).readAsStringSync(), contains(source.url));
        }
      }
    },
  );

  test(
    'citations survive history text in both languages without fabricated links',
    () {
      for (final locale in ['de', 'en']) {
        final value = parseCitedCoachAnswer(cited(locale));
        expect(value.text, 'Eine abwechslungsreiche Ernährung [1].');
        expect(value.sources.single.id, 'who-diet');
      }
      expect(parseCitedCoachAnswer('Ältere Antwort.').sources, isEmpty);
      for (final modified in [
        cited('de').replaceAll('https://www.who.int/', 'https://evil.example/'),
        cited('de').replaceFirst('[1] [', '[2] ['),
        '${cited('de')}\nWeitere erfundene Quelle',
      ]) {
        expect(parseCitedCoachAnswer(modified).sources, isEmpty);
      }
    },
  );

  for (final size in [const Size(320, 700), const Size(834, 1194)]) {
    for (final english in [false, true]) {
      testWidgets(
        'source link is readable and opens exact URL, $size, en=$english',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          L10n.use(english ? L10n.english : L10n.german);
          Uri? opened;
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.dark,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CitedCoachText(
                      cited(english ? 'en' : 'de'),
                      style: const TextStyle(fontSize: 14),
                      opener: (uri) async {
                        opened = uri;
                        return true;
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text(L10n.current.coachSourceCount(1)), findsOneWidget);
          expect(find.byKey(const ValueKey('source-who-diet')), findsNothing);
          await tester.tap(
            find.byKey(const ValueKey('inline-source-who-diet-1-0')),
          );
          await tester.pump();
          expect(opened, coachSources.first.uri);
          opened = null;
          await tester.tap(find.byKey(const Key('coach-answer-sources')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('source-who-diet')));
          await tester.pump();
          expect(opened, coachSources.first.uri);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'multiple references link to their own sources and appear together',
    (tester) async {
      Uri? opened;
      final first = coachSources[0];
      final second = coachSources[1];
      final answer =
          'Abwechslungsreich essen [1]. Kalorien sind eine Energieeinheit [2]. '
          'Ein weiterer Hinweis [1].\n\n'
          'Quellen:\n'
          '[1] [${first.title}](${first.url})\n'
          '[2] [${second.title}](${second.url})';
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: SingleChildScrollView(
              child: CitedCoachText(
                answer,
                style: const TextStyle(fontSize: 14),
                opener: (uri) async {
                  opened = uri;
                  return true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(L10n.current.coachSourceCount(2)), findsOneWidget);
      expect(find.byKey(const ValueKey('source-who-diet')), findsNothing);
      await tester.tap(
        find.byKey(const ValueKey('inline-source-nhs-calories-2-1')),
      );
      await tester.pump();
      expect(opened, second.uri);
      await tester.tap(find.byKey(const Key('coach-answer-sources')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('source-who-diet')), findsOneWidget);
      expect(find.byKey(const ValueKey('source-nhs-calories')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('calorie and protein sections have small green source links', (
    tester,
  ) async {
    final calorie = coachSources.singleWhere((s) => s.id == 'nhs-calories');
    final protein = coachSources.singleWhere((s) => s.id == 'efsa-reference');
    Uri? opened;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: SingleChildScrollView(
            child: CitedCoachText(
              'Kalorien sind eine Energieeinheit. [1]\n\n'
              'Protein ist ein Nährstoff. [2]\n\n'
              'Quellen:\n'
              '[1] [${calorie.title}](${calorie.url})\n'
              '[2] [${protein.title}](${protein.url})',
              style: const TextStyle(fontSize: 14),
              opener: (uri) async {
                opened = uri;
                return true;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final calorieChip = find.byKey(
      const ValueKey('inline-source-nhs-calories-1-0'),
    );
    final proteinChip = find.byKey(
      const ValueKey('inline-source-efsa-reference-2-0'),
    );
    expect(calorieChip, findsOneWidget);
    expect(proteinChip, findsOneWidget);
    expect(tester.getSize(calorieChip).height, lessThanOrEqualTo(28));
    final button = tester.widget<TextButton>(proteinChip);
    expect(button.style!.foregroundColor!.resolve({}), AppColors.primary);
    expect(AppColors.mint, AppColors.primary);
    await tester.tap(proteinChip);
    await tester.pump();
    expect(opened, protein.uri);
    await tester.tap(find.byKey(const Key('coach-answer-sources')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('source-nhs-calories')), findsOneWidget);
    expect(find.byKey(const ValueKey('source-efsa-reference')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uncited older replies do not pretend to have a source', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: CitedCoachText(
            'Ältere Antwort ohne Beleg.',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('coach-no-answer-sources')), findsOneWidget);
    expect(find.text(L10n.current.coachNoAnswerSources), findsOneWidget);
    expect(find.byKey(const ValueKey('source-who-diet')), findsNothing);
  });

  testWidgets('source overview opens and closes without a premium account', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: CoachSourcesButton()),
      ),
    );
    await tester.tap(find.byKey(const Key('coach-sources')));
    await tester.pumpAndSettle();
    expect(find.text(L10n.current.coachHealthLimits), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('source-who-diet')),
      160,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.byKey(const ValueKey('source-who-diet')), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text(L10n.current.coachHealthLimits), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
