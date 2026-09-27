import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../../core/models/app_models.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/recipe_serving.dart';
import 'recipe_detail_sections.dart' show ProTipBox, StepNumber;
import 'recipe_format.dart';

/// Opens the full-screen cook mode (Plus). Returns `true` when the user
/// finished the last step.
Future<bool?> openCookMode(
  BuildContext context, {
  required Recipe recipe,
  RecipePremiumDetails? details,
  double? portions,
  int initialStep = 0,
}) {
  final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  final page = CookModePage(
    recipe: recipe,
    details: details,
    portions: portions,
    initialStep: initialStep,
  );
  return Navigator.of(context).push<bool>(
    reduceMotion
        ? PageRouteBuilder<bool>(
            fullscreenDialog: true,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (_, _, _) => page,
          )
        : MaterialPageRoute<bool>(fullscreenDialog: true, builder: (_) => page),
  );
}

/// Countdown for one step. Uses the wall clock, so it stays correct when a
/// browser tab throttles timers in the background.
class _StepTimer {
  _StepTimer(this.total) : _remaining = total;

  final Duration total;
  Duration _remaining;
  DateTime? _endsAt;
  bool finished = false;

  bool get running => _endsAt != null;
  bool get pristine => !running && !finished && _remaining == total;

  Duration remaining(DateTime now) {
    final endsAt = _endsAt;
    if (endsAt == null) return _remaining;
    final left = endsAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  void start(DateTime now) {
    if (finished) {
      _remaining = total;
      finished = false;
    }
    _endsAt = now.add(_remaining);
  }

  void pause(DateTime now) {
    if (!running) return;
    _remaining = remaining(now);
    _endsAt = null;
  }

  void reset() {
    _remaining = total;
    _endsAt = null;
    finished = false;
  }

  /// Marks the timer as finished once its time is up.
  bool complete(DateTime now) {
    if (!running || remaining(now) > Duration.zero) return false;
    _endsAt = null;
    _remaining = Duration.zero;
    finished = true;
    return true;
  }
}

/// One step per page with large text, the Plus tip and a real countdown per
/// step. All timers stop when the page is closed.
class CookModePage extends StatefulWidget {
  const CookModePage({
    required this.recipe,
    this.details,
    this.portions,
    this.initialStep = 0,
    this.clock,
    super.key,
  });

  final Recipe recipe;
  final RecipePremiumDetails? details;

  /// Portions for the ingredient overview; defaults to the recipe's own.
  final double? portions;
  final int initialStep;

  /// Time source, replaceable in tests.
  final DateTime Function()? clock;

  @override
  State<CookModePage> createState() => _CookModePageState();
}

class _CookModePageState extends State<CookModePage> {
  late final PageController _pages;
  late int _index;
  final Map<int, _StepTimer> _timers = {};
  Timer? _ticker;

  List<RecipeStep> get _steps => widget.recipe.steps;
  DateTime _now() => (widget.clock ?? DateTime.now)();
  bool get _anyRunning => _timers.values.any((timer) => timer.running);
  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialStep.clamp(0, math.max(0, _steps.length - 1));
    _pages = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pages.dispose();
    super.dispose();
  }

  _StepTimer? _timerFor(int index) {
    if (index < 0 || index >= _steps.length) return null;
    final minutes = _steps[index].minutes;
    if (minutes <= 0) return null;
    return _timers.putIfAbsent(
      index,
      () => _StepTimer(Duration(minutes: minutes)),
    );
  }

  void _toggleTimer(int index) {
    final timer = _timerFor(index);
    if (timer == null) return;
    setState(() {
      if (timer.running) {
        timer.pause(_now());
      } else {
        timer.start(_now());
      }
    });
    _syncTicker();
  }

  void _resetTimer(int index) {
    setState(() => _timers[index]?.reset());
    _syncTicker();
  }

  void _syncTicker() {
    if (_anyRunning) {
      _ticker ??= Timer.periodic(
        const Duration(milliseconds: 500),
        (_) => _tick(),
      );
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  void _tick() {
    if (!mounted) return;
    final now = _now();
    final done = [
      for (final entry in _timers.entries)
        if (entry.value.complete(now)) entry.key,
    ];
    setState(() {});
    for (final index in done) {
      _alertFinished(index);
    }
    _syncTicker();
  }

  void _alertFinished(int index) {
    unawaited(HapticFeedback.heavyImpact());
    unawaited(SystemSound.play(SystemSoundType.alert));
    final message = 'Die Zeit für Schritt ${index + 1} ist um.';
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        message,
        TextDirection.ltr,
        assertiveness: Assertiveness.assertive,
      ),
    );
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: index == _index
            ? null
            : SnackBarAction(label: 'Zeigen', onPressed: () => _goTo(index)),
      ),
    );
  }

  void _stopTimers() {
    _ticker?.cancel();
    _ticker = null;
    final now = _now();
    for (final timer in _timers.values) {
      timer.pause(now);
    }
  }

  void _goTo(int index) {
    if (!mounted || index < 0 || index >= _steps.length) return;
    if (_reduceMotion || !_pages.hasClients) {
      _pages.jumpToPage(index);
    } else {
      unawaited(
        _pages.animateToPage(
          index,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  void _finish() {
    _stopTimers();
    Navigator.of(context).pop(true);
  }

  Future<void> _confirmClose() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: const Text('Kochmodus beenden?'),
        content: const Text('Laufende Timer werden dabei gestoppt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Weiterkochen'),
          ),
          FilledButton(
            key: const Key('cook-leave-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Beenden'),
          ),
        ],
      ),
    );
    if (leave != true || !mounted) return;
    _stopTimers();
    Navigator.of(context).pop(false);
  }

  void _showIngredients() {
    final portions = widget.portions ?? basePortions(widget.recipe);
    final items = scaleIngredients(widget.recipe, portions);
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) => ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.82,
          ),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Zutaten',
                                style: Theme.of(
                                  sheetContext,
                                ).textTheme.headlineMedium,
                              ),
                              Text(
                                'für ${portionsLabel(portions)}',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          tooltip: 'Schließen',
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, index) =>
                            _CookIngredientRow(ingredient: items[index]),
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

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    final total = steps.length;
    final now = _now();
    final last = _index >= total - 1;
    final others = [
      for (final entry in _timers.entries)
        if (entry.key != _index &&
            (entry.value.running || entry.value.finished))
          entry,
    ]..sort((a, b) => a.key.compareTo(b.key));

    return PopScope<bool>(
      canPop: !_anyRunning,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmClose());
      },
      child: CallbackShortcuts(
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
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          key: const Key('cook-close'),
                          tooltip: 'Kochmodus beenden',
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kochmodus · ${widget.recipe.title}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12.5,
                                ),
                              ),
                              Text(
                                total == 0
                                    ? 'Keine Schritte'
                                    : 'Schritt ${_index + 1} von $total',
                                key: const Key('cook-progress-label'),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        if (widget.recipe.ingredients.isNotEmpty)
                          IconButton(
                            key: const Key('cook-ingredients'),
                            tooltip: 'Zutaten anzeigen',
                            onPressed: _showIngredients,
                            icon: const Icon(
                              Icons.format_list_bulleted_rounded,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (total > 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                      child: ExcludeSemantics(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: (_index + 1) / total,
                            minHeight: 6,
                            color: AppColors.primary,
                            backgroundColor: AppColors.surfaceHigh,
                          ),
                        ),
                      ),
                    ),
                  if (others.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          for (final entry in others)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                avatar: Icon(
                                  entry.value.running
                                      ? Icons.timer_outlined
                                      : Icons.alarm_on_rounded,
                                  size: 17,
                                  color: entry.value.running
                                      ? AppColors.orange
                                      : AppColors.primary,
                                ),
                                label: Text(
                                  entry.value.running
                                      ? 'Schritt ${entry.key + 1} · '
                                            '${formatCountdown(entry.value.remaining(now))}'
                                      : 'Schritt ${entry.key + 1} · Zeit ist um',
                                ),
                                tooltip: 'Zu Schritt ${entry.key + 1}',
                                backgroundColor: AppColors.surfaceHigh,
                                side: const BorderSide(
                                  color: AppColors.borderBright,
                                ),
                                labelStyle: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w700,
                                ),
                                onPressed: () => _goTo(entry.key),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: total == 0
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Für dieses Rezept ist noch keine Anleitung '
                                'hinterlegt.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : PageView.builder(
                            controller: _pages,
                            itemCount: total,
                            onPageChanged: (index) =>
                                setState(() => _index = index),
                            itemBuilder: (context, index) {
                              final timer = _timerFor(index);
                              return _CookStepView(
                                key: ValueKey('cook-step-$index'),
                                index: index,
                                step: steps[index],
                                tip: widget.details?.tipForStep(index) ?? '',
                                timer: timer,
                                now: now,
                                onToggleTimer: () => _toggleTimer(index),
                                onResetTimer: () => _resetTimer(index),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Center(
                      heightFactor: 1,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                key: const Key('cook-previous'),
                                onPressed: _index > 0
                                    ? () => _goTo(_index - 1)
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 56),
                                  foregroundColor: AppColors.text,
                                  side: const BorderSide(
                                    color: AppColors.borderBright,
                                  ),
                                ),
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: const Text('Zurück'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                key: const Key('cook-next'),
                                onPressed: total == 0
                                    ? null
                                    : last
                                    ? _finish
                                    : () => _goTo(_index + 1),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(0, 56),
                                ),
                                iconAlignment: IconAlignment.end,
                                icon: Icon(
                                  last
                                      ? Icons.check_rounded
                                      : Icons.arrow_forward_rounded,
                                ),
                                label: Text(last ? 'Fertig' : 'Weiter'),
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
        ),
      ),
    );
  }
}

class _CookStepView extends StatelessWidget {
  const _CookStepView({
    required this.index,
    required this.step,
    required this.tip,
    required this.timer,
    required this.now,
    required this.onToggleTimer,
    required this.onResetTimer,
    super.key,
  });

  final int index;
  final RecipeStep step;
  final String tip;
  final _StepTimer? timer;
  final DateTime now;
  final VoidCallback onToggleTimer;
  final VoidCallback onResetTimer;

  @override
  Widget build(BuildContext context) {
    final title = step.title?.trim() ?? '';
    final stepTimer = timer;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StepNumber(number: index + 1, size: 44),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title.isEmpty ? 'Schritt ${index + 1}' : title,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 26,
                          height: 1.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                step.text,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (stepTimer != null) ...[
                const SizedBox(height: 24),
                _TimerPanel(
                  timer: stepTimer,
                  now: now,
                  onToggle: onToggleTimer,
                  onReset: onResetTimer,
                ),
              ],
              if (tip.isNotEmpty) ...[
                const SizedBox(height: 22),
                ProTipBox(tip: tip, large: true),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerPanel extends StatelessWidget {
  const _TimerPanel({
    required this.timer,
    required this.now,
    required this.onToggle,
    required this.onReset,
  });

  final _StepTimer timer;
  final DateTime now;
  final VoidCallback onToggle;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final remaining = timer.remaining(now);
    final fraction = timer.total.inMilliseconds == 0
        ? 0.0
        : (remaining.inMilliseconds / timer.total.inMilliseconds).clamp(
            0.0,
            1.0,
          );
    final (
      IconData statusIcon,
      String status,
      Color statusColor,
    ) = timer.finished
        ? (Icons.check_circle_rounded, 'Zeit ist um!', AppColors.primary)
        : timer.running
        ? (Icons.timelapse_rounded, 'Läuft', AppColors.orange)
        : timer.pristine
        ? (
            Icons.timer_outlined,
            'Timer · ${formatMinutes(timer.total.inMinutes)}',
            AppColors.textMuted,
          )
        : (Icons.pause_circle_outline_rounded, 'Pausiert', AppColors.textMuted);
    final (IconData actionIcon, String actionLabel) = timer.running
        ? (Icons.pause_rounded, 'Pausieren')
        : timer.finished
        ? (Icons.replay_rounded, 'Neu starten')
        : timer.pristine
        ? (Icons.play_arrow_rounded, 'Timer starten')
        : (Icons.play_arrow_rounded, 'Fortsetzen');
    return Container(
      key: const Key('cook-timer'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: timer.finished ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: CircularProgressIndicator(
                      value: fraction,
                      strokeWidth: 7,
                      color: timer.finished
                          ? AppColors.primary
                          : AppColors.orange,
                      backgroundColor: AppColors.surfaceHigh,
                    ),
                  ),
                ),
                Semantics(
                  label: 'Verbleibende Zeit: ${spokenDuration(remaining)}',
                  child: ExcludeSemantics(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          formatCountdown(remaining),
                          key: const Key('cook-timer-value'),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, size: 19, color: statusColor),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      key: const Key('cook-timer-toggle'),
                      onPressed: onToggle,
                      icon: Icon(actionIcon),
                      label: Text(actionLabel),
                    ),
                    if (!timer.pristine)
                      TextButton.icon(
                        key: const Key('cook-timer-reset'),
                        onPressed: onReset,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(44, 54),
                        ),
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Zurücksetzen'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CookIngredientRow extends StatelessWidget {
  const _CookIngredientRow({required this.ingredient});

  final ScaledIngredient ingredient;

  @override
  Widget build(BuildContext context) {
    final measure = ingredient.measure;
    final note = ingredient.note;
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (note != null)
                    Text(
                      note,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  measure ?? ingredient.gramsLabel,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (measure != null)
                  Text(
                    ingredient.gramsLabel,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
