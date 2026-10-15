import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'halal_content_policy.dart';
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

enum BarcodeErrorKind {
  invalid,
  notFound,
  notAllowed,
  rateLimited,
  unavailable,
  unknown,
}

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
      throw BarcodeLookupException(
        L10n.current.coreThisBarcodeIsInvalid,
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
        throw BarcodeLookupException(
          L10n.current.coreTheProductResponseWasIncomplete,
          kind: BarcodeErrorKind.unavailable,
        );
      }
      final error = errorFromPayload(data);
      if (error != null) throw error;
      final food = data['food'];
      if (food is! Map) {
        throw BarcodeLookupException(
          L10n.current.coreThisProductWasNotFound,
          kind: BarcodeErrorKind.notFound,
        );
      }
      final item = FoodItem.fromMap(Map<String, dynamic>.from(food));
      if (!HalalContentPolicy.isAllowedFood(item)) {
        throw BarcodeLookupException(
          L10n.current.coreThisProductDoesNotMeetLookinS,
          kind: BarcodeErrorKind.notAllowed,
        );
      }
      return item;
    } on BarcodeLookupException {
      rethrow;
    } on FunctionException catch (error) {
      // The function answers some results with an error status, for example
      // 422 for products outside the halal rule. Its JSON body still says
      // what happened and must not be replaced by a generic server error.
      final fromBody = errorFromPayload(error.details);
      if (fromBody != null) throw fromBody;
      if (error.status == 401 || error.status == 403) {
        throw BarcodeLookupException(
          L10n.current.corePleaseSignInAgainThenTryScanning,
          kind: BarcodeErrorKind.unavailable,
        );
      }
      if (error.status == 429) {
        throw BarcodeLookupException(
          L10n.current.corePleaseWaitAMomentBeforeSearchingFor,
          kind: BarcodeErrorKind.rateLimited,
        );
      }
      throw BarcodeLookupException(
        L10n.current.coreBarcodeSearchDidNotReceiveAValid,
        kind: BarcodeErrorKind.unavailable,
      );
    } catch (_) {
      throw BarcodeLookupException(
        L10n.current.coreBarcodeSearchIsCurrentlyUnavailablePleaseTry,
        kind: BarcodeErrorKind.unavailable,
      );
    }
  }

  /// Reads the `{error, code}` body of the Edge Function, whatever the HTTP
  /// status was. Returns `null` when the body carries no error.
  static BarcodeLookupException? errorFromPayload(Object? data) {
    if (data is! Map) return null;
    final message = data['error'];
    if (message is! String || message.trim().isEmpty) return null;
    final kind = switch (data['code']) {
      'invalid_barcode' => BarcodeErrorKind.invalid,
      'not_found' => BarcodeErrorKind.notFound,
      'not_halal' => BarcodeErrorKind.notAllowed,
      'rate_limited' => BarcodeErrorKind.rateLimited,
      'upstream_unavailable' => BarcodeErrorKind.unavailable,
      _ => BarcodeErrorKind.unknown,
    };
    final localized = L10n.isEnglish
        ? switch (kind) {
            BarcodeErrorKind.invalid => L10n.current.coreThisBarcodeIsInvalid,
            BarcodeErrorKind.notFound =>
              L10n.current.coreThisProductWasNotFound,
            BarcodeErrorKind.notAllowed =>
              L10n.current.coreThisProductDoesNotMeetLookinS,
            BarcodeErrorKind.rateLimited =>
              L10n.current.corePleaseWaitAMomentBeforeSearchingFor,
            _ => L10n.current.coreBarcodeSearchIsCurrentlyUnavailablePleaseTry,
          }
        : message;
    return BarcodeLookupException(localized, kind: kind);
  }
}
