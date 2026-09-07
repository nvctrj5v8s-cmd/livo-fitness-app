import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_reveal.dart';
import '../../../shared/widgets/ui_components.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  int _period = 0;
  int? _selectedPoint;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return SingleChildScrollView(
      key: const PageStorageKey('progress-scroll'),
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1020),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AnimatedReveal(
                  child: PageHeader(
                    title: 'Fortschritt',
                    subtitle:
                        'Trends erkennen, ohne dich von einzelnen Tagen stressen zu lassen.',
                  ),
                ),
                const SizedBox(height: 22),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 70),
                  child: _PeriodSelector(
                    selected: _period,
                    onSelected: (value) => setState(() {
                      _period = value;
                      _selectedPoint = null;
                    }),
                  ),
                ),
                const SizedBox(height: 18),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 130),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 380),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.035, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_period),
                      child: _WeightChartCard(
                        values: controller.weightHistory,
                        currentWeight: controller.currentWeight,
                        targetWeight: controller.targetWeight,
                        selectedPoint: _selectedPoint,
                        onPointSelected: (index) =>
                            setState(() => _selectedPoint = index),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 200),
                  child: _StatGrid(controller: controller),
                ),
                const SizedBox(height: 28),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 260),
                  child: SectionHeader(title: 'Ernährungs-Balance'),
                ),
                const SizedBox(height: 11),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 320),
                  child: _NutritionChartCard(),
                ),
                const SizedBox(height: 14),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 380),
                  child: _MilestoneCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const labels = ['4 Wochen', '3 Monate', '1 Jahr'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(
          labels.length,
          (index) => Expanded(
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected == index ? null : Colors.transparent,
                  gradient: selected == index
                      ? const LinearGradient(
                          colors: [AppColors.primary, AppColors.mint],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selected == index
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected == index
                        ? AppColors.black
                        : AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: selected == index
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeightChartCard extends StatelessWidget {
  const _WeightChartCard({
    required this.values,
    required this.currentWeight,
    required this.targetWeight,
    required this.selectedPoint,
    required this.onPointSelected,
  });
  final List<double> values;
  final double currentWeight;
  final double targetWeight;
  final int? selectedPoint;
  final ValueChanged<int> onPointSelected;

  @override
  Widget build(BuildContext context) {
    final displayed = selectedPoint == null
        ? currentWeight
        : values[selectedPoint!];
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.mint.withValues(alpha: 0.11),
          AppColors.surfaceHigh,
          AppColors.surface,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 14,
            runSpacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gewicht',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween(begin: 0.96, end: 1.0).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Text(
                      '$displayed kg',
                      key: ValueKey(displayed),
                      style: const TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                ],
              ),
              StatusPill(
                label: '− ${(81.2 - currentWeight).toStringAsFixed(1)} KG',
                icon: Icons.south_east_rounded,
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 210,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    final usableWidth = math.max(1, constraints.maxWidth - 42);
                    final ratio =
                        ((details.localPosition.dx - 30) / usableWidth).clamp(
                          0.0,
                          1.0,
                        );
                    onPointSelected((ratio * (values.length - 1)).round());
                  },
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1050),
                    curve: Curves.easeOutCubic,
                    builder: (context, animation, _) => CustomPaint(
                      painter: _WeightChartPainter(
                        values: values,
                        target: targetWeight,
                        animation: animation,
                        selected: selectedPoint,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Start',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              Text(
                'Heute',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  const _WeightChartPainter({
    required this.values,
    required this.target,
    required this.animation,
    required this.selected,
  });
  final List<double> values;
  final double target;
  final double animation;
  final int? selected;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 30.0;
    const top = 14.0;
    const bottom = 12.0;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - 12,
      size.height - bottom,
    );
    final minValue = math.min(target - 0.4, values.reduce(math.min) - 0.4);
    final maxValue = values.reduce(math.max) + 0.4;
    final range = math.max(0.1, maxValue - minValue);
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    final labelPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < 4; i++) {
      final y = chart.top + chart.height * i / 3;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
      final label = maxValue - range * i / 3;
      labelPainter.text = TextSpan(
        text: label.toStringAsFixed(0),
        style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
      );
      labelPainter.layout();
      labelPainter.paint(canvas, Offset(0, y - labelPainter.height / 2));
    }
    final targetY = chart.bottom - ((target - minValue) / range) * chart.height;
    final targetPaint = Paint()
      ..color = AppColors.orange.withValues(alpha: 0.5)
      ..strokeWidth = 1.4;
    for (double x = chart.left; x < chart.right; x += 8) {
      canvas.drawLine(
        Offset(x, targetY),
        Offset(math.min(x + 4, chart.right), targetY),
        targetPaint,
      );
    }

    final points = List.generate(values.length, (index) {
      final x = chart.left + chart.width * index / (values.length - 1);
      final y =
          chart.bottom - ((values[index] - minValue) / range) * chart.height;
      return Offset(x, y);
    });
    final fullPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final middle = (previous.dx + current.dx) / 2;
      fullPath.cubicTo(
        middle,
        previous.dy,
        middle,
        current.dy,
        current.dx,
        current.dy,
      );
    }
    final metrics = fullPath.computeMetrics().first;
    final path = metrics.extractPath(0, metrics.length * animation);
    final endpoint =
        metrics.getTangentForOffset(metrics.length * animation)?.position ??
        points.first;
    final areaPath = Path.from(path)
      ..lineTo(endpoint.dx, chart.bottom)
      ..lineTo(points.first.dx, chart.bottom)
      ..close();
    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.24),
          AppColors.mint.withValues(alpha: 0.015),
        ],
      ).createShader(chart)
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, areaPaint);
    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.mint, AppColors.primary],
      ).createShader(chart)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    if (animation > 0.95) {
      for (var i = 0; i < points.length; i++) {
        if (selected == i) {
          canvas.drawCircle(
            points[i],
            9,
            Paint()..color = AppColors.primary.withValues(alpha: 0.18),
          );
        }
        canvas.drawCircle(
          points[i],
          selected == i ? 5 : 3,
          Paint()..color = selected == i ? AppColors.primary : AppColors.mint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_WeightChartPainter old) =>
      old.animation != animation ||
      old.selected != selected ||
      old.target != target ||
      old.values != values;
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 650 ? 3 : 1;
        const gap = 11.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            _StatCard(
              width: width,
              icon: Icons.local_fire_department_outlined,
              color: AppColors.orange,
              value: '${controller.streakDays} Tage',
              label: 'Aktuelle Serie',
            ),
            _StatCard(
              width: width,
              icon: Icons.flag_outlined,
              color: AppColors.primary,
              value: '${(controller.goalProgress * 100).round()} %',
              label: 'Gewichtsziel',
            ),
            _StatCard(
              width: width,
              icon: Icons.water_drop_outlined,
              color: AppColors.blue,
              value: '${controller.waterGlasses}/8',
              label: 'Wasser heute',
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
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

class _NutritionChartCard extends StatelessWidget {
  const _NutritionChartCard();

  @override
  Widget build(BuildContext context) {
    const calorieValues = [0.82, 0.94, 0.74, 0.88, 1.05, 0.79, 0.91];
    const proteinValues = [0.68, 0.86, 0.72, 0.93, 0.81, 0.76, 0.89];
    const labels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.blue.withValues(alpha: 0.08),
          AppColors.surfaceHigh,
          AppColors.primary.withValues(alpha: 0.04),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              StatusPill(label: 'KALORIEN', color: AppColors.primary),
              SizedBox(width: 8),
              StatusPill(label: 'PROTEIN', color: AppColors.mint),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 170,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                7,
                (index) => Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _AnimatedBar(
                              value: calorieValues[index],
                              color: AppColors.primary,
                              delay: index * 55,
                            ),
                            const SizedBox(width: 4),
                            _AnimatedBar(
                              value: proteinValues[index],
                              color: AppColors.mint,
                              delay: 100 + index * 55,
                            ),
                          ],
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
        ],
      ),
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  const _AnimatedBar({
    required this.value,
    required this.color,
    required this.delay,
  });
  final double value;
  final Color color;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: Duration(milliseconds: 650 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) => Container(
        width: 9,
        height: 120 * animatedValue,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.14),
            AppColors.mint.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.emoji_events_outlined, color: AppColors.primary, size: 30),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Neue Beständigkeit',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Du hast acht Tage in Folge mindestens eine Mahlzeit eingetragen.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.4,
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
