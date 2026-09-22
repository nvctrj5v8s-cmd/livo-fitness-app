import 'dart:async';
import 'dart:io';

import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/onboarding/data/personalization_store.dart';
import 'package:fitness_ai_app/features/onboarding/domain/personalization_profile.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/personalization_card.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/personalization_gate.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/personalization_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Late storage reads cannot overwrite a more recent save or deletion',
    () async {
      final pending = Completer<PersonalizationRecord>();
      final store = _MemoryStore()..pendingRead = pending;
      final controller = _controller(store);
      final staleRead = controller.loadPersonalization();
      await controller.savePersonalization(
        const PersonalizationProfile(displayName: 'Neu'),
      );
      pending.complete(
        const PersonalizationRecord(
          profile: PersonalizationProfile(displayName: 'Alt'),
        ),
      );
      await staleRead;
      expect(controller.greetingName, 'Neu');
      final pendingAgain = Completer<PersonalizationRecord>();
      store.pendingRead = pendingAgain;
      final secondRead = controller.loadPersonalization();
      await controller.clearPersonalization();
      pendingAgain.complete(
        const PersonalizationRecord(
          profile: PersonalizationProfile(displayName: 'Alt'),
        ),
      );
      await secondRead;
      expect(controller.personalization, isNull);
    },
  );

  testWidgets('Timed-out reads cannot restore answers after bypass and save', (
    tester,
  ) async {
    final pending = Completer<PersonalizationRecord>();
    final store = _MemoryStore()..pendingRead = pending;
    final controller = _controller(store);
    await _gate(tester, controller);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Für jetzt fortfahren'));
    await tester.pumpAndSettle();
    await controller.savePersonalization(
      const PersonalizationProfile(displayName: 'Neu'),
    );
    pending.complete(
      const PersonalizationRecord(
        profile: PersonalizationProfile(displayName: 'Alt'),
      ),
    );
    await tester.pumpAndSettle();
    expect(controller.greetingName, 'Neu');
    expect(find.text('App bereit'), findsOneWidget);
  });

  testWidgets('Six calm setup screens retain useful answers and save once', (
    tester,
  ) async {
    PersonalizationProfile? result;
    await _page(tester, onComplete: (profile) async => result = profile);
    await tester.enterText(find.byKey(const ValueKey('personal-name')), 'Mira');
    await _next(tester);
    await _tap(tester, 'personal-goal-balanced');
    await _next(tester);
    await _tap(tester, 'personal-activity-mixed');
    await _next(tester);
    await _tap(tester, 'personal-nutrition-vegetarian');
    await tester.enterText(
      find.byKey(const ValueKey('personal-allergies')),
      'Erdnüsse',
    );
    await _next(tester);
    await _tap(tester, 'personal-desired-meals-4');
    await tester.tap(find.byKey(const ValueKey('personal-cooking-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bis 30 Minuten').last);
    await tester.pumpAndSettle();
    await _next(tester);
    expect(find.byKey(const ValueKey('personal-step-5')), findsOneWidget);
    await _tap(tester, 'personal-review-edit-4');
    expect(find.byKey(const ValueKey('personal-step-4')), findsOneWidget);
    await _tap(tester, 'personal-desired-meals-5');
    await _next(tester);
    expect(find.byKey(const ValueKey('personal-step-5')), findsOneWidget);
    expect(result, isNull);
    await _next(tester);
    expect(result!.displayName, 'Mira');
    expect(result!.goal, PersonalGoal.balanced);
    expect(result!.activity, ActivityPattern.mixed);
    expect(result!.usualMeals, isNull);
    expect(result!.desiredMeals, 5);
    expect(result!.nutrition, NutritionPreference.vegetarian);
    expect(result!.allergies, 'Erdnüsse');
    expect(result!.cookingMinutes, 30);
    expect(result!.focus, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Saving failures retain draft and retry; double tap is locked', (
    tester,
  ) async {
    var attempts = 0;
    final pending = Completer<void>();
    await _page(
      tester,
      editing: true,
      onComplete: (_) async {
        attempts++;
        if (attempts == 1) throw StateError('Disk unavailable');
        await pending.future;
      },
    );
    await _next(tester);
    expect(
      find.textContaining('Deine Auswahl konnte nicht gespeichert'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('personal-step-5')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('personal-next')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('personal-next')));
    expect(attempts, 2);
    pending.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Skip persists no answers; future launches go straight to child',
    (tester) async {
      final store = _MemoryStore();
      final controller = _controller(store);
      await _gate(tester, controller);
      await _tap(tester, 'personal-later');
      expect(find.text('App bereit'), findsOneWidget);
      expect(store.record.deferred, isTrue);
      expect(store.record.profile, isNull);
      expect(controller.personalization, isNull);
      await tester.pumpWidget(const SizedBox());
      final second = _controller(store);
      await _gate(tester, second);
      expect(find.text('App bereit'), findsOneWidget);
      expect(find.byType(PersonalizationPage), findsNothing);
    },
  );

  testWidgets('Saved answers load before entering the app', (tester) async {
    final store = _MemoryStore()
      ..record = const PersonalizationRecord(
        profile: PersonalizationProfile(displayName: 'Mira', desiredMeals: 3),
      );
    final controller = _controller(store);
    await _gate(tester, controller);
    expect(find.text('App bereit'), findsOneWidget);
    expect(controller.greetingName, 'Mira');
    expect(controller.personalization!.desiredMeals, 3);
  });

  testWidgets('Read failure offers a non-destructive bypass', (tester) async {
    final store = _MemoryStore()..failRead = true;
    await _gate(tester, _controller(store));
    expect(
      find.text('Deine Einstellungen konnten nicht geladen werden.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Für jetzt fortfahren'));
    await tester.pumpAndSettle();
    expect(find.text('App bereit'), findsOneWidget);
    expect(store.writes, 0);
  });

  testWidgets('Profile editor can cancel, save and remove only preferences', (
    tester,
  ) async {
    final store = _MemoryStore()
      ..record = const PersonalizationRecord(
        profile: PersonalizationProfile(displayName: 'Mira', desiredMeals: 3),
      );
    final controller = _controller(store);
    await controller.loadPersonalization();
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: PersonalizationCard(profileMode: true),
            ),
          ),
        ),
      ),
    );
    await _tap(tester, 'personalization-edit');
    expect(find.byKey(const ValueKey('personal-step-5')), findsOneWidget);
    await _tap(tester, 'personal-review-edit-0');
    await tester.enterText(
      find.byKey(const ValueKey('personal-name')),
      'Entwurf',
    );
    await _tap(tester, 'personal-later');
    expect(controller.greetingName, 'Mira');
    expect(store.writes, 0);
    await _tap(tester, 'personalization-edit');
    await _tap(tester, 'personal-review-edit-0');
    await tester.enterText(find.byKey(const ValueKey('personal-name')), 'Alex');
    await _next(tester);
    await _next(tester);
    expect(controller.greetingName, 'Alex');
    expect(store.writes, 1);
    await _tap(tester, 'personalization-remove');
    expect(controller.personalization, isNull);
    expect(store.record.profile, isNull);
    expect(tester.takeException(), isNull);
  });

  for (final (size, scale) in [
    (const Size(390, 844), 1.0),
    (const Size(320, 568), 2.0),
    (const Size(740, 360), 2.0),
    (const Size(1280, 800), 1.0),
  ]) {
    testWidgets(
      'All steps fit $size text scale $scale; reduced motion settles',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await _page(tester, scale: scale, reduced: true);
        for (var step = 0; step < 6; step++) {
          expect(find.byKey(ValueKey('personal-step-$step')), findsOneWidget);
          expect(
            find.byKey(const ValueKey('personal-next')).hitTestable(),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull, reason: 'step $step');
          expect(tester.binding.hasScheduledFrame, isFalse);
          if (step < 5) await _next(tester);
        }
      },
    );
  }

  testWidgets('Animations show an intermediate frame then finish', (
    tester,
  ) async {
    await _page(tester);
    await tester.tap(find.byKey(const ValueKey('personal-next')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  // Opt-in design captures; no generated images or golden baselines in the repo.
  const screenshotDir = String.fromEnvironment('PERSONALIZATION_SCREENSHOTS');
  if (screenshotDir.isNotEmpty) {
    testWidgets('Capture mobile and desktop setup artwork', (tester) async {
      const fontPath = String.fromEnvironment('PERSONALIZATION_FONT');
      if (fontPath.isNotEmpty) {
        await tester.runAsync(() async {
          final font = FontLoader('Roboto')
            ..addFont(File(fontPath).readAsBytes().then(ByteData.sublistView));
          final icons = FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
          final fallback = FontLoader('Ahem')
            ..addFont(File(fontPath).readAsBytes().then(ByteData.sublistView));
          await Future.wait([font.load(), icons.load(), fallback.load()]);
        });
      }
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final (size, suffix) in [
        (const Size(390, 844), 'mobile'),
        (const Size(1280, 800), 'desktop'),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpWidget(const SizedBox());
        await _page(
          tester,
          initial: const PersonalizationProfile(
            displayName: 'Mira',
            activity: ActivityPattern.mixed,
            desiredMeals: 3,
            usualMeals: 4,
            nutrition: NutritionPreference.vegetarian,
            goal: PersonalGoal.balanced,
            cookingMinutes: 30,
            focus: RoutineFocus.time,
          ),
        );
        for (var step = 0; step < 6; step++) {
          if ([0, 2, 3, 5].contains(step)) {
            await expectLater(
              find.byType(PersonalizationPage),
              matchesGoldenFile(
                Uri.file('$screenshotDir/personal-$suffix-$step.png'),
              ),
            );
          }
          if (step < 5) await _next(tester);
        }
      }
    });
  }
}

Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(ValueKey(key));
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _next(WidgetTester tester) => _tap(tester, 'personal-next');

Future<void> _page(
  WidgetTester tester, {
  Future<void> Function(PersonalizationProfile)? onComplete,
  PersonalizationProfile initial = const PersonalizationProfile(),
  bool editing = false,
  bool reduced = false,
  double scale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: reduced,
          textScaler: TextScaler.linear(scale),
        ),
        child: child!,
      ),
      home: PersonalizationPage(
        initial: initial,
        editing: editing,
        onComplete: onComplete ?? (_) async {},
        onLater: () async {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

AppController _controller(_MemoryStore store) {
  final controller = AppController(
    personalizationUserId: 'user-a',
    personalizationStore: store,
  );
  addTearDown(controller.dispose);
  return controller;
}

Future<void> _gate(WidgetTester tester, AppController controller) async {
  await tester.pumpWidget(
    AppScope(
      controller: controller,
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const PersonalizationGate(
          child: Scaffold(body: Text('App bereit')),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _MemoryStore implements PersonalizationStore {
  Completer<PersonalizationRecord>? pendingRead;
  PersonalizationRecord record = const PersonalizationRecord();
  bool failRead = false;
  int writes = 0;
  @override
  Future<PersonalizationRecord> load(String userId) async {
    if (failRead) throw StateError('Read failed');
    if (pendingRead != null) return pendingRead!.future;
    return record;
  }

  @override
  Future<void> save(String userId, PersonalizationProfile profile) async {
    writes++;
    record = PersonalizationRecord(profile: profile);
  }

  @override
  Future<void> defer(String userId) async {
    record = const PersonalizationRecord(deferred: true);
  }

  @override
  Future<void> clear(String userId) async {
    record = const PersonalizationRecord();
  }
}
