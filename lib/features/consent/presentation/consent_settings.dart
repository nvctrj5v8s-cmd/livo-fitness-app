import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';
import '../domain/consent.dart';
import 'consent_dialogs.dart';

/// Switches to give or revoke each consent at any time (Art. 7 Abs. 3 DSGVO).
class ConsentSettingsCard extends StatelessWidget {
  const ConsentSettingsCard({required this.controller, super.key});

  final AppController controller;

  Future<void> _setHealth(BuildContext context, bool value) async {
    final consent = controller.consent;
    if (value) {
      await ensureHealthConsent(context, consent);
      return;
    }
    final confirmed = await _confirm(
      context,
      title: 'Einwilligung widerrufen?',
      text:
          'Wir löschen dann deine Gesundheitsangaben in deinem Konto '
          '(Allergien, Zielgewicht, Gewichts- und Taillenwerte). Auf diesem '
          'Gerät bleiben deine Angaben erhalten.',
      action: 'Widerrufen und löschen',
    );
    if (!confirmed) return;
    await consent.set(ConsentKind.healthData, false);
    unawaited(controller.clearAccountHealthData());
  }

  Future<void> _setAi(BuildContext context, bool value) async {
    final consent = controller.consent;
    if (value) {
      await ensureAiConsent(context, consent);
      return;
    }
    final confirmed = await _confirm(
      context,
      title: 'Einwilligung widerrufen?',
      text:
          'KI-Coach und KI-Foto senden dann nichts mehr an OpenAI und fragen '
          'dich vor der nächsten Nutzung erneut.',
      action: 'Widerrufen',
    );
    if (confirmed) await consent.set(ConsentKind.aiProcessing, false);
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String text,
    required String action,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(action),
          ),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final consent = controller.consent;
    return ListenableBuilder(
      listenable: consent,
      builder: (context, _) => SurfaceCard(
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Text(
                'Einwilligungen',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
            SwitchListTile(
              key: const Key('consent-switch-health'),
              value: consent.healthGranted,
              onChanged: (value) => unawaited(_setHealth(context, value)),
              title: const Text(ConsentTexts.healthTitle),
              subtitle: const Text(
                'Gewicht, Zielgewicht und Allergien im Konto speichern',
              ),
            ),
            SwitchListTile(
              key: const Key('consent-switch-ai'),
              value: consent.aiGranted,
              onChanged: (value) => unawaited(_setAi(context, value)),
              title: const Text(ConsentTexts.aiTitle),
              subtitle: const Text('Fragen und Fotos an OpenAI (USA) senden'),
            ),
          ],
        ),
      ),
    );
  }
}
