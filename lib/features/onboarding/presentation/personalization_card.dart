import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';
import '../domain/personalization_profile.dart';
import 'personalization_entry.dart';

class PersonalizationCard extends StatelessWidget {
  const PersonalizationCard({
    this.profileMode = false,
    this.onRecipes,
    super.key,
  });
  final bool profileMode;
  final VoidCallback? onRecipes;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final profile = controller.personalization;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tune_rounded, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            profile == null
                ? context.l10n.onboardingYourDayYourLookin
                : context.l10n.onboardingMakeLookinFitYou,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            profile == null
                ? context.l10n.onboardingHowDoYouLikeToEatSet
                : profile.routineLabel,
            style: const TextStyle(color: AppColors.text, height: 1.4),
          ),
          if (profile != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (profile.goal != null) _PreferenceTag(profile.goal!.label),
                if (profile.nutrition != null)
                  _PreferenceTag(profile.nutrition!.label),
                if (profile.cookingMinutes != null)
                  _PreferenceTag(
                    context.l10n.onboardingUpToValueMin(
                      (profile.cookingMinutes).toString(),
                    ),
                  ),
                if (profile.activity != null)
                  _PreferenceTag(profile.activity!.label),
                if (profile.allergies.trim().isNotEmpty)
                  _PreferenceTag(profile.allergies.trim()),
              ],
            ),
            if (profileMode) ...[
              const SizedBox(height: 12),
              for (final line in profile.summaryLines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    line,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
            ],
            if (!profileMode) ...[
              const SizedBox(height: 12),
              Text(
                _dailyHint(profile),
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (onRecipes != null && profile != null)
                FilledButton.tonalIcon(
                  onPressed: onRecipes,
                  icon: const Icon(Icons.restaurant_menu_rounded),
                  label: Text(context.l10n.onboardingViewRecipeIdeas),
                ),
              TextButton.icon(
                key: const ValueKey('personalization-edit'),
                onPressed: () => openPersonalizationEditor(context),
                icon: const Icon(Icons.edit_outlined),
                label: Text(
                  profile == null
                      ? context.l10n.onboardingPersonalise
                      : context.l10n.onboardingChangeAnswers,
                ),
              ),
              if (profileMode && profile != null)
                TextButton(
                  key: const ValueKey('personalization-remove'),
                  onPressed: () => _remove(context, controller),
                  child: Text(context.l10n.onboardingRemoveAnswers),
                ),
            ],
          ),
          if (profileMode)
            Text(
              context.l10n.onboardingYourOptionalInformationHelpsLookinAndThe,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
        ],
      ),
    );
  }

  String _dailyHint(PersonalizationProfile profile) => switch (profile.focus) {
    RoutineFocus.time =>
      L10n.current.onboardingShortOnTimeTodayQuickMealsAppear,
    RoutineFocus.budget =>
      L10n.current.onboardingIdeasMarkedAsBudgetRecipesAppearHigher,
    RoutineFocus.consistency => L10n.current.onboardingYourRhythmIsAGuideYouCan,
    _ =>
      profile.cookingMinutes != null
          ? L10n.current.onboardingYourRecipeIdeasTakeYourCookingTime
          : L10n.current.onboardingYourRecipeIdeasReflectThePreferencesYou,
  };

  Future<void> _remove(BuildContext context, AppController controller) async {
    try {
      await controller.clearPersonalization();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.onboardingYourSetupAnswersHaveBeenRemovedFrom,
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.onboardingRemovalDidNotWorkPleaseTryAgain,
            ),
          ),
        );
      }
    }
  }
}

class _PreferenceTag extends StatelessWidget {
  const _PreferenceTag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.08),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      label,
      style: const TextStyle(color: AppColors.text, fontSize: 12),
    ),
  );
}
