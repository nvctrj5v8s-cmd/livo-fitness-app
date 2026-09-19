import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ui_components.dart';

Future<void> showReminderSheet(BuildContext context, AppController controller) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ReminderSheet(controller: controller),
  );
}

Future<void> showNutritionProfileSheet(
  BuildContext context,
  AppController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _NutritionProfileSheet(controller: controller),
  );
}

Future<void> showPremiumSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _PremiumSheet(),
  );
}

Future<void> showPrivacySheet(BuildContext context, AppController controller) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PrivacySheet(controller: controller),
  );
}

Future<void> showHelpSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _HelpSheet(),
  );
}

class _ReminderSheet extends StatefulWidget {
  const _ReminderSheet({required this.controller});
  final AppController controller;

  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  @override
  Widget build(BuildContext context) {
    return _SettingsSheetFrame(
      title: 'Erinnerungen',
      subtitle: 'Dein Rhythmus, jederzeit anpassbar',
      child: ListView(
        children: [
          _SwitchCard(
            icon: Icons.restaurant_outlined,
            color: AppColors.primary,
            title: 'Mahlzeiten eintragen',
            subtitle: 'Täglich um 13:00 und 19:00 Uhr',
            value: widget.controller.mealReminders,
            onChanged: (value) {
              widget.controller.setMealReminders(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 10),
          _SwitchCard(
            icon: Icons.water_drop_outlined,
            color: AppColors.blue,
            title: 'Wasser trinken',
            subtitle: 'Alle zwei Stunden zwischen 9 und 19 Uhr',
            value: widget.controller.waterReminders,
            onChanged: (value) {
              widget.controller.setWaterReminders(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 10),
          _SwitchCard(
            icon: Icons.insights_outlined,
            color: AppColors.mint,
            title: 'Wochenrückblick',
            subtitle: 'Sonntagabend mit deinen wichtigsten Trends',
            value: widget.controller.weeklySummary,
            onChanged: (value) {
              widget.controller.setWeeklySummary(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 18),
          const SurfaceCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.textMuted),
                SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'Die Schalter funktionieren lokal. Echte Push-Nachrichten benötigen später die Betriebssystem-Berechtigung und einen Benachrichtigungsdienst.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      height: 1.45,
                    ),
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

class _SwitchCard extends StatelessWidget {
  const _SwitchCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(15, 10, 8, 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _NutritionProfileSheet extends StatefulWidget {
  const _NutritionProfileSheet({required this.controller});
  final AppController controller;

  @override
  State<_NutritionProfileSheet> createState() => _NutritionProfileSheetState();
}

class _NutritionProfileSheetState extends State<_NutritionProfileSheet> {
  late String _style;
  late String _activity;
  late final TextEditingController _allergiesController;

  @override
  void initState() {
    super.initState();
    _style = widget.controller.nutritionStyle;
    _activity = widget.controller.activityLevel;
    _allergiesController = TextEditingController(
      text: widget.controller.allergies == 'Keine angegeben'
          ? ''
          : widget.controller.allergies,
    );
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsSheetFrame(
      title: 'Ernährungsprofil',
      subtitle: widget.controller.personalization == null
          ? 'Deine gespeicherten Profilangaben'
          : 'Ernährungsweise und Aktivität änderst du unter „Antworten ändern“.',
      child: ListView(
        children: [
          if (widget.controller.personalization == null) ...[
            const Text(
              'Ernährungsstil',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Ausgewogen', 'Vegetarisch', 'Vegan', 'Low Carb']
                  .map(
                    (value) => ChoiceChip(
                      label: Text(value),
                      selected: _style == value,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _style = value),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
          TextField(
            controller: _allergiesController,
            decoration: const InputDecoration(
              labelText: 'Allergien oder Unverträglichkeiten',
              hintText: 'z. B. Erdnüsse, Laktose',
              prefixIcon: Icon(Icons.no_food_outlined),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.controller.personalization == null) ...[
            const Text(
              'Aktivitätsniveau',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Wenig aktiv', 'Moderat aktiv', 'Sehr aktiv']
                  .map(
                    (value) => ChoiceChip(
                      label: Text(value),
                      selected: _activity == value,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _activity = value),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 26),
          FilledButton(
            onPressed: () {
              widget.controller.updateNutritionProfile(
                newNutritionStyle: _style,
                newAllergies: _allergiesController.text,
                newActivityLevel: _activity,
              );
              Navigator.pop(context);
            },
            child: const Text('Ernährungsprofil speichern'),
          ),
        ],
      ),
    );
  }
}

class _PremiumSheet extends StatefulWidget {
  const _PremiumSheet();

  @override
  State<_PremiumSheet> createState() => _PremiumSheetState();
}

class _PremiumSheetState extends State<_PremiumSheet> {
  bool _yearly = true;

  @override
  Widget build(BuildContext context) {
    return _SettingsSheetFrame(
      title: 'LIVO Premium',
      subtitle: 'Die komplette Abo-Oberfläche als Vorschau',
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.18),
                  AppColors.mint.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.28),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusPill(
                  label: '7 TAGE KOSTENLOS',
                  icon: Icons.workspace_premium_rounded,
                ),
                SizedBox(height: 18),
                Text(
                  'Mehr Klarheit. Weniger Grübeln.',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'Persönliche Pläne, tiefere Auswertungen und später der sichere KI-Coach.',
                  style: TextStyle(color: AppColors.textMuted, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (final benefit in const [
            'Flexible Wochen- und Einkaufsplanung',
            'Erweiterte Ernährungs- und Gewichtstrends',
            'Unbegrenzte Favoriten und eigene Rezepte',
            'KI-Coach nach sicherer Backend-Anbindung',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(benefit)),
                ],
              ),
            ),
          const SizedBox(height: 10),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Monatlich')),
              ButtonSegment(value: true, label: Text('Jährlich · −25 %')),
            ],
            selected: {_yearly},
            onSelectionChanged: (values) =>
                setState(() => _yearly = values.first),
          ),
          const SizedBox(height: 16),
          Text(
            _yearly
                ? '5,99 € / Monat · jährlich abgerechnet'
                : '7,99 € / Monat',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Checkout bereit: Store-Produkte und Zahlungsanbieter werden später verbunden.',
                ),
              ),
            ),
            child: const Text('Kostenlos testen'),
          ),
          const SizedBox(height: 10),
          const Text(
            'Vorschaupreise – vor Veröffentlichung müssen Preis, Laufzeit, Kündigung und Store-Texte final geprüft werden.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacySheet extends StatelessWidget {
  const _PrivacySheet({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _SettingsSheetFrame(
      title: 'Datenschutz & Daten',
      subtitle: 'Transparent und unter deiner Kontrolle',
      child: ListView(
        children: [
          const SurfaceCard(
            child: Column(
              children: [
                _DataRow(icon: Icons.person_outline, label: 'Profil & Ziele'),
                Divider(height: 25),
                _DataRow(
                  icon: Icons.restaurant_outlined,
                  label: 'Mahlzeiten & Nährwerte',
                ),
                Divider(height: 25),
                _DataRow(
                  icon: Icons.insights_outlined,
                  label: 'Fortschrittsdaten',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Lokale Datenübersicht'),
                content: Text(
                  'Name: ${controller.name}\nZiel: ${controller.goal}\nMahlzeiten: ${controller.meals.length}\nGewicht: ${controller.currentWeight} kg\nFavoriten: ${controller.favoriteRecipeIds.length}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Schließen'),
                  ),
                ],
              ),
            ),
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Lokale Daten ansehen'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _confirmDeletion(context),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Lokale Demodaten löschen'),
          ),
          const SizedBox(height: 15),
          const Text(
            'Aktuell verlässt kein Profil- oder Ernährungswert diese Demo. Vor dem Backend folgen Einwilligung, Verschlüsselung, Export und ein vollständiger Löschprozess.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Demodaten löschen?'),
        content: const Text(
          'Mahlzeiten, Favoriten, Listen und Wasserstand werden lokal geleert. Nach einem App-Neustart erscheinen die Beispieldaten wieder.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    controller.clearLocalDemoData();
    Navigator.pop(context);
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        const StatusPill(label: 'NUR LOKAL'),
      ],
    );
  }
}

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  @override
  Widget build(BuildContext context) {
    return const _SettingsSheetFrame(
      title: 'Hilfe & Sicherheit',
      subtitle: 'Gesundheit geht immer vor Tracking',
      child: SingleChildScrollView(
        child: Column(
          children: [
            _HelpCard(
              icon: Icons.health_and_safety_outlined,
              color: AppColors.primary,
              title: 'Keine medizinische Beratung',
              text:
                  'LIVO unterstützt Gewohnheiten, stellt aber keine Diagnose und ersetzt keine Ärztin, keinen Arzt oder qualifizierte Ernährungsberatung.',
            ),
            SizedBox(height: 10),
            _HelpCard(
              icon: Icons.favorite_border_rounded,
              color: AppColors.error,
              title: 'Essstörung oder akute Beschwerden',
              text:
                  'Nutze keine Diät- oder Kalorienziele auf eigene Faust. Hole dir persönliche Hilfe bei medizinischem oder psychotherapeutischem Fachpersonal. Bei einem akuten Notfall wende dich an den örtlichen Notruf.',
            ),
            SizedBox(height: 10),
            _HelpCard(
              icon: Icons.balance_outlined,
              color: AppColors.blue,
              title: 'Zahlen sind Orientierung',
              text:
                  'Nährwerte und Ziele sind Schätzungen. Achte zusätzlich auf Energie, Wohlbefinden, Schlaf und ein entspanntes Verhältnis zum Essen.',
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.5,
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

class _SettingsSheetFrame extends StatelessWidget {
  const _SettingsSheetFrame({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final height = math.min(MediaQuery.sizeOf(context).height * 0.84, 720.0);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              20 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Schließen',
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
