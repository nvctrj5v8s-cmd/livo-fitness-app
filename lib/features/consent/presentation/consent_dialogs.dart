import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/legal_links_row.dart';
import '../../coach/presentation/coach_sources_view.dart';
import '../application/consent_controller.dart';
import '../domain/consent.dart';

/// Asks for consent before health data is stored in the account. Returns
/// whether it is (now) granted. Asks again after an earlier "no".
Future<bool> ensureHealthConsent(
  BuildContext context,
  ConsentController consent,
) => _ensure(
  context,
  consent,
  kind: ConsentKind.healthData,
  title: ConsentTexts.healthTitle,
  text: ConsentTexts.health,
);

/// Asks for consent before anything is sent to the AI provider.
Future<bool> ensureAiConsent(BuildContext context, ConsentController consent) =>
    _ensure(
      context,
      consent,
      kind: ConsentKind.aiProcessing,
      title: ConsentTexts.aiTitle,
      text: ConsentTexts.ai,
    );

Future<bool> _ensure(
  BuildContext context,
  ConsentController consent, {
  required ConsentKind kind,
  required String title,
  required String text,
}) async {
  if (consent.decision(kind) == true) return true;
  final granted = await showDialog<bool>(
    context: context,
    builder: (_) => ConsentDialog(
      title: title,
      text: text,
      showAiNotice: kind == ConsentKind.aiProcessing,
    ),
  );
  if (granted != true) return false;
  final stored = await consent.set(kind, true);
  if (!stored && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.consentConsentCouldNotBeSaved)),
    );
  }
  return stored;
}

/// One consent with a checkbox that is never pre-ticked. The button stays
/// disabled until the box is ticked, so agreeing is always a deliberate act.
class ConsentDialog extends StatefulWidget {
  const ConsentDialog({
    required this.title,
    required this.text,
    this.showAiNotice = false,
    super.key,
  });

  final String title;
  final String text;
  final bool showAiNotice;

  @override
  State<ConsentDialog> createState() => _ConsentDialogState();
}

class _ConsentDialogState extends State<ConsentDialog> {
  bool _ticked = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showAiNotice) ...[
              Text(
                context.l10n.coachHealthLimits,
                style: const TextStyle(height: 1.4),
              ),
              const CoachSourcesButton(),
            ],
            CheckboxListTile(
              key: const Key('consent-dialog-checkbox'),
              value: _ticked,
              onChanged: (value) => setState(() => _ticked = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text(widget.text, style: const TextStyle(height: 1.4)),
            ),
            const SizedBox(height: 6),
            Text(
              ConsentTexts.revocableNote,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const LegalLinksRow(
              pages: [LegalPage.terms, LegalPage.privacy],
              alignment: WrapAlignment.start,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.consentNotNow),
        ),
        FilledButton(
          key: const Key('consent-dialog-confirm'),
          onPressed: _ticked ? () => Navigator.pop(context, true) : null,
          child: Text(context.l10n.consentGiveConsent),
        ),
      ],
    );
  }
}
