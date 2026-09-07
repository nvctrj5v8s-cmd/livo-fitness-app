import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_reveal.dart';
import '../../../shared/widgets/ui_components.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({required this.onAddMeal, super.key});

  final VoidCallback onAddMeal;

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  int _selectedDay = 3;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
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
                      onPressed: widget.onAddMeal,
                      tooltip: 'Mahlzeit hinzufügen',
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 70),
                  child: _WeekSelector(
                    selected: _selectedDay,
                    onSelected: (index) => setState(() => _selectedDay = index),
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
                      key: ValueKey(_selectedDay),
                      child: _DiarySummary(controller: controller),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 200),
                  child: SectionHeader(
                    title: 'Mahlzeiten',
                    action: 'Hinzufügen',
                    onAction: widget.onAddMeal,
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 250),
                  child: _MealList(
                    meals: controller.meals,
                    onRemove: controller.removeMeal,
                    onAdd: widget.onAddMeal,
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
}

class _WeekSelector extends StatelessWidget {
  const _WeekSelector({required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const days = [
      ('Mo', '01'),
      ('Di', '02'),
      ('Mi', '03'),
      ('Do', '04'),
      ('Fr', '05'),
      ('Sa', '06'),
      ('So', '07'),
    ];
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final active = index == selected;
          return Semantics(
            button: true,
            selected: active,
            label: '${days[index].$1}, ${days[index].$2}',
            child: InkWell(
              onTap: () => onSelected(index),
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
                              color: AppColors.primary.withValues(alpha: 0.2),
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
                        days[index].$1,
                        style: TextStyle(
                          color: active ? AppColors.black : AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        days[index].$2,
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
    );
  }
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
                value: '${controller.consumedCalories}',
                suffix: 'kcal',
              ),
              const _SummaryDivider(),
              _SummaryNumber(
                label: 'Übrig',
                value: '${controller.remainingCalories}',
                suffix: 'kcal',
                accent: true,
              ),
              const _SummaryDivider(),
              _SummaryNumber(
                label: 'Protein',
                value: '${controller.consumedProtein}',
                suffix: 'g',
              ),
            ],
          ),
          const SizedBox(height: 18),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: controller.calorieProgress),
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

class _MealList extends StatelessWidget {
  const _MealList({
    required this.meals,
    required this.onRemove,
    required this.onAdd,
  });
  final List<MealEntry> meals;
  final ValueChanged<String> onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final meal in meals) ...[
          Dismissible(
            key: ValueKey(meal.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => onRemove(meal.id),
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
            child: _MealRow(meal: meal),
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
  const _MealRow({required this.meal});
  final MealEntry meal;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  '${meal.protein} P · ${meal.carbs} K · ${meal.fat} F',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
        ],
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
