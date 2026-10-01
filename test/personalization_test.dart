import 'dart:async';

import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/onboarding/data/personalization_store.dart';
import 'package:fitness_ai_app/features/onboarding/domain/personalization_profile.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/personalization_gate.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/personalization_page.dart';
import 'package:fitness_ai_app/features/onboarding/presentation/questions_first_gate.dart';
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

  test('neue Antworten überstehen Speichern und Laden', () {
    const profile = PersonalizationProfile(
      goal: PersonalGoal.loseWeight,
      sex: BodySex.female,
      targetWeightKg: 64.5,
      pace: WeightPace.gentle,
      motivations: {Motivation.energy, Motivation.health},
      obstacles: {Obstacle.cravings},
      experience: TrackingExperience.none,
      healthNotes: {HealthNote.pregnantOrNursing},
    );
    final restored = PersonalizationProfile.fromJson(profile.toJson());
    expect(restored.sex, BodySex.female);
    expect(restored.targetWeightKg, 64.5);
    expect(restored.pace, WeightPace.gentle);
    expect(restored.motivations, {Motivation.energy, Motivation.health});
    expect(restored.obstacles, {Obstacle.cravings});
    expect(restored.experience, TrackingExperience.none);
    expect(restored.healthNotes, {HealthNote.pregnantOrNursing});
    // Older records without the new fields still load.
    final old = PersonalizationProfile.fromJson({
      'version': 1,
      'goal': 'maintain',
    });
    expect(old.motivations, isEmpty);
    expect(old.healthNotes, isEmpty);
  });

  testWidgets('alle Fragen bis zum Plan und gespeicherte Antworten', (
    tester,
  ) async {
    PersonalizationProfile? result;
    await _page(tester, onComplete: (profile) async => result = profile);

    await tester.enterText(find.byKey(const ValueKey('personal-name')), 'Mira');
    await _next(tester);
    await _tap(tester, 'personal-goal-loseWeight');
    await _next(tester);
    _expectStep('motivation');
    await _tap(tester, 'personal-motivation-energy');
    await _tap(tester, 'personal-motivation-health');
    await _next(tester);
    _expectStep('sex');
    await _tap(tester, 'personal-sex-female');
    await _next(tester);
    expect(find.text('Geburtsdatum'), findsOneWidget);
    expect(find.text('Überspringen'), findsWidgets);
    await _tap(tester, 'personal-confirm-value');
    await _next(tester);
    expect(find.text('Deine Größe'), findsOneWidget);
    await _tap(tester, 'personal-confirm-value');
    await _next(tester);
    _expectStep('weight');
    await _tap(tester, 'personal-confirm-value');
    await _next(tester);
    _expectStep('target');
    await _tap(tester, 'personal-confirm-value');
    expect(find.byKey(const ValueKey('personal-target-value')), findsOneWidget);
    expect(find.byKey(const ValueKey('personal-pace')), findsOneWidget);
    await _next(tester);
    _expectStep('activity');
    await _tap(tester, 'personal-activity-mixed');
    await _next(tester);
    _expectStep('food');
    await _tap(tester, 'personal-nutrition-vegetarian');
    await tester.ensureVisible(find.byKey(const Key('edit-allergies')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('edit-allergies')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('peanuts')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-allergies')));
    await tester.pumpAndSettle();
    await _next(tester);
    _expectStep('kitchen');
    await _tap(tester, 'personal-cooking-normal');
    await _tap(tester, 'personal-experience-none');
    await _next(tester);
    _expectStep('obstacles');
    await _tap(tester, 'personal-obstacle-cravings');
    await _next(tester);
    _expectStep('health');
    await _next(tester);
    _expectStep('summary');
    expect(
      find.byKey(const ValueKey('personal-summary-calories')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('personal-summary-date')), findsOneWidget);
    expect(find.textContaining('Grobe Schätzung'), findsOneWidget);
    expect(find.textContaining('Allergenen blendet LIVO aus'), findsOneWidget);
    await _next(tester);

    expect(result, isNotNull);
    expect(result!.displayName, 'Mira');
    expect(result!.goal, PersonalGoal.loseWeight);
    expect(result!.motivations, {Motivation.energy, Motivation.health});
    expect(result!.sex, BodySex.female);
    expect(result!.targetWeightKg, 65);
    expect(result!.pace, WeightPace.gentle);
    expect(result!.activity, ActivityPattern.mixed);
    expect(result!.nutrition, NutritionPreference.vegetarian);
    expect(result!.allergies, 'Erdnüsse');
    expect(result!.cookingMinutes, 30);
    expect(result!.experience, TrackingExperience.none);
    expect(result!.obstacles, {Obstacle.cravings});
    expect(result!.healthNotes, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ohne Gewichtsziel keine Zielgewicht-Frage', (tester) async {
    await _page(tester);
    await _next(tester);
    await _tap(tester, 'personal-goal-balanced');
    for (var i = 0; i < 6; i++) {
      await _next(tester);
    }
    _expectStep('activity');
  });

  testWidgets('kein Abnehmziel unter einem BMI von 18,5', (tester) async {
    await _page(
      tester,
      initial: const PersonalizationProfile(
        goal: PersonalGoal.loseWeight,
        heightCm: 175,
        weightKg: 56,
      ),
    );
    while (find
        .byKey(const ValueKey('personal-step-target'))
        .evaluate()
        .isEmpty) {
      await _next(tester);
    }
    expect(find.textContaining('unteren gesunden Bereich'), findsOneWidget);
    expect(find.byKey(const ValueKey('personal-target-value')), findsNothing);
  });

  testWidgets('Gesundheitshinweis: keine Kalorienziele im Plan', (
    tester,
  ) async {
    PersonalizationProfile? result;
    await _page(
      tester,
      initial: PersonalizationProfile(
        goal: PersonalGoal.loseWeight,
        heightCm: 170,
        weightKg: 80,
        birthDate: DateTime(1990, 5, 1),
      ),
      onComplete: (profile) async => result = profile,
    );
    while (find
        .byKey(const ValueKey('personal-step-health'))
        .evaluate()
        .isEmpty) {
      await _next(tester);
    }
    await _tap(tester, 'personal-health-eatingDisorder');
    expect(find.textContaining('keine Kalorienziele'), findsOneWidget);
    await _next(tester);
    expect(
      find.byKey(const ValueKey('personal-summary-paused')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('personal-summary-calories')),
      findsNothing,
    );
    await _next(tester);
    expect(result!.needsProfessionalGuidance, isTrue);
  });

  testWidgets('Plan wird erstellt: ehrliche Schritte, dann der Plan', (
    tester,
  ) async {
    await _page(
      tester,
      initial: PersonalizationProfile(
        goal: PersonalGoal.loseWeight,
        heightCm: 170,
        weightKg: 82,
        targetWeightKg: 76,
        birthDate: DateTime(1990, 5, 1),
        allergies: 'Erdnüsse',
      ),
    );
    while (find
        .byKey(const ValueKey('personal-step-health'))
        .evaluate()
        .isEmpty) {
      await _next(tester);
    }
    await tester.tap(find.byKey(const ValueKey('personal-next')));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Dein Plan wird erstellt …'), findsOneWidget);
    expect(find.byKey(const ValueKey('plan-building')), findsOneWidget);
    expect(
      find.text('Energiebedarf aus Alter, Größe und Gewicht berechnen'),
      findsOneWidget,
    );
    expect(
      find.text('Zeit bis zu deinem Wunschgewicht abschätzen'),
      findsOneWidget,
    );
    expect(
      find.text('Rezepte mit deinen Allergenen aussortieren'),
      findsOneWidget,
    );
    expect(find.text('Rezepte nach deinem Ziel sortieren'), findsOneWidget);
    // No obstacles chosen: nothing about the coach is claimed.
    expect(find.textContaining('Coach auf deine'), findsNothing);
    expect(find.text('Einen Moment …'), findsOneWidget);
    final next = tester.widget<FilledButton>(
      find.byKey(const ValueKey('personal-next')),
    );
    expect(next.onPressed, isNull);

    await tester.pumpAndSettle();
    expect(find.text('Dein LIVO-Plan ist bereit.'), findsOneWidget);
    expect(find.byKey(const ValueKey('personal-summary')), findsOneWidget);
    expect(find.text('Los geht’s'), findsOneWidget);
    expect(find.text('Eiweiß'), findsOneWidget);
    expect(find.text('Kohlenhydrate'), findsOneWidget);

    // Back and forth: the plan shows right away the second time.
    await _tap(tester, 'personal-back');
    await tester.tap(find.byKey(const ValueKey('personal-next')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('plan-building')), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('Bewegung reduzieren: Plan ohne Wartezeit', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await _page(
      tester,
      initial: PersonalizationProfile(
        heightCm: 170,
        weightKg: 70,
        birthDate: DateTime(1990, 5, 1),
      ),
    );
    while (find
        .byKey(const ValueKey('personal-step-health'))
        .evaluate()
        .isEmpty) {
      await _next(tester);
    }
    await tester.tap(find.byKey(const ValueKey('personal-next')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const ValueKey('plan-building')), findsNothing);
    expect(find.text('Dein LIVO-Plan ist bereit.'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('alles übersprungen: keine erfundenen Werte, kein Plan-Theater', (
    tester,
  ) async {
    PersonalizationProfile? result;
    await _page(tester, onComplete: (profile) async => result = profile);
    var steps = 0;
    while (find
        .byKey(const ValueKey('personal-step-summary'))
        .evaluate()
        .isEmpty) {
      // Every question offers „Überspringen“ while nothing is chosen.
      if (find.byKey(const ValueKey('personal-step-name')).evaluate().isEmpty &&
          find
              .byKey(const ValueKey('personal-step-health'))
              .evaluate()
              .isEmpty) {
        expect(find.text('Überspringen'), findsWidgets, reason: 'step $steps');
      }
      await _next(tester);
      steps++;
    }
    await tester.pump();
    expect(find.byKey(const ValueKey('plan-building')), findsNothing);
    expect(find.text('Du startest ganz neutral.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('personal-summary-neutral')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('personal-summary-calories')),
      findsNothing,
    );
    expect(find.textContaining('sortiert nach'), findsNothing);
    await tester.pumpAndSettle();
    await _next(tester);

    expect(result, isNotNull);
    expect(result!.hasAnswers, isFalse);
    expect(result!.birthDate, isNull);
    expect(result!.heightCm, isNull);
    expect(result!.weightKg, isNull);
    expect(result!.targetWeightKg, isNull);
    expect(result!.pace, isNull);
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

  testWidgets('Antworten von vor der Registrierung gehen ins Konto', (
    tester,
  ) async {
    final store = _MemoryStore();
    final pending = _MemoryPending()
      ..record = const PersonalizationRecord(
        profile: PersonalizationProfile(
          displayName: 'Sami',
          goal: PersonalGoal.maintain,
        ),
      );
    final controller = _controller(store);
    await _gate(tester, controller, pending: pending);

    expect(find.text('App bereit'), findsOneWidget);
    expect(find.byType(PersonalizationPage), findsNothing);
    expect(store.record.profile?.displayName, 'Sami');
    expect(controller.greetingName, 'Sami');
    expect(pending.record.hasDecision, isFalse);
    expect(pending.accountSeen, isTrue);
  });

  testWidgets('„Überspringen“ vorher ersetzt keine Antworten eines Kontos', (
    tester,
  ) async {
    final store = _MemoryStore()
      ..record = const PersonalizationRecord(
        profile: PersonalizationProfile(displayName: 'Bestand'),
      );
    final pending = _MemoryPending()
      ..record = const PersonalizationRecord(deferred: true);
    await _gate(tester, _controller(store), pending: pending);
    expect(find.text('App bereit'), findsOneWidget);
    expect(store.record.profile?.displayName, 'Bestand');
  });

  group('Fragen vor der Anmeldung', () {
    testWidgets('neu: erst Fragen, dann Registrierung mit Hinweis', (
      tester,
    ) async {
      final pending = _MemoryPending();
      await _questionsFirst(tester, pending);
      expect(find.byKey(const ValueKey('questions-first')), findsOneWidget);
      expect(find.text('App'), findsNothing);

      while (find
          .byKey(const ValueKey('personal-step-summary'))
          .evaluate()
          .isEmpty) {
        await _next(tester);
      }
      await _next(tester);
      expect(pending.record.profile, isNotNull);
      expect(find.byKey(const Key('auth-answers-ready')), findsOneWidget);
      expect(find.text('Fast geschafft!'), findsOneWidget);

      await _tap(tester, 'auth-edit-answers');
      expect(find.byKey(const ValueKey('questions-first')), findsOneWidget);
    });

    testWidgets('„Schon ein Konto?“ führt direkt zur Anmeldung', (
      tester,
    ) async {
      final pending = _MemoryPending();
      await _questionsFirst(tester, pending);
      await _tap(tester, 'personal-sign-in');
      expect(find.byKey(const ValueKey('questions-first')), findsNothing);
      expect(find.byKey(const Key('auth-answers-ready')), findsNothing);
      expect(find.text('Anmelden'), findsWidgets);
      expect(pending.record.hasDecision, isFalse);
    });

    testWidgets('nach einem Konto auf dem Gerät gleich die Anmeldung', (
      tester,
    ) async {
      final pending = _MemoryPending()..accountSeen = true;
      await _questionsFirst(tester, pending);
      expect(find.byKey(const ValueKey('questions-first')), findsNothing);
    });

    testWidgets('angemeldet: direkt in die App', (tester) async {
      await _questionsFirst(tester, _MemoryPending(), signedIn: true);
      expect(find.text('App'), findsOneWidget);
    });
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
      await _page(
        tester,
        scale: scale,
        initial: PersonalizationProfile(
          goal: PersonalGoal.loseWeight,
          heightCm: 170,
          weightKg: 82,
          birthDate: DateTime(1990, 5, 1),
          allergies: 'Erdnüsse, Milch',
          obstacles: const {Obstacle.cravings, Obstacle.time},
        ),
      );
      for (var step = 0; step < 20; step++) {
        expect(
          find.byKey(const ValueKey('personal-next')).hitTestable(),
          findsOneWidget,
          reason: 'step $step',
        );
        expect(tester.takeException(), isNull, reason: 'step $step');
        if (find
            .byKey(const ValueKey('personal-step-summary'))
            .evaluate()
            .isNotEmpty) {
          return;
        }
        await _next(tester);
      }
      fail('Die Zusammenfassung wurde nicht erreicht.');
    });
  }
}

void _expectStep(String name) =>
    expect(find.byKey(ValueKey('personal-step-$name')), findsOneWidget);

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
        initial: initial,
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

Future<void> _gate(
  WidgetTester tester,
  AppController controller, {
  _MemoryPending? pending,
}) async {
  await tester.pumpWidget(
    AppScope(
      controller: controller,
      child: MaterialApp(
        theme: AppTheme.dark,
        home: PersonalizationGate(
          pending: pending ?? _MemoryPending(),
          child: const Scaffold(body: Text('App bereit')),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _questionsFirst(
  WidgetTester tester,
  _MemoryPending pending, {
  bool signedIn = false,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: QuestionsFirstGate(
        pending: pending,
        isSignedIn: () => signedIn,
        authChanges: const Stream.empty(),
        child: const Scaffold(body: Text('App')),
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

class _MemoryPending implements PendingPersonalizationStore {
  PersonalizationRecord record = const PersonalizationRecord();
  bool accountSeen = false;

  @override
  Future<PersonalizationRecord> load() async => record;

  @override
  Future<void> save(PersonalizationProfile profile) async =>
      record = PersonalizationRecord(profile: profile);

  @override
  Future<void> defer() async =>
      record = const PersonalizationRecord(deferred: true);

  @override
  Future<void> clear() async => record = const PersonalizationRecord();

  @override
  Future<bool> hasSeenAccount() async => accountSeen;

  @override
  Future<void> markAccountSeen() async => accountSeen = true;
}
