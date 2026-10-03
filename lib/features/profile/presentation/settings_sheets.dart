import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/legal_links_row.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../allergies/presentation/allergy_profile_field.dart';
import 'account_data_actions.dart';

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

  /// Allergies as stored text; edited in the allergy picker.
  late String _allergies;

  @override
  void initState() {
    super.initState();
    _style = widget.controller.nutritionStyle;
    _activity = widget.controller.activityLevel;
    _allergies = widget.controller.hasAllergyProfile
        ? widget.controller.allergies
        : '';
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
          AllergyProfileField(
            key: const ValueKey('profile-allergy-options'),
            value: _allergies,
            onChanged: (value) => setState(() => _allergies = value),
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
                newAllergies: _allergies,
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
                _DataRow(
                  icon: Icons.person_outline,
                  label: 'Profil & Ziele',
                  place: 'IM KONTO',
                ),
                Divider(height: 25),
                _DataRow(
                  icon: Icons.restaurant_outlined,
                  label: 'Mahlzeiten & Nährwerte',
                  place: 'IM KONTO',
                ),
                Divider(height: 25),
                _DataRow(
                  icon: Icons.photo_camera_outlined,
                  label: 'KI-Foto & KI-Chat',
                  place: 'KI-DIENST',
                ),
                Divider(height: 25),
                _DataRow(
                  icon: Icons.account_circle_outlined,
                  label: 'Profilbild & Erinnerungen',
                  place: 'NUR GERÄT',
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
          const SizedBox(height: 14),
          AccountDataActions(subscription: controller.subscription),
          const SizedBox(height: 14),
          const SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rechtliches',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                SizedBox(height: 4),
                LegalLinksRow(alignment: WrapAlignment.start),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Profil, Ziele und Tagebuch werden in deinem Lookin-Konto (Supabase) gespeichert, damit sie auf jedem Gerät verfügbar sind. '
            'Fotos für die KI-Foto-Analyse und Nachrichten an den KI-Coach werden über unseren Server an OpenAI übertragen; Fotos werden dabei nicht gespeichert. '
            'Profilbild, Erinnerungen und gemerkte Lebensmittel bleiben nur auf diesem Gerät. '
            'Unter den Optionen oben kannst du deine Kontodaten exportieren oder dein Konto endgültig löschen.',
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
        content: Text(
          controller.personalizationUserId == null
              ? 'Mahlzeiten, Favoriten, Listen und Wasserstand werden lokal geleert. Nach einem App-Neustart erscheinen die Beispiel-Mahlzeiten wieder.'
              : 'Gespeicherte Listen und dein Wasserstand werden auf diesem Gerät geleert. Deine gespeicherten Mahlzeiten und Favoriten im Konto bleiben erhalten.',
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
  const _DataRow({
    required this.icon,
    required this.label,
    required this.place,
  });
  final IconData icon;
  final String label;
  final String place;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        StatusPill(label: place),
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
                  'Lookin unterstützt Gewohnheiten, stellt aber keine Diagnose und ersetzt keine Ärztin, keinen Arzt oder qualifizierte Ernährungsberatung.',
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
