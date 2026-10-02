import '../../../core/state/app_controller.dart';

/// App data the coach receives with each question, as documented in
/// `docs/AI_COACH_PRIVACY.md`: goal, daily targets, today's diary totals,
/// nutrition style, allergies and activity level. Never name, e-mail or
/// account ID.
///
/// Today's totals come from today's diary (not the day currently open in the
/// diary). While today's diary is loading or failed to load they are left
/// out, so the coach never works with made-up zeros.
Map<String, Object?> coachContextFor(AppController app, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final diaryShowsToday =
      app.diaryDate.year == today.year &&
      app.diaryDate.month == today.month &&
      app.diaryDate.day == today.day;
  final todayUnknown =
      diaryShowsToday && (app.diaryLoading || app.diaryError != null);
  // Under 18 or a stated health situation: Lookin calculates no targets, so
  // the coach gets none either. The reason itself is not sent.
  final targetsPaused = app.dailyTargets.isPaused;
  final profile = app.personalization;
  return {
    'goal': app.goal,
    if (targetsPaused)
      'calorie_targets_paused': true
    else ...{
      'calorie_goal': app.calorieGoal,
      'protein_goal': app.proteinGoal,
    },
    if (!todayUnknown) ...{
      'calories_today': app.consumedCalories,
      if (!targetsPaused) 'remaining_calories': app.remainingCalories,
      'protein_today': app.consumedProtein,
      'carbs_today': app.consumedCarbs,
      'fat_today': app.consumedFat,
    },
    'nutrition_style': app.nutritionStyle,
    'allergies': app.allergies,
    'activity_level': app.activityLevel,
    if (profile != null && profile.motivations.isNotEmpty)
      'motivations': [for (final value in profile.motivations) value.label],
    if (profile != null && profile.obstacles.isNotEmpty)
      'obstacles': [for (final value in profile.obstacles) value.label],
    if (profile?.experience case final experience?)
      'tracking_experience': experience.label,
  };
}
