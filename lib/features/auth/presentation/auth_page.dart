import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../language/presentation/language_switch.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/legal_links_row.dart';
import '../../../shared/widgets/ui_components.dart';
import 'email_status_pages.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    this.answersReady = false,
    this.startWithSignUp = false,
    this.onEditAnswers,
    this.initialEmail,
    this.initialName,
    super.key,
  });

  /// Prefills the name field with the name given in the questions, so it
  /// is not typed twice.
  final String? initialName;

  /// Prefills the e-mail field, for example after confirming the address.
  final String? initialEmail;

  /// The questions were answered before sign-up: start with "Registrieren"
  /// and say that the account keeps the answers.
  final bool answersReady;

  /// Opens on "Registrieren", for example after skipping the questions.
  final bool startWithSignUp;

  /// Back to the questions, shown together with [answersReady].
  final VoidCallback? onEditAnswers;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _entranceController;
  late bool _isSignUp = widget.answersReady || widget.startWithSignUp;
  bool _loading = false;
  bool _obscurePassword = true;
  String? _message;
  bool _messageIsError = false;
  bool _canResend = false;

  /// Set after sign-up while the confirmation e-mail is pending.
  String? _inboxEmail;

  /// Kept in memory only while the check-inbox page is open. Once the link in
  /// the e-mail was used (often in another browser window), coming back here
  /// signs in automatically, so the answers saved in this window are kept.
  String? _pendingPassword;
  bool _autoSigningIn = false;

  /// Supabase allows one confirmation e-mail per minute; the button waits too.
  static const _resendWait = Duration(seconds: 60);
  DateTime? _resendReadyAt;
  Timer? _resendTicker;

  int get _resendCooldown {
    final ready = _resendReadyAt;
    if (ready == null) return 0;
    final left = ready.difference(DateTime.now()).inMilliseconds;
    return left <= 0 ? 0 : (left / 1000).ceil();
  }

  void _startResendCooldown() {
    _resendReadyAt = DateTime.now().add(_resendWait);
    _resendTicker?.cancel();
    _resendTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      if (_resendCooldown == 0) timer.cancel();
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    final email = widget.initialEmail;
    if (email != null) _emailController.text = email;
    final name = widget.initialName?.trim();
    if (name != null && name.isNotEmpty) _nameController.text = name;
    WidgetsBinding.instance.addObserver(this);
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pendingPassword = null;
    _resendTicker?.cancel();
    _entranceController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _message = null;
      _canResend = false;
    });
    try {
      final auth = Supabase.instance.client.auth;
      if (_isSignUp) {
        final response = await auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          data: {
            'display_name': _nameController.text.trim(),
            'locale': L10n.code,
          },
        );
        if (!mounted) return;
        setState(() {
          if (response.session == null) {
            _inboxEmail = _emailController.text.trim();
            _pendingPassword = _passwordController.text;
            _message = null;
            _startResendCooldown();
          } else {
            _message = L10n.current.authYourLookinAccountIsReady;
            _messageIsError = false;
          }
        });
      } else {
        await auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _message = _friendlyAuthError(error.message);
        _messageIsError = true;
        _canResend = _isUnconfirmed(error.message);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = L10n.current.authConnectionFailedPleaseTryAgain;
        _messageIsError = true;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendConfirmation() async {
    if (_loading || _resendCooldown > 0) return;
    final email = _inboxEmail ?? _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _message = L10n.current.authEnterYourEmailAddressFirst;
        _messageIsError = true;
      });
      return;
    }
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      if (!mounted) return;
      setState(() {
        _message = L10n.current.authIfYourAddressHasNotBeenConfirmed;
        _messageIsError = false;
        _startResendCooldown();
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _message = _friendlyAuthError(error.message);
        _messageIsError = true;
        // Also wait after a server-side limit before trying again.
        _startResendCooldown();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = L10n.current.authConnectionFailedPleaseTryAgain;
        _messageIsError = true;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_loading) return;
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _message = L10n.current.authEnterYourEmailAddressFirst;
        _messageIsError = true;
      });
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
      _canResend = false;
    });
    try {
      // The e-mail template links to the Site URL set in Supabase Auth.
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      setState(() {
        // Supabase does not reveal whether an account exists.
        _message = L10n.current.authIfALookinAccountExistsWithThis;
        _messageIsError = false;
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _message = _friendlyAuthError(error.message);
        _messageIsError = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = L10n.current.authConnectionFailedPleaseTryAgain;
        _messageIsError = true;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setMode(bool signUp) {
    if (_isSignUp == signUp || _loading) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isSignUp = signUp;
      _message = null;
      _canResend = false;
    });
  }

  static bool _isUnconfirmed(String message) =>
      message.toLowerCase().contains('email not confirmed');

  String _friendlyAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return L10n.current.authYourEmailOrPasswordIsIncorrectIf;
    }
    if (_isUnconfirmed(message)) {
      return L10n.current.authYourEmailAddressHasNotBeenConfirmed;
    }
    if (lower.contains('user already registered')) {
      return L10n.current.authAnAccountAlreadyExistsForThisEmail;
    }
    if (lower.contains('security purposes') ||
        lower.contains('rate limit') ||
        lower.contains('too many')) {
      return L10n.current.authTooManyAttemptsPleaseWaitAMoment;
    }
    if (lower.contains('weak') || lower.contains('pwned')) {
      return L10n.current.authThisPasswordIsTooEasyToGuess;
    }
    if (lower.contains('password')) {
      return L10n.current.authYourPasswordMustContainAtLeastEight;
    }
    if (lower.contains('email') && lower.contains('invalid')) {
      return L10n.current.authPleaseCheckYourEmailAddress;
    }
    return L10n.current.authThatDidNotWorkJustNowPlease;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _inboxEmail != null) {
      unawaited(_signInAfterConfirmation(silent: true));
    }
  }

  /// Tries to sign in with the data from sign-up. Fails quietly while the
  /// address is still unconfirmed.
  Future<void> _signInAfterConfirmation({required bool silent}) async {
    final email = _inboxEmail;
    final password = _pendingPassword;
    if (_autoSigningIn || _loading) return;
    if (email == null || password == null) {
      if (!silent) _leaveInbox(toSignIn: true);
      return;
    }
    _autoSigningIn = true;
    if (!silent) setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // The gates take over once the session exists.
      _pendingPassword = null;
    } on AuthException catch (error) {
      if (!mounted || silent) return;
      if (_isUnconfirmed(error.message)) {
        setState(() {
          _message = L10n.current.authYourAddressHasNotBeenConfirmedYet;
          _messageIsError = true;
        });
      } else {
        _leaveInbox(toSignIn: true);
      }
    } catch (_) {
      if (mounted && !silent) {
        setState(() {
          _message = L10n.current.authConnectionFailedPleaseTryAgain;
          _messageIsError = true;
        });
      }
    } finally {
      _autoSigningIn = false;
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  void _leaveInbox({required bool toSignIn}) {
    _pendingPassword = null;
    setState(() {
      _inboxEmail = null;
      _message = null;
      _canResend = false;
      _isSignUp = !toSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inboxEmail = _inboxEmail;
    if (inboxEmail != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _leaveInbox(toSignIn: false);
        },
        child: CheckInboxPage(
          email: inboxEmail,
          resendCooldown: _resendCooldown,
          loading: _loading,
          message: _message,
          messageIsError: _messageIsError,
          onResend: _resendConfirmation,
          onSignIn: () => unawaited(_signInAfterConfirmation(silent: false)),
          onBack: () => _leaveInbox(toSignIn: false),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 900;
              final panel = _AuthPanel(
                formKey: _formKey,
                nameController: _nameController,
                emailController: _emailController,
                passwordController: _passwordController,
                isSignUp: _isSignUp,
                loading: _loading,
                obscurePassword: _obscurePassword,
                message: _message,
                messageIsError: _messageIsError,
                canResend: _canResend,
                resendCooldown: _resendCooldown,
                onResendConfirmation: _resendConfirmation,
                onModeChanged: _setMode,
                onTogglePassword: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onSubmit: _submit,
                onResetPassword: _resetPassword,
              );
              if (!desktop) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(
                            alignment: Alignment.centerRight,
                            child: LanguageSwitch(),
                          ),
                          const SizedBox(height: 6),
                          _Entrance(
                            animation: _entranceController,
                            begin: 0,
                            end: 0.55,
                            child: widget.answersReady
                                ? _AnswersReadyIntro(
                                    onEdit: widget.onEditAnswers,
                                  )
                                : const _MobileIntro(),
                          ),
                          const SizedBox(height: 22),
                          _Entrance(
                            animation: _entranceController,
                            begin: 0.2,
                            end: 1,
                            child: panel,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 44,
                        vertical: 34,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: SizedBox(
                          height: constraints.maxHeight - 68,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 11,
                                child: _Entrance(
                                  animation: _entranceController,
                                  begin: 0,
                                  end: 0.72,
                                  child: widget.answersReady
                                      ? _AnswersReadyIntro(
                                          onEdit: widget.onEditAnswers,
                                        )
                                      : const _AuthStory(),
                                ),
                              ),
                              const SizedBox(width: 54),
                              Expanded(
                                flex: 9,
                                child: _Entrance(
                                  animation: _entranceController,
                                  begin: 0.22,
                                  end: 1,
                                  fromRight: true,
                                  child: panel,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Last child: it must lie above the scrolling page to be tappable.
                  const Positioned(top: 10, right: 30, child: LanguageSwitch()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthPanel extends StatelessWidget {
  const _AuthPanel({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.isSignUp,
    required this.loading,
    required this.obscurePassword,
    required this.message,
    required this.messageIsError,
    required this.canResend,
    required this.resendCooldown,
    required this.onResendConfirmation,
    required this.onModeChanged,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onResetPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSignUp;
  final bool loading;
  final bool obscurePassword;
  final String? message;
  final bool messageIsError;
  final bool canResend;
  final int resendCooldown;
  final VoidCallback onResendConfirmation;
  final ValueChanged<bool> onModeChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onResetPassword;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.surfaceHigh.withValues(alpha: 0.98),
          AppColors.surface.withValues(alpha: 0.98),
        ],
      ),
      borderColor: AppColors.primary.withValues(alpha: 0.34),
      child: AutofillGroup(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ModeSwitch(isSignUp: isSignUp, onChanged: onModeChanged),
              const SizedBox(height: 25),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 330),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Column(
                  key: ValueKey(isSignUp),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSignUp
                          ? context.l10n.authYourStart
                          : context.l10n.authWelcomeBack,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      isSignUp
                          ? context.l10n.authOneAccountForYourGoalsNutritionAnd
                          : context.l10n.authSignInAndPickUpWhereYou,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: isSignUp
                    ? Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            decoration: InputDecoration(
                              labelText: context.l10n.authYourName,
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? context.l10n.authPleaseEnterYourName
                                : null,
                          ),
                          const SizedBox(height: 13),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: context.l10n.authEmailAddress,
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: (value) => value == null || !value.contains('@')
                    ? context.l10n.authPleaseEnterAValidEmailAddress
                    : null,
              ),
              const SizedBox(height: 13),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: [
                  isSignUp ? AutofillHints.newPassword : AutofillHints.password,
                ],
                onFieldSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  labelText: context.l10n.authPassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: onTogglePassword,
                    tooltip: obscurePassword
                        ? context.l10n.authShowPassword
                        : context.l10n.authHidePassword,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        key: ValueKey(obscurePassword),
                      ),
                    ),
                  ),
                ),
                validator: (value) => value == null || value.length < 8
                    ? context.l10n.authAtLeastEightCharacters
                    : null,
              ),
              if (!isSignUp)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: loading ? null : onResetPassword,
                    child: Text(context.l10n.authForgotPassword),
                  ),
                )
              else
                const SizedBox(height: 15),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                child: message == null
                    ? const SizedBox.shrink()
                    : Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              (messageIsError
                                      ? AppColors.error
                                      : AppColors.primary)
                                  .withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color:
                                (messageIsError
                                        ? AppColors.error
                                        : AppColors.primary)
                                    .withValues(alpha: 0.24),
                          ),
                        ),
                        child: Text(
                          message!,
                          style: TextStyle(
                            color: messageIsError
                                ? AppColors.error
                                : AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
              ),
              if (canResend)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextButton.icon(
                    key: const Key('auth-resend-confirmation'),
                    onPressed: loading || resendCooldown > 0
                        ? null
                        : onResendConfirmation,
                    icon: const Icon(Icons.mark_email_unread_outlined),
                    label: Text(resendLabel(resendCooldown)),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: loading ? null : onSubmit,
                  icon: loading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.black,
                          ),
                        )
                      : Icon(
                          isSignUp
                              ? Icons.arrow_forward_rounded
                              : Icons.login_rounded,
                        ),
                  label: Text(
                    isSignUp
                        ? context.l10n.authGetStartedForFree
                        : context.l10n.authSignIn,
                  ),
                ),
              ),
              if (isSignUp) ...[
                const SizedBox(height: 10),
                Text(
                  context.l10n.authByTappingGetStartedForFreeYou,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
                const LegalLinksRow(
                  pages: [
                    LegalPage.terms,
                    LegalPage.privacy,
                    LegalPage.imprint,
                  ],
                ),
              ],
              // Withdrawal must work without signing in (§ 356a BGB).
              if (!isSignUp)
                const LegalLinksRow(
                  pages: [LegalPage.withdrawalForm, LegalPage.imprint],
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.textMuted,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      context.l10n.authSecurelyStoredDeleteAtAnyTime,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.isSignUp, required this.onChanged});

  final bool isSignUp;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: context.l10n.authSignIn2,
              selected: !isSignUp,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ModeButton(
              label: context.l10n.authSignUp,
              selected: isSignUp,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? AppColors.black : AppColors.textMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _AuthStory extends StatelessWidget {
  const _AuthStory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandMark(),
          const Spacer(),
          const _OrbitVisual(),
          const SizedBox(height: 34),
          Text(
            context.l10n.authYourFoodYourRhythm,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 56,
              height: 0.96,
              letterSpacing: -2.8,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.authTrackUnderstandAndMakeBetterChoicesWithout,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              _FeatureChip(Icons.bolt_rounded, context.l10n.authQuick),
              _FeatureChip(Icons.auto_graph_rounded, context.l10n.authPersonal),
              _FeatureChip(Icons.shield_outlined, context.l10n.authPrivate),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// Shown after the questions: the account is what keeps the answers.
class _AnswersReadyIntro extends StatelessWidget {
  const _AnswersReadyIntro({this.onEdit});

  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('auth-answers-ready'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _BrandMark(),
        const SizedBox(height: 24),
        Text(
          context.l10n.authAlmostThere,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.authCreateYourFreeAccountLookinWillThen,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 15,
            height: 1.45,
          ),
        ),
        if (onEdit != null) ...[
          const SizedBox(height: 6),
          TextButton.icon(
            key: const Key('auth-edit-answers'),
            onPressed: onEdit,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: Text(context.l10n.authChangeAnswers),
          ),
        ],
      ],
    );
  }
}

class _MobileIntro extends StatelessWidget {
  const _MobileIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BrandMark(),
        const SizedBox(height: 24),
        Text(
          context.l10n.authYourDayYourRhythm,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.authEatSimplyChooseClearly,
          style: TextStyle(color: AppColors.textMuted, fontSize: 15),
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.mint],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.24),
                blurRadius: 24,
              ),
            ],
          ),
          child: const Icon(Icons.eco_rounded, color: AppColors.black),
        ),
        const SizedBox(width: 12),
        const Text(
          'Lookin',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

class _OrbitVisual extends StatelessWidget {
  const _OrbitVisual();

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 1100),
      curve: Curves.easeOutBack,
      builder: (context, value, _) => Transform.scale(
        scale: 0.82 + value * 0.18,
        child: Opacity(
          opacity: value.clamp(0, 1),
          child: SizedBox(
            height: 184,
            width: 340,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 178,
                  height: 178,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      width: 2,
                    ),
                  ),
                ),
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.25),
                        AppColors.surfaceHigh,
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.42),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        blurRadius: 42,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      SizedBox(height: 7),
                      Text(
                        context.l10n.authToday,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  left: 12,
                  top: 23,
                  child: _OrbitTag('PROTEIN', AppColors.mint),
                ),
                Positioned(
                  right: 0,
                  top: 62,
                  child: _OrbitTag(context.l10n.authEnergy, AppColors.orange),
                ),
                const Positioned(
                  left: 25,
                  bottom: 13,
                  child: _OrbitTag('BALANCE', AppColors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrbitTag extends StatelessWidget {
  const _OrbitTag(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Entrance extends StatelessWidget {
  const _Entrance({
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
    this.fromRight = false,
  });
  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;
  final bool fromRight;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(fromRight ? 0.08 : -0.04, 0.045),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
