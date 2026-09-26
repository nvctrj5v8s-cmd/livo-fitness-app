import 'package:fitness_ai_app/features/onboarding/domain/personalization_profile.dart';
import 'package:fitness_ai_app/features/profile/domain/daily_targets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 9, 26);

  test('ohne Alter, Größe oder Gewicht bleiben die Ziele leer', () {
    expect(
      DailyTargets.fromProfile(null).status,
      DailyTargetsStatus.missingData,
    );
    final partial = PersonalizationProfile(
      birthDate: DateTime(1995, 1, 1),
      heightCm: 180,
    );
    final targets = DailyTargets.fromProfile(partial, today: today);
    expect(targets.isReady, isFalse);
    expect(targets.calories, isNull);
    expect(targets.protein, isNull);
    expect(targets.fat, isNull);
  });

  test('unter 18 Jahren werden keine Kalorienziele berechnet', () {
    final profile = PersonalizationProfile(
      birthDate: DateTime(2010, 5, 1),
      heightCm: 165,
      weightKg: 55,
    );
    expect(
      DailyTargets.fromProfile(profile, today: today).status,
      DailyTargetsStatus.underage,
    );
  });

  test('berechnet Kalorien, Protein und Fett aus den Angaben', () {
    final profile = PersonalizationProfile(
      birthDate: DateTime(1996, 9, 26),
      heightCm: 180,
      weightKg: 80,
      activity: ActivityPattern.mixed,
      goal: PersonalGoal.maintain,
    );
    final targets = DailyTargets.fromProfile(profile, today: today);
    // BMR = 800 + 1125 - 150 - 78 = 1697; * 1.375 = 2333.4 -> 2330
    expect(targets.isReady, isTrue);
    expect(targets.calories, 2330);
    expect(targets.protein, 96);
    expect(targets.fat, 78);
  });

  test('Muskelaufbau liegt über, Abnehmen maßvoll unter dem Erhalt', () {
    PersonalizationProfile withGoal(PersonalGoal goal) =>
        PersonalizationProfile(
          birthDate: DateTime(1996, 9, 26),
          heightCm: 180,
          weightKg: 80,
          activity: ActivityPattern.mixed,
          goal: goal,
        );
    final maintain = DailyTargets.fromProfile(
      withGoal(PersonalGoal.maintain),
      today: today,
    ).calories!;
    final build = DailyTargets.fromProfile(
      withGoal(PersonalGoal.buildStrength),
      today: today,
    );
    final lose = DailyTargets.fromProfile(
      withGoal(PersonalGoal.loseWeight),
      today: today,
    ).calories!;
    expect(build.calories, greaterThan(maintain));
    expect(build.protein, 144);
    expect(lose, lessThan(maintain));
    expect(lose, greaterThanOrEqualTo(1690));
  });
}
