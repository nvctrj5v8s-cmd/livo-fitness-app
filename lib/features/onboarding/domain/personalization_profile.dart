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
  }) => PersonalizationProfile(
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
      allergies: allergies.length <= 160
          ? allergies
          : allergies.substring(0, 160),
      cookingMinutes: _allowedInt(json['cooking_minutes'], const [15, 30, 45]),
      focus: _enumValue(RoutineFocus.values, json['focus']),
      birthDate: _dateValue(json['birth_date']),
      heightCm: _boundedInt(json['height_cm'], 90, 250),
      weightKg: _boundedDouble(json['weight_kg'], 25, 400),
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
