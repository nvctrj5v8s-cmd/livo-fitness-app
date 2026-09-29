import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../application/planning_controller.dart';

/// Building blocks shared by the week plan, shopping list and pantry sheets.

bool kitchenReduceMotion(BuildContext context) =>
    MediaQuery.maybeOf(context)?.disableAnimations ?? false;

/// [duration], or zero when the system asks for less motion.
Duration kitchenMotion(BuildContext context, Duration duration) =>
    kitchenReduceMotion(context) ? Duration.zero : duration;

Future<bool> confirmKitchenAction(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.black,
          ),
          child: Text(action),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// Sheet with a title, an optional pinned [top] area (input, week switcher,
/// feedback), a lazily built list and an optional pinned [bottom] bar. On
/// short screens or with large text the top area scrolls together with the
/// list so nothing overflows.
class KitchenSheetFrame extends StatelessWidget {
  const KitchenSheetFrame({
    required this.title,
    required this.subtitle,
    required this.children,
    this.top,
    this.bottom,
    this.headerTrailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? top;
  final Widget? bottom;

  /// Extra actions next to the close button, for example a menu.
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    final height = math.min(MediaQuery.sizeOf(context).height * 0.9, 760.0);
    final compact =
        height < 560 || MediaQuery.textScalerOf(context).scale(10) > 13;
    final subtitleText = AnimatedSwitcher(
      duration: kitchenMotion(context, const Duration(milliseconds: 220)),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.centerLeft,
        children: [...previous, ?current],
      ),
      child: Text(
        subtitle,
        key: ValueKey(subtitle),
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
    );
    // On small screens or with large text only the title row stays pinned;
    // subtitle and top area scroll with the list so it keeps enough room.
    final list = ListView(
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        if (compact) ...[subtitleText, const SizedBox(height: 12)],
        if (compact && top != null) ...[top!, const SizedBox(height: 14)],
        ...children,
      ],
    );
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: compact
                                ? Theme.of(context).textTheme.titleLarge
                                : Theme.of(context).textTheme.headlineMedium,
                          ),
                          if (!compact) ...[
                            const SizedBox(height: 3),
                            subtitleText,
                          ],
                        ],
                      ),
                    ),
                    ?headerTrailing,
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Schließen',
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                if (!compact && top != null) ...[
                  const SizedBox(height: 14),
                  top!,
                ],
                SizedBox(height: compact ? 8 : 14),
                Expanded(child: list),
                ?bottom,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Loading state and load/save problems of the kitchen lists.
class KitchenStorageStatus extends StatelessWidget {
  const KitchenStorageStatus({
    required this.planning,
    this.showNote = true,
    super.key,
  });

  final PlanningController planning;

  /// Whether the note about where the lists are stored is included. Sheets
  /// that show [KitchenStorageNote] elsewhere turn it off.
  final bool showNote;

  @override
  Widget build(BuildContext context) {
    final loadError = planning.loadError;
    final saveError = planning.saveError;
    final hasProblem =
        planning.loading || loadError != null || saveError != null;
    if (!showNote && !hasProblem) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (planning.loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Expanded(child: Text('Deine Listen werden geladen …')),
                ],
              ),
            ),
          if (loadError != null)
            _ErrorBox(
              text: loadError,
              actions: [
                TextButton(
                  onPressed: () => unawaited(planning.load()),
                  child: const Text('Erneut versuchen'),
                ),
                TextButton(
                  key: const Key('kitchen-reset'),
                  onPressed: () async {
                    final confirmed = await confirmKitchenAction(
                      context,
                      title: 'Gespeicherte Listen zurücksetzen?',
                      body:
                          'Wochenplan, Einkaufsliste und Vorräte dieses Kontos '
                          'werden auf diesem Gerät gelöscht.',
                      action: 'Zurücksetzen',
                    );
                    if (confirmed) unawaited(planning.clearAll());
                  },
                  child: const Text('Zurücksetzen'),
                ),
              ],
            ),
          if (saveError != null) _ErrorBox(text: saveError),
          if (showNote) KitchenStorageNote(planning: planning),
        ],
      ),
    );
  }
}

/// Honest note about where the lists are kept.
class KitchenStorageNote extends StatelessWidget {
  const KitchenStorageNote({required this.planning, super.key});

  final PlanningController planning;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          planning.persistent
              ? Icons.phone_android_rounded
              : Icons.info_outline_rounded,
          size: 16,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            planning.persistent
                ? 'Nur auf diesem Gerät gespeichert – nicht in der Cloud '
                      'und nicht auf deinen anderen Geräten.'
                : 'Ohne Konto gilt diese Liste nur bis zum Neustart der '
                      'App.',
            key: const Key('kitchen-storage-note'),
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.text, this.actions = const []});

  final String text;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 19,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
        if (actions.isNotEmpty) Wrap(spacing: 4, children: actions),
        if (actions.isEmpty) const SizedBox(height: 4),
      ],
    ),
  );
}

/// Result of the last action, read out by screen readers.
class KitchenFeedback extends StatelessWidget {
  const KitchenFeedback({
    required this.text,
    this.color = AppColors.primary,
    super.key,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Semantics(
      liveRegion: true,
      child: Text(
        text,
        key: const Key('kitchen-feedback'),
        style: TextStyle(color: color, fontSize: 13),
      ),
    ),
  );
}

/// Fades and grows a newly shown entry into place once. With reduced motion
/// or [animate] off it shows the child right away.
class KitchenAppear extends StatefulWidget {
  const KitchenAppear({
    required this.child,
    this.animate = true,
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final bool animate;
  final Duration delay;

  @override
  State<KitchenAppear> createState() => _KitchenAppearState();
}

class _KitchenAppearState extends State<KitchenAppear>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 320);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration + widget.delay,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      widget.delay.inMicroseconds / (_duration + widget.delay).inMicroseconds,
      1,
      curve: Curves.easeOutCubic,
    ),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!widget.animate || kitchenReduceMotion(context)) {
      _controller.value = 1;
    } else {
      unawaited(_controller.forward());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _curve,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: _curve,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.18),
            end: Offset.zero,
          ).animate(_curve),
          child: widget.child,
        ),
      ),
    );
  }
}
