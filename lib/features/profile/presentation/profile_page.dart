import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_reveal.dart';
import '../../../shared/widgets/ui_components.dart';
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
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedReveal(
                  child: PageHeader(
                    title: 'Profil',
                    subtitle: 'Deine Ziele und Einstellungen an einem Ort.',
                    trailing: IconButton.filledTonal(
                      onPressed: () => _openEditProfile(context, controller),
                      tooltip: 'Profil bearbeiten',
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 70),
                  child: _ProfileHero(controller: controller),
                ),
                const SizedBox(height: 24),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 140),
                  child: SectionHeader(title: 'Meine Ziele'),
                ),
                const SizedBox(height: 11),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 190),
                  child: _GoalGrid(controller: controller),
                ),
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;
          final details = Column(
            crossAxisAlignment: compact
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                controller.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 5),
              Text(
                controller.goal,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 11),
              const Wrap(
                alignment: WrapAlignment.center,
                spacing: 7,
                runSpacing: 7,
                children: [
                  StatusPill(label: 'LEVEL 8', icon: Icons.bolt_rounded),
                  StatusPill(
                    label: '8 TAGE SERIE',
                    icon: Icons.local_fire_department_outlined,
                    color: AppColors.orange,
                  ),
                ],
              ),
            ],
          );
          if (compact) {
            return Column(
              children: [
                const _EditableAvatar(),
                const SizedBox(height: 16),
                details,
              ],
            );
          }
          return Row(
            children: [
              const _EditableAvatar(),
              const SizedBox(width: 20),
              Expanded(child: details),
              _GoalRing(progress: controller.goalProgress),
            ],
          );
        },
      ),
    );
  }
}

class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.mint],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 24,
          ),
        ],
      ),
      child: const AppAvatar(radius: 42),
    );
  }
}

class _GoalRing extends StatelessWidget {
  const _GoalRing({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox.square(
        dimension: 88,
        child: CustomPaint(
          painter: _GoalRingPainter(value),
          child: Center(
            child: Text(
              '${(value * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalRingPainter extends CustomPainter {
  const _GoalRingPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(6);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = AppColors.surfaceSoft
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GoalRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _GoalGrid extends StatelessWidget {
  const _GoalGrid({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 680 ? 3 : 1;
        const gap = 10.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            _GoalTile(
              width: width,
              icon: Icons.monitor_weight_outlined,
              color: AppColors.primary,
              value: '${controller.targetWeight.toStringAsFixed(1)} kg',
              label: 'Zielgewicht',
            ),
            _GoalTile(
              width: width,
              icon: Icons.local_fire_department_outlined,
              color: AppColors.orange,
              value: '${controller.calorieGoal} kcal',
              label: 'Tagesziel',
            ),
            _GoalTile(
              width: width,
              icon: Icons.fitness_center_rounded,
              color: AppColors.mint,
              value: '${controller.proteinGoal} g',
              label: 'Protein',
            ),
          ],
        );
      },
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.width,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
  final double width;
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: SurfaceCard(
        child: Row(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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
            value: controller.nutritionStyle,
            onTap: () => showNutritionProfileSheet(context, controller),
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
            value: controller.activityLevel,
            onTap: () => showNutritionProfileSheet(context, controller),
          ),
          const Divider(height: 1),
          _ProfileRow(
            icon: Icons.schedule_rounded,
            title: 'Mahlzeiten',
            value: '3 + 1 Snack',
            onTap: () => showNutritionProfileSheet(context, controller),
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
      leading: Icon(icon, color: AppColors.textMuted, size: 21),
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
      leading: Icon(icon, color: color),
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
              children: ['Fett verlieren', 'Gewicht halten', 'Muskeln aufbauen']
                  .map(
                    (goal) => ChoiceChip(
                      label: Text(goal),
                      selected: _goal == goal,
                      onSelected: (_) => setState(() => _goal = goal),
                      showCheckmark: false,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _goal == goal ? AppColors.black : AppColors.text,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 19),
            Text(
              'Kalorienziel: ${_calories.round()} kcal',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Slider(
              value: _calories,
              min: 1400,
              max: 3200,
              divisions: 36,
              activeColor: AppColors.primary,
              onChanged: (value) => setState(() => _calories = value),
            ),
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
