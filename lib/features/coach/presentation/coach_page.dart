import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_reveal.dart';
import '../../../shared/widgets/ui_components.dart';

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
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('LIVO Coach'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Column(
                children: [
                  AnimatedReveal(child: _CoachOrb(animation: _controller)),
                  const SizedBox(height: 26),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 70),
                    child: Text(
                      'Eine Frage. Dein ganzer Tag im Blick.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const AnimatedReveal(
                    delay: Duration(milliseconds: 120),
                    child: Text(
                      'Der Coach berücksichtigt später deine Ziele, Mahlzeiten, Vorlieben und Vorräte. Die echte KI ist noch nicht verbunden.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 27),
                  const AnimatedReveal(
                    delay: Duration(milliseconds: 180),
                    child: _ConversationPreview(),
                  ),
                  const SizedBox(height: 14),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 240),
                    child: _DisabledComposer(onTap: _showUnavailable),
                  ),
                  const SizedBox(height: 20),
                  const AnimatedReveal(
                    delay: Duration(milliseconds: 300),
                    child: _SafetyNote(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Die sichere KI-Anbindung kommt später. Das Design ist bereits vorbereitet.',
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
      builder: (context, _) {
        final wave = math.sin(animation.value * math.pi * 2);
        return Container(
          width: 126,
          height: 126,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.mint],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: 0.16 + (wave + 1) * 0.05,
                ),
                blurRadius: 34 + wave * 7,
                spreadRadius: 6 + wave * 2,
              ),
            ],
          ),
          child: Transform.rotate(
            angle: wave * 0.04,
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.black,
              size: 42,
            ),
          ),
        );
      },
    );
  }
}

class _ConversationPreview extends StatelessWidget {
  const _ConversationPreview();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: _ChatBubble(
              text: 'Was könnte ich heute Abend noch essen?',
              fromUser: true,
            ),
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: _ChatBubble(
              text:
                  'Dir fehlen in der Demo noch Protein und Gemüse. Eine Gemüse-Pasta mit Skyr-Dip würde gut passen. Mengen und Nährwerte prüfst du vor dem Speichern.',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: const [
              StatusPill(label: 'REZEPT ANSEHEN'),
              StatusPill(label: 'ALTERNATIVE'),
              StatusPill(label: 'EINKAUFSLISTE'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, this.fromUser = false});
  final String text;
  final bool fromUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 560),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: fromUser ? AppColors.primary : AppColors.surfaceHigh,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(fromUser ? 18 : 5),
          bottomRight: Radius.circular(fromUser ? 5 : 18),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fromUser ? AppColors.black : AppColors.text,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}

class _DisabledComposer extends StatelessWidget {
  const _DisabledComposer({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Frag deinen Coach …',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: AppColors.black,
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
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mint.withValues(alpha: 0.16)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: AppColors.mint, size: 21),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Lifestyle-Unterstützung statt medizinischer Beratung. Kritische Themen werden später technisch begrenzt.',
              style: TextStyle(
                color: AppColors.textMuted,
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
