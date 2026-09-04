import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_reveal.dart';
import '../../../shared/widgets/feature_badge.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedReveal(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'LIVO Coach',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      const FeatureBadge(label: 'NOCH NICHT VERBUNDEN'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 50),
                  child: Text(
                    'Später dein persönlicher Begleiter für Essen, Planung und Gewohnheiten.',
                  ),
                ),
                const SizedBox(height: 22),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 110),
                  child: _CoachHero(animation: _controller),
                ),
                const SizedBox(height: 28),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 180),
                  child: _Heading('Was dein Coach können wird'),
                ),
                const SizedBox(height: 13),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 230),
                  child: _CapabilityGrid(),
                ),
                const SizedBox(height: 28),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 300),
                  child: _Heading('So könnte ein Gespräch aussehen'),
                ),
                const SizedBox(height: 13),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 350),
                  child: _ChatPreview(onTap: _showPreview),
                ),
                const SizedBox(height: 16),
                const AnimatedReveal(
                  delay: Duration(milliseconds: 410),
                  child: _SafetyCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPreview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Der Coach ist eine Design-Vorschau. Die sichere KI-Anbindung folgt später.',
        ),
      ),
    );
  }
}

class _CoachHero extends StatelessWidget {
  const _CoachHero({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF194C3D), AppColors.darkForest],
        ),
        borderRadius: BorderRadius.circular(34),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final angle = animation.value * math.pi * 2;
              return Positioned(
                right: -10 + math.cos(angle) * 18,
                top: -25 + math.sin(angle) * 13,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mint.withValues(alpha: 0.11),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 620;
                final copy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'DEIN PERSÖNLICHER COACH',
                      style: TextStyle(
                        color: AppColors.mint,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 13),
                    const Text(
                      'Eine Antwort, die deinen\nganzen Tag berücksichtigt.',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 27,
                        height: 1.08,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ziele, bisherige Mahlzeiten, Vorlieben und Vorräte – ohne jedes Mal alles neu erklären zu müssen.',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.66),
                        height: 1.45,
                      ),
                    ),
                  ],
                );
                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      copy,
                      const SizedBox(height: 25),
                      Center(child: _CoachOrb(animation: animation)),
                    ],
                  );
                }
                return SizedBox(
                  height: 250,
                  child: Row(
                    children: [
                      Expanded(child: copy),
                      const SizedBox(width: 30),
                      _CoachOrb(animation: animation, size: 145),
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

class _CoachOrb extends StatelessWidget {
  const _CoachOrb({required this.animation, this.size = 125});
  final Animation<double> animation;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final pulse = 0.96 + math.sin(animation.value * math.pi * 2) * 0.035;
        return Transform.scale(
          scale: pulse,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.lime, AppColors.mint, AppColors.lilac],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.lime.withValues(alpha: 0.2),
                  blurRadius: 35,
                  spreadRadius: 7,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.darkForest,
              size: 42,
            ),
          ),
        );
      },
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.titleLarge);
}

class _CapabilityGrid extends StatelessWidget {
  const _CapabilityGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760
            ? 4
            : constraints.maxWidth >= 480
            ? 2
            : 1;
        const gap = 11.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        const items = [
          (
            Icons.restaurant_rounded,
            'Tageshilfe',
            'Was passt noch in dein Ziel?',
            AppColors.lime,
          ),
          (
            Icons.swap_horiz_rounded,
            'Alternativen',
            'Einfach Zutaten austauschen',
            AppColors.sky,
          ),
          (
            Icons.calendar_month_rounded,
            'Planung',
            'Woche und Einkauf vorbereiten',
            AppColors.peach,
          ),
          (
            Icons.insights_rounded,
            'Erklärung',
            'Fortschritt verständlich machen',
            AppColors.lilac,
          ),
        ];
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items
              .map(
                (item) => Container(
                  width: width,
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(23),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: item.$4,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(item.$1, color: AppColors.ink, size: 21),
                      ),
                      const SizedBox(height: 13),
                      Text(
                        item.$2,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$3,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ChatPreview extends StatelessWidget {
  const _ChatPreview({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: _Bubble(
              text: 'Was kann ich heute Abend essen, damit mein Protein passt?',
              user: true,
            ),
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: _Bubble(
              text:
                  'Dir fehlen laut Demo noch etwa 45 g Protein. Eine Bowl mit Hähnchen oder Tofu, Gemüse und Joghurt-Dip würde gut passen. Mengen und Nährwerte würdest du vor dem Speichern bestätigen.',
            ),
          ),
          const SizedBox(height: 17),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(19),
            child: Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(19),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Frag deinen Coach …',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.forest,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: AppColors.lime,
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

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, this.user = false});
  final String text;
  final bool user;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 590),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: user ? AppColors.forest : AppColors.lilac.withValues(alpha: 0.6),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(user ? 18 : 5),
          bottomRight: Radius.circular(user ? 5 : 18),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: user ? AppColors.white : AppColors.ink,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.lime.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: AppColors.forest, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Lifestyle-Unterstützung statt medizinischer Beratung. Unsichere Bereiche werden später technisch blockiert und Nährwerte müssen bestätigt werden.',
              style: TextStyle(
                color: AppColors.forest,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
