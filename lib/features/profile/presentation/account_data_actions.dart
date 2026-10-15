import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/data/account_data_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/legal_links_row.dart';
import '../../subscription/application/subscription_controller.dart';
import '../../subscription/domain/entitlement.dart';

class AccountDataActions extends StatefulWidget {
  const AccountDataActions({this.subscription, super.key});

  /// Used to warn before deleting an account with a running store
  /// subscription, which deleting the account does not cancel.
  final SubscriptionController? subscription;

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
            ? L10n.current.profileSavingCancelled
            : L10n.current.profileYourDataHasBeenSavedAsA,
      );
    } catch (_) {
      _showStatus(
        L10n.current.profileExportFailedPleaseCheckYourConnectionAnd,
        error: true,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool get _hasStoreSubscription {
    final subscription = widget.subscription;
    return subscription != null &&
        subscription.entitlement.kind == EntitlementKind.subscription &&
        subscription.hasPremium;
  }

  Future<void> _delete() async {
    if (_busy) return;
    final password = await showDialog<String>(
      context: context,
      builder: (_) => DeleteAccountDialog(
        email: _repository.currentEmail,
        storeSubscription: _hasStoreSubscription,
        managementUri: widget.subscription?.managementUri,
      ),
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
            ? L10n.current.profileYourPasswordIsIncorrectYourAccountWas
            : L10n.current.profileYourAccountCouldNotBeDeletedPlease,
        error: true,
      );
    } on StateError catch (error) {
      _showStatus(error.message.toString(), error: true);
    } catch (_) {
      _showStatus(
        L10n.current.profileYourAccountCouldNotBeCompletelyDeleted,
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
          label: Text(context.l10n.profileExportMyData),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.profileTheExportAlsoContainsHealthAndChat,
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const Key('delete-account'),
          onPressed: _busy ? null : _delete,
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
          icon: const Icon(Icons.person_remove_outlined),
          label: Text(context.l10n.profileDeleteAccountAndAccountData),
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

@visibleForTesting
class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({
    required this.email,
    this.storeSubscription = false,
    this.managementUri,
    super.key,
  });
  final String? email;

  /// The account has a running store subscription.
  final bool storeSubscription;
  final Uri? managementUri;

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
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
      title: Text(context.l10n.profilePermanentlyDeleteAccount),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.profileYourAccountValueAndItsAssociatedData(
                (widget.email == null ? '' : ' (${widget.email})').toString(),
              ),
            ),
            if (widget.storeSubscription) ...[
              const SizedBox(height: 14),
              Container(
                key: const Key('delete-subscription-warning'),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.6),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.profileYourPremiumSubscriptionWillContinue,
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.profileDeletingYourAccountDoesNotCancelYour,
                    ),
                    if (widget.managementUri != null)
                      TextButton.icon(
                        key: const Key('delete-open-subscriptions'),
                        onPressed: () =>
                            openExternalLink(context, widget.managementUri!),
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: Text(context.l10n.profileOpenStoreSubscriptions),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            TextField(
              controller: _password,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: context.l10n.profilePasswordToConfirm,
                suffixIcon: IconButton(
                  tooltip: _obscure
                      ? context.l10n.profileShowPassword
                      : context.l10n.profileHidePassword,
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
          child: Text(context.l10n.profileCancel),
        ),
        FilledButton(
          onPressed: _password.text.isEmpty
              ? null
              : () => Navigator.pop(context, _password.text),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: Text(context.l10n.profileDeleteAccount),
        ),
      ],
    );
  }
}
