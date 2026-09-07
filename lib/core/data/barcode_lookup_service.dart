import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

class BarcodeLookupService {
  BarcodeLookupService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<FoodItem> lookup(String barcode) async {
    final normalized = barcode.trim();
    if (normalized.isEmpty) throw const FormatException('Ungültiger Barcode.');
    final response = await _client.functions.invoke(
      'barcode-lookup',
      body: {'barcode': normalized},
    );
    final data = response.data;
    if (data is! Map || data['food'] is! Map) {
      throw Exception('Dieses Produkt wurde nicht gefunden.');
    }
    return FoodItem.fromMap(Map<String, dynamic>.from(data['food'] as Map));
  }
}
