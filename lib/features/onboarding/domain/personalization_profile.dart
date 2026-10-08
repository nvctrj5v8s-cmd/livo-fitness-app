/// Stable enum names support a later English UI without changing saved data.
enum PersonalGoal {
  balanced('Gesünder essen'),
  loseWeight('Fett verlieren'),
  maintain('Gewicht halten'),
  buildStrength('Muskeln aufbauen');

  const PersonalGoal(this.label);
  final String label;
}

enum ActivityPattern {
  mostlySeated('Meist sitzend'),
  mixed('Mal so, mal so'),
  oftenMoving('Viel in Bewegung'),
  veryActive('Sehr aktiv');

  const ActivityPattern(this.label);
  final String label;
}

enum NutritionPreference {
  mixed('Gemischt'),
  vegetarian('Vegetarisch'),
  vegan('Vegan'),
  pescatarian('Mit Fisch, ohne Fleisch');

  const NutritionPreference(this.label);
  final String label;
}

enum MeasurementSystem { metric, imperial }

/// Older optional preferences are kept so existing accounts continue to work.
enum RoutineFocus {
  time('Wenig Zeit'),
  ideas('Neue Essensideen'),
  consistency('Mehr Regelmäßigkeit'),
  budget('Aufs Budget achten');

  const RoutineFocus(this.label);
  final String label;
}

/// Only used for the energy estimate (Mifflin-St Jeor). Without an answer
/// Lookin keeps the sex-neutral midpoint.
enum BodySex {
  female('Weiblich'),
  male('Männlich'),
  unspecified('Möchte ich nicht angeben');

  const BodySex(this.label);
  final String label;
}

/// How fast a weight goal may be approached. Deliberately no faster option
/// than about 0.5 kg per week.
enum WeightPace {
  gentle('Sanft', 0.25),
  steady('Ausgewogen', 0.5);

  const WeightPace(this.label, this.kgPerWeek);
  final String label;
  final double kgPerWeek;
}

enum Motivation {
  health('Gesünder leben'),
  energy('Mehr Energie im Alltag'),
  wellbeing('Wohler im eigenen Körper'),
  fitness('Sportlich stärker werden'),
  habits('Bessere Gewohnheiten'),
  rolemodel('Vorbild für Familie & Kinder');

  const Motivation(this.label);
  final String label;
}

enum Obstacle {
  cravings('Heißhunger & Naschen'),
  time('Wenig Zeit zum Kochen'),
  irregular('Unregelmäßige Mahlzeiten'),
  eatingOut('Viel unterwegs essen'),
  motivation('Motivation hält nicht lange'),
  knowledge('Unsicher, was gut für mich ist'),
  stress('Essen bei Stress');

  const Obstacle(this.label);
  final String label;
}

enum TrackingExperience {
  none('Noch nie'),
  some('Schon mal ausprobiert'),
  regular('Ja, regelmäßig');

  const TrackingExperience(this.label);
  final String label;
}

/// Situations in which Lookin must not calculate calorie targets on its own
/// (project rule: pregnancy, eating disorders, relevant illnesses). Stored
/// only on this device and never sent to the coach in detail.
enum HealthNote {
  pregnantOrNursing('Schwanger oder stillend'),
  eatingDisorder('Essstörung – aktuell oder früher'),
  medicalDiet('Erkrankung, bei der die Ernährung ärztlich begleitet wird');

  const HealthNote(this.label);
  final String label;
}

const _unchanged = Object();

class PersonalizationProfile {
  const PersonalizationProfile({
    this.displayName = '',
    this.goal,
    this.activity,
    this.usualMeals,
    this.desiredMeals,
    this.nutrition,
    this.allergies = '',
    this.cookingMinutes,
    this.focus,
    this.birthDate,
    this.heightCm,
    this.weightKg,
    this.measurementSystem = MeasurementSystem.metric,
    this.sex,
    this.targetWeightKg,
    this.pace,
    this.motivations = const {},
    this.obstacles = const {},
    this.experience,
    this.healthNotes = const {},
  });

  final String displayName;
  final PersonalGoal? goal;
  final ActivityPattern? activity;
  final int? usualMeals;
  final int? desiredMeals;
  final NutritionPreference? nutrition;
  final String allergies;
  final int? cookingMinutes;
  final RoutineFocus? focus;

  /// Optional physical data, saved only on this device with the preferences.
  final DateTime? birthDate;
  final int? heightCm;
  final double? weightKg;
  final MeasurementSystem measurementSystem;

  final BodySex? sex;

  /// Only asked for weight goals; never below a BMI of 18.5 (see
  /// [lowestHealthyWeightKg]).
  final double? targetWeightKg;
  final WeightPace? pace;
  final Set<Motivation> motivations;
  final Set<Obstacle> obstacles;
  final TrackingExperience? experience;

  /// Any entry pauses automatic calorie targets.
  final Set<HealthNote> healthNotes;

  bool get needsProfessionalGuidance => healthNotes.isNotEmpty;

  /// Whether anything was answered that Lookin adapts to. The name alone is
  /// only a greeting.
  bool get hasAnswers =>
      goal != null ||
      sex != null ||
      birthDate != null ||
      heightCm != null ||
      weightKg != null ||
      activity != null ||
      nutrition != null ||
      allergies.trim().isNotEmpty ||
      cookingMinutes != null ||
      motivations.isNotEmpty ||
      obstacles.isNotEmpty ||
      experience != null ||
      healthNotes.isNotEmpty;

  bool get hasWeightGoal =>
      goal == PersonalGoal.loseWeight || goal == PersonalGoal.buildStrength;

  /// Weight at a BMI of 18.5 for [heightCm], rounded up to 0.5 kg.
  double? get lowestHealthyWeightKg {
    final height = heightCm;
    if (height == null) return null;
    final meters = height / 100;
    return (18.5 * meters * meters * 2).ceil() / 2;
  }

  /// Pace assumed when gaining weight with training: about 0.8 kg per month.
  /// The calorie plan adds 10 % on top of maintenance (about 0.25 kg per week
  /// if everything were stored), but part of a surplus is not stored as body
  /// mass, so the estimate uses a bit less. Fat loss uses [WeightPace].
  static const gainKgPerWeek = 0.2;

  /// Rough number of weeks to the target weight at the chosen pace, or
  /// `null` without enough data. An estimate, never a promise.
  int? weeksToTarget() {
    final current = weightKg;
    final target = targetWeightKg;
    final rate = (pace ?? WeightPace.gentle).kgPerWeek;
    if (current == null || target == null || !hasWeightGoal) return null;
    final difference = (current - target).abs();
    if (difference < 0.5) return 0;
    final weekly = goal == PersonalGoal.buildStrength ? gainKgPerWeek : rate;
    return (difference / weekly).ceil();
  }

  int? ageOn(DateTime date) {
    final birthday = birthDate;
    if (birthday == null) return null;
    var age = date.year - birthday.year;
    if (date.month < birthday.month ||
        (date.month == birthday.month && date.day < birthday.day)) {
      age--;
    }
    return age < 0 ? null : age;
  }

  PersonalizationProfile copyWith({
    String? displayName,
    Object? goal = _unchanged,
    Object? activity = _unchanged,
    Object? usualMeals = _unchanged,
    Object? desiredMeals = _unchanged,
    Object? nutrition = _unchanged,
    String? allergies,
    Object? cookingMinutes = _unchanged,
    Object? focus = _unchanged,
    Object? birthDate = _unchanged,
    Object? heightCm = _unchanged,
    Object? weightKg = _unchanged,
    MeasurementSystem? measurementSystem,
    Object? sex = _unchanged,
    Object? targetWeightKg = _unchanged,
    Object? pace = _unchanged,
    Set<Motivation>? motivations,
    Set<Obstacle>? obstacles,
    Object? experience = _unchanged,
    Set<HealthNote>? healthNotes,
  }) => PersonalizationProfile(
    sex: identical(sex, _unchanged) ? this.sex : sex as BodySex?,
    targetWeightKg: identical(targetWeightKg, _unchanged)
        ? this.targetWeightKg
        : targetWeightKg as double?,
    pace: identical(pace, _unchanged) ? this.pace : pace as WeightPace?,
    motivations: motivations ?? this.motivations,
    obstacles: obstacles ?? this.obstacles,
    experience: identical(experience, _unchanged)
        ? this.experience
        : experience as TrackingExperience?,
    healthNotes: healthNotes ?? this.healthNotes,
    displayName: displayName ?? this.displayName,
    goal: identical(goal, _unchanged) ? this.goal : goal as PersonalGoal?,
    activity: identical(activity, _unchanged)
        ? this.activity
        : activity as ActivityPattern?,
    usualMeals: identical(usualMeals, _unchanged)
        ? this.usualMeals
        : usualMeals as int?,
    desiredMeals: identical(desiredMeals, _unchanged)
        ? this.desiredMeals
        : desiredMeals as int?,
    nutrition: identical(nutrition, _unchanged)
        ? this.nutrition
        : nutrition as NutritionPreference?,
    allergies: allergies ?? this.allergies,
    cookingMinutes: identical(cookingMinutes, _unchanged)
        ? this.cookingMinutes
        : cookingMinutes as int?,
    focus: identical(focus, _unchanged) ? this.focus : focus as RoutineFocus?,
    birthDate: identical(birthDate, _unchanged)
        ? this.birthDate
        : birthDate as DateTime?,
    heightCm: identical(heightCm, _unchanged)
        ? this.heightCm
        : heightCm as int?,
    weightKg: identical(weightKg, _unchanged)
        ? this.weightKg
        : weightKg as double?,
    measurementSystem: measurementSystem ?? this.measurementSystem,
  );

  Map<String, Object?> toJson() => {
    'version': 1,
    'display_name': displayName.trim(),
    'goal': goal?.name,
    'activity': activity?.name,
    'usual_meals': usualMeals,
    'desired_meals': desiredMeals,
    'nutrition': nutrition?.name,
    'allergies': allergies.trim(),
    'cooking_minutes': cookingMinutes,
    'focus': focus?.name,
    if (birthDate != null) 'birth_date': _dateString(birthDate!),
    if (heightCm != null) 'height_cm': heightCm,
    if (weightKg != null) 'weight_kg': weightKg,
    if (birthDate != null ||
        heightCm != null ||
        weightKg != null ||
        measurementSystem != MeasurementSystem.metric)
      'measurement_system': measurementSystem.name,
    if (sex != null) 'sex': sex!.name,
    if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
    if (pace != null) 'pace': pace!.name,
    if (motivations.isNotEmpty)
      'motivations': [for (final value in motivations) value.name],
    if (obstacles.isNotEmpty)
      'obstacles': [for (final value in obstacles) value.name],
    if (experience != null) 'experience': experience!.name,
    if (healthNotes.isNotEmpty)
      'health_notes': [for (final value in healthNotes) value.name],
  };

  factory PersonalizationProfile.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1) {
      throw const FormatException('Unsupported preferences version');
    }
    final name = json['display_name'] is String
        ? (json['display_name'] as String).trim()
        : '';
    final allergies = json['allergies'] is String
        ? (json['allergies'] as String).trim()
        : '';
    return PersonalizationProfile(
      displayName: name.length <= 40 ? name : name.substring(0, 40),
      goal: _enumValue(PersonalGoal.values, json['goal']),
      activity: _enumValue(ActivityPattern.values, json['activity']),
      usualMeals: _allowedInt(json['usual_meals'], const [2, 3, 4, 5]),
      desiredMeals: _allowedInt(json['desired_meals'], const [2, 3, 4, 5]),
      nutrition: _enumValue(NutritionPreference.values, json['nutrition']),
      allergies: allergies.length <= 500
          ? allergies
          : allergies.substring(0, 500),
      cookingMinutes: _allowedInt(json['cooking_minutes'], const [15, 30, 45]),
      focus: _enumValue(RoutineFocus.values, json['focus']),
      birthDate: _dateValue(json['birth_date']),
      heightCm: _boundedInt(json['height_cm'], 90, 250),
      weightKg: _boundedDouble(json['weight_kg'], 25, 400),
      sex: _enumValue(BodySex.values, json['sex']),
      targetWeightKg: _boundedDouble(json['target_weight_kg'], 25, 400),
      pace: _enumValue(WeightPace.values, json['pace']),
      motivations: _enumSet(Motivation.values, json['motivations']),
      obstacles: _enumSet(Obstacle.values, json['obstacles']),
      experience: _enumValue(TrackingExperience.values, json['experience']),
      healthNotes: _enumSet(HealthNote.values, json['health_notes']),
      measurementSystem:
          _enumValue(MeasurementSystem.values, json['measurement_system']) ??
          MeasurementSystem.metric,
    );
  }

  String get routineLabel => desiredMeals == null
      ? 'Dein Rhythmus bleibt flexibel'
      : '$desiredMeals Mahlzeiten passen in deinen Tag';

  List<String> get summaryLines => [
    if (goal != null) 'Dein Fokus: ${goal!.label.toLowerCase()}.',
    if (activity != null) 'Dein Alltag: ${activity!.label.toLowerCase()}.',
    if (nutrition != null && nutrition != NutritionPreference.mixed)
      'Passend gekennzeichnete ${nutrition!.label.toLowerCase()} Rezeptideen erscheinen zuerst.',
    if (allergies.trim().isNotEmpty)
      'Dein Coach berücksichtigt: ${allergies.trim()}.',
    if (cookingMinutes != null)
      'Rezepte bis $cookingMinutes Minuten bekommen Vorrang, wenn passende vorhanden sind.',
    if (focus == RoutineFocus.budget)
      'Als Budget-Rezept markierte Ideen rücken nach vorne.',
  ];

  /// Context is prepared locally. It is only included with an AI request when
  /// the user actively uses the in-app coach.
  Map<String, Object?> toPreferenceContext() => {
    'schema_version': 1,
    'locale': 'de',
    'goal': goal?.name,
    'activity_pattern': activity?.name,
    'usual_meals': usualMeals,
    'desired_meals': desiredMeals,
    'nutrition_preference': nutrition?.name,
    'allergies': allergies.trim().isEmpty ? null : allergies.trim(),
    'age': ageOn(DateTime.now()),
    'height_cm': heightCm,
    'weight_kg': weightKg,
    'measurement_system': measurementSystem.name,
    'cooking_minutes': cookingMinutes,
    'routine_focus': focus?.name,
    'suitability_screening': 'not_performed',
    'allow_medical_advice': false,
    'allow_automatic_calorie_targets': false,
  };
}

T? _enumValue<T extends Enum>(List<T> values, Object? raw) {
  for (final value in values) {
    if (value.name == raw) return value;
  }
  return null;
}

Set<T> _enumSet<T extends Enum>(List<T> values, Object? raw) => {
  if (raw is List)
    for (final item in raw)
      if (_enumValue(values, item) case final T value) value,
};

int? _allowedInt(Object? raw, List<int> allowed) =>
    raw is int && allowed.contains(raw) ? raw : null;

int? _boundedInt(Object? raw, int min, int max) =>
    raw is int && raw >= min && raw <= max ? raw : null;

double? _boundedDouble(Object? raw, double min, double max) {
  final value = raw is num ? raw.toDouble() : null;
  return value != null && value >= min && value <= max ? value : null;
}

DateTime? _dateValue(Object? raw) {
  if (raw is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) {
    return null;
  }
  final parsed = DateTime.tryParse(raw);
  if (parsed == null || parsed.year < 1900 || parsed.isAfter(DateTime.now())) {
    return null;
  }
  return DateTime(parsed.year, parsed.month, parsed.day);
}

String _dateString(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
