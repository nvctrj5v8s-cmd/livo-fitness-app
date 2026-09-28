import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';

/// Asks once and then deletes [entry] from the diary (also in Supabase for
/// saved entries). Returns `true` only when the entry is really gone.
Future<bool> confirmDeleteDiaryEntry(
  BuildContext context,
  MealEntry entry,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Eintrag löschen?'),
      content: Text('„${entry.name}“ wird aus deinem Tagebuch entfernt.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          key: const Key('delete-entry-confirm'),
          onPressed: () => Navigator.pop(dialogContext, true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Löschen'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;
  return AppScope.of(context).removeMeal(entry.id);
}

/// The quiet delete action at the end of both diary edit sheets.
class DeleteEntryButton extends StatelessWidget {
  const DeleteEntryButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton.icon(
      key: const Key('delete-entry'),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.error,
        minimumSize: const Size(48, 48),
      ),
      icon: const Icon(Icons.delete_outline_rounded),
      label: const Text('Eintrag löschen'),
    ),
  );
}
