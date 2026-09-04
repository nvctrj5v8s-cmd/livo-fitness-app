import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_reveal.dart';
import '../../../shared/widgets/feature_badge.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

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
                  'Ernährung',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: 8),
              const AnimatedReveal(
                delay: Duration(milliseconds: 60),
                child: Text(
                  'Einfach erfassen. Klar verstehen. Besser entscheiden.',
                ),
              ),
              const SizedBox(height: 24),
              const AnimatedReveal(
                delay: Duration(milliseconds: 110),
                child: _WeekPicker(),
              ),
              const SizedBox(height: 18),
              const AnimatedReveal(
                delay: Duration(milliseconds: 170),
                child: _QuickCapture(),
              ),
              const SizedBox(height: 28),
              const AnimatedReveal(
                delay: Duration(milliseconds: 230),
                child: _DailySummary(),
              ),
              const SizedBox(height: 28),
              const AnimatedReveal(
                delay: Duration(milliseconds: 290),
                child: _MealSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekPicker extends StatelessWidget {
  const _WeekPicker();

  @override
  Widget build(BuildContext context) {
    const days = [
      ('Mo', '01'),
      ('Di', '02'),
      ('Mi', '03'),
      ('Do', '04'),
      ('Fr', '05'),
      ('Sa', '06'),
      ('So', '07'),
    ];
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final selected = index == 3;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 58,
            decoration: BoxDecoration(
              color: selected ? AppColors.forest : AppColors.white,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: selected ? AppColors.forest : AppColors.line,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  days[index].$1,
                  style: TextStyle(
                    color: selected ? AppColors.mint : AppColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  days[index].$2,
                  style: TextStyle(
                    color: selected ? AppColors.white : AppColors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuickCapture extends StatelessWidget {
  const _QuickCapture();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Wie möchtest du eintragen?',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
              ),
              FeatureBadge(label: 'KI BALD'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CaptureButton(
                  icon: Icons.edit_note_rounded,
                  label: 'Manuell',
                  active: true,
                  onTap: () => _soon(context, false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CaptureButton(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Mit Text',
                  onTap: () => _soon(context, true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CaptureButton(
                  icon: Icons.photo_camera_outlined,
                  label: 'Foto',
                  onTap: () => _soon(context, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _soon(BuildContext context, bool ai) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ai
              ? 'Diese KI-Funktion wird später sicher angebunden.'
              : 'Die manuelle Eingabe bauen wir als erste echte Funktion.',
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.forest : AppColors.cream,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: active ? AppColors.lime : AppColors.forest),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: active ? AppColors.white : AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailySummary extends StatelessWidget {
  const _DailySummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _SummaryValue(value: '680', label: 'gegessen'),
          ),
          _Divider(),
          Expanded(
            child: _SummaryValue(value: '2.100', label: 'Tagesziel'),
          ),
          _Divider(),
          Expanded(
            child: _SummaryValue(value: '1.420', label: 'übrig'),
          ),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 34,
    color: AppColors.ink.withValues(alpha: 0.1),
  );
}

class _MealSection extends StatelessWidget {
  const _MealSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Heute', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 13),
        const _MealTile(
          icon: Icons.wb_sunny_outlined,
          color: AppColors.lime,
          title: 'Frühstück',
          subtitle: 'Haferflocken, Beeren, Joghurt',
          calories: '420 kcal',
        ),
        const SizedBox(height: 10),
        const _MealTile(
          icon: Icons.lunch_dining_outlined,
          color: AppColors.peach,
          title: 'Mittagessen',
          subtitle: 'Noch nichts eingetragen',
          calories: '＋',
        ),
        const SizedBox(height: 10),
        const _MealTile(
          icon: Icons.nights_stay_outlined,
          color: AppColors.lilac,
          title: 'Abendessen',
          subtitle: 'Noch nichts eingetragen',
          calories: '＋',
        ),
      ],
    );
  }
}

class _MealTile extends StatelessWidget {
  const _MealTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.calories,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String calories;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
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
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Text(
              calories,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.forest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
