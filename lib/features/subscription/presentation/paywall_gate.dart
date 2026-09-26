import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../data/paywall_store.dart';
import 'paywall_page.dart';

/// Shows the LIVO Premium paywall once per account and device after the
/// personalization. Premium accounts skip it; it can always be closed.
class PaywallGate extends StatefulWidget {
  const PaywallGate({
    required this.child,
    this.store = const DevicePaywallStore(),
    super.key,
  });

  final Widget child;
  final PaywallStore store;

  @override
  State<PaywallGate> createState() => _PaywallGateState();
}

class _PaywallGateState extends State<PaywallGate> {
  bool _started = false;
  bool? _showPaywall;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final controller = AppScope.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_decide(controller));
    });
  }

  Future<void> _decide(AppController controller) async {
    final userId = controller.personalizationUserId;
    final subscription = controller.subscription;
    if (userId == null) {
      setState(() => _showPaywall = false);
      return;
    }
    var seen = false;
    try {
      seen = await widget.store
          .hasSeen(userId)
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      // Storage unavailable (e.g. private browser): decide from entitlement.
    }
    if (!mounted) return;
    if (seen) {
      setState(() => _showPaywall = false);
      unawaited(subscription.load());
      return;
    }
    await subscription.load();
    if (!mounted) return;
    if (subscription.loadFailed) {
      // Offline or server problem: never block the app; retry next launch.
      setState(() => _showPaywall = false);
      return;
    }
    final show = !subscription.hasPremium;
    if (!show) unawaited(_remember(userId));
    setState(() => _showPaywall = show);
  }

  Future<void> _remember(String userId) async {
    try {
      await widget.store.markSeen(userId).timeout(const Duration(seconds: 2));
    } catch (_) {
      // The paywall may appear once more on the next launch; the app stays open.
    }
  }

  void _finish() {
    final userId = AppScope.of(context).personalizationUserId;
    setState(() => _showPaywall = false);
    if (userId != null) unawaited(_remember(userId));
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      child: switch (_showPaywall) {
        null => const Scaffold(
          key: ValueKey('paywall-gate-loading'),
          backgroundColor: AppColors.background,
          body: Center(child: Text('Dein LIVO wird vorbereitet …')),
        ),
        true => KeyedSubtree(
          key: const ValueKey('paywall-gate-offer'),
          child: PaywallPage(
            subscription: AppScope.of(context).subscription,
            source: PaywallSource.onboarding,
            onClose: _finish,
            onActivated: _finish,
          ),
        ),
        false => KeyedSubtree(
          key: const ValueKey('paywall-gate-app'),
          child: widget.child,
        ),
      },
    );
  }
}
