import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/legal_links_row.dart';
import '../data/withdrawal_repository.dart';

/// Withdrawal function for Lookin Premium (§ 356a BGB): labelled
/// "Vertrag widerrufen", asks only for name and e-mail (no reason), and
/// confirms receipt with date and time right away.
class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({
    required this.repository,
    this.initialName = '',
    super.key,
  });

  final WithdrawalRepository repository;
  final String initialName;

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  late final _name = TextEditingController(text: widget.initialName);
  late final _email = TextEditingController(
    text: widget.repository.currentEmail ?? '',
  );
  final _note = TextEditingController();
  bool _sending = false;
  String? _error;
  WithdrawalReceipt? _receipt;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _note.dispose();
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_email.text.trim());

  Future<void> _confirm() async {
    if (_sending || !_valid) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final receipt = await widget.repository.withdraw(
        name: _name.text.trim(),
        email: _email.text.trim(),
        note: _note.text,
      );
      if (!mounted) return;
      setState(() => _receipt = receipt);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error =
            'Der Widerruf konnte gerade nicht übermittelt werden. Bitte versuche '
            'es erneut oder widerrufe per E-Mail an lookinsupport@gmail.com. '
            'Es zählt, dass du die Erklärung innerhalb der Frist absendest.',
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Vertrag widerrufen'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: _receipt == null ? _form(context) : _done(_receipt!),
          ),
        ),
      ),
    );
  }

  Widget _form(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
    children: [
      const Text(
        'Hier widerrufst du deinen Vertrag über Lookin Premium. Einen Grund '
        'musst du nicht angeben. Du bekommst sofort eine Eingangsbestätigung '
        'mit Datum und Uhrzeit.',
        style: TextStyle(color: AppColors.textMuted, height: 1.45),
      ),
      const SizedBox(height: 18),
      TextField(
        key: const Key('withdrawal-name'),
        controller: _name,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Dein Name'),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 12),
      TextField(
        key: const Key('withdrawal-email'),
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'E-Mail für die Bestätigung',
        ),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 12),
      TextField(
        key: const Key('withdrawal-note'),
        controller: _note,
        maxLength: 300,
        decoration: const InputDecoration(
          labelText: 'Bestellnummer oder Hinweis (freiwillig)',
          helperText: 'Zum Beispiel die Bestellnummer aus der Google-Play-Mail',
        ),
      ),
      if (_error != null) ...[
        const SizedBox(height: 8),
        Text(_error!, style: const TextStyle(color: AppColors.error)),
      ],
      const SizedBox(height: 18),
      FilledButton(
        key: const Key('withdrawal-confirm'),
        onPressed: _sending || !_valid ? null : _confirm,
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
        child: _sending
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Widerruf bestätigen'),
      ),
      const SizedBox(height: 10),
      const LegalLinksRow(pages: [LegalPage.withdrawal]),
    ],
  );

  Widget _done(WithdrawalReceipt receipt) {
    final at = receipt.receivedAt;
    String two(int value) => value.toString().padLeft(2, '0');
    final when =
        '${two(at.day)}.${two(at.month)}.${at.year} um '
        '${two(at.hour)}:${two(at.minute)} Uhr';
    return ListView(
      key: const Key('withdrawal-done'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: AppColors.primary,
          size: 48,
        ),
        const SizedBox(height: 14),
        Text(
          'Dein Widerruf ist am $when eingegangen.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Text(
          receipt.emailSent
              ? 'Wir haben dir eine Eingangsbestätigung an ${_email.text.trim()} '
                    'geschickt. Die Rückzahlung erfolgt über Google Play.'
              : 'Bitte mach einen Screenshot dieser Bestätigung. Eine '
                    'Bestätigung per E-Mail folgt, sobald unser E-Mail-Versand '
                    'eingerichtet ist. Die Rückzahlung erfolgt über Google Play.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted, height: 1.45),
        ),
        if (receipt.reference != null) ...[
          const SizedBox(height: 10),
          Text(
            'Vorgangsnummer: ${receipt.reference}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
        const SizedBox(height: 22),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fertig'),
        ),
      ],
    );
  }
}

/// Opens the withdrawal page for the signed-in account.
Future<void> openWithdrawal(BuildContext context, {String name = ''}) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WithdrawalPage(
          repository: SupabaseWithdrawalRepository(),
          initialName: name,
        ),
      ),
    );
