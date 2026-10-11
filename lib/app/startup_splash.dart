import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Plays the Lookin start animation once per cold start above the app.
///
/// The ring is drawn, the dot pops into its centre, "Lookin." is written
/// letter by letter, then the view zooms into the dot until it fills the
/// screen and fades into the app. [child] is built right away underneath, so
/// the app keeps loading while the animation runs.
///
/// Mount it above `FitnessAiApp`: its `MaterialApp` is re-keyed on every
/// account change, and the splash must not replay on sign-in or sign-out.
class StartupSplash extends StatefulWidget {
  const StartupSplash({required this.child, super.key});

  final Widget child;

  /// Full animation length.
  static const duration = Duration(milliseconds: _totalMs);

  /// Plain fade from the dark background when animations are reduced.
  static const reducedMotionDuration = Duration(milliseconds: 200);

  /// Fade after a tap to skip.
  static const skipDuration = Duration(milliseconds: 180);

  static const semanticsLabel = 'Lookin wird geöffnet';

  @override
  State<StartupSplash> createState() => _StartupSplashState();
}

class _StartupSplashState extends State<StartupSplash> {
  bool _done = false;

  void _finish() {
    if (mounted && !_done) setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      fit: StackFit.expand,
      children: [
        widget.child,
        if (!_done)
          Positioned.fill(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: MediaQuery.fromView(
                view: View.of(context),
                child: _SplashOverlay(onFinished: _finish),
              ),
            ),
          ),
      ],
    );
  }
}

// Timeline in milliseconds.
const _totalMs = 3300;
const _ringStart = 100;
const _ringEnd = 1050;
const _dotStart = 900;
const _dotEnd = 1350;
const _lettersStart = 1150;
const _letterStep = 130;
const _letterDuration = 320; // last letter done at 2250 ms
const _zoomStart = 2550;
const _textFadeEnd = 2750;
const _zoomEnd = 3050;

const _word = 'Lookin.';

// Proportions of the app icon, relative to the ring's centre-line radius.
const _strokeRatio = 0.258;
const _dotRatio = 0.292;
// The gap sits top right: the arc runs clockwise from its right end (-48.6°)
// to its left end (-77.6°).
const _arcStart = -48.6 * math.pi / 180;
const _arcSweep = (360 - 29) * math.pi / 180;

class _SplashOverlay extends StatefulWidget {
  const _SplashOverlay({required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<_SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<_SplashOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: StartupSplash.duration,
  );
  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: StartupSplash.skipDuration,
  );
  bool _started = false;
  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    _intro.addStatusListener(_onStatus);
    _exit.addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) widget.onFinished();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced) {
      _exit
        ..duration = StartupSplash.reducedMotionDuration
        ..forward();
    } else {
      _intro.forward();
    }
  }

  void _skip() {
    if (_exit.isAnimating || _exit.isCompleted) return;
    _intro.stop();
    _exit.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    _exit.dispose();
    super.dispose();
  }

  double _phase(int startMs, int endMs, [Curve curve = Curves.linear]) {
    final ms = _intro.value * _totalMs;
    final t = ((ms - startMs) / (endMs - startMs)).clamp(0.0, 1.0);
    return curve.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: StartupSplash.semanticsLabel,
      child: BlockSemantics(
        child: ExcludeSemantics(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _skip,
            child: AnimatedBuilder(
              animation: Listenable.merge([_intro, _exit]),
              builder: (context, _) {
                final fade = _phase(_zoomEnd, _totalMs, Curves.easeOut);
                final opacity = ((1 - fade) * (1 - _exit.value)).clamp(
                  0.0,
                  1.0,
                );
                return Opacity(
                  opacity: opacity,
                  child: ColoredBox(
                    color: AppColors.background,
                    child: _reduced
                        ? const SizedBox.expand()
                        : LayoutBuilder(builder: _buildScene),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScene(BuildContext context, BoxConstraints constraints) {
    final size = constraints.biggest;
    final ring = (size.shortestSide * 0.12).clamp(26.0, 52.0);
    final outer = ring * (1 + _strokeRatio / 2);
    final fontSize = (ring * 0.92).clamp(24.0, 46.0);
    final gap = ring * 0.5;
    final textHeight = fontSize * 1.3;
    final groupHeight = outer * 2 + gap + textHeight;
    final center = Offset(
      size.width / 2,
      math.max(outer, (size.height - groupHeight) / 2 + outer),
    );

    // Zoom until the dot covers the farthest corner of the screen.
    final far = math.sqrt(
      math.pow(math.max(center.dx, size.width - center.dx), 2) +
          math.pow(math.max(center.dy, size.height - center.dy), 2),
    );
    final maxScale = math.max(1.0, far / (ring * _dotRatio) * 1.04);
    final zoomT = _phase(_zoomStart, _zoomEnd, Curves.easeInCubic);
    final scale = math.pow(maxScale, zoomT).toDouble();

    final letters = _phase(
      _lettersStart,
      _lettersStart + _letterStep * (_word.length - 1) + _letterDuration,
      Curves.easeOutCubic,
    );
    final textOpacity = 1 - _phase(_zoomStart, _textFadeEnd, Curves.easeOut);

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          key: const ValueKey('startup-splash-mark'),
          painter: _MarkPainter(
            center: center,
            ring: ring,
            ringProgress: _phase(_ringStart, _ringEnd, Curves.easeInOutCubic),
            dotScale: _phase(_dotStart, _dotEnd, Curves.easeOutBack),
            zoom: scale,
          ),
        ),
        if (textOpacity > 0)
          Positioned(
            left: 16,
            right: 16,
            top: center.dy + outer + gap,
            height: textHeight,
            child: Opacity(
              opacity: textOpacity,
              child: Transform.translate(
                offset: Offset(0, (1 - letters) * fontSize * 0.2),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text.rich(
                      key: const ValueKey('startup-splash-word'),
                      TextSpan(children: _letterSpans()),
                      textScaler: TextScaler.noScaling,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -fontSize * 0.045,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<TextSpan> _letterSpans() {
    return [
      for (var i = 0; i < _word.length; i++)
        TextSpan(
          text: _word[i],
          style: TextStyle(
            color: (i == _word.length - 1 ? AppColors.primary : AppColors.text)
                .withValues(
                  alpha: _phase(
                    _lettersStart + _letterStep * i,
                    _lettersStart + _letterStep * i + _letterDuration,
                    Curves.easeOut,
                  ),
                ),
          ),
        ),
    ];
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({
    required this.center,
    required this.ring,
    required this.ringProgress,
    required this.dotScale,
    required this.zoom,
  });

  final Offset center;
  final double ring;
  final double ringProgress;
  final double dotScale;
  final double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..scale(zoom);
    final paint = Paint()
      ..color = AppColors.primary
      ..isAntiAlias = true;
    if (ringProgress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: ring),
        _arcStart,
        _arcSweep * ringProgress,
        false,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = ring * _strokeRatio
          ..strokeCap = StrokeCap.round,
      );
    }
    if (dotScale > 0) {
      canvas.drawCircle(Offset.zero, ring * _dotRatio * dotScale, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.center != center ||
      old.ring != ring ||
      old.ringProgress != ringProgress ||
      old.dotScale != dotScale ||
      old.zoom != zoom;
}
