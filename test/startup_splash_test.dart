import 'package:fitness_ai_app/app/startup_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final splash = find.byWidgetPredicate(
    (widget) =>
        widget is Semantics &&
        widget.properties.label == StartupSplash.semanticsLabel,
  );
  final mark = find.byKey(const ValueKey('startup-splash-mark'));

  testWidgets('spielt einmal und zeigt danach die App', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const StartupSplash(child: _App(label: 'App')));

    // The app is built right away underneath and loads during the animation.
    expect(find.text('App'), findsOneWidget);
    expect(find.bySemanticsLabel('Lookin wird geöffnet'), findsOneWidget);
    expect(splash, findsOneWidget);
    expect(mark, findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.byKey(const ValueKey('startup-splash-word')), findsOneWidget);
    expect(splash, findsOneWidget);

    await tester.pumpAndSettle();
    expect(splash, findsNothing);
    expect(mark, findsNothing);
    expect(find.text('App'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('Gesamtdauer liegt zwischen 1,6 und 2,0 Sekunden', (
    tester,
  ) async {
    expect(StartupSplash.duration.inMilliseconds, inInclusiveRange(1600, 2000));
    await tester.pumpWidget(const StartupSplash(child: _App(label: 'App')));
    await tester.pump(const Duration(milliseconds: 1500));
    expect(mark, findsOneWidget);
    await tester.pump(StartupSplash.duration);
    expect(mark, findsNothing);
  });

  testWidgets('spielt nicht erneut, wenn die App neu aufgebaut wird', (
    tester,
  ) async {
    await tester.pumpWidget(
      const StartupSplash(
        child: _App(key: ValueKey('a'), label: 'Gast'),
      ),
    );
    await tester.pumpAndSettle();
    expect(mark, findsNothing);

    // Like the re-keyed MaterialApp after sign-in or sign-out.
    await tester.pumpWidget(
      const StartupSplash(
        child: _App(key: ValueKey('b'), label: 'Konto'),
      ),
    );
    await tester.pump();
    expect(find.text('Konto'), findsOneWidget);
    expect(mark, findsNothing);
  });

  testWidgets('reduzierte Bewegung: keine Animation, nur kurzer Übergang', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: StartupSplash(child: _App(label: 'App')),
      ),
    );
    expect(mark, findsNothing);
    expect(find.byKey(const ValueKey('startup-splash-word')), findsNothing);
    expect(StartupSplash.reducedMotionDuration.inMilliseconds, lessThan(300));
    // The first frame starts the fade; it ends one fade length later.
    await tester.pump();
    await tester.pump(
      StartupSplash.reducedMotionDuration + const Duration(milliseconds: 16),
    );
    expect(splash, findsNothing);
    expect(find.text('App'), findsOneWidget);
  });

  testWidgets('Tippen überspringt die Animation', (tester) async {
    await tester.pumpWidget(const StartupSplash(child: _App(label: 'App')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tapAt(const Offset(20, 20));
    await tester.pump();
    expect(splash, findsOneWidget);
    await tester.pump(
      StartupSplash.skipDuration + const Duration(milliseconds: 16),
    );
    expect(splash, findsNothing);
    expect(find.text('App'), findsOneWidget);
  });

  for (final size in const [Size(240, 320), Size(320, 200), Size(1600, 900)]) {
    testWidgets('kein Überlauf bei ${size.width.toInt()}x'
        '${size.height.toInt()}', (tester) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const StartupSplash(child: _App(label: 'App')));
      for (var ms = 0; ms < 2000; ms += 100) {
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'bei $ms ms');
      }
      expect(mark, findsNothing);
    });
  }
}

class _App extends StatelessWidget {
  const _App({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: Text(label))),
    );
  }
}
