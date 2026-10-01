import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_page.dart';
import '../data/personalization_store.dart';
import '../domain/personalization_profile.dart';
import 'personalization_page.dart';

/// "Questions first": new people answer the questions before they see the
/// sign-up, like most nutrition apps do. The answers stay on this device
/// until an account exists; `PersonalizationGate` then moves them into it.
///
/// Signed in → [child]. Signed out on a device that already had an account,
/// or after "Schon ein Konto? Anmelden" → the sign-in right away.
class QuestionsFirstGate extends StatefulWidget {
  const QuestionsFirstGate({
    required this.child,
    this.pending = const DevicePendingPersonalizationStore(),
    this.isSignedIn,
    this.authChanges,
    super.key,
  });

  final Widget child;
  final PendingPersonalizationStore pending;

  /// Overridable for tests; defaults to the Supabase session.
  final bool Function()? isSignedIn;
  final Stream<Object?>? authChanges;

  @override
  State<QuestionsFirstGate> createState() => _QuestionsFirstGateState();
}

class _QuestionsFirstGateState extends State<QuestionsFirstGate> {
  PersonalizationRecord _record = const PersonalizationRecord();
  bool _accountSeen = false;
  bool _loaded = false;
  bool _wantsSignIn = false;
  bool _editing = false;
  StreamSubscription<Object?>? _authSubscription;

  bool get _signedIn =>
      widget.isSignedIn?.call() ??
      Supabase.instance.client.auth.currentSession != null;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        (widget.authChanges ?? Supabase.instance.client.auth.onAuthStateChange)
            .listen((_) {
              if (mounted) setState(() {});
            });
    unawaited(_load());
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    var record = const PersonalizationRecord();
    var seen = false;
    try {
      record = await widget.pending.load().timeout(const Duration(seconds: 3));
      seen = await widget.pending.hasSeenAccount().timeout(
        const Duration(seconds: 3),
      );
    } catch (_) {
      // Private browsing or blocked storage: still let people in.
    }
    if (!mounted) return;
    setState(() {
      _record = record;
      _accountSeen = seen;
      _loaded = true;
    });
  }

  Future<void> _complete(PersonalizationProfile profile) async {
    try {
      await widget.pending.save(profile);
    } catch (_) {
      // Without storage the questions return once after sign-up.
    }
    if (!mounted) return;
    setState(() {
      _record = PersonalizationRecord(profile: profile);
      _editing = false;
    });
  }

  Future<void> _skip() async {
    try {
      await widget.pending.defer();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _record = const PersonalizationRecord(deferred: true);
      _editing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_signedIn) return widget.child;
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final askQuestions =
        _editing || (!_wantsSignIn && !_accountSeen && !_record.hasDecision);
    if (askQuestions) {
      return PersonalizationPage(
        key: const ValueKey('questions-first'),
        initial: _record.profile ?? const PersonalizationProfile(),
        onComplete: _complete,
        onLater: _skip,
        onSignIn: _editing ? null : () => setState(() => _wantsSignIn = true),
      );
    }
    final answered = _record.profile != null && !_wantsSignIn;
    return AuthPage(
      key: ValueKey('auth-${answered ? 'answers' : 'plain'}'),
      answersReady: answered,
      startWithSignUp: !_wantsSignIn && !_accountSeen,
      onEditAnswers: answered ? () => setState(() => _editing = true) : null,
    );
  }
}
