import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_reveal.dart';
import '../../../shared/widgets/ui_components.dart';
import 'edit_meal_sheet.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({required this.onAddMeal, super.key});

  final ValueChanged<DateTime> onAddMeal;

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = _startOfWeek(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final weekDates = List.generate(
      7,
      (index) => _weekStart.add(Duration(days: index)),
    );
    return SingleChildScrollView(
      key: const PageStorageKey('diary-scroll'),
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedReveal(
                  child: PageHeader(
                    title: 'Tagebuch',
                    subtitle:
                        'Deine Mahlzeiten klar und ohne unnötigen Aufwand.',
                    trailing: IconButton.filledTonal(
                      onPressed: () => widget.onAddMeal(controller.diaryDate),
                      tooltip: 'Mahlzeit hinzufügen',
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 70),
                  child: _WeekSelector(
                    dates: weekDates,
                    selectedDate: controller.diaryDate,
                    onSelected: controller.loadRemoteDiary,
                    onPrevious: () => _changeWeek(controller, -1),
                    onNext: () => _changeWeek(controller, 1),
                    onToday: () => _goToToday(controller),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 130),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 360),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(controller.diaryDate),
                      child: _DiarySummary(controller: controller),
                    ),
                  ),
                ),
                if (controller.personalization != null) ...[
                  const SizedBox(height: 18),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dein Mahlzeitenrhythmus',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(controller.personalization!.routineLabel),
                        const SizedBox(height: 6),
                        const Text(
                          'Dein Wunsch, kein Muss. Du kannst jederzeit weitere Mahlzeiten eintragen.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 200),
                  child: SectionHeader(
                    title: 'Mahlzeiten',
                    action: 'Hinzufügen',
                    onAction: () => widget.onAddMeal(controller.diaryDate),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 250),
                  child: _MealList(
                    meals: controller.diaryMeals,
                    onRemove: controller.removeMeal,
                    onEdit: (entry) => showEditMealSheet(context, entry),
                    onAdd: () => widget.onAddMeal(controller.diaryDate),
                  ),
                ),
                const SizedBox(height: 26),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 320),
                  child: _HydrationCard(controller: controller),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changeWeek(AppController controller, int direction) {
    final selected = controller.diaryDate.add(Duration(days: 7 * direction));
    setState(() => _weekStart = _startOfWeek(selected));
    controller.loadRemoteDiary(selected);
  }

  void _goToToday(AppController controller) {
    final today = DateTime.now();
    setState(() => _weekStart = _startOfWeek(today));
    controller.loadRemoteDiary(today);
  }

  DateTime _startOfWeek(DateTime date) =>
      DateTime(date.year, date.month, date.day - date.weekday + 1);
}

class _WeekSelector extends StatelessWidget {
  const _WeekSelector({
    required this.dates,
    required this.selectedDate,
    required this.onSelected,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final List<DateTime> dates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    const weekdayLabels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return Column(
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: onPrevious,
              tooltip: 'Vorherige Woche',
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Center(
                child: TextButton(
                  onPressed: onToday,
                  child: Text(
                    '${dates.first.day.toString().padLeft(2, '0')}.${dates.first.month.toString().padLeft(2, '0')} - ${dates.last.day.toString().padLeft(2, '0')}.${dates.last.month.toString().padLeft(2, '0')}.${dates.last.year}',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            IconButton.filledTonal(
              onPressed: onNext,
              tooltip: 'Naechste Woche',
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final date = dates[index];
              final active = _sameDay(date, selectedDate);
              return Semantics(
                button: true,
                selected: active,
                label: '${weekdayLabels[index]}, ${date.day}.${date.month}.',
                child: InkWell(
                  onTap: () => onSelected(date),
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutBack,
                    scale: active ? 1 : 0.94,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      width: 55,
                      decoration: BoxDecoration(
                        color: active ? null : AppColors.surface,
                        gradient: active
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.primary, AppColors.mint],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: active ? AppColors.primary : AppColors.border,
                        ),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            weekdayLabels[index],
                            style: TextStyle(
                              color: active
                                  ? AppColors.black
                                  : AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString().padLeft(2, '0'),
                            style: TextStyle(
                              color: active ? AppColors.black : AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _DiarySummary extends StatelessWidget {
  const _DiarySummary({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withValues(alpha: 0.13),
          AppColors.surfaceHigh,
          AppColors.mint.withValues(alpha: 0.05),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _SummaryNumber(
                label: 'Gegessen',
                value: '${controller.diaryConsumedCalories}',
                suffix: 'kcal',
              ),
              const _SummaryDivider(),
              _SummaryNumber(
                label: 'Übrig',
                value: '${controller.diaryRemainingCalories}',
                suffix: 'kcal',
                accent: true,
              ),
              const _SummaryDivider(),
              _SummaryNumber(
                label: 'Protein',
                value: '${controller.diaryConsumedProtein}',
                suffix: 'g',
              ),
            ],
          ),
          const SizedBox(height: 18),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: controller.diaryCalorieProgress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              borderRadius: BorderRadius.circular(99),
              backgroundColor: AppColors.surfaceSoft,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          _MacroOverview(controller: controller),
          if (controller.diaryRemainingCalories < 0) ...[
            const SizedBox(height: 14),
            const _DiaryHint(
              icon: Icons.info_outline_rounded,
              text:
                  'Du liegst ueber deinem Tagesziel. Das ist eine Orientierung, keine Bewertung.',
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryNumber extends StatelessWidget {
  const _SummaryNumber({
    required this.label,
    required this.value,
    required this.suffix,
    this.accent = false,
  });
  final String label;
  final String value;
  final String suffix;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 5),
          FittedBox(
            child: Text.rich(
              TextSpan(
                text: value,
                style: TextStyle(
                  color: accent ? AppColors.primary : AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
                children: [
                  TextSpan(
                    text: ' $suffix',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
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

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 42, color: AppColors.border);
}

class _MacroOverview extends StatelessWidget {
  const _MacroOverview({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _MacroBar(
        label: 'Protein',
        value: controller.diaryConsumedProtein,
        goal: controller.proteinGoal,
        color: AppColors.mint,
      ),
      const SizedBox(height: 11),
      _MacroBar(
        label: 'Kohlenhydrate',
        value: controller.diaryConsumedCarbs,
        goal: controller.diaryCarbohydrateGoal,
        color: AppColors.orange,
      ),
      const SizedBox(height: 11),
      _MacroBar(
        label: 'Fett',
        value: controller.diaryConsumedFat,
        goal: controller.diaryFatGoal,
        color: AppColors.purple,
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
  });

  final String label;
  final int value;
  final int goal;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            '$value / $goal g',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
      const SizedBox(height: 6),
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: (value / goal).clamp(0, 1).toDouble()),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, progress, _) => LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          borderRadius: BorderRadius.circular(99),
          backgroundColor: AppColors.surfaceSoft,
          color: color,
        ),
      ),
    ],
  );
}

class _DiaryHint extends StatelessWidget {
  const _DiaryHint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: AppColors.orange.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.orange.withValues(alpha: 0.28)),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.orange, size: 18),
        const SizedBox(width: 9),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 11, height: 1.35)),
        ),
      ],
    ),
  );
}

class _MealList extends StatelessWidget {
  const _MealList({
    required this.meals,
    required this.onRemove,
    required this.onEdit,
    required this.onAdd,
  });
  final List<MealEntry> meals;
  final Future<bool> Function(String) onRemove;
  final ValueChanged<MealEntry> onEdit;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final meal in meals) ...[
          Dismissible(
            key: ValueKey(meal.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => onRemove(meal.id),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 22),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
              ),
            ),
            child: _MealRow(meal: meal, onEdit: () => onEdit(meal)),
          ),
          const SizedBox(height: 9),
        ],
        PressableScale(
          onTap: onAdd,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: AppColors.primary),
                SizedBox(width: 7),
                Text(
                  'Weitere Mahlzeit',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.meal, required this.onEdit});
  final MealEntry meal;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final amountPrefix = meal.amountGrams == null
        ? ''
        : '${meal.amountGrams!.round()} g · ';
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                width: 58,
                height: 58,
                child: meal.imageAsset == null
                    ? const ColoredBox(
                        color: AppColors.surfaceHigh,
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: AppColors.primary,
                        ),
                      )
                    : Image.asset(meal.imageAsset!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
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
                  const SizedBox(height: 3),
                  Text(
                    meal.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$amountPrefix${meal.protein} P · ${meal.carbs} K · ${meal.fat} F',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${meal.calories}\nkcal',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 3),
                const Icon(
                  Icons.edit_outlined,
                  size: 15,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HydrationCard extends StatelessWidget {
  const _HydrationCard({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.water_drop_rounded, color: AppColors.blue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wasser',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '${controller.waterGlasses} von 8 Gläsern',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(8, (index) {
                    final filled = index < controller.waterGlasses;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 180 + index * 25),
                        curve: Curves.easeOutBack,
                        height: filled ? 5 : 3,
                        margin: EdgeInsets.only(right: index == 7 ? 0 : 4),
                        decoration: BoxDecoration(
                          color: filled
                              ? AppColors.blue
                              : AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: filled
                              ? [
                                  BoxShadow(
                                    color: AppColors.blue.withValues(
                                      alpha: 0.22,
                                    ),
                                    blurRadius: 7,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.removeWater,
            icon: const Icon(Icons.remove_rounded),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              '${controller.waterGlasses}',
              key: ValueKey(controller.waterGlasses),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),
          IconButton.filled(
            onPressed: controller.addWater,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: AppColors.black,
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
