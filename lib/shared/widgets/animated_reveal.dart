import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedReveal extends StatefulWidget {
  const AnimatedReveal({
    required this.child,
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Duration delay;

  @override
  State<AnimatedReveal> createState() => _AnimatedRevealState();
}

class _AnimatedRevealState extends State<AnimatedReveal> {
  bool _visible = false;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _delayTimer = Timer(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return widget.child;
    }
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      child: AnimatedScale(
        scale: _visible ? 1 : 0.975,
        alignment: Alignment.topCenter,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutBack,
        child: AnimatedSlide(
          offset: _visible ? Offset.zero : const Offset(0, 0.055),
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}
