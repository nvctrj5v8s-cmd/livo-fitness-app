import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import 'introduction_artwork.dart';

const _slides = [
  _IntroSlide(
    label: 'DEIN ALLTAG. EINFACHER.',
    title: 'Dein Essen.',
    emphasis: 'Dein Rhythmus.',
    description:
        'Mahlzeiten und Wasser an einem Ort. Für einen Alltag, der sich gut anfühlt.',
    accent: AppColors.primary,
    detail: 'Weniger suchen. Mehr Überblick.',
    icon: Icons.restaurant_rounded,
  ),
  _IntroSlide(
    label: 'GUTE IDEEN FÜR DEINEN TELLER.',
    title: 'Weniger überlegen.',
    emphasis: 'Mehr genießen.',
    description:
        'Entdecke Rezepte, plane deine Woche und nimm deine Einkaufsliste gleich mit.',
    accent: AppColors.primary,
    detail: 'Deine Woche, nach deinem Geschmack.',
    icon: Icons.auto_awesome_outlined,
  ),
  _IntroSlide(
    label: 'KLEINE ROUTINEN. GUTES GEFÜHL.',
    title: 'Ein Schluck mehr.',
    emphasis: 'Ein guter Anfang.',
    description:
        'Wasser und Mahlzeiten bewusst im Blick. Entdecke Routinen, die in deinen Alltag passen.',
    accent: AppColors.primary,
    detail: 'Dein Alltag zählt. Nicht die perfekte Zahl.',
    icon: Icons.water_drop_outlined,
  ),
  _IntroSlide(
    label: 'IN DEINEM TEMPO.',
    title: 'Kleine Schritte.',
    emphasis: 'Dein Fortschritt.',
    description:
        'Behalte deine Gewohnheiten im Blick. Dein Weg muss zu dir passen, nicht umgekehrt.',
    accent: AppColors.primary,
    detail: 'Mehr Gefühl für dich. Ohne Druck.',
    icon: Icons.insights_rounded,
  ),
  _IntroSlide(
    label: 'SO INDIVIDUELL WIE DU.',
    title: 'Deine Wünsche.',
    emphasis: 'Dein eigenes Livo.',
    description:
        'Dein Profil, deine Vorlieben und deine Ziele bilden den Ausgangspunkt. Du bestimmst die Richtung.',
    accent: AppColors.primary,
    detail: 'Alles beginnt mit dir.',
    icon: Icons.person_outline_rounded,
  ),
];

class _IntroSlide {
  const _IntroSlide({
    required this.label,
    required this.title,
    required this.emphasis,
    required this.description,
    required this.accent,
    required this.detail,
    required this.icon,
  });
  final String label;
  final String title;
  final String emphasis;
  final String description;
  final Color accent;
  final String detail;
  final IconData icon;
}

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({
    required this.onComplete,
    this.busy = false,
    super.key,
  });
  final Future<void> Function() onComplete;
  final bool busy;

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage>
    with SingleTickerProviderStateMixin {
  final _pages = PageController();
  late final AnimationController _entrance;
  int _index = 0;
  bool _moving = false;
  bool _started = false;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion) {
      _entrance.value = 1;
    } else if (!_started) {
      _entrance.forward();
    }
    _started = true;
  }

  @override
  void dispose() {
    _pages.dispose();
    _entrance.dispose();
    super.dispose();
  }

  Duration _duration(int milliseconds) =>
      _reducedMotion ? Duration.zero : Duration(milliseconds: milliseconds);

  Future<void> _goTo(int index) async {
    if (widget.busy ||
        _moving ||
        !_pages.hasClients ||
        index < 0 ||
        index >= _slides.length) {
      return;
    }
    setState(() => _moving = true);
    if (_reducedMotion) {
      _pages.jumpToPage(index);
    } else {
      await _pages.animateToPage(
        index,
        duration: _duration(480),
        curve: Curves.easeInOutCubic,
      );
    }
    if (mounted) setState(() => _moving = false);
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];
    final last = _index == _slides.length - 1;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _goTo(_index + 1),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _goTo(_index - 1),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: _duration(650),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.7, -0.3),
                        radius: 1.15,
                        colors: [
                          Color.alphaBlend(
                            slide.accent.withValues(alpha: 0.085),
                            AppColors.background,
                          ),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1160),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 66,
                                height: 48,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'livo.',
                                    textScaler: TextScaler.noScaling,
                                    style: TextStyle(
                                      color: AppColors.text,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1.7,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    key: const ValueKey('intro-skip'),
                                    onPressed: widget.busy
                                        ? null
                                        : widget.onComplete,
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.textMuted,
                                      minimumSize: const Size(48, 48),
                                    ),
                                    child: const Text(
                                      'Überspringen',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: PageView.builder(
                            key: const ValueKey('intro-pages'),
                            controller: _pages,
                            physics: widget.busy
                                ? const NeverScrollableScrollPhysics()
                                : const ClampingScrollPhysics(),
                            itemCount: _slides.length,
                            onPageChanged: (index) =>
                                setState(() => _index = index),
                            itemBuilder: (context, index) => AnimatedBuilder(
                              animation: Listenable.merge([_pages, _entrance]),
                              builder: (context, _) {
                                final distance =
                                    _pages.hasClients &&
                                        _pages.position.hasContentDimensions
                                    ? ((_pages.page ?? _index.toDouble()) -
                                              index)
                                          .abs()
                                          .clamp(0.0, 1.0)
                                    : 0.0;
                                final progress = _reducedMotion
                                    ? 1.0
                                    : Curves.easeOutCubic.transform(
                                        _entrance.value,
                                      );
                                return Opacity(
                                  opacity: _reducedMotion
                                      ? 1
                                      : progress * (1 - distance * 0.4),
                                  child: _SlideContent(
                                    index: index,
                                    active: index == _index,
                                    progress: progress,
                                    scale: _reducedMotion
                                        ? 1
                                        : 1 - distance * 0.08,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _slides.length,
                                    (index) => Semantics(
                                      selected: index == _index,
                                      enabled: !widget.busy && !_moving,
                                      onTap: widget.busy || _moving
                                          ? null
                                          : () => _goTo(index),
                                      label:
                                          'Seite ${index + 1} von ${_slides.length}',
                                      button: true,
                                      child: InkWell(
                                        excludeFromSemantics: true,
                                        borderRadius: BorderRadius.circular(24),
                                        onTap: widget.busy || _moving
                                            ? null
                                            : () => _goTo(index),
                                        child: SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: Center(
                                            child: AnimatedContainer(
                                              duration: _duration(320),
                                              curve: Curves.easeOutCubic,
                                              width: index == _index ? 32 : 7,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                color: index == _index
                                                    ? slide.accent
                                                    : AppColors.borderBright,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (_index > 0) ...[
                                      IconButton.outlined(
                                        tooltip: 'Zurück',
                                        onPressed: widget.busy || _moving
                                            ? null
                                            : () => _goTo(_index - 1),
                                        style: IconButton.styleFrom(
                                          minimumSize: const Size(56, 56),
                                          foregroundColor: AppColors.text,
                                          side: const BorderSide(
                                            color: AppColors.borderBright,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.arrow_back_rounded,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    Expanded(
                                      child: FilledButton(
                                        key: const ValueKey('intro-next'),
                                        onPressed: widget.busy || _moving
                                            ? null
                                            : last
                                            ? widget.onComplete
                                            : () => _goTo(_index + 1),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: slide.accent,
                                          foregroundColor: AppColors.black,
                                          minimumSize: const Size(0, 56),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                widget.busy
                                                    ? 'Einen Moment …'
                                                    : last
                                                    ? 'Los geht’s'
                                                    : 'Weiter',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: widget.busy
                                      ? null
                                      : widget.onComplete,
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.textMuted,
                                    minimumSize: const Size(48, 48),
                                  ),
                                  child: const Text.rich(
                                    TextSpan(
                                      text: 'Schon dabei? ',
                                      children: [
                                        TextSpan(
                                          text: 'Anmelden',
                                          style: TextStyle(
                                            color: AppColors.text,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideContent extends StatefulWidget {
  const _SlideContent({
    required this.index,
    required this.active,
    required this.progress,
    required this.scale,
  });
  final int index;
  final bool active;
  final double progress;
  final double scale;

  @override
  State<_SlideContent> createState() => _SlideContentState();
}

class _SlideContentState extends State<_SlideContent> {
  int _replay = 0;

  @override
  Widget build(BuildContext context) {
    final index = widget.index;
    final active = widget.active;
    final slide = _slides[index];
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final caption = _PreviewCaption(
      index: index,
      onReplay: !active || reducedMotion
          ? null
          : () => setState(() => _replay++),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 860;
        final visualHeight = desktop
            ? 420.0
            : (constraints.maxHeight * 0.50).clamp(150.0, 330.0);
        final illustration = SizedBox(
          height: visualHeight,
          child: Transform.scale(
            scale: widget.scale,
            child: TickerMode(
              enabled: active && !reducedMotion,
              child: TweenAnimationBuilder<double>(
                key: ValueKey((index, active, _replay, reducedMotion)),
                tween: Tween(begin: active && !reducedMotion ? 0 : 1, end: 1),
                duration: reducedMotion || !active
                    ? Duration.zero
                    : const Duration(milliseconds: 1800),
                curve: Curves.linear,
                builder: (context, value, _) => IntroductionArtwork(
                  index: index,
                  progress: reducedMotion ? 1 : widget.progress * value,
                  accent: slide.accent,
                ),
              ),
            ),
          ),
        );
        final copy = _IntroCopy(slide: slide, index: index, desktop: desktop);
        return SingleChildScrollView(
          key: PageStorageKey('introduction-scroll-$index'),
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: desktop ? 40 : 24,
                vertical: desktop ? 24 : 8,
              ),
              child: desktop
                  ? Row(
                      children: [
                        Expanded(flex: 5, child: copy),
                        const SizedBox(width: 32),
                        Expanded(
                          flex: 5,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [illustration, caption],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        illustration,
                        caption,
                        const SizedBox(height: 16),
                        copy,
                        const SizedBox(height: 6),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _IntroCopy extends StatelessWidget {
  const _IntroCopy({
    required this.slide,
    required this.index,
    required this.desktop,
  });
  final _IntroSlide slide;
  final int index;
  final bool desktop;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: desktop
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${index + 1}'.padLeft(2, '0'),
              style: TextStyle(
                color: slide.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                slide.label,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Semantics(
        header: true,
        child: Text.rich(
          TextSpan(
            text: '${slide.title}\n',
            children: [
              TextSpan(
                text: slide.emphasis,
                style: TextStyle(color: slide.accent),
              ),
            ],
          ),
          key: ValueKey('intro-title-$index'),
          textAlign: desktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: AppColors.text,
            fontSize: desktop ? 49 : 33,
            height: 1.09,
            letterSpacing: desktop ? -2 : -1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const SizedBox(height: 16),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Text(
          slide.description,
          textAlign: desktop ? TextAlign.left : TextAlign.center,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ),
      if (desktop) ...[
        const SizedBox(height: 30),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: slide.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(slide.icon, color: slide.accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                slide.detail,
                style: const TextStyle(color: AppColors.text, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    ],
  );
}

class _PreviewCaption extends StatelessWidget {
  const _PreviewCaption({required this.index, required this.onReplay});
  final int index;
  final VoidCallback? onReplay;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Flexible(
          child: Text(
            'Beispielansicht',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ),
        if (onReplay != null)
          IconButton(
            key: ValueKey('intro-replay-$index'),
            tooltip: 'Animation wiederholen',
            onPressed: onReplay,
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              foregroundColor: AppColors.primary,
            ),
            icon: const Icon(Icons.replay_rounded, size: 17),
          ),
      ],
    ),
  );
}
