import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/data/progress_repository.dart';
import '../../../core/models/progress_models.dart';
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
  final _repository = ProgressRepository();
  ProgressPeriod _period = ProgressPeriod.thirtyDays;
  ProgressSnapshot? _snapshot;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_load()));
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final end = DateTime.now();
    try {
      final value = await _repository.load(start: _period.start(end), end: end);
      if (!mounted) return;
      setState(() => _snapshot = value);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _snapshot ??= const ProgressSnapshot(nutrition: [], weights: []);
        _error = 'Deine Fortschrittsdaten konnten nicht geladen werden.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectPeriod(ProgressPeriod value) async {
    if (value == _period) return;
    setState(() => _period = value);
    await _load();
  }

  Future<void> _addWeight() async {
    final result = await showModalBottomSheet<_WeightInput>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _WeightSheet(),
    );
    if (result == null) return;
    try {
      await _repository.saveWeight(
        date: result.date,
        weightKg: result.weight,
        waistCm: result.waist,
      );
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Messung gespeichert.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Messung konnte nicht gespeichert werden.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final snapshot = _snapshot;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: SingleChildScrollView(
        key: const PageStorageKey('progress-scroll'),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1060),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedReveal(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: PageHeader(
                            title: 'Dein Fortschritt',
                            subtitle:
                                'Klare Trends aus deinem echten Tagebuch – ohne Druck durch einzelne Tage.',
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Aktualisieren',
                          onPressed: _loading ? null : _load,
                          icon: _loading
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 60),
                    child: _PeriodSelector(
                      selected: _period,
                      onSelected: (value) => unawaited(_selectPeriod(value)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_error != null && snapshot == null)
                    _LoadError(message: _error!, onRetry: _load)
                  else if (_loading && snapshot == null)
                    const _LoadingState()
                  else if (snapshot != null)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      child: Column(
                        key: ValueKey(_period),
                        children: [
                          AnimatedReveal(
                            delay: const Duration(milliseconds: 100),
                            child: _ProgressHero(
                              snapshot: snapshot,
                              controller: controller,
                              period: _period,
                            ),
                          ),
                          const SizedBox(height: 13),
                          AnimatedReveal(
                            delay: const Duration(milliseconds: 150),
                            child: _OverviewGrid(
                              snapshot: snapshot,
                              controller: controller,
                            ),
                          ),
                          const SizedBox(height: 26),
                          const _SectionTitle(
                            title: 'Ernährungstrend',
                            subtitle:
                                'Durchschnitt pro Zeitabschnitt im Vergleich zu deinen Zielen',
                          ),
                          const SizedBox(height: 11),
                          AnimatedReveal(
                            delay: const Duration(milliseconds: 210),
                            child: _NutritionTrendCard(
                              snapshot: snapshot,
                              calorieGoal: controller.calorieGoal,
                              proteinGoal: controller.proteinGoal,
                              period: _period,
                            ),
                          ),
                          const SizedBox(height: 13),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final macro = _MacroBalanceCard(
                                snapshot: snapshot,
                                controller: controller,
                              );
                              final consistency = _ConsistencyCard(
                                snapshot: snapshot,
                                calorieGoal: controller.calorieGoal,
                                period: _period,
                              );
                              if (constraints.maxWidth < 760) {
                                return Column(
                                  children: [
                                    macro,
                                    const SizedBox(height: 13),
                                    consistency,
                                  ],
                                );
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: macro),
                                  const SizedBox(width: 13),
                                  Expanded(child: consistency),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 26),
                          const _SectionTitle(
                            title: 'Körperverlauf',
                            subtitle:
                                'Gewicht und optionaler Taillenumfang – ruhig und langfristig betrachtet',
                          ),
                          const SizedBox(height: 11),
                          AnimatedReveal(
                            delay: const Duration(milliseconds: 300),
                            child: _WeightCard(
                              records: snapshot.weights,
                              targetWeight: controller.targetWeight,
                              onAdd: _addWeight,
                            ),
                          ),
                          const SizedBox(height: 13),
                          AnimatedReveal(
                            delay: const Duration(milliseconds: 360),
                            child: _InsightsCard(
                              snapshot: snapshot,
                              controller: controller,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onSelected});
  final ProgressPeriod selected;
  final ValueChanged<ProgressPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ProgressPeriod.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final period = ProgressPeriod.values[index];
          final active = period == selected;
          return Semantics(
            button: true,
            selected: active,
            child: InkWell(
              onTap: () => onSelected(period),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 17),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.border,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .18),
                            blurRadius: 16,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  period.label,
                  style: TextStyle(
                    color: active ? AppColors.black : AppColors.textMuted,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12,
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

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({
    required this.snapshot,
    required this.controller,
    required this.period,
  });
  final ProgressSnapshot snapshot;
  final AppController controller;
  final ProgressPeriod period;

  @override
  Widget build(BuildContext context) {
    final score = snapshot.adherence(
      calorieGoal: controller.calorieGoal,
      proteinGoal: controller.proteinGoal,
    );
    final tracked = snapshot.trackedDayCount;
    final total = period.days ?? math.max(tracked, 1);
    final text = tracked == 0
        ? 'Dein erster Eintrag macht Trends sichtbar.'
        : score >= .85
        ? 'Du liegst sehr nah an deinen persönlichen Zielen.'
        : score >= .65
        ? 'Deine Richtung stimmt – Beständigkeit bringt jetzt am meisten.'
        : 'Regelmäßiges Tracken schafft zuerst Klarheit.';
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withValues(alpha: .15),
          AppColors.surfaceHigh,
          AppColors.mint.withValues(alpha: .05),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StatusPill(
                  label: 'DEIN RHYTHMUS',
                  icon: Icons.auto_graph_rounded,
                ),
                const SizedBox(height: 13),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  tracked == 0
                      ? 'Trage Mahlzeiten ein und ergänze dein Gewicht. LIVO berechnet danach nur aus deinen echten Daten.'
                      : '$tracked von $total Tagen mit Einträgen · ${snapshot.mealCount} Mahlzeiten ausgewertet',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    height: 1.45,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          _ScoreRing(value: score),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => SizedBox.square(
        dimension: 86,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: animated,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(animated * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Zielnähe',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.snapshot, required this.controller});
  final ProgressSnapshot snapshot;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _Metric(
        Icons.local_fire_department_outlined,
        AppColors.orange,
        '${snapshot.average((day) => day.calories).round()}',
        'Ø kcal / Track-Tag',
      ),
      _Metric(
        Icons.fitness_center_rounded,
        AppColors.mint,
        '${snapshot.average((day) => day.protein).round()} g',
        'Ø Protein / Track-Tag',
      ),
      _Metric(
        Icons.check_circle_outline_rounded,
        AppColors.primary,
        '${snapshot.calorieGoalDays(controller.calorieGoal)}',
        'Tage im Kalorienbereich',
      ),
      _Metric(
        Icons.bolt_rounded,
        AppColors.blue,
        '${controller.streakDays} Tage',
        'Aktuelle Serie',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 850
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        const gap = 11.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  child: _MetricCard(metric: metric),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _Metric {
  const _Metric(this.icon, this.color, this.value, this.label);
  final IconData icon;
  final Color color;
  final String value;
  final String label;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});
  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: metric.color.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(metric.icon, color: metric.color, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metric.label,
                  maxLines: 2,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    height: 1.25,
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

class _NutritionTrendCard extends StatelessWidget {
  const _NutritionTrendCard({
    required this.snapshot,
    required this.calorieGoal,
    required this.proteinGoal,
    required this.period,
  });
  final ProgressSnapshot snapshot;
  final int calorieGoal;
  final int proteinGoal;
  final ProgressPeriod period;

  @override
  Widget build(BuildContext context) {
    final buckets = _buckets(snapshot.nutrition, period);
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(label: 'KALORIEN', color: AppColors.primary),
              StatusPill(label: 'PROTEIN', color: AppColors.mint),
              StatusPill(label: 'ZIEL = 100 %', color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 22),
          if (buckets.isEmpty)
            const _EmptyPanel(
              icon: Icons.bar_chart_rounded,
              title: 'Noch kein Ernährungstrend',
              text:
                  'Nach deinem ersten Tagebucheintrag entsteht hier automatisch ein echter Verlauf.',
            )
          else
            SizedBox(
              height: 205,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: buckets.map((bucket) {
                  final calorieRatio = calorieGoal <= 0
                      ? 0.0
                      : bucket.calories / calorieGoal;
                  final proteinRatio = proteinGoal <= 0
                      ? 0.0
                      : bucket.protein / proteinGoal;
                  return Expanded(
                    child: Tooltip(
                      message:
                          '${bucket.label}: ${bucket.calories.round()} kcal · ${bucket.protein.round()} g Protein',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _TrendBar(
                                  value: calorieRatio,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 3),
                                _TrendBar(
                                  value: proteinRatio,
                                  color: AppColors.mint,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            bucket.label,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrendBar extends StatelessWidget {
  const _TrendBar({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1.25)),
      duration: const Duration(milliseconds: 720),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => Container(
        width: 8,
        height: 145 * (animated / 1.25),
        decoration: BoxDecoration(
          color: value > 1.1 ? AppColors.orange : color,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: .18), blurRadius: 8),
          ],
        ),
      ),
    );
  }
}

class _MacroBalanceCard extends StatelessWidget {
  const _MacroBalanceCard({required this.snapshot, required this.controller});
  final ProgressSnapshot snapshot;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Makro-Balance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Durchschnitt an getrackten Tagen',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 19),
          _MacroRow(
            label: 'Protein',
            value: snapshot.average((day) => day.protein),
            goal: controller.proteinGoal.toDouble(),
            color: AppColors.mint,
          ),
          const SizedBox(height: 15),
          _MacroRow(
            label: 'Kohlenhydrate',
            value: snapshot.average((day) => day.carbs),
            goal: controller.diaryCarbohydrateGoal.toDouble(),
            color: AppColors.blue,
          ),
          const SizedBox(height: 15),
          _MacroRow(
            label: 'Fett',
            value: snapshot.average((day) => day.fat),
            goal: controller.diaryFatGoal.toDouble(),
            color: AppColors.orange,
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
  });
  final String label;
  final double value;
  final double goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = goal <= 0 ? 0.0 : value / goal;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              '${value.round()} / ${goal.round()} g',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: ratio.clamp(0, 1)),
            duration: const Duration(milliseconds: 700),
            builder: (_, animated, _) => LinearProgressIndicator(
              value: animated,
              minHeight: 7,
              color: color,
              backgroundColor: AppColors.border,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConsistencyCard extends StatelessWidget {
  const _ConsistencyCard({
    required this.snapshot,
    required this.calorieGoal,
    required this.period,
  });
  final ProgressSnapshot snapshot;
  final int calorieGoal;
  final ProgressPeriod period;

  @override
  Widget build(BuildContext context) {
    final byDate = {
      for (final day in snapshot.nutrition) _dayKey(day.date): day,
    };
    final today = DateTime.now();
    final visibleCount = math.min(period.days ?? 28, 28);
    final cells = List.generate(visibleCount, (index) {
      final date = DateTime(
        today.year,
        today.month,
        today.day - visibleCount + index + 1,
      );
      return (date: date, data: byDate[_dayKey(date)]);
    });
    final tracked = cells.where((cell) => cell.data?.tracked == true).length;
    final rate = visibleCount == 0 ? 0.0 : tracked / visibleCount;
    return SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tracking-Konstanz',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${(rate * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Die letzten maximal 28 Tage',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 7,
              crossAxisSpacing: 7,
            ),
            itemCount: cells.length,
            itemBuilder: (context, index) {
              final cell = cells[index];
              final data = cell.data;
              final close =
                  data != null &&
                  data.tracked &&
                  (data.calories - calorieGoal).abs() <= calorieGoal * .1;
              final color = data == null || !data.tracked
                  ? AppColors.border
                  : close
                  ? AppColors.primary
                  : AppColors.mint.withValues(alpha: .55);
              return Tooltip(
                message: data == null || !data.tracked
                    ? '${cell.date.day}.${cell.date.month}. · kein Eintrag'
                    : '${cell.date.day}.${cell.date.month}. · ${data.calories.round()} kcal',
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 13),
          const Wrap(
            spacing: 13,
            runSpacing: 7,
            children: [
              _LegendDot(color: AppColors.primary, label: 'im Zielbereich'),
              _LegendDot(color: AppColors.mint, label: 'getrackt'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 9.5),
        ),
      ],
    );
  }
}

class _WeightCard extends StatelessWidget {
  const _WeightCard({
    required this.records,
    required this.targetWeight,
    required this.onAdd,
  });
  final List<WeightRecord> records;
  final double targetWeight;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final latest = records.isEmpty ? null : records.last;
    final change = records.length < 2
        ? null
        : records.last.weightKg - records.first.weightKg;
    return SurfaceCard(
      padding: const EdgeInsets.all(19),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.blue.withValues(alpha: .07),
          AppColors.surfaceHigh,
          AppColors.surface,
        ],
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
                    const Text(
                      'Gewicht',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      latest == null
                          ? 'Noch keine Messung'
                          : '${latest.weightKg.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.5,
                      ),
                    ),
                    if (change != null)
                      Text(
                        '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} kg im Zeitraum',
                        style: const TextStyle(
                          color: AppColors.mint,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Eintragen'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (records.isEmpty)
            const _EmptyPanel(
              icon: Icons.monitor_weight_outlined,
              title: 'Dein echter Verlauf beginnt hier',
              text:
                  'Ein bis zwei Messungen pro Woche reichen. Tages-Schwankungen sind normal.',
            )
          else
            SizedBox(
              height: 190,
              width: double.infinity,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, animation, _) => CustomPaint(
                  painter: _WeightPainter(
                    records: records,
                    target: targetWeight,
                    animation: animation,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeightPainter extends CustomPainter {
  const _WeightPainter({
    required this.records,
    required this.target,
    required this.animation,
  });
  final List<WeightRecord> records;
  final double target;
  final double animation;

  @override
  void paint(Canvas canvas, Size size) {
    final values = records.map((record) => record.weightKg).toList();
    final minValue = math.min(target, values.reduce(math.min)) - .5;
    final maxValue = math.max(target, values.reduce(math.max)) + .5;
    final range = math.max(1, maxValue - minValue);
    final rect = Rect.fromLTRB(10, 12, size.width - 10, size.height - 20);
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = rect.top + rect.height * i / 3;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), grid);
    }
    final targetY = rect.bottom - (target - minValue) / range * rect.height;
    final targetPaint = Paint()
      ..color = AppColors.orange.withValues(alpha: .55)
      ..strokeWidth = 1.4;
    for (var x = rect.left; x < rect.right; x += 9) {
      canvas.drawLine(
        Offset(x, targetY),
        Offset(math.min(x + 5, rect.right), targetY),
        targetPaint,
      );
    }
    final points = List.generate(values.length, (index) {
      final x = values.length == 1
          ? rect.center.dx
          : rect.left + rect.width * index / (values.length - 1);
      final y = rect.bottom - (values[index] - minValue) / range * rect.height;
      return Offset(x, y);
    });
    if (points.length == 1) {
      canvas.drawCircle(points.first, 5, Paint()..color = AppColors.primary);
      return;
    }
    final full = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final middle = (previous.dx + current.dx) / 2;
      full.cubicTo(
        middle,
        previous.dy,
        middle,
        current.dy,
        current.dx,
        current.dy,
      );
    }
    final metric = full.computeMetrics().first;
    final visible = metric.extractPath(0, metric.length * animation);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.mint, AppColors.primary],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(visible, paint);
    if (animation > .95) {
      for (final point in points) {
        canvas.drawCircle(point, 3.5, Paint()..color = AppColors.primary);
      }
    }
  }

  @override
  bool shouldRepaint(_WeightPainter oldDelegate) =>
      oldDelegate.animation != animation ||
      oldDelegate.records != records ||
      oldDelegate.target != target;
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard({required this.snapshot, required this.controller});
  final ProgressSnapshot snapshot;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final tracked = snapshot.trackedDayCount;
    final avgProtein = snapshot.average((day) => day.protein);
    final proteinDays = snapshot.proteinGoalDays(controller.proteinGoal);
    final insights = <String>[
      tracked == 0
          ? 'Trage auch an normalen Tagen ein. So wird dein Trend ehrlich und nützlich.'
          : '$tracked Tage liefern bereits eine bessere Grundlage als ein einzelner Tageswert.',
      avgProtein >= controller.proteinGoal * .9
          ? 'Dein Proteindurchschnitt liegt nah am Ziel. Das unterstützt Sättigung und Muskelerhalt.'
          : 'An $proteinDays Tagen lag Protein nahe am Ziel. Eine feste Proteinquelle pro Mahlzeit kann helfen.',
      snapshot.weights.length < 2
          ? 'Für einen Gewichtstrend genügen ein bis zwei Messungen pro Woche unter ähnlichen Bedingungen.'
          : 'Bewerte Gewicht über mehrere Wochen; Wasser und Salz verschieben einzelne Messungen.',
    ];
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: .075),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: .16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Was deine Daten sagen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ...insights.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.mint,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        height: 1.42,
                        fontSize: 12,
                      ),
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

class _WeightSheet extends StatefulWidget {
  const _WeightSheet();

  @override
  State<_WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends State<_WeightSheet> {
  final _weight = TextEditingController();
  final _waist = TextEditingController();
  DateTime _date = DateTime.now();
  String? _error;

  @override
  void dispose() {
    _weight.dispose();
    _waist.dispose();
    super.dispose();
  }

  double? _parse(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  void _submit() {
    final weight = _parse(_weight.text);
    final waist = _waist.text.trim().isEmpty ? null : _parse(_waist.text);
    if (weight == null || weight < 25 || weight > 400) {
      setState(
        () => _error =
            'Bitte gib ein realistisches Gewicht zwischen 25 und 400 kg ein.',
      );
      return;
    }
    if (waist != null && (waist < 30 || waist > 300)) {
      setState(
        () => _error = 'Der Taillenumfang muss zwischen 30 und 300 cm liegen.',
      );
      return;
    }
    Navigator.pop(
      context,
      _WeightInput(date: _date, weight: weight, waist: waist),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.borderBright)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderBright,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Neue Messung',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              const Text(
                'Eine Messung ersetzt den Wert desselben Tages.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      controller: _weight,
                      label: 'Gewicht',
                      suffix: 'kg',
                      autofocus: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NumberField(
                      controller: _waist,
                      label: 'Taille (optional)',
                      suffix: 'cm',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDate: _date,
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: AppColors.mint,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.orange, fontSize: 11),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Messung speichern'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    this.autofocus = false,
  });
  final TextEditingController controller;
  final String label;
  final String suffix;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, suffixText: suffix),
    );
  }
}

class _WeightInput {
  const _WeightInput({required this.date, required this.weight, this.waist});
  final DateTime date;
  final double weight;
  final double? waist;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mint, size: 28),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
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

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 320,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EmptyPanel(
          icon: Icons.cloud_off_outlined,
          title: message,
          text: 'Prüfe deine Verbindung und versuche es erneut.',
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Erneut versuchen'),
        ),
      ],
    );
  }
}

class _TrendBucket {
  const _TrendBucket({
    required this.label,
    required this.calories,
    required this.protein,
  });
  final String label;
  final double calories;
  final double protein;
}

List<_TrendBucket> _buckets(List<NutritionDay> days, ProgressPeriod period) {
  final tracked = days.where((day) => day.tracked).toList();
  if (tracked.isEmpty) return const [];
  final maxBuckets = period == ProgressPeriod.sevenDays ? 7 : 12;
  final chunkSize = math.max(1, (tracked.length / maxBuckets).ceil());
  final result = <_TrendBucket>[];
  for (var index = 0; index < tracked.length; index += chunkSize) {
    final chunk = tracked.sublist(
      index,
      math.min(index + chunkSize, tracked.length),
    );
    final calories =
        chunk.fold<double>(0, (sum, day) => sum + day.calories) / chunk.length;
    final protein =
        chunk.fold<double>(0, (sum, day) => sum + day.protein) / chunk.length;
    final date = chunk.last.date;
    result.add(
      _TrendBucket(
        label: period == ProgressPeriod.sevenDays
            ? _weekday(date.weekday)
            : '${date.day}.${date.month}.',
        calories: calories,
        protein: protein,
      ),
    );
  }
  return result;
}

String _weekday(int value) =>
    const ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][value - 1];

String _dayKey(DateTime date) => '${date.year}-${date.month}-${date.day}';
