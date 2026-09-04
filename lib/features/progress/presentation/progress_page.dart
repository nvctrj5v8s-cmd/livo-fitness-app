import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_reveal.dart';
import '../../../shared/widgets/feature_badge.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedReveal(
                child: Text(
                  'Fortschritt',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: 8),
              const AnimatedReveal(
                delay: Duration(milliseconds: 60),
                child: Text(
                  'Kleine Schritte werden sichtbar. Ohne Druck, ohne Perfektion.',
                ),
              ),
              const SizedBox(height: 26),
              const AnimatedReveal(
                delay: Duration(milliseconds: 130),
                child: _WeightCard(),
              ),
              const SizedBox(height: 14),
              const AnimatedReveal(
                delay: Duration(milliseconds: 200),
                child: _ConsistencyCard(),
              ),
              const SizedBox(height: 26),
              const AnimatedReveal(
                delay: Duration(milliseconds: 270),
                child: _InsightCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightCard extends StatelessWidget {
  const _WeightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Gewichtstrend',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const FeatureBadge(label: 'DEMO'),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '78,4',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 6, left: 5),
                child: Text('kg', style: TextStyle(color: AppColors.muted)),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  '− 1,2 kg',
                  style: TextStyle(
                    color: AppColors.forest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const SizedBox(
            height: 145,
            width: double.infinity,
            child: CustomPaint(painter: _ChartPainter()),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Woche 1'),
              Text('Woche 2'),
              Text('Woche 3'),
              Text('Heute'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  const _ChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final points = <Offset>[
      Offset(0, size.height * 0.2),
      Offset(size.width * 0.18, size.height * 0.34),
      Offset(size.width * 0.36, size.height * 0.3),
      Offset(size.width * 0.55, size.height * 0.56),
      Offset(size.width * 0.73, size.height * 0.62),
      Offset(size.width, size.height * 0.8),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final middle = (previous.dx + current.dx) / 2;
      path.cubicTo(
        middle,
        previous.dy,
        middle,
        current.dy,
        current.dx,
        current.dy,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.forest
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(points.last, 7, Paint()..color = AppColors.lime);
    canvas.drawCircle(points.last, 3, Paint()..color = AppColors.forest);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConsistencyCard extends StatelessWidget {
  const _ConsistencyCard();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = const [
          _StatCard(
            icon: Icons.local_fire_department_outlined,
            color: AppColors.peach,
            value: '6 Tage',
            label: 'Aktuelle Serie',
          ),
          _StatCard(
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.lime,
            value: '82 %',
            label: 'Ziele erreicht',
          ),
        ];
        if (constraints.maxWidth < 540) {
          return Column(
            children: [cards[0], const SizedBox(height: 12), cards[1]],
          );
        }
        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(icon, color: AppColors.ink),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.lilac, Color(0xFFE9E5FF)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FeatureBadge(label: 'KI-BERICHT – SPÄTER'),
          const SizedBox(height: 20),
          Text(
            'Deine Woche, verständlich erklärt',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Der Coach erkennt später vorsichtige Muster und gibt nachvollziehbare, allgemeine Hinweise statt medizinischer Bewertungen.',
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.lock_outline_rounded),
            label: const Text('Noch nicht aktiviert'),
          ),
        ],
      ),
    );
  }
}
