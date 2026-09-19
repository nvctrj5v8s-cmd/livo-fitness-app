import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

class BarcodeLookupException implements Exception {
  const BarcodeLookupException(
    this.message, {
    this.kind = BarcodeErrorKind.unknown,
  });

  final String message;
  final BarcodeErrorKind kind;

  @override
  String toString() => message;
}

enum BarcodeErrorKind { invalid, notFound, rateLimited, unavailable, unknown }

/// Looks up one scanned food product through the protected Supabase function.
/// The function enforces a per-account limit and adds Open Food Facts source
/// metadata before storing a shared product record in the catalog.
class BarcodeLookupService {
  BarcodeLookupService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<FoodItem> lookup(String barcode) async {
    final normalized = barcode.trim().replaceAll(RegExp(r'\D'), '');
    if (normalized.length < 8 || normalized.length > 14) {
      throw const BarcodeLookupException(
        'Dieser Barcode ist ungültig.',
        kind: BarcodeErrorKind.invalid,
      );
    }

    try {
      final response = await _client.functions.invoke(
        'barcode-lookup',
        body: {'barcode': normalized},
      );
      final data = response.data;
      if (data is! Map) {
        throw const BarcodeLookupException(
          'Die Produktantwort war unvollständig.',
          kind: BarcodeErrorKind.unavailable,
        );
      }
      final error = data['error'];
      if (error is String) {
        throw BarcodeLookupException(
          error,
          kind: switch (data['code']) {
            'invalid_barcode' => BarcodeErrorKind.invalid,
            'not_found' => BarcodeErrorKind.notFound,
            'rate_limited' => BarcodeErrorKind.rateLimited,
            'upstream_unavailable' => BarcodeErrorKind.unavailable,
            _ => BarcodeErrorKind.unknown,
          },
        );
      }
      final food = data['food'];
      if (food is! Map) {
        throw const BarcodeLookupException(
          'Dieses Produkt wurde nicht gefunden.',
          kind: BarcodeErrorKind.notFound,
        );
      }
      return FoodItem.fromMap(Map<String, dynamic>.from(food));
    } on BarcodeLookupException {
      rethrow;
    } on FunctionException {
      throw const BarcodeLookupException(
        'Die Barcode-Suche ist gerade nicht erreichbar. Bitte versuche es später erneut.',
        kind: BarcodeErrorKind.unavailable,
      );
    } catch (_) {
      throw const BarcodeLookupException(
        'Die Barcode-Suche ist gerade nicht erreichbar. Bitte versuche es später erneut.',
        kind: BarcodeErrorKind.unavailable,
      );
    }
  }
}
