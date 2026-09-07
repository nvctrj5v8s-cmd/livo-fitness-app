import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _entranceController;
  bool _isSignUp = false;
  bool _loading = false;
  bool _obscurePassword = true;
  String? _message;
  bool _messageIsError = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
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
    });
    try {
      final auth = Supabase.instance.client.auth;
      if (_isSignUp) {
        final response = await auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          data: {'display_name': _nameController.text.trim()},
        );
        if (!mounted) return;
        setState(() {
          _message = response.session == null
              ? 'Fast geschafft: Bestätige zuerst deine E-Mail-Adresse.'
              : 'Dein LIVO-Konto ist bereit.';
          _messageIsError = false;
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
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'Verbindung fehlgeschlagen. Bitte versuche es erneut.';
        _messageIsError = true;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _message = 'Gib zuerst deine E-Mail-Adresse ein.';
        _messageIsError = true;
      });
      return;
    }
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      setState(() {
        _message = 'Wir haben dir einen Link zum Zurücksetzen geschickt.';
        _messageIsError = false;
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _message = _friendlyAuthError(error.message);
        _messageIsError = true;
      });
    }
  }

  void _setMode(bool signUp) {
    if (_isSignUp == signUp || _loading) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isSignUp = signUp;
      _message = null;
    });
  }

  String _friendlyAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'E-Mail oder Passwort ist nicht korrekt.';
    }
    if (lower.contains('user already registered')) {
      return 'Für diese E-Mail gibt es bereits ein Konto.';
    }
    if (lower.contains('password')) {
      return 'Das Passwort muss mindestens sechs Zeichen haben.';
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
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
                          _Entrance(
                            animation: _entranceController,
                            begin: 0,
                            end: 0.55,
                            child: const _MobileIntro(),
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
              return Center(
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
                              child: const _AuthStory(),
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
                      isSignUp ? 'Dein Start.' : 'Willkommen zurück.',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      isSignUp
                          ? 'Ein Konto für Ziele, Ernährung und Fortschritt.'
                          : 'Einloggen und direkt dort weitermachen, wo du aufgehört hast.',
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
                            decoration: const InputDecoration(
                              labelText: 'Dein Name',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Bitte gib deinen Namen ein.'
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
                decoration: const InputDecoration(
                  labelText: 'E-Mail-Adresse',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: (value) => value == null || !value.contains('@')
                    ? 'Bitte gib eine gültige E-Mail ein.'
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
                  labelText: 'Passwort',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: onTogglePassword,
                    tooltip: obscurePassword
                        ? 'Passwort anzeigen'
                        : 'Passwort verbergen',
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
                validator: (value) => value == null || value.length < 6
                    ? 'Mindestens sechs Zeichen.'
                    : null,
              ),
              if (!isSignUp)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: loading ? null : onResetPassword,
                    child: const Text('Passwort vergessen?'),
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
                  label: Text(isSignUp ? 'Kostenlos starten' : 'Einloggen'),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.textMuted,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Sicher gespeichert · jederzeit löschbar',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
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
              label: 'Anmelden',
              selected: !isSignUp,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ModeButton(
              label: 'Registrieren',
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
            'Dein Essen.\nDein Rhythmus.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 56,
              height: 0.96,
              letterSpacing: -2.8,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Tracken, verstehen und besser entscheiden — ohne komplizierte Tabellen.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              _FeatureChip(Icons.bolt_rounded, 'Schnell'),
              _FeatureChip(Icons.auto_graph_rounded, 'Persönlich'),
              _FeatureChip(Icons.shield_outlined, 'Privat'),
            ],
          ),
          const Spacer(),
        ],
      ),
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
          'Dein Alltag.\nDein Rhythmus.',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 10),
        const Text(
          'Einfach essen. Klarer entscheiden.',
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
          'LIVO',
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
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      SizedBox(height: 7),
                      Text(
                        'HEUTE',
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
                const Positioned(
                  right: 0,
                  top: 62,
                  child: _OrbitTag('ENERGIE', AppColors.orange),
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
