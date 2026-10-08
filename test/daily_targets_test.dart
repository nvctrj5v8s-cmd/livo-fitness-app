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

  test('Geschlecht verfeinert den Grundumsatz', () {
    PersonalizationProfile person(BodySex? sex) => PersonalizationProfile(
      birthDate: DateTime(1996, 9, 26),
      heightCm: 180,
      weightKg: 80,
      activity: ActivityPattern.mixed,
      goal: PersonalGoal.maintain,
      sex: sex,
    );
    int calories(BodySex? sex) =>
        DailyTargets.fromProfile(person(sex), today: today).calories!;
    // BMR male = 1697 + 83 = 1780 -> * 1.375 = 2447.5; female = 1614 -> 2219
    expect(calories(BodySex.male), 2450);
    expect(calories(BodySex.female), 2220);
    expect(calories(BodySex.unspecified), calories(null));
  });

  test('Tempo bestimmt das Defizit, höchstens 20 Prozent', () {
    PersonalizationProfile person(WeightPace pace) => PersonalizationProfile(
      birthDate: DateTime(1996, 9, 26),
      heightCm: 180,
      weightKg: 80,
      activity: ActivityPattern.mixed,
      goal: PersonalGoal.loseWeight,
      pace: pace,
    );
    final gentle = DailyTargets.fromProfile(
      person(WeightPace.gentle),
      today: today,
    ).calories!;
    final steady = DailyTargets.fromProfile(
      person(WeightPace.steady),
      today: today,
    ).calories!;
    // Maintenance 2333: 0,25 kg -> -275 kcal; 0,5 kg -> -550, capped at -467.
    expect(gentle, 2060);
    expect(steady, 1870);
  });

  test('Gesundheitshinweis: keine automatischen Ziele', () {
    final targets = DailyTargets.fromProfile(
      PersonalizationProfile(
        birthDate: DateTime(1996, 9, 26),
        heightCm: 180,
        weightKg: 80,
        goal: PersonalGoal.loseWeight,
        healthNotes: const {HealthNote.pregnantOrNursing},
      ),
      today: today,
    );
    expect(targets.status, DailyTargetsStatus.professionalGuidance);
    expect(targets.isPaused, isTrue);
    expect(targets.calories, isNull);
  });

  test('Zielgewicht: Untergrenze BMI 18,5 und grobe Wochenzahl', () {
    const profile = PersonalizationProfile(
      heightCm: 175,
      weightKg: 80,
      goal: PersonalGoal.loseWeight,
      targetWeightKg: 75,
      pace: WeightPace.gentle,
    );
    expect(profile.lowestHealthyWeightKg, 57);
    expect(profile.weeksToTarget(), 20);
  });

  test('Zunehmen: Wochenzahl nutzt 0,2 kg pro Woche, nicht die Hälfte', () {
    const profile = PersonalizationProfile(
      heightCm: 178,
      weightKg: 70,
      goal: PersonalGoal.buildStrength,
      targetWeightKg: 75,
    );
    expect(PersonalizationProfile.gainKgPerWeek, 0.2);
    // 5 kg / 0,2 kg = 25 Wochen (gut ein halbes Jahr), nicht fast ein Jahr.
    expect(profile.weeksToTarget(), 25);
    // Abnehmen bleibt unverändert beim gewählten Tempo.
    const lose = PersonalizationProfile(
      weightKg: 80,
      goal: PersonalGoal.loseWeight,
      targetWeightKg: 75,
      pace: WeightPace.steady,
    );
    expect(lose.weeksToTarget(), 10);
  });
}
