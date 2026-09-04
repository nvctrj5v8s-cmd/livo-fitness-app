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
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            children: [
              const AnimatedReveal(child: FeatureBadge(label: 'KI-VORSCHAU')),
              const SizedBox(height: 26),
              AnimatedReveal(
                delay: const Duration(milliseconds: 80),
                child: _CoachOrb(animation: _controller),
              ),
              const SizedBox(height: 28),
              AnimatedReveal(
                delay: const Duration(milliseconds: 150),
                child: Text(
                  'Dein Coach, der dich\nwirklich versteht.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: 12),
              AnimatedReveal(
                delay: const Duration(milliseconds: 220),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: const Text(
                    'Hier entstehen später persönliche Essensideen, sanfte Motivation und verständliche Wochenberichte.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 34),
              const AnimatedReveal(
                delay: Duration(milliseconds: 300),
                child: _ExamplePrompts(),
              ),
              const SizedBox(height: 22),
              AnimatedReveal(
                delay: const Duration(milliseconds: 360),
                child: _DisabledComposer(onTap: _showPreviewMessage),
              ),
              const SizedBox(height: 18),
              const AnimatedReveal(
                delay: Duration(milliseconds: 420),
                child: _SafetyNote(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPreviewMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Der KI-Chat ist nur als Design-Vorschau sichtbar und noch nicht verbunden.',
        ),
      ),
    );
  }
}

class _CoachOrb extends StatelessWidget {
  const _CoachOrb({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = 0.96 + animation.value * 0.06;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.lime, AppColors.mint, AppColors.lilac],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mint.withValues(
                    alpha: 0.25 + animation.value * 0.18,
                  ),
                  blurRadius: 30 + animation.value * 20,
                  spreadRadius: animation.value * 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 42,
              color: AppColors.forest,
            ),
          ),
        );
      },
    );
  }
}

class _ExamplePrompts extends StatelessWidget {
  const _ExamplePrompts();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 9,
      runSpacing: 9,
      children: const [
        _PromptChip('Was passt heute noch?'),
        _PromptChip('Proteinreiche Idee'),
        _PromptChip('Meine Woche erklären'),
      ],
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DisabledComposer extends StatelessWidget {
  const _DisabledComposer({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.forest,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: AppColors.lime,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lime.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: AppColors.forest, size: 21),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Die spätere KI unterstützt allgemeine Fitnessziele. Sie ersetzt keine medizinische Beratung und wird durch feste Sicherheitsregeln begrenzt.',
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: AppColors.forest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
