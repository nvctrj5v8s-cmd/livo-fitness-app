import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_reveal.dart';
import '../../../shared/widgets/feature_badge.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _waterGlasses = 4;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AnimatedReveal(child: _TopBar()),
                const SizedBox(height: 24),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 60),
                  child: _Greeting(),
                ),
                const SizedBox(height: 20),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 120),
                  child: _NutritionHero(),
                ),
                const SizedBox(height: 28),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 190),
                  child: _SectionHeading(
                    eyebrow: 'SCHNELLZUGRIFF',
                    title: 'Alles an einem Ort',
                  ),
                ),
                const SizedBox(height: 14),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 240),
                  child: _ToolGrid(
                    waterGlasses: _waterGlasses,
                    onAddWater: () => setState(
                      () => _waterGlasses = math.min(8, _waterGlasses + 1),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 310),
                  child: _SectionHeading(
                    eyebrow: 'HEUTE',
                    title: 'Dein Essensplan',
                    action: 'Alle ansehen',
                  ),
                ),
                const SizedBox(height: 14),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 360),
                  child: _MealTimeline(),
                ),
                const SizedBox(height: 20),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 420),
                  child: _SmartInsight(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.darkForest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.bubble_chart_rounded, color: AppColors.lime),
        ),
        const SizedBox(width: 10),
        const Text(
          'LIVO',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.2,
          ),
        ),
        const Spacer(),
        _TopAction(icon: Icons.notifications_none_rounded, onTap: () {}),
        const SizedBox(width: 9),
        _TopAction(icon: Icons.person_outline_rounded, onTap: () {}),
      ],
    );
  }
}

class _TopAction extends StatelessWidget {
  const _TopAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, size: 21),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const weekdays = [
      'MONTAG',
      'DIENSTAG',
      'MITTWOCH',
      'DONNERSTAG',
      'FREITAG',
      'SAMSTAG',
      'SONNTAG',
    ];
    const months = [
      'JANUAR',
      'FEBRUAR',
      'MÄRZ',
      'APRIL',
      'MAI',
      'JUNI',
      'JULI',
      'AUGUST',
      'SEPTEMBER',
      'OKTOBER',
      'NOVEMBER',
      'DEZEMBER',
    ];
    final dateLabel =
        '${weekdays[now.weekday - 1]}, ${now.day}. ${months[now.month - 1]}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateLabel,
          style: const TextStyle(
            color: AppColors.forest,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Guten Morgen 👋',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 5),
        const Text(
          'Heute zählt nicht perfekt – heute zählt, dass du dranbleibst.',
        ),
      ],
    );
  }
}

class _NutritionHero extends StatelessWidget {
  const _NutritionHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17493A), AppColors.darkForest],
        ),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkForest.withValues(alpha: 0.22),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -70,
            top: -70,
            child: _GlowBubble(size: 220, color: AppColors.mint),
          ),
          const Positioned(
            left: -60,
            bottom: -100,
            child: _GlowBubble(size: 190, color: AppColors.lime),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 720;
                final summary = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FeatureBadge(
                      label: 'DEIN TAGESZIEL · DEMO',
                      icon: Icons.bolt_rounded,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      '1.420',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        height: 0.95,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'kcal noch verfügbar',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.68),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MacroPill(
                          label: 'Protein',
                          value: '46 / 130 g',
                          color: AppColors.peach,
                        ),
                        _MacroPill(
                          label: 'Carbs',
                          value: '72 / 220 g',
                          color: AppColors.lime,
                        ),
                        _MacroPill(
                          label: 'Fett',
                          value: '24 / 70 g',
                          color: AppColors.lilac,
                        ),
                      ],
                    ),
                  ],
                );
                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      summary,
                      const SizedBox(height: 28),
                      const Center(child: _CalorieDial()),
                    ],
                  );
                }
                return SizedBox(
                  height: 275,
                  child: Row(
                    children: [
                      Expanded(child: summary),
                      const SizedBox(width: 30),
                      const _CalorieDial(size: 205),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            '$label  ',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.66),
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalorieDial extends StatelessWidget {
  const _CalorieDial({this.size = 175});
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 0.33),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutExpo,
      builder: (context, value, _) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _DialPainter(value),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.lime,
                size: 26,
              ),
              SizedBox(height: 5),
              Text(
                '680',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'von 2.100 kcal',
                style: TextStyle(color: AppColors.mint, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  const _DialPainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = (Offset.zero & size).deflate(9);
    canvas.drawArc(
      bounds,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );
    canvas.drawArc(
      bounds,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      Paint()
        ..color = AppColors.lime
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_DialPainter oldDelegate) => value != oldDelegate.value;
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    this.action,
  });
  final String eyebrow;
  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  color: AppColors.coral,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        if (action != null)
          Text(
            action!,
            style: const TextStyle(
              color: AppColors.forest,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class _ToolGrid extends StatelessWidget {
  const _ToolGrid({required this.waterGlasses, required this.onAddWater});
  final int waterGlasses;
  final VoidCallback onAddWater;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            _ToolCard(
              width: width,
              icon: Icons.water_drop_outlined,
              color: AppColors.sky,
              title: 'Wasser',
              value: '$waterGlasses von 8 Gläsern',
              action: '+ 1 Glas',
              onTap: onAddWater,
            ),
            _ToolCard(
              width: width,
              icon: Icons.calendar_month_outlined,
              color: AppColors.lime,
              title: 'Wochenplan',
              value: '7 Tage im Blick',
              action: 'Plan öffnen',
              onTap: () => _preview(context, 'Der Wochenplan ist vorbereitet.'),
            ),
            _ToolCard(
              width: width,
              icon: Icons.shopping_bag_outlined,
              color: AppColors.peach,
              title: 'Einkaufsliste',
              value: '12 offene Artikel',
              action: 'Liste öffnen',
              onTap: () => _preview(
                context,
                'Die Einkaufsliste folgt mit dem Wochenplan.',
              ),
            ),
            _ToolCard(
              width: width,
              icon: Icons.kitchen_outlined,
              color: AppColors.lilac,
              title: 'Meine Vorräte',
              value: 'Rezepte daraus finden',
              action: 'Vorrat öffnen',
              onTap: () => _preview(
                context,
                'Der Vorratsbereich wird später mit Rezepten verbunden.',
              ),
            ),
          ],
        );
      },
    );
  }

  void _preview(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.width,
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.action,
    required this.onTap,
  });
  final double width;
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: width,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    action,
                    style: const TextStyle(
                      color: AppColors.forest,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
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

class _MealTimeline extends StatelessWidget {
  const _MealTimeline();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: const [
          _MealCard(
            time: '08:15',
            title: 'Beeren-Bowl',
            detail: '420 kcal · 26 g Protein',
            icon: Icons.breakfast_dining_rounded,
            color: AppColors.lilac,
            completed: true,
          ),
          SizedBox(width: 12),
          _MealCard(
            time: '13:00',
            title: 'Green Power Bowl',
            detail: '610 kcal · 38 g Protein',
            icon: Icons.rice_bowl_rounded,
            color: AppColors.lime,
          ),
          SizedBox(width: 12),
          _MealCard(
            time: '19:00',
            title: 'Ofengemüse & Feta',
            detail: '530 kcal · 31 g Protein',
            icon: Icons.dinner_dining_rounded,
            color: AppColors.peach,
          ),
          SizedBox(width: 12),
          _MealCard(
            time: 'Flexibel',
            title: 'Snack hinzufügen',
            detail: 'Noch 360 kcal geplant',
            icon: Icons.add_rounded,
            color: AppColors.sky,
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.time,
    required this.title,
    required this.detail,
    required this.icon,
    required this.color,
    this.completed = false,
  });
  final String time;
  final String title;
  final String detail;
  final IconData icon;
  final Color color;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.ink),
              ),
              const Spacer(),
              if (completed)
                const Icon(Icons.check_circle_rounded, color: AppColors.forest)
              else
                const Icon(Icons.more_horiz_rounded, color: AppColors.muted),
            ],
          ),
          const Spacer(),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.coral,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SmartInsight extends StatelessWidget {
  const _SmartInsight();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.lilac, Color(0xFFEAE7FF)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: AppColors.forest, size: 28),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeatureBadge(label: 'KI-EINBLICK · SPÄTER'),
                SizedBox(height: 13),
                Text(
                  'Dein Protein ist morgens noch etwas niedrig.',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  'Der spätere Coach könnte passende, einfache Ergänzungen aus deinen Vorlieben vorschlagen.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
