import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/personalization_profile.dart';

/// Code-native decorative scenes driven by the user's current choices.
/// Every animation finishes; reduced motion renders its final frame directly.
class PersonalizationArtwork extends StatelessWidget {
  const PersonalizationArtwork({
    required this.step,
    required this.profile,
    required this.compact,
    super.key,
  });

  final int step;
  final PersonalizationProfile profile;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final selection = switch (step) {
      1 => profile.goal?.index ?? -1,
      2 => profile.activity?.index ?? -1,
      3 => profile.nutrition?.index ?? -1,
      4 => profile.cookingMinutes ?? 0,
      _ => 0,
    };
    final caption = switch (step) {
      0 =>
        profile.displayName.trim().isEmpty
            ? 'Platz für dich.'
            : 'Hallo, ${profile.displayName.trim()}.',
      1 => profile.goal?.label ?? 'Du bestimmst die Richtung.',
      2 => profile.activity?.label ?? 'Jeder Alltag ist anders.',
      3 => profile.nutrition?.label ?? 'Was dir guttut, zählt.',
      4 =>
        profile.cookingMinutes == null
            ? profile.routineLabel
            : '${profile.routineLabel} · bis ${profile.cookingMinutes} Min.',
      _ => 'Deine Wünsche auf einen Blick.',
    };
    final token = (
      step,
      selection,
      profile.displayName,
      profile.usualMeals,
      profile.desiredMeals,
      profile.allergies,
      reduced,
    );
    return ExcludeSemantics(
      child: SizedBox(
        height: compact ? 164 : 332,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 360,
            height: 236,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.alphaBlend(
                      AppColors.primary.withValues(alpha: 0.045),
                      AppColors.surfaceHigh,
                    ),
                    AppColors.surface,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.025),
                    blurRadius: 44,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'DEINE AUSWAHL',
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 9,
                            letterSpacing: 1.8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${step + 1}'.padLeft(2, '0'),
                          textScaler: TextScaler.noScaling,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(token),
                        tween: Tween(begin: reduced ? 1 : 0, end: 1),
                        duration: reduced
                            ? Duration.zero
                            : const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, progress, _) => CustomPaint(
                          size: const Size(double.infinity, double.infinity),
                          painter: _PreferenceScene(
                            step: step,
                            progress: progress,
                            selection: selection,
                            usualMeals: profile.usualMeals,
                            desiredMeals: profile.desiredMeals,
                            fontFamily: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.fontFamily,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          caption,
                          textScaler: TextScaler.noScaling,
                          maxLines: 1,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreferenceScene extends CustomPainter {
  const _PreferenceScene({
    required this.step,
    required this.progress,
    required this.selection,
    required this.usualMeals,
    required this.desiredMeals,
    required this.fontFamily,
  });

  final int step;
  final double progress;
  final int selection;
  final int? usualMeals;
  final int? desiredMeals;
  final String? fontFamily;

  Paint _fill(Color color) => Paint()..color = color;
  Paint _stroke(Color color, [double width = 1.5]) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 312, size.height / 132);
    const center = Offset(156, 65);
    canvas.drawCircle(
      center,
      64,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 64)),
    );
    switch (step) {
      case 0:
        _avatar(canvas);
      case 1:
        _direction(canvas);
      case 2:
        _activity(canvas);
      case 3:
        _nutrition(canvas);
      case 4:
        _routine(canvas);
      default:
        _review(canvas);
    }
    canvas.restore();
  }

  void _icon(
    Canvas canvas,
    IconData icon,
    Offset center,
    double size,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: size,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  void _badge(
    Canvas canvas,
    Offset center,
    IconData icon, {
    bool selected = false,
    double scale = 1,
  }) {
    final rect = Rect.fromCenter(
      center: center,
      width: 46 * scale,
      height: 46 * scale,
    );
    final rounded = RRect.fromRectAndRadius(rect, Radius.circular(15 * scale));
    canvas.drawRRect(
      rounded,
      _fill(selected ? AppColors.primary : AppColors.surfaceSoft),
    );
    if (!selected) canvas.drawRRect(rounded, _stroke(AppColors.borderBright));
    _icon(
      canvas,
      icon,
      center,
      23 * scale,
      selected ? AppColors.black : AppColors.textMuted,
    );
  }

  void _avatar(Canvas canvas) {
    const center = Offset(156, 65);
    canvas.drawCircle(center, 47, _stroke(AppColors.border));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 47),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      _stroke(AppColors.primary, 2.5),
    );
    canvas.drawCircle(
      center,
      36,
      _fill(AppColors.primary.withValues(alpha: 0.1)),
    );
    _icon(canvas, Icons.person_outline_rounded, center, 44, AppColors.primary);
    _badge(
      canvas,
      Offset(58 + 7 * progress, 48),
      Icons.favorite_border_rounded,
      scale: 0.72,
    );
    _badge(
      canvas,
      Offset(254 - 7 * progress, 84),
      Icons.tune_rounded,
      scale: 0.72,
    );
    _dottedLine(canvas, const Offset(86, 51), const Offset(105, 58));
    _dottedLine(canvas, const Offset(207, 75), const Offset(227, 80));
  }

  void _direction(Canvas canvas) {
    const icons = [
      Icons.spa_outlined,
      Icons.flag_outlined,
      Icons.balance_rounded,
      Icons.fitness_center_rounded,
    ];
    const center = Offset(156, 65);
    canvas.drawCircle(center, 45, _stroke(AppColors.border));
    canvas.drawCircle(
      center,
      55,
      _stroke(AppColors.primary.withValues(alpha: 0.11)),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 45),
      -math.pi / 2,
      math.pi * 1.5 * progress,
      false,
      _stroke(AppColors.primary, 2),
    );
    final icon = selection < 0 ? Icons.explore_outlined : icons[selection];
    _badge(canvas, center, icon, selected: selection >= 0, scale: 1.35);
    for (var index = 0; index < 4; index++) {
      final angle = math.pi * (index / 2) - math.pi / 4;
      final location =
          center + Offset(math.cos(angle) * 104, math.sin(angle) * 62);
      canvas.drawCircle(
        location,
        selection == index ? 5 : 3,
        _fill(selection == index ? AppColors.primary : AppColors.borderBright),
      );
    }
  }

  void _activity(Canvas canvas) {
    const icons = [
      Icons.chair_alt_outlined,
      Icons.swap_horiz_rounded,
      Icons.directions_walk_rounded,
      Icons.directions_run_rounded,
    ];
    final path = Path()
      ..moveTo(34, 83)
      ..cubicTo(102, 83, 100, 49, 171, 49)
      ..cubicTo(212, 49, 241, 34, 278, 34);
    canvas.drawPath(path, _stroke(AppColors.border, 3));
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress),
      _stroke(AppColors.primary.withValues(alpha: 0.4), 3),
    );
    for (var i = 0; i < 4; i++) {
      final x = 40.0 + i * 77;
      final y = 89.0 - i * 17;
      _badge(
        canvas,
        Offset(x, y),
        icons[i],
        selected: selection == i,
        scale: selection == i ? 1.05 : 0.83,
      );
    }
    for (var i = 0; i < 6; i++) {
      canvas.drawCircle(
        Offset(119 + i * 12, 111),
        1.5,
        _fill(AppColors.borderBright),
      );
    }
  }

  void _nutrition(Canvas canvas) {
    const center = Offset(156, 64);
    canvas.drawCircle(
      center + const Offset(0, 4),
      54,
      _fill(AppColors.black.withValues(alpha: 0.4)),
    );
    canvas.drawCircle(center, 53, _fill(AppColors.surfaceSoft));
    canvas.drawCircle(center, 53, _stroke(AppColors.borderBright, 2));
    canvas.drawCircle(
      center,
      43,
      _stroke(AppColors.primary.withValues(alpha: 0.2)),
    );
    const icons = [
      Icons.restaurant_rounded,
      Icons.eco_outlined,
      Icons.spa_outlined,
      Icons.set_meal_outlined,
    ];
    _icon(
      canvas,
      selection < 0 ? Icons.restaurant_menu_rounded : icons[selection],
      center,
      43 * (0.8 + 0.2 * progress),
      AppColors.primary,
    );
    for (var i = 0; i < 3; i++) {
      final position = Offset(72 + i * 4.0, 46 + i * 18.0);
      final leaf = Path()
        ..moveTo(position.dx, position.dy)
        ..quadraticBezierTo(
          position.dx - 17,
          position.dy - 18,
          position.dx + 7,
          position.dy - 21,
        )
        ..quadraticBezierTo(
          position.dx + 14,
          position.dy - 6,
          position.dx,
          position.dy,
        );
      canvas.drawPath(
        leaf,
        _fill(AppColors.primary.withValues(alpha: 0.2 + 0.2 * progress)),
      );
    }
    canvas.drawLine(
      const Offset(237, 26),
      const Offset(237, 105),
      _stroke(AppColors.textMuted, 2),
    );
    canvas.drawLine(
      const Offset(231, 26),
      const Offset(231, 44),
      _stroke(AppColors.textMuted, 2),
    );
    canvas.drawLine(
      const Offset(243, 26),
      const Offset(243, 44),
      _stroke(AppColors.textMuted, 2),
    );
    canvas.drawArc(
      const Rect.fromLTWH(231, 35, 12, 16),
      0,
      math.pi,
      false,
      _stroke(AppColors.textMuted, 2),
    );
  }

  void _routine(Canvas canvas) {
    final count = desiredMeals ?? 3;
    final startX = 156 - ((count - 1) * 22);
    for (var i = 0; i < count; i++) {
      final appear = (progress * 1.35 - i * 0.1).clamp(0.0, 1.0);
      final center = Offset(startX + i * 44, 69);
      canvas.drawCircle(
        center,
        17 * (0.78 + 0.22 * appear),
        _fill(AppColors.surfaceSoft),
      );
      canvas.drawCircle(
        center,
        17,
        _stroke(AppColors.primary.withValues(alpha: 0.25 + 0.55 * appear)),
      );
      canvas.drawCircle(
        center,
        10,
        _stroke(AppColors.primary.withValues(alpha: 0.18)),
      );
    }
    _badge(
      canvas,
      const Offset(63, 31),
      Icons.schedule_rounded,
      selected: selection > 0,
      scale: 0.75,
    );
    _badge(
      canvas,
      const Offset(252, 103),
      desiredMeals == null
          ? Icons.all_inclusive_rounded
          : Icons.restaurant_rounded,
      selected: desiredMeals != null,
      scale: 0.75,
    );
    _dottedLine(canvas, const Offset(86, 39), const Offset(116, 53));
    _dottedLine(canvas, const Offset(205, 84), const Offset(229, 96));
  }

  void _review(Canvas canvas) {
    final card = RRect.fromRectAndRadius(
      const Rect.fromLTWH(72, 5, 169, 119),
      const Radius.circular(19),
    );
    canvas.drawRRect(card, _fill(AppColors.surfaceHigh));
    canvas.drawRRect(card, _stroke(AppColors.borderBright));
    const rowIcons = [
      Icons.person_outline_rounded,
      Icons.restaurant_rounded,
      Icons.tune_rounded,
    ];
    for (var i = 0; i < 3; i++) {
      final y = 29.0 + i * 35;
      _icon(canvas, rowIcons[i], Offset(93, y), 17, AppColors.textMuted);
      canvas.drawLine(
        Offset(113, y - 4),
        Offset(162 + i * 9.0, y - 4),
        _stroke(AppColors.borderBright, 4),
      );
      canvas.drawLine(
        Offset(113, y + 5),
        Offset(146 + i * 7.0, y + 5),
        _stroke(AppColors.border, 3),
      );
      final phase = (progress * 1.6 - i * 0.22).clamp(0.0, 1.0);
      if (phase > 0) {
        _icon(
          canvas,
          Icons.check_rounded,
          Offset(218, y),
          16 * phase,
          AppColors.primary,
        );
      }
    }
    _badge(
      canvas,
      const Offset(250, 25),
      Icons.check_rounded,
      selected: true,
      scale: 0.8 + 0.15 * progress,
    );
  }

  void _dottedLine(Canvas canvas, Offset from, Offset to) {
    for (var i = 0; i <= 4; i++) {
      canvas.drawCircle(
        Offset.lerp(from, to, i / 4)!,
        1.2,
        _fill(AppColors.borderBright),
      );
    }
  }

  @override
  bool shouldRepaint(_PreferenceScene oldDelegate) =>
      oldDelegate.fontFamily != fontFamily ||
      oldDelegate.step != step ||
      oldDelegate.progress != progress ||
      oldDelegate.selection != selection ||
      oldDelegate.usualMeals != usualMeals ||
      oldDelegate.desiredMeals != desiredMeals;
}
