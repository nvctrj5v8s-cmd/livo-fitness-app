import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';

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
      // A recovery link grants a temporary session. Require a fresh login.
      await auth.signOut(scope: SignOutScope.local);
    } on AuthException catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Das Passwort konnte nicht gesetzt werden. Bitte fordere einen neuen Link an.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Verbindung fehlgeschlagen. Bitte versuche es erneut.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Abmelden fehlgeschlagen. Bitte versuche es erneut.',
        );
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
                          'Neues Passwort',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Wähle ein neues Passwort. Danach meldest du dich damit erneut an.',
                        ),
                        const SizedBox(height: 22),
                        TextFormField(
                          key: const Key('recovery-password'),
                          controller: _password,
                          obscureText: _obscure,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: InputDecoration(
                            labelText: 'Neues Passwort',
                            suffixIcon: IconButton(
                              tooltip: _obscure
                                  ? 'Passwort anzeigen'
                                  : 'Passwort verbergen',
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
                              ? 'Mindestens acht Zeichen.'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          key: const Key('recovery-confirmation'),
                          controller: _confirmation,
                          obscureText: _obscure,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: const InputDecoration(
                            labelText: 'Passwort wiederholen',
                          ),
                          validator: (value) => value != _password.text
                              ? 'Die Passwörter stimmen nicht überein.'
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
                              : const Text('Passwort speichern'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _busy ? null : _cancel,
                          child: const Text('Abbrechen und zum Login'),
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
