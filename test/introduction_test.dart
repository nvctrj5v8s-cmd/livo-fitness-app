import 'dart:async';
import 'dart:ui' show SemanticsAction;

import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/core/theme/app_colors.dart';
import 'package:fitness_ai_app/features/onboarding/data/introduction_store.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/introduction_artwork.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/introduction_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Einführung führt durch fünf Seiten und speichert einmal', (
    tester,
  ) async {
    final store = _MemoryStore();
    await _pump(tester, store);
    expect(find.byKey(const ValueKey('intro-title-0')), findsOneWidget);
    expect(find.text('Nächster Bildschirm'), findsNothing);

    for (var index = 1; index < 5; index++) {
      await tester.tap(find.byKey(const ValueKey('intro-next')));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('intro-title-$index')), findsOneWidget);
      expect(store.writes, 0);
      expect(find.text('Nächster Bildschirm'), findsNothing);
      for (final art in tester.widgetList<IntroductionArtwork>(
        find.byType(IntroductionArtwork),
      )) {
        expect(art.accent, AppColors.primary);
      }
    }
    expect(find.text('Los geht’s'), findsOneWidget);
    await tester.tap(find.text('Los geht’s'));
    await tester.pumpAndSettle();

    expect(store.done, isTrue);
    expect(store.writes, 1);
    expect(find.text('Nächster Bildschirm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Überspringen wird beim nächsten Start berücksichtigt', (
    tester,
  ) async {
    final store = _MemoryStore();
    await _pump(tester, store);
    await tester.tap(find.text('Überspringen'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await _pump(tester, store);
    expect(find.text('Nächster Bildschirm'), findsOneWidget);
    expect(find.text('Überspringen'), findsNothing);
    expect(store.writes, 1);
  });

  testWidgets('Wischen, Zurück und Pfeiltasten navigieren', (tester) async {
    await _pump(tester, _MemoryStore());
    await tester.drag(
      find.byKey(const ValueKey('intro-pages')),
      const Offset(-340, 0),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('intro-title-1')), findsOneWidget);
    await tester.tap(find.byTooltip('Zurück'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('intro-title-0')), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('intro-title-1')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Seitenindikatoren sind mit Screenreader bedienbar', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await _pump(tester, _MemoryStore());
      final indicator = find.bySemanticsLabel('Seite 5 von 5');
      expect(
        tester
            .getSemantics(indicator)
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
      tester.widget<Semantics>(indicator).properties.onTap!();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('intro-title-4')), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('Anmelden überspringt die Einführung für bestehende Nutzer', (
    tester,
  ) async {
    final store = _MemoryStore();
    await _pump(tester, store);
    await tester.tap(find.text('Schon dabei? Anmelden'));
    await tester.pumpAndSettle();
    expect(store.done, isTrue);
    expect(find.text('Nächster Bildschirm'), findsOneWidget);
  });

  testWidgets('Während Laden erscheint weder Login noch Einführung', (
    tester,
  ) async {
    final read = Completer<bool>();
    final store = _MemoryStore()..read = read;
    await _pump(tester, store, settle: false);
    expect(find.byKey(const ValueKey('introduction-loading')), findsOneWidget);
    expect(find.text('Nächster Bildschirm'), findsNothing);
    expect(find.text('Überspringen'), findsNothing);
    read.complete(true);
    await tester.pumpAndSettle();
    expect(find.text('Nächster Bildschirm'), findsOneWidget);
  });

  testWidgets(
    'Doppeltippen während Speichern erzeugt nur einen Schreibvorgang',
    (tester) async {
      final write = Completer<void>();
      final store = _MemoryStore()..write = write;
      await _pump(tester, store);
      await tester.tap(find.text('Überspringen'));
      await tester.pump();
      await tester.tap(find.text('Überspringen'));
      expect(store.writes, 1);
      await tester.pumpWidget(const SizedBox());
      write.complete();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Speicherfehler blockieren den Einstieg nicht', (tester) async {
    final store = _MemoryStore()..fail = true;
    await _pump(tester, store);
    await tester.tap(find.text('Überspringen'));
    await tester.pumpAndSettle();
    expect(find.text('Nächster Bildschirm'), findsOneWidget);
    expect(
      find.text(
        'Die Einführung erscheint beim nächsten Start eventuell erneut.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reduced Motion beendet Seitenwechsel ohne Animation', (
    tester,
  ) async {
    await _pump(tester, _MemoryStore(), reducedMotion: true);
    await tester.tap(find.byKey(const ValueKey('intro-next')));
    await tester.pump();
    expect(find.byKey(const ValueKey('intro-title-1')), findsOneWidget);
    final pages = tester.widget<PageView>(
      find.byKey(const ValueKey('intro-pages')),
    );
    expect(pages.controller!.page, 1);
    for (final animation in tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    )) {
      expect(animation.duration, Duration.zero);
    }
    expect(find.byTooltip('Animation wiederholen'), findsNothing);
    for (final art in tester.widgetList<IntroductionArtwork>(
      find.byType(IntroductionArtwork),
    )) {
      expect(art.progress, 1);
    }
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.tap(find.text('Überspringen'));
    await tester.pumpAndSettle();
    expect(find.text('Nächster Bildschirm'), findsOneWidget);
  });

  testWidgets(
    'Sichtbare Animation auf jeder Seite ist endlich und wiederholbar',
    (tester) async {
      await _pump(tester, _MemoryStore());
      for (var index = 0; index < 5; index++) {
        final replay = find.byKey(ValueKey('intro-replay-$index'));
        await tester.ensureVisible(replay);
        await tester.tap(replay);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        final first = _artProgress(tester, index);
        expect(first, greaterThan(0));
        expect(first, lessThan(0.8));
        await tester.pump(const Duration(milliseconds: 500));
        expect(_artProgress(tester, index), greaterThan(first));
        await tester.pumpAndSettle();
        expect(_artProgress(tester, index), 1);
        expect(tester.binding.hasScheduledFrame, isFalse);
        if (index < 4) {
          await tester.tap(find.byKey(const ValueKey('intro-next')));
          await tester.pumpAndSettle();
        }
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Bewegung reduzieren beendet auch eine laufende Vorschau', (
    tester,
  ) async {
    final store = _MemoryStore();
    await _pump(tester, store);
    await tester.tap(find.byKey(const ValueKey('intro-replay-0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(_artProgress(tester, 0), lessThan(1));
    await _pump(tester, store, reducedMotion: true, settle: false);
    expect(_artProgress(tester, 0), 1);
    expect(find.byTooltip('Animation wiederholen'), findsNothing);
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  for (final viewport in [
    (const Size(320, 568), 1.0),
    (const Size(390, 844), 2.0),
    (const Size(320, 568), 2.0),
    (const Size(740, 360), 1.0),
    (const Size(1280, 800), 1.0),
  ]) {
    testWidgets(
      'Alle Intro-Seiten ohne Overflow bei ${viewport.$1} und Text ${viewport.$2}',
      (tester) async {
        await _pump(
          tester,
          _MemoryStore(),
          size: viewport.$1,
          textScale: viewport.$2,
        );
        for (var index = 0; index < 5; index++) {
          expect(
            find.byKey(const ValueKey('intro-next')).hitTestable(),
            findsOneWidget,
          );
          expect(find.text('Überspringen').hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(find.byKey(const ValueKey('intro-next')));
          await tester.pumpAndSettle();
        }
        expect(find.text('Nächster Bildschirm'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

double _artProgress(WidgetTester tester, int index) => tester
    .widgetList<IntroductionArtwork>(find.byType(IntroductionArtwork))
    .singleWhere((art) => art.index == index)
    .progress;

Future<void> _pump(
  WidgetTester tester,
  IntroductionStore store, {
  Size size = const Size(390, 844),
  double textScale = 1,
  bool reducedMotion = false,
  bool settle = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: reducedMotion,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: IntroductionGate(
        store: store,
        child: const Scaffold(body: Center(child: Text('Nächster Bildschirm'))),
      ),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

class _MemoryStore implements IntroductionStore {
  bool done = false;
  bool fail = false;
  int writes = 0;
  Completer<bool>? read;
  Completer<void>? write;

  @override
  Future<bool> isComplete() async {
    if (fail) throw StateError('Unavailable storage');
    return read == null ? done : await read!.future;
  }

  @override
  Future<void> complete() async {
    writes++;
    if (fail) throw StateError('Unavailable storage');
    if (write != null) await write!.future;
    done = true;
  }
}
