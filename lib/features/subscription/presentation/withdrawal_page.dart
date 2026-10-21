import 'dart:async';

import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/legal_links_row.dart';
import '../data/store_billing.dart';
import '../data/withdrawal_repository.dart';

/// Withdrawal function for Lookin Premium (§ 356a BGB): labelled
/// "Vertrag widerrufen", asks only for name and e-mail (no reason), and
/// confirms receipt with date and time right away. On an iPhone it also
/// opens Apple's refund request, because only Apple can refund App Store
/// payments.
class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({
    required this.repository,
    this.initialName = '',
    this.billing,
    this.appleStore,
    super.key,
  });

  final WithdrawalRepository repository;
  final String initialName;

  /// Store boundary for Apple's refund request; defaults to the app's one.
  final StoreBilling? billing;

  /// Whether purchases on this device go through the App Store. Detected
  /// from the platform; tests set it.
  final bool? appleStore;

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
  bool _refunding = false;
  StoreRefundResult? _refund;

  bool get _apple =>
      widget.appleStore ??
      (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS);

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
            L10n.current.subscriptionYourWithdrawalCouldNotBeSubmittedJust,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _requestAppleRefund() async {
    if (_refunding) return;
    setState(() => _refunding = true);
    final result = await (widget.billing ?? sharedStoreBilling).requestRefund();
    if (!mounted) return;
    setState(() {
      _refunding = false;
      _refund = result;
    });
    if (result == StoreRefundResult.unavailable) {
      // Older iOS or a store error: Apple's refund website works everywhere.
      // The fallback text names the address in case nothing opens.
      unawaited(
        launchUrl(
          Uri.https('reportaproblem.apple.com'),
          mode: LaunchMode.externalApplication,
        ).then((_) {}, onError: (Object _) {}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(context.l10n.subscriptionWithdrawFromContract),
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
      Text(
        context.l10n.subscriptionHereYouCanWithdrawFromYourLookin,
        style: TextStyle(color: AppColors.textMuted, height: 1.45),
      ),
      const SizedBox(height: 18),
      TextField(
        key: const Key('withdrawal-name'),
        controller: _name,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: context.l10n.subscriptionYourName,
        ),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 12),
      TextField(
        key: const Key('withdrawal-email'),
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: context.l10n.subscriptionEmailForAcknowledgement,
        ),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 12),
      TextField(
        key: const Key('withdrawal-note'),
        controller: _note,
        maxLength: 300,
        decoration: InputDecoration(
          labelText: context.l10n.subscriptionOrderNumberOrNoteOptional,
          helperText: context.l10n.subscriptionForExampleTheOrderNumberFromThe,
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
            : Text(context.l10n.subscriptionConfirmWithdrawal),
      ),
      const SizedBox(height: 10),
      const LegalLinksRow(pages: [LegalPage.withdrawal]),
    ],
  );

  Widget _done(WithdrawalReceipt receipt) {
    final at = receipt.receivedAt;
    String two(int value) => value.toString().padLeft(2, '0');
    final when = L10n.isEnglish
        ? AppFormat.dateTime(at)
        : '${two(at.day)}.${two(at.month)}.${at.year} um '
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
          L10n.current.subscriptionYourWithdrawalWasReceivedOnValue(
            (when).toString(),
          ),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Text(
          receipt.emailSent
              ? L10n.current.subscriptionWeHaveSentAnAcknowledgementToValue(
                  (_email.text.trim()).toString(),
                )
              : L10n
                    .current
                    .subscriptionPleaseTakeAScreenshotOfThisAcknowledgement,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted, height: 1.45),
        ),
        const SizedBox(height: 8),
        if (_apple)
          _AppleRefundCard(
            busy: _refunding,
            result: _refund,
            onRequest: _requestAppleRefund,
          )
        else
          Text(
            L10n.current.subscriptionRefundThroughGooglePlay,
            key: const Key('withdrawal-refund-google'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, height: 1.45),
          ),
        if (receipt.reference != null) ...[
          const SizedBox(height: 10),
          Text(
            L10n.current.subscriptionReferenceNumberValue(
              (receipt.reference).toString(),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
        const SizedBox(height: 22),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(L10n.current.subscriptionDone),
        ),
      ],
    );
  }
}

/// Only Apple can refund App Store payments: one button opens Apple's own
/// refund request (or its website on older iOS).
class _AppleRefundCard extends StatelessWidget {
  const _AppleRefundCard({
    required this.busy,
    required this.result,
    required this.onRequest,
  });

  final bool busy;
  final StoreRefundResult? result;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      key: const Key('withdrawal-apple-refund'),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.subscriptionAppleRefundTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.subscriptionAppleRefundText,
            style: const TextStyle(color: AppColors.textMuted, height: 1.45),
          ),
          const SizedBox(height: 12),
          if (result == StoreRefundResult.submitted)
            Row(
              key: const Key('withdrawal-apple-refund-sent'),
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.subscriptionAppleRefundSubmitted)),
              ],
            )
          else
            FilledButton(
              key: const Key('withdrawal-apple-refund-open'),
              onPressed: busy ? null : onRequest,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: busy
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.subscriptionAppleRefundButton),
            ),
          if (result == StoreRefundResult.unavailable) ...[
            const SizedBox(height: 10),
            Text(
              l10n.subscriptionAppleRefundFallback,
              key: const Key('withdrawal-apple-refund-fallback'),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ],
      ),
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
