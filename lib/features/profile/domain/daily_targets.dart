import '../../onboarding/domain/personalization_profile.dart';

enum DailyTargetsStatus { ready, missingData, underage }

/// Orientation values only; not a medical or dietary prescription.
class DailyTargets {
  const DailyTargets._({
    required this.status,
    this.calories,
    this.protein,
    this.fat,
  });

  const DailyTargets.missingData()
    : this._(status: DailyTargetsStatus.missingData);
  const DailyTargets.underage() : this._(status: DailyTargetsStatus.underage);

  final DailyTargetsStatus status;
  final int? calories;
  final int? protein;
  final int? fat;

  bool get isReady => status == DailyTargetsStatus.ready;

  /// Mifflin-St Jeor with a sex-neutral constant (midpoint of +5 and -161),
  /// because LIVO does not ask for sex.
  static DailyTargets fromProfile(
    PersonalizationProfile? profile, {
    DateTime? today,
  }) {
    final age = profile?.ageOn(today ?? DateTime.now());
    final height = profile?.heightCm;
    final weight = profile?.weightKg;
    if (profile == null || age == null || height == null || weight == null) {
      return const DailyTargets.missingData();
    }
    if (age < 18) return const DailyTargets.underage();

    final bmr = 10 * weight + 6.25 * height - 5 * age - 78;
    final activityFactor = switch (profile.activity) {
      ActivityPattern.mostlySeated => 1.2,
      ActivityPattern.mixed || null => 1.375,
      ActivityPattern.oftenMoving => 1.55,
      ActivityPattern.veryActive => 1.725,
    };
    final maintenance = bmr * activityFactor;
    final rawCalories = switch (profile.goal) {
      PersonalGoal.loseWeight => (maintenance * 0.85).clamp(bmr, maintenance),
      PersonalGoal.buildStrength => maintenance * 1.1,
      PersonalGoal.maintain || PersonalGoal.balanced || null => maintenance,
    };
    final calories = (rawCalories / 10).round() * 10;

    final proteinPerKg = switch (profile.goal) {
      PersonalGoal.loseWeight || PersonalGoal.buildStrength => 1.8,
      _ => 1.2,
    };
    final protein = (weight * proteinPerKg).clamp(0, 180).round();
    final fat = (calories * 0.3 / 9).round();

    return DailyTargets._(
      status: DailyTargetsStatus.ready,
      calories: calories,
      protein: protein,
      fat: fat,
    );
  }
}
