import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Number of animated scenes; one per introduction slide.
const introductionSceneCount = 6;

/// Decorative previews of real LIVO screens with illustrative values. The page
/// owns animation timing, replay and reduced motion; these scenes only draw
/// the supplied progress.
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
    final entry = _phase(position, 0, 0.45);
    final (badge, labelIcon, label) = switch (index) {
      0 => (
        Icons.menu_book_rounded,
        Icons.check_circle_outline_rounded,
        'Vier Mahlzeiten. Ein Überblick.',
      ),
      1 => (
        Icons.add_rounded,
        Icons.touch_app_outlined,
        'Foto, Barcode oder selbst eintragen',
      ),
      2 => (
        Icons.photo_camera_rounded,
        Icons.tune_rounded,
        'Schätzung prüfen, dann speichern',
      ),
      3 => (
        Icons.auto_awesome_rounded,
        Icons.chat_bubble_outline_rounded,
        'Nur Ernährung und Fitness',
      ),
      4 => (
        Icons.restaurant_menu_rounded,
        Icons.shopping_basket_outlined,
        'Wochenplan und Einkaufsliste',
      ),
      _ => (
        Icons.person_rounded,
        Icons.local_fire_department_outlined,
        'Richtwerte nur, wenn du möchtest',
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
                  offset: Offset(0, 22 * (1 - entry)),
                  child: Transform.rotate(
                    angle: -0.04 + 0.028 * entry,
                    child: _PreviewBoard(
                      accent: accent,
                      padded: index != 1,
                      child: switch (index) {
                        0 => _DiaryPreview(position, accent),
                        1 => _QuickAddPreview(position, accent),
                        2 => _PhotoPreview(position, accent),
                        3 => _CoachPreview(position, accent),
                        4 => _RecipesPreview(position, accent),
                        _ => _ProfilePreview(position, accent),
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: 6,
                  // The quick-add scene needs its navigation bar visible.
                  top: index == 1 ? 8 : null,
                  bottom: index == 1 ? null : 10,
                  child: _Enter(
                    progress: position,
                    start: 0.55,
                    end: 0.95,
                    child: Transform.rotate(
                      angle: -0.04,
                      child: _FloatingLabel(labelIcon, label, accent),
                    ),
                  ),
                ),
                Positioned(
                  top: 22,
                  right: 5,
                  child: _Enter(
                    progress: position,
                    start: 0.08,
                    end: 0.5,
                    distance: -20,
                    child: Transform.rotate(
                      angle: 0.09 - 0.09 * _phase(position, 0.08, 0.6),
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.mint],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.25),
                              blurRadius: 28,
                              offset: const Offset(0, 9),
                            ),
                          ],
                        ),
                        child: Icon(badge, color: AppColors.black, size: 28),
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

double _linear(double progress, double start, double end) =>
    ((progress - start) / (end - start)).clamp(0.0, 1.0);

String _thousands(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

class _Enter extends StatelessWidget {
  const _Enter({
    required this.progress,
    required this.start,
    required this.end,
    required this.child,
    this.distance = 16,
    this.horizontal = false,
  });

  final double progress;
  final double start;
  final double end;
  final double distance;
  final bool horizontal;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final value = _phase(progress, start, end);
    final shift = distance * (1 - value);
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: horizontal ? Offset(shift, 0) : Offset(0, shift),
        child: child,
      ),
    );
  }
}

class _PreviewBoard extends StatelessWidget {
  const _PreviewBoard({
    required this.child,
    required this.accent,
    this.padded = true,
  });
  final Widget child;
  final Color accent;
  final bool padded;

  @override
  Widget build(BuildContext context) => Container(
    width: 288,
    height: 326,
    clipBehavior: Clip.antiAlias,
    padding: padded ? const EdgeInsets.all(20) : EdgeInsets.zero,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(32),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(
            accent.withValues(alpha: 0.07),
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
            weight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: accent, size: 18),
      ],
    ),
  );
}

// ─── 1 · Tagebuch ──────────────────────────────────────────────────────────

class _DiaryPreview extends StatelessWidget {
  const _DiaryPreview(this.progress, this.accent);
  final double progress;
  final Color accent;

  static const _meals = [
    (Icons.free_breakfast_rounded, 'Frühstück', 420),
    (Icons.lunch_dining_rounded, 'Mittagessen', 610),
    (Icons.dinner_dining_rounded, 'Abendessen', 230),
    (Icons.cookie_rounded, 'Snacks', 0),
  ];

  @override
  Widget build(BuildContext context) {
    final ring = _phase(progress, 0.1, 0.8);
    final calories = (1260 * ring).round();
    return Column(
      children: [
        _PreviewTitle('DEIN TAG', Icons.wb_sunny_outlined, accent),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: Row(
            children: [
              SizedBox.square(
                dimension: 90,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: _CalorieRingPainter(ring * 0.6, accent, 8),
                    ),
                    Center(
                      child: SizedBox(
                        width: 60,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _FitText(
                              _thousands(calories),
                              size: 19,
                              weight: FontWeight.w900,
                              alignment: Alignment.center,
                            ),
                            const _FitText(
                              'von 2.100',
                              size: 8,
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
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MacroBar(
                      'Kohlenhydrate',
                      '${(145 * ring).round()} g',
                      0.58 * _phase(progress, 0.2, 0.85),
                      AppColors.blue,
                    ),
                    const SizedBox(height: 9),
                    _MacroBar(
                      'Protein',
                      '${(72 * ring).round()} g',
                      0.5 * _phase(progress, 0.27, 0.9),
                      AppColors.mint,
                    ),
                    const SizedBox(height: 9),
                    _MacroBar(
                      'Fett',
                      '${(42 * ring).round()} g',
                      0.6 * _phase(progress, 0.34, 0.95),
                      AppColors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < _meals.length; i++) ...[
          if (i > 0) const SizedBox(height: 5),
          _Enter(
            progress: progress,
            start: 0.18 + i * 0.1,
            end: 0.55 + i * 0.1,
            distance: 22,
            horizontal: true,
            child: _MealRow(
              icon: _meals[i].$1,
              label: _meals[i].$2,
              calories: _meals[i].$3,
              accent: accent,
            ),
          ),
        ],
      ],
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar(this.label, this.value, this.fill, this.color);
  final String label;
  final String value;
  final double fill;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _FitText(label, size: 8.5, color: AppColors.textMuted),
          ),
          SizedBox(
            width: 34,
            child: _FitText(
              value,
              size: 9,
              weight: FontWeight.w800,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: fill,
          minHeight: 4,
          color: color,
          backgroundColor: AppColors.surfaceSoft,
        ),
      ),
    ],
  );
}

class _MealRow extends StatelessWidget {
  const _MealRow({
    required this.icon,
    required this.label,
    required this.calories,
    required this.accent,
  });
  final IconData icon;
  final String label;
  final int calories;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final eaten = calories > 0;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: eaten ? accent.withValues(alpha: 0.14) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 13, color: accent),
          ),
          const SizedBox(width: 8),
          Expanded(child: _FitText(label, size: 10.5, weight: FontWeight.w700)),
          SizedBox(
            width: 52,
            child: _FitText(
              eaten ? '$calories kcal' : 'Noch leer',
              size: 9,
              color: eaten ? AppColors.text : AppColors.textMuted,
              alignment: Alignment.centerRight,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            eaten ? Icons.check_circle_rounded : Icons.add_circle_outline,
            size: 15,
            color: eaten ? accent : AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

// ─── 2 · Plus-Menü ─────────────────────────────────────────────────────────

class _QuickAddPreview extends StatelessWidget {
  const _QuickAddPreview(this.progress, this.accent);
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final press = _linear(progress, 0.08, 0.3);
    final pressScale = 1 - 0.14 * math.sin(press * math.pi);
    final ripple = _linear(progress, 0.12, 0.42);
    final sheet = _phase(progress, 0.26, 0.58);
    const options = [
      (Icons.photo_camera_rounded, 'KI-Foto', 'KI schätzt Lebensmittel'),
      (Icons.qr_code_scanner_rounded, 'Barcode scannen', 'Produkt finden'),
      (Icons.edit_note_rounded, 'Manuell eintragen', 'Suchen oder selbst'),
    ];
    return Stack(
      children: [
        // Dimmed diary behind the sheet.
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Opacity(
            opacity: 1 - 0.55 * sheet,
            child: Column(
              children: [
                _PreviewTitle('DEIN TAG', Icons.wb_sunny_outlined, accent),
                const SizedBox(height: 12),
                for (final label in ['Frühstück', 'Mittagessen', 'Abendessen'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _FitText(label, size: 10, weight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 52,
          child: Transform.translate(
            offset: Offset(0, 220 * (1 - sheet)),
            child: Opacity(
              opacity: sheet,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderBright),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.6),
                      blurRadius: 24,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.borderBright,
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _FitText(
                      'Mahlzeit hinzufügen',
                      size: 12.5,
                      weight: FontWeight.w900,
                    ),
                    const SizedBox(height: 8),
                    for (var i = 0; i < options.length; i++) ...[
                      if (i > 0) const SizedBox(height: 6),
                      _Enter(
                        progress: progress,
                        start: 0.42 + i * 0.1,
                        end: 0.72 + i * 0.1,
                        distance: 14,
                        child: _OptionTile(
                          icon: options[i].$1,
                          title: options[i].$2,
                          subtitle: options[i].$3,
                          accent: accent,
                          highlighted:
                              i == 0 && _linear(progress, 0.86, 0.96) > 0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.surfaceHigh,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                for (final (i, icon) in const [
                  Icons.menu_book_rounded,
                  Icons.auto_awesome_outlined,
                  null,
                  Icons.restaurant_menu_outlined,
                  Icons.person_outline_rounded,
                ].indexed)
                  Expanded(
                    child: icon == null
                        ? Center(
                            child: SizedBox.square(
                              dimension: 46,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (ripple > 0 && ripple < 1)
                                    Container(
                                      width: 34 + 24 * ripple,
                                      height: 34 + 24 * ripple,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: accent.withValues(
                                            alpha: 0.5 * (1 - ripple),
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  Transform.scale(
                                    scale: pressScale,
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.mint,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: accent.withValues(
                                              alpha: 0.35,
                                            ),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                      child: Transform.rotate(
                                        angle: math.pi / 4 * sheet,
                                        child: const Icon(
                                          Icons.add_rounded,
                                          color: AppColors.black,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Icon(
                            icon,
                            size: 19,
                            color: i == 0 ? accent : AppColors.textMuted,
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

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.highlighted,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: highlighted
          ? accent.withValues(alpha: 0.12)
          : AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: highlighted ? accent.withValues(alpha: 0.5) : AppColors.border,
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: accent),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FitText(title, size: 10, weight: FontWeight.w800),
              const SizedBox(height: 1),
              _FitText(subtitle, size: 7.5, color: AppColors.textMuted),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          size: 15,
          color: AppColors.textMuted,
        ),
      ],
    ),
  );
}

// ─── 3 · KI-Foto ───────────────────────────────────────────────────────────

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview(this.progress, this.accent);
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scan = _linear(progress, 0.06, 0.42);
    final grams = 150 + (30 * _phase(progress, 0.72, 0.92)).round();
    final kcal = (grams * 1.3).round();
    final pressingPlus =
        _linear(progress, 0.72, 0.8) > 0 && _linear(progress, 0.72, 0.8) < 1;
    return Column(
      children: [
        SizedBox(
          height: 124,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: _PlatePainter(accent)),
                if (scan > 0 && scan < 1)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 124 * scan - 14,
                    height: 28,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            accent.withValues(alpha: 0),
                            accent.withValues(alpha: 0.45),
                            accent.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: _Enter(
                    progress: progress,
                    start: 0.02,
                    end: 0.2,
                    distance: -8,
                    child: const _PhotoBadge('KI-Schätzung'),
                  ),
                ),
                for (final (i, (label, x, y)) in const [
                  ('Reis', 34.0, 70.0),
                  ('Lachs', 132.0, 42.0),
                  ('Salat', 150.0, 90.0),
                ].indexed)
                  Positioned(
                    left: x,
                    top: y,
                    child: Transform.scale(
                      scale: _phase(progress, 0.36 + i * 0.07, 0.56 + i * 0.07),
                      child: _DetectionChip(label, accent),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _Enter(
          progress: progress,
          start: 0.5,
          end: 0.72,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        'R',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        children: [
                          const _FitText(
                            'Reis',
                            size: 11.5,
                            weight: FontWeight.w800,
                          ),
                          const SizedBox(height: 2),
                          _FitText(
                            '$kcal kcal · K ${(grams * 0.28).round()} g · '
                            'P ${(grams * 0.027).round()} g',
                            size: 8,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.help_rounded,
                      size: 13,
                      color: AppColors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 34,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 6),
                      const Expanded(
                        child: _FitText(
                          'Menge',
                          size: 9,
                          color: AppColors.textMuted,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const _StepChip(Icons.remove_rounded, false),
                      SizedBox(
                        width: 58,
                        child: _FitText(
                          '$grams g',
                          size: 12,
                          weight: FontWeight.w900,
                          alignment: Alignment.center,
                        ),
                      ),
                      _StepChip(Icons.add_rounded, pressingPlus),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _Enter(
          progress: progress,
          start: 0.8,
          end: 1,
          child: Container(
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(11),
            ),
            child: _FitText(
              'Zu Mittagessen hinzufügen · ${kcal + 310} kcal',
              size: 9.5,
              weight: FontWeight.w800,
              color: AppColors.black,
              alignment: Alignment.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoBadge extends StatelessWidget {
  const _PhotoBadge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.black.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.auto_awesome_rounded,
          size: 10,
          color: AppColors.primary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _DetectionChip extends StatelessWidget {
  const _DetectionChip(this.label, this.accent);
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.black.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: accent.withValues(alpha: 0.7)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _StepChip extends StatelessWidget {
  const _StepChip(this.icon, this.pressed);
  final IconData icon;
  final bool pressed;

  @override
  Widget build(BuildContext context) => Transform.scale(
    scale: pressed ? 0.86 : 1,
    child: Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: pressed
            ? AppColors.primary.withValues(alpha: 0.25)
            : AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 15, color: AppColors.primary),
    ),
  );
}

class _PlatePainter extends CustomPainter {
  const _PlatePainter(this.accent);
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A221B), Color(0xFF15110E)],
        ).createShader(Offset.zero & size),
    );
    final center = Offset(size.width * 0.52, size.height * 0.55);
    canvas.drawCircle(
      center.translate(0, 5),
      66,
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );
    canvas.drawCircle(center, 64, Paint()..color = const Color(0xFFE9E6DF));
    canvas.drawCircle(center, 52, Paint()..color = const Color(0xFFF5F2EC));
    // Rice
    final rice = Paint()..color = const Color(0xFFF7F1DE);
    final riceShade = Paint()..color = const Color(0xFFE4DAC0);
    for (var i = 0; i < 26; i++) {
      final a = i * 0.9;
      final r = 6.0 + (i % 5) * 4.2;
      final p = center + Offset(-22 + math.cos(a) * r, 6 + math.sin(a) * r);
      canvas.drawOval(
        Rect.fromCenter(center: p, width: 7, height: 3.6),
        i.isEven ? rice : riceShade,
      );
    }
    // Salmon
    final salmon = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center + const Offset(18, -16),
        width: 40,
        height: 24,
      ),
      const Radius.circular(9),
    );
    canvas.drawRRect(salmon, Paint()..color = const Color(0xFFF08A5D));
    for (var i = 0; i < 4; i++) {
      final x = salmon.left + 8 + i * 8.0;
      canvas.drawLine(
        Offset(x, salmon.top + 4),
        Offset(x - 4, salmon.bottom - 4),
        Paint()
          ..color = const Color(0xFFFFC1A1)
          ..strokeWidth = 1.6,
      );
    }
    // Salad
    const greens = [Color(0xFF5DBB63), Color(0xFF7ED36F), Color(0xFF3F9A4A)];
    for (var i = 0; i < 9; i++) {
      final a = i * 0.8;
      final p = center + Offset(22 + math.cos(a) * 11, 22 + math.sin(a) * 8);
      canvas.drawOval(
        Rect.fromCenter(center: p, width: 13, height: 9),
        Paint()..color = greens[i % greens.length],
      );
    }
    canvas.drawCircle(
      center + const Offset(30, 18),
      4,
      Paint()..color = const Color(0xFFE5484D),
    );
    canvas.drawCircle(
      center + const Offset(14, 28),
      3.5,
      Paint()..color = const Color(0xFFE5484D),
    );
  }

  @override
  bool shouldRepaint(_PlatePainter oldDelegate) => oldDelegate.accent != accent;
}

// ─── 4 · Coach ─────────────────────────────────────────────────────────────

class _CoachPreview extends StatelessWidget {
  const _CoachPreview(this.progress, this.accent);
  final double progress;
  final Color accent;

  static const _answer =
      'Du hast heute noch etwa 650 kcal frei. Wie wäre eine '
      'Lachs-Tomaten-Bowl? Rund 35 g Protein.';

  @override
  Widget build(BuildContext context) {
    final typing = _linear(progress, 0.34, 0.54);
    final reveal = _linear(progress, 0.52, 0.92);
    final chars = (_answer.length * reveal).round();
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.mint],
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: AppColors.black,
              ),
            ),
            const SizedBox(width: 9),
            const Expanded(
              child: Column(
                children: [
                  _FitText('LIVO Coach', size: 12, weight: FontWeight.w900),
                  _FitText(
                    'KI · Ernährung & Fitness',
                    size: 8,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: _Enter(
            progress: progress,
            start: 0.1,
            end: 0.32,
            distance: 12,
            child: _Bubble(
              text: 'Was kann ich heute Abend noch essen?',
              mine: true,
              accent: accent,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: reveal == 0
              ? Opacity(
                  opacity: typing > 0 ? 1 : 0,
                  child: _TypingDots(typing, accent),
                )
              : _Bubble(
                  text: _answer.substring(0, chars),
                  mine: false,
                  accent: accent,
                  reserveLines: 4,
                ),
        ),
        const Spacer(),
        Row(
          children: [
            for (final (i, label) in const [
              'Mehr Protein',
              'Tagesziel',
              'Abendessen',
            ].indexed) ...[
              if (i > 0) const SizedBox(width: 5),
              Expanded(
                flex: i == 0 ? 5 : 4,
                child: _Enter(
                  progress: progress,
                  start: 0.84 + i * 0.04,
                  end: 0.96 + i * 0.01,
                  distance: 8,
                  child: Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: accent.withValues(alpha: 0.3)),
                    ),
                    child: _FitText(
                      label,
                      size: 8.5,
                      weight: FontWeight.w700,
                      color: accent,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        _Enter(
          progress: progress,
          start: 0.02,
          end: 0.3,
          child: Container(
            height: 34,
            padding: const EdgeInsets.only(left: 11, right: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: _FitText(
                    'Frag deinen Coach …',
                    size: 9.5,
                    color: AppColors.textMuted,
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    size: 15,
                    color: AppColors.black,
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

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.mine,
    required this.accent,
    this.reserveLines = 2,
  });
  final String text;
  final bool mine;
  final Color accent;
  final int reserveLines;

  @override
  Widget build(BuildContext context) => Container(
    width: 196,
    height: 12 + reserveLines * 13.5,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: mine ? accent : AppColors.surfaceHigh,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(14),
        topRight: const Radius.circular(14),
        bottomLeft: Radius.circular(mine ? 14 : 4),
        bottomRight: Radius.circular(mine ? 4 : 14),
      ),
      border: mine ? null : Border.all(color: AppColors.border),
    ),
    child: Text(
      text,
      maxLines: reserveLines,
      overflow: TextOverflow.clip,
      style: TextStyle(
        color: mine ? AppColors.black : AppColors.text,
        fontSize: 9.5,
        height: 1.4,
        fontWeight: mine ? FontWeight.w700 : FontWeight.w500,
      ),
    ),
  );
}

class _TypingDots extends StatelessWidget {
  const _TypingDots(this.value, this.accent);
  final double value;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    width: 54,
    height: 28,
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: Transform.translate(
              offset: Offset(
                0,
                -3 * math.max(0, math.sin((value * 3 - i * 0.25) * math.pi)),
              ),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

// ─── 5 · Rezepte & Planung ─────────────────────────────────────────────────

class _RecipesPreview extends StatelessWidget {
  const _RecipesPreview(this.progress, this.accent);
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final added = _linear(progress, 0.6, 0.66) >= 1;
    return Column(
      children: [
        _PreviewTitle('FÜR DICH', Icons.restaurant_menu_rounded, accent),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final (i, label) in const [
              'Schnell',
              'High Protein',
              'Vegetarisch',
            ].indexed) ...[
              if (i > 0) const SizedBox(width: 5),
              Expanded(
                flex: i == 1 ? 5 : 4,
                child: _Enter(
                  progress: progress,
                  start: 0.04 + i * 0.06,
                  end: 0.3 + i * 0.06,
                  distance: 8,
                  child: Container(
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: i == 1 ? accent : AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: i == 1 ? accent : AppColors.border,
                      ),
                    ),
                    child: _FitText(
                      label,
                      size: 8.5,
                      weight: FontWeight.w800,
                      alignment: Alignment.center,
                      color: i == 1 ? AppColors.black : AppColors.text,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        _Enter(
          progress: progress,
          start: 0.16,
          end: 0.48,
          child: Container(
            height: 124,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFF08A5D).withValues(alpha: 0.5),
                              AppColors.mint.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                      const Positioned(
                        right: 10,
                        top: 9,
                        child: Icon(
                          Icons.set_meal_rounded,
                          size: 30,
                          color: Color(0xCCFFFFFF),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text(
                            '20 Min.',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
                  child: Column(
                    children: [
                      const _FitText(
                        'Lachs-Avocado-Reis',
                        size: 11.5,
                        weight: FontWeight.w900,
                      ),
                      const SizedBox(height: 2),
                      const _FitText(
                        '560 kcal · 34 g Protein',
                        size: 8,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 7),
                      _DiaryButton(added: added, accent: accent),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _Enter(
                  progress: progress,
                  start: 0.62,
                  end: 0.86,
                  child: _MiniPlanCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Wochenplan',
                    items: const ['Mo · Oats', 'Di · Reis-Bowl'],
                    checked: _linear(progress, 0.8, 0.95),
                    accent: accent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Enter(
                  progress: progress,
                  start: 0.7,
                  end: 0.94,
                  child: _MiniPlanCard(
                    icon: Icons.shopping_basket_rounded,
                    title: 'Einkaufsliste',
                    items: const ['Lachs', 'Avocado'],
                    checked: _linear(progress, 0.86, 1),
                    accent: accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The "add to diary" button of a recipe card that flips to a confirmation.
class _DiaryButton extends StatelessWidget {
  const _DiaryButton({required this.added, required this.accent});
  final bool added;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    height: 24,
    decoration: BoxDecoration(
      color: added ? accent.withValues(alpha: 0.15) : accent,
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: accent),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          added ? Icons.check_rounded : Icons.add_rounded,
          size: 13,
          color: added ? accent : AppColors.black,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: _FitText(
            added ? 'Im Tagebuch' : 'Zum Tagebuch hinzufügen',
            size: 8.5,
            weight: FontWeight.w800,
            color: added ? accent : AppColors.black,
            alignment: Alignment.center,
          ),
        ),
      ],
    ),
  );
}

class _MiniPlanCard extends StatelessWidget {
  const _MiniPlanCard({
    required this.icon,
    required this.title,
    required this.items,
    required this.checked,
    required this.accent,
  });
  final IconData icon;
  final String title;
  final List<String> items;
  final double checked;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: accent),
            const SizedBox(width: 5),
            Expanded(child: _FitText(title, size: 9, weight: FontWeight.w800)),
          ],
        ),
        const Spacer(),
        for (final (i, item) in items.indexed) ...[
          if (i > 0) const SizedBox(height: 3),
          Row(
            children: [
              Icon(
                checked > (i + 1) / (items.length + 1)
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: 11,
                color: checked > (i + 1) / (items.length + 1)
                    ? accent
                    : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _FitText(item, size: 8, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

// ─── 6 · Profil ────────────────────────────────────────────────────────────

class _ProfilePreview extends StatelessWidget {
  const _ProfilePreview(this.progress, this.accent);
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final count = _phase(progress, 0.3, 0.8);
    final goals = _phase(progress, 0.6, 0.95);
    return Column(
      children: [
        Transform.scale(
          scale: 0.75 + 0.25 * _phase(progress, 0.02, 0.4),
          child: SizedBox.square(
            dimension: 60,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _AvatarRingPainter(
                      _phase(progress, 0.05, 0.55),
                      accent,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.text,
                      size: 30,
                    ),
                  ),
                ),
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 19,
                    height: 19,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 10,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        const _FitText(
          'Dein Profil',
          size: 14,
          weight: FontWeight.w900,
          alignment: Alignment.center,
        ),
        const SizedBox(height: 3),
        _Enter(
          progress: progress,
          start: 0.15,
          end: 0.4,
          distance: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flag_rounded, size: 11, color: accent),
              const SizedBox(width: 4),
              Text(
                'Muskeln aufbauen',
                style: TextStyle(
                  color: accent,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _Enter(
          progress: progress,
          start: 0.22,
          end: 0.5,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _Stat(
                  Icons.checklist_rounded,
                  AppColors.mint,
                  '${(4 * count).round()}',
                  'Einträge heute',
                ),
                const VerticalDivider(width: 1, color: AppColors.border),
                _Stat(
                  Icons.local_fire_department_rounded,
                  AppColors.orange,
                  '${(12 * count).round()}',
                  'Tage Serie',
                  glow: count >= 1,
                ),
                const VerticalDivider(width: 1, color: AppColors.border),
                _Stat(
                  Icons.restaurant_rounded,
                  accent,
                  _thousands((1480 * count).round()),
                  'kcal heute',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _Enter(
          progress: progress,
          start: 0.5,
          end: 0.72,
          child: const _FitText(
            'MEINE TÄGLICHEN ZIELE',
            size: 8.5,
            spacing: 1.2,
            weight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        _Enter(
          progress: progress,
          start: 0.55,
          end: 0.8,
          child: Row(
            children: [
              _GoalTile(
                AppColors.orange,
                _thousands((2330 * goals).round()),
                'kcal',
              ),
              const SizedBox(width: 6),
              _GoalTile(
                AppColors.mint,
                '${(144 * goals).round()} g',
                'Protein',
              ),
              const SizedBox(width: 6),
              _GoalTile(AppColors.blue, '${(78 * goals).round()} g', 'Fett'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(
    this.icon,
    this.color,
    this.value,
    this.label, {
    this.glow = false,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final bool glow;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: glow
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, size: 13, color: color),
        ),
        const SizedBox(height: 3),
        _FitText(
          value,
          size: 12,
          weight: FontWeight.w900,
          alignment: Alignment.center,
        ),
        _FitText(
          label,
          size: 7,
          color: AppColors.textMuted,
          alignment: Alignment.center,
        ),
      ],
    ),
  );
}

class _GoalTile extends StatelessWidget {
  const _GoalTile(this.color, this.value, this.label);
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FitText(value, size: 12, weight: FontWeight.w900),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _FitText(label, size: 7.5, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ─── Shared decoration ─────────────────────────────────────────────────────

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
      final angle = i * math.pi / 4 + 0.2 + 0.12 * _phase(progress, 0, 1);
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
  const _CalorieRingPainter(this.fraction, this.accent, this.stroke);
  final double fraction;
  final Color accent;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - stroke;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.surfaceSoft
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    final sweep = math.pi * 2 * fraction;
    if (sweep <= 0) return;
    canvas.drawArc(
      bounds,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + sweep,
          transform: const GradientRotation(-math.pi / 2),
          colors: [AppColors.mint, accent],
        ).createShader(bounds)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
    final endpoint =
        center +
        Offset(math.cos(sweep - math.pi / 2), math.sin(sweep - math.pi / 2)) *
            radius;
    canvas.drawCircle(
      endpoint,
      stroke,
      Paint()..color = accent.withValues(alpha: 0.15),
    );
    canvas.drawCircle(endpoint, 2.5, Paint()..color = AppColors.text);
  }

  @override
  bool shouldRepaint(_CalorieRingPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.accent != accent;
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
        ..strokeWidth = 2.5,
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
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_AvatarRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.accent != accent;
}
