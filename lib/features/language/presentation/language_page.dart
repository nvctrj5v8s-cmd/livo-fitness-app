import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/l10n.dart';
import '../../../l10n/locale_controller.dart';
import '../../../shared/widgets/ui_components.dart';

/// Each language is named in its own language, so everyone finds theirs.
class LanguageOption {
  const LanguageOption({
    required this.locale,
    required this.code,
    required this.name,
    required this.tagline,
  });

  final Locale locale;
  final String code;
  final String name;
  final String tagline;

  static const all = [
    LanguageOption(
      locale: L10n.german,
      code: 'DE',
      name: 'Deutsch',
      tagline: 'Die ganze App auf Deutsch', // l10n-ignore: own language
    ),
    LanguageOption(
      locale: L10n.english,
      code: 'EN',
      name: 'English',
      tagline: 'Use the whole app in English',
    ),
  ];

  static LanguageOption of(Locale locale) =>
      all.firstWhere((option) => option.locale == L10n.resolve(locale));
}

/// First start: choose the language before anything else. The texts on this
/// page follow the selection right away, so the person sees the result.
class LanguagePage extends StatefulWidget {
  const LanguagePage({
    required this.initial,
    required this.onChosen,
    super.key,
  });

  final Locale initial;
  final Future<void> Function(Locale locale) onChosen;

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage>
    with SingleTickerProviderStateMixin {
  late Locale _selected = L10n.resolve(widget.initial);
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else if (!_entrance.isAnimating && _entrance.value == 0) {
      unawaited(_entrance.forward());
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _select(Locale locale) {
    if (_busy || locale == _selected) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = locale);
  }

  Future<void> _continue() async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.lightImpact();
    await widget.onChosen(_selected);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final texts = L10n.of(_selected);
    final reduced = MediaQuery.disableAnimationsOf(context);
    final switchDuration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 260);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Rise(
                      animation: _entrance,
                      start: 0,
                      end: 0.45,
                      child: _GlobeMark(animation: _entrance),
                    ),
                    const SizedBox(height: 26),
                    _Rise(
                      animation: _entrance,
                      start: 0.12,
                      end: 0.55,
                      child: Semantics(
                        header: true,
                        child: AnimatedSwitcher(
                          duration: switchDuration,
                          transitionBuilder: _fadeSlide,
                          child: Text(
                            texts.languageTitle,
                            key: ValueKey('title-${_selected.languageCode}'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.6,
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Rise(
                      animation: _entrance,
                      start: 0.2,
                      end: 0.62,
                      child: AnimatedSwitcher(
                        duration: switchDuration,
                        transitionBuilder: _fadeSlide,
                        child: Text(
                          texts.languageSubtitle,
                          key: ValueKey('sub-${_selected.languageCode}'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 15,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    for (final (index, option)
                        in LanguageOption.all.indexed) ...[
                      if (index > 0) const SizedBox(height: 14),
                      _Rise(
                        animation: _entrance,
                        start: 0.32 + index * 0.12,
                        end: 0.78 + index * 0.1,
                        child: LanguageCard(
                          key: Key('language-${option.locale.languageCode}'),
                          option: option,
                          selected: option.locale == _selected,
                          onTap: () => _select(option.locale),
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    _Rise(
                      animation: _entrance,
                      start: 0.6,
                      end: 1,
                      child: FilledButton(
                        key: const Key('language-continue'),
                        onPressed: _busy ? null : _continue,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(58),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: switchDuration,
                          transitionBuilder: _fadeSlide,
                          child: Row(
                            key: ValueKey('cta-${_selected.languageCode}'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  texts.languageContinue,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward_rounded),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _fadeSlide(Widget child, Animation<double> animation) => FadeTransition(
  opacity: animation,
  child: SlideTransition(
    position: Tween(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  ),
);

/// Large tappable card for one language, with an animated check.
class LanguageCard extends StatelessWidget {
  const LanguageCard({
    required this.option,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 260);
    final texts = L10n.of(option.locale);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: selected
          ? texts.languageSelectedSemantics(option.name)
          : option.name,
      excludeSemantics: true,
      child: PressableScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(16, 16, 18, 16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.09)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 26,
                  spreadRadius: -4,
                ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: duration,
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.primary : AppColors.surfaceSoft,
                ),
                child: Text(
                  option.code,
                  style: TextStyle(
                    color: selected ? AppColors.black : AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      option.tagline,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedScale(
                duration: duration,
                curve: Curves.easeOutBack,
                scale: selected ? 1 : 0.6,
                child: AnimatedOpacity(
                  duration: duration,
                  opacity: selected ? 1 : 0,
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 28,
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

/// A globe made of the Lookin ring: the ring draws in once and two small
/// speech marks ("Aa") fade in. No endless motion.
class _GlobeMark extends StatelessWidget {
  const _GlobeMark({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(
            (animation.value / 0.6).clamp(0.0, 1.0),
          );
          return SizedBox(
            width: 96,
            height: 96,
            child: CustomPaint(
              painter: _RingPainter(progress: t),
              child: Center(
                child: Opacity(
                  opacity: Curves.easeOut.transform(
                    ((animation.value - 0.3) / 0.4).clamp(0.0, 1.0),
                  ),
                  child: const Icon(
                    Icons.translate_rounded,
                    color: AppColors.primary,
                    size: 38,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 7.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (progress <= 0) return;
    // Open ring with the gap at the top right, like the app icon.
    const start = -math.pi / 2 + 0.85;
    const fullSweep = 2 * math.pi - 0.75;
    canvas.drawArc(
      rect,
      start,
      fullSweep * progress,
      false,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

/// Fades and lifts a child in during [start]–[end] of [animation].
class _Rise extends StatelessWidget {
  const _Rise({
    required this.animation,
    required this.start,
    required this.end,
    required this.child,
  });

  final Animation<double> animation;
  final double start;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, math.min(end, 1), curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// Profile › Sprache: the same cards in a sheet. The app switches as soon as
/// a card is tapped.
Future<void> showLanguageSheet(BuildContext context) {
  final controller = LocaleScope.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.backgroundRaised,
    builder: (sheetContext) => _LanguageSheet(controller: controller),
  );
}

class _LanguageSheet extends StatefulWidget {
  const _LanguageSheet({required this.controller});

  final LocaleController? controller;

  @override
  State<_LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<_LanguageSheet> {
  late Locale _selected =
      widget.controller?.locale ?? L10n.resolve(Locale(L10n.code));

  Future<void> _pick(Locale locale) async {
    if (locale == _selected) {
      Navigator.of(context).pop();
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selected = locale);
    final reduced = MediaQuery.disableAnimationsOf(context);
    await widget.controller?.choose(locale);
    await Future<void>.delayed(
      reduced ? Duration.zero : const Duration(milliseconds: 320),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final texts = L10n.of(_selected);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                texts.languageSheetTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              texts.languageSheetSubtitle,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            for (final (index, option) in LanguageOption.all.indexed) ...[
              if (index > 0) const SizedBox(height: 12),
              LanguageCard(
                key: Key('language-sheet-${option.locale.languageCode}'),
                option: option,
                selected: option.locale == _selected,
                onTap: () => unawaited(_pick(option.locale)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
