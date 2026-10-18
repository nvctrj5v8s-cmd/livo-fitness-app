import 'package:fitness_ai_app/l10n/l10n.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/state/app_controller.dart';
import '../../consent/domain/consent.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/legal_links_row.dart';
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

  /// Express request to start before the withdrawal period ends. Never
  /// pre-ticked; the purchase stays disabled until the box is ticked.
  bool _immediateStart = false;
  _Notice? _notice;
  _Celebration? _celebration;

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
          _celebration = _Celebration.trial;
        case TrialStartStatus.alreadyPremium:
          _notice = _Notice(
            L10n.current.subscriptionPremiumIsAlreadyActiveForYourAccount,
            _Tone.success,
          );
        case TrialStartStatus.emailUnconfirmed:
          _notice = _Notice(
            L10n.current.subscriptionPleaseConfirmYourEmailAddressUsingThe,
            _Tone.info,
          );
        case TrialStartStatus.alreadyUsed:
          _notice = _Notice(
            L10n.current.subscriptionYouHaveAlreadyUsedYourFreeTrial,
            _Tone.warning,
          );
        case TrialStartStatus.notConfigured:
          _notice = _Notice(
            L10n.current.subscriptionTheTrialIsBeingSetUpPlease,
            _Tone.info,
          );
        case TrialStartStatus.signedOut:
          _notice = _Notice(
            L10n.current.subscriptionPleaseSignInToStartYourTrial,
            _Tone.warning,
          );
        case TrialStartStatus.previewOnly:
          _notice = _Notice(
            L10n.current.subscriptionNoTrialStartsInThePreviewWithout,
            _Tone.info,
          );
        case TrialStartStatus.unavailable:
          _notice = _Notice(
            L10n.current.subscriptionYourTrialCouldNotBeStartedJust,
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

  Future<void> _purchase() async {
    if (!_subscription.storeBillingAvailable) {
      _showMessage(PremiumCopy.unavailableMessage);
      return;
    }
    if (_subscription.isPurchasing) return;
    if (!_immediateStart) {
      _showMessage(PremiumCopy.immediateStartRequired);
      return;
    }
    // Recorded with the plan before the store dialog opens, so the
    // confirmation e-mail can name it.
    final consent = context
        .dependOnInheritedWidgetOfExactType<AppScope>()
        ?.notifier
        ?.consent;
    final stored =
        await consent?.set(
          ConsentKind.immediateStart,
          true,
          context: _selected.name,
        ) ??
        true;
    if (!mounted) return;
    // Without the stored request there is no proof for a later partial
    // payment on withdrawal, so the purchase does not start.
    if (!stored) {
      _showMessage(PremiumCopy.immediateStartNotStored);
      return;
    }
    _afterStoreFlow(await _subscription.purchase(_selected));
  }

  Future<void> _restore() async {
    if (!_subscription.storeBillingAvailable) {
      _showMessage(PremiumCopy.restoreUnavailableMessage);
      return;
    }
    if (_subscription.isPurchasing) return;
    _afterStoreFlow(await _subscription.restore());
  }

  void _afterStoreFlow(PurchaseOutcome outcome) {
    if (!mounted) return;
    if (outcome == PurchaseOutcome.active) {
      // A real celebration instead of a small message and a closing page.
      setState(() => _celebration = _Celebration.purchase);
      return;
    }
    _showMessage(PremiumCopy.purchaseOutcomeMessage(outcome));
  }

  Future<void> _manage() async {
    final uri = _subscription.managementUri;
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) _showMessage(PremiumCopy.manageFailedMessage);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final reducedMotion = media.disableAnimations;
    final wide = media.size.width >= 900;
    final pinActions =
        !wide &&
        _celebration == null &&
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
                    child: _celebration != null
                        ? _SuccessView(
                            key: const ValueKey('paywall-success'),
                            kind: _celebration!,
                            expiresAt: _subscription.entitlement.expiresAt,
                            onContinue: widget.onActivated ?? widget.onClose,
                          )
                        : Builder(
                            key: const ValueKey('paywall-offer'),
                            // Reads the padding that already includes the
                            // pinned action bar (extendBody).
                            builder: (context) => wide
                                ? _wideOffer(context)
                                : _narrowOffer(context, pinActions),
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

  Widget _reveal(double start, Widget child) =>
      _Reveal(animation: _intro, start: start, child: child);

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
                            context.l10n.subscriptionStartForFree,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.l10n
                                .subscriptionAllPremiumFeaturesForValueDaysThen(
                                  (SubscriptionPlans.trialDays).toString(),
                                ),
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
              : L10n.current.subscriptionTrialAlreadyUsed,
          busy: subscription.isStartingTrial,
          enabled: canTrial,
          shimmer: _intro,
          onPressed: _startTrial,
        ),
        SizedBox(height: compact ? 7 : 10),
        _PromiseLine(
          text: canTrial
              ? PremiumCopy.trialPromise
              : L10n.current.subscriptionYouCanSubscribeToPremiumOncePayments,
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
          label: Text(
            L10n.current.subscriptionContinueWithTheFreeVersion,
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
    billingAvailable: _subscription.storeBillingAvailable,
    busy: _subscription.isPurchasing,
    immediateStart: _immediateStart,
    onImmediateStartChanged: (value) => setState(() => _immediateStart = value),
  );

  Widget _legalFooter() => _LegalFooter(
    billingAvailable: _subscription.storeBillingAvailable,
    onManage: _subscription.managementUri == null ? null : _manage,
    onRestore: _restore,
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
              label: 'Lookin Premium',
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
                    'Lookin',
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
          tooltip: context.l10n.subscriptionClose,
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
        context.l10n.subscriptionGladYouAreHere,
      ),
      PaywallSource.coach => (
        Icons.auto_awesome_rounded,
        context.l10n.subscriptionTheLookinCoachIsPartOfPremium,
      ),
      PaywallSource.mealPhoto => (
        Icons.photo_camera_rounded,
        context.l10n.subscriptionAiPhotoIsPartOfPremium,
      ),
      PaywallSource.recipes => (
        Icons.restaurant_menu_rounded,
        context.l10n.subscriptionAllRecipesAreAvailableWithPremium,
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
                TextSpan(text: context.l10n.subscriptionGet),
                TextSpan(
                  text: 'Lookin Premium',
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
            context.l10n.subscriptionAiPhotoYourPersonalCoachAndAll,
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
        context.l10n.subscriptionAiPhotoRecognition,
        context.l10n.subscriptionTakeAPhotoLookinEstimatesFoodsAnd,
      ),
      (
        Icons.auto_awesome_rounded,
        AppColors.mint,
        'Lookin Coach',
        context.l10n.subscriptionYourAiChatForNutritionAndFitness,
      ),
      (
        Icons.restaurant_menu_rounded,
        AppColors.orange,
        context.l10n.subscriptionAllRecipes,
        '${PremiumCopy.premiumRecipes}. ${PremiumCopy.freeRecipes}.',
      ),
      (
        Icons.bolt_rounded,
        AppColors.purple,
        context.l10n.subscriptionGenerousAiAllowance,
        context.l10n.subscriptionUpTo100AiRequestsADay,
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
    final text = busy ? context.l10n.subscriptionStartingTrial : label;
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
    final left =
        -band + (size.width + band * 2) * Curves.easeInOut.transform(t);
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
              ? context.l10n.subscriptionYourFreeTrialIsActiveItEnds
              : context.l10n.subscriptionFreeTrialUntilValueItEndsAutomatically(
                  (formatPremiumDateTime(expiresAt)).toString(),
                )
        : expiresAt == null
        ? context.l10n.subscriptionYourPremiumSubscriptionIsActive
        : context.l10n.subscriptionYourPremiumSubscriptionIsActiveUntilValue(
            (formatPremiumDateTime(expiresAt)).toString(),
          );
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
                  context.l10n.subscriptionPremiumIsActive,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
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
            child: Text(context.l10n.subscriptionDone),
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
    required this.billingAvailable,
    required this.busy,
    required this.immediateStart,
    required this.onImmediateStartChanged,
  });

  final PremiumPlanId selected;
  final ValueChanged<PremiumPlanId> onSelected;
  final VoidCallback onPurchase;
  final PremiumPlan plan;
  final bool billingAvailable;
  final bool busy;
  final bool immediateStart;
  final ValueChanged<bool> onImmediateStartChanged;

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
              context.l10n.subscriptionChooseAPremiumSubscription,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (!billingAvailable) const _SoonTag(),
          ],
        ),
        const SizedBox(height: 14),
        Semantics(
          container: true,
          label: context.l10n.subscriptionSubscriptionPlans,
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
        if (billingAvailable) ...[
          CheckboxListTile(
            key: const Key('paywall-immediate-start'),
            value: immediateStart,
            onChanged: (value) => onImmediateStartChanged(value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              ConsentTexts.immediateStart,
              style: TextStyle(fontSize: 12.5, height: 1.4),
            ),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton(
          key: const Key('paywall-purchase'),
          onPressed: busy || (billingAvailable && !immediateStart)
              ? null
              : onPurchase,
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(
                Icons.schedule_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                billingAvailable
                    ? PremiumCopy.storeNote
                    : PremiumCopy.unavailableNote,
                style: const TextStyle(
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
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_rounded, size: 13, color: AppColors.textMuted),
        SizedBox(width: 5),
        Flexible(
          child: Text(
            context.l10n.subscriptionComingSoon,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
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
    final detail = PremiumCopy.priceDetail(plan);
    final billing = PremiumCopy.billingNote(plan);
    final savings = SubscriptionPlans.yearlySavingsPercent;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label:
          '$title${plan.isYearly ? context.l10n.subscriptionPopularSavings(savings.toString()) : ''}: $price $unit, $detail, $billing',
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
                                context.l10n.subscriptionPopularValue(
                                  (savings).toString(),
                                ),
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
                        detail,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        billing,
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
      (context.l10n.subscriptionDiaryMacrosStreak, true, true),
      (context.l10n.subscriptionSearchBarcodeCustomFoods, true, true),
      (context.l10n.subscriptionProfileDailyTargets, true, true),
      (
        context.l10n.subscriptionRecipes,
        '${SubscriptionPlans.freeRecipeSharePercent} %',
        context.l10n.subscriptionAll,
      ),
      (context.l10n.subscriptionAiPhotoRecognition, false, true),
      (context.l10n.subscriptionLookinCoachAiChat, false, true),
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
            context.l10n.subscriptionFreeOrPremium,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          ExcludeSemantics(
            child: Row(
              children: [
                const Expanded(flex: 5, child: SizedBox()),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        context.l10n.subscriptionFree,
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
              label: context.l10n.subscriptionValueFreeValuePremiumValue(
                (label).toString(),
                (_spoken(free)).toString(),
                (_spoken(premium)).toString(),
              ),
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
    true => L10n.current.subscriptionIncluded,
    false => L10n.current.subscriptionNotIncluded,
    final String text => text.toLowerCase(),
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
    required this.billingAvailable,
    required this.onManage,
    required this.onRestore,
  });

  final bool billingAvailable;
  final VoidCallback? onManage;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final terms = context.l10n.subscriptionFreeTrialValueDaysOncePerEmail(
      (SubscriptionPlans.trialDays).toString(),
      (PremiumCopy.priceTermsFor(
        billingAvailable: billingAvailable,
      )).toString(),
    );
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
              icon: Icon(
                billingAvailable
                    ? Icons.restore_rounded
                    : Icons.schedule_rounded,
                size: 15,
              ),
              label: Text(
                billingAvailable
                    ? context.l10n.subscriptionRestorePurchases
                    : context.l10n.subscriptionRestorePurchasesComingSoon,
              ),
            ),
            if (onManage != null)
              TextButton(
                key: const Key('paywall-manage'),
                onPressed: onManage,
                style: linkStyle,
                child: Text(context.l10n.subscriptionManageSubscription),
              ),
          ],
        ),
        const LegalLinksRow(
          pages: [
            LegalPage.privacy,
            LegalPage.terms,
            LegalPage.withdrawal,
            LegalPage.imprint,
          ],
        ),
      ],
    );
  }
}

// ─── Success ───────────────────────────────────────────────────────────────

/// What the full-screen "Premium is active" view celebrates.
enum _Celebration { trial, purchase }

/// Full-screen "Premium is active", after the free trial and after a
/// purchase. One finite animation: the check pops up, rings and confetti
/// dots fly outwards once, the benefits slide in one after another. With
/// "reduce motion" everything is shown at once.
class _SuccessView extends StatefulWidget {
  const _SuccessView({
    required this.kind,
    required this.expiresAt,
    required this.onContinue,
    super.key,
  });

  final _Celebration kind;
  final DateTime? expiresAt;
  final VoidCallback onContinue;

  @override
  State<_SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<_SuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      unawaited(HapticFeedback.mediumImpact());
      unawaited(_controller.forward());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _subtitle(BuildContext context) {
    final l10n = context.l10n;
    final expiresAt = widget.expiresAt;
    if (widget.kind == _Celebration.purchase) {
      final renewal = expiresAt == null
          ? ''
          : '\n${l10n.subscriptionNextRenewalValue(formatPremiumDateTime(expiresAt))}';
      return '${l10n.subscriptionThankYouYourSubscriptionRenewsAutomatically}$renewal';
    }
    final until = expiresAt == null
        ? l10n.subscriptionYourFreeTrialLastsValueDays(
            (SubscriptionPlans.trialDays).toString(),
          )
        : l10n.subscriptionYourFreeTrialRunsUntilValue(
            (formatPremiumDateTime(expiresAt)).toString(),
          );
    return l10n.subscriptionValueItEndsAutomaticallyAtNoCost(
      (until).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final benefits = [
      l10n.subscriptionAiPhotoRecognition,
      'Lookin Coach',
      l10n.subscriptionAllRecipes,
    ];
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        4,
        24,
        28 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              double phase(
                double begin,
                double end, [
                Curve curve = Curves.easeOutCubic,
              ]) => Interval(
                begin,
                end,
                curve: curve,
              ).transform(_controller.value);

              Widget reveal(double begin, Widget child) {
                final t = phase(begin, begin + 0.22);
                return Opacity(
                  opacity: t.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 18 * (1 - t)),
                    child: child,
                  ),
                );
              }

              final pop = phase(0, 0.32, Curves.easeOutBack);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 240,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: ExcludeSemantics(
                            child: CustomPaint(
                              painter: _BurstPainter(
                                progress: phase(0.06, 1, Curves.easeOutCubic),
                              ),
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: 0.55 + 0.45 * pop,
                          child: Opacity(
                            opacity: (pop * 1.6).clamp(0.0, 1.0),
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
                                    color: AppColors.primary.withValues(
                                      alpha: 0.4,
                                    ),
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
                      ],
                    ),
                  ),
                  reveal(
                    0.28,
                    Semantics(
                      liveRegion: true,
                      header: true,
                      child: Text(
                        l10n.subscriptionPremiumIsActive,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  reveal(
                    0.36,
                    Text(
                      _subtitle(context),
                      key: const Key('paywall-success-subtitle'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 15,
                        height: 1.45,
                      ),
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
                        for (final (i, label) in benefits.indexed) ...[
                          if (i > 0) const SizedBox(height: 12),
                          reveal(
                            0.46 + i * 0.1,
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
                                    l10n.subscriptionValueUnlocked(
                                      (label).toString(),
                                    ),
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  reveal(
                    0.76,
                    FilledButton(
                      key: const Key('paywall-success-continue'),
                      onPressed: widget.onContinue,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: Text(l10n.subscriptionLetSGo),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Two soft rings and a ring of confetti dots that fly outwards once
/// ([progress] 0 to 1) and fade out. Drawn only; no timers of its own.
class _BurstPainter extends CustomPainter {
  const _BurstPainter({required this.progress});

  final double progress;

  static const _colors = [
    AppColors.primary,
    AppColors.mint,
    AppColors.orange,
    AppColors.text,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final center = size.center(Offset.zero);
    final reach = math.min(size.width, size.height) / 2;
    for (var ring = 0; ring < 2; ring++) {
      final p = ((progress - ring * 0.18) / (1 - ring * 0.18)).clamp(0.0, 1.0);
      if (p <= 0) continue;
      canvas.drawCircle(
        center,
        56 + (reach - 56) * Curves.easeOutCubic.transform(p),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * (1 - p)
          ..color = AppColors.primary.withValues(alpha: 0.55 * (1 - p)),
      );
    }
    const dots = 18;
    for (var i = 0; i < dots; i++) {
      final angle = i * 2 * math.pi / dots + (i.isEven ? 0.12 : -0.12);
      final spread = 0.62 + 0.38 * ((i * 7) % 5) / 4;
      final distance =
          62 + (reach - 70) * spread * Curves.easeOutCubic.transform(progress);
      final fade = progress < 0.55 ? 1.0 : (1 - (progress - 0.55) / 0.45);
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * distance,
        (i % 3 == 0 ? 4.5 : 3.0) * (1 - 0.4 * progress),
        Paint()..color = _colors[i % _colors.length].withValues(alpha: fade),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.progress != progress;
}
