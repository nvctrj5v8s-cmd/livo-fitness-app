import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';

/// Message for the sign-in page after a new password was saved. The app shows
/// it once the recovery session has ended.
final passwordSavedNotice = ValueNotifier<String?>(null);

/// Shown only after a verified Supabase password-recovery callback.
class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({super.key});

  @override
  State<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = Supabase.instance.client.auth;
      await auth.updateUser(UserAttributes(password: _password.text));
      passwordSavedNotice.value =
          L10n.current.authYourNewPasswordHasBeenSavedSign;
      // A recovery link grants a temporary session. Require a fresh login.
      await auth.signOut(scope: SignOutScope.local);
    } on AuthException catch (error) {
      if (mounted) {
        setState(() => _error = _saveError(error));
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = L10n.current.authConnectionFailedPleaseTryAgain,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _saveError(AuthException error) {
    final text = '${error.code ?? ''} ${error.message}'.toLowerCase();
    if (text.contains('same_password') ||
        text.contains('different from the old')) {
      return L10n.current.authYourNewPasswordMustBeDifferentFrom;
    }
    if (text.contains('weak_password') || text.contains('at least')) {
      return L10n.current.authYourPasswordIsTooWeakPleaseUse;
    }
    return L10n.current.authYourPasswordCouldNotBeSetRequest;
  }

  Future<void> _cancel() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
    } catch (_) {
      if (mounted) {
        setState(() => _error = L10n.current.authSignOutFailedPleaseTryAgain);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SurfaceCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.lock_reset_rounded,
                          size: 42,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          context.l10n.authNewPassword,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(context.l10n.authChooseANewPasswordYouWillThen),
                        const SizedBox(height: 22),
                        TextFormField(
                          key: const Key('recovery-password'),
                          controller: _password,
                          obscureText: _obscure,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: InputDecoration(
                            labelText: context.l10n.authNewPassword,
                            suffixIcon: IconButton(
                              tooltip: _obscure
                                  ? context.l10n.authShowPassword
                                  : context.l10n.authHidePassword,
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.length < 8
                              ? context.l10n.authAtLeastEightCharacters
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          key: const Key('recovery-confirmation'),
                          controller: _confirmation,
                          obscureText: _obscure,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: InputDecoration(
                            labelText: context.l10n.authRepeatPassword,
                          ),
                          validator: (value) => value != _password.text
                              ? context.l10n.authThePasswordsDoNotMatch
                              : null,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            _error!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ],
                        const SizedBox(height: 22),
                        FilledButton(
                          key: const Key('recovery-save'),
                          onPressed: _busy ? null : _save,
                          child: _busy
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(context.l10n.authSavePassword),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _busy ? null : _cancel,
                          child: Text(context.l10n.authCancelAndReturnToSignIn),
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
