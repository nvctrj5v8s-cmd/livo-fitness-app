/// Versioned preferences, separate from medical data and from UI wording.
/// Stable enum names can also be used by a future English interface.
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
    );
  }

  String get routineLabel => desiredMeals == null
      ? 'Dein Rhythmus bleibt flexibel'
      : '$desiredMeals Mahlzeiten passen in deinen Tag';

  List<String> get summaryLines => [
    if (goal != null) 'Dein Fokus: ${goal!.label.toLowerCase()}.',
    if (activity != null) 'Dein Alltag: ${activity!.label.toLowerCase()}.',
    if (usualMeals != null &&
        desiredMeals != null &&
        usualMeals != desiredMeals)
      'Bisher $usualMeals, künftig lieber $desiredMeals Mahlzeiten. Dein Tagebuch erinnert dich an deinen Wunsch.'
    else
      desiredMeals == null
          ? 'Du entscheidest jeden Tag, wie viele Mahlzeiten dir passen.'
          : 'Dein Tagebuch zeigt deinen Wunsch nach $desiredMeals Mahlzeiten – ohne feste Essenszeiten.',
    if (nutrition != null && nutrition != NutritionPreference.mixed)
      'Passend gekennzeichnete ${nutrition!.label.toLowerCase()} Rezeptideen erscheinen zuerst.',
    if (allergies.trim().isNotEmpty)
      'Dein Coach berücksichtigt: ${allergies.trim()}.',
    if (cookingMinutes != null)
      'Rezepte bis $cookingMinutes Minuten bekommen Vorrang, wenn passende vorhanden sind.',
    if (focus == RoutineFocus.budget)
      'Als Budget-Rezept markierte Ideen rücken nach vorne.',
    if (focus == RoutineFocus.time && cookingMinutes == null)
      'Schnelle Rezepte bis 15 Minuten rücken nach vorne.',
    if (focus == RoutineFocus.consistency)
      'Dein Mahlzeitenrhythmus bleibt auf der Startseite sichtbar.',
    if (focus == RoutineFocus.ideas)
      'Deine Startseite führt dich direkt zu den Rezeptideen.',
  ];

  /// Prepared context only: no network call, API key or consent is implied.
  /// Name/account identity intentionally omitted. Any future AI integration
  /// must request permission and establish suitability before dietary advice.
  Map<String, Object?> toPreferenceContext() => {
    'schema_version': 1,
    'locale': 'de',
    'goal': goal?.name,
    'activity_pattern': activity?.name,
    'usual_meals': usualMeals,
    'desired_meals': desiredMeals,
    'nutrition_preference': nutrition?.name,
    'allergies': allergies.trim().isEmpty ? null : allergies.trim(),
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
