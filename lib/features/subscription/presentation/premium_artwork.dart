import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

double _phase(double progress, double start, double end, [Curve? curve]) =>
    (curve ?? Curves.easeOutCubic).transform(
      ((progress - start) / (end - start)).clamp(0.0, 1.0),
    );

/// Decorative Premium emblem with the unlocked features orbiting it. The
/// paywall owns timing and reduced motion; this widget only draws [progress]
/// (0 = before entrance, 1 = settled, static end state).
class PremiumHeroArtwork extends StatelessWidget {
  const PremiumHeroArtwork({required this.progress, super.key});

  final double progress;

  static const _satellites = [
    (Icons.photo_camera_rounded, 'KI-Foto', Offset(-118, -52), AppColors.primary),
    (Icons.auto_awesome_rounded, 'Coach', Offset(120, -46), AppColors.mint),
    (Icons.restaurant_menu_rounded, 'Rezepte', Offset(-104, 60), AppColors.orange),
    (Icons.rocket_launch_rounded, 'Neues', Offset(110, 64), AppColors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    final emblem = _phase(p, 0, 0.42, Curves.easeOutBack);
    return ExcludeSemantics(
      child: MediaQuery.withNoTextScaling(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 360,
            height: 232,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: CustomPaint(painter: _HaloPainter(p))),
                for (final (i, (icon, label, offset, color))
                    in _satellites.indexed)
                  _Satellite(
                    icon: icon,
                    label: label,
                    offset: offset,
                    color: color,
                    value: _phase(p, 0.28 + i * 0.07, 0.62 + i * 0.07),
                  ),
                Opacity(
                  opacity: _phase(p, 0, 0.25),
                  child: Transform.rotate(
                    angle: -0.16 * (1 - emblem),
                    child: Transform.scale(
                      scale: 0.55 + 0.45 * emblem,
                      child: _Emblem(glow: _phase(p, 0.2, 0.7)),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _SparklePainter(p)),
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

class _Emblem extends StatelessWidget {
  const _Emblem({required this.glow});

  final double glow;

  @override
  Widget build(BuildContext context) => Container(
    width: 104,
    height: 104,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(34),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.mint],
      ),
      border: Border.all(color: AppColors.white.withValues(alpha: 0.3)),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.18 + 0.3 * glow),
          blurRadius: 30 + 26 * glow,
          spreadRadius: 1 + 3 * glow,
        ),
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.55),
          blurRadius: 26,
          offset: const Offset(0, 16),
        ),
      ],
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        // Soft gloss for a polished, physical feel.
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(33),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.center,
              colors: [
                AppColors.white.withValues(alpha: 0.42),
                AppColors.white.withValues(alpha: 0),
              ],
            ),
          ),
        ),
        const Center(
          child: Icon(
            Icons.workspace_premium_rounded,
            size: 56,
            color: AppColors.black,
          ),
        ),
      ],
    ),
  );
}

class _Satellite extends StatelessWidget {
  const _Satellite({
    required this.icon,
    required this.label,
    required this.offset,
    required this.color,
    required this.value,
  });

  final IconData icon;
  final String label;
  final Offset offset;
  final Color color;
  final double value;

  @override
  Widget build(BuildContext context) {
    // Travels out of the emblem to its final spot.
    final position = Offset.lerp(offset * 0.35, offset, value)!;
    return Transform.translate(
      offset: position,
      child: Opacity(
        opacity: value,
        child: Container(
          height: 34,
          padding: const EdgeInsets.fromLTRB(4, 4, 11, 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: color.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 14),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, size: 15, color: AppColors.black),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HaloPainter extends CustomPainter {
  const _HaloPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final appear = _phase(progress, 0, 0.5);

    canvas.drawCircle(
      center,
      150,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2 * appear),
            AppColors.mint.withValues(alpha: 0.06 * appear),
            AppColors.primary.withValues(alpha: 0),
          ],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: center, radius: 150)),
    );

    // Two tilted orbits settle into place once.
    final orbit = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.16 * appear)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(-0.2 + 0.14 * _phase(progress, 0, 1));
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 330, height: 176),
      orbit,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 262, height: 214),
      orbit..color = AppColors.mint.withValues(alpha: 0.12 * appear),
    );
    canvas.restore();

    for (var i = 0; i < 10; i++) {
      final angle = i * math.pi / 5 + 0.3 + 0.18 * _phase(progress, 0, 1);
      final point = center + Offset(math.cos(angle) * 165, math.sin(angle) * 88);
      canvas.drawCircle(
        point,
        i.isEven ? 2.4 : 1.4,
        Paint()
          ..color = AppColors.primary.withValues(
            alpha: (i.isEven ? 0.55 : 0.3) * _phase(progress, 0.2, 0.7),
          ),
      );
    }

    // Progress ring drawn around the emblem.
    final ring = _phase(progress, 0.12, 0.64);
    if (ring > 0) {
      final bounds = Rect.fromCircle(center: center, radius: 76);
      canvas.drawCircle(
        center,
        76,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.drawArc(
        bounds,
        -math.pi / 2,
        math.pi * 2 * ring,
        false,
        Paint()
          ..shader = const SweepGradient(
            colors: [AppColors.mint, AppColors.primary, AppColors.mint],
            transform: GradientRotation(-math.pi / 2),
          ).createShader(bounds)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(_HaloPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Four-point stars that twinkle once and then rest.
class _SparklePainter extends CustomPainter {
  const _SparklePainter(this.progress);

  final double progress;

  static const _stars = [
    (Offset(-66, -60), 11.0),
    (Offset(70, -64), 8.0),
    (Offset(86, 12), 10.0),
    (Offset(-82, 22), 7.0),
    (Offset(10, -96), 8.5),
    (Offset(-24, 88), 6.0),
    (Offset(40, 84), 7.5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (final (i, (offset, radius)) in _stars.indexed) {
      final start = 0.44 + i * 0.055;
      final t = ((progress - start) / 0.3).clamp(0.0, 1.0);
      if (t == 0) continue;
      final scale = t < 0.5
          ? 1.3 * Curves.easeOut.transform(t * 2)
          : 1.3 - 0.45 * Curves.easeInOut.transform((t - 0.5) * 2);
      final opacity = t < 0.5 ? t * 2 : 1 - 0.3 * ((t - 0.5) * 2);
      _star(
        canvas,
        center + offset,
        radius * scale,
        (i.isEven ? AppColors.primary : AppColors.white).withValues(
          alpha: opacity.clamp(0.0, 1.0),
        ),
      );
    }
  }

  void _star(Canvas canvas, Offset c, double r, Color color) {
    final inner = r * 0.22;
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + inner, c.dy - inner, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + inner, c.dy + inner, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - inner, c.dy + inner, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - inner, c.dy - inner, c.dx, c.dy - r)
      ..close();
    canvas.drawCircle(
      c,
      r * 0.9,
      Paint()
        ..color = color.withValues(alpha: color.a * 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
