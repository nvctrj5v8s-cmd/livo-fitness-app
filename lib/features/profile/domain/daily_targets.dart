import '../../onboarding/domain/personalization_profile.dart';

enum DailyTargetsStatus {
  ready,
  missingData,
  underage,

  /// Pregnancy, eating disorder or a medically guided diet: no automatic
  /// targets, see `HealthNote`.
  professionalGuidance,
}

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
  const DailyTargets.professionalGuidance()
    : this._(status: DailyTargetsStatus.professionalGuidance);

  final DailyTargetsStatus status;
  final int? calories;
  final int? protein;
  final int? fat;

  bool get isReady => status == DailyTargetsStatus.ready;

  /// Whether Lookin deliberately calculates no targets for this person.
  bool get isPaused =>
      status == DailyTargetsStatus.underage ||
      status == DailyTargetsStatus.professionalGuidance;

  /// Largest daily deficit Lookin suggests, whatever pace was chosen.
  static const maxDeficitShare = 0.2;

  /// Mifflin-St Jeor. Without a stated sex Lookin uses the midpoint of the
  /// female (-161) and male (+5) constants.
  static DailyTargets fromProfile(
    PersonalizationProfile? profile, {
    DateTime? today,
  }) {
    if (profile != null && profile.needsProfessionalGuidance) {
      return const DailyTargets.professionalGuidance();
    }
    final age = profile?.ageOn(today ?? DateTime.now());
    final height = profile?.heightCm;
    final weight = profile?.weightKg;
    if (profile == null || age == null || height == null || weight == null) {
      return const DailyTargets.missingData();
    }
    if (age < 18) return const DailyTargets.underage();

    final sexConstant = switch (profile.sex) {
      BodySex.female => -161,
      BodySex.male => 5,
      BodySex.unspecified || null => -78,
    };
    final bmr = 10 * weight + 6.25 * height - 5 * age + sexConstant;
    final activityFactor = switch (profile.activity) {
      ActivityPattern.mostlySeated => 1.2,
      ActivityPattern.mixed || null => 1.375,
      ActivityPattern.oftenMoving => 1.55,
      ActivityPattern.veryActive => 1.725,
    };
    final maintenance = bmr * activityFactor;
    final rawCalories = switch (profile.goal) {
      PersonalGoal.loseWeight => _reduced(maintenance, bmr, profile.pace),
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

  /// About 7700 kcal per kg of body fat, spread over a week. Never more than
  /// [maxDeficitShare] below maintenance and never below the basal rate.
  static double _reduced(double maintenance, double bmr, WeightPace? pace) {
    if (pace == null) return (maintenance * 0.85).clamp(bmr, maintenance);
    final deficit = pace.kgPerWeek * 7700 / 7;
    final capped = deficit.clamp(0, maintenance * maxDeficitShare);
    return (maintenance - capped).clamp(bmr, maintenance);
  }
}
