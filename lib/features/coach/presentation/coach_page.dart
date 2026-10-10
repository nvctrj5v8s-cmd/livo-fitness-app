import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image/image.dart' as img;

import '../../consent/presentation/consent_dialogs.dart';
import '../../../core/data/ai_coach_service.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_reveal.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../subscription/domain/subscription_plans.dart';
import '../../subscription/presentation/paywall_page.dart';
import '../../subscription/presentation/premium_widgets.dart';
import '../application/coach_chat_controller.dart';
import '../application/coach_context.dart';
import 'coach_formatted_text.dart';

/// The coach chat is part of Lookin Premium. Free accounts see what it offers
/// and a way to the paywall; the server enforces the same rule.
class CoachPage extends StatelessWidget {
  const CoachPage({super.key, this.service});

  /// Replaceable backend boundary (tests); defaults to the Edge Function.
  final AiCoachService? service;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final subscription = app.subscription;
    final chat = CoachChatController.of(app, service: service);
    if (subscription.hasPremium) return _CoachChat(chat: chat);
    if (!subscription.hasLoaded) {
      if (subscription.loadFailed) {
        // Offline or server problem: never pretend a premium account is free.
        return _CoachUnavailable(
          onRetry: () => unawaited(subscription.load(force: true)),
        );
      }
      return const _CoachLoading();
    }
    return _CoachLocked(
      // Only signed-in accounts can have a stored chat to delete.
      chat: app.personalizationUserId == null ? null : chat,
      canStartTrial: subscription.canStartTrial,
    );
  }
}

/// Asks before the stored chat is deleted for good.
Future<bool> _confirmClearHistory(
  BuildContext context, {
  required bool newChat,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surfaceHigh,
      title: Text(newChat ? 'Neuen Chat beginnen?' : 'Chatverlauf löschen?'),
      content: Text(
        '${newChat ? 'Dafür wird dein bisheriger Chatverlauf' : 'Dein Chatverlauf wird'} '
        'dauerhaft aus deinem Konto gelöscht. Das lässt sich nicht rückgängig '
        'machen. Dein Tageslimit bleibt unverändert.',
        style: const TextStyle(color: AppColors.textMuted, height: 1.45),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          key: const Key('coach-confirm-clear'),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Verlauf löschen'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

class _CoachChat extends StatefulWidget {
  const _CoachChat({required this.chat});

  final CoachChatController chat;

  @override
  State<_CoachChat> createState() => _CoachChatState();
}

class _CoachChatState extends State<_CoachChat>
    with SingleTickerProviderStateMixin {
  final _composer = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final _latestAnswerKey = GlobalKey();

  /// Entries that already played their entrance animation.
  final Set<int> _animated = {};
  late final AnimationController _pulse;
  int? _revealedAnswerId;

  CoachChatController get _chat => widget.chat;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    // Loaded history is shown without animation.
    _animated.addAll(_chat.entries.map((entry) => entry.id));
    _revealedAnswerId = _chat.latestAnswerId;
    _chat.addListener(_onChatChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_chat.ensureHistory());
    });
  }

  @override
  void didUpdateWidget(covariant _CoachChat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chat != widget.chat) {
      oldWidget.chat.removeListener(_onChatChanged);
      widget.chat.addListener(_onChatChanged);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
      _pulse.value = 0;
    } else if (_pulse.value == 0 && !_pulse.isAnimating) {
      _pulse.forward();
    }
  }

  @override
  void dispose() {
    _chat.removeListener(_onChatChanged);
    _composer.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _onChatChanged() {
    if (!mounted) return;
    setState(() {});
    final answerId = _chat.latestAnswerId;
    if (answerId != null && answerId != _revealedAnswerId) {
      _revealedAnswerId = answerId;
      _revealLatestAnswer();
    }
  }

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  Future<void> _send([String? suggestion]) async {
    final text = suggestion ?? _composer.text;
    if (text.trim().isEmpty || !_chat.canSend) return;
    final app = AppScope.of(context);
    if (!await ensureAiConsent(context, app.consent) || !mounted) return;
    if (suggestion == null) _composer.clear();
    _focusNode.unfocus();
    final pending = _chat.send(text, context: coachContextFor(app));
    _jumpToLatest();
    await pending;
    if (!mounted) return;
    _afterRequest(app);
  }

  Future<void> _retry() async {
    final app = AppScope.of(context);
    final pending = _chat.retry(context: coachContextFor(app));
    _jumpToLatest();
    await pending;
    if (mounted) _afterRequest(app);
  }

  /// A trial or subscription that ended on the server: refresh the
  /// entitlement, which switches this tab to the locked state.
  void _afterRequest(AppController app) {
    if (_chat.issue?.kind == CoachIssueKind.premiumRequired) {
      unawaited(app.subscription.load(force: true));
    }
  }

  Future<void> _clearHistory() async {
    if (_chat.busy) return;
    final confirmed = await _confirmClearHistory(context, newChat: true);
    if (!confirmed || !mounted) return;
    _composer.clear();
    await _chat.clearHistory();
  }

  Future<void> _analyzeImage() async {
    if (!_chat.canSend) return;
    final consent = AppScope.of(context).consent;
    if (!await ensureAiConsent(context, consent) || !mounted) return;
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Lebensmittel-Foto',
          extensions: ['jpg', 'jpeg', 'png', 'webp'],
        ),
      ],
    );
    if (file == null) return;

    final sourceBytes = await file.readAsBytes();
    final decoded = img.decodeImage(sourceBytes);
    if (decoded == null) {
      _chat.showIssue('Dieses Bild konnte nicht gelesen werden.');
      return;
    }
    final resized = decoded.width > 1280 || decoded.height > 1280
        ? img.copyResize(
            decoded,
            width: decoded.width >= decoded.height ? 1280 : null,
            height: decoded.height > decoded.width ? 1280 : null,
          )
        : decoded;
    final bytes = Uint8List.fromList(img.encodeJpg(resized, quality: 78));
    if (bytes.length > 4 * 1024 * 1024) {
      _chat.showIssue('Das Foto ist zu groß. Bitte wähle ein kleineres Bild.');
      return;
    }
    if (!mounted) return;
    final app = AppScope.of(context);
    final pending = _chat.analyzePhoto(bytes, context: coachContextFor(app));
    _jumpToLatest();
    await pending;
    if (mounted) _afterRequest(app);
  }

  /// The list is reversed: offset 0 shows the newest message.
  void _jumpToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_reduceMotion) {
        _scrollController.jumpTo(0);
      } else {
        unawaited(
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          ),
        );
      }
    });
  }

  /// Short answers stay at the bottom; a long answer is scrolled so that its
  /// beginning is visible instead of its end.
  void _revealLatestAnswer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final answerContext = _latestAnswerKey.currentContext;
      if (answerContext == null) {
        _jumpToLatest();
        return;
      }
      unawaited(
        Scrollable.ensureVisible(
          answerContext,
          alignment: 1,
          duration: _reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = _chat;
    // On phones the floating navigation reports its height as bottom padding;
    // with the keyboard open the composer then sits right above the keyboard.
    final bottomPadding = math.max(MediaQuery.paddingOf(context).bottom, 8.0);
    final limit = chat.dailyLimit;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 20,
        title: const _CoachTitle(),
        actions: [
          if (limit != null && limit > 0 && chat.remaining != null)
            _QuotaPill(remaining: chat.remaining!, dailyLimit: limit),
          IconButton(
            key: const Key('coach-new-chat'),
            tooltip: 'Neuer Chat (Verlauf löschen)',
            onPressed: chat.hasMessages && !chat.busy
                ? () => unawaited(_clearHistory())
                : null,
            color: AppColors.text,
            disabledColor: AppColors.textMuted.withValues(alpha: 0.5),
            icon: chat.clearing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_comment_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            children: [
              Expanded(child: _buildMessages(chat)),
              AnimatedSwitcher(
                duration: _reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                child: chat.issue == null
                    ? const SizedBox.shrink()
                    : _IssueBanner(
                        key: ValueKey(chat.issue),
                        issue: chat.issue!,
                        busy: chat.busy,
                        onRetry: () => unawaited(_retry()),
                        onPremium: () => unawaited(
                          showPaywall(context, source: PaywallSource.coach),
                        ),
                        onDismiss: chat.dismissIssue,
                      ),
              ),
              _Composer(
                controller: _composer,
                focusNode: _focusNode,
                enabled: chat.canSend,
                sending: chat.sending,
                limitReached: chat.limitReached,
                onSend: () => unawaited(_send()),
                onImage: () => unawaited(_analyzeImage()),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(22, 7, 22, bottomPadding),
                child: _ComposerFooter(controller: _composer),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessages(CoachChatController chat) {
    if (!chat.hasMessages && chat.historyLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 25,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(height: 12),
            Text(
              'Dein Verlauf wird geladen …',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }
    if (!chat.hasMessages) {
      return _WelcomeState(
        animation: _pulse,
        notice: chat.notice,
        onSuggestion: (value) => unawaited(_send(value)),
      );
    }
    final entries = chat.entries;
    final typing = chat.sending ? 1 : 0;
    return ListView.builder(
      key: const Key('coach-messages'),
      controller: _scrollController,
      reverse: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      itemCount: entries.length + typing + 1,
      itemBuilder: (context, index) {
        if (typing == 1 && index == 0) return const _TypingBubble();
        final position = index - typing;
        if (position == entries.length) {
          return _HistoryNote(
            onClear: chat.busy ? null : () => unawaited(_clearHistory()),
          );
        }
        final entry = entries[entries.length - 1 - position];
        final animate =
            entry.fresh && !_reduceMotion && _animated.add(entry.id);
        return KeyedSubtree(
          key: entry.id == chat.latestAnswerId
              ? _latestAnswerKey
              : ValueKey('coach-entry-${entry.id}'),
          child: _AnimatedMessage(entry: entry, animate: animate),
        );
      },
    );
  }
}

class _QuotaPill extends StatelessWidget {
  const _QuotaPill({required this.remaining, required this.dailyLimit});

  final int remaining;
  final int dailyLimit;

  @override
  Widget build(BuildContext context) {
    final label = 'Noch $remaining von $dailyLimit KI-Anfragen heute';
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: Center(
        child: Tooltip(
          message: label,
          child: Semantics(
            label: label,
            excludeSemantics: true,
            child: StatusPill(
              key: const Key('coach-quota'),
              label: '$remaining/$dailyLimit',
              icon: Icons.bolt_rounded,
              color: remaining == 0 ? AppColors.orange : AppColors.mint,
            ),
          ),
        ),
      ),
    );
  }
}

class _CoachTitle extends StatelessWidget {
  const _CoachTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.mint],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: AppColors.black,
          ),
        ),
        const SizedBox(width: 10),
        const Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lookin Coach',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              Row(
                children: [
                  _OnlineDot(),
                  SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      'KI · Ernährung & Fitness',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) => Container(
    width: 6,
    height: 6,
    decoration: const BoxDecoration(
      color: AppColors.mint,
      shape: BoxShape.circle,
    ),
  );
}

class _CoachLoading extends StatelessWidget {
  const _CoachLoading();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      titleSpacing: 20,
      title: const _CoachTitle(),
    ),
    body: const Center(
      child: SizedBox.square(
        dimension: 25,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );
}

/// The premium status could not be read (offline, server problem).
class _CoachUnavailable extends StatelessWidget {
  const _CoachUnavailable({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const Key('coach-unavailable'),
    backgroundColor: Colors.transparent,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      titleSpacing: 20,
      title: const _CoachTitle(),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.textMuted,
              size: 34,
            ),
            const SizedBox(height: 14),
            const Text(
              'Der Coach kann gerade nicht geöffnet werden.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dein Premium-Status konnte nicht geladen werden. Bitte prüfe '
              'deine Internetverbindung.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, height: 1.45),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const Key('coach-subscription-retry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CoachLocked extends StatelessWidget {
  const _CoachLocked({required this.chat, required this.canStartTrial});

  /// Chat of a signed-in account, for deleting a stored history.
  final CoachChatController? chat;
  final bool canStartTrial;

  static const _benefits = [
    (
      Icons.dinner_dining_rounded,
      'Ideen, die zu deinen restlichen Kalorien passen',
    ),
    (
      Icons.fitness_center_rounded,
      'Protein- und Trainingstipps für deinen Alltag',
    ),
    (Icons.photo_camera_rounded, 'Fotos deiner Mahlzeiten einschätzen lassen'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = math.max(MediaQuery.paddingOf(context).bottom, 8.0);
    return Scaffold(
      key: const Key('coach-locked'),
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 20,
        title: const _CoachTitle(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(22, 12, 22, bottomPadding + 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AnimatedReveal(child: _LockedPreview()),
                const SizedBox(height: 28),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 90),
                  child: Column(
                    children: [
                      const PremiumBadge(label: 'Premium-Funktion'),
                      const SizedBox(height: 12),
                      Text(
                        'Dein persönlicher KI-Coach',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Frag nach Mahlzeiten, Nährwerten oder Training – die '
                        'Antworten berücksichtigen dein Ziel und deine '
                        'Tageswerte.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                for (final (i, (icon, label)) in _benefits.indexed) ...[
                  if (i > 0) const SizedBox(height: 10),
                  AnimatedReveal(
                    delay: Duration(milliseconds: 150 + i * 60),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 340),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        key: const Key('coach-unlock-premium'),
                        onPressed: () => unawaited(
                          showPaywall(context, source: PaywallSource.coach),
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                        ),
                        icon: const Icon(Icons.workspace_premium_rounded),
                        label: const Text('Premium freischalten'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        canStartTrial
                            ? '${SubscriptionPlans.trialDays} Tage kostenlos '
                                  'testen · endet automatisch · keine '
                                  'Zahlungsdaten'
                            : 'Deine Testphase ist vorbei. Mit Premium '
                                  'schreibst du weiter mit deinem Coach.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'KI kann Fehler machen · Keine medizinische Beratung',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    height: 1.3,
                  ),
                ),
                if (chat case final chat?) ...[
                  const SizedBox(height: 14),
                  _StoredHistoryDelete(chat: chat),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lets accounts without (or after) premium delete an earlier coach chat.
class _StoredHistoryDelete extends StatelessWidget {
  const _StoredHistoryDelete({required this.chat});

  final CoachChatController chat;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await _confirmClearHistory(context, newChat: false);
    if (confirmed) await chat.clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: chat,
      builder: (context, _) {
        final issue = chat.issue?.retry == CoachRetryAction.clearHistory
            ? chat.issue
            : null;
        return Column(
          children: [
            if (chat.notice case final notice?)
              Text(
                notice,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.mint, fontSize: 12.5),
              )
            else
              TextButton.icon(
                key: const Key('coach-locked-clear-history'),
                onPressed: chat.clearing
                    ? null
                    : () => unawaited(_delete(context)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                ),
                icon: chat.clearing
                    ? const SizedBox.square(
                        dimension: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Gespeicherten Coach-Verlauf löschen'),
              ),
            if (issue != null)
              Text(
                issue.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
          ],
        );
      },
    );
  }
}

/// A clearly labelled example of a coach conversation behind a lock.
class _LockedPreview extends StatelessWidget {
  const _LockedPreview();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Beispiel eines Coach-Gesprächs, mit Premium verfügbar',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(AppColors.surfaceHigh, AppColors.primary, 0.07)!,
              AppColors.surface,
            ],
          ),
          border: Border.all(color: AppColors.borderBright),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                _CoachOrb(size: 30),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Beispiel',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 17),
              ],
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 290),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primarySoft],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                child: const Text(
                  'Was kann ich heute Abend noch essen?',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 330),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      border: Border.all(color: AppColors.borderBright),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                        bottomLeft: Radius.circular(5),
                      ),
                    ),
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Colors.transparent],
                        stops: [0.35, 1],
                      ).createShader(bounds),
                      child: const Text(
                        'Du hast heute noch etwa 650 kcal frei. Wie wäre eine '
                        'Lachs-Bowl mit Reis und Gemüse? Das bringt dir rund '
                        '35 g Protein und hält lange satt.',
                        maxLines: 3,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 13.5,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 6,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Mit Premium',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeState extends StatelessWidget {
  const _WelcomeState({
    required this.animation,
    required this.onSuggestion,
    this.notice,
  });

  final Animation<double> animation;
  final ValueChanged<String> onSuggestion;
  final String? notice;

  static const _suggestions = [
    (
      'Abendessen',
      'Was kann ich heute Abend noch essen?',
      Icons.dinner_dining_rounded,
    ),
    (
      'Mehr Protein',
      'Gib mir eine einfache proteinreiche Idee.',
      Icons.fitness_center_rounded,
    ),
    (
      'Tagesziel',
      'Wie erreiche ich heute sinnvoll mein Kalorienziel?',
      Icons.track_changes_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
      child: Column(
        children: [
          if (notice case final notice?) ...[
            Semantics(
              liveRegion: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.mint,
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      notice,
                      key: const Key('coach-notice'),
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final wave = math.sin(animation.value * math.pi * 2);
              return Transform.translate(
                offset: Offset(0, wave * 3),
                child: Transform.scale(scale: 1 + wave * 0.018, child: child),
              );
            },
            child: const _CoachOrb(),
          ),
          const SizedBox(height: 24),
          Text(
            'Was brauchst du heute?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 9),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 470),
            child: const Text(
              'Frag nach Mahlzeiten, Rezepten, Nährwerten oder Training. Dein '
              'Ziel und deine heutigen Werte werden dabei berücksichtigt.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, height: 1.45),
            ),
          ),
          const SizedBox(height: 28),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 9,
              runSpacing: 9,
              children: [
                for (final suggestion in _suggestions)
                  _SuggestionChip(
                    label: suggestion.$1,
                    icon: suggestion.$3,
                    onTap: () => onSuggestion(suggestion.$2),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _ScopeNote(),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 470),
            child: const Text(
              'Mit jeder Frage gehen dein Ziel, deine Tagesziele, heutigen '
              'Tageswerte, Ernährungsstil, Allergien und Aktivität an den '
              'KI-Dienst – nicht dein Name. Der Chat wird in deinem Konto '
              'gespeichert und lässt sich jederzeit löschen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachOrb extends StatelessWidget {
  const _CoachOrb({this.size = 92});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.mint],
        ),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: size * 0.41,
            spreadRadius: size * 0.02,
          ),
        ],
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        color: AppColors.black,
        size: size * 0.39,
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      borderRadius: 18,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderBright),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 17),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScopeNote extends StatelessWidget {
  const _ScopeNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mint.withValues(alpha: 0.13)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, color: AppColors.mint, size: 16),
          SizedBox(width: 7),
          Flexible(
            child: Text(
              'Fokussiert auf Ernährung, Fitness und gesunden Alltag',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

/// Top of the conversation: where the history lives and how to delete it.
class _HistoryNote extends StatelessWidget {
  const _HistoryNote({required this.onClear});

  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: AppColors.textMuted,
                size: 14,
              ),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Dein Verlauf ist in deinem Konto gespeichert – höchstens '
                  'die letzten ${CoachChatController.historyMessageLimit} '
                  'Nachrichten der letzten '
                  '${CoachChatController.historyRetentionDays} Tage.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          TextButton(
            key: const Key('coach-clear-history-inline'),
            onPressed: onClear,
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Verlauf löschen'),
          ),
        ],
      ),
    );
  }
}

class _AnimatedMessage extends StatelessWidget {
  const _AnimatedMessage({required this.entry, required this.animate});

  final CoachChatEntry entry;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final bubble = _MessageBubble(entry: entry);
    if (!animate) return bubble;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 310),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: child,
        ),
      ),
      child: bubble,
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.entry});

  final CoachChatEntry entry;

  @override
  Widget build(BuildContext context) {
    final fromUser = entry.fromUser;
    const assistantStyle = TextStyle(
      color: AppColors.text,
      fontSize: 14,
      height: 1.48,
    );
    return Semantics(
      container: true,
      label: fromUser
          ? (entry.failed ? 'Deine Frage, nicht gesendet' : 'Deine Frage')
          : 'Antwort vom Coach',
      child: Column(
        crossAxisAlignment: fromUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 610),
            margin: EdgeInsets.only(
              bottom: entry.failed ? 4 : 12,
              left: fromUser ? 36 : 0,
              right: fromUser ? 0 : 20,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              gradient: fromUser && !entry.failed
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primarySoft],
                    )
                  : null,
              color: fromUser
                  ? (entry.failed ? AppColors.surfaceSoft : null)
                  : AppColors.surfaceHigh,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(fromUser ? 20 : 6),
                bottomRight: Radius.circular(fromUser ? 6 : 20),
              ),
              border: fromUser && !entry.failed
                  ? null
                  : Border.all(
                      color: entry.failed
                          ? AppColors.error.withValues(alpha: 0.45)
                          : AppColors.borderBright,
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: fromUser
                ? Text(
                    entry.text,
                    style: TextStyle(
                      color: entry.failed ? AppColors.text : AppColors.black,
                      fontSize: 14,
                      height: 1.48,
                    ),
                  )
                : CoachFormattedText(entry.text, style: assistantStyle),
          ),
          if (entry.failed)
            const Padding(
              padding: EdgeInsets.only(bottom: 12, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 14,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Nicht gesendet',
                    style: TextStyle(color: AppColors.error, fontSize: 11.5),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  Timer? _slowTimer;
  bool _slow = false;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _slowTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) setState(() => _slow = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only moves while an answer is on its way, never with reduced motion.
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation
        ..stop()
        ..value = 0.5;
    } else if (!_animation.isAnimating) {
      unawaited(_animation.repeat());
    }
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Der Coach schreibt eine Antwort',
      excludeSemantics: true,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          key: const Key('coach-typing'),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(6),
            ),
            border: Border.all(color: AppColors.borderBright),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final phase = (_animation.value - index * 0.16) % 1.0;
                    final lift = math.sin(phase * math.pi).clamp(0.0, 1.0);
                    return Transform.translate(
                      offset: Offset(0, -3 * lift),
                      child: Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            AppColors.textMuted,
                            AppColors.primary,
                            lift,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  _slow
                      ? 'Das dauert etwas länger als sonst …'
                      : 'Coach schreibt …',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
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

class _IssueBanner extends StatelessWidget {
  const _IssueBanner({
    required this.issue,
    required this.busy,
    required this.onRetry,
    required this.onPremium,
    required this.onDismiss,
    super.key,
  });

  final CoachChatIssue issue;
  final bool busy;
  final VoidCallback onRetry;
  final VoidCallback onPremium;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final limit = issue.kind == CoachIssueKind.dailyLimit;
    final color = limit ? AppColors.orange : AppColors.error;
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const Key('coach-issue'),
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 10),
        padding: const EdgeInsets.fromLTRB(13, 0, 2, 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        // The action sits on its own line so long messages and large text
        // never squeeze the message into a narrow column.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Icon(
                    switch (issue.kind) {
                      CoachIssueKind.dailyLimit =>
                        Icons.hourglass_bottom_rounded,
                      CoachIssueKind.network => Icons.wifi_off_rounded,
                      CoachIssueKind.premiumRequired =>
                        Icons.lock_outline_rounded,
                      _ => Icons.info_outline_rounded,
                    },
                    color: color,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    child: Text(
                      issue.message,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Hinweis schließen',
                  onPressed: onDismiss,
                  color: AppColors.textMuted,
                  iconSize: 18,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            if (issue.canRetry || issue.kind == CoachIssueKind.premiumRequired)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: issue.canRetry
                      ? TextButton.icon(
                          key: const Key('coach-retry'),
                          onPressed: busy ? null : onRetry,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Erneut versuchen'),
                        )
                      : TextButton.icon(
                          key: const Key('coach-premium'),
                          onPressed: onPremium,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          icon: const Icon(
                            Icons.workspace_premium_rounded,
                            size: 18,
                          ),
                          label: const Text('Premium ansehen'),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.sending,
    required this.limitReached,
    required this.onSend,
    required this.onImage,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final bool sending;
  final bool limitReached;
  final VoidCallback onSend;
  final VoidCallback onImage;

  @override
  Widget build(BuildContext context) {
    final hint = limitReached
        ? 'Tageslimit erreicht – morgen geht es weiter'
        : sending
        ? 'Der Coach antwortet …'
        : 'Frag deinen Coach …';
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.borderBright, AppColors.border],
          ),
          borderRadius: BorderRadius.circular(23),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.26),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Container(
            padding: const EdgeInsets.fromLTRB(4, 5, 6, 5),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  key: const Key('coach-photo'),
                  tooltip: 'Lebensmittel-Foto analysieren',
                  onPressed: enabled ? onImage : null,
                  color: AppColors.mint,
                  disabledColor: AppColors.textMuted,
                  icon: const Icon(Icons.photo_camera_outlined),
                ),
                Expanded(
                  child: TextField(
                    key: const Key('coach-input'),
                    controller: controller,
                    focusNode: focusNode,
                    enabled: enabled,
                    minLines: 1,
                    maxLines: 5,
                    maxLength: CoachChatController.maxMessageLength,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.send,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(color: AppColors.text, height: 1.35),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    final canSend = enabled && value.text.trim().isNotEmpty;
                    return IconButton.filled(
                      key: const Key('coach-send'),
                      tooltip: 'Nachricht senden',
                      onPressed: canSend ? onSend : null,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.surfaceSoft,
                        foregroundColor: AppColors.black,
                        disabledForegroundColor: AppColors.textMuted,
                        fixedSize: const Size(44, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textMuted,
                              ),
                            )
                          : const Icon(Icons.arrow_upward_rounded),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Disclaimer and the character counter of the composer.
class _ComposerFooter extends StatelessWidget {
  const _ComposerFooter({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    const max = CoachChatController.maxMessageLength;
    return Row(
      children: [
        const Expanded(
          child: Text(
            'KI kann Fehler machen · Werte sind Schätzungen · Keine '
            'medizinische Beratung',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10.5,
              height: 1.3,
            ),
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final length = value.text.characters.length;
            if (length == 0) return const SizedBox.shrink();
            final nearLimit = length >= max - 50;
            return Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Semantics(
                label: 'Noch ${max - length} von $max Zeichen frei',
                excludeSemantics: true,
                child: Text(
                  '$length/$max',
                  key: const Key('coach-counter'),
                  style: TextStyle(
                    color: nearLimit ? AppColors.orange : AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: nearLimit ? FontWeight.w800 : FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
