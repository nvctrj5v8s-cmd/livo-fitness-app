import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/domain/daily_targets.dart';
import '../domain/personalization_profile.dart';
import '../domain/recipe_preferences.dart';

/// Last step of the questions: first "Dein Plan wird erstellt …", then the
/// plan. The short wait is presentation only, so every line names something
/// Lookin really does with the answers – nothing is promised that the app
/// does not do. With reduced motion everything shows at once.
class PlanReveal extends StatefulWidget {
  const PlanReveal({
    required this.profile,
    required this.onReady,
    this.skipBuilding = false,
    super.key,
  });

  final PersonalizationProfile profile;

  /// Called once the plan is visible; the page then enables "Fertig".
  final VoidCallback onReady;

  /// The plan was already built once in this session.
  final bool skipBuilding;

  @override
  State<PlanReveal> createState() => _PlanRevealState();
}

class _PlanRevealState extends State<PlanReveal> with TickerProviderStateMixin {
  static const _stepDuration = Duration(milliseconds: 720);

  late final List<_BuildStep> _steps = _buildStepsFor(widget.profile);
  late final AnimationController _build = AnimationController(
    vsync: this,
    duration: _stepDuration * _steps.length + const Duration(milliseconds: 450),
  );
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    // Without answers there is nothing to build – no show, no numbers.
    if (widget.skipBuilding || reduceMotion || !widget.profile.hasAnswers) {
      _build.value = 1;
      if (reduceMotion) {
        _reveal.value = 1;
      } else {
        unawaited(_reveal.forward());
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onReady();
      });
      return;
    }
    unawaited(
      _build.forward().then((_) {
        if (!mounted) return;
        unawaited(HapticFeedback.mediumImpact());
        setState(() {});
        widget.onReady();
        unawaited(_reveal.forward());
      }),
    );
  }

  @override
  void dispose() {
    _build.dispose();
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final building = !_build.isCompleted;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: .97, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: building
          ? _BuildingView(
              key: const ValueKey('plan-building'),
              animation: _build,
              steps: _steps,
            )
          : _PlanView(
              key: const ValueKey('personal-summary'),
              profile: widget.profile,
              animation: _reveal,
            ),
    );
  }
}

class _BuildStep {
  const _BuildStep(this.icon, this.text);
  final IconData icon;
  final String text;
}

/// What Lookin really does with these answers, in that order. Every line
/// mirrors the actual calculation or setting; nothing is added for show.
List<_BuildStep> _buildStepsFor(PersonalizationProfile profile) {
  final targets = DailyTargets.fromProfile(profile);
  final energyInputs = [
    'Alter',
    'Größe',
    'Gewicht',
    if (profile.sex == BodySex.female || profile.sex == BodySex.male)
      'Geschlecht',
    if (profile.activity != null) 'Alltag',
  ];
  final sorting = recipeSortingReasons(profile);
  return [
    if (targets.isReady) ...[
      _BuildStep(
        Icons.calculate_outlined,
        'Energiebedarf aus ${joinGerman(energyInputs)} berechnen',
      ),
      _BuildStep(
        Icons.pie_chart_outline_rounded,
        profile.goal == PersonalGoal.loseWeight ||
                profile.goal == PersonalGoal.buildStrength
            ? 'Eiweiß und Fett passend zu deinem Ziel festlegen'
            : 'Eiweiß und Fett aus deinem Gewicht ableiten',
      ),
      if (profile.weeksToTarget() case final weeks? when weeks > 0)
        const _BuildStep(
          Icons.show_chart_rounded,
          'Zeit bis zu deinem Wunschgewicht abschätzen',
        ),
    ] else if (targets.isPaused)
      const _BuildStep(
        Icons.favorite_outline_rounded,
        'Kalorienziele für dich bewusst weglassen',
      )
    else
      const _BuildStep(
        Icons.fact_check_outlined,
        'Deine Antworten zusammenfassen',
      ),
    if (profile.allergies.trim().isNotEmpty)
      const _BuildStep(
        Icons.no_food_outlined,
        'Rezepte mit deinen Allergenen aussortieren',
      ),
    if (sorting.isNotEmpty)
      _BuildStep(
        Icons.restaurant_menu_rounded,
        'Rezepte nach ${joinGerman(sorting)} sortieren',
      ),
    if (profile.obstacles.isNotEmpty ||
        profile.motivations.isNotEmpty ||
        profile.experience != null)
      const _BuildStep(
        Icons.auto_awesome_outlined,
        'Deinem Coach deine Antworten als Hintergrund mitgeben',
      ),
  ];
}

// --- Building ------------------------------------------------------------------

class _BuildingView extends StatelessWidget {
  const _BuildingView({
    required this.animation,
    required this.steps,
    super.key,
  });

  final Animation<double> animation;
  final List<_BuildStep> steps;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        // The last 450 ms are a short pause on 100 %.
        final progress = (animation.value * 1.12).clamp(0.0, 1.0);
        final active = (progress * steps.length).floor();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: _ProgressOrb(progress: progress)),
            const SizedBox(height: 22),
            for (final (index, step) in steps.indexed)
              _StepLine(
                step: step,
                state: index < active
                    ? _LineState.done
                    : index == active
                    ? _LineState.active
                    : _LineState.waiting,
              ),
          ],
        );
      },
    );
  }
}

class _ProgressOrb extends StatelessWidget {
  const _ProgressOrb({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final percent = (Curves.easeOut.transform(progress) * 100).round();
    return Semantics(
      label: 'Plan wird erstellt, $percent Prozent',
      excludeSemantics: true,
      child: SizedBox(
        width: 136,
        height: 136,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: .10 + .18 * progress,
                    ),
                    blurRadius: 34,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            CustomPaint(
              size: const Size.square(136),
              painter: _RingPainter(Curves.easeOut.transform(progress)),
            ),
            Text(
              '$percent %',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final ring = rect.deflate(9);
    canvas.drawArc(
      ring,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = AppColors.border,
    );
    if (value <= 0) return;
    canvas.drawArc(
      ring,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: math.pi * 1.5,
          colors: [AppColors.mint, AppColors.primary, AppColors.mint],
        ).createShader(ring),
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.value != value;
}

enum _LineState { waiting, active, done }

class _StepLine extends StatelessWidget {
  const _StepLine({required this.step, required this.state});

  final _BuildStep step;
  final _LineState state;

  @override
  Widget build(BuildContext context) {
    final visible = state != _LineState.waiting;
    return AnimatedOpacity(
      opacity: visible ? 1 : .22,
      duration: const Duration(milliseconds: 260),
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, .25),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 26,
                height: 26,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: switch (state) {
                    _LineState.done => Container(
                      key: const ValueKey('done'),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 17,
                        color: AppColors.black,
                      ),
                    ),
                    _LineState.active => const Padding(
                      key: ValueKey('active'),
                      padding: EdgeInsets.all(4),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.primary,
                      ),
                    ),
                    _LineState.waiting => Icon(
                      step.icon,
                      key: const ValueKey('waiting'),
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.text,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.3,
                    fontWeight: state == _LineState.active
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: state == _LineState.done
                        ? AppColors.textMuted
                        : AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Result --------------------------------------------------------------------

class _PlanView extends StatelessWidget {
  const _PlanView({required this.profile, required this.animation, super.key});

  final PersonalizationProfile profile;
  final Animation<double> animation;

  static const _monthNames = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', //
    'August', 'September', 'Oktober', 'November', 'Dezember',
  ];

  Animation<double> _part(double start, double end) => CurvedAnimation(
    parent: animation,
    curve: Interval(start, end, curve: Curves.easeOutCubic),
  );

  @override
  Widget build(BuildContext context) {
    final targets = DailyTargets.fromProfile(profile);
    final weeks = targets.isReady ? profile.weeksToTarget() : null;
    final current = profile.weightKg;
    final target = profile.targetWeightKg;
    final showChart =
        weeks != null && weeks > 0 && current != null && target != null;
    final benefits = _benefits();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Appear(
          animation: _part(0, .32),
          child: !profile.hasAnswers
              ? const _NeutralCard()
              : targets.isReady
              ? _TargetsCard(targets: targets, animation: _part(.05, .6))
              : _PausedCard(status: targets.status),
        ),
        if (showChart) ...[
          const SizedBox(height: 14),
          _Appear(
            animation: _part(.22, .45),
            child: _GoalCard(
              current: current,
              target: target,
              dateLabel: _month(DateTime.now().add(Duration(days: weeks * 7))),
              paceLabel: profile.goal == PersonalGoal.loseWeight
                  ? (profile.pace ?? WeightPace.gentle).label.toLowerCase()
                  : null,
              imperial: profile.measurementSystem == MeasurementSystem.imperial,
              progress: _part(.3, .85),
            ),
          ),
        ],
        const SizedBox(height: 18),
        _Appear(
          animation: _part(.4, .55),
          child: const Text(
            'Das macht Lookin jetzt für dich',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 10),
        for (final (index, (icon, text)) in benefits.indexed)
          _Appear(
            animation: _part(
              math.min(.45 + index * .08, .9),
              math.min(.65 + index * .08, 1),
            ),
            child: _BenefitLine(icon: icon, text: text),
          ),
        const SizedBox(height: 6),
        _Appear(
          animation: _part(.8, 1),
          child: const Text(
            'Richtwerte zur Orientierung, keine medizinische Beratung. Du kannst '
            'alles jederzeit im Profil anpassen.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// Only things the app does with these answers – same rules as the
  /// recipe order and the coach context.
  List<(IconData, String)> _benefits() {
    final sorting = recipeSortingReasons(profile);
    return [
      if (profile.allergies.trim().isNotEmpty)
        (
          Icons.no_food_outlined,
          'Rezepte mit deinen Allergenen blendet Lookin aus.',
        ),
      if (sorting.isNotEmpty)
        (
          Icons.restaurant_menu_rounded,
          'Rezepte erscheinen sortiert nach ${joinGerman(sorting)}.',
        ),
      if (profile.obstacles.isNotEmpty || profile.motivations.isNotEmpty)
        (
          Icons.psychology_outlined,
          'Dein Coach kennt deine Ziele und Hürden und richtet Tipps daran '
              'aus.',
        ),
      (
        Icons.edit_note_rounded,
        'Mahlzeiten per Suche oder Barcode eintragen – mit Premium auch per '
            'Foto.',
      ),
    ];
  }

  String _month(DateTime date) => '${_monthNames[date.month - 1]} ${date.year}';
}

class _Appear extends StatelessWidget {
  const _Appear({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, .12),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    ),
  );
}

class _TargetsCard extends StatelessWidget {
  const _TargetsCard({required this.targets, required this.animation});

  final DailyTargets targets;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final calories = targets.calories!;
    final protein = targets.protein!;
    final fat = targets.fat!;
    // The rest of the energy, as carbohydrates (4 kcal per gram).
    final carbs = math.max(0, (calories - protein * 4 - fat * 9) / 4).round();
    final macros = [
      ('Eiweiß', protein, protein * 4 / calories, AppColors.mint),
      ('Kohlenhydrate', carbs, carbs * 4 / calories, AppColors.blue),
      ('Fett', fat, fat * 9 / calories, AppColors.orange),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: .18),
            AppColors.mint.withValues(alpha: .05),
          ],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: .45)),
      ),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = animation.value;
          final shown = (calories * t / 10).round() * 10;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Dein Tagesrichtwert',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$shown',
                      style: const TextStyle(
                        fontSize: 44,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.8,
                      ),
                    ),
                    const TextSpan(
                      text: ' kcal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                key: const ValueKey('personal-summary-calories'),
                semanticsLabel: '$calories Kilokalorien pro Tag',
              ),
              const SizedBox(height: 16),
              for (final (label, grams, share, color) in macros) ...[
                _MacroBar(
                  label: label,
                  grams: (grams * t).round(),
                  share: share * t,
                  color: color,
                ),
                const SizedBox(height: 9),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.grams,
    required this.share,
    required this.color,
  });

  final String label;
  final int grams;
  final double share;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '$grams g',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: Stack(
          children: [
            Container(height: 7, color: AppColors.border),
            FractionallySizedBox(
              widthFactor: share.clamp(0.0, 1.0),
              child: Container(
                height: 7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: .65), color],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

/// Everything was skipped: say plainly that nothing was personalised.
class _NeutralCard extends StatelessWidget {
  const _NeutralCard();

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('personal-summary-neutral'),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      color: AppColors.surfaceHigh,
      border: Border.all(color: AppColors.border),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.tune_rounded, color: AppColors.primary),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Du hast keine Angaben gemacht. Darum berechnet Lookin noch keine '
            'Tagesziele und sortiert Rezepte nicht für dich. Sobald du im '
            'Profil etwas ergänzt, passt sich Lookin an.',
            style: TextStyle(height: 1.45),
          ),
        ),
      ],
    ),
  );
}

class _PausedCard extends StatelessWidget {
  const _PausedCard({required this.status});

  final DailyTargetsStatus status;

  @override
  Widget build(BuildContext context) {
    final text = switch (status) {
      DailyTargetsStatus.professionalGuidance =>
        'Für dich berechnet Lookin keine Kalorienziele. Tagebuch, Rezepte und '
            'Coach kannst du trotzdem nutzen – deine Ziele besprichst du am '
            'besten mit einer Ärztin, einem Arzt oder einer Ernährungsfachkraft.',
      DailyTargetsStatus.underage =>
        'Für Personen unter 18 Jahren berechnet Lookin keine Kalorienziele. '
            'Rezepte, Tagebuch und Tipps kannst du trotzdem nutzen.',
      _ =>
        'Ohne Alter, Größe und Gewicht berechnet Lookin keine Tagesziele. Du '
            'kannst sie jederzeit im Profil ergänzen.',
    };
    return Container(
      key: const ValueKey('personal-summary-paused'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.surfaceHigh,
        border: Border.all(color: AppColors.mint.withValues(alpha: .4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.favorite_rounded, color: AppColors.mint),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(height: 1.45))),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.current,
    required this.target,
    required this.dateLabel,
    required this.paceLabel,
    required this.imperial,
    required this.progress,
  });

  final double current;
  final double target;
  final String dateLabel;
  final String? paceLabel;
  final bool imperial;
  final Animation<double> progress;

  String _weight(double kg) => imperial
      ? '${(kg * 2.2046226218).round()} lb'
      : '${kg.toStringAsFixed(1).replaceAll('.', ',').replaceAll(',0', '')} kg';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.surfaceHigh,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_weight(target)} etwa im $dateLabel',
            key: const ValueKey('personal-summary-date'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: progress,
              builder: (context, _) => CustomPaint(
                painter: _GoalChartPainter(
                  progress: progress.value,
                  falling: target < current,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Heute · ${_weight(current)}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  dateLabel,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            paceLabel == null
                ? 'Grobe Schätzung – dein Körper hält sich nicht an Kalender.'
                : 'Grobe Schätzung bei $paceLabel Tempo – dein Körper hält sich '
                      'nicht an Kalender.',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// A smooth line from today to the estimated date. The real course will
/// vary; the caption says so ('Grobe Schätzung').
class _GoalChartPainter extends CustomPainter {
  _GoalChartPainter({required this.progress, required this.falling});

  final double progress;
  final bool falling;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 10.0;
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final y = inset + (size.height - 2 * inset) * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final start = Offset(inset, falling ? inset : size.height - inset);
    final end = Offset(
      size.width - inset,
      falling ? size.height - inset : inset,
    );
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx + (end.dx - start.dx) * .45,
        start.dy,
        start.dx + (end.dx - start.dx) * .55,
        end.dy,
        end.dx,
        end.dy,
      );
    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);
    if (progress > 0) {
      final tip = metric
          .getTangentForOffset(metric.length * progress)!
          .position;
      final area = Path.from(drawn)
        ..lineTo(tip.dx, size.height)
        ..lineTo(start.dx, size.height)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader =
              ui.Gradient.linear(Offset(0, inset), Offset(0, size.height), [
                AppColors.primary.withValues(alpha: .22),
                AppColors.primary.withValues(alpha: 0),
              ]),
      );
      canvas.drawPath(
        drawn,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(start, end, [
            AppColors.mint,
            AppColors.primary,
          ]),
      );
      canvas.drawCircle(tip, 5, Paint()..color = AppColors.primary);
    }
    canvas.drawCircle(start, 5, Paint()..color = AppColors.mint);
    if (progress >= .98) {
      canvas.drawCircle(
        end,
        11,
        Paint()..color = AppColors.primary.withValues(alpha: .25),
      );
      canvas.drawCircle(end, 6, Paint()..color = AppColors.primary);
    }
  }

  @override
  bool shouldRepaint(_GoalChartPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.falling != falling;
}

class _BenefitLine extends StatelessWidget {
  const _BenefitLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: AppColors.primary),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              text,
              style: const TextStyle(fontSize: 13.5, height: 1.35),
            ),
          ),
        ),
      ],
    ),
  );
}
