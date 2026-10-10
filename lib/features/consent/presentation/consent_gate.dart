import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/legal_links_row.dart';
import '../application/consent_controller.dart';
import '../domain/consent.dart';

/// Asks once after sign-in for the two optional consents. Both boxes start
/// unticked and the app works without them; declining is recorded too, so
/// the question does not come back on every start.
class ConsentGate extends StatefulWidget {
  const ConsentGate({required this.child, super.key});

  final Widget child;

  @override
  State<ConsentGate> createState() => _ConsentGateState();
}

class _ConsentGateState extends State<ConsentGate> {
  ConsentController? _consent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final consent = AppScope.of(context).consent;
    if (!identical(consent, _consent)) {
      _consent = consent;
      unawaited(consent.load());
    }
  }

  @override
  Widget build(BuildContext context) {
    final consent = AppScope.of(context).consent;
    if (!consent.hasLoaded) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!consent.needsInitialDecision) return widget.child;
    return ConsentPage(consent: consent);
  }
}

class ConsentPage extends StatefulWidget {
  const ConsentPage({required this.consent, super.key});

  final ConsentController consent;

  @override
  State<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage> {
  late bool _health = widget.consent.decision(ConsentKind.healthData) ?? false;
  late bool _ai = widget.consent.decision(ConsentKind.aiProcessing) ?? false;
  bool _saving = false;

  Future<void> _continue() async {
    if (_saving) return;
    setState(() => _saving = true);
    await widget.consent.set(ConsentKind.healthData, _health);
    await widget.consent.set(ConsentKind.aiProcessing, _ai);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
              children: [
                Text(
                  'Deine Einwilligungen',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Lookin funktioniert auch ohne diese Einwilligungen. Ohne sie '
                  'bleiben Gesundheitsangaben nur auf diesem Gerät, und KI-Coach '
                  'und KI-Foto fragen dich vor der ersten Nutzung noch einmal.',
                  style: TextStyle(color: AppColors.textMuted, height: 1.45),
                ),
                const SizedBox(height: 20),
                _ConsentCard(
                  key: const Key('consent-health'),
                  title: ConsentTexts.healthTitle,
                  text: ConsentTexts.health,
                  value: _health,
                  onChanged: (value) => setState(() => _health = value),
                ),
                const SizedBox(height: 12),
                _ConsentCard(
                  key: const Key('consent-ai'),
                  title: ConsentTexts.aiTitle,
                  text: ConsentTexts.ai,
                  value: _ai,
                  onChanged: (value) => setState(() => _ai = value),
                ),
                const SizedBox(height: 14),
                const Text(
                  ConsentTexts.revocableNote,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                ),
                const LegalLinksRow(
                  pages: [LegalPage.privacy],
                  alignment: WrapAlignment.start,
                ),
                const SizedBox(height: 14),
                FilledButton(
                  key: const Key('consent-continue'),
                  onPressed: _saving ? null : _continue,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                  ),
                  child: Text(
                    _health || _ai
                        ? 'Speichern und weiter'
                        : 'Ohne Einwilligung weiter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsentCard extends StatelessWidget {
  const _ConsentCard({
    required this.title,
    required this.text,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String title;
  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: value ? AppColors.primary : AppColors.border),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: (next) => onChanged(next ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textMuted, height: 1.4),
          ),
        ),
      ),
    );
  }
}
