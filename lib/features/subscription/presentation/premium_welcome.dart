import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/l10n.dart';

/// What the welcome screen celebrates.
enum PremiumWelcomeKind { trial, purchase }

/// Full-screen "Welcome to Lookin Premium" after a purchase or the start of
/// the free trial.
///
/// One finite sequence (about four seconds): a glow blooms, light rays turn
/// behind the Lookin mark while its ring draws itself and the dot pops in,
/// confetti shoots from both lower corners, the PREMIUM badge shines once,
/// the title and the feature cards slide in one after another and the button
/// shimmers twice. Afterwards everything stands still; tapping the mark
/// throws confetti again. With "reduce motion" the final state is shown at
/// once and no confetti is drawn.
class PremiumWelcomeView extends StatefulWidget {
  const PremiumWelcomeView({
    required this.kind,
    required this.statusLine,
    required this.onContinue,
    this.detailLine,
    this.planChip,
    super.key,
  });

  final PremiumWelcomeKind kind;

  /// First line under the title, e.g. the thank-you or the trial end.
  final String statusLine;

  /// Optional second line, e.g. the next renewal date.
  final String? detailLine;

  /// Optional chip with the bought plan, e.g. "Yearly · €49.99 per year".
  final String? planChip;
  final VoidCallback onContinue;

  @override
  State<PremiumWelcomeView> createState() => _PremiumWelcomeViewState();
}

class _PremiumWelcomeViewState extends State<PremiumWelcomeView>
    with TickerProviderStateMixin {
  static const _sequence = Duration(milliseconds: 4200);
  static const _confettiDuration = Duration(milliseconds: 3400);

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: _sequence,
  );
  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: _confettiDuration,
  );
  bool _started = false;
  bool _reduced = false;
  int _burst = 0;

  @override
  void initState() {
    super.initState();
    _intro.addListener(_onIntroTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced) {
      _intro.value = 1;
      return;
    }
    unawaited(_intro.forward());
  }

  bool _confettiFired = false;
  bool _cardHaptics = false;

  void _onIntroTick() {
    // The confetti starts when the dot of the mark has popped in.
    if (!_confettiFired && _intro.value >= 0.2) {
      _confettiFired = true;
      _fireConfetti();
    }
    if (!_cardHaptics && _intro.value >= 0.55) {
      _cardHaptics = true;
      unawaited(HapticFeedback.selectionClick());
    }
  }

  void _fireConfetti() {
    if (_reduced) return;
    setState(() => _burst++);
    unawaited(HapticFeedback.heavyImpact());
    unawaited(_confetti.forward(from: 0));
  }

  @override
  void dispose() {
    _intro.removeListener(_onIntroTick);
    _intro.dispose();
    _confetti.dispose();
    super.dispose();
  }

  double _phase(
    double begin,
    double end, [
    Curve curve = Curves.easeOutCubic,
  ]) => Interval(begin, end, curve: curve).transform(_intro.value);

  Widget _reveal(double begin, Widget child, {double distance = 22}) {
    final t = _phase(begin, math.min(1, begin + 0.2));
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, distance * (1 - t)),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final media = MediaQuery.of(context);
    final sceneHeight = (media.size.height * 0.28).clamp(160.0, 236.0);
    final features = [
      (
        Icons.photo_camera_rounded,
        AppColors.primary,
        l10n.subscriptionAiPhotoRecognition,
        l10n.subscriptionWelcomePhotoText,
      ),
      (
        Icons.chat_bubble_rounded,
        AppColors.mint,
        'Lookin Coach',
        l10n.subscriptionWelcomeCoachText,
      ),
      (
        Icons.restaurant_menu_rounded,
        AppColors.orange,
        l10n.subscriptionAllRecipes,
        l10n.subscriptionWelcomeRecipesText,
      ),
    ];

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _intro,
          builder: (context, _) => Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: sceneHeight,
                            child: GestureDetector(
                              key: const Key('premium-welcome-mark'),
                              behavior: HitTestBehavior.opaque,
                              onTap: _fireConfetti,
                              child: ExcludeSemantics(
                                child: CustomPaint(
                                  painter: _ScenePainter(
                                    bloom: _phase(0, 0.3),
                                    rays: _phase(0.05, 0.4),
                                    rayTurn: _reduced
                                        ? 0
                                        : Curves.easeOutCubic.transform(
                                            _intro.value,
                                          ),
                                    ring: _phase(
                                      0.02,
                                      0.18,
                                      Curves.easeInOutCubic,
                                    ),
                                    dot: _phase(0.14, 0.24, Curves.easeOutBack),
                                    pulse: _phase(0.2, 0.62, Curves.easeOut),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _reveal(
                            0.22,
                            Center(
                              child: _PremiumBadge(shine: _phase(0.3, 0.5)),
                            ),
                            distance: 10,
                          ),
                          const SizedBox(height: 12),
                          _reveal(
                            0.28,
                            Semantics(
                              liveRegion: true,
                              header: true,
                              child: _ShimmerText(
                                text: l10n.subscriptionWelcomeTitle,
                                progress: _phase(0.36, 0.62, Curves.easeInOut),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      height: 1.15,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _reveal(
                            0.34,
                            Text(
                              widget.detailLine == null
                                  ? widget.statusLine
                                  : '${widget.statusLine}\n${widget.detailLine}',
                              key: const Key('paywall-success-subtitle'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14.5,
                                height: 1.45,
                              ),
                            ),
                          ),
                          if (widget.planChip case final chip?) ...[
                            const SizedBox(height: 12),
                            _reveal(0.4, Center(child: _PlanChip(label: chip))),
                          ],
                          const SizedBox(height: 18),
                          for (final (i, feature) in features.indexed) ...[
                            if (i > 0) const SizedBox(height: 9),
                            _FeatureCard(
                              icon: feature.$1,
                              color: feature.$2,
                              title: feature.$3,
                              text: feature.$4,
                              progress: _phase(
                                0.46 + i * 0.08,
                                0.66 + i * 0.08,
                                Curves.easeOutBack,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Pinned, so the way into the app is always on screen.
              _reveal(
                0.7,
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    22,
                    6,
                    22,
                    14 + media.padding.bottom,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ShimmerButton(
                            label: l10n.subscriptionLetSGo,
                            shine: _phase(0.8, 1, Curves.easeInOut),
                            onPressed: widget.onContinue,
                          ),
                          if (widget.kind == PremiumWelcomeKind.purchase) ...[
                            const SizedBox(height: 10),
                            Text(
                              l10n.subscriptionWelcomeRenewsNote,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                distance: 30,
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: AnimatedBuilder(
                animation: _confetti,
                builder: (context, _) => CustomPaint(
                  painter: _ConfettiPainter(
                    progress: _confetti.isAnimating ? _confetti.value : 0,
                    seed: _burst,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Glow, turning light rays, the Lookin mark (open ring + dot) and two soft
/// pulse rings, all drawn around the centre of the scene.
class _ScenePainter extends CustomPainter {
  const _ScenePainter({
    required this.bloom,
    required this.rays,
    required this.rayTurn,
    required this.ring,
    required this.dot,
    required this.pulse,
  });

  final double bloom;
  final double rays;
  final double rayTurn;
  final double ring;
  final double dot;
  final double pulse;

  // Same proportions as the app icon and the start screen.
  static const _strokeRatio = 0.258;
  static const _dotRatio = 0.292;
  static const _arcStart = -48.6 * math.pi / 180;
  static const _arcSweep = (360 - 29) * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final reach = size.shortestSide / 2;
    final markRadius = reach * 0.3;

    if (bloom > 0) {
      canvas.drawCircle(
        center,
        reach * (0.4 + 0.75 * bloom),
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.28 * bloom),
              AppColors.mint.withValues(alpha: 0.10 * bloom),
              AppColors.background.withValues(alpha: 0),
            ],
            stops: const [0, 0.45, 1],
          ).createShader(Rect.fromCircle(center: center, radius: reach * 1.15)),
      );
    }

    if (rays > 0) {
      const count = 12;
      final rayPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.22 * rays),
            AppColors.primary.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: reach * 1.2));
      for (var i = 0; i < count; i++) {
        final angle = rayTurn * 0.9 + i * 2 * math.pi / count;
        const half = 0.075;
        final path = Path()
          ..moveTo(center.dx, center.dy)
          ..lineTo(
            center.dx + math.cos(angle - half) * reach * 1.2,
            center.dy + math.sin(angle - half) * reach * 1.2,
          )
          ..lineTo(
            center.dx + math.cos(angle + half) * reach * 1.2,
            center.dy + math.sin(angle + half) * reach * 1.2,
          )
          ..close();
        canvas.drawPath(path, rayPaint);
      }
    }

    if (pulse > 0 && pulse < 1) {
      for (var wave = 0; wave < 2; wave++) {
        final p = ((pulse - wave * 0.25) / 0.75).clamp(0.0, 1.0);
        if (p <= 0 || p >= 1) continue;
        canvas.drawCircle(
          center,
          markRadius * (1.2 + 1.9 * p),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3 * (1 - p)
            ..color = AppColors.primary.withValues(alpha: 0.6 * (1 - p)),
        );
      }
    }

    // Dark disc behind the mark so it reads clearly on the rays.
    if (ring > 0) {
      canvas.drawCircle(
        center,
        markRadius * 1.55,
        Paint()..color = AppColors.background.withValues(alpha: 0.85 * ring),
      );
      canvas.drawCircle(
        center,
        markRadius * 1.55,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = AppColors.primary.withValues(alpha: 0.35 * ring),
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: markRadius),
        _arcStart,
        _arcSweep * ring,
        false,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = markRadius * _strokeRatio
          ..strokeCap = StrokeCap.round,
      );
    }
    if (dot > 0) {
      canvas.drawCircle(
        center,
        markRadius * _dotRatio * dot,
        Paint()..color = AppColors.primary,
      );
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.bloom != bloom ||
      old.rays != rays ||
      old.rayTurn != rayTurn ||
      old.ring != ring ||
      old.dot != dot ||
      old.pulse != pulse;
}

/// Confetti from both lower corners: shot upwards, slowed by gravity and
/// air, fluttering while it falls, fading at the end. Positions follow from
/// [progress] alone, so the painter needs no state of its own.
class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.progress, required this.seed});

  final double progress;
  final int seed;

  static const _colors = [
    AppColors.primary,
    AppColors.mint,
    AppColors.orange,
    AppColors.purple,
    AppColors.blue,
    AppColors.text,
  ];
  static const _pieces = 72;
  static const _seconds = 3.4;
  static const _gravity = 1150.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1 || size.isEmpty) return;
    final random = math.Random(seed * 7919 + 11);
    final t = progress * _seconds;
    final fade = progress < 0.72 ? 1.0 : (1 - (progress - 0.72) / 0.28);
    final scale = (size.height / 800).clamp(0.6, 1.3);
    for (var i = 0; i < _pieces; i++) {
      final fromLeft = i.isEven;
      final speed = (900 + random.nextDouble() * 650) * scale;
      // Mostly upwards, tilted towards the middle of the screen.
      final angle = (fromLeft ? -1 : 1) * (0.18 + random.nextDouble() * 0.5);
      final vx = math.sin(angle).abs() * speed * (fromLeft ? 1 : -1);
      final vy = -math.cos(angle) * speed;
      final drag = 0.55 + random.nextDouble() * 0.35;
      final delay = random.nextDouble() * 0.18;
      final spin = (random.nextDouble() * 2 - 1) * 9;
      final flutter = 5 + random.nextDouble() * 7;
      final color = _colors[random.nextInt(_colors.length)];
      final round = random.nextDouble() < 0.28;
      final w = (5 + random.nextDouble() * 5) * scale;
      final h = (9 + random.nextDouble() * 8) * scale;

      final local = t - delay;
      if (local <= 0) continue;
      // Air resistance: the speed decays, gravity keeps pulling.
      final k = 1 / drag;
      final decay = (1 - math.exp(-k * local)) / k;
      final x = (fromLeft ? -10.0 : size.width + 10) + vx * decay;
      final y =
          size.height * 0.92 +
          vy * decay +
          0.5 * _gravity * local * local * 0.55;
      if (y > size.height + 30) continue;

      canvas
        ..save()
        ..translate(x, y)
        ..rotate(spin * local);
      final paint = Paint()..color = color.withValues(alpha: fade);
      if (round) {
        canvas.drawCircle(Offset.zero, w * 0.55, paint);
      } else {
        // Flutter: the strip turns around its long axis while it falls.
        final width = w * (0.25 + 0.75 * math.cos(flutter * local).abs());
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: width, height: h),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.progress != progress || old.seed != seed;
}

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge({required this.shine});

  /// 0 → 1: a light band sweeps once across the badge.
  final double shine;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.mint],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  size: 16,
                  color: AppColors.black,
                ),
                SizedBox(width: 6),
                Text(
                  'LOOKIN PREMIUM',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (shine > 0 && shine < 1)
            Positioned.fill(
              child: FractionalTranslation(
                translation: Offset(-1.2 + 2.4 * shine, 0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.white.withValues(alpha: 0),
                        AppColors.white.withValues(alpha: 0.65),
                        AppColors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Text with a light band that sweeps across it once ([progress] 0 → 1).
class _ShimmerText extends StatelessWidget {
  const _ShimmerText({
    required this.text,
    required this.progress,
    required this.style,
  });

  final String text;
  final double progress;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final label = Text(text, textAlign: TextAlign.center, style: style);
    if (progress <= 0 || progress >= 1) return label;
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        final x = -0.4 + 1.8 * progress;
        return LinearGradient(
          colors: const [AppColors.text, AppColors.primary, AppColors.text],
          stops: [
            (x - 0.25).clamp(0.0, 1.0),
            x.clamp(0.0, 1.0),
            (x + 0.25).clamp(0.0, 1.0),
          ],
        ).createShader(bounds);
      },
      child: label,
    );
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderBright),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              key: const Key('premium-welcome-plan'),
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
    required this.progress,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String text;

  /// 0 → 1 (may overshoot slightly): slides in from the right and pops.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    return Opacity(
      opacity: p.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(28 * (1 - p), 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [color.withValues(alpha: 0.13), AppColors.surface],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.32)),
          ),
          child: Row(
            children: [
              Transform.scale(
                scale: 0.7 + 0.3 * p,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: AppColors.black, size: 23),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      text,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.check_circle_rounded, color: color, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerButton extends StatelessWidget {
  const _ShimmerButton({
    required this.label,
    required this.shine,
    required this.onPressed,
  });

  final String label;

  /// 0 → 1: two light bands sweep across the button.
  final double shine;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final band = (shine * 2) % 1;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('paywall-success-continue'),
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(58),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(label)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
          if (shine > 0 && shine < 1)
            Positioned.fill(
              child: IgnorePointer(
                child: FractionalTranslation(
                  translation: Offset(-1 + 2 * band, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.white.withValues(alpha: 0),
                          AppColors.white.withValues(alpha: 0.45),
                          AppColors.white.withValues(alpha: 0),
                        ],
                        stops: const [0.3, 0.5, 0.7],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
