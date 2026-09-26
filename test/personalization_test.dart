import 'dart:async';

import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/onboarding/data/personalization_store.dart';
import 'package:fitness_ai_app/features/onboarding/domain/personalization_profile.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/personalization_gate.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/personalization_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Late storage reads cannot overwrite a newer saved profile', () async {
    final pending = Completer<PersonalizationRecord>();
    final store = _MemoryStore()..pendingRead = pending;
    final controller = _controller(store);
    final read = controller.loadPersonalization();
    await controller.savePersonalization(
      const PersonalizationProfile(displayName: 'Neu'),
    );
    pending.complete(
      const PersonalizationRecord(
        profile: PersonalizationProfile(displayName: 'Alt'),
      ),
    );
    await read;
    expect(controller.greetingName, 'Neu');
  });

  testWidgets('six short screens save the useful profile data', (tester) async {
    PersonalizationProfile? result;
    await _page(tester, onComplete: (profile) async => result = profile);

    await tester.enterText(find.byKey(const ValueKey('personal-name')), 'Mira');
    await _next(tester);
    await _tap(tester, 'personal-goal-balanced');
    await _next(tester);
    expect(find.text('Geburtsdatum'), findsOneWidget);
    await _next(tester);
    expect(find.text('Deine Größe'), findsOneWidget);
    await tester.tap(find.text('US · ft / lb'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ft'), findsWidgets);
    await _next(tester);
    expect(find.textContaining('lb'), findsWidgets);
    await _next(tester);
    await _tap(tester, 'personal-activity-mixed');
    await tester.enterText(
      find.byKey(const ValueKey('personal-allergies')),
      'Erdnüsse',
    );
    await _next(tester);

    expect(result, isNotNull);
    expect(result!.displayName, 'Mira');
    expect(result!.goal, PersonalGoal.balanced);
    expect(result!.activity, ActivityPattern.mixed);
    expect(result!.birthDate, isNotNull);
    expect(result!.heightCm, isNotNull);
    expect(result!.weightKg, isNotNull);
    expect(result!.measurementSystem, MeasurementSystem.imperial);
    expect(result!.allergies, 'Erdnüsse');
    expect(tester.takeException(), isNull);
  });

  testWidgets('skip stores no body data and future launches open the app', (
    tester,
  ) async {
    final store = _MemoryStore();
    final controller = _controller(store);
    await _gate(tester, controller);
    await _tap(tester, 'personal-later');
    expect(find.text('App bereit'), findsOneWidget);
    expect(store.record.deferred, isTrue);
    expect(store.record.profile, isNull);

    await tester.pumpWidget(const SizedBox());
    await _gate(tester, _controller(store));
    expect(find.text('App bereit'), findsOneWidget);
    expect(find.byType(PersonalizationPage), findsNothing);
  });

  testWidgets('a saving error keeps the same screen and allows retry', (
    tester,
  ) async {
    var attempts = 0;
    await _page(
      tester,
      onComplete: (_) async {
        attempts++;
        if (attempts == 1) throw StateError('unavailable');
      },
    );
    for (var step = 0; step < 5; step++) {
      await _next(tester);
    }
    await _next(tester);
    expect(
      find.textContaining('Deine Angaben konnten nicht gespeichert'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('personal-step-5')), findsOneWidget);
    await _next(tester);
    expect(attempts, 2);
    expect(tester.takeException(), isNull);
  });

  for (final (size, scale) in [
    (const Size(390, 844), 1.0),
    (const Size(320, 568), 2.0),
    (const Size(740, 360), 2.0),
    (const Size(1280, 800), 1.0),
  ]) {
    testWidgets('all short screens fit $size at text scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _page(tester, scale: scale);
      for (var step = 0; step < 6; step++) {
        expect(find.byKey(ValueKey('personal-step-$step')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('personal-next')).hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull, reason: 'step $step');
        if (step < 5) await _next(tester);
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
  double scale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: PersonalizationPage(
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

  @override
  Future<PersonalizationRecord> load(String userId) async {
    if (pendingRead != null) return pendingRead!.future;
    return record;
  }

  @override
  Future<void> save(String userId, PersonalizationProfile profile) async {
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
