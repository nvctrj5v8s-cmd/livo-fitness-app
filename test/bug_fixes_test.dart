import 'dart:async';

import 'package:fitness_ai_app/core/data/barcode_lookup_service.dart';
import 'package:fitness_ai_app/core/data/supabase_diary_repository.dart';
import 'package:fitness_ai_app/core/models/app_models.dart';
import 'package:fitness_ai_app/core/models/custom_food.dart';
import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/features/diary/presentation/barcode_scanner_page.dart';
import 'package:fitness_ai_app/features/subscription/data/subscription_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Diary backend without network. The streak load waits for [trackingDays].
class _FakeDiary extends Fake implements SupabaseDiaryRepository {
  final trackingDays = Completer<Set<DateTime>>();
  int customMealsSaved = 0;
  final deleted = <String>[];

  @override
  Future<Set<DateTime>> loadTrackingDays(DateTime now) => trackingDays.future;

  @override
  Future<MealEntry> addCustomMeal({
    required String name,
    required MealSlot slot,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    required DateTime date,
    CustomFoodNutrition? nutrition,
  }) async {
    customMealsSaved++;
    return MealEntry(
      id: 'custom-$customMealsSaved',
      remoteMealId: 'meal-$customMealsSaved',
      name: name,
      slot: slot,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
  }

  @override
  Future<void> deleteEntry(MealEntry entry) async {
    deleted.add(entry.remoteMealId!);
  }
}

AppController _signedInController(_FakeDiary diary) => AppController(
  personalizationUserId: 'user-1',
  diaryRepository: diary,
  subscriptionRepository: const PreviewSubscriptionRepository(),
);

void main() {
  group('Barcode-Fehler', () {
    test('422-Antwort „not_halal“ wird als Halal-Sperre erkannt', () {
      final error = BarcodeLookupService.errorFromPayload({
        'error':
            'Dieses Produkt entspricht nicht den Halal-Inhaltsregeln von LIVO.',
        'code': 'not_halal',
      });
      expect(error?.kind, BarcodeErrorKind.notAllowed);
      expect(error?.message, contains('Halal'));
    });

    test('Antworten ohne Fehler ergeben keinen Fehler', () {
      expect(BarcodeLookupService.errorFromPayload({'food': {}}), isNull);
      expect(BarcodeLookupService.errorFromPayload('Bad Gateway'), isNull);
      expect(BarcodeLookupService.errorFromPayload(null), isNull);
    });

    test(
      'Derselbe fehlgeschlagene Barcode wird nicht sofort erneut gesucht',
      () {
        var now = DateTime(2026, 9, 27, 12);
        final guard = RepeatedScanGuard(now: () => now);
        expect(guard.shouldLookUp('4000000000000'), isTrue);
        guard.markFailed('4000000000000');

        // The camera keeps reporting the code while it stays in view.
        for (var i = 0; i < 10; i++) {
          now = now.add(const Duration(milliseconds: 500));
          expect(guard.shouldLookUp('4000000000000'), isFalse);
        }
        // Another product is looked up at once.
        expect(guard.shouldLookUp('5000000000000'), isTrue);
        // After the code was out of view for a moment it may be tried again.
        now = now.add(const Duration(seconds: 5));
        expect(guard.shouldLookUp('4000000000000'), isTrue);
      },
    );
  });

  test('Technische Fehler erscheinen nicht roh im Tagebuch', () {
    expect(
      AppController.diaryErrorMessage(Exception('SocketException: failed')),
      isNot(contains('Socket')),
    );
    expect(
      AppController.diaryErrorMessage(
        StateError('Bitte melde dich an, bevor du etwas speicherst.'),
      ),
      'Bitte melde dich an, bevor du etwas speicherst.',
    );
  });

  test('Doppeltipp beim Speichern erzeugt nur einen Eintrag', () async {
    final diary = _FakeDiary();
    final controller = _signedInController(diary);
    addTearDown(controller.dispose);

    final first = controller.addCustomMealToDiary(
      name: 'Linsensuppe',
      slot: MealSlot.lunch,
      calories: 320,
      protein: 18,
      carbs: 40,
      fat: 8,
      date: DateTime.now(),
    );
    final second = controller.addCustomMealToDiary(
      name: 'Linsensuppe',
      slot: MealSlot.lunch,
      calories: 320,
      protein: 18,
      carbs: 40,
      fat: 8,
      date: DateTime.now(),
    );
    diary.trackingDays.complete({});

    expect(await first, isTrue);
    expect(await second, isFalse);
    expect(diary.customMealsSaved, 1);
    expect(controller.meals, hasLength(1));
  });

  test('Einträge der Startseite lassen sich löschen', () async {
    final diary = _FakeDiary()..trackingDays.complete({});
    final controller = _signedInController(diary);
    addTearDown(controller.dispose);

    // Home shows today's `meals`; the diary list may be on another day.
    await controller.addCustomMealToDiary(
      name: 'Apfel',
      slot: MealSlot.snack,
      calories: 80,
      protein: 0,
      carbs: 20,
      fat: 0,
      date: DateTime.now(),
    );
    controller.diaryMeals.clear();
    final entry = controller.meals.single;

    expect(await controller.removeMeal(entry.id), isTrue);
    expect(diary.deleted, [entry.remoteMealId]);
    expect(controller.meals, isEmpty);
  });

  test('Demodaten löschen entfernt im Konto nichts aus der Ansicht', () async {
    final diary = _FakeDiary()..trackingDays.complete({});
    final controller = _signedInController(diary);
    addTearDown(controller.dispose);
    await controller.addCustomMealToDiary(
      name: 'Apfel',
      slot: MealSlot.snack,
      calories: 80,
      protein: 0,
      carbs: 20,
      fat: 0,
      date: DateTime.now(),
    );

    controller.clearLocalDemoData();
    expect(controller.meals, hasLength(1));
    expect(controller.waterGlasses, 0);
  });
}
