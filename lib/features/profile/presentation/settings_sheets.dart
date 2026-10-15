import 'package:fitness_ai_app/l10n/display_text.dart';
import 'package:fitness_ai_app/l10n/l10n.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/config/legal_links.dart';
import '../../../core/config/support_contact.dart';
import '../../../core/state/app_controller.dart';
import '../../consent/presentation/consent_dialogs.dart';
import '../../subscription/presentation/withdrawal_page.dart';
import '../../consent/presentation/consent_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/legal_links_row.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../allergies/presentation/allergy_profile_field.dart';
import 'account_data_actions.dart';

Future<void> showReminderSheet(BuildContext context, AppController controller) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ReminderSheet(controller: controller),
  );
}

Future<void> showNutritionProfileSheet(
  BuildContext context,
  AppController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _NutritionProfileSheet(controller: controller),
  );
}

Future<void> showPrivacySheet(BuildContext context, AppController controller) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PrivacySheet(controller: controller),
  );
}

Future<void> showHelpSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _HelpSheet(),
  );
}

Future<void> showLegalSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _LegalSheet(),
  );
}

/// Impressum and legal texts in one place that users can find by its name.
class _LegalSheet extends StatelessWidget {
  const _LegalSheet();

  @override
  Widget build(BuildContext context) {
    final pages = [
      (Icons.badge_outlined, context.l10n.profileImprint, LegalLinks.imprint),
      (Icons.description_outlined, context.l10n.profileTerms, LegalLinks.terms),
      (
        Icons.privacy_tip_outlined,
        context.l10n.profilePrivacyPolicy,
        LegalLinks.privacy,
      ),
      (
        Icons.undo_rounded,
        context.l10n.profileWithdrawalInformation,
        LegalLinks.withdrawal,
      ),
    ];
    return _SettingsSheetFrame(
      title: context.l10n.profileImprintLegal,
      subtitle: context.l10n.profileOpensInBrowser,
      child: ListView(
        children: [
          SurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (i, (icon, label, uri)) in pages.indexed) ...[
                  if (i > 0) const Divider(height: 1),
                  ListTile(
                    key: Key('legal-sheet-$i'),
                    leading: Icon(icon, color: AppColors.primary),
                    title: Text(label),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                    onTap: () => openExternalLink(context, uri),
                  ),
                ],
                const Divider(height: 1),
                ListTile(
                  key: const Key('legal-sheet-withdraw'),
                  leading: const Icon(
                    Icons.undo_rounded,
                    color: AppColors.error,
                  ),
                  title: Text(context.l10n.profileWithdrawFromContract),
                  subtitle: Text(
                    context.l10n.profileForLookinPremiumWithoutGivingAReason,
                  ),
                  onTap: () =>
                      openWithdrawal(context, name: AppScope.of(context).name),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderSheet extends StatefulWidget {
  const _ReminderSheet({required this.controller});
  final AppController controller;

  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  @override
  Widget build(BuildContext context) {
    return _SettingsSheetFrame(
      title: context.l10n.profileReminders,
      subtitle: context.l10n.profileComingSoon,
      child: ListView(
        children: [
          SurfaceCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.textMuted),
                SizedBox(width: 11),
                Expanded(
                  child: Text(
                    context.l10n.profileMealWaterAndWeeklyReviewRemindersWill,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionProfileSheet extends StatefulWidget {
  const _NutritionProfileSheet({required this.controller});
  final AppController controller;

  @override
  State<_NutritionProfileSheet> createState() => _NutritionProfileSheetState();
}

class _NutritionProfileSheetState extends State<_NutritionProfileSheet> {
  late String _style;
  late String _activity;

  /// Allergies as stored text; edited in the allergy picker.
  late String _allergies;

  @override
  void initState() {
    super.initState();
    _style = widget.controller.nutritionStyle;
    _activity = widget.controller.activityLevel;
    _allergies = widget.controller.hasAllergyProfile
        ? widget.controller.allergies
        : '';
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsSheetFrame(
      title: context.l10n.profileNutritionProfile,
      subtitle: widget.controller.personalization == null
          ? context.l10n.profileYourSavedProfileInformation
          : context.l10n.profileChangeNutritionStyleAndActivityUnderChange,
      child: ListView(
        children: [
          if (widget.controller.personalization == null) ...[
            Text(
              context.l10n.profileNutritionStyle,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ["Ausgewogen", "Vegetarisch", "Vegan", "Low Carb"]
                  .map(
                    (value) => ChoiceChip(
                      label: Text(DisplayText.of(value)),
                      selected: _style == value,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _style = value),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
          AllergyProfileField(
            key: const ValueKey('profile-allergy-options'),
            value: _allergies,
            onChanged: (value) => setState(() => _allergies = value),
          ),
          const SizedBox(height: 20),
          if (widget.controller.personalization == null) ...[
            Text(
              context.l10n.profileActivityLevel,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ["Wenig aktiv", "Moderat aktiv", "Sehr aktiv"]
                  .map(
                    (value) => ChoiceChip(
                      label: Text(DisplayText.of(value)),
                      selected: _activity == value,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _activity = value),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 26),
          FilledButton(
            onPressed: () async {
              final controller = widget.controller;
              final hasAllergies =
                  _allergies.trim().isNotEmpty &&
                  _allergies.trim() !=
                      'Keine angegeben'; // l10n-ignore: canonical empty value
              if (hasAllergies && !controller.consent.healthGranted) {
                await ensureHealthConsent(context, controller.consent);
                if (!context.mounted) return;
              }
              widget.controller.updateNutritionProfile(
                newNutritionStyle: _style,
                newAllergies: _allergies,
                newActivityLevel: _activity,
              );
              Navigator.pop(context);
            },
            child: Text(context.l10n.profileSaveNutritionProfile),
          ),
        ],
      ),
    );
  }
}

class _PrivacySheet extends StatelessWidget {
  const _PrivacySheet({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _SettingsSheetFrame(
      title: context.l10n.profilePrivacyData,
      subtitle: context.l10n.profileTransparentAndUnderYourControl,
      child: ListView(
        children: [
          SurfaceCard(
            child: Column(
              children: [
                _DataRow(
                  icon: Icons.person_outline,
                  label: context.l10n.profileProfileTargets,
                  place: context.l10n.profileInAccount,
                ),
                Divider(height: 25),
                _DataRow(
                  icon: Icons.restaurant_outlined,
                  label: context.l10n.profileMealsNutrition,
                  place: context.l10n.profileInAccount,
                ),
                Divider(height: 25),
                _DataRow(
                  icon: Icons.photo_camera_outlined,
                  label: context.l10n.profileAiPhotoAiChat,
                  place: context.l10n.profileAiService,
                ),
                Divider(height: 25),
                _DataRow(
                  icon: Icons.account_circle_outlined,
                  label: context.l10n.profileProfilePictureReminders,
                  place: context.l10n.profileDeviceOnly,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text(context.l10n.profileLocalDataOverview),
                content: Text(
                  context.l10n.profileLocalOverviewSummary(
                    (controller.name).toString(),
                    (DisplayText.of(controller.goal)).toString(),
                    (controller.meals.length).toString(),
                    (controller.favoriteRecipeIds.length).toString(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(context.l10n.profileClose),
                  ),
                ],
              ),
            ),
            icon: const Icon(Icons.visibility_outlined),
            label: Text(context.l10n.profileViewLocalData),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _confirmDeletion(context),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(context.l10n.profileDeleteLocalDemoData),
          ),
          const SizedBox(height: 14),
          ConsentSettingsCard(controller: controller),
          const SizedBox(height: 14),
          AccountDataActions(subscription: controller.subscription),
          const SizedBox(height: 14),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.profileLegal,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                SizedBox(height: 4),
                LegalLinksRow(alignment: WrapAlignment.start),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            context.l10n.profileYourProfileTargetsAndDiaryAreSaved,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.profileDeleteDemoData),
        content: Text(
          controller.personalizationUserId == null
              ? context.l10n.profileMealsFavouritesListsAndWaterTotalsAre
              : context.l10n.profileSavedListsAndYourWaterTotalAre,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.profileCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(context.l10n.profileDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    controller.clearLocalDemoData();
    Navigator.pop(context);
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.icon,
    required this.label,
    required this.place,
  });
  final IconData icon;
  final String label;
  final String place;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        StatusPill(label: place),
      ],
    );
  }
}

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  Future<void> _writeToSupport(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final opened = await SupportContact.open(
      subject: l10n.profileSupportMailSubject,
    );
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.profileSupportMailNotOpened(SupportContact.email)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsSheetFrame(
      title: context.l10n.profileHelpSafety,
      subtitle: context.l10n.profileHealthAlwaysComesBeforeTracking,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _HelpCard(
              icon: Icons.health_and_safety_outlined,
              color: AppColors.primary,
              title: context.l10n.profileNotMedicalAdvice,
              text: context.l10n.profileLookinSupportsHabitsButDoesNotDiagnose,
            ),
            SizedBox(height: 10),
            _HelpCard(
              icon: Icons.favorite_border_rounded,
              color: AppColors.error,
              title: context.l10n.profileEatingDisorderOrAcuteSymptoms,
              text: context.l10n.profileDoNotFollowDietOrCalorieTargets,
            ),
            SizedBox(height: 10),
            _HelpCard(
              icon: Icons.balance_outlined,
              color: AppColors.blue,
              title: context.l10n.profileNumbersAreAGuide,
              text:
                  context.l10n.profileNutritionValuesAndTargetsAreEstimatesAlso,
            ),
            const SizedBox(height: 10),
            _HelpCard(
              icon: Icons.mail_outline_rounded,
              color: AppColors.mint,
              title: context.l10n.profileContactSupport,
              text: context.l10n.profileContactSupportText,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              key: const Key('help-contact-support'),
              onPressed: () => _writeToSupport(context),
              icon: const Icon(Icons.send_rounded),
              label: const Text(SupportContact.email),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSheetFrame extends StatelessWidget {
  const _SettingsSheetFrame({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final height = math.min(MediaQuery.sizeOf(context).height * 0.84, 720.0);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              20 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      tooltip: context.l10n.profileClose,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
