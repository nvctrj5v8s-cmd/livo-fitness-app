import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:fitness_ai_app/l10n/display_text.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/allergy_safety.dart';

class AllergyProfileField extends StatelessWidget {
  const AllergyProfileField({
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final selected = AllergySafety.selectedIds(value);
    final labels = [
      for (final option in AllergySafety.allergens)
        if (selected.contains(option.id)) DisplayText.of(option.label),
      ...AllergySafety.otherEntries(value),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wraps the button below the title on narrow screens or large text.
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              context.l10n.allergiesAllergiesIntolerances,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            TextButton.icon(
              key: const Key('edit-allergies'),
              onPressed: enabled ? () => _openEditor(context) : null,
              icon: const Icon(Icons.tune_rounded, size: 17),
              label: Text(
                labels.isEmpty
                    ? context.l10n.allergiesSelect
                    : context.l10n.allergiesChange,
              ),
            ),
          ],
        ),
        if (labels.isEmpty)
          Text(
            context.l10n.allergiesNoneSpecified,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 2,
            children: [
              for (final label in labels)
                Chip(visualDensity: VisualDensity.compact, label: Text(label)),
            ],
          ),
      ],
    );
  }

  Future<void> _openEditor(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      builder: (_) => _AllergyEditor(initialValue: value),
    );
    if (result != null) onChanged(result);
  }
}

class AllergySafetyNotice extends StatelessWidget {
  const AllergySafetyNotice({required this.assessment, super.key});
  final AllergyAssessment assessment;

  @override
  Widget build(BuildContext context) {
    if (!assessment.hasProfile) return const SizedBox.shrink();
    final conflict = assessment.hasConflict;
    final unknown = assessment.dataUnknown;
    final conflictNames = assessment.conflicts.map(DisplayText.of).join(', ');
    final color = conflict ? AppColors.error : AppColors.orange;
    final title = conflict
        ? context.l10n.allergiesPossibleAllergenConflict
        : unknown
        ? context.l10n.allergiesAllergyInformationMissing
        : context.l10n.allergiesPleaseCheckTheIngredientsList;
    final details = conflict
        ? context.l10n
              .allergiesTheAvailableProductOrIngredientInformationMentions(
                (conflictNames).toString(),
              )
        : unknown
        ? context.l10n.allergiesNoReliableAllergenOrIngredientInformationIs
        : context.l10n.allergiesNoneOfYourSelectedTriggersWereRecognised;
    return Container(
      key: const Key('allergy-safety-notice'),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: .5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            conflict ? Icons.warning_amber_rounded : Icons.fact_check_outlined,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  context.l10n.allergiesValueIfYouHaveAllergiesAlwaysCheck(
                    (details).toString(),
                  ),
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllergyEditor extends StatefulWidget {
  const _AllergyEditor({required this.initialValue});
  final String initialValue;
  @override
  State<_AllergyEditor> createState() => _AllergyEditorState();
}

class _AllergyEditorState extends State<_AllergyEditor> {
  late final Set<String> _selected;
  late final TextEditingController _other;

  @override
  void initState() {
    super.initState();
    _selected = AllergySafety.selectedIds(widget.initialValue);
    _other = TextEditingController(
      text: AllergySafety.otherEntries(widget.initialValue).join(', '),
    );
  }

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    heightFactor: .88,
    child: Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.allergiesWhatShouldTheAppTakeIntoAccount,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.allergiesClose,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                context
                    .l10n
                    .allergiesSelectKnownAllergensLactoseIsListedSeparately,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in AllergySafety.allergens)
                    FilterChip(
                      key: ValueKey(option.id),
                      label: Text(DisplayText.of(option.label)),
                      selected: _selected.contains(option.id),
                      showCheckmark: true,
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          _selected.add(option.id);
                        } else {
                          _selected.remove(option.id);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                key: const Key('other-allergies'),
                controller: _other,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: context.l10n.allergiesOtherAllergiesIntolerances,
                  hintText: context.l10n.allergiesEGCoconutHistamine,
                  helperText:
                      context.l10n.allergiesSeparateMultipleEntriesWithCommas,
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.allergiesProductInformationMayBeMissingOrOutdated,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.allergiesOptionalHealthInformationItIsSavedIn,
                key: Key('allergy-privacy-note'),
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('save-allergies'),
              onPressed: () => Navigator.pop(
                context,
                AllergySafety.encode(_selected, _other.text),
              ),
              child: Text(context.l10n.allergiesSaveSelection),
            ),
          ),
        ),
      ],
    ),
  );
}
