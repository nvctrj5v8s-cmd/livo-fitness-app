import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../application/subscription_controller.dart';
import '../domain/entitlement.dart';
import '../domain/subscription_plans.dart';
import 'premium_artwork.dart';
import 'premium_format.dart';

/// Where the paywall was opened; only changes the small context line.
enum PaywallSource { onboarding, profile, coach, mealPhoto, recipes }

/// Opens the paywall full-screen. Returns `true` if the account has premium
/// afterwards, e.g. because the free trial was started.
Future<bool> showPaywall(
  BuildContext context, {
  PaywallSource source = PaywallSource.profile,
}) async {
  final subscription = AppScope.of(context).subscription;
  final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  await Navigator.of(context).push<bool>(
    PageRouteBuilder<bool>(
      fullscreenDialog: true,
      transitionDuration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 420),
      reverseTransitionDuration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 260),
      pageBuilder: (routeContext, _, _) => PaywallPage(
        subscription: subscription,
        source: source,
        onClose: () => Navigator.of(routeContext).pop(false),
        onActivated: () => Navigator.of(routeContext).pop(true),
      ),
      transitionsBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
  return subscription.hasPremium;
}

double _phase(double value, double start, double end) => Curves.easeOutCubic
    .transform(((value - start) / (end - start)).clamp(0.0, 1.0));

class PaywallPage extends StatefulWidget {
  const PaywallPage({
    required this.subscription,
    required this.onClose,
    this.onActivated,
    this.source = PaywallSource.onboarding,
    super.key,
  });

  final SubscriptionController subscription;

  /// "Weiter mit der kostenlosen Version" and the close button.
  final VoidCallback onClose;

  /// After the trial started and the user continues into the app.
  final VoidCallback? onActivated;
  final PaywallSource source;

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

enum _Tone { info, warning, success }

class _Notice {
  const _Notice(this.message, this.tone);
  final String message;
  final _Tone tone;
}

class _PaywallPageState extends State<PaywallPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  PremiumPlanId _selected = SubscriptionPlans.recommended;
  _Notice? _notice;
  bool _trialStarted = false;

  SubscriptionController get _subscription => widget.subscription;
  PremiumPlan get _plan => SubscriptionPlans.byId(_selected);

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _subscription.addListener(_onSubscription);
    if (!_subscription.hasLoaded && !_subscription.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_subscription.load());
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _intro.value = 1;
    } else if (_intro.value == 0 && !_intro.isAnimating) {
      unawaited(_intro.forward());
    }
  }

  @override
  void dispose() {
    _subscription.removeListener(_onSubscription);
    _intro.dispose();
    super.dispose();
  }

  void _onSubscription() {
    if (mounted) setState(() {});
  }

  Future<void> _startTrial() async {
    if (_subscription.isStartingTrial) return;
    setState(() => _notice = null);
    final result = await _subscription.startTrial();
    if (!mounted) return;
    setState(() {
      switch (result.status) {
        case TrialStartStatus.started:
          _trialStarted = true;
        case TrialStartStatus.alreadyPremium:
          _notice = const _Notice(
            'Premium ist für dein Konto bereits aktiv.',
            _Tone.success,
          );
        case TrialStartStatus.alreadyUsed:
          _notice = const _Notice(
            'Du hast deine kostenlose Testphase bereits genutzt – sie gilt '
            'einmal pro Konto.',
            _Tone.warning,
          );
        case TrialStartStatus.notConfigured:
          _notice = const _Notice(
            'Die Testphase wird gerade eingerichtet. Bitte versuche es später '
            'noch einmal – es wurde nichts gestartet und nichts berechnet.',
            _Tone.info,
          );
        case TrialStartStatus.signedOut:
          _notice = const _Notice(
            'Bitte melde dich an, um die Testphase zu starten.',
            _Tone.warning,
          );
        case TrialStartStatus.previewOnly:
          _notice = const _Notice(
            'In der Vorschau ohne Konto startet keine Testphase. Melde dich '
            'an, um Premium kostenlos zu testen.',
            _Tone.info,
          );
        case TrialStartStatus.unavailable:
          _notice = const _Notice(
            'Die Testphase konnte gerade nicht gestartet werden. Bitte prüfe '
            'deine Verbindung und versuche es erneut.',
            _Tone.warning,
          );
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _purchase() => _showMessage(
    '${PremiumCopy.billingPending}. Es wurde nichts gekauft und nichts '
    'berechnet – teste Premium bis dahin ${SubscriptionPlans.trialDays} Tage '
    'kostenlos.',
  );

  void _restore() => _showMessage(
    'Käufe wiederherstellen ist bald verfügbar. Bisher gibt es in LIVO noch '
    'keine Käufe, die wiederhergestellt werden müssten.',
  );

  Future<void> _legal(String title, String message) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surfaceHigh,
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Schließen'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final reducedMotion = media.disableAnimations;
    final wide = media.size.width >= 900;
    final pinActions =
        !wide &&
        !_trialStarted &&
        media.size.height >= 620 &&
        media.textScaler.scale(1) <= 1.3;
    return Scaffold(
      key: const Key('paywall-page'),
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(child: _PaywallBackdrop()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _TopBar(onClose: widget.onClose),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: reducedMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 420),
                    switchInCurve: Curves.easeOutCubic,
                    child: _trialStarted
                        ? _TrialSuccessView(
                            key: const ValueKey('paywall-success'),
                            expiresAt: _subscription.entitlement.expiresAt,
                            onContinue: widget.onActivated ?? widget.onClose,
                          )
                        : Builder(
                            key: const ValueKey('paywall-offer'),
                            // Reads the padding that already includes the
                            // pinned action bar (extendBody).
                            builder: (context) =>
                                wide ? _wideOffer(context) : _narrowOffer(
                                    context,
                                    pinActions,
                                  ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: pinActions
          ? _PinnedActions(child: _actions(compact: true))
          : null,
    );
  }

  double _bottomInset(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom;

  Widget _reveal(double start, Widget child) => _Reveal(
    animation: _intro,
    start: start,
    child: child,
  );

  Widget _hero(double height) => SizedBox(
    height: height,
    child: AnimatedBuilder(
      animation: _intro,
      builder: (context, _) => PremiumHeroArtwork(progress: _intro.value),
    ),
  );

  Widget _narrowOffer(BuildContext context, bool pinActions) {
    final heroHeight = (MediaQuery.sizeOf(context).height * 0.26).clamp(
      150.0,
      226.0,
    );
    return SingleChildScrollView(
      key: const Key('paywall-scroll'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 28 + _bottomInset(context)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _hero(heroHeight),
              const SizedBox(height: 6),
              _reveal(0.1, _Headline(source: widget.source)),
              const SizedBox(height: 24),
              _Benefits(animation: _intro),
              const SizedBox(height: 24),
              if (!pinActions) ...[
                _reveal(0.4, _actions(compact: false)),
                const SizedBox(height: 30),
              ],
              _reveal(0.46, _planSection()),
              const SizedBox(height: 28),
              _reveal(0.56, const _ComparisonCard()),
              const SizedBox(height: 22),
              _legalFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wideOffer(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('paywall-scroll'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(40, 0, 40, 40 + _bottomInset(context)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 11,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _hero(270),
                    const SizedBox(height: 8),
                    _reveal(0.1, _Headline(source: widget.source)),
                    const SizedBox(height: 28),
                    _Benefits(animation: _intro),
                    const SizedBox(height: 26),
                    _reveal(0.56, const _ComparisonCard()),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _reveal(
                    0.3,
                    _Panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Starte kostenlos',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Alle Premium-Funktionen '
                            '${SubscriptionPlans.trialDays} Tage lang – danach '
                            'geht es automatisch kostenlos weiter.',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _actions(compact: false),
                          const SizedBox(height: 22),
                          const Divider(color: AppColors.border, height: 1),
                          const SizedBox(height: 22),
                          _planSection(),
                          const SizedBox(height: 22),
                          _legalFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actions({required bool compact}) {
    final subscription = _subscription;
    if (subscription.hasPremium) {
      return _ActiveCard(
        entitlement: subscription.entitlement,
        trialing: subscription.isTrialing,
        onDone: widget.onActivated ?? widget.onClose,
      );
    }
    final canTrial = subscription.canStartTrial;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_notice case final notice?) ...[
          _NoticeCard(notice: notice),
          const SizedBox(height: 10),
        ],
        _TrialButton(
          label: canTrial
              ? PremiumCopy.trialCta
              : 'Testphase bereits genutzt',
          busy: subscription.isStartingTrial,
          enabled: canTrial,
          shimmer: _intro,
          onPressed: _startTrial,
        ),
        SizedBox(height: compact ? 7 : 10),
        _PromiseLine(
          text: canTrial
              ? PremiumCopy.trialPromise
              : 'Premium kannst du abonnieren, sobald die Bezahlung '
                    'eingerichtet ist.',
        ),
        SizedBox(height: compact ? 2 : 6),
        TextButton.icon(
          key: const Key('paywall-continue-free'),
          onPressed: widget.onClose,
          iconAlignment: IconAlignment.end,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.text,
            minimumSize: const Size.fromHeight(48),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          icon: const Icon(Icons.arrow_forward_rounded, size: 19),
          label: const Text(
            'Weiter mit der kostenlosen Version',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _planSection() => _PlanSection(
    selected: _selected,
    onSelected: (id) => setState(() => _selected = id),
    onPurchase: _purchase,
    plan: _plan,
  );

  Widget _legalFooter() => _LegalFooter(
    onRestore: _restore,
    onPrivacy: () => _legal(
      'Datenschutz',
      'Die vollständige Datenschutzerklärung wird vor dem Start der '
          'Bezahlung hier verlinkt. Für die Testphase speichert LIVO nur, '
          'dass und bis wann dein Konto sie nutzt – keine Zahlungsdaten.',
    ),
    onTerms: () => _legal(
      'AGB',
      'Die vollständigen Allgemeinen Geschäftsbedingungen für LIVO Premium '
          'werden vor dem Start der Bezahlung hier verlinkt.',
    ),
  );
}

// ─── Layout pieces ─────────────────────────────────────────────────────────

class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.animation,
    required this.start,
    required this.child,
  });

  final Animation<double> animation;
  final double start;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    child: child,
    builder: (context, child) {
      final t = _phase(animation.value, start, start + 0.32);
      return Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - t)),
          child: child,
        ),
      );
    },
  );
}

class _PaywallBackdrop extends StatelessWidget {
  const _PaywallBackdrop();

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundRaised,
                AppColors.background,
                AppColors.background,
              ],
            ),
          ),
        ),
        Positioned(
          top: -260,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 680,
              height: 680,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.16),
                    AppColors.primary.withValues(alpha: 0.04),
                    AppColors.primary.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: -220,
          bottom: -260,
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.mint.withValues(alpha: 0.08),
                  AppColors.mint.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 8, 12, 4),
    child: Row(
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Semantics(
              label: 'LIVO Premium',
              excludeSemantics: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.mint],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 17,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Text(
                    'LIVO',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.55),
                      ),
                    ),
                    child: const Text(
                      'PREMIUM',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          key: const Key('paywall-close'),
          tooltip: 'Schließen',
          onPressed: onClose,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceHigh,
            foregroundColor: AppColors.text,
            minimumSize: const Size(48, 48),
            side: const BorderSide(color: AppColors.borderBright),
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.close_rounded, size: 22),
        ),
      ],
    ),
  );
}

class _Headline extends StatelessWidget {
  const _Headline({required this.source});

  final PaywallSource source;

  @override
  Widget build(BuildContext context) {
    final contextLine = switch (source) {
      PaywallSource.onboarding => (
        Icons.celebration_rounded,
        'Schön, dass du da bist',
      ),
      PaywallSource.coach => (
        Icons.auto_awesome_rounded,
        'Der LIVO Coach ist Teil von Premium',
      ),
      PaywallSource.mealPhoto => (
        Icons.photo_camera_rounded,
        'KI-Foto ist Teil von Premium',
      ),
      PaywallSource.recipes => (
        Icons.restaurant_menu_rounded,
        'Alle Rezepte gibt es mit Premium',
      ),
      PaywallSource.profile => null,
    };
    final titleScale = MediaQuery.textScalerOf(
      context,
    ).clamp(maxScaleFactor: 1.5);
    return Column(
      children: [
        if (contextLine case (final icon, final label)) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: AppColors.borderBright),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: AppColors.primary),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Hol dir '),
                TextSpan(
                  text: 'LIVO Premium',
                  style: TextStyle(
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [AppColors.primary, AppColors.mint],
                      ).createShader(const Rect.fromLTWH(40, 0, 300, 40)),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            textScaler: titleScale,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 34,
              height: 1.08,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Text(
            'KI-Foto, dein persönlicher Coach und alle Rezepte – für weniger '
            'Aufwand und mehr Klarheit beim Essen.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 15.5,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _Benefits extends StatelessWidget {
  const _Benefits({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final benefits = [
      (
        Icons.photo_camera_rounded,
        AppColors.primary,
        'KI-Foto-Erkennung',
        'Foto machen – LIVO schätzt Lebensmittel und Mengen. Du prüfst alles '
            'vor dem Speichern.',
      ),
      (
        Icons.auto_awesome_rounded,
        AppColors.mint,
        'LIVO Coach',
        'Dein KI-Chat für Ernährung und Fitness, abgestimmt auf dein Ziel und '
            'deine Tageswerte.',
      ),
      (
        Icons.restaurant_menu_rounded,
        AppColors.orange,
        'Alle Rezepte',
        '${PremiumCopy.premiumRecipes}. ${PremiumCopy.freeRecipes}.',
      ),
      (
        Icons.rocket_launch_rounded,
        AppColors.purple,
        'Neue Premium-Funktionen',
        'Kommende Premium-Funktionen sind automatisch inklusive.',
      ),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceHigh.withValues(alpha: 0.92),
            AppColors.surface.withValues(alpha: 0.92),
          ],
        ),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          for (final (i, (icon, color, title, text)) in benefits.indexed) ...[
            if (i > 0) const SizedBox(height: 18),
            _Reveal(
              animation: animation,
              start: 0.2 + i * 0.07,
              child: _BenefitRow(
                icon: icon,
                color: color,
                title: title,
                text: text,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.lerp(color, AppColors.white, 0.18)!, color],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.black, size: 23),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13.5,
                  height: 1.42,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(AppColors.surfaceHigh, AppColors.primary, 0.05)!,
          AppColors.surface,
        ],
      ),
      border: Border.all(color: AppColors.borderBright),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.45),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
      ],
    ),
    child: child,
  );
}

class _PinnedActions extends StatelessWidget {
  const _PinnedActions({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.background.withValues(alpha: 0),
          AppColors.background.withValues(alpha: 0.94),
          AppColors.background,
        ],
        stops: const [0, 0.2, 1],
      ),
    ),
    child: SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 4),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: child,
          ),
        ),
      ),
    ),
  );
}

// ─── Actions ───────────────────────────────────────────────────────────────

class _TrialButton extends StatelessWidget {
  const _TrialButton({
    required this.label,
    required this.busy,
    required this.enabled,
    required this.shimmer,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final bool enabled;
  final Animation<double> shimmer;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !busy;
    final foreground = enabled ? AppColors.black : AppColors.textMuted;
    final text = busy ? 'Testphase wird gestartet …' : label;
    return Semantics(
      button: true,
      enabled: active,
      label: text,
      onTap: active ? onPressed : null,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: enabled
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.primary,
                    Color.lerp(AppColors.primary, AppColors.mint, 0.55)!,
                  ],
                )
              : null,
          color: enabled ? null : AppColors.surfaceSoft,
          border: enabled ? null : Border.all(color: AppColors.borderBright),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 26,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              key: const Key('paywall-start-trial'),
              onTap: active ? onPressed : null,
              child: AnimatedBuilder(
                animation: shimmer,
                builder: (context, child) => CustomPaint(
                  // One sweep after the entrance; never repeats.
                  foregroundPainter: enabled
                      ? _ShimmerPainter(
                          ((shimmer.value - 0.74) / 0.26).clamp(0.0, 1.0),
                        )
                      : null,
                  child: child,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 58),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (busy)
                          const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.black,
                            ),
                          )
                        else
                          Icon(
                            enabled
                                ? Icons.bolt_rounded
                                : Icons.check_circle_outline_rounded,
                            color: foreground,
                            size: 22,
                          ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: foreground,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  const _ShimmerPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final band = size.width * 0.32;
    final left = -band + (size.width + band * 2) * Curves.easeInOut.transform(t);
    final rect = Rect.fromLTWH(left - band, 0, band * 2, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          transform: const GradientRotation(0.35),
          colors: [
            AppColors.white.withValues(alpha: 0),
            AppColors.white.withValues(alpha: 0.42),
            AppColors.white.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) => oldDelegate.t != t;
}

class _PromiseLine extends StatelessWidget {
  const _PromiseLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(top: 1),
        child: Icon(
          Icons.verified_user_outlined,
          size: 15,
          color: AppColors.mint,
        ),
      ),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12.5,
            height: 1.35,
          ),
        ),
      ),
    ],
  );
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.notice});

  final _Notice notice;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (notice.tone) {
      _Tone.info => (Icons.info_outline_rounded, AppColors.blue),
      _Tone.warning => (Icons.error_outline_rounded, AppColors.orange),
      _Tone.success => (Icons.check_circle_rounded, AppColors.mint),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                notice.message,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({
    required this.entitlement,
    required this.trialing,
    required this.onDone,
  });

  final Entitlement entitlement;
  final bool trialing;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final expiresAt = entitlement.expiresAt;
    final detail = trialing
        ? expiresAt == null
              ? 'Deine kostenlose Testphase läuft. Sie endet automatisch – '
                    'ohne Kosten.'
              : 'Kostenlose Testphase bis ${formatPremiumDateTime(expiresAt)}. '
                    'Sie endet automatisch – ohne Kosten.'
        : expiresAt == null
        ? 'Dein Premium-Abo ist aktiv.'
        : 'Dein Premium-Abo ist aktiv bis ${formatPremiumDateTime(expiresAt)}.';
    return Container(
      key: const Key('paywall-active'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.primary.withValues(alpha: 0.09),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Premium ist aktiv',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: const TextStyle(color: AppColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 14),
          FilledButton(
            key: const Key('paywall-active-done'),
            onPressed: onDone,
            child: const Text('Fertig'),
          ),
        ],
      ),
    );
  }
}

// ─── Plans ─────────────────────────────────────────────────────────────────

class _PlanSection extends StatelessWidget {
  const _PlanSection({
    required this.selected,
    required this.onSelected,
    required this.onPurchase,
    required this.plan,
  });

  final PremiumPlanId selected;
  final ValueChanged<PremiumPlanId> onSelected;
  final VoidCallback onPurchase;
  final PremiumPlan plan;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: [
            Text(
              'Premium-Abo wählen',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const _SoonTag(),
          ],
        ),
        const SizedBox(height: 14),
        Semantics(
          container: true,
          label: 'Abo-Pläne',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, candidate) in SubscriptionPlans.all.indexed) ...[
                if (i > 0) const SizedBox(height: 12),
                _PlanCard(
                  plan: candidate,
                  selected: candidate.id == selected,
                  onTap: () => onSelected(candidate.id),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          key: const Key('paywall-purchase'),
          onPressed: onPurchase,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.text,
            minimumSize: const Size.fromHeight(58),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: AnimatedSwitcher(
            duration: reducedMotion
                ? Duration.zero
                : const Duration(milliseconds: 220),
            child: Column(
              key: ValueKey(plan.id),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  PremiumCopy.purchaseLabel(plan),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  PremiumCopy.purchaseSummary(plan),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(
                Icons.schedule_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(width: 7),
            Expanded(
              child: Text(
                '${PremiumCopy.billingPending} – bis dahin wird nichts '
                'gekauft oder berechnet.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SoonTag extends StatelessWidget {
  const _SoonTag();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: AppColors.borderBright),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_rounded, size: 13, color: AppColors.textMuted),
        SizedBox(width: 5),
        Text(
          'Bald verfügbar',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final PremiumPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final title = PremiumCopy.planTitle(plan);
    final price = PremiumCopy.headlinePrice(plan);
    final unit = PremiumCopy.headlineUnit(plan);
    final intro = PremiumCopy.introDetail(plan);
    final followUp = PremiumCopy.followUp(plan);
    final savings = SubscriptionPlans.yearlySavingsPercent;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label:
          '$title${plan.isYearly ? ', beliebt, $savings Prozent günstiger als '
                    'monatlich' : ''}: $price $unit, $intro, $followUp',
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: ValueKey('paywall-plan-${plan.id.name}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: reducedMotion
                ? Duration.zero
                : const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: selected
                    ? [
                        Color.lerp(
                          AppColors.surfaceHigh,
                          AppColors.primary,
                          0.13,
                        )!,
                        AppColors.surfaceHigh,
                      ]
                    : [AppColors.surface, AppColors.surface],
              ),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.16),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? AppColors.primary : AppColors.textMuted,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (plan.isYearly)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.mint],
                                ),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                'Beliebt · −$savings %',
                                style: const TextStyle(
                                  color: AppColors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Text(
                            price,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 28,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              unit,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        intro,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        followUp,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
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

// ─── Comparison & legal ────────────────────────────────────────────────────

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard();

  @override
  Widget build(BuildContext context) {
    final rows = <(String, Object, Object)>[
      ('Tagebuch, Makros & Serie', true, true),
      ('Suche, Barcode & eigene Lebensmittel', true, true),
      ('Profil & Tagesziele', true, true),
      ('Rezepte', '${SubscriptionPlans.freeRecipeSharePercent} %', 'Alle'),
      ('KI-Foto-Erkennung', false, true),
      ('LIVO Coach (KI-Chat)', false, true),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kostenlos oder Premium?',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          ExcludeSemantics(
            child: Row(
              children: [
                const Expanded(flex: 5, child: SizedBox()),
                const Expanded(
                  flex: 3,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Kostenlos',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          'Premium',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final (label, free, premium) in rows) ...[
            const Divider(height: 20, color: AppColors.border),
            Semantics(
              label:
                  '$label. Kostenlos: ${_spoken(free)}. '
                  'Premium: ${_spoken(premium)}.',
              excludeSemantics: true,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13.5,
                        height: 1.3,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(child: _Cell(free, premium: false)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(child: _Cell(premium, premium: true)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _spoken(Object value) => switch (value) {
    true => 'enthalten',
    false => 'nicht enthalten',
    final String text => text == 'Alle' ? 'alle' : text,
    _ => '',
  };
}

class _Cell extends StatelessWidget {
  const _Cell(this.value, {required this.premium});

  final Object value;
  final bool premium;

  @override
  Widget build(BuildContext context) => switch (value) {
    true => Icon(
      Icons.check_circle_rounded,
      size: 21,
      color: premium ? AppColors.primary : AppColors.mint,
    ),
    false => const Icon(
      Icons.lock_outline_rounded,
      size: 19,
      color: AppColors.textMuted,
    ),
    final String text => FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: TextStyle(
          color: premium ? AppColors.primary : AppColors.text,
          fontSize: 13.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
    _ => const SizedBox.shrink(),
  };
}

class _LegalFooter extends StatelessWidget {
  const _LegalFooter({
    required this.onRestore,
    required this.onPrivacy,
    required this.onTerms,
  });

  final VoidCallback onRestore;
  final VoidCallback onPrivacy;
  final VoidCallback onTerms;

  @override
  Widget build(BuildContext context) {
    const yearly = SubscriptionPlans.yearly;
    const monthly = SubscriptionPlans.monthly;
    final terms =
        'Kostenlose Testphase: ${SubscriptionPlans.trialDays} Tage, einmal '
        'pro Konto. Sie endet automatisch – ohne Kosten und ohne '
        'automatische Verlängerung. Es werden keine Zahlungsdaten abgefragt.\n\n'
        'Abo-Preise (Bezahlung wird gerade eingerichtet): Jährlich '
        '${formatEuro(yearly.firstChargeCents)} im ersten Jahr, danach '
        '${formatEuro(yearly.regularChargeCents)} pro Jahr. Monatlich '
        '${formatEuro(monthly.introMonthlyPriceCents)} pro Monat in den '
        'ersten ${monthly.introMonths} Monaten, danach '
        '${formatEuro(monthly.monthlyPriceCents)} pro Monat. Alle Preise inkl. '
        'MwSt. Ein Abo verlängert sich automatisch zum genannten Folgepreis '
        'und ist jederzeit zum Ende des Abrechnungszeitraums kündbar.';
    final linkStyle = TextButton.styleFrom(
      foregroundColor: AppColors.textMuted,
      minimumSize: const Size(48, 44),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          terms,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          runSpacing: 0,
          children: [
            TextButton.icon(
              key: const Key('paywall-restore'),
              onPressed: onRestore,
              style: linkStyle,
              icon: const Icon(Icons.schedule_rounded, size: 15),
              label: const Text('Käufe wiederherstellen – bald verfügbar'),
            ),
            TextButton(
              onPressed: onPrivacy,
              style: linkStyle,
              child: const Text('Datenschutz'),
            ),
            TextButton(
              onPressed: onTerms,
              style: linkStyle,
              child: const Text('AGB'),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Success ───────────────────────────────────────────────────────────────

class _TrialSuccessView extends StatelessWidget {
  const _TrialSuccessView({
    required this.expiresAt,
    required this.onContinue,
    super.key,
  });

  final DateTime? expiresAt;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final until = expiresAt == null
        ? 'Deine kostenlose Testphase läuft ${SubscriptionPlans.trialDays} '
              'Tage.'
        : 'Deine kostenlose Testphase läuft bis '
              '${formatPremiumDateTime(expiresAt!)}.';
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        28 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: reducedMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 900),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) => Transform.scale(
                    scale: 0.6 + 0.4 * value,
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  ),
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.mint],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 48,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 60,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Semantics(
                liveRegion: true,
                header: true,
                child: Text(
                  'Premium ist aktiv',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$until Sie endet automatisch – ohne Kosten und ohne Abo.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    for (final (i, label) in const [
                      'KI-Foto-Erkennung',
                      'LIVO Coach',
                      'Alle Rezepte',
                    ].indexed) ...[
                      if (i > 0) const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$label freigeschaltet',
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 26),
              FilledButton(
                key: const Key('paywall-success-continue'),
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text('Los geht’s'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
