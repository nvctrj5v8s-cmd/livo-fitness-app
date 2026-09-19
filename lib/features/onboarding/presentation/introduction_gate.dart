import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/introduction_store.dart';
import 'introduction_page.dart';

class IntroductionGate extends StatefulWidget {
  const IntroductionGate({
    required this.child,
    this.store = const DeviceIntroductionStore(),
    super.key,
  });

  final Widget child;
  final IntroductionStore store;

  @override
  State<IntroductionGate> createState() => _IntroductionGateState();
}

class _IntroductionGateState extends State<IntroductionGate> {
  bool? _complete;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    var complete = false;
    try {
      complete = await widget.store.isComplete().timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {
      // Storage can be unavailable in a private browser; keep entry usable.
    }
    if (mounted) setState(() => _complete = complete);
  }

  Future<void> _finish() async {
    if (_saving || _complete == true) return;
    setState(() => _saving = true);
    var saved = true;
    try {
      await widget.store.complete().timeout(const Duration(seconds: 2));
    } catch (_) {
      saved = false;
    }
    if (!mounted) return;
    setState(() => _complete = true);
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Die Einführung erscheint beim nächsten Start eventuell erneut.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      child: switch (_complete) {
        null => Scaffold(
          key: const ValueKey('introduction-loading'),
          backgroundColor: AppColors.background,
          body: Center(
            child: Semantics(
              label: 'LIVO wird geöffnet',
              child: const Text(
                'livo.',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 42,
                  letterSpacing: -2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        false => IntroductionPage(
          key: const ValueKey('introduction'),
          onComplete: _finish,
          busy: _saving,
        ),
        true => KeyedSubtree(
          key: const ValueKey('application'),
          child: widget.child,
        ),
      },
    );
  }
}
