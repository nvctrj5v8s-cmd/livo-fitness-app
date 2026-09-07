import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_reveal.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../coach/presentation/coach_page.dart';
import '../../diary/presentation/add_meal_sheet.dart';
import '../../profile/presentation/settings_sheets.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.onOpenPage, super.key});

  final ValueChanged<int> onOpenPage;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return SingleChildScrollView(
      key: const PageStorageKey('home-scroll'),
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedReveal(
                  child: _HomeHeader(
                    name: controller.name,
                    onProfile: () => onOpenPage(4),
                    onNotifications: () =>
                        showReminderSheet(context, controller),
                  ),
                ),
                const SizedBox(height: 26),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 70),
                  child: _NutritionOverview(controller: controller),
                ),
                const SizedBox(height: 26),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 140),
                  child: _QuickActions(
                    controller: controller,
                    onAddMeal: () => showAddMealSheet(context),
                    onDiary: () => onOpenPage(1),
                    onRecipes: () => onOpenPage(2),
                  ),
                ),
                const SizedBox(height: 28),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 210),
                  child: SectionHeader(
                    title: 'Heute gegessen',
                    action: 'Tagebuch',
                    onAction: () => onOpenPage(1),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 260),
                  child: _MealRail(meals: controller.meals),
                ),
                const SizedBox(height: 28),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 330),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 760;
                      if (!wide) {
                        return Column(
                          children: [
                            _WeekCard(onTap: () => onOpenPage(3)),
                            const SizedBox(height: 14),
                            const _CoachCard(),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _WeekCard(onTap: () => onOpenPage(3)),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(child: _CoachCard()),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.name,
    required this.onProfile,
    required this.onNotifications,
  });

  final String name;
  final VoidCallback onProfile;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const weekdays = [
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag',
    ];
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weekdays[now.weekday - 1]}, ${now.day}.${now.month}.',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hallo, $name',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onNotifications,
          tooltip: 'Benachrichtigungen',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.text,
            side: const BorderSide(color: AppColors.border),
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        const SizedBox(width: 9),
        AppAvatar(radius: 23, onTap: onProfile),
      ],
    );
  }
}

class _NutritionOverview extends StatelessWidget {
  const _NutritionOverview({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceHigh,
            AppColors.surface,
            AppColors.primary.withValues(alpha: 0.055),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderBright),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.075),
            blurRadius: 42,
            spreadRadius: -12,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 680;
          final ring = _CalorieRing(
            progress: controller.calorieProgress,
            consumed: controller.consumedCalories,
            remaining: controller.remainingCalories,
          );
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const StatusPill(
                    label: 'HEUTE',
                    icon: Icons.local_fire_department_rounded,
                  ),
                  const Spacer(),
                  Text(
                    '${controller.calorieGoal} kcal Ziel',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _MacroRow(
                label: 'Protein',
                value: controller.consumedProtein,
                goal: controller.proteinGoal,
                color: AppColors.primary,
              ),
              const SizedBox(height: 15),
              _MacroRow(
                label: 'Kohlenhydrate',
                value: controller.consumedCarbs,
                goal: 240,
                color: AppColors.mint,
              ),
              const SizedBox(height: 15),
              _MacroRow(
                label: 'Fett',
                value: controller.consumedFat,
                goal: 70,
                color: AppColors.orange,
              ),
            ],
          );

          if (!wide) {
            return Column(
              children: [ring, const SizedBox(height: 24), details],
            );
          }
          return Row(
            children: [
              ring,
              const SizedBox(width: 38),
              Expanded(child: details),
            ],
          );
        },
      ),
    );
  }
}

class _CalorieRing extends StatelessWidget {
  const _CalorieRing({
    required this.progress,
    required this.consumed,
    required this.remaining,
  });

  final double progress;
  final int consumed;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox.square(
        dimension: 178,
        child: CustomPaint(
          painter: _RingPainter(progress: value),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: consumed),
                duration: const Duration(milliseconds: 900),
                builder: (context, number, _) => Text(
                  '$number',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const Text(
                'kcal gegessen',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 7),
              Text(
                '$remaining übrig',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(8);
    final base = Paint()
      ..color = AppColors.surfaceSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    final active = Paint()
      ..shader = const SweepGradient(
        colors: [AppColors.primary, AppColors.mint],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, active);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
  });

  final String label;
  final int value;
  final int goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = (value / goal).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '$value / $goal g',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, _) => LinearProgressIndicator(
            value: animatedValue,
            minHeight: 6,
            borderRadius: BorderRadius.circular(99),
            backgroundColor: AppColors.surfaceSoft,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.controller,
    required this.onAddMeal,
    required this.onDiary,
    required this.onRecipes,
  });

  final AppController controller;
  final VoidCallback onAddMeal;
  final VoidCallback onDiary;
  final VoidCallback onRecipes;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        const gap = 10.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            _QuickButton(
              width: width,
              icon: Icons.add_rounded,
              label: 'Mahlzeit',
              detail: 'Suchen oder scannen',
              color: AppColors.primary,
              onTap: onAddMeal,
            ),
            _QuickButton(
              width: width,
              icon: Icons.water_drop_outlined,
              label: '${controller.waterGlasses}/8 Wasser',
              detail: 'Glas hinzufügen',
              color: AppColors.blue,
              onTap: controller.addWater,
            ),
            _QuickButton(
              width: width,
              icon: Icons.menu_book_outlined,
              label: 'Tagebuch',
              detail: 'Heute ansehen',
              color: AppColors.mint,
              onTap: onDiary,
            ),
            _QuickButton(
              width: width,
              icon: Icons.restaurant_menu_rounded,
              label: 'Rezepte',
              detail: 'Neue Ideen',
              color: AppColors.orange,
              onTap: onRecipes,
            ),
          ],
        );
      },
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({
    required this.width,
    required this.icon,
    required this.label,
    required this.detail,
    required this.color,
    required this.onTap,
  });
  final double width;
  final IconData icon;
  final String label;
  final String detail;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: PressableScale(
        onTap: onTap,
        borderRadius: 21,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.14), AppColors.surfaceHigh],
            ),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: color.withValues(alpha: 0.24)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween(begin: 0.82, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                          child: child,
                        ),
                      ),
                      child: Text(
                        label,
                        key: ValueKey(label),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealRail extends StatelessWidget {
  const _MealRail({required this.meals});
  final List<MealEntry> meals;

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) return const Text('Noch keine Mahlzeiten eingetragen.');
    return Column(
      children: List.generate(
        meals.length,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index == meals.length - 1 ? 0 : 10),
          child: SizedBox(
            height: 116,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 22,
                  child: Column(
                    children: [
                      Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? AppColors.primary
                              : AppColors.surfaceSoft,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: index == 0
                                ? AppColors.primary
                                : AppColors.borderBright,
                            width: 2,
                          ),
                          boxShadow: index == 0
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      if (index != meals.length - 1)
                        Expanded(
                          child: Container(
                            width: 1,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            color: AppColors.border,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(child: _MealCard(meal: meals[index])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});
  final MealEntry meal;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceHigh, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            height: double.infinity,
            child: meal.imageAsset == null
                ? const ColoredBox(
                    color: AppColors.surfaceHigh,
                    child: Icon(
                      Icons.restaurant_rounded,
                      color: AppColors.primary,
                      size: 34,
                    ),
                  )
                : Image.asset(meal.imageAsset!, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.slot.label,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    meal.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        '${meal.calories} kcal',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Text(
                        '•',
                        style: TextStyle(color: AppColors.borderBright),
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          '${meal.protein} g Protein',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const values = [0.78, 0.92, 0.64, 0.86, 0.71, 0.88, 0.56];
    const labels = ['M', 'D', 'M', 'D', 'F', 'S', 'S'];
    return PressableScale(
      onTap: onTap,
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Diese Woche',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Ø 84 % deines Kalorienziels',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 92,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  values.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: values[index]),
                            duration: Duration(milliseconds: 500 + index * 70),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) => Container(
                              height: 58 * value,
                              decoration: BoxDecoration(
                                color: index == 3
                                    ? AppColors.primary
                                    : AppColors.surfaceSoft,
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            labels[index],
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard();

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const CoachPage())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.16),
              AppColors.mint.withValues(alpha: 0.07),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusPill(
                  label: 'KI · SPÄTER',
                  icon: Icons.auto_awesome_rounded,
                ),
                Spacer(),
                Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
              ],
            ),
            SizedBox(height: 22),
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.primary,
              size: 30,
            ),
            SizedBox(height: 12),
            Text(
              'Dein persönlicher Coach',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Versteht später deinen Tag, deine Ziele und deine Vorlieben.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
