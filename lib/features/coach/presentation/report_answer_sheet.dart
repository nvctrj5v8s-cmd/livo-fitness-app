import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/data/ai_coach_service.dart';
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

/// Sends one report; replaceable in tests.
typedef SubmitAnswerReport =
    Future<AnswerReportResult> Function(ReportReason reason, String answer);

/// "Report answer": a small sheet that sends the report right inside the app
/// (Google Play requires reporting without leaving the app). The server keeps
/// the reason, the answer and the account for at most 12 months.
Future<void> showReportAnswerSheet(
  BuildContext context, {
  required String answer,
  SubmitAnswerReport? submit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.backgroundRaised,
    builder: (_) => _ReportAnswerSheet(
      answer: answer,
      submit:
          submit ??
          (reason, answer) => AiCoachService().reportAnswer(
            reason: reason.name,
            answer: answer,
          ),
    ),
  );
}

class _ReportAnswerSheet extends StatefulWidget {
  const _ReportAnswerSheet({required this.answer, required this.submit});

  final String answer;
  final SubmitAnswerReport submit;

  @override
  State<_ReportAnswerSheet> createState() => _ReportAnswerSheetState();
}

class _ReportAnswerSheetState extends State<_ReportAnswerSheet> {
  ReportReason _reason = ReportReason.wrong;
  bool _busy = false;
  String? _error;

  Future<void> _send() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final result = await widget.submit(_reason, widget.answer);
    if (!mounted) return;
    switch (result) {
      case AnswerReportResult.sent:
        unawaited(HapticFeedback.lightImpact());
        navigator.pop();
        messenger.showSnackBar(SnackBar(content: Text(l10n.coachReportThanks)));
      case AnswerReportResult.limit:
        setState(() {
          _busy = false;
          _error = l10n.coachReportLimit;
        });
      case AnswerReportResult.failed:
        setState(() {
          _busy = false;
          _error = l10n.coachReportFailed;
        });
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
                if (value == null || _busy) return;
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
            if (_error case final error?) ...[
              const SizedBox(height: 6),
              Row(
                key: const Key('report-error'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('report-send'),
              onPressed: _busy ? null : () => unawaited(_send()),
              icon: _busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.black,
                      ),
                    )
                  : const Icon(Icons.outlined_flag_rounded),
              label: Text(l10n.coachReportSend),
            ),
          ],
        ),
      ),
    );
  }
}
