import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;
import 'package:image_picker/image_picker.dart';

import '../../../core/data/ai_coach_service.dart';
import '../../../core/data/halal_content_policy.dart';
import '../../../core/models/app_models.dart';
import '../../../core/models/custom_food.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import 'camera_capture_page.dart';

class MealPhotoPage extends StatefulWidget {
  const MealPhotoPage({required this.initialSlot, this.date, super.key});

  final MealSlot initialSlot;
  final DateTime? date;

  @override
  State<MealPhotoPage> createState() => _MealPhotoPageState();
}

class _MealPhotoPageState extends State<MealPhotoPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _service = AiCoachService();
  final List<_EditableMealItem> _items = [];
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _takeAndAnalyze());
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
    if (_takingPhoto || _analyzing) return;
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
      for (final item in _items) {
        item.dispose();
      }
      setState(() {
        _items
          ..clear()
          ..addAll(analysis.items.map(_EditableMealItem.fromAi));
        _summary = analysis.summary;
        _analyzing = false;
      });
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

  void _addEmptyItem() {
    setState(() => _items.add(_EditableMealItem.empty()));
  }

  Future<void> _searchFood() async {
    final controller = AppScope.of(context);
    final food = await showModalBottomSheet<FoodItem>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      builder: (_) => _CatalogFoodPicker(foods: controller.foods),
    );
    if (!mounted || food == null) return;
    setState(() => _items.add(_EditableMealItem.fromFood(food)));
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      setState(() => _error = 'Füge mindestens ein Lebensmittel hinzu.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final controller = AppScope.of(context);
    for (final item in _items) {
      final amount = item.number(item.amount)!;
      final factor = 100 / amount;
      final nutrition = CustomFoodNutrition(
        basis: NutritionBasis.per100g,
        amount: amount,
        calories: item.number(item.calories)! * factor,
        protein: item.number(item.protein)! * factor,
        carbohydrates: item.number(item.carbohydrates)! * factor,
        fat: item.number(item.fat)! * factor,
      );
      final saved = await controller.addCustomFoodToDiary(
        name: item.name.text.trim(),
        slot: _slot,
        nutrition: nutrition,
        date: _date,
        requireLabelValues: false,
      );
      if (!mounted) return;
      if (!saved) {
        setState(() {
          _saving = false;
          _error =
              controller.diaryError ??
              'Ein Lebensmittel konnte nicht gespeichert werden.';
        });
        return;
      }
    }
    if (mounted) Navigator.pop(context, true);
  }

  double get _totalCalories =>
      _items.fold(0, (sum, item) => sum + (item.number(item.calories) ?? 0));
  double get _totalProtein =>
      _items.fold(0, (sum, item) => sum + (item.number(item.protein) ?? 0));
  double get _totalCarbs => _items.fold(
    0,
    (sum, item) => sum + (item.number(item.carbohydrates) ?? 0),
  );
  double get _totalFat =>
      _items.fold(0, (sum, item) => sum + (item.number(item.fat) ?? 0));

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _imageBytes != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: hasPhoto,
      appBar: AppBar(
        backgroundColor: hasPhoto ? Colors.transparent : null,
        foregroundColor: hasPhoto ? AppColors.white : null,
        scrolledUnderElevation: hasPhoto ? 0 : null,
        title: const Text('Mahlzeit erkennen'),
        actions: [
          if (_imageBytes != null && !_analyzing) ...[
            IconButton(
              tooltip: 'Foto aus Galerie',
              onPressed: _saving
                  ? null
                  : () => _takeAndAnalyze(fromGallery: true),
              icon: const Icon(Icons.photo_library_outlined),
            ),
            IconButton(
              tooltip: 'Neues Foto aufnehmen',
              onPressed: _saving ? null : _takeAndAnalyze,
              icon: const Icon(Icons.camera_alt_outlined),
            ),
          ],
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 132),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_analyzing) const _AnalyzingCard(),
                  if (_error != null) ...[
                    _MessageCard(message: _error!, error: true),
                    const SizedBox(height: 12),
                  ],
                  if (_summary?.isNotEmpty == true) ...[
                    _MessageCard(message: _summary!),
                    const SizedBox(height: 12),
                  ],
                  if (_items.isNotEmpty) ...[
                    _MealSlotSelector(
                      value: _slot,
                      enabled: !_saving,
                      onChanged: (slot) => setState(() => _slot = slot),
                    ),
                    const SizedBox(height: 14),
                    _NutritionSummary(
                      calories: _totalCalories,
                      protein: _totalProtein,
                      carbohydrates: _totalCarbs,
                      fat: _totalFat,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Erkannte Lebensmittel',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          '${_items.length}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'KI-Werte sind Schätzungen. Prüfe Namen, Gramm und Nährwerte vor dem Speichern.',
                      style: TextStyle(color: AppColors.textMuted, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    for (var index = 0; index < _items.length; index++) ...[
                      _EditableFoodCard(
                        key: ValueKey('photo-food-$index'),
                        item: _items[index],
                        enabled: !_saving,
                        onChanged: () => setState(() {}),
                        onRemove: () {
                          final removed = _items.removeAt(index);
                          removed.dispose();
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('photo-search-food'),
                            onPressed: _saving ? null : _searchFood,
                            icon: const Icon(Icons.search_rounded),
                            label: const Text('Suchen'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('photo-add-food'),
                            onPressed: _saving ? null : _addEmptyItem,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Selbst hinzufügen'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _items.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: FilledButton.icon(
                key: const Key('save-photo-meal'),
                onPressed: _saving || _analyzing ? null : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(
                  _saving ? 'Wird gespeichert ...' : 'Im Tagebuch speichern',
                ),
              ),
            ),
    );
  }
}

class _EditableMealItem {
  _EditableMealItem({
    required String name,
    required double amount,
    required double calories,
    required double protein,
    required double carbohydrates,
    required double fat,
    required this.confidence,
  }) : name = TextEditingController(text: name),
       amount = TextEditingController(text: _format(amount)),
       calories = TextEditingController(text: _format(calories)),
       protein = TextEditingController(text: _format(protein)),
       carbohydrates = TextEditingController(text: _format(carbohydrates)),
       fat = TextEditingController(text: _format(fat));

  factory _EditableMealItem.fromAi(AiMealPhotoItem item) => _EditableMealItem(
    name: item.name,
    amount: item.amountGrams,
    calories: item.calories,
    protein: item.protein,
    carbohydrates: item.carbohydrates,
    fat: item.fat,
    confidence: item.confidence,
  );

  factory _EditableMealItem.fromFood(FoodItem food) {
    final factor = 100 / food.servingGrams;
    return _EditableMealItem(
      name: food.name,
      amount: 100,
      calories: food.calories * factor,
      protein: food.protein * factor,
      carbohydrates: food.carbohydrates * factor,
      fat: food.fat * factor,
      confidence: 'catalog',
    );
  }

  factory _EditableMealItem.empty() => _EditableMealItem(
    name: '',
    amount: 100,
    calories: 0,
    protein: 0,
    carbohydrates: 0,
    fat: 0,
    confidence: 'manual',
  );

  final TextEditingController name;
  final TextEditingController amount;
  final TextEditingController calories;
  final TextEditingController protein;
  final TextEditingController carbohydrates;
  final TextEditingController fat;
  final String confidence;

  double? number(TextEditingController controller) =>
      parseNutritionNumber(controller.text);

  static String _format(double value) => value
      .toStringAsFixed(value == value.roundToDouble() ? 0 : 1)
      .replaceAll('.', ',');

  void dispose() {
    name.dispose();
    amount.dispose();
    calories.dispose();
    protein.dispose();
    carbohydrates.dispose();
    fat.dispose();
  }
}

class _EditableFoodCard extends StatelessWidget {
  const _EditableFoodCard({
    required this.item,
    required this.enabled,
    required this.onChanged,
    required this.onRemove,
    super.key,
  });

  final _EditableMealItem item;
  final bool enabled;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: item.name,
                  enabled: enabled,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Lebensmittel',
                    isDense: true,
                  ),
                  validator: (value) {
                    final name = value?.trim() ?? '';
                    if (name.isEmpty) return 'Bitte einen Namen eingeben.';
                    return HalalContentPolicy.restrictionReason(name);
                  },
                ),
              ),
              IconButton(
                tooltip: 'Entfernen',
                onPressed: enabled ? onRemove : null,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _NumberField(
                  controller: item.amount,
                  label: 'Menge',
                  suffix: 'g',
                  positive: true,
                  enabled: enabled,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                flex: 2,
                child: _NumberField(
                  controller: item.calories,
                  label: 'Kalorien',
                  suffix: 'kcal',
                  enabled: enabled,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  controller: item.carbohydrates,
                  label: 'Kohlenhydrate',
                  suffix: 'g',
                  enabled: enabled,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumberField(
                  controller: item.protein,
                  label: 'Protein',
                  suffix: 'g',
                  enabled: enabled,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumberField(
                  controller: item.fat,
                  label: 'Fett',
                  suffix: 'g',
                  enabled: enabled,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.enabled,
    required this.onChanged,
    this.positive = false,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final bool enabled;
  final bool positive;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    enabled: enabled,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      suffixText: suffix,
      isDense: true,
    ),
    onChanged: (_) => onChanged(),
    validator: (value) {
      final number = parseNutritionNumber(value ?? '');
      if (number == null || (positive ? number <= 0 : number < 0)) {
        return positive ? 'Größer 0' : 'Ungültig';
      }
      return null;
    },
  );
}

class _MealSlotSelector extends StatelessWidget {
  const _MealSlotSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final MealSlot value;
  final bool enabled;
  final ValueChanged<MealSlot> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        const Icon(Icons.restaurant_rounded, color: AppColors.primary),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Als Mahlzeit speichern',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<MealSlot>(
            value: value,
            dropdownColor: AppColors.surfaceHigh,
            onChanged: enabled
                ? (slot) {
                    if (slot != null) onChanged(slot);
                  }
                : null,
            items: MealSlot.values
                .map(
                  (slot) => DropdownMenuItem(
                    value: slot,
                    child: Text(slot == MealSlot.snack ? 'Snacks' : slot.label),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ),
  );
}

class _NutritionSummary extends StatelessWidget {
  const _NutritionSummary({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
  });

  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _SummaryValue('${calories.round()}', 'kcal', AppColors.primary),
      _SummaryValue(_short(carbohydrates), 'Carbs', AppColors.blue),
      _SummaryValue(_short(protein), 'Protein', AppColors.mint),
      _SummaryValue(_short(fat), 'Fett', AppColors.orange),
    ],
  );

  String _short(double value) => '${value.toStringAsFixed(1)} g';
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue(this.value, this.label, this.color);

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    ),
  );
}

class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader({required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.sizeOf(context).height * 0.5).clamp(
      260.0,
      560.0,
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
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 90,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.background, Color(0x00050708)],
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

class _AnalyzingCard extends StatelessWidget {
  const _AnalyzingCard();

  @override
  Widget build(BuildContext context) => const _MessageCard(
    message: 'KI erkennt Lebensmittel und schätzt die sichtbaren Mengen …',
    loading: true,
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
    final normalized = _query.trim().toLowerCase();
    final foods = widget.foods
        .where(
          (food) =>
              normalized.isEmpty ||
              food.name.toLowerCase().contains(normalized) ||
              (food.brand?.toLowerCase().contains(normalized) ?? false),
        )
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
                ? const Center(child: Text('Kein Lebensmittel gefunden.'))
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
                          '${food.calories.round()} kcal · ${food.servingGrams.round()} g',
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
