import 'dart:async';

import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/age_store.dart';

/// Asks once whether the person is at least 18 (the terms are for adults).
/// "Yes" opens the app; "No" shows a closing page. Nothing is stored for "no".
class AgeGate extends StatefulWidget {
  const AgeGate({
    required this.child,
    this.store = const DeviceAgeStore(),
    super.key,
  });

  final Widget child;
  final AgeStore store;

  @override
  State<AgeGate> createState() => _AgeGateState();
}

enum _Age { loading, ask, denied, confirmed }

class _AgeGateState extends State<AgeGate> {
  _Age _state = _Age.loading;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    var confirmed = false;
    try {
      confirmed = await widget.store.isConfirmed().timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {
      // Storage can be unavailable (private browser): ask again.
    }
    if (mounted) setState(() => _state = confirmed ? _Age.confirmed : _Age.ask);
  }

  Future<void> _yes() async {
    setState(() => _state = _Age.confirmed);
    try {
      await widget.store.confirm().timeout(const Duration(seconds: 2));
    } catch (_) {
      // The question may appear again next time; nothing else is lost.
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_state) {
      _Age.loading => const Scaffold(
        key: ValueKey('age-loading'),
        backgroundColor: AppColors.background,
        body: SizedBox.expand(),
      ),
      _Age.confirmed => KeyedSubtree(
        key: const ValueKey('age-confirmed'),
        child: widget.child,
      ),
      _Age.ask => _AgePage(
        key: const ValueKey('age-ask'),
        title: context.l10n.onboardingAgeGateTitle,
        text: context.l10n.onboardingAgeGateText,
        actions: [
          FilledButton(
            key: const Key('age-yes'),
            onPressed: _yes,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 56)),
            child: Text(context.l10n.onboardingAgeGateYes),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            key: const Key('age-no'),
            onPressed: () => setState(() => _state = _Age.denied),
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
            child: Text(context.l10n.onboardingAgeGateNo),
          ),
        ],
      ),
      _Age.denied => _AgePage(
        key: const ValueKey('age-denied'),
        title: context.l10n.onboardingAgeBlockedTitle,
        text: context.l10n.onboardingAgeBlockedText,
        actions: const [],
      ),
    };
  }
}

class _AgePage extends StatelessWidget {
  const _AgePage({
    required this.title,
    required this.text,
    required this.actions,
    super.key,
  });

  final String title;
  final String text;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  if (actions.isNotEmpty) const SizedBox(height: 28),
                  ...actions,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
