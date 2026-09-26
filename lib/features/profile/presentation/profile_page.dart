import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_reveal.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../onboarding/presentation/personalization_card.dart';
import '../../onboarding/presentation/personalization_entry.dart';
import '../domain/daily_targets.dart';
import 'avatar_editor.dart';
import 'settings_sheets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return SingleChildScrollView(
      key: const PageStorageKey('profile-scroll'),
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileTopBar(
                  onEdit: () => _openEditProfile(context, controller),
                ),
                const SizedBox(height: 14),
                AnimatedReveal(child: _ProfileIdentity(controller: controller)),
                const SizedBox(height: 22),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 70),
                  child: _TodayStats(controller: controller),
                ),
                const SizedBox(height: 26),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 140),
                  child: SectionHeader(title: 'Meine täglichen Ziele'),
                ),
                const SizedBox(height: 11),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 190),
                  child: _DailyGoals(controller: controller),
                ),
                const SizedBox(height: 20),
                const PersonalizationCard(profileMode: true),
                const SizedBox(height: 25),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 250),
                  child: SectionHeader(title: 'Ernährungsprofil'),
                ),
                const SizedBox(height: 11),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 300),
                  child: _NutritionProfile(controller: controller),
                ),
                const SizedBox(height: 25),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 360),
                  child: SectionHeader(title: 'App & Datenschutz'),
                ),
                const SizedBox(height: 11),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 410),
                  child: _SettingsList(controller: controller),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openEditProfile(BuildContext context, AppController controller) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _EditProfileSheet(controller: controller),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.onEdit});
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const SizedBox(width: 48),
      Expanded(
        child: Text(
          'Profil',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      IconButton.filledTonal(
        onPressed: onEdit,
        tooltip: 'Profil bearbeiten',
        icon: const Icon(Icons.tune_rounded, size: 20),
      ),
    ],
  );
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final goal =
        controller.personalization?.goal?.label ??
        (controller.personalization == null ? controller.goal : null);
    return Column(
      children: [
        const _EditableAvatar(),
        const SizedBox(height: 16),
        Text(
          controller.greetingName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        if (goal != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.flag_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  goal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          )
        else
          const Text(
            'Noch kein Ziel gewählt',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
      ],
    );
  }
}

class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.mint],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 30,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            child: AppAvatar(
              radius: 54,
              onTap: () => showAvatarEditor(context),
              semanticLabel: 'Profilbild ändern',
            ),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: ExcludeSemantics(
            child: GestureDetector(
              onTap: () => showAvatarEditor(context),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: AppColors.background, width: 3),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TodayStats extends StatelessWidget {
  const _TodayStats({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final entries = controller.diaryMeals.length;
    final streak = controller.streakDays;
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatColumn(
                icon: Icons.checklist_rounded,
                color: AppColors.mint,
                value: '$entries',
                label: entries == 1 ? 'Eintrag heute' : 'Einträge heute',
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.border),
            Expanded(
              child: _StatColumn(
                icon: Icons.local_fire_department_rounded,
                color: AppColors.orange,
                value: controller.streakLoading ? '–' : '$streak',
                label: streak == 1 ? 'Tag Serie' : 'Tage Serie',
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.border),
            Expanded(
              child: _StatColumn(
                icon: Icons.restaurant_rounded,
                color: AppColors.primary,
                value: _formatThousands(controller.diaryConsumedCalories),
                label: 'kcal heute',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    ),
  );
}

String _formatThousands(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

class _DailyGoals extends StatelessWidget {
  const _DailyGoals({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final targets = controller.dailyTargets;
    final ready = targets.isReady;
    final note = switch (targets.status) {
      DailyTargetsStatus.ready =>
        'Diese Richtwerte berechnen wir aus deinem Alter, deiner Größe, '
            'deinem Gewicht und deinem Alltag. Sie dienen zur Orientierung '
            'und ersetzen keine ärztliche Beratung.',
      DailyTargetsStatus.missingData =>
        'Deine Tagesziele berechnen wir aus deinem Alter, deiner Größe, '
            'deinem Gewicht und deinem Alltag. Wenn du möchtest, beantworte '
            'dazu ein paar kurze Fragen. Du kannst LIVO aber auch ganz ohne '
            'Ziele nutzen.',
      DailyTargetsStatus.underage =>
        'Für Personen unter 18 Jahren berechnet LIVO keine Kalorienziele. '
            'Bei Fragen zur Ernährung wende dich bitte an eine Ärztin, einen '
            'Arzt oder eine Ernährungsfachkraft.',
    };
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _TargetTile(
                  key: const Key('daily-goal-calories'),
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.orange,
                  value: ready ? _formatThousands(targets.calories!) : '–',
                  unit: 'kcal',
                  label: 'Kalorien',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TargetTile(
                  key: const Key('daily-goal-protein'),
                  icon: Icons.egg_alt_rounded,
                  color: AppColors.mint,
                  value: ready ? '${targets.protein}' : '–',
                  unit: 'g',
                  label: 'Protein',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TargetTile(
                  key: const Key('daily-goal-fat'),
                  icon: Icons.water_drop_rounded,
                  color: AppColors.blue,
                  value: ready ? '${targets.fat}' : '–',
                  unit: 'g',
                  label: 'Fett',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  note,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          if (targets.status != DailyTargetsStatus.underage) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: ready
                  ? TextButton.icon(
                      onPressed: () => openPersonalizationEditor(context),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Angaben ändern'),
                    )
                  : FilledButton.tonalIcon(
                      key: const Key('daily-goals-answer'),
                      onPressed: () => openPersonalizationEditor(context),
                      icon: const Icon(Icons.quiz_outlined, size: 18),
                      label: const Text('Fragen beantworten'),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TargetTile extends StatelessWidget {
  const _TargetTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.unit,
    required this.label,
    super.key,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(11, 12, 8, 12),
    decoration: BoxDecoration(
      color: AppColors.surfaceSoft,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 9),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (value != '–')
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            style: const TextStyle(color: AppColors.text),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    ),
  );
}

class _NutritionProfile extends StatelessWidget {
  const _NutritionProfile({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _ProfileRow(
            icon: Icons.restaurant_outlined,
            title: 'Ernährungsstil',
            value: controller.personalization == null
                ? controller.nutritionStyle
                : controller.personalization!.nutrition?.label ?? 'Noch offen',
            onTap: () => controller.personalization == null
                ? showNutritionProfileSheet(context, controller)
                : openPersonalizationEditor(context),
          ),
          const Divider(height: 1),
          _ProfileRow(
            icon: Icons.no_food_outlined,
            title: 'Allergien',
            value: controller.allergies,
            onTap: () => showNutritionProfileSheet(context, controller),
          ),
          const Divider(height: 1),
          _ProfileRow(
            icon: Icons.directions_run_rounded,
            title: 'Aktivität',
            value: controller.personalization == null
                ? controller.activityLevel
                : controller.personalization!.activity?.label ?? 'Noch offen',
            onTap: () => controller.personalization == null
                ? showNutritionProfileSheet(context, controller)
                : openPersonalizationEditor(context),
          ),
          const Divider(height: 1),
          _ProfileRow(
            icon: Icons.schedule_rounded,
            title: 'Mahlzeiten',
            value: controller.personalization?.desiredMeals == null
                ? 'Flexibel'
                : '${controller.personalization!.desiredMeals} pro Tag',
            onTap: () => openPersonalizationEditor(context),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.workspace_premium_outlined,
            title: 'LIVO Premium',
            subtitle: 'Pläne und Vorteile ansehen',
            color: AppColors.primary,
            onTap: () => showPremiumSheet(context),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.notifications_none_rounded,
            title: 'Erinnerungen',
            subtitle: 'Mahlzeiten und Wasser',
            onTap: () => showReminderSheet(context, controller),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.shield_outlined,
            title: 'Datenschutz & Daten',
            subtitle: 'Exportieren, löschen, Einwilligungen',
            onTap: () => showPrivacySheet(context, controller),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Hilfe & Sicherheit',
            subtitle: 'Hinweise und Kontakt',
            onTap: () => showHelpSheet(context),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = AppColors.textMuted,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: color, size: 21),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
      ),
      onTap: onTap,
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.controller});
  final AppController controller;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late String _goal;
  late double _calories;
  late double _targetWeight;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.controller.name);
    _goal = widget.controller.goal;
    _calories = widget.controller.calorieGoal.toDouble();
    _targetWeight = widget.controller.targetWeight;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        22 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profil bearbeiten',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 18),
            if (widget.controller.personalization != null)
              const Text(
                'Rufname und persönliche Wünsche änderst du im Profil unter „Antworten ändern“. Die folgenden Zahlen sind deine separat eingestellten Ziele.',
                style: TextStyle(color: AppColors.textMuted, height: 1.5),
              ),
            if (widget.controller.personalization == null) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Mein Ziel',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    ['Fett verlieren', 'Gewicht halten', 'Muskeln aufbauen']
                        .map(
                          (goal) => ChoiceChip(
                            label: Text(goal),
                            selected: _goal == goal,
                            onSelected: (_) => setState(() => _goal = goal),
                            showCheckmark: false,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: _goal == goal
                                  ? AppColors.black
                                  : AppColors.text,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
            const SizedBox(height: 19),
            if (widget.controller.dailyTargets.isReady)
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Text(
                  'Dein Kalorienziel wird aus deinen Angaben berechnet.',
                  style: TextStyle(color: AppColors.textMuted, height: 1.4),
                ),
              )
            else ...[
              Text(
                'Kalorienziel: ${_calories.round()} kcal',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Slider(
                value: _calories.clamp(1400, 3200),
                min: 1400,
                max: 3200,
                divisions: 36,
                activeColor: AppColors.primary,
                onChanged: (value) => setState(() => _calories = value),
              ),
            ],
            Text(
              'Zielgewicht: ${_targetWeight.toStringAsFixed(1)} kg',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Slider(
              value: _targetWeight,
              min: 50,
              max: 110,
              divisions: 120,
              activeColor: AppColors.primary,
              onChanged: (value) => setState(() => _targetWeight = value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.controller.updateProfile(
                    newName: _nameController.text,
                    newGoal: _goal,
                    newCalorieGoal: _calories.round(),
                    newTargetWeight: _targetWeight,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Änderungen übernehmen'),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Demo: Änderungen bleiben bis zum Neustart erhalten.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
