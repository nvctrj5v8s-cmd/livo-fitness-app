import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;
import 'package:image_picker/image_picker.dart';

import '../../../core/data/ai_coach_service.dart';
import '../../../core/data/food_search_service.dart';
import '../../../core/data/halal_content_policy.dart';
import '../../../core/models/app_models.dart';
import '../../../core/models/custom_food.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import 'camera_capture_page.dart';

class MealPhotoPage extends StatefulWidget {
  const MealPhotoPage({
    required this.initialSlot,
    this.date,
    this.initialPhoto,
    this.initialItems,
    super.key,
  });

  final MealSlot initialSlot;
  final DateTime? date;

  /// Skips camera and analysis, e.g. for previews and tests.
  final Uint8List? initialPhoto;
  final List<AiMealPhotoItem>? initialItems;

  @override
  State<MealPhotoPage> createState() => _MealPhotoPageState();
}

class _MealPhotoPageState extends State<MealPhotoPage> {
  final _picker = ImagePicker();
  final _service = AiCoachService();
  final List<MealItemDraft> _items = [];
  late MealSlot _slot;
  Uint8List? _imageBytes;
  bool _takingPhoto = false;
  bool _analyzing = false;
  bool _saving = false;
  String? _summary;
  String? _error;

  DateTime get _date => widget.date ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _slot = widget.initialSlot;
    _imageBytes = widget.initialPhoto;
    if (widget.initialItems case final items?) {
      _items.addAll(items.map(MealItemDraft.fromAi));
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _takeAndAnalyze());
    }
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  bool get _hasNativeCamera =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<Uint8List?> _captureWithCamera() async {
    if (_hasNativeCamera) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final recovered = await _picker.retrieveLostData();
        if (!recovered.isEmpty && recovered.files?.isNotEmpty == true) {
          return recovered.files!.first.readAsBytes();
        }
      }
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 86,
        requestFullMetadata: false,
      );
      return photo?.readAsBytes();
    }
    if (!mounted) return null;
    return Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const CameraCapturePage(),
      ),
    );
  }

  Future<Uint8List?> _pickFromGallery() async {
    if (kIsWeb || _hasNativeCamera) {
      final photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 86,
        requestFullMetadata: false,
      );
      return photo?.readAsBytes();
    }
    final file = await file_selector.openFile(
      acceptedTypeGroups: const [
        file_selector.XTypeGroup(
          label: 'Lebensmittel-Foto',
          extensions: ['jpg', 'jpeg', 'png', 'webp'],
        ),
      ],
    );
    return file?.readAsBytes();
  }

  Future<void> _takeAndAnalyze({bool fromGallery = false}) async {
    if (_takingPhoto || _analyzing || _saving) return;
    setState(() {
      _takingPhoto = true;
      _error = null;
    });
    try {
      final sourceBytes = fromGallery
          ? await _pickFromGallery()
          : await _captureWithCamera();
      if (!mounted) return;
      if (sourceBytes == null) {
        setState(() => _takingPhoto = false);
        return;
      }
      final decoded = image_lib.decodeImage(sourceBytes);
      if (decoded == null) {
        setState(() {
          _takingPhoto = false;
          _error = 'Dieses Foto konnte nicht gelesen werden.';
        });
        return;
      }
      final oriented = image_lib.bakeOrientation(decoded);
      final resized = oriented.width > 1280 || oriented.height > 1280
          ? image_lib.copyResize(
              oriented,
              width: oriented.width >= oriented.height ? 1280 : null,
              height: oriented.height > oriented.width ? 1280 : null,
            )
          : oriented;
      final prepared = Uint8List.fromList(
        image_lib.encodeJpg(resized, quality: 78),
      );
      setState(() {
        _imageBytes = prepared;
        _takingPhoto = false;
        _analyzing = true;
      });
      final controller = AppScope.of(context);
      final analysis = await _service.analyzeMealPhoto(
        bytes: prepared,
        context: {
          'goal': controller.goal,
          'calorie_goal': controller.calorieGoal,
          'calories_today': controller.diaryConsumedCalories,
          'remaining_calories': controller.diaryRemainingCalories,
          'protein_goal': controller.proteinGoal,
          'protein_today': controller.diaryConsumedProtein,
          'nutrition_style': controller.nutritionStyle,
          'allergies': controller.allergies,
        },
      );
      if (!mounted) return;
      final previous = List.of(_items);
      setState(() {
        _items
          ..clear()
          ..addAll(analysis.items.map(MealItemDraft.fromAi));
        _summary = analysis.summary;
        _analyzing = false;
      });
      _disposeLater(previous);
    } on AiCoachException catch (error) {
      if (!mounted) return;
      setState(() {
        _takingPhoto = false;
        _analyzing = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _takingPhoto = false;
        _analyzing = false;
        _error = 'Das Foto konnte gerade nicht analysiert werden.';
      });
    }
  }

  void _disposeLater(Iterable<MealItemDraft> items) {
    final list = List.of(items);
    if (list.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final item in list) {
        item.dispose();
      }
    });
  }

  void _addEmptyItem() {
    setState(() {
      _items.add(MealItemDraft.empty()..expanded = true);
      _error = null;
    });
  }

  void _removeItem(MealItemDraft item) {
    setState(() => _items.remove(item));
    _disposeLater([item]);
  }

  Future<void> _searchFood() async {
    final controller = AppScope.of(context);
    final food = await showModalBottomSheet<FoodItem>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _CatalogFoodPicker(foods: controller.foods),
    );
    if (!mounted || food == null) return;
    setState(() {
      _items.add(MealItemDraft.fromFood(food));
      _error = null;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_items.isEmpty) {
      setState(() => _error = 'Füge mindestens ein Lebensmittel hinzu.');
      return;
    }
    for (final item in _items) {
      final problem = item.problem();
      if (problem != null) {
        setState(() {
          item.expanded = true;
          _error = problem;
        });
        return;
      }
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final controller = AppScope.of(context);
    final saved = <MealItemDraft>[];
    for (final item in List.of(_items)) {
      final amount = item.grams!;
      final factor = 100 / amount;
      final nutrition = CustomFoodNutrition(
        basis: NutritionBasis.per100g,
        amount: amount,
        calories: item.value(item.calories)! * factor,
        protein: item.value(item.protein)! * factor,
        carbohydrates: item.value(item.carbohydrates)! * factor,
        fat: item.value(item.fat)! * factor,
      );
      final ok = await controller.addCustomFoodToDiary(
        name: item.name.text.trim(),
        slot: _slot,
        nutrition: nutrition,
        date: _date,
        requireLabelValues: false,
      );
      if (!mounted) return;
      if (!ok) {
        // Drop already saved items so a retry cannot create duplicates.
        setState(() {
          _items.removeWhere(saved.contains);
          _saving = false;
          _error =
              '${controller.diaryError ?? 'Ein Lebensmittel konnte nicht gespeichert werden.'}'
              '${saved.isEmpty ? '' : ' Bereits gespeicherte Einträge wurden aus der Liste entfernt.'}';
        });
        _disposeLater(saved);
        return;
      }
      saved.add(item);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Zu ${_slotLabel(_slot)} hinzugefügt.')),
    );
    Navigator.pop(context, true);
  }

  double _total(TextEditingController Function(MealItemDraft) field) =>
      _items.fold(0, (sum, item) => sum + (item.value(field(item)) ?? 0));

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _imageBytes != null;
    final busy = _takingPhoto || _analyzing || _saving;
    final totalCalories = _total((item) => item.calories);
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: hasPhoto,
      appBar: AppBar(
        backgroundColor: hasPhoto ? Colors.transparent : null,
        foregroundColor: hasPhoto ? AppColors.white : null,
        scrolledUnderElevation: hasPhoto ? 0 : null,
        title: const Text('Mahlzeit erkennen'),
        actions: [
          if (hasPhoto) ...[
            _AppBarAction(
              tooltip: 'Foto aus Galerie',
              icon: Icons.photo_library_outlined,
              onPressed: busy ? null : () => _takeAndAnalyze(fromGallery: true),
            ),
            const SizedBox(width: 6),
            _AppBarAction(
              tooltip: 'Neues Foto aufnehmen',
              icon: Icons.camera_alt_outlined,
              onPressed: busy ? null : _takeAndAnalyze,
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 130),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          if (_imageBytes case final bytes?)
            _PhotoHeader(bytes: bytes)
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: _PhotoPlaceholder(
                loading: _takingPhoto,
                onCamera: _takeAndAnalyze,
                onGallery: () => _takeAndAnalyze(fromGallery: true),
              ),
            ),
          Transform.translate(
            offset: Offset(0, hasPhoto ? -26 : 0),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Deine Mahlzeit',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const _EstimateBadge(),
                    ],
                  ),
                  if (_summary?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      _summary!,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        height: 1.45,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_analyzing) ...[
                    const _MessageCard(
                      message:
                          'KI erkennt Lebensmittel und schätzt die Mengen …',
                      loading: true,
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (_error != null) ...[
                    _MessageCard(message: _error!, error: true),
                    const SizedBox(height: 14),
                  ],
                  _MealSlotPicker(
                    value: _slot,
                    enabled: !_saving,
                    onChanged: (slot) => setState(() => _slot = slot),
                  ),
                  const SizedBox(height: 14),
                  _TotalsCard(
                    calories: totalCalories,
                    carbohydrates: _total((item) => item.carbohydrates),
                    protein: _total((item) => item.protein),
                    fat: _total((item) => item.fat),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _items.isEmpty
                              ? 'Lebensmittel'
                              : 'Erkannte Lebensmittel',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (_items.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '${_items.length}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tippe auf ein Lebensmittel, um Name und Nährwerte zu '
                    'ändern. Wenn du die Menge änderst, passen sich '
                    'Kalorien und Nährwerte automatisch an.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final item in _items) ...[
                    _FoodItemCard(
                      key: ObjectKey(item),
                      item: item,
                      enabled: !_saving,
                      onChanged: () => setState(() {}),
                      onRemove: () => _removeItem(item),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: _AddTile(
                          key: const Key('photo-search-food'),
                          icon: Icons.search_rounded,
                          label: 'Suchen',
                          onTap: _saving ? null : _searchFood,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _AddTile(
                          key: const Key('photo-add-food'),
                          icon: Icons.add_rounded,
                          label: 'Selbst hinzufügen',
                          onTap: _saving ? null : _addEmptyItem,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'KI-Werte sind Schätzungen. Ein Foto ersetzt keine '
                          'Waage oder Verpackungsangabe – prüfe Mengen und '
                          'Nährwerte vor dem Speichern.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _items.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: FilledButton(
                key: const Key('save-photo-meal'),
                onPressed: busy ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.black,
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Zu ${_slotLabel(_slot)} hinzufügen · '
                          '${totalCalories.round()} kcal',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
              ),
            ),
    );
  }
}

String _slotLabel(MealSlot slot) =>
    slot == MealSlot.snack ? 'Snacks' : slot.label;

/// Editable, user-confirmable draft of one detected food. Nutrient values
/// always belong to the current amount; changing the amount rescales them.
class MealItemDraft {
  MealItemDraft({
    required String name,
    required double amount,
    required double calories,
    required double protein,
    required double carbohydrates,
    required double fat,
    required this.source,
  }) : name = TextEditingController(text: name),
       amount = TextEditingController(text: formatNumber(amount)),
       calories = TextEditingController(text: formatNumber(calories)),
       protein = TextEditingController(text: formatNumber(protein)),
       carbohydrates = TextEditingController(text: formatNumber(carbohydrates)),
       fat = TextEditingController(text: formatNumber(fat)) {
    _captureDensity();
  }

  factory MealItemDraft.fromAi(AiMealPhotoItem item) => MealItemDraft(
    name: item.name,
    amount: item.amountGrams,
    calories: item.calories,
    protein: item.protein,
    carbohydrates: item.carbohydrates,
    fat: item.fat,
    source: item.confidence,
  );

  factory MealItemDraft.fromFood(FoodItem food) {
    final factor = 100 / food.servingGrams;
    return MealItemDraft(
      name: food.name,
      amount: 100,
      calories: food.calories * factor,
      protein: food.protein * factor,
      carbohydrates: food.carbohydrates * factor,
      fat: food.fat * factor,
      source: 'catalog',
    );
  }

  factory MealItemDraft.empty() => MealItemDraft(
    name: '',
    amount: 100,
    calories: 0,
    protein: 0,
    carbohydrates: 0,
    fat: 0,
    source: 'manual',
  );

  final TextEditingController name;
  final TextEditingController amount;
  final TextEditingController calories;
  final TextEditingController protein;
  final TextEditingController carbohydrates;
  final TextEditingController fat;

  /// `high`, `medium`, `low`, `catalog` or `manual`.
  final String source;
  bool expanded = false;

  double _caloriesPerGram = 0;
  double _proteinPerGram = 0;
  double _carbsPerGram = 0;
  double _fatPerGram = 0;

  double? value(TextEditingController controller) =>
      parseNutritionNumber(controller.text);

  double? get grams {
    final value = this.value(amount);
    return value == null || value <= 0 ? null : value;
  }

  void _captureDensity() {
    final g = grams;
    if (g == null) return;
    _caloriesPerGram = (value(calories) ?? 0) / g;
    _proteinPerGram = (value(protein) ?? 0) / g;
    _carbsPerGram = (value(carbohydrates) ?? 0) / g;
    _fatPerGram = (value(fat) ?? 0) / g;
  }

  /// Called after the user typed a new amount.
  void amountEdited() {
    final g = grams;
    if (g == null) return;
    calories.text = formatNumber(_caloriesPerGram * g);
    protein.text = formatNumber(_proteinPerGram * g);
    carbohydrates.text = formatNumber(_carbsPerGram * g);
    fat.text = formatNumber(_fatPerGram * g);
  }

  /// Called after the user typed a nutrient value for the current amount.
  void nutrientEdited() => _captureDensity();

  void changeAmountBy(double delta) {
    final next = ((grams ?? 0) + delta).clamp(1, 5000).toDouble();
    amount.text = formatNumber(next);
    amountEdited();
  }

  String? problem() {
    final label = name.text.trim();
    if (label.isEmpty) return 'Bitte gib jedem Lebensmittel einen Namen.';
    final restricted = HalalContentPolicy.restrictionReason(label);
    if (restricted != null) return restricted;
    if (grams == null) return 'Bitte gib für „$label“ eine Menge über 0 g an.';
    for (final field in [calories, protein, carbohydrates, fat]) {
      final number = value(field);
      if (number == null || number < 0) {
        return 'Bitte prüfe die Nährwerte von „$label“.';
      }
    }
    return null;
  }

  static String formatNumber(double value) {
    final rounded = (value * 10).round() / 10;
    return rounded
        .toStringAsFixed(rounded == rounded.roundToDouble() ? 0 : 1)
        .replaceAll('.', ',');
  }

  void dispose() {
    name.dispose();
    amount.dispose();
    calories.dispose();
    protein.dispose();
    carbohydrates.dispose();
    fat.dispose();
  }
}

class _AppBarAction extends StatelessWidget {
  const _AppBarAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      backgroundColor: Colors.black.withValues(alpha: .45),
      foregroundColor: AppColors.white,
    ),
    icon: Icon(icon, size: 21),
  );
}

class _EstimateBadge extends StatelessWidget {
  const _EstimateBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: AppColors.primary.withValues(alpha: .3)),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
        SizedBox(width: 5),
        Text(
          'KI-Schätzung',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _MealSlotPicker extends StatelessWidget {
  const _MealSlotPicker({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final MealSlot value;
  final bool enabled;
  final ValueChanged<MealSlot> onChanged;

  static const _icons = {
    MealSlot.breakfast: Icons.free_breakfast_rounded,
    MealSlot.lunch: Icons.lunch_dining_rounded,
    MealSlot.dinner: Icons.dinner_dining_rounded,
    MealSlot.snack: Icons.cookie_rounded,
  };

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Zu welcher Mahlzeit?',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 9),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final slot in MealSlot.values)
            _SlotChip(
              key: ValueKey('photo-slot-${slot.name}'),
              icon: _icons[slot]!,
              label: _slotLabel(slot),
              selected: slot == value,
              onTap: enabled ? () => onChanged(slot) : null,
            ),
        ],
      ),
    ],
  );
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: selected ? AppColors.primary : AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.check_circle_rounded : icon,
                size: 17,
                color: selected ? AppColors.black : AppColors.textMuted,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.black : AppColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({
    required this.calories,
    required this.carbohydrates,
    required this.protein,
    required this.fat,
  });

  final double calories;
  final double carbohydrates;
  final double protein;
  final double fat;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(AppColors.surfaceHigh, AppColors.primary, .08)!,
          AppColors.surfaceHigh,
        ],
      ),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.border),
    ),
    child: IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.orange,
                  size: 22,
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${calories.round()}',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'kcal gesamt',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 20, color: AppColors.border),
          Expanded(
            flex: 3,
            child: _MacroValue('Kohlenh.', carbohydrates, AppColors.blue),
          ),
          Expanded(
            flex: 3,
            child: _MacroValue('Protein', protein, AppColors.mint),
          ),
          Expanded(flex: 3, child: _MacroValue('Fett', fat, AppColors.purple)),
        ],
      ),
    ),
  );
}

class _MacroValue extends StatelessWidget {
  const _MacroValue(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(height: 8),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '${value.round()} g',
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
      ),
    ],
  );
}

class _FoodItemCard extends StatelessWidget {
  const _FoodItemCard({
    required this.item,
    required this.enabled,
    required this.onChanged,
    required this.onRemove,
    super.key,
  });

  final MealItemDraft item;
  final bool enabled;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final name = item.name.text.trim();
    final kcal = item.value(item.calories) ?? 0;
    final p = item.value(item.protein) ?? 0;
    final c = item.value(item.carbohydrates) ?? 0;
    final f = item.value(item.fat) ?? 0;
    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.expanded
              ? AppColors.primary.withValues(alpha: .45)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            onTap: enabled
                ? () {
                    item.expanded = !item.expanded;
                    onChanged();
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 8, 4),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      name.isEmpty ? '+' : name.characters.first.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? 'Neues Lebensmittel' : name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: name.isEmpty
                                ? AppColors.textMuted
                                : AppColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${kcal.round()} kcal · K ${c.round()} g · '
                          'P ${p.round()} g · F ${f.round()} g',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _SourceBadge(source: item.source),
                      ],
                    ),
                  ),
                  Icon(
                    item.expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: _AmountStepper(
              item: item,
              enabled: enabled,
              onChanged: onChanged,
            ),
          ),
          if (item.expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 14),
                  TextField(
                    controller: item.name,
                    enabled: enabled,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      isDense: true,
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _NutrientField(
                          controller: item.calories,
                          label: 'Kalorien',
                          suffix: 'kcal',
                          enabled: enabled,
                          onChanged: () {
                            item.nutrientEdited();
                            onChanged();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _NutrientField(
                          controller: item.carbohydrates,
                          label: 'Kohlenh.',
                          suffix: 'g',
                          enabled: enabled,
                          onChanged: () {
                            item.nutrientEdited();
                            onChanged();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _NutrientField(
                          controller: item.protein,
                          label: 'Protein',
                          suffix: 'g',
                          enabled: enabled,
                          onChanged: () {
                            item.nutrientEdited();
                            onChanged();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _NutrientField(
                          controller: item.fat,
                          label: 'Fett',
                          suffix: 'g',
                          enabled: enabled,
                          onChanged: () {
                            item.nutrientEdited();
                            onChanged();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Nährwerte gelten für die oben eingestellte Menge.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11.5,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: enabled ? onRemove : null,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 19),
                      label: const Text('Entfernen'),
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

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (source) {
      'high' => ('Gut erkannt', AppColors.mint, Icons.check_circle_rounded),
      'medium' => ('Bitte kurz prüfen', AppColors.orange, Icons.help_rounded),
      'catalog' => ('Aus der Suche', AppColors.blue, Icons.search_rounded),
      'manual' => ('Eigener Eintrag', AppColors.purple, Icons.edit_rounded),
      _ => ('Unsicher – bitte prüfen', AppColors.error, Icons.warning_rounded),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _AmountStepper extends StatelessWidget {
  const _AmountStepper({
    required this.item,
    required this.enabled,
    required this.onChanged,
  });

  final MealItemDraft item;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: AppColors.surfaceSoft,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 9, right: 4),
            child: Text(
              'Menge',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
        _StepButton(
          icon: Icons.remove_rounded,
          tooltip: '10 g weniger',
          onTap: enabled
              ? () {
                  item.changeAmountBy(-10);
                  onChanged();
                }
              : null,
        ),
        SizedBox(
          width: 78,
          child: TextField(
            controller: item.amount,
            enabled: enabled,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            decoration: const InputDecoration(
              isDense: true,
              suffixText: 'g',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (_) {
              item.amountEdited();
              onChanged();
            },
          ),
        ),
        _StepButton(
          icon: Icons.add_rounded,
          tooltip: '10 g mehr',
          onTap: enabled
              ? () {
                  item.changeAmountBy(10);
                  onChanged();
                }
              : null,
        ),
      ],
    ),
  );
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => IconButton.filled(
    tooltip: tooltip,
    onPressed: onTap,
    style: IconButton.styleFrom(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.primary,
      minimumSize: const Size(44, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    icon: Icon(icon, size: 20),
  );
}

class _NutrientField extends StatelessWidget {
  const _NutrientField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    enabled: enabled,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      suffixText: suffix,
      isDense: true,
    ),
    onChanged: (_) => onChanged(),
  );
}

class _AddTile extends StatelessWidget {
  const _AddTile({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: .35),
            width: 1.4,
          ),
          color: AppColors.primary.withValues(alpha: .05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader({required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.sizeOf(context).height * 0.48).clamp(
      260.0,
      580.0,
    );
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true),
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 140,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xB3000000), Color(0x00000000)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({
    required this.loading,
    required this.onCamera,
    required this.onGallery,
  });

  final bool loading;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 230),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.borderBright),
    ),
    child: Center(
      child: loading
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.primary,
                  size: 34,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Fotografiere deine Mahlzeit – die KI schätzt '
                  'Lebensmittel und Mengen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, height: 1.4),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  key: const Key('photo-open-camera'),
                  onPressed: onCamera,
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Foto aufnehmen'),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  key: const Key('photo-open-gallery'),
                  onPressed: onGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Aus Galerie wählen'),
                ),
              ],
            ),
    ),
  );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.message,
    this.error = false,
    this.loading = false,
  });

  final String message;
  final bool error;
  final bool loading;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: (error ? AppColors.error : AppColors.primary).withValues(
        alpha: .09,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: (error ? AppColors.error : AppColors.primary).withValues(
          alpha: .24,
        ),
      ),
    ),
    child: Row(
      children: [
        if (loading)
          const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Icon(
            error ? Icons.error_outline_rounded : Icons.auto_awesome,
            color: error ? AppColors.error : AppColors.primary,
          ),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

class _CatalogFoodPicker extends StatefulWidget {
  const _CatalogFoodPicker({required this.foods});

  final List<FoodItem> foods;

  @override
  State<_CatalogFoodPicker> createState() => _CatalogFoodPickerState();
}

class _CatalogFoodPickerState extends State<_CatalogFoodPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final foods = widget.foods
        .where((food) => FoodSearchService.matches(food, _query))
        .take(40)
        .toList();
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .82,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderBright,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Lebensmittel suchen',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: foods.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Kein Lebensmittel gefunden. Du kannst es auch über '
                        '„Selbst hinzufügen“ eintragen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    itemCount: foods.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final food = foods[index];
                      return ListTile(
                        tileColor: AppColors.surfaceHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(food.name),
                        subtitle: Text(
                          '${food.calories.round()} kcal · '
                          '${food.servingGrams.round()} g',
                        ),
                        trailing: const Icon(
                          Icons.add_circle_rounded,
                          color: AppColors.primary,
                        ),
                        onTap: () => Navigator.pop(context, food),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
