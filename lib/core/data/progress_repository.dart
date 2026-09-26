import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/progress_models.dart';

class ProgressRepository {
  ProgressRepository({SupabaseClient? client}) : _providedClient = client;

  final SupabaseClient? _providedClient;
  SupabaseClient get _client => _providedClient ?? Supabase.instance.client;
  static const _customNotePrefix = 'livo:custom:';

  Future<ProgressSnapshot> load({
    required DateTime start,
    required DateTime end,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const ProgressSnapshot(nutrition: [], weights: []);
    }
    final results = await Future.wait([
      _loadNutrition(user.id, start, end),
      _loadWeights(user.id, start, end),
    ]);
    return ProgressSnapshot(
      nutrition: results[0] as List<NutritionDay>,
      weights: results[1] as List<WeightRecord>,
    );
  }

  Future<List<NutritionDay>> _loadNutrition(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final totals = <DateTime, _MutableDay>{};
    const pageSize = 300;
    for (var offset = 0; ; offset += pageSize) {
      final rows = await _client
          .from('meals')
          .select(
            'id,meal_date,note,meal_items(id,amount_grams,foods(serving_grams,calories,protein,carbohydrates,fat))',
          )
          .eq('user_id', userId)
          .gte('meal_date', _dateOnly(start))
          .lte('meal_date', _dateOnly(end))
          .order('meal_date')
          .range(offset, offset + pageSize - 1);
      for (final raw in rows.whereType<Map>()) {
        final date = DateTime.tryParse(raw['meal_date'].toString());
        if (date == null) continue;
        final key = DateTime(date.year, date.month, date.day);
        final day = totals.putIfAbsent(key, () => _MutableDay());
        final custom = _customNutrition(raw['note']);
        if (custom != null) {
          day.add(custom);
          day.mealCount++;
          continue;
        }
        var hasNutrition = false;
        final items = raw['meal_items'];
        if (items is List) {
          for (final item in items.whereType<Map>()) {
            final food = item['foods'];
            if (food is! Map) continue;
            final serving = _number(food['serving_grams']);
            if (serving <= 0) continue;
            final factor = _number(item['amount_grams']) / serving;
            day.calories += _number(food['calories']) * factor;
            day.protein += _number(food['protein']) * factor;
            day.carbs += _number(food['carbohydrates']) * factor;
            day.fat += _number(food['fat']) * factor;
            hasNutrition = true;
          }
        }
        if (hasNutrition) day.mealCount++;
      }
      if (rows.length < pageSize) break;
    }
    final result =
        totals.entries
            .map(
              (entry) => NutritionDay(
                date: entry.key,
                calories: entry.value.calories,
                protein: entry.value.protein,
                carbs: entry.value.carbs,
                fat: entry.value.fat,
                mealCount: entry.value.mealCount,
              ),
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  Future<List<WeightRecord>> _loadWeights(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _client
        .from('body_measurements')
        .select('id,measured_on,weight_kg,waist_cm')
        .eq('user_id', userId)
        .gte('measured_on', _dateOnly(start))
        .lte('measured_on', _dateOnly(end))
        .order('measured_on');
    return rows
        .whereType<Map>()
        .map((row) {
          final date = DateTime.parse(row['measured_on'].toString());
          return WeightRecord(
            id: row['id'].toString(),
            date: DateTime(date.year, date.month, date.day),
            weightKg: _number(row['weight_kg']),
            waistCm: row['waist_cm'] == null ? null : _number(row['waist_cm']),
          );
        })
        .toList(growable: false);
  }

  Future<void> saveWeight({
    required DateTime date,
    required double weightKg,
    double? waistCm,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Bitte melde dich zuerst an.');
    await _client.from('body_measurements').upsert({
      'user_id': user.id,
      'measured_on': _dateOnly(date),
      'weight_kg': weightKg,
      'waist_cm': waistCm,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,measured_on');
  }

  _Nutrition? _customNutrition(Object? note) {
    if (note is! String || !note.startsWith(_customNotePrefix)) return null;
    try {
      final raw = jsonDecode(note.substring(_customNotePrefix.length));
      if (raw is! Map) return null;
      final nutrition = raw['nutrition'];
      if (nutrition is Map) {
        final amount = _number(nutrition['amount']);
        final factor = nutrition['basis'] == 'portion' ? amount : amount / 100;
        return _Nutrition(
          calories: _number(nutrition['calories']) * factor,
          protein: _number(nutrition['protein']) * factor,
          carbs: _number(nutrition['carbohydrates']) * factor,
          fat: _number(nutrition['fat']) * factor,
        );
      }
      return _Nutrition(
        calories: _number(raw['calories']),
        protein: _number(raw['protein']),
        carbs: _number(raw['carbs']),
        fat: _number(raw['fat']),
      );
    } catch (_) {
      return null;
    }
  }

  double _number(Object? value) => value is num ? value.toDouble() : 0;
  String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _MutableDay {
  double calories = 0;
  double protein = 0;
  double carbs = 0;
  double fat = 0;
  int mealCount = 0;

  void add(_Nutrition value) {
    calories += value.calories;
    protein += value.protein;
    carbs += value.carbs;
    fat += value.fat;
  }
}

class _Nutrition {
  const _Nutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
}
