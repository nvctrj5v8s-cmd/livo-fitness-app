import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/data/account_data_repository.dart';
import '../../../core/theme/app_colors.dart';

class AccountDataActions extends StatefulWidget {
  const AccountDataActions({super.key});

  @override
  State<AccountDataActions> createState() => _AccountDataActionsState();
}

class _AccountDataActionsState extends State<AccountDataActions> {
  final _repository = AccountDataRepository();
  bool _busy = false;
  String? _status;
  bool _isError = false;

  void _showStatus(String text, {bool error = false}) {
    if (!mounted) return;
    setState(() {
      _status = text;
      _isError = error;
    });
  }

  Future<void> _export() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final bytes = await _repository.exportCurrentAccount();
      if (!mounted) return;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final location = await FileSaver.instance.saveAs(
        name: 'lookin-daten-$today',
        bytes: bytes,
        fileExtension: 'json',
        mimeType: MimeType.json,
      );
      _showStatus(
        location == null
            ? 'Speichern abgebrochen.'
            : 'Deine Daten wurden als JSON-Datei gespeichert.',
      );
    } catch (_) {
      _showStatus(
        'Der Export hat nicht geklappt. Bitte pr\u00FCfe deine Verbindung und versuche es erneut.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    if (_busy) return;
    final password = await showDialog<String>(
      context: context,
      builder: (_) => _DeleteAccountDialog(email: _repository.currentEmail),
    );
    if (password == null || !mounted) return;
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      await _repository.deleteCurrentAccount(password);
      // AuthGate returns to the sign-in page after signOut.
    } on FunctionException catch (error) {
      _showStatus(
        error.status == 403
            ? 'Das Passwort stimmt nicht. Dein Konto wurde nicht gel\u00F6scht.'
            : 'Das Konto konnte nicht gel\u00F6scht werden. Bitte versuche es erneut.',
        error: true,
      );
    } on StateError catch (error) {
      _showStatus(error.message.toString(), error: true);
    } catch (_) {
      _showStatus(
        'Das Konto konnte nicht vollst\u00E4ndig gel\u00F6scht werden. Bitte pr\u00FCfe, ob du noch angemeldet bist.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.tonalIcon(
          key: const Key('export-account-data'),
          onPressed: _busy ? null : _export,
          icon: const Icon(Icons.download_rounded),
          label: const Text('Meine Daten exportieren'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Der Export enth\u00E4lt auch Gesundheits- und Chatdaten. Bewahre die Datei sicher auf.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const Key('delete-account'),
          onPressed: _busy ? null : _delete,
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
          icon: const Icon(Icons.person_remove_outlined),
          label: const Text('Konto und Kontodaten l\u00F6schen'),
        ),
        if (_busy)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (_status != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              _status!,
              style: TextStyle(
                color: _isError ? AppColors.error : AppColors.primary,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.email});
  final String? email;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Konto endg\u00FCltig l\u00F6schen?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dein Konto${widget.email == null ? '' : ' (${widget.email})'} '
              'und die dazugeh\u00F6rigen Daten werden gel\u00F6scht. '
              'Das kann nicht r\u00FCckg\u00E4ngig gemacht werden. '
              'Ein sp\u00E4teres Store-Abo m\u00FCsstest du separat im Store k\u00FCndigen.',
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _password,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Passwort zur Best\u00E4tigung',
                suffixIcon: IconButton(
                  tooltip: _obscure
                      ? 'Passwort anzeigen'
                      : 'Passwort verbergen',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _password.text.isEmpty
              ? null
              : () => Navigator.pop(context, _password.text),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Konto l\u00F6schen'),
        ),
      ],
    );
  }
}
