import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/l10n.dart';

/// What the welcome screen celebrates.
enum PremiumWelcomeKind { trial, purchase }

/// Texts of the membership card.
class WelcomeCardData {
  const WelcomeCardData({
    required this.planLabel,
    required this.footerLabel,
    required this.footerValue,
    this.memberName,
  });

  /// Left bottom: the bought plan or the trial.
  final String planLabel;

  /// Right bottom, small caption and value, e.g. "Next renewal" / date.
  final String footerLabel;
  final String footerValue;

  /// Shown on the card; "Premium member" when empty.
  final String? memberName;
}

/// Full-screen "Welcome to Lookin Premium" after a purchase or the start of
/// the free trial.
///
/// One finite sequence of about five seconds: a glow blooms, the Lookin mark
/// draws itself, a shock ring and confetti burst out, three feature chips fly
/// out of the mark into orbit, the title appears word by word, a membership
/// card flips in (drag it sideways to tilt it) and the benefits unlock one
/// after another: a lock opens, the tile floods with colour and the number of
/// daily coach questions counts up. Afterwards everything stands still;
/// tapping the mark throws confetti again. With "reduce motion" the final
/// state is shown at once and no confetti is drawn.
class PremiumWelcomeView extends StatefulWidget {
  const PremiumWelcomeView({
    required this.kind,
    required this.statusLine,
    required this.card,
    required this.aiLimit,
    required this.onContinue,
    super.key,
  });

  final PremiumWelcomeKind kind;

  /// Line under the title, e.g. the thank-you.
  final String statusLine;
  final WelcomeCardData card;

  /// Daily AI requests of this plan (counts up in the coach row).
  final int aiLimit;
  final VoidCallback onContinue;

  @override
  State<PremiumWelcomeView> createState() => _PremiumWelcomeViewState();
}

class _PremiumWelcomeViewState extends State<PremiumWelcomeView>
    with TickerProviderStateMixin {
  static const _sequence = Duration(milliseconds: 5200);
  static const _confettiDuration = Duration(milliseconds: 3400);

  // Moments of the sequence (0 to 1), also used for the haptic ticks.
  static const _burstAt = 0.1;
  static const _cardAt = 0.34;
  static const _unlockAt = [0.5, 0.6, 0.7];

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: _sequence,
  );
  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: _confettiDuration,
  );
  late final AnimationController _tiltBack = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final AnimationController _tap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  final _scroll = ScrollController();
  bool _autoScrolled = false;
  bool _started = false;
  bool _reduced = false;
  int _burst = 0;
  bool _burstFired = false;
  bool _cardLanded = false;
  final _unlocked = [false, false, false];

  // Sideways tilt of the card (-1 to 1).
  double _tilt = 0;
  double _tiltFrom = 0;

  @override
  void initState() {
    super.initState();
    _intro.addListener(_onIntroTick);
    _tiltBack.addListener(() {
      setState(
        () => _tilt =
            _tiltFrom * (1 - Curves.elasticOut.transform(_tiltBack.value)),
      );
    });
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

  void _onIntroTick() {
    if (_reduced) return;
    final v = _intro.value;
    if (!_burstFired && v >= _burstAt) {
      _burstFired = true;
      _fireConfetti();
    }
    // While the benefits unlock, bring them into view (only if the person has
    // not scrolled on their own).
    if (!_autoScrolled && v >= 0.44) {
      _autoScrolled = true;
      if (_scroll.hasClients && _scroll.offset < 4) {
        unawaited(
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 750),
            curve: Curves.easeInOutCubic,
          ),
        );
      }
    }
    if (!_cardLanded && v >= _cardAt + 0.14) {
      _cardLanded = true;
      unawaited(HapticFeedback.lightImpact());
    }
    for (var i = 0; i < _unlockAt.length; i++) {
      if (!_unlocked[i] && v >= _unlockAt[i] + 0.04) {
        _unlocked[i] = true;
        unawaited(HapticFeedback.selectionClick());
      }
    }
  }

  void _fireConfetti() {
    if (_reduced) return;
    setState(() => _burst++);
    unawaited(HapticFeedback.heavyImpact());
    unawaited(_confetti.forward(from: 0));
  }

  void _tapCard() {
    if (_reduced) return;
    unawaited(HapticFeedback.selectionClick());
    unawaited(_tap.forward(from: 0));
  }

  @override
  void dispose() {
    _intro.removeListener(_onIntroTick);
    _intro.dispose();
    _confetti.dispose();
    _tiltBack.dispose();
    _tap.dispose();
    _scroll.dispose();
    super.dispose();
  }

  double _phase(
    double begin,
    double end, [
    Curve curve = Curves.easeOutCubic,
  ]) => Interval(begin, end, curve: curve).transform(_intro.value);

  Widget _reveal(double begin, Widget child, {double distance = 22}) {
    final t = _phase(begin, math.min(1, begin + 0.12));
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
    final sceneHeight = (media.size.height * 0.21).clamp(150.0, 214.0);
    // A function: the counting number must be re-read on every frame.
    List<(IconData, Color, String, String)> features() => [
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
        l10n.subscriptionWelcomeCoachText(
          (widget.aiLimit * _phase(0.62, 0.8)).round().toString(),
        ),
      ),
      (
        Icons.restaurant_menu_rounded,
        AppColors.orange,
        l10n.subscriptionAllRecipes,
        l10n.subscriptionWelcomeRecipesText,
      ),
    ];
    final words = l10n.subscriptionWelcomeTitle.split(' ');

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: AnimatedBuilder(
                animation: _intro,
                builder: (context, _) => CustomPaint(
                  painter: _AuroraPainter(
                    progress: _phase(0, 1, Curves.linear),
                    strength: _phase(0.04, 0.3),
                  ),
                ),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: Listenable.merge([_intro, _tap]),
          builder: (context, _) => Column(
            children: [
              Expanded(
                // Soft fade at the top edge while the page scrolls under the bar.
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
                    stops: [0, 0.035],
                  ).createShader(bounds),
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: sceneHeight,
                              child: _scene(l10n, sceneHeight),
                            ),
                            _reveal(
                              0.16,
                              Center(
                                child: _PremiumBadge(shine: _phase(0.24, 0.42)),
                              ),
                              distance: 10,
                            ),
                            const SizedBox(height: 12),
                            Semantics(
                              liveRegion: true,
                              header: true,
                              child: _ShimmerMask(
                                progress: _phase(0.3, 0.5, Curves.easeInOut),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 9,
                                  children: [
                                    for (final (i, word) in words.indexed)
                                      _reveal(
                                        0.18 + i * 0.035,
                                        Text(
                                          word,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                height: 1.15,
                                              ),
                                        ),
                                        distance: 16,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _reveal(
                              0.26,
                              Text(
                                widget.statusLine,
                                key: const Key('paywall-success-subtitle'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14.5,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _card(l10n),
                            const SizedBox(height: 22),
                            _reveal(
                              0.44,
                              Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Text(
                                      l10n.subscriptionWelcomeUnlockedHeading,
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              distance: 8,
                            ),
                            const SizedBox(height: 10),
                            for (final (i, feature) in features().indexed) ...[
                              if (i > 0) const SizedBox(height: 9),
                              _UnlockRow(
                                key: Key('premium-welcome-feature-$i'),
                                icon: feature.$1,
                                color: feature.$2,
                                title: feature.$3,
                                text: feature.$4,
                                appear: _phase(
                                  0.42 + i * 0.03,
                                  0.54 + i * 0.03,
                                ),
                                unlock: _phase(
                                  _unlockAt[i],
                                  _unlockAt[i] + 0.1,
                                  Curves.easeOut,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Pinned, so the way into the app is always on screen.
              _reveal(
                0.58,
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
                            shine: _phase(0.78, 1, Curves.easeInOut),
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

  /// Mark, shock rings and the three chips that fly into orbit.
  Widget _scene(AppLocalizations l10n, double sceneHeight) {
    final chips = [
      (Icons.photo_camera_rounded, l10n.subscriptionAiPhoto, AppColors.primary),
      (Icons.auto_awesome_rounded, 'Coach', AppColors.mint),
      (
        Icons.restaurant_menu_rounded,
        l10n.subscriptionRecipes,
        AppColors.orange,
      ),
    ];
    // Targets follow the size of the mark, so the chips never cover it.
    final disc = sceneHeight / 2 * 0.3 * 1.55;
    final targets = [
      Offset(-(disc + 64), -disc * 0.45),
      Offset(disc + 66, -disc * 0.95),
      Offset(disc * 0.9, disc + 26),
    ];
    return GestureDetector(
      key: const Key('premium-welcome-mark'),
      behavior: HitTestBehavior.opaque,
      onTap: _fireConfetti,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: CustomPaint(
                painter: _ScenePainter(
                  bloom: _phase(0, 0.2),
                  rays: _phase(0.03, 0.26),
                  rayTurn: _reduced
                      ? 0
                      : Curves.easeOutCubic.transform(_intro.value),
                  ring: _phase(0.01, 0.1, Curves.easeInOutCubic),
                  dot: _phase(0.07, 0.13, Curves.easeOutBack),
                  pulse: _phase(0.1, 0.4, Curves.easeOut),
                  sparkle: _phase(0.14, 0.5, Curves.linear),
                ),
              ),
            ),
          ),
          for (final (i, chip) in chips.indexed)
            _flyingChip(
              icon: chip.$1,
              label: chip.$2,
              color: chip.$3,
              target: targets[i],
              fly: _phase(0.12 + i * 0.03, 0.3 + i * 0.03, Curves.easeOutBack),
            ),
        ],
      ),
    );
  }

  Widget _flyingChip({
    required IconData icon,
    required String label,
    required Color color,
    required Offset target,
    required double fly,
  }) {
    return ExcludeSemantics(
      child: Opacity(
        opacity: (fly * 2).clamp(0.0, 1.0),
        child: Transform.translate(
          offset: target * fly,
          child: Transform.scale(
            scale: 0.4 + 0.6 * fly,
            child: Container(
              padding: const EdgeInsets.fromLTRB(5, 5, 11, 5),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: color.withValues(alpha: 0.6)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.28),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 14, color: AppColors.black),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    label,
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(AppLocalizations l10n) {
    final entrance = _phase(_cardAt, _cardAt + 0.2, Curves.easeOutBack);
    final sweep = _phase(_cardAt + 0.14, _cardAt + 0.34, Curves.easeInOut);
    // A short wobble after landing invites the person to tilt it.
    final wobbleT = _phase(_cardAt + 0.2, _cardAt + 0.34, Curves.linear);
    final wobble = _reduced
        ? 0.0
        : math.sin(wobbleT * math.pi * 3) * (1 - wobbleT) * 0.16;
    final bounce = _tap.isAnimating
        ? math.sin(_tap.value * math.pi * 2) * (1 - _tap.value) * 0.35
        : 0.0;
    final rotateY = _tilt * 0.5 + wobble + bounce;
    final flip = (1 - entrance.clamp(0.0, 1.2)) * 1.1;
    final tapShine = _tap.isAnimating ? _tap.value : -1.0;
    final sheen = sweep > 0 && sweep < 1 ? sweep : tapShine + _tilt * 0.5;
    return Opacity(
      opacity: (entrance * 1.6).clamp(0.0, 1.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: GestureDetector(
            key: const Key('premium-welcome-card'),
            behavior: HitTestBehavior.opaque,
            onTap: _tapCard,
            onHorizontalDragStart: (_) => _tiltBack.stop(),
            onHorizontalDragUpdate: (details) => setState(
              () => _tilt = (_tilt + details.delta.dx / 120).clamp(-1.0, 1.0),
            ),
            onHorizontalDragEnd: (_) {
              _tiltFrom = _tilt;
              unawaited(_tiltBack.forward(from: 0));
            },
            onHorizontalDragCancel: () {
              _tiltFrom = _tilt;
              unawaited(_tiltBack.forward(from: 0));
            },
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateX(flip)
                ..rotateY(rotateY)
                ..scaleByDouble(
                  0.9 + 0.1 * entrance.clamp(0.0, 1.0),
                  0.9 + 0.1 * entrance.clamp(0.0, 1.0),
                  1,
                  1,
                ),
              child: _MemberCard(
                data: widget.card,
                kind: widget.kind,
                memberFallback: l10n.subscriptionWelcomeMember,
                memberLabel: l10n.subscriptionWelcomeMemberLabel,
                sheen: sheen,
                tiltShift: _tilt,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Two soft aurora blobs behind everything. They drift once while the
/// sequence runs and then rest.
class _AuroraPainter extends CustomPainter {
  const _AuroraPainter({required this.progress, required this.strength});

  final double progress;
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    if (strength <= 0 || size.isEmpty) return;
    final drift = math.sin(progress * math.pi * 1.4);
    void blob(Offset center, double radius, Color color, double alpha) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: alpha * strength),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    blob(
      Offset(size.width * (0.2 + 0.12 * drift), size.height * 0.12),
      size.width * 0.8,
      AppColors.primary,
      0.13,
    );
    blob(
      Offset(size.width * (0.9 - 0.14 * drift), size.height * 0.34),
      size.width * 0.75,
      AppColors.mint,
      0.1,
    );
  }

  @override
  bool shouldRepaint(_AuroraPainter old) =>
      old.progress != progress || old.strength != strength;
}

/// Glow, turning light rays, the Lookin mark (open ring + dot), pulse rings
/// and twinkling stars, all drawn around the centre of the scene.
class _ScenePainter extends CustomPainter {
  const _ScenePainter({
    required this.bloom,
    required this.rays,
    required this.rayTurn,
    required this.ring,
    required this.dot,
    required this.pulse,
    required this.sparkle,
  });

  final double bloom;
  final double rays;
  final double rayTurn;
  final double ring;
  final double dot;
  final double pulse;
  final double sparkle;

  // Same proportions as the app icon and the start screen.
  static const _strokeRatio = 0.258;
  static const _dotRatio = 0.292;
  static const _arcStart = -48.6 * math.pi / 180;
  static const _arcSweep = (360 - 29) * math.pi / 180;

  static const _stars = [
    (Offset(-0.78, -0.62), 0.0, 9.0),
    (Offset(0.7, -0.78), 0.2, 7.0),
    (Offset(-0.9, 0.2), 0.45, 6.0),
    (Offset(0.92, 0.12), 0.65, 8.0),
    (Offset(-0.35, 0.86), 0.3, 6.0),
    (Offset(0.55, 0.8), 0.8, 7.0),
  ];

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
      for (var wave = 0; wave < 3; wave++) {
        final p = ((pulse - wave * 0.2) / 0.6).clamp(0.0, 1.0);
        if (p <= 0 || p >= 1) continue;
        canvas.drawCircle(
          center,
          markRadius * (1.2 + 2.4 * p),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.2 * (1 - p)
            ..color = (wave.isEven ? AppColors.primary : AppColors.mint)
                .withValues(alpha: 0.6 * (1 - p)),
        );
      }
    }

    // Twinkling stars.
    if (sparkle > 0 && sparkle < 1) {
      for (final (anchor, phaseShift, radius) in _stars) {
        final t = ((sparkle - phaseShift * 0.5) / 0.5).clamp(0.0, 1.0);
        if (t <= 0 || t >= 1) continue;
        final alpha = math.sin(t * math.pi);
        _star(
          canvas,
          Offset(
            center.dx + anchor.dx * size.width * 0.46,
            center.dy + anchor.dy * reach * 0.95,
          ),
          radius * (0.5 + 0.7 * alpha),
          AppColors.primary.withValues(alpha: 0.9 * alpha),
        );
      }
    }

    // Dark disc behind the mark so it reads clearly on the rays.
    if (ring > 0) {
      canvas
        ..drawCircle(
          center,
          markRadius * 1.55,
          Paint()..color = AppColors.background.withValues(alpha: 0.85 * ring),
        )
        ..drawCircle(
          center,
          markRadius * 1.55,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = AppColors.primary.withValues(alpha: 0.35 * ring),
        )
        ..drawArc(
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

  static void _star(Canvas canvas, Offset c, double r, Color color) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.bloom != bloom ||
      old.rays != rays ||
      old.rayTurn != rayTurn ||
      old.ring != ring ||
      old.dot != dot ||
      old.pulse != pulse ||
      old.sparkle != sparkle;
}

/// The Lookin mark: open ring and dot, in the proportions of the app icon.
class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.color});

  final Color color;

  static const _strokeRatio = 0.258;
  static const _dotRatio = 0.292;
  static const _arcStart = -48.6 * math.pi / 180;
  static const _arcSweep = (360 - 29) * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 / (1 + _strokeRatio / 2);
    canvas
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius),
        _arcStart,
        _arcSweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * _strokeRatio
          ..strokeCap = StrokeCap.round,
      )
      ..drawCircle(center, radius * _dotRatio, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.color != color;
}

/// Premium membership card: dark glass with a lime-to-mint edge, the mark as
/// watermark, the member name, the plan and the next renewal. A light band
/// ([sheen] 0 to 1) glides across it.
class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.data,
    required this.kind,
    required this.memberFallback,
    required this.memberLabel,
    required this.sheen,
    required this.tiltShift,
  });

  final WelcomeCardData data;
  final PremiumWelcomeKind kind;
  final String memberFallback;
  final String memberLabel;
  final double sheen;
  final double tiltShift;

  @override
  Widget build(BuildContext context) {
    final name = data.memberName?.trim();
    // A card shape at normal text size; with large text it grows so that no
    // line is cut off.
    final roomy =
        MediaQuery.textScalerOf(context).scale(1) <= 1.15 &&
        MediaQuery.sizeOf(context).width >= 380;
    final gap = roomy ? const Spacer() : const SizedBox(height: 16);
    final card = Container(
      padding: const EdgeInsets.all(1.6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.mint, AppColors.primarySoft],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 36,
            spreadRadius: 1,
            offset: Offset(-tiltShift * 14, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.4),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        AppColors.surfaceHigh,
                        AppColors.primary,
                        0.1,
                      )!,
                      AppColors.surface,
                      Color.lerp(AppColors.surface, AppColors.mint, 0.12)!,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -34,
              bottom: -42,
              width: 190,
              height: 190,
              child: ExcludeSemantics(
                child: Opacity(
                  opacity: 0.09,
                  child: CustomPaint(
                    painter: const _MarkPainter(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: roomy ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 26,
                        height: 26,
                        child: CustomPaint(
                          painter: _MarkPainter(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Lookin',
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.7),
                          ),
                        ),
                        child: Text(
                          kind == PremiumWelcomeKind.trial
                              ? 'TRIAL'
                              : 'PREMIUM',
                          textScaler: TextScaler.noScaling,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  gap,
                  Text(
                    memberLabel,
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      name == null || name.isEmpty ? memberFallback : name,
                      key: const Key('premium-welcome-member'),
                      textScaler: TextScaler.noScaling,
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          data.planLabel,
                          key: const Key('premium-welcome-plan'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              data.footerLabel,
                              key: const Key('premium-welcome-footer-label'),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              data.footerValue,
                              key: const Key('premium-welcome-footer-value'),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (sheen > -0.5 && sheen < 1.5)
              Positioned.fill(
                child: IgnorePointer(
                  child: FractionalTranslation(
                    translation: Offset(-1.1 + 2.4 * sheen, 0),
                    child: FractionallySizedBox(
                      widthFactor: 0.45,
                      alignment: Alignment.centerLeft,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.skewX(-0.35),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.white.withValues(alpha: 0),
                                AppColors.white.withValues(alpha: 0.17),
                                AppColors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return roomy ? AspectRatio(aspectRatio: 1.9, child: card) : card;
  }
}

/// One benefit that unlocks: it starts locked and dimmed; at [unlock] 0 to 1
/// the lock opens, the tile floods with its colour, rings and sparks fly out
/// and the check pops in.
class _UnlockRow extends StatelessWidget {
  const _UnlockRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
    required this.appear,
    required this.unlock,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String text;

  /// 0 to 1: the (still locked) row slides in.
  final double appear;

  /// 0 to 1: the unlocking.
  final double unlock;

  @override
  Widget build(BuildContext context) {
    final u = unlock;
    final opened = u >= 0.5;
    final flash = math.sin(u.clamp(0.0, 1.0) * math.pi);
    return Opacity(
      opacity: appear.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(26 * (1 - appear), 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(
                  AppColors.surface,
                  color.withValues(alpha: 0.15),
                  u,
                )!,
                AppColors.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.lerp(
                AppColors.border,
                color.withValues(alpha: 0.5 + 0.3 * flash),
                u,
              )!,
            ),
            boxShadow: flash > 0.05
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3 * flash),
                      blurRadius: 24,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 46,
                height: 46,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: OverflowBox(
                        maxWidth: 120,
                        maxHeight: 120,
                        child: CustomPaint(
                          size: const Size(120, 120),
                          painter: _BurstRingPainter(progress: u, color: color),
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 1 + 0.2 * flash,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Color.lerp(AppColors.surfaceSoft, color, u),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: u > 0.5
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.35),
                                    blurRadius: 16,
                                  ),
                                ]
                              : null,
                        ),
                        child: Transform.rotate(
                          angle: opened || u == 0
                              ? 0
                              : math.sin(u * math.pi * 6) * 0.25 * (1 - u),
                          child: Icon(
                            opened ? icon : Icons.lock_rounded,
                            color: opened
                                ? AppColors.black
                                : AppColors.textMuted,
                            size: 23,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Color.lerp(
                          AppColors.textMuted,
                          AppColors.text,
                          u,
                        ),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      text,
                      style: TextStyle(
                        color: AppColors.textMuted.withValues(
                          alpha: 0.55 + 0.45 * u,
                        ),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Transform.scale(
                scale: opened
                    ? Curves.easeOutBack.transform(((u - 0.5) * 2).clamp(0, 1))
                    : 1,
                child: Icon(
                  opened
                      ? Icons.check_circle_rounded
                      : Icons.lock_outline_rounded,
                  color: opened ? color : AppColors.textMuted,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A ring and eight sparks that fly out of a tile when it unlocks.
class _BurstRingPainter extends CustomPainter {
  const _BurstRingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final center = size.center(Offset.zero);
    final p = Curves.easeOutCubic.transform(progress);
    canvas.drawCircle(
      center,
      22 + 36 * p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6 * (1 - progress)
        ..color = color.withValues(alpha: 0.7 * (1 - progress)),
    );
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + 0.3;
      final distance = 20 + 34 * p * (i.isEven ? 1 : 0.7);
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * distance,
        (i.isEven ? 3.0 : 2.0) * (1 - progress),
        Paint()..color = color.withValues(alpha: 1 - progress),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstRingPainter old) =>
      old.progress != progress || old.color != color;
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

  /// 0 to 1: a light band sweeps once across the badge.
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

/// A light band that sweeps once ([progress] 0 to 1) across its child (the
/// title): the child is tinted lime where the band is.
class _ShimmerMask extends StatelessWidget {
  const _ShimmerMask({required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0 || progress >= 1) return child;
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
      child: child,
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

  /// 0 to 1: two light bands sweep across the button.
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
