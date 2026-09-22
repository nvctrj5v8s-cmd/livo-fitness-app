import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/personalization_profile.dart';
import 'personalization_artwork.dart';

/// An optional, local preference questionnaire. Saving and navigation belong to
/// the parent so a failed write never looks like a completed setup.
class PersonalizationPage extends StatefulWidget {
  const PersonalizationPage({
    this.initial = const PersonalizationProfile(),
    required this.onComplete,
    required this.onLater,
    this.editing = false,
    super.key,
  });

  final PersonalizationProfile initial;
  final Future<void> Function(PersonalizationProfile) onComplete;
  final Future<void> Function() onLater;
  final bool editing;

  @override
  State<PersonalizationPage> createState() => _PersonalizationPageState();
}

class _PersonalizationPageState extends State<PersonalizationPage> {
  late PersonalizationProfile _draft;
  late final TextEditingController _name;
  late final TextEditingController _allergies;
  final _scroll = ScrollController();
  late int _step;
  bool _fromReview = false;
  bool _saving = false;
  String? _error;

  static const _stepCount = 6;
  static const _lastStep = _stepCount - 1;

  static const _titles = [
    'Ein paar Antworten.\nEin besseres LIVO.',
    'Was möchtest du\nerreichen?',
    'Wie aktiv ist\ndein Alltag?',
    'Was passt zu\ndeiner Ernährung?',
    'Wie passt Essen\nin deinen Tag?',
    'Bereit für dein\npersönliches LIVO.',
  ];
  static const _descriptions = [
    'Die kurzen Fragen helfen der App und deinem KI-Coach, Vorschläge besser an dich anzupassen. Alles ist freiwillig.',
    'Dein Ziel bestimmt, welche Empfehlungen für dich zuerst kommen – ohne Druck und ohne Extrempläne.',
    'Ein grober Eindruck reicht. So werden Hinweise und Vorschläge realistischer für deinen Alltag.',
    'Damit Rezepte und der KI-Coach besser zu dir passen. Angaben zu Unverträglichkeiten sind ebenfalls freiwillig.',
    'Nur dein bevorzugter Rhythmus und deine übliche Kochzeit – beides bleibt jederzeit flexibel.',
    'Du kannst jede Antwort später im Profil ändern. LIVO funktioniert auch vollständig ohne diese Angaben.',
  ];
  static const _sections = [
    'DEIN START',
    'DEIN ZIEL',
    'DEIN ALLTAG',
    'DEINE ERNÄHRUNG',
    'DEIN RHYTHMUS',
    'FÜR DICH EINGESTELLT',
  ];

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
    _name = TextEditingController(text: _draft.displayName);
    _allergies = TextEditingController(text: _draft.allergies);
    _step = widget.editing ? _lastStep : 0;
  }

  @override
  void dispose() {
    _name.dispose();
    _allergies.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Duration _duration(int milliseconds) =>
      MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : Duration(milliseconds: milliseconds);

  void _goTo(int step, {bool fromReview = false}) {
    if (_saving || step < 0 || step > _lastStep) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _step = step;
      _fromReview = fromReview;
      _error = null;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _back() {
    if (_saving) return;
    if (_fromReview) {
      _goTo(_lastStep);
    } else if (_step == 0 || (widget.editing && _step == _lastStep)) {
      _save(later: true);
    } else {
      _goTo(_step - 1);
    }
  }

  void _next() {
    if (_saving) return;
    if (_step == _lastStep) {
      _save();
    } else {
      _goTo(_fromReview ? _lastStep : _step + 1);
    }
  }

  Future<void> _save({bool later = false}) async {
    if (_saving) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (later) {
        await widget.onLater();
      } else {
        await widget.onComplete(
          _draft.copyWith(
            displayName: _name.text.trim(),
            allergies: _allergies.text.trim(),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = later
              ? 'Das hat gerade nicht geklappt. Bitte versuche es noch einmal.'
              : 'Deine Auswahl konnte nicht gespeichert werden. Deine Antworten sind noch hier. Bitte versuche es noch einmal.';
        });
        if (_scroll.hasClients) _scroll.jumpTo(0);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _update(PersonalizationProfile profile) {
    if (!_saving) setState(() => _draft = profile);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _back();
    },
    child: CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true): _back,
        const SingleActivator(LogicalKeyboardKey.arrowRight, alt: true): _next,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.9, -0.6),
                radius: 1.3,
                colors: [
                  Color.alphaBlend(
                    AppColors.primary.withValues(alpha: 0.045),
                    AppColors.background,
                  ),
                  AppColors.background,
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxHeight < 460;
                      return Column(
                        children: [
                          _header(compact),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scroll,
                              key: const ValueKey('personal-scroll'),
                              padding: EdgeInsets.fromLTRB(
                                constraints.maxWidth >= 800 ? 32 : 20,
                                compact ? 10 : 24,
                                constraints.maxWidth >= 800 ? 32 : 20,
                                24,
                              ),
                              child: AnimatedSwitcher(
                                duration: _duration(330),
                                reverseDuration: _duration(180),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.045, 0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    ),
                                layoutBuilder: (current, previous) => Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    for (final child in previous)
                                      IgnorePointer(
                                        child: ExcludeSemantics(child: child),
                                      ),
                                    ?current,
                                  ],
                                ),
                                child: _content(
                                  wide: constraints.maxWidth >= 800,
                                  compact: compact,
                                ),
                              ),
                            ),
                          ),
                          _footer(compact),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _header(bool compact) => Padding(
    padding: EdgeInsets.fromLTRB(20, compact ? 0 : 8, 12, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 68,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'livo.',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 29,
                    letterSpacing: -1.6,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '${_step + 1} / $_stepCount',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                heightFactor: 1,
                child: TextButton(
                  key: const ValueKey('personal-later'),
                  onPressed: _saving ? null : () => _save(later: true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.text,
                    backgroundColor: AppColors.surfaceHigh,
                    minimumSize: const Size(48, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Text(
                    widget.editing ? 'Schließen' : 'Überspringen',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
          child: Semantics(
            label: 'Einrichtung, Schritt ${_step + 1} von $_stepCount',
            value: _sections[_step],
            child: ExcludeSemantics(
              child: Row(
                children: List.generate(
                  _stepCount,
                  (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == _lastStep ? 0 : 6,
                      ),
                      child: AnimatedContainer(
                        duration: _duration(350),
                        height: index == _step ? 5 : 3,
                        decoration: BoxDecoration(
                          color: index <= _step
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _content({required bool wide, required bool compact}) {
    final art = PersonalizationArtwork(
      step: _step,
      profile: _draft,
      compact: !wide,
    );
    final copy = Container(
      padding: EdgeInsets.all(wide ? 30 : 22),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          AppColors.primary.withValues(alpha: 0.025),
          AppColors.surface,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderBright),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          Text(
            _sections[_step],
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.7,
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            header: true,
            child: Text(
              _titles[_step],
              style: TextStyle(
                color: AppColors.text,
                fontSize: wide ? 39 : 30,
                height: 1.09,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
              ),
            ),
          ),
          const SizedBox(height: 13),
          Text(
            _descriptions[_step],
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 24),
          _answers(),
        ],
      ),
    );
    return KeyedSubtree(
      key: ValueKey('personal-step-$_step'),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 26, right: 32),
                    child: art,
                  ),
                ),
                Expanded(flex: 6, child: copy),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!compact) ...[art, const SizedBox(height: 24)],
                copy,
                if (compact) ...[const SizedBox(height: 24), art],
              ],
            ),
    );
  }

  Widget _answers() => switch (_step) {
    0 => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const ValueKey('personal-name'),
          controller: _name,
          enabled: !_saving,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.givenName],
          decoration: const InputDecoration(
            labelText: 'Dein Name (optional)',
            hintText: 'Zum Beispiel Alex',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          onChanged: (value) => _update(_draft.copyWith(displayName: value)),
          onSubmitted: (_) => _next(),
        ),
        const SizedBox(height: 20),
        const _InfoNote(
          icon: Icons.auto_awesome_rounded,
          title: 'Freiwillig, aber hilfreich',
          text:
              'Du kannst oben überspringen. Die App funktioniert trotzdem vollständig. Mit Antworten passen sich KI-Coach, Rezepte und Tagebuch besser an dich an.',
        ),
        const SizedBox(height: 16),
        const _InfoNote(
          icon: Icons.manage_accounts_outlined,
          title: 'Später jederzeit änderbar',
          text:
              'Wenn du jetzt überspringst, findest du diese Einrichtung später im Profil unter „Persönlich einrichten“.',
        ),
      ],
    ),
    1 => _choiceList<PersonalGoal>(
      values: PersonalGoal.values,
      selected: _draft.goal,
      prefix: 'goal',
      label: (value) => value.label,
      detail: (value) => switch (value) {
        PersonalGoal.balanced => 'Mehr Abwechslung und bewusste Entscheidungen',
        PersonalGoal.loseWeight =>
          'Dein persönlicher Wunsch, ohne feste Vorgaben',
        PersonalGoal.maintain =>
          'Eine Routine, die sich für dich passend anfühlt',
        PersonalGoal.buildStrength =>
          'Ernährung und Training gemeinsam im Blick',
      },
      icon: (value) => switch (value) {
        PersonalGoal.balanced => Icons.spa_outlined,
        PersonalGoal.loseWeight => Icons.flag_outlined,
        PersonalGoal.maintain => Icons.balance_rounded,
        PersonalGoal.buildStrength => Icons.fitness_center_rounded,
      },
      onSelect: (value) => _update(_draft.copyWith(goal: value)),
    ),
    2 => _choiceList<ActivityPattern>(
      values: ActivityPattern.values,
      selected: _draft.activity,
      prefix: 'activity',
      label: (value) => value.label,
      detail: (value) => switch (value) {
        ActivityPattern.mostlySeated => 'Viel am Schreibtisch oder im Sitzen',
        ActivityPattern.mixed => 'Sitzen, Stehen und Gehen wechseln sich ab',
        ActivityPattern.oftenMoving =>
          'Viel auf den Beinen, drinnen oder draußen',
        ActivityPattern.veryActive => 'Körperliche Arbeit oder viel Bewegung',
      },
      icon: (value) => switch (value) {
        ActivityPattern.mostlySeated => Icons.chair_alt_outlined,
        ActivityPattern.mixed => Icons.swap_horiz_rounded,
        ActivityPattern.oftenMoving => Icons.directions_walk_rounded,
        ActivityPattern.veryActive => Icons.directions_run_rounded,
      },
      onSelect: (value) => _update(_draft.copyWith(activity: value)),
    ),
    3 => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _choiceList<NutritionPreference>(
          values: NutritionPreference.values,
          selected: _draft.nutrition,
          prefix: 'nutrition',
          label: (value) => value.label,
          detail: (value) => switch (value) {
            NutritionPreference.mixed =>
              'Pflanzliche und tierische Lebensmittel',
            NutritionPreference.vegetarian => 'Ohne Fleisch und Fisch',
            NutritionPreference.vegan => 'Ausschließlich pflanzlich',
            NutritionPreference.pescatarian => 'Mit Fisch, ohne Fleisch',
          },
          icon: (value) => switch (value) {
            NutritionPreference.mixed => Icons.restaurant_rounded,
            NutritionPreference.vegetarian => Icons.eco_outlined,
            NutritionPreference.vegan => Icons.spa_outlined,
            NutritionPreference.pescatarian => Icons.set_meal_outlined,
          },
          onSelect: (value) => _update(_draft.copyWith(nutrition: value)),
        ),
        const SizedBox(height: 18),
        TextField(
          key: const ValueKey('personal-allergies'),
          controller: _allergies,
          enabled: !_saving,
          maxLength: 160,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Allergien oder Unverträglichkeiten (optional)',
            hintText: 'Zum Beispiel Erdnüsse oder Laktose',
            prefixIcon: Icon(Icons.health_and_safety_outlined),
          ),
          onChanged: (value) =>
              _update(_draft.copyWith(allergies: value.trim())),
        ),
        const _InfoNote(
          icon: Icons.shield_outlined,
          title: 'Wichtig für sichere Vorschläge',
          text:
              'LIVO berücksichtigt deine Angabe, kann aber keine medizinische Prüfung oder Diagnose ersetzen.',
        ),
      ],
    ),
    4 => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _mealChoices(
          title: 'Wie viele Mahlzeiten passen meist zu dir?',
          subtitle: 'Eine Orientierung für dein Tagebuch – kein Muss.',
          selected: _draft.desiredMeals,
          prefix: 'desired-meals',
          onSelect: (value) => _update(_draft.copyWith(desiredMeals: value)),
        ),
        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 22),
        const Text(
          'Wie viel Zeit möchtest du meist kochen?',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          key: ValueKey('personal-cooking-${_draft.cookingMinutes ?? 0}'),
          initialValue: _draft.cookingMinutes ?? 0,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.schedule_rounded),
            labelText: 'Bevorzugte Kochzeit',
          ),
          items: const [
            DropdownMenuItem(value: 0, child: Text('Flexibel')),
            DropdownMenuItem(value: 15, child: Text('Bis 15 Minuten')),
            DropdownMenuItem(value: 30, child: Text('Bis 30 Minuten')),
            DropdownMenuItem(value: 45, child: Text('Bis 45 Minuten')),
          ],
          onChanged: _saving
              ? null
              : (value) => _update(
                  _draft.copyWith(cookingMinutes: value == 0 ? null : value),
                ),
        ),
      ],
    ),
    _ => _review(),
  };

  Widget _choiceList<T extends Enum>({
    required List<T> values,
    required T? selected,
    required String prefix,
    required String Function(T) label,
    required String Function(T) detail,
    required IconData Function(T) icon,
    required void Function(T?) onSelect,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final value in values)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ChoiceTile(
            key: ValueKey('personal-$prefix-${value.name}'),
            title: label(value),
            detail: detail(value),
            icon: icon(value),
            selected: selected == value,
            duration: _duration(220),
            onTap: _saving
                ? null
                : () => onSelect(selected == value ? null : value),
          ),
        ),
      const SizedBox(height: 4),
      const Text(
        'Optional · Erneut antippen hebt deine Auswahl auf.',
        style: TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.5),
      ),
    ],
  );

  Widget _mealChoices({
    required String title,
    required String subtitle,
    required int? selected,
    required String prefix,
    required ValueChanged<int?> onSelect,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        subtitle,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final count in <int?>[2, 3, 4, 5, null])
            Semantics(
              selected: selected == count,
              child: OutlinedButton(
                key: ValueKey('personal-$prefix-${count ?? 'flexible'}'),
                onPressed: _saving ? null : () => onSelect(count),
                style: OutlinedButton.styleFrom(
                  foregroundColor: selected == count
                      ? AppColors.primary
                      : AppColors.text,
                  backgroundColor: selected == count
                      ? AppColors.primary.withValues(alpha: 0.09)
                      : AppColors.surfaceHigh,
                  side: BorderSide(
                    color: selected == count
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                  minimumSize: const Size(54, 52),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  count?.toString() ?? 'Flexibel',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    ],
  );

  Widget _review() {
    final rows = <(int, String, String)>[
      (
        0,
        'Name',
        _draft.displayName.trim().isEmpty ? 'Offen' : _draft.displayName.trim(),
      ),
      (1, 'Ziel', _draft.goal?.label ?? 'Offen'),
      (2, 'Aktivität', _draft.activity?.label ?? 'Offen'),
      (
        3,
        'Ernährung',
        [
          _draft.nutrition?.label ?? 'Offen',
          if (_draft.allergies.trim().isNotEmpty) _draft.allergies.trim(),
        ].join(' · '),
      ),
      (
        4,
        'Tagesrhythmus',
        '${_mealLabel(_draft.desiredMeals)} · ${_draft.cookingMinutes == null ? 'Kochzeit flexibel' : 'bis ${_draft.cookingMinutes} Min.'}',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(23),
          ),
          child: Column(
            children: [
              for (var index = 0; index < rows.length; index++) ...[
                if (index != 0)
                  const Divider(height: 1, indent: 18, endIndent: 18),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: ValueKey('personal-review-edit-$index'),
                    onTap: _saving
                        ? null
                        : () => _goTo(rows[index].$1, fromReview: true),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rows[index].$2,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  rows[index].$3,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: AppColors.primary,
                            semanticLabel: 'Ändern',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'So liest sich deine Auswahl',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        for (final line in _draft.summaryLines)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Icon(
                    Icons.check_rounded,
                    size: 17,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    line,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        const _InfoNote(
          icon: Icons.auto_awesome_rounded,
          title: 'Ab jetzt persönlicher',
          text:
              'Diese Angaben helfen LIVO und dem KI-Coach, Antworten und Vorschläge auf dein Ziel und deinen Alltag abzustimmen.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Du behältst die Kontrolle: Im Profil kannst du Antworten ändern oder entfernen.',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  String _mealLabel(int? value) =>
      value == null ? 'flexibel' : '$value pro Tag';

  Widget _footer(bool compact) => Container(
    decoration: const BoxDecoration(
      color: AppColors.background,
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    padding: EdgeInsets.fromLTRB(20, compact ? 8 : 14, 20, compact ? 8 : 18),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton.outlined(
                  key: const ValueKey('personal-back'),
                  tooltip: _fromReview ? 'Zur Übersicht' : 'Zurück',
                  onPressed: _saving ? null : _back,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(52, 56),
                    foregroundColor: AppColors.text,
                    side: const BorderSide(color: AppColors.borderBright),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('personal-next'),
                    onPressed: _saving ? null : _next,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 56),
                      textStyle: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 15,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            _saving
                                ? 'Einen Moment …'
                                : _step == _lastStep
                                ? 'LIVO für mich einrichten'
                                : _fromReview
                                ? 'Zur Übersicht'
                                : _step == 0
                                ? 'Kurz einrichten'
                                : 'Weiter',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _step == _lastStep
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 19,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.detail,
    required this.icon,
    required this.selected,
    required this.duration,
    required this.onTap,
    super.key,
  });

  final String title;
  final String detail;
  final IconData icon;
  final bool selected;
  final Duration duration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: AnimatedContainer(
      duration: duration,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? Color.alphaBlend(
                AppColors.primary.withValues(alpha: 0.07),
                AppColors.surface,
              )
            : AppColors.surface,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                  size: 24,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? AppColors.primary : AppColors.borderBright,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 23),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            height: 1.55,
          ),
        ),
      ],
    ),
  );
}
