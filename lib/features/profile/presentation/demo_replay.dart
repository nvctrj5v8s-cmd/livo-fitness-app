import 'package:flutter/material.dart';

import '../../../core/data/account_data_repository.dart';
import '../../../core/state/app_controller.dart';
import '../../onboarding/presentation/introduction_page.dart';
import '../../onboarding/presentation/personalization_page.dart';
import '../../subscription/presentation/paywall_page.dart';

/// Only this account sees the "Neu starten" demo entry in the profile.
const demoAccountEmail = 'mohammad.shikho999@icloud.com';

bool isDemoAccountEmail(String? email) =>
    email != null && email.trim().toLowerCase() == demoAccountEmail;

/// Reads the signed-in e-mail without throwing when no backend is configured
/// (demo mode and widget tests run without Supabase).
bool isDemoAccountSignedIn() {
  try {
    return isDemoAccountEmail(AccountDataRepository().currentEmail);
  } catch (_) {
    return false;
  }
}

/// Plays the first-start experience again: introduction, questions, premium
/// offer. It is a pure preview. Nothing is saved, no device marker or account
/// value changes, and the sign-up page is not part of it.
Future<void> showDemoReplay(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const DemoReplayFlow(),
    ),
  );
}

enum _ReplayStep { introduction, questions, premium }

class DemoReplayFlow extends StatefulWidget {
  const DemoReplayFlow({super.key});

  @override
  State<DemoReplayFlow> createState() => _DemoReplayFlowState();
}

class _DemoReplayFlowState extends State<DemoReplayFlow> {
  _ReplayStep _step = _ReplayStep.introduction;

  void _advance() {
    if (!mounted) return;
    switch (_step) {
      case _ReplayStep.introduction:
        setState(() => _step = _ReplayStep.questions);
      case _ReplayStep.questions:
        setState(() => _step = _ReplayStep.premium);
      case _ReplayStep.premium:
        _close();
    }
  }

  void _close() {
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      child: switch (_step) {
        _ReplayStep.introduction => IntroductionPage(
          key: const ValueKey('replay-introduction'),
          onComplete: () async => _advance(),
        ),
        _ReplayStep.questions => PersonalizationPage(
          key: const ValueKey('replay-questions'),
          onComplete: (_) async => _advance(),
          onLater: () async => _advance(),
        ),
        _ReplayStep.premium => PaywallPage(
          key: const ValueKey('replay-premium'),
          subscription: AppScope.of(context).subscription,
          source: PaywallSource.onboarding,
          onClose: _close,
          onActivated: _close,
        ),
      },
    );
  }
}
