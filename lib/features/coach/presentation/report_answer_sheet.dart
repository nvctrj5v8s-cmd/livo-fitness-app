import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/support_contact.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/l10n.dart';

/// Reasons a person can pick when reporting an answer of the AI coach.
enum ReportReason { wrong, unsafe, inappropriate, other }

extension on ReportReason {
  String label(AppLocalizations l10n) => switch (this) {
    ReportReason.wrong => l10n.coachReportReasonWrong,
    ReportReason.unsafe => l10n.coachReportReasonUnsafe,
    ReportReason.inappropriate => l10n.coachReportReasonInappropriate,
    ReportReason.other => l10n.coachReportReasonOther,
  };
}

/// Text of the prepared e-mail. The answer is cut so the link stays usable.
String buildReportBody(
  AppLocalizations l10n, {
  required ReportReason reason,
  required String answer,
}) {
  const maxAnswer = 1200;
  final text = answer.length > maxAnswer
      ? '${answer.substring(0, maxAnswer)} …'
      : answer;
  return '${l10n.coachReportMailNotice}\n\n'
      '${l10n.coachReportMailReason(reason.label(l10n))}\n\n'
      '${l10n.coachReportMailAnswerLabel}\n$text\n';
}

/// "Report answer": a small sheet that prepares an e-mail to support. The
/// mail app opens with the answer included; the person reviews and sends it.
Future<void> showReportAnswerSheet(
  BuildContext context, {
  required String answer,
  Future<bool> Function(Uri uri)? opener,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.backgroundRaised,
    builder: (_) => _ReportAnswerSheet(answer: answer, opener: opener),
  );
}

class _ReportAnswerSheet extends StatefulWidget {
  const _ReportAnswerSheet({required this.answer, this.opener});

  final String answer;
  final Future<bool> Function(Uri uri)? opener;

  @override
  State<_ReportAnswerSheet> createState() => _ReportAnswerSheetState();
}

class _ReportAnswerSheetState extends State<_ReportAnswerSheet> {
  ReportReason _reason = ReportReason.wrong;
  bool _busy = false;

  Future<void> _send() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final opened = await SupportContact.open(
      subject: l10n.coachReportMailSubject,
      body: buildReportBody(l10n, reason: _reason, answer: widget.answer),
      opener: widget.opener,
    );
    if (!mounted) return;
    if (opened) {
      navigator.pop();
    } else {
      setState(() => _busy = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.coachReportMailNotOpened(SupportContact.email)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.coachReportSheetTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.coachReportSheetText,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            RadioGroup<ReportReason>(
              groupValue: _reason,
              onChanged: (value) {
                if (value == null) return;
                HapticFeedback.selectionClick();
                setState(() => _reason = value);
              },
              child: Column(
                children: [
                  for (final reason in ReportReason.values)
                    RadioListTile<ReportReason>(
                      key: Key('report-reason-${reason.name}'),
                      value: reason,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                      title: Text(reason.label(l10n)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              key: const Key('report-send'),
              onPressed: _busy ? null : () => unawaited(_send()),
              icon: const Icon(Icons.mail_outline_rounded),
              label: Text(l10n.coachReportPrepareEmail),
            ),
          ],
        ),
      ),
    );
  }
}
