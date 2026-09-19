import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Decorative previews with illustrative values. The page owns animation timing,
/// replay and reduced motion; these scenes only draw the supplied progress.
class IntroductionArtwork extends StatelessWidget {
  const IntroductionArtwork({
    required this.index,
    required this.progress,
    required this.accent,
    super.key,
  });

  final int index;
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final position = progress.clamp(0.0, 1.0);
    final entry = _phase(position, 0, 0.5);
    final (badge, labelIcon, label) = switch (index) {
      0 => (
        Icons.restaurant_rounded,
        Icons.check_rounded,
        'Eintragen. Weiterleben.',
      ),
      1 => (
        Icons.eco_outlined,
        Icons.shopping_bag_outlined,
        'Deine Einkaufsliste ist dabei',
      ),
      2 => (
        Icons.water_drop_outlined,
        Icons.check_circle_outline_rounded,
        'Kleine Routinen. Dein Alltag.',
      ),
      3 => (
        Icons.insights_rounded,
        Icons.trending_up_rounded,
        'Jeder kleine Schritt zählt',
      ),
      _ => (
        Icons.tune_rounded,
        Icons.favorite_border_rounded,
        'So individuell wie du',
      ),
    };

    return ExcludeSemantics(
      child: MediaQuery.withNoTextScaling(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 380,
            height: 390,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _OrbitPainter(accent, position)),
                ),
                Transform.translate(
                  offset: Offset(0, 20 * (1 - entry)),
                  child: Transform.rotate(
                    angle: -0.045 + 0.03 * entry,
                    child: _PreviewBoard(
                      accent: accent,
                      child: switch (index) {
                        0 => _DayPreview(position, accent),
                        1 => _PlanPreview(position, accent),
                        2 => _WaterPreview(position, accent),
                        3 => _ProgressPreview(position, accent),
                        _ => _ProfilePreview(position, accent),
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: 6,
                  bottom: 12,
                  child: _Enter(
                    progress: position,
                    start: 0.48,
                    end: 0.94,
                    child: Transform.rotate(
                      angle: -0.045,
                      child: _FloatingLabel(labelIcon, label, accent),
                    ),
                  ),
                ),
                Positioned(
                  top: 24,
                  right: 5,
                  child: _Enter(
                    progress: position,
                    start: 0.08,
                    end: 0.58,
                    distance: -20,
                    child: Transform.rotate(
                      angle: 0.09,
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(23),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.2),
                              blurRadius: 28,
                              offset: const Offset(0, 9),
                            ),
                          ],
                        ),
                        child: Icon(badge, color: AppColors.black, size: 29),
                      ),
                    ),
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

double _phase(double progress, double start, double end) => Curves.easeOutCubic
    .transform(((progress - start) / (end - start)).clamp(0.0, 1.0));

class _Enter extends StatelessWidget {
  const _Enter({
    required this.progress,
    required this.start,
    required this.end,
    required this.child,
    this.distance = 16,
  });

  final double progress;
  final double start;
  final double end;
  final double distance;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final value = _phase(progress, start, end);
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, distance * (1 - value)),
        child: child,
      ),
    );
  }
}

class _PreviewBoard extends StatelessWidget {
  const _PreviewBoard({required this.child, required this.accent});
  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    width: 288,
    height: 326,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(32),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(
            accent.withValues(alpha: 0.08),
            AppColors.surfaceHigh,
          ),
          AppColors.surface,
        ],
      ),
      border: Border.all(color: accent.withValues(alpha: 0.24)),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.65),
          blurRadius: 40,
          offset: const Offset(0, 22),
        ),
      ],
    ),
    child: child,
  );
}

/// Scales decorative labels inside the fixed artwork canvas, including when
/// tests use a wide fallback font. Accessible page text remains outside.
class _FitText extends StatelessWidget {
  const _FitText(
    this.text, {
    this.size = 12,
    this.color = AppColors.text,
    this.weight = FontWeight.w500,
    this.alignment = Alignment.centerLeft,
    this.spacing = 0,
  });

  final String text;
  final double size;
  final Color color;
  final FontWeight weight;
  final Alignment alignment;
  final double spacing;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: Text(
        text,
        maxLines: 1,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          height: 1.2,
        ),
      ),
    ),
  );
}

class _PreviewTitle extends StatelessWidget {
  const _PreviewTitle(this.label, this.icon, this.accent);
  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 19,
    child: Row(
      children: [
        Expanded(
          child: _FitText(
            label,
            size: 10,
            spacing: 1.6,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: accent, size: 18),
      ],
    ),
  );
}

class _DayPreview extends StatelessWidget {
  const _DayPreview(this.progress, this.accent);
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ring = _phase(progress, 0.08, 0.88);
    final calories = (1260 * ring).round();
    final calorieLabel = calories >= 1000
        ? '${calories ~/ 1000}.${(calories % 1000).toString().padLeft(3, '0')}'
        : '$calories';
    return Column(
      children: [
        _PreviewTitle('HEUTE IM BLICK', Icons.wb_sunny_outlined, accent),
        const SizedBox(height: 18),
        SizedBox(
          width: 157,
          height: 157,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _CalorieRingPainter(ring, accent)),
              Center(
                child: SizedBox(
                  width: 116,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _FitText(
                        calorieLabel,
                        size: 35,
                        weight: FontWeight.w800,
                        alignment: Alignment.center,
                        spacing: -1.2,
                      ),
                      const SizedBox(height: 4),
                      const _FitText(
                        'kcal erfasst',
                        size: 11,
                        color: AppColors.textMuted,
                        alignment: Alignment.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 21),
        Row(
          children: [
            Expanded(
              child: _SmallMetric(
                'Protein',
                '${(72 * ring).round()} g',
                0.7 * _phase(progress, 0.3, 0.9),
                accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _SmallMetric(
                'Kohlenh.',
                '${(145 * ring).round()} g',
                0.6 * _phase(progress, 0.39, 0.95),
                accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _SmallMetric(
                'Fett',
                '${(42 * ring).round()} g',
                0.48 * _phase(progress, 0.48, 1),
                accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SmallMetric extends StatelessWidget {
  const _SmallMetric(this.label, this.value, this.fill, this.accent);
  final String label;
  final String value;
  final double fill;
  final Color accent;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _FitText(
        value,
        size: 17,
        weight: FontWeight.w700,
        alignment: Alignment.center,
      ),
      const SizedBox(height: 4),
      _FitText(
        label,
        size: 9,
        color: AppColors.textMuted,
        alignment: Alignment.center,
      ),
      const SizedBox(height: 9),
      ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: fill,
          minHeight: 3,
          color: accent.withValues(alpha: 0.8),
          backgroundColor: AppColors.surfaceSoft,
        ),
      ),
    ],
  );
}

class _PlanPreview extends StatelessWidget {
  const _PlanPreview(this.progress, this.accent);
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _PreviewTitle('DEIN WOCHENPLAN', Icons.calendar_month_outlined, accent),
      const SizedBox(height: 17),
      Row(
        children: [
          for (var day = 0; day < 7; day++) ...[
            if (day > 0) const SizedBox(width: 6),
            Expanded(
              child: _Enter(
                progress: progress,
                start: 0.05 + day * 0.04,
                end: 0.43 + day * 0.04,
                distance: 8,
                child: Container(
                  height: 31,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: day == 2 ? accent : AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _FitText(
                    const ['M', 'D', 'M', 'D', 'F', 'S', 'S'][day],
                    size: 11,
                    weight: FontWeight.w700,
                    alignment: Alignment.center,
                    color: day == 2 ? AppColors.black : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 16),
      _Enter(
        progress: progress,
        start: 0.17,
        end: 0.64,
        child: _RecipeRow(
          'Grüne Bowl',
          'Frisch in 15 Min.',
          Icons.eco_outlined,
          accent,
        ),
      ),
      const SizedBox(height: 9),
      _Enter(
        progress: progress,
        start: 0.32,
        end: 0.81,
        child: _RecipeRow(
          'Ofengemüse',
          'Einfach vorbereiten',
          Icons.restaurant_outlined,
          accent,
        ),
      ),
      const SizedBox(height: 9),
      _Enter(
        progress: progress,
        start: 0.47,
        end: 0.97,
        child: _RecipeRow(
          'Beeren-Oats',
          'Dein Morgenmoment',
          Icons.spa_outlined,
          accent,
        ),
      ),
    ],
  );
}

class _RecipeRow extends StatelessWidget {
  const _RecipeRow(this.title, this.subtitle, this.icon, this.accent);
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    height: 53,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: accent.withValues(alpha: 0.09)),
    ),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FitText(title, size: 12, weight: FontWeight.w700),
              const SizedBox(height: 3),
              _FitText(subtitle, size: 9, color: AppColors.textMuted),
            ],
          ),
        ),
        const SizedBox(width: 7),
        Icon(Icons.check_circle_rounded, size: 15, color: accent),
      ],
    ),
  );
}

class _WaterPreview extends StatelessWidget {
  const _WaterPreview(this.progress, this.accent);
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final fill = _phase(progress, 0.08, 0.84);
    final liters = (1.25 * fill).toStringAsFixed(2).replaceAll('.', ',');
    const weekdays = ['M', 'D', 'M', 'D', 'F', 'S', 'S'];
    const heights = [0.48, 0.65, 0.55, 0.85, 0.72, 0.96, 0.63];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreviewTitle('WASSER & ROUTINE', Icons.water_drop_outlined, accent),
        const SizedBox(height: 17),
        SizedBox(
          height: 119,
          child: Row(
            children: [
              SizedBox(
                width: 91,
                height: 119,
                child: CustomPaint(painter: _WaterGlassPainter(fill, accent)),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FitText(
                      '$liters L',
                      size: 28,
                      weight: FontWeight.w800,
                      spacing: -0.8,
                    ),
                    const SizedBox(height: 5),
                    const _FitText(
                      'von 2 Litern',
                      size: 10,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 17),
                    Row(
                      children: [
                        for (var drop = 0; drop < 8; drop++)
                          Expanded(
                            child: Icon(
                              drop < (5 * fill).round()
                                  ? Icons.water_drop_rounded
                                  : Icons.water_drop_outlined,
                              size: 13,
                              color: drop < (5 * fill).round()
                                  ? accent
                                  : AppColors.textMuted.withValues(alpha: 0.5),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    _FitText(
                      '${(5 * fill).round()} von 8 Gläsern',
                      size: 9,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _FitText('DEINE WOCHE', size: 9, spacing: 1.5),
        const SizedBox(height: 12),
        SizedBox(
          height: 69,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var day = 0; day < 7; day++) ...[
                if (day > 0) const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor:
                                heights[day] *
                                _phase(
                                  progress,
                                  0.26 + day * 0.055,
                                  0.64 + day * 0.055,
                                ),
                            widthFactor: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: accent.withValues(
                                  alpha: day == 5 ? 1 : 0.38 + day * 0.06,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _FitText(
                        weekdays[day],
                        size: 9,
                        color: AppColors.textMuted,
                        alignment: Alignment.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressPreview extends StatelessWidget {
  const _ProgressPreview(this.progress, this.accent);
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _PreviewTitle('DEIN FORTSCHRITT', Icons.insights_rounded, accent),
      const SizedBox(height: 16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 38,
            child: _FitText(
              (5 * _phase(progress, 0.05, 0.75)).round().toString(),
              size: 42,
              weight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FitText('aktive Tage', size: 15, weight: FontWeight.w700),
                SizedBox(height: 4),
                _FitText('diese Woche', size: 10, color: AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _Enter(
            progress: progress,
            start: 0.52,
            end: 0.95,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.trending_up_rounded, color: accent, size: 22),
            ),
          ),
        ],
      ),
      const SizedBox(height: 11),
      SizedBox(
        height: 96,
        width: double.infinity,
        child: CustomPaint(
          painter: _TrendPainter(_phase(progress, 0.12, 0.94), accent),
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          for (final label in ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'])
            Expanded(
              child: _FitText(
                label,
                size: 9,
                color: AppColors.textMuted,
                alignment: Alignment.center,
              ),
            ),
        ],
      ),
      const SizedBox(height: 17),
      _Enter(
        progress: progress,
        start: 0.45,
        end: 0.94,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: accent.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: accent, size: 19),
              const SizedBox(width: 9),
              const Expanded(child: _FitText('Deine Routine wächst', size: 11)),
            ],
          ),
        ),
      ),
    ],
  );
}

class _ProfilePreview extends StatelessWidget {
  const _ProfilePreview(this.progress, this.accent);
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _PreviewTitle('DU IM MITTELPUNKT', Icons.tune_rounded, accent),
      const SizedBox(height: 16),
      _Enter(
        progress: progress,
        start: 0.03,
        end: 0.57,
        child: Row(
          children: [
            Transform.scale(
              scale: 0.8 + 0.2 * _phase(progress, 0.03, 0.57),
              child: SizedBox(
                width: 64,
                height: 64,
                child: CustomPaint(
                  painter: _AvatarRingPainter(
                    _phase(progress, 0.04, 0.73),
                    accent,
                  ),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.text,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FitText('Dein Profil.', size: 18, weight: FontWeight.w700),
                  SizedBox(height: 3),
                  _FitText('Dein Tempo.', size: 18, weight: FontWeight.w700),
                  SizedBox(height: 6),
                  _FitText(
                    'Passend zu deinem Alltag',
                    size: 9,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _Enter(
        progress: progress,
        start: 0.2,
        end: 0.66,
        child: _PreferenceRow(
          Icons.flag_outlined,
          'DEIN ZIEL',
          'Bewusster essen',
          accent,
        ),
      ),
      const SizedBox(height: 7),
      _Enter(
        progress: progress,
        start: 0.36,
        end: 0.82,
        child: _PreferenceRow(
          Icons.eco_outlined,
          'DEINE VORLIEBEN',
          'Vegetarisch',
          accent,
        ),
      ),
      const SizedBox(height: 7),
      _Enter(
        progress: progress,
        start: 0.52,
        end: 0.98,
        child: _PreferenceRow(
          Icons.schedule_rounded,
          'DEIN RHYTHMUS',
          'Flexibel planen',
          accent,
        ),
      ),
    ],
  );
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow(this.icon, this.label, this.value, this.accent);
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    height: 46,
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: accent.withValues(alpha: 0.1)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: accent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FitText(
                label,
                size: 8,
                spacing: 0.9,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 3),
              _FitText(value, size: 12, weight: FontWeight.w600),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.check_rounded, color: accent, size: 16),
      ],
    ),
  );
}

class _FloatingLabel extends StatelessWidget {
  const _FloatingLabel(this.icon, this.label, this.accent);
  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    width: 273,
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      color: AppColors.surfaceSoft,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: accent.withValues(alpha: 0.3)),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.45),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      children: [
        Icon(icon, color: accent, size: 18),
        const SizedBox(width: 8),
        Expanded(child: _FitText(label, size: 12, weight: FontWeight.w600)),
      ],
    ),
  );
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter(this.accent, this.progress);
  final Color accent;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [accent.withValues(alpha: 0.1), accent.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: 190));
    canvas.drawCircle(center, 190, glow);
    final stroke = Paint()
      ..color = accent.withValues(alpha: 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.4 + _phase(progress, 0, 1) * 0.16);
    canvas.drawOval(const Rect.fromLTWH(-183, -151, 366, 302), stroke);
    canvas.drawOval(const Rect.fromLTWH(-166, -181, 332, 362), stroke);
    canvas.restore();
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + 0.2;
      final position =
          center + Offset(math.cos(angle) * 177, math.sin(angle) * 176);
      canvas.drawCircle(
        position,
        i.isEven ? 3 : 1.5,
        Paint()..color = accent.withValues(alpha: i.isEven ? 0.55 : 0.3),
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.progress != progress;
}

class _CalorieRingPainter extends CustomPainter {
  const _CalorieRingPainter(this.progress, this.accent);
  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 8;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.surfaceSoft
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
    for (var i = 0; i < 36; i++) {
      final angle = -math.pi / 2 + i * math.pi / 18;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * (radius - 14),
        center + direction * (radius - 17),
        Paint()
          ..color = accent.withValues(alpha: i < 24 * progress ? 0.32 : 0.07)
          ..strokeWidth = 1.2,
      );
    }
    final sweep = math.pi * 2 * 0.67 * progress;
    if (sweep <= 0) return;
    canvas.drawArc(
      bounds,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 10,
    );
    final endpoint =
        center +
        Offset(math.cos(sweep - math.pi / 2), math.sin(sweep - math.pi / 2)) *
            radius;
    canvas.drawCircle(
      endpoint,
      10,
      Paint()..color = accent.withValues(alpha: 0.13),
    );
    canvas.drawCircle(endpoint, 3, Paint()..color = AppColors.text);
  }

  @override
  bool shouldRepaint(_CalorieRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.accent != accent;
}

class _WaterGlassPainter extends CustomPainter {
  const _WaterGlassPainter(this.progress, this.accent);
  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.13;
    final right = size.width * 0.87;
    final top = size.height * 0.06;
    final bottom = size.height * 0.93;
    final glass = Path()
      ..moveTo(left, top)
      ..lineTo(right, top)
      ..lineTo(right - 8, bottom - 9)
      ..quadraticBezierTo(right - 9, bottom, right - 18, bottom)
      ..lineTo(left + 18, bottom)
      ..quadraticBezierTo(left + 9, bottom, left + 8, bottom - 9)
      ..close();
    canvas.drawPath(glass, Paint()..color = AppColors.surfaceSoft);
    canvas.save();
    canvas.clipPath(glass);
    final level = bottom - (bottom - top) * 0.67 * progress;
    final wave = math.sin(progress * math.pi * 2) * 5;
    final liquid = Path()
      ..moveTo(0, level)
      ..cubicTo(
        size.width * 0.3,
        level + 5 + wave,
        size.width * 0.65,
        level - 6 - wave,
        size.width,
        level,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      liquid,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: 0.85),
            accent.withValues(alpha: 0.23),
          ],
        ).createShader(Offset.zero & size),
    );
    for (var bubble = 0; bubble < 3; bubble++) {
      final x = size.width * (0.34 + bubble * 0.17);
      final y = bottom - 10 - (15 + bubble * 13) * progress;
      if (y > level + 8) {
        canvas.drawCircle(
          Offset(x, y),
          2 + bubble * 0.5,
          Paint()..color = AppColors.text.withValues(alpha: 0.36),
        );
      }
    }
    canvas.restore();
    canvas.drawPath(
      glass,
      Paint()
        ..color = accent.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(left + 9, top + 12),
      Offset(left + 13, top + 47),
      Paint()
        ..color = AppColors.text.withValues(alpha: 0.17)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_WaterGlassPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.accent != accent;
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter(this.progress, this.accent);
  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 0.7;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final path = Path()..moveTo(4, size.height * 0.83);
    path.cubicTo(
      size.width * 0.19,
      size.height * 0.8,
      size.width * 0.14,
      size.height * 0.32,
      size.width * 0.33,
      size.height * 0.52,
    );
    path.cubicTo(
      size.width * 0.56,
      size.height * 0.87,
      size.width * 0.53,
      size.height * 0.2,
      size.width * 0.72,
      size.height * 0.32,
    );
    path.cubicTo(
      size.width * 0.86,
      size.height * 0.4,
      size.width * 0.86,
      size.height * 0.1,
      size.width - 5,
      size.height * 0.14,
    );
    if (progress <= 0) return;
    final metric = path.computeMetrics().first;
    final partial = metric.extractPath(0, metric.length * progress);
    final end = metric.getTangentForOffset(metric.length * progress)?.position;
    if (end == null) return;
    final fill = Path.from(partial)
      ..lineTo(end.dx, size.height)
      ..lineTo(4, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent.withValues(alpha: 0.22), accent.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      partial,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(end, 7, Paint()..color = accent.withValues(alpha: 0.2));
    canvas.drawCircle(end, 3.5, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_TrendPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.accent != accent;
}

class _AvatarRingPainter extends CustomPainter {
  const _AvatarRingPainter(this.progress, this.accent);
  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - 2,
    );
    canvas.drawOval(
      bounds,
      Paint()
        ..color = accent.withValues(alpha: 0.13)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawArc(
      bounds,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_AvatarRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.accent != accent;
}
