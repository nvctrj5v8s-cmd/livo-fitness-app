import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';

/// After sign-up: the confirmation e-mail is on its way. Explains the next
/// steps, offers a rate-limited resend and the way back to the form.
class CheckInboxPage extends StatelessWidget {
  const CheckInboxPage({
    required this.email,
    required this.resendCooldown,
    required this.loading,
    required this.onResend,
    required this.onSignIn,
    required this.onBack,
    this.message,
    this.messageIsError = false,
    super.key,
  });

  final String email;

  /// Seconds until the next resend is allowed; 0 means now.
  final int resendCooldown;
  final bool loading;
  final VoidCallback onResend;
  final VoidCallback onSignIn;
  final VoidCallback onBack;
  final String? message;
  final bool messageIsError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _StatusScaffold(
      onBack: onBack,
      backLabel: context.l10n.authUseADifferentEmailAddress,
      children: [
        const _StatusIcon(icon: Icons.mark_email_unread_rounded),
        const SizedBox(height: 22),
        Semantics(
          header: true,
          child: Text(
            context.l10n.authCheckYourInbox,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            text: context.l10n.authWeHaveSentAConfirmationEmailTo,
            children: [
              TextSpan(
                text: email,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(text: context.l10n.authIfNoLookinAccountExistsForThis),
            ],
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        _Step(
          number: 1,
          title: context.l10n.authOpenYourInbox,
          text: context.l10n.authTheEmailComesFromLookinNoreplyLookin,
        ),
        _Step(
          number: 2,
          title: context.l10n.authTapConfirmEmail,
          text: context.l10n.authTheLinkCanOnlyBeUsedOnce,
        ),
        _Step(
          number: 3,
          title: context.l10n.authSignIn2,
          text: context.l10n.authUsingYourEmailAddressAndPassword,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.authNothingArrivedCheckYourSpamFolderToo,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 14),
          Semantics(
            liveRegion: true,
            child: Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: messageIsError ? AppColors.error : AppColors.primary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          key: const Key('inbox-sign-in'),
          onPressed: loading ? null : onSignIn,
          icon: const Icon(Icons.login_rounded),
          label: Text(context.l10n.authIHaveConfirmedContinue),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const Key('inbox-resend'),
          onPressed: loading || resendCooldown > 0 ? null : onResend,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(resendLabel(resendCooldown)),
        ),
      ],
    );
  }
}

/// Label of the resend button, with the remaining wait time.
String resendLabel(int cooldown) => cooldown > 0
    ? L10n.current.authSendAgainInValueS((cooldown).toString())
    : L10n.current.authResendConfirmationEmail;

/// Shown after the link from the confirmation e-mail was used.
class EmailConfirmedPage extends StatelessWidget {
  const EmailConfirmedPage({required this.onSignIn, super.key});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _StatusScaffold(
      children: [
        const _StatusIcon(icon: Icons.check_rounded, filled: true),
        const SizedBox(height: 22),
        Semantics(
          header: true,
          child: Text(
            context.l10n.authEmailConfirmed,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.authYourLookinAccountIsNowActiveYou,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.authTipReturnToLookinInTheWindow,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          key: const Key('confirmed-sign-in'),
          onPressed: onSignIn,
          icon: const Icon(Icons.login_rounded),
          label: Text(context.l10n.authSignInNow),
        ),
      ],
    );
  }
}

class _StatusScaffold extends StatelessWidget {
  const _StatusScaffold({required this.children, this.onBack, this.backLabel});

  final List<Widget> children;
  final VoidCallback? onBack;
  final String? backLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              if (onBack != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                    child: TextButton.icon(
                      key: const Key('status-back'),
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text(backLabel ?? context.l10n.authBack),
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        ),
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
}

/// Round icon that pops in once (no animation with reduced motion).
class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.icon, this.filled = false});

  final IconData icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final badge = Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: filled ? 1 : 0.45),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 28,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 38,
        color: filled ? AppColors.black : AppColors.primary,
      ),
    );
    return Center(
      child: reduced
          ? badge
          : TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutBack,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              ),
              child: badge,
            ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title, required this.text});

  final int number;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: number == 1 ? AppColors.primary : AppColors.surfaceSoft,
              border: Border.all(color: AppColors.primary),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: number == 1 ? AppColors.black : AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
