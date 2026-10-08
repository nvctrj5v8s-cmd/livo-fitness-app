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
        if (selected.contains(option.id)) option.label,
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
            const Text(
              'Allergien & Unvertr\u00E4glichkeiten',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            TextButton.icon(
              key: const Key('edit-allergies'),
              onPressed: enabled ? () => _openEditor(context) : null,
              icon: const Icon(Icons.tune_rounded, size: 17),
              label: Text(labels.isEmpty ? 'Ausw\u00E4hlen' : '\u00C4ndern'),
            ),
          ],
        ),
        if (labels.isEmpty)
          const Text(
            'Keine angegeben',
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
    final conflictNames = assessment.conflicts.join(', ');
    final color = conflict ? AppColors.error : AppColors.orange;
    final title = conflict
        ? 'M\u00F6glicher Allergenkonflikt'
        : unknown
        ? 'Allergieangaben fehlen'
        : 'Bitte Zutatenliste pr\u00FCfen';
    final details = conflict
        ? 'Die verf\u00FCgbaren Produkt-/Zutatenangaben nennen: $conflictNames.'
        : unknown
        ? 'Zu diesem Eintrag liegen keine verl\u00E4sslichen Allergen- oder Zutatenangaben vor.'
        : 'In den vorhandenen Angaben wurde kein gew\u00E4hlter Ausl\u00F6ser erkannt. Das ist keine Sicherheitsgarantie.';
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
                  '$details Pr\u00FCfe bei Allergien immer die aktuelle Verpackung und m\u00F6gliche Kreuzkontamination.',
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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 12, 10),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Was soll die App beachten?',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Schlie\u00DFen',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'W\u00E4hle bekannte Allergene aus. Laktose ist separat als Unvertr\u00E4glichkeit aufgef\u00FChrt.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in AllergySafety.allergens)
                    FilterChip(
                      key: ValueKey(option.id),
                      label: Text(option.label),
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
                decoration: const InputDecoration(
                  labelText: 'Weitere Allergien / Unvertr\u00E4glichkeiten',
                  hintText: 'z. B. Kokos, Histamin',
                  helperText: 'Mehrere Angaben mit Komma trennen.',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Produktangaben k\u00F6nnen fehlen oder veraltet sein. Pr\u00FCfe bei einer Allergie immer die aktuelle Verpackung und m\u00F6gliche Kreuzkontamination.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Freiwillige Gesundheitsangabe: Sie wird in deinem Konto '
                'gespeichert und dem Lookin Coach als Kontext mitgegeben, damit er '
                'nichts Unpassendes vorschl\u00E4gt. Du kannst sie hier jederzeit '
                '\u00E4ndern oder leeren.',
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
              child: const Text('Auswahl speichern'),
            ),
          ),
        ),
      ],
    ),
  );
}
