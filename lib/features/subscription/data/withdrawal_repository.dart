import 'package:supabase_flutter/supabase_flutter.dart';

/// What the server confirmed for a withdrawal.
class WithdrawalReceipt {
  const WithdrawalReceipt({
    required this.receivedAt,
    required this.emailSent,
    this.reference,
  });

  final DateTime receivedAt;

  /// A confirmation e-mail went out. `false` until e-mail sending is set up.
  final bool emailSent;
  final String? reference;
}

/// Replaceable boundary for the withdrawal function (§ 356a BGB).
abstract interface class WithdrawalRepository {
  String? get currentEmail;

  Future<WithdrawalReceipt> withdraw({
    required String name,
    required String email,
    String? note,
  });
}

/// Sends the withdrawal to the `legal-actions` Edge Function, which stores
/// it and sends the confirmation e-mails.
final class SupabaseWithdrawalRepository implements WithdrawalRepository {
  SupabaseWithdrawalRepository({SupabaseClient? client})
    : _providedClient = client;

  final SupabaseClient? _providedClient;
  SupabaseClient get _client => _providedClient ?? Supabase.instance.client;

  @override
  String? get currentEmail => _client.auth.currentUser?.email;

  @override
  Future<WithdrawalReceipt> withdraw({
    required String name,
    required String email,
    String? note,
  }) async {
    final response = await _client.functions.invoke(
      'legal-actions',
      body: {
        'action': 'withdraw',
        'name': name,
        'email': email,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
    final data = response.data;
    if (data is! Map) throw StateError('Unerwartete Antwort.');
    final received = DateTime.tryParse('${data['received_at'] ?? ''}');
    if (received == null) throw StateError('Unerwartete Antwort.');
    return WithdrawalReceipt(
      receivedAt: received.toLocal(),
      emailSent: data['confirmation_email'] == 'sent',
      reference: data['id'] as String?,
    );
  }
}
