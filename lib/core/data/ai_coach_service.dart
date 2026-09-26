import 'dart:convert';
import 'dart:typed_data';

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

class AiCoachHistory {
  const AiCoachHistory({
    required this.messages,
    this.remaining,
    this.dailyLimit,
  });

  final List<AiCoachMessage> messages;
  final int? remaining;
  final int? dailyLimit;
}

class AiMealPhotoItem {
  const AiMealPhotoItem({
    required this.name,
    required this.amountGrams,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.confidence,
  });

  final String name;
  final double amountGrams;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final String confidence;

  factory AiMealPhotoItem.fromMap(Map<String, dynamic> map) {
    double number(String key) {
      final value = map[key];
      if (value is! num || !value.isFinite || value < 0) {
        throw const FormatException('Ungültiger KI-Nährwert.');
      }
      return value.toDouble();
    }

    final name = (map['name'] as String? ?? '').trim();
    final amount = number('amount_grams');
    if (name.isEmpty || name.length > 100 || amount <= 0 || amount > 5000) {
      throw const FormatException('Ungültiges erkanntes Lebensmittel.');
    }
    return AiMealPhotoItem(
      name: name,
      amountGrams: amount,
      calories: number('calories'),
      protein: number('protein'),
      carbohydrates: number('carbohydrates'),
      fat: number('fat'),
      confidence: switch (map['confidence']) {
        'high' => 'high',
        'medium' => 'medium',
        _ => 'low',
      },
    );
  }
}

class AiMealPhotoAnalysis {
  const AiMealPhotoAnalysis({
    required this.items,
    required this.summary,
    required this.needsReview,
    required this.remaining,
    required this.dailyLimit,
  });

  final List<AiMealPhotoItem> items;
  final String summary;
  final bool needsReview;
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
        body: {'message': cleanMessage, 'context': context},
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

  Future<AiCoachHistory> loadHistory() async {
    try {
      final response = await _client.functions.invoke(
        'ai-coach',
        body: const {'action': 'history'},
      );
      final data = response.data;
      if (data is! Map) {
        throw const AiCoachException(
          'Dein Chatverlauf konnte nicht geladen werden.',
          code: 'invalid_response',
        );
      }
      final rawMessages = data['messages'];
      final messages = rawMessages is List
          ? rawMessages
                .whereType<Map>()
                .map(_messageFromJson)
                .whereType<AiCoachMessage>()
                .toList(growable: false)
          : const <AiCoachMessage>[];
      return AiCoachHistory(
        messages: messages,
        remaining: _nullableInteger(data['remaining']),
        dailyLimit: _nullableInteger(data['daily_limit']),
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
      throw const AiCoachException(
        'Dein Chatverlauf konnte gerade nicht geladen werden.',
        code: 'unavailable',
      );
    } catch (_) {
      throw const AiCoachException(
        'Dein Chatverlauf konnte gerade nicht geladen werden.',
        code: 'unavailable',
      );
    }
  }

  Future<AiCoachReply> analyzeImage({
    required Uint8List bytes,
    required Map<String, Object?> context,
    String mimeType = 'image/jpeg',
  }) async {
    if (bytes.isEmpty || bytes.length > 4 * 1024 * 1024) {
      throw const AiCoachException(
        'Das Foto ist zu groß. Bitte wähle ein kleineres Bild.',
        code: 'image_too_large',
      );
    }
    try {
      final response = await _client.functions.invoke(
        'ai-coach',
        body: {
          'action': 'vision',
          'image_base64': base64Encode(bytes),
          'mime_type': mimeType,
          'context': context,
        },
      );
      final data = response.data;
      if (data is! Map) {
        throw const AiCoachException(
          'Die Bildanalyse hat keine gültige Antwort erhalten.',
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
          'Auf dem Foto konnte gerade nichts sicher erkannt werden.',
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
          'Bitte melde dich erneut an, um die Bildanalyse zu verwenden.',
          code: 'unauthorized',
        );
      }
      if (error.status == 429) {
        throw const AiCoachException(
          'Dein Nachrichtenlimit für heute ist erreicht. Morgen kannst du wieder analysieren.',
          code: 'daily_limit',
        );
      }
      throw const AiCoachException(
        'Die Bildanalyse ist gerade nicht erreichbar. Bitte versuche es erneut.',
        code: 'unavailable',
      );
    } catch (_) {
      throw const AiCoachException(
        'Die Bildanalyse ist gerade nicht erreichbar. Bitte prüfe deine Verbindung.',
        code: 'unavailable',
      );
    }
  }

  Future<AiMealPhotoAnalysis> analyzeMealPhoto({
    required Uint8List bytes,
    required Map<String, Object?> context,
    String mimeType = 'image/jpeg',
  }) async {
    if (bytes.isEmpty || bytes.length > 4 * 1024 * 1024) {
      throw const AiCoachException(
        'Das Foto ist zu groß. Bitte nimm ein kleineres Bild auf.',
        code: 'image_too_large',
      );
    }
    try {
      final response = await _client.functions.invoke(
        'ai-coach',
        body: {
          'action': 'meal_photo',
          'image_base64': base64Encode(bytes),
          'mime_type': mimeType,
          'context': context,
        },
      );
      final data = response.data;
      if (data is! Map) {
        throw const AiCoachException(
          'Die Fotoanalyse hat keine gültige Antwort erhalten.',
          code: 'invalid_response',
        );
      }
      final error = data['error'];
      if (error is String && error.trim().isNotEmpty) {
        throw AiCoachException(error, code: data['code'] as String?);
      }
      final rawAnalysis = data['analysis'];
      if (rawAnalysis is! Map) {
        throw const AiCoachException(
          'Auf dem Foto konnten keine Lebensmittel sicher erkannt werden.',
          code: 'invalid_response',
        );
      }
      final analysis = Map<String, dynamic>.from(rawAnalysis);
      final rawItems = analysis['items'];
      final items = rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) =>
                      AiMealPhotoItem.fromMap(Map<String, dynamic>.from(item)),
                )
                .take(8)
                .toList(growable: false)
          : const <AiMealPhotoItem>[];
      if (items.isEmpty) {
        throw const AiCoachException(
          'Auf dem Foto konnten keine erlaubten Lebensmittel sicher erkannt werden.',
          code: 'empty_response',
        );
      }
      return AiMealPhotoAnalysis(
        items: items,
        summary: (analysis['summary'] as String? ?? '').trim(),
        needsReview: analysis['needs_review'] != false,
        remaining: _integer(data['remaining']),
        dailyLimit: _integer(data['daily_limit']),
      );
    } on AiCoachException {
      rethrow;
    } on FormatException {
      throw const AiCoachException(
        'Die erkannten Werte waren unvollständig. Bitte versuche es erneut.',
        code: 'invalid_response',
      );
    } on FunctionException catch (error) {
      if (error.status == 401 || error.status == 403) {
        throw const AiCoachException(
          'Bitte melde dich erneut an, um die Fotoanalyse zu verwenden.',
          code: 'unauthorized',
        );
      }
      if (error.status == 429) {
        throw const AiCoachException(
          'Dein KI-Limit für heute ist erreicht. Morgen kannst du wieder analysieren.',
          code: 'daily_limit',
        );
      }
      throw const AiCoachException(
        'Die Fotoanalyse ist gerade nicht erreichbar. Bitte versuche es erneut.',
        code: 'unavailable',
      );
    } catch (_) {
      throw const AiCoachException(
        'Die Fotoanalyse ist gerade nicht erreichbar. Bitte prüfe deine Verbindung.',
        code: 'unavailable',
      );
    }
  }

  AiCoachMessage? _messageFromJson(Map value) {
    final role = value['role'];
    final content = value['content'];
    if (content is! String || content.trim().isEmpty) return null;
    if (role == 'user') {
      return AiCoachMessage(role: AiCoachRole.user, text: content.trim());
    }
    if (role == 'assistant') {
      return AiCoachMessage(role: AiCoachRole.assistant, text: content.trim());
    }
    return null;
  }

  int _integer(Object? value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }

  int? _nullableInteger(Object? value) {
    if (value is int) return value;
    return int.tryParse('$value');
  }
}
