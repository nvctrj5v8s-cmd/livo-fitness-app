import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/personalization_profile.dart';

/// A short, optional setup. Each question owns one fixed screen so the user
/// never needs to scroll through a long form.
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
  static const _stepCount = 6;
  static const _months = [
    'Jan',
    'Feb',
    'Mär',
    'Apr',
    'Mai',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Okt',
    'Nov',
    'Dez',
  ];
  static const _metricMin = 35.0;
  static const _metricMax = 200.0;
  static const _rulerTickWidth = 12.0;

  late PersonalizationProfile _draft;
  late final TextEditingController _name;
  late final TextEditingController _allergies;
  late DateTime _birthDate;
  late int _heightCm;
  late double _weightKg;
  late MeasurementSystem _units;
  late final FixedExtentScrollController _dayWheel;
  late final FixedExtentScrollController _monthWheel;
  late final FixedExtentScrollController _yearWheel;
  late final FixedExtentScrollController _heightWheel;
  late final FixedExtentScrollController _feetWheel;
  late final FixedExtentScrollController _inchWheel;
  late final ScrollController _weightRuler;

  int _step = 0;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
    _name = TextEditingController(text: _draft.displayName);
    _allergies = TextEditingController(text: _draft.allergies);
    final now = DateTime.now();
    _birthDate = _draft.birthDate ?? DateTime(now.year - 25, 1, 1);
    _heightCm = _draft.heightCm ?? 175;
    _weightKg = _draft.weightKg ?? 70;
    _units = _draft.measurementSystem;
    _dayWheel = FixedExtentScrollController(initialItem: _birthDate.day - 1);
    _monthWheel = FixedExtentScrollController(
      initialItem: _birthDate.month - 1,
    );
    _yearWheel = FixedExtentScrollController(
      initialItem: now.year - _birthDate.year,
    );
    _heightWheel = FixedExtentScrollController(
      initialItem: (_heightCm - 120).clamp(0, 110).toInt(),
    );
    final imperial = _imperialHeight(_heightCm);
    _feetWheel = FixedExtentScrollController(initialItem: imperial.$1 - 3);
    _inchWheel = FixedExtentScrollController(initialItem: imperial.$2);
    _weightRuler = ScrollController(initialScrollOffset: _weightOffset);
  }

  @override
  void dispose() {
    _name.dispose();
    _allergies.dispose();
    _dayWheel.dispose();
    _monthWheel.dispose();
    _yearWheel.dispose();
    _heightWheel.dispose();
    _feetWheel.dispose();
    _inchWheel.dispose();
    _weightRuler.dispose();
    super.dispose();
  }

  int get _currentYear => DateTime.now().year;
  int get _yearCount => _currentYear - 1900 + 1;
  int get _heightFeet => _imperialHeight(_heightCm).$1;
  int get _heightInches => _imperialHeight(_heightCm).$2;
  bool get _imperial => _units == MeasurementSystem.imperial;
  double get _shownWeight => _imperial ? _weightKg * 2.2046226218 : _weightKg;
  double get _weightStep => _imperial ? 1 : .5;
  double get _weightMin => _imperial ? 80 : _metricMin;
  double get _weightMax => _imperial ? 440 : _metricMax;
  int get _weightItemCount =>
      ((_weightMax - _weightMin) / _weightStep).round() + 1;
  int get _weightIndex => ((_shownWeight - _weightMin) / _weightStep)
      .round()
      .clamp(0, _weightItemCount - 1)
      .toInt();
  double get _weightOffset => _weightIndex * _rulerTickWidth;

  (int, int) _imperialHeight(int centimeters) {
    final totalInches = (centimeters / 2.54).round().clamp(36, 96).toInt();
    return (totalInches ~/ 12, totalInches % 12);
  }

  void _go(int step) {
    if (_saving || step < 0 || step >= _stepCount) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _step = step;
      _error = null;
    });
  }

  void _back() {
    if (_saving) return;
    if (_step == 0) {
      _save(later: true);
    } else {
      _go(_step - 1);
    }
  }

  void _next() {
    if (_saving) return;
    if (_step == _stepCount - 1) {
      _save();
    } else {
      _go(_step + 1);
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
            birthDate: _birthDate,
            heightCm: _heightCm,
            weightKg: _weightKg,
            measurementSystem: _units,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = later
              ? 'Das hat gerade nicht geklappt. Bitte versuche es noch einmal.'
              : 'Deine Angaben konnten nicht gespeichert werden. Bitte versuche es erneut.';
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _update(PersonalizationProfile value) {
    if (!_saving) setState(() => _draft = value);
  }

  void _setUnits(MeasurementSystem value) {
    if (_saving || _units == value) return;
    setState(() => _units = value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_weightRuler.hasClients) return;
      _weightRuler.jumpTo(_weightOffset);
      if (value == MeasurementSystem.imperial) {
        final height = _imperialHeight(_heightCm);
        _feetWheel.jumpToItem(height.$1 - 3);
        _inchWheel.jumpToItem(height.$2);
      } else {
        _heightWheel.jumpToItem((_heightCm - 120).clamp(0, 110).toInt());
      }
    });
  }

  void _setBirthDate({int? day, int? month, int? year}) {
    final nextYear = year ?? _birthDate.year;
    final nextMonth = month ?? _birthDate.month;
    final maxDay = DateUtils.getDaysInMonth(nextYear, nextMonth);
    final nextDay = math.min(day ?? _birthDate.day, maxDay);
    setState(() => _birthDate = DateTime(nextYear, nextMonth, nextDay));
    if (nextDay != _dayWheel.selectedItem + 1) {
      _dayWheel.jumpToItem(nextDay - 1);
    }
  }

  void _setImperialHeight({int? feet, int? inches}) {
    final totalInches = (feet ?? _heightFeet) * 12 + (inches ?? _heightInches);
    setState(
      () => _heightCm = (totalInches * 2.54).round().clamp(90, 250).toInt(),
    );
  }

  void _onWeightScroll() {
    if (!_weightRuler.hasClients) return;
    final next = (_weightRuler.offset / _rulerTickWidth)
        .round()
        .clamp(0, _weightItemCount - 1)
        .toInt();
    final shown = _weightMin + next * _weightStep;
    final kg = _imperial ? shown / 2.2046226218 : shown;
    if ((_weightKg - kg).abs() >= .01) setState(() => _weightKg = kg);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
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
          body: SafeArea(
            child: Column(
              children: [
                _Header(
                  step: _step,
                  count: _stepCount,
                  saving: _saving,
                  editing: widget.editing,
                  onSkip: () => _save(later: true),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = math
                          .min(560.0, constraints.maxWidth - 32)
                          .toDouble();
                      final content = SizedBox(
                        width: math.max(280, width).toDouble(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: KeyedSubtree(
                            key: ValueKey('personal-step-$_step'),
                            child: _QuestionFrame(
                              title: _title,
                              subtitle: _subtitle,
                              error: _error,
                              child: _answers(),
                            ),
                          ),
                        ),
                      );
                      // On normal phones the controls keep their full size so
                      // wheels and the ruler receive direct drag gestures.
                      // A compact landscape window is the only fallback.
                      return Center(
                        child: constraints.maxHeight < 510
                            ? FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: content,
                              )
                            : content,
                      );
                    },
                  ),
                ),
                _Footer(
                  saving: _saving,
                  first: _step == 0,
                  last: _step == _stepCount - 1,
                  onBack: _back,
                  onNext: _next,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  String get _title => switch (_step) {
    0 => 'Damit LIVO dich richtig anspricht.',
    1 => 'Was ist dein Ziel?',
    2 => 'Wann hast du Geburtstag?',
    3 => 'Wie groß bist du?',
    4 => 'Wo stehst du gerade?',
    _ => 'Was passt zu deinem Alltag?',
  };

  String get _subtitle => switch (_step) {
    0 =>
      'Dein Name ist optional. Alle Angaben kannst du später im Profil ändern.',
    1 => 'Das hilft LIVO, Vorschläge sinnvoll zu priorisieren – ohne Druck.',
    2 => 'Wische direkt in den Rädern nach oben oder unten.',
    3 =>
      'Wähle die Einheit, die für dich natürlich ist, und wische zum passenden Wert.',
    4 =>
      'Ziehe das Lineal nach links oder rechts. Es ist dein aktuelles Gewicht, kein Ziel.',
    _ => 'Damit Rezepte, Vorschläge und der Coach zu dir passen.',
  };

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
          autofillHints: const [AutofillHints.givenName],
          decoration: const InputDecoration(
            labelText: 'Wie dürfen wir dich nennen? (optional)',
            hintText: 'Zum Beispiel Alex',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          onChanged: (value) => _update(_draft.copyWith(displayName: value)),
          onSubmitted: (_) => _next(),
        ),
        const SizedBox(height: 18),
        const _SoftNote(
          icon: Icons.tune_rounded,
          text:
              'Du kannst oben überspringen. LIVO funktioniert auch ohne diese Antworten.',
        ),
      ],
    ),
    1 => _ChoiceGrid<PersonalGoal>(
      values: PersonalGoal.values,
      selected: _draft.goal,
      keyPrefix: 'goal',
      label: (item) => item.label,
      icon: (item) => switch (item) {
        PersonalGoal.balanced => Icons.favorite_outline_rounded,
        PersonalGoal.loseWeight => Icons.trending_down_rounded,
        PersonalGoal.maintain => Icons.balance_rounded,
        PersonalGoal.buildStrength => Icons.fitness_center_rounded,
      },
      onChanged: (item) => _update(_draft.copyWith(goal: item)),
    ),
    2 => Column(
      children: [
        _PickerCard(
          label: 'Geburtsdatum',
          height: 205,
          child: Row(
            children: [
              Expanded(
                child: _Wheel(
                  controller: _dayWheel,
                  count: DateUtils.getDaysInMonth(
                    _birthDate.year,
                    _birthDate.month,
                  ),
                  label: (index) => '${index + 1}'.padLeft(2, '0'),
                  onSelected: (index) => _setBirthDate(day: index + 1),
                ),
              ),
              Expanded(
                child: _Wheel(
                  controller: _monthWheel,
                  count: 12,
                  label: (index) => _months[index],
                  onSelected: (index) => _setBirthDate(month: index + 1),
                ),
              ),
              Expanded(
                child: _Wheel(
                  controller: _yearWheel,
                  count: _yearCount,
                  label: (index) => '${_currentYear - index}',
                  onSelected: (index) =>
                      _setBirthDate(year: _currentYear - index),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    3 => Column(
      children: [
        _UnitToggle(value: _units, onChanged: _setUnits),
        const SizedBox(height: 18),
        _PickerCard(
          label: 'Deine Größe',
          height: 205,
          child: _imperial
              ? Row(
                  children: [
                    Expanded(
                      child: _Wheel(
                        controller: _feetWheel,
                        count: 6,
                        label: (index) => '${index + 3} ft',
                        onSelected: (index) =>
                            _setImperialHeight(feet: index + 3),
                      ),
                    ),
                    Expanded(
                      child: _Wheel(
                        controller: _inchWheel,
                        count: 12,
                        label: (index) => '$index in',
                        onSelected: (index) =>
                            _setImperialHeight(inches: index),
                      ),
                    ),
                  ],
                )
              : _Wheel(
                  controller: _heightWheel,
                  count: 111,
                  label: (index) => '${index + 120} cm',
                  onSelected: (index) =>
                      setState(() => _heightCm = index + 120),
                ),
        ),
      ],
    ),
    4 => Column(
      children: [
        _UnitToggle(value: _units, onChanged: _setUnits),
        // Keep the controls large enough to use with a thumb. The spacing is
        // deliberately tighter than the other steps so the full ruler stays
        // visible on a regular phone without any scaling.
        const SizedBox(height: 16),
        Text(
          _imperial
              ? '${_shownWeight.round()} lb'
              : '${_shownWeight.toStringAsFixed(1).replaceAll('.', ',')} kg',
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 54,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.8,
          ),
        ),
        const SizedBox(height: 18),
        _WeightRuler(
          controller: _weightRuler,
          count: _weightItemCount,
          itemWidth: _rulerTickWidth,
          selectedIndex: _weightIndex,
          valueFor: (index) => _weightMin + index * _weightStep,
          unit: _imperial ? 'lb' : 'kg',
          onChanged: _onWeightScroll,
        ),
        const SizedBox(height: 14),
        const _SoftNote(
          icon: Icons.info_outline_rounded,
          text:
              'Ziehe das Lineal nach links oder rechts. Dein Gewicht wird nicht bewertet.',
        ),
      ],
    ),
    _ => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Wie aktiv bist du meistens?', style: _groupLabelStyle),
        const SizedBox(height: 9),
        _ChoiceGrid<ActivityPattern>(
          values: ActivityPattern.values,
          selected: _draft.activity,
          keyPrefix: 'activity',
          label: (item) => item.label,
          icon: (item) => switch (item) {
            ActivityPattern.mostlySeated => Icons.chair_alt_outlined,
            ActivityPattern.mixed => Icons.directions_walk_rounded,
            ActivityPattern.oftenMoving => Icons.directions_run_rounded,
            ActivityPattern.veryActive => Icons.bolt_rounded,
          },
          compact: true,
          onChanged: (item) => _update(_draft.copyWith(activity: item)),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<NutritionPreference>(
          key: const ValueKey('personal-nutrition'),
          initialValue: _draft.nutrition,
          dropdownColor: AppColors.surfaceHigh,
          decoration: const InputDecoration(labelText: 'Ernährung'),
          items: NutritionPreference.values
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(switch (item) {
                    NutritionPreference.mixed => 'Gemischt',
                    NutritionPreference.vegetarian => 'Vegetarisch',
                    NutritionPreference.vegan => 'Vegan',
                    NutritionPreference.pescatarian => 'Pescetarisch',
                  }, textScaler: TextScaler.noScaling),
                ),
              )
              .toList(),
          onChanged: _saving
              ? null
              : (item) => _update(_draft.copyWith(nutrition: item)),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('personal-allergies'),
          controller: _allergies,
          enabled: !_saving,
          maxLength: 160,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Allergien',
            hintText: 'z. B. Nüsse',
          ),
          onChanged: (value) => _update(_draft.copyWith(allergies: value)),
        ),
      ],
    ),
  };
}

const _groupLabelStyle = TextStyle(
  color: AppColors.text,
  fontSize: 14,
  fontWeight: FontWeight.w800,
);

class _Header extends StatelessWidget {
  const _Header({
    required this.step,
    required this.count,
    required this.saving,
    required this.editing,
    required this.onSkip,
  });

  final int step;
  final int count;
  final bool saving;
  final bool editing;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 14, 8),
    child: Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              const Text(
                'livo.',
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.4,
                ),
              ),
              const Spacer(),
              if (constraints.maxWidth >= 290) ...[
                Text(
                  '${step + 1} / $count',
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(width: 7),
              ],
              SizedBox(
                width: 108,
                child: TextButton(
                  key: const ValueKey('personal-later'),
                  onPressed: saving ? null : onSkip,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(editing ? 'Schließen' : 'Überspringen'),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: List.generate(
            count,
            (index) => Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: index == count - 1 ? 0 : 5),
                decoration: BoxDecoration(
                  color: index <= step ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _QuestionFrame extends StatelessWidget {
  const _QuestionFrame({
    required this.title,
    required this.subtitle,
    required this.error,
    required this.child,
  });

  final String title;
  final String subtitle;
  final String? error;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 27,
            height: 1.05,
            letterSpacing: -1,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textMuted, height: 1.4),
        ),
        if (error != null) ...[
          const SizedBox(height: 10),
          Text(error!, style: const TextStyle(color: AppColors.error)),
        ],
        const SizedBox(height: 21),
        child,
      ],
    ),
  );
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.saving,
    required this.first,
    required this.last,
    required this.onBack,
    required this.onNext,
  });

  final bool saving;
  final bool first;
  final bool last;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.border)),
      color: AppColors.background,
    ),
    child: Row(
      children: [
        IconButton.outlined(
          key: const ValueKey('personal-back'),
          onPressed: saving ? null : onBack,
          icon: Icon(first ? Icons.close_rounded : Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton(
            key: const ValueKey('personal-next'),
            onPressed: saving ? null : onNext,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
            child: Text(
              saving
                  ? 'Wird gespeichert …'
                  : last
                  ? 'Fertig'
                  : 'Weiter',
            ),
          ),
        ),
      ],
    ),
  );
}

class _ChoiceGrid<T> extends StatelessWidget {
  const _ChoiceGrid({
    required this.values,
    required this.selected,
    required this.keyPrefix,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.compact = false,
  });

  final List<T> values;
  final T? selected;
  final String keyPrefix;
  final String Function(T value) label;
  final IconData Function(T value) icon;
  final ValueChanged<T> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: values.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 9,
      mainAxisSpacing: 9,
      childAspectRatio: compact ? 2.6 : 1.75,
    ),
    itemBuilder: (context, index) {
      final value = values[index];
      final active = value == selected;
      return Semantics(
        button: true,
        selected: active,
        child: Material(
          color: active
              ? AppColors.primary.withValues(alpha: .13)
              : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(17),
          child: InkWell(
            key: ValueKey('personal-$keyPrefix-${(value as Enum).name}'),
            borderRadius: BorderRadius.circular(17),
            onTap: () => onChanged(value),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 10,
                vertical: compact ? 7 : 4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: active ? AppColors.primary : AppColors.border,
                ),
              ),
              child: compact
                  ? Row(
                      children: [
                        Icon(
                          icon(value),
                          size: 18,
                          color: active
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            label(value),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon(value),
                          size: 20,
                          color: active
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            label(value),
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    },
  );
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.value, required this.onChanged});
  final MeasurementSystem value;
  final ValueChanged<MeasurementSystem> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<MeasurementSystem>(
    segments: const [
      ButtonSegment(
        value: MeasurementSystem.metric,
        label: Text('Metrisch · cm / kg'),
      ),
      ButtonSegment(
        value: MeasurementSystem.imperial,
        label: Text('US · ft / lb'),
      ),
    ],
    selected: {value},
    showSelectedIcon: false,
    onSelectionChanged: (values) => onChanged(values.first),
  );
}

class _PickerCard extends StatelessWidget {
  const _PickerCard({
    required this.label,
    required this.child,
    this.height = 150,
  });
  final String label;
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(label, style: _groupLabelStyle),
        ),
        const SizedBox(height: 4),
        SizedBox(height: height, child: child),
      ],
    ),
  );
}

class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.controller,
    required this.count,
    required this.label,
    required this.onSelected,
  });

  final FixedExtentScrollController controller;
  final int count;
  final String Function(int index) label;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => CupertinoTheme(
    data: const CupertinoThemeData(brightness: Brightness.dark),
    child: CupertinoPicker.builder(
      scrollController: controller,
      itemExtent: 32,
      selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
        background: AppColors.primary.withValues(alpha: .10),
      ),
      onSelectedItemChanged: onSelected,
      childCount: count,
      itemBuilder: (context, index) => Center(
        child: Text(
          label(index),
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

class _WeightRuler extends StatelessWidget {
  const _WeightRuler({
    required this.controller,
    required this.count,
    required this.itemWidth,
    required this.selectedIndex,
    required this.valueFor,
    required this.unit,
    required this.onChanged,
  });

  final ScrollController controller;
  final int count;
  final double itemWidth;
  final int selectedIndex;
  final double Function(int index) valueFor;
  final String unit;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final side = constraints.maxWidth / 2 - itemWidth / 2;
      return SizedBox(
        height: 152,
        child: Stack(
          alignment: Alignment.center,
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification ||
                    notification is ScrollEndNotification) {
                  onChanged();
                }
                return false;
              },
              child: ListView.builder(
                controller: controller,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: side),
                itemCount: count,
                itemBuilder: (context, index) {
                  final value = valueFor(index);
                  final major = value.round() % (unit == 'lb' ? 10 : 5) == 0;
                  final selected = index == selectedIndex;
                  return SizedBox(
                    width: itemWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (major)
                          Text(
                            value.toStringAsFixed(unit == 'lb' ? 0 : 0),
                            style: TextStyle(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                        SizedBox(height: major ? 8 : 31),
                        Container(
                          height: major ? 48 : 22,
                          width: selected ? 3 : 1,
                          color: selected
                              ? AppColors.primary
                              : AppColors.borderBright,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            IgnorePointer(
              child: Container(
                width: 2,
                height: 98,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: .35),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _SoftNote extends StatelessWidget {
  const _SoftNote({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    ),
  );
}
