import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_reveal.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../diary/presentation/add_meal_sheet.dart';
import '../../diary/presentation/edit_meal_sheet.dart';
import '../../profile/presentation/settings_sheets.dart';

/// The first tab is today's diary: calm summary first, meals second.
class HomePage extends StatefulWidget {
  const HomePage({required this.onOpenPage, super.key});
  final ValueChanged<int> onOpenPage;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MealSlot? _expanded;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return SingleChildScrollView(
      key: const PageStorageKey('diary-home-scroll'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedReveal(
                child: _DiaryHeader(
                  name: controller.greetingName,
                  streak: controller.streakDays,
                  streakLoading: controller.streakLoading,
                  remindersActive:
                      controller.mealReminders ||
                      controller.waterReminders ||
                      controller.weeklySummary,
                  onNotifications: () => showReminderSheet(context, controller),
                  onProfile: () => widget.onOpenPage(4),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedReveal(
                delay: const Duration(milliseconds: 70),
                child: _CalorieOverview(controller: controller),
              ),
              const SizedBox(height: 30),
              const AnimatedReveal(
                delay: Duration(milliseconds: 120),
                child: _MealHeading(),
              ),
              const SizedBox(height: 13),
              for (var index = 0; index < MealSlot.values.length; index++) ...[
                AnimatedReveal(
                  delay: Duration(milliseconds: 160 + index * 55),
                  child: _MealSection(
                    key: ValueKey(
                      'meal-section-${MealSlot.values[index].name}',
                    ),
                    slot: MealSlot.values[index],
                    entries: controller.meals
                        .where((meal) => meal.slot == MealSlot.values[index])
                        .toList(),
                    expanded: _expanded == MealSlot.values[index],
                    onToggle: () {
                      final slot = MealSlot.values[index];
                      final hasEntries = controller.meals.any(
                        (meal) => meal.slot == slot,
                      );
                      if (!hasEntries) {
                        showAddMealSheet(context, initialSlot: slot);
                      } else {
                        setState(
                          () => _expanded = _expanded == slot ? null : slot,
                        );
                      }
                    },
                    onAdd: () => showAddMealSheet(
                      context,
                      initialSlot: MealSlot.values[index],
                    ),
                    onEdit: (entry) => showEditMealSheet(context, entry),
                  ),
                ),
                if (index != MealSlot.values.length - 1)
                  const SizedBox(height: 11),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DiaryHeader extends StatelessWidget {
  const _DiaryHeader({
    required this.name,
    required this.streak,
    required this.streakLoading,
    required this.remindersActive,
    required this.onNotifications,
    required this.onProfile,
  });
  final String name;
  final int streak;
  final bool streakLoading;
  final bool remindersActive;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

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
    final greeting = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${weekdays[now.weekday - 1]}, ${now.day}.${now.month}.',
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Hallo, $name',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ],
    );
    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StreakPill(days: streak, loading: streakLoading),
        const SizedBox(width: 7),
        IconButton(
          key: const ValueKey('reminder-button'),
          onPressed: onNotifications,
          tooltip: 'Erinnerungen',
          style: IconButton.styleFrom(
            minimumSize: const Size(46, 46),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.text,
            side: const BorderSide(color: AppColors.border),
          ),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded, size: 21),
              if (remindersActive)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 7),
        AppAvatar(radius: 23, onTap: onProfile),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              greeting,
              const SizedBox(height: 14),
              Align(alignment: Alignment.centerRight, child: controls),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: greeting),
            const SizedBox(width: 12),
            controls,
          ],
        );
      },
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.days, required this.loading});
  final int days;
  final bool loading;

  @override
  Widget build(BuildContext context) => Semantics(
    label: loading ? 'Serie wird geladen' : '$days Tage Tracking-Serie',
    child: Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.orange,
            size: 21,
          ),
          const SizedBox(width: 4),
          AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 260),
            child: Text(
              loading ? '…' : '$days',
              key: ValueKey((loading, days)),
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _CalorieOverview extends StatelessWidget {
  const _CalorieOverview({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceHigh,
            AppColors.surface,
            AppColors.primary.withValues(alpha: 0.045),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderBright),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ring = _CalorieRing(
            progress: controller.calorieProgress,
            consumed: controller.consumedCalories,
            remaining: controller.remainingCalories,
            reduceMotion: reduceMotion,
          );
          final macros = _MacroSummary(
            controller: controller,
            reduceMotion: reduceMotion,
          );
          return constraints.maxWidth < 600
              ? Column(children: [ring, const SizedBox(height: 20), macros])
              : Row(
                  children: [
                    ring,
                    const SizedBox(width: 34),
                    Expanded(child: macros),
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
    required this.reduceMotion,
  });
  final double progress;
  final int consumed;
  final int remaining;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduceMotion ? progress : 0, end: progress),
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        if (largeText) {
          return SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$consumed kcal gegessen',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  remaining >= 0
                      ? '$remaining kcal übrig'
                      : '${remaining.abs()} kcal über deinem Ziel',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: value,
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(99),
                  backgroundColor: AppColors.surfaceSoft,
                  color: AppColors.primary,
                ),
              ],
            ),
          );
        }
        return SizedBox.square(
          dimension: 154,
          child: CustomPaint(
            painter: _RingPainter(value),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$consumed',
                  style: const TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const Text(
                  'kcal gegessen',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 5),
                Text(
                  remaining >= 0
                      ? '$remaining übrig'
                      : '${remaining.abs()} darüber',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(8);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = AppColors.surfaceSoft
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..shader = const SweepGradient(
          colors: [AppColors.primary, AppColors.mint],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 11,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _MacroSummary extends StatelessWidget {
  const _MacroSummary({required this.controller, required this.reduceMotion});
  final AppController controller;
  final bool reduceMotion;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 12,
        runSpacing: 3,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Dein Tag',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          Text(
            '${controller.calorieGoal} kcal Ziel',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
      const SizedBox(height: 18),
      _MacroBar(
        label: 'Protein',
        value: controller.consumedProtein,
        goal: controller.proteinGoal,
        color: AppColors.primary,
        reduceMotion: reduceMotion,
      ),
      const SizedBox(height: 13),
      _MacroBar(
        label: 'Kohlenhydrate',
        value: controller.consumedCarbs,
        goal: controller.diaryCarbohydrateGoal,
        color: AppColors.mint,
        reduceMotion: reduceMotion,
      ),
      const SizedBox(height: 13),
      _MacroBar(
        label: 'Fett',
        value: controller.consumedFat,
        goal: controller.diaryFatGoal,
        color: AppColors.orange,
        reduceMotion: reduceMotion,
      ),
    ],
  );
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
    required this.reduceMotion,
  });
  final String label;
  final int value;
  final int goal;
  final Color color;
  final bool reduceMotion;
  @override
  Widget build(BuildContext context) {
    final target = goal <= 0 ? 0.0 : (value / goal).clamp(0.0, 1.0);
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 3,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              '$value / $goal g',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 7),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: reduceMotion ? target : 0, end: target),
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 750),
          builder: (context, progress, _) => LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            borderRadius: BorderRadius.circular(99),
            backgroundColor: AppColors.surfaceSoft,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MealHeading extends StatelessWidget {
  const _MealHeading();
  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Deine Mahlzeiten',
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.35,
        ),
      ),
      SizedBox(height: 5),
      Text(
        'Tippe auf eine Mahlzeit, um Essen einzutragen.',
        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
    ],
  );
}

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.slot,
    required this.entries,
    required this.expanded,
    required this.onToggle,
    required this.onAdd,
    required this.onEdit,
    super.key,
  });
  final MealSlot slot;
  final List<MealEntry> entries;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onAdd;
  final ValueChanged<MealEntry> onEdit;
  int get calories => entries.fold(0, (sum, entry) => sum + entry.calories);
  Color get color => switch (slot) {
    MealSlot.breakfast => AppColors.primary,
    MealSlot.lunch => AppColors.mint,
    MealSlot.dinner => AppColors.orange,
    MealSlot.snack => AppColors.blue,
  };
  IconData get icon => switch (slot) {
    MealSlot.breakfast => Icons.wb_sunny_outlined,
    MealSlot.lunch => Icons.lunch_dining_outlined,
    MealSlot.dinner => Icons.nights_stay_outlined,
    MealSlot.snack => Icons.cookie_outlined,
  };
  String get title => slot == MealSlot.snack ? 'Snacks' : slot.label;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedContainer(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: expanded ? color.withValues(alpha: 0.48) : AppColors.border,
        ),
        boxShadow: expanded
            ? [BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: 24)]
            : null,
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(23),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: color, size: 23),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entries.isEmpty
                                ? 'Noch nichts eingetragen'
                                : '${entries.length} ${entries.length == 1 ? 'Eintrag' : 'Einträge'} · $calories kcal',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      key: ValueKey('add-${slot.name}'),
                      tooltip: '$title hinzufügen',
                      onPressed: onAdd,
                      style: IconButton.styleFrom(
                        backgroundColor: color.withValues(alpha: 0.11),
                        foregroundColor: color,
                      ),
                      icon: const Icon(Icons.add_rounded),
                    ),
                    if (entries.isNotEmpty) ...[
                      const SizedBox(width: 3),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 250),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: expanded && entries.isNotEmpty
                ? Column(
                    children: [
                      const Divider(height: 1, indent: 14, endIndent: 14),
                      for (var index = 0; index < entries.length; index++)
                        _TrackedMealRow(
                          entry: entries[index],
                          showDivider: index != entries.length - 1,
                          onTap: () => onEdit(entries[index]),
                        ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _TrackedMealRow extends StatelessWidget {
  const _TrackedMealRow({
    required this.entry,
    required this.showDivider,
    required this.onTap,
  });
  final MealEntry entry;
  final bool showDivider;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 3),
        leading: Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.restaurant_rounded,
            color: AppColors.textMuted,
            size: 19,
          ),
        ),
        title: Text(
          entry.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        subtitle: Text(
          '${entry.protein} P · ${entry.carbs} K · ${entry.fat} F',
          style: const TextStyle(fontSize: 10),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${entry.calories} kcal',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 19,
            ),
          ],
        ),
      ),
      if (showDivider) const Divider(height: 1, indent: 70, endIndent: 17),
    ],
  );
}
