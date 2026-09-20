import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/data/ai_coach_service.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage>
    with SingleTickerProviderStateMixin {
  final _composer = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final _service = AiCoachService();
  final List<AiCoachMessage> _messages = [];
  late final AnimationController _pulse;

  bool _sending = false;
  String? _error;
  String? _lastFailedMessage;
  int? _remaining;
  int? _dailyLimit;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
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
    _composer.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _send([String? suggestion]) async {
    if (_sending) return;
    final text = (suggestion ?? _composer.text).trim();
    if (text.isEmpty) return;
    if (text.length > 600) {
      setState(() {
        _error = 'Bitte kürze deine Frage auf höchstens 600 Zeichen.';
      });
      return;
    }

    final previousMessages = List<AiCoachMessage>.of(_messages);
    final controller = AppScope.of(context);
    final coachContext = <String, Object?>{
      'goal': controller.goal,
      'calorie_goal': controller.calorieGoal,
      'calories_today': controller.diaryConsumedCalories,
      'remaining_calories': controller.diaryRemainingCalories,
      'protein_goal': controller.proteinGoal,
      'protein_today': controller.diaryConsumedProtein,
      'carbs_today': controller.diaryConsumedCarbs,
      'fat_today': controller.diaryConsumedFat,
      'nutrition_style': controller.nutritionStyle,
      'allergies': controller.allergies,
      'activity_level': controller.activityLevel,
    };

    _composer.clear();
    _focusNode.unfocus();
    setState(() {
      _messages.add(AiCoachMessage(role: AiCoachRole.user, text: text));
      _sending = true;
      _error = null;
      _lastFailedMessage = null;
    });
    _scrollToEnd();

    try {
      final reply = await _service.send(
        message: text,
        history: previousMessages,
        context: coachContext,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(
          AiCoachMessage(role: AiCoachRole.assistant, text: reply.text),
        );
        _remaining = reply.remaining;
        _dailyLimit = reply.dailyLimit;
      });
    } on AiCoachException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _lastFailedMessage = text;
      });
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _scrollToEnd();
      }
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      unawaited(
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 330),
          curve: Curves.easeOutCubic,
        ),
      );
    });
  }

  void _clearConversation() {
    if (_messages.isEmpty && _error == null) return;
    setState(() {
      _messages.clear();
      _error = null;
      _lastFailedMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 960;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 20,
        title: const _CoachTitle(),
        actions: [
          if (_remaining != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: StatusPill(
                  label: '$_remaining / $_dailyLimit übrig',
                  icon: Icons.bolt_rounded,
                  color: AppColors.mint,
                ),
              ),
            ),
          if (_messages.isNotEmpty)
            IconButton(
              tooltip: 'Chat leeren',
              onPressed: _clearConversation,
              icon: const Icon(Icons.refresh_rounded),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? _WelcomeState(
                        animation: _pulse,
                        onSuggestion: (value) => unawaited(_send(value)),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
                        itemCount: _messages.length + (_sending ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_sending && index == _messages.length) {
                            return const _TypingBubble();
                          }
                          return _AnimatedMessage(
                            key: ValueKey('coach-message-$index'),
                            message: _messages[index],
                          );
                        },
                      ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _error == null
                    ? const SizedBox.shrink()
                    : _ErrorBanner(
                        key: ValueKey(_error),
                        message: _error!,
                        onRetry: _lastFailedMessage == null
                            ? null
                            : () => unawaited(_send(_lastFailedMessage)),
                      ),
              ),
              _Composer(
                controller: _composer,
                focusNode: _focusNode,
                sending: _sending,
                onSend: () => unawaited(_send()),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, compact ? 104 : 18),
                child: const Text(
                  'KI kann Fehler machen · Keine medizinische Beratung',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    height: 1.3,
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
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LIVO Coach',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            Row(
              children: [
                _OnlineDot(),
                SizedBox(width: 5),
                Text(
                  'KI · Ernährung & Fitness',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
              ],
            ),
          ],
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

class _WelcomeState extends StatelessWidget {
  const _WelcomeState({required this.animation, required this.onSuggestion});

  final Animation<double> animation;
  final ValueChanged<String> onSuggestion;

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
      padding: const EdgeInsets.fromLTRB(22, 34, 22, 20),
      child: Column(
        children: [
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
              'Frag nach Mahlzeiten, Rezepten, Nährwerten oder Training. Dein Tagesziel wird dabei berücksichtigt.',
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
        ],
      ),
    );
  }
}

class _CoachOrb extends StatelessWidget {
  const _CoachOrb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
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
            blurRadius: 38,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        color: AppColors.black,
        size: 36,
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

class _AnimatedMessage extends StatelessWidget {
  const _AnimatedMessage({required this.message, super.key});

  final AiCoachMessage message;

  @override
  Widget build(BuildContext context) {
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
      child: _MessageBubble(message: message),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final AiCoachMessage message;

  @override
  Widget build(BuildContext context) {
    final fromUser = message.role == AiCoachRole.user;
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 610),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: fromUser
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primarySoft],
                )
              : null,
          color: fromUser ? null : AppColors.surfaceHigh,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(fromUser ? 20 : 6),
            bottomRight: Radius.circular(fromUser ? 6 : 20),
          ),
          border: fromUser ? null : Border.all(color: AppColors.borderBright),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: fromUser ? AppColors.black : AppColors.text,
            fontSize: 14,
            height: 1.48,
          ),
        ),
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

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat();
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
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
        child: AnimatedBuilder(
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
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      padding: const EdgeInsets.fromLTRB(13, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.error,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.text, fontSize: 12),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('Nochmal'),
            ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.fromLTRB(15, 5, 6, 5),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    enabled: !sending,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 600,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(color: AppColors.text, height: 1.35),
                    decoration: const InputDecoration(
                      hintText: 'Frag deinen Coach …',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  label: 'Nachricht senden',
                  child: IconButton.filled(
                    onPressed: sending ? null : onSend,
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
