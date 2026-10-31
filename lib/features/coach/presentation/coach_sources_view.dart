import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/legal_links_row.dart';
import '../domain/coach_sources.dart';
import 'coach_formatted_text.dart';

class CoachSourcesButton extends StatelessWidget {
  const CoachSourcesButton({super.key});

  @override
  Widget build(BuildContext context) => TextButton.icon(
    key: const Key('coach-sources'),
    onPressed: () => showCoachSources(context),
    icon: const Icon(Icons.menu_book_outlined, size: 18),
    label: Text(context.l10n.coachSourcesAndLimits),
  );
}

Future<void> showCoachSources(
  BuildContext context,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: .8,
    maxChildSize: .95,
    builder: (context, scroll) => Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.coachSourcesAndLimits,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              const SizedBox(height: 12),
              Text(
                context.l10n.coachHealthLimits,
                style: const TextStyle(height: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.coachSourceScope,
                style: const TextStyle(color: AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 12),
              for (final source in coachSources) _SourceLink(source: source),
              const SizedBox(height: 12),
              Text(
                context.l10n.coachExternalSourcePrivacy,
                style: const TextStyle(color: AppColors.textMuted, height: 1.4),
              ),
              const LegalLinksRow(
                pages: [LegalPage.terms, LegalPage.privacy],
                alignment: WrapAlignment.start,
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);

/// Display the exact references saved with this answer, including after reload.
class CitedCoachText extends StatelessWidget {
  const CitedCoachText(
    this.text, {
    required this.style,
    this.opener,
    super.key,
  });

  final String text;
  final TextStyle style;
  final Future<bool> Function(Uri)? opener;

  @override
  Widget build(BuildContext context) {
    final answer = parseCitedCoachAnswer(text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CoachFormattedText(
          answer.text,
          style: style,
          citationBuilder: (number, occurrence) {
            if (number < 1 || number > answer.sources.length) return null;
            return _InlineSourceChip(
              source: answer.sources[number - 1],
              number: number,
              occurrence: occurrence,
              opener: opener,
            );
          },
        ),
        if (answer.sources.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            '${context.l10n.coachAnswerSources} (${answer.sources.length})',
            style: style.copyWith(fontWeight: FontWeight.w700),
          ),
          for (final (index, source) in answer.sources.indexed)
            _SourceLink(source: source, number: index + 1, opener: opener),
          Text(
            context.l10n.coachSourcesDoNotVerifyEstimates,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ] else ...[
          const SizedBox(height: 10),
          Text(
            context.l10n.coachNoAnswerSources,
            key: const Key('coach-no-answer-sources'),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _InlineSourceChip extends StatelessWidget {
  const _InlineSourceChip({
    required this.source,
    required this.number,
    required this.occurrence,
    this.opener,
  });

  final CoachSource source;
  final int number;
  final int occurrence;
  final Future<bool> Function(Uri)? opener;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 190),
    child: TextButton(
      key: ValueKey('inline-source-${source.id}-$number-$occurrence'),
      onPressed: () => openExternalLink(context, source.uri, opener: opener),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.mint,
        backgroundColor: AppColors.surfaceSoft,
        minimumSize: const Size(48, 40),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tapTargetSize: MaterialTapTargetSize.padded,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        '[$number] ${source.title}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11),
      ),
    ),
  );
}

class _SourceLink extends StatelessWidget {
  const _SourceLink({required this.source, this.number, this.opener});

  final CoachSource source;
  final int? number;
  final Future<bool> Function(Uri)? opener;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: OutlinedButton(
      key: ValueKey('source-${source.id}'),
      onPressed: () => openExternalLink(context, source.uri, opener: opener),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.mint,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(12),
        minimumSize: const Size(48, 48),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${number == null ? '' : '[$number] '}${source.title}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.open_in_new, size: 16),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            source.summary,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(source.url, style: const TextStyle(fontSize: 11, height: 1.4)),
        ],
      ),
    ),
  );
}
