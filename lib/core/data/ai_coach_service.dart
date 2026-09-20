import 'package:supabase_flutter/supabase_flutter.dart';

enum AiCoachRole { user, assistant }

class AiCoachMessage {
  const AiCoachMessage({required this.role, required this.text});

  final AiCoachRole role;
  final String text;

  Map<String, String> toJson() => {
    'role': role == AiCoachRole.user ? 'user' : 'assistant',
    'content': text,
  };
}

class AiCoachReply {
  const AiCoachReply({
    required this.text,
    required this.remaining,
    required this.dailyLimit,
  });

  final String text;
  final int remaining;
  final int dailyLimit;
}

class AiCoachException implements Exception {
  const AiCoachException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class AiCoachService {
  AiCoachService({SupabaseClient? client}) : _providedClient = client;

  final SupabaseClient? _providedClient;
  SupabaseClient get _client => _providedClient ?? Supabase.instance.client;

  Future<AiCoachReply> send({
    required String message,
    required List<AiCoachMessage> history,
    required Map<String, Object?> context,
  }) async {
    final cleanMessage = message.trim();
    if (cleanMessage.isEmpty) {
      throw const AiCoachException('Schreib zuerst eine kurze Frage.');
    }
    if (cleanMessage.length > 600) {
      throw const AiCoachException(
        'Deine Nachricht ist zu lang. Bitte kürze sie auf höchstens 600 Zeichen.',
      );
    }

    try {
      final response = await _client.functions.invoke(
        'ai-coach',
        body: {
          'message': cleanMessage,
          'history': history.reversed
              .take(8)
              .toList()
              .reversed
              .map((entry) => entry.toJson())
              .toList(),
          'context': context,
        },
      );
      final data = response.data;
      if (data is! Map) {
        throw const AiCoachException(
          'Der Coach hat keine gültige Antwort erhalten.',
          code: 'invalid_response',
        );
      }
      final error = data['error'];
      if (error is String && error.trim().isNotEmpty) {
        throw AiCoachException(error, code: data['code'] as String?);
      }
      final answer = data['answer'];
      if (answer is! String || answer.trim().isEmpty) {
        throw const AiCoachException(
          'Der Coach konnte gerade keine Antwort formulieren.',
          code: 'invalid_response',
        );
      }
      return AiCoachReply(
        text: answer.trim(),
        remaining: _integer(data['remaining']),
        dailyLimit: _integer(data['daily_limit']),
      );
    } on AiCoachException {
      rethrow;
    } on FunctionException catch (error) {
      if (error.status == 401 || error.status == 403) {
        throw const AiCoachException(
          'Bitte melde dich erneut an, um den Coach zu verwenden.',
          code: 'unauthorized',
        );
      }
      if (error.status == 429) {
        throw const AiCoachException(
          'Dein Nachrichtenlimit für heute ist erreicht. Morgen kannst du wieder schreiben.',
          code: 'daily_limit',
        );
      }
      throw const AiCoachException(
        'Der Coach ist gerade nicht erreichbar. Bitte versuche es gleich noch einmal.',
        code: 'unavailable',
      );
    } catch (_) {
      throw const AiCoachException(
        'Der Coach ist gerade nicht erreichbar. Bitte prüfe deine Verbindung.',
        code: 'unavailable',
      );
    }
  }

  int _integer(Object? value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }
}
