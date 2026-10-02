import 'dart:async';
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
  const AiCoachException(
    this.message, {
    this.code,
    this.remaining,
    this.dailyLimit,
  });

  /// The server answered that Lookin Premium is required (HTTP 402).
  static const premiumRequiredCode = 'premium_required';

  /// Today's AI requests are used up (HTTP 429 with `daily_limit`).
  static const dailyLimitCode = 'daily_limit';

  /// The login expired or is missing (HTTP 401/403).
  static const unauthorizedCode = 'unauthorized';

  /// The request never reached the server (offline, DNS, CORS, …).
  static const networkCode = 'network';

  /// No answer within the app's waiting time.
  static const timeoutCode = 'timeout';

  /// The server or the AI service failed; trying again may help.
  static const unavailableCode = 'unavailable';

  /// The server answered with something the app cannot read.
  static const invalidResponseCode = 'invalid_response';

  /// The question was rejected (empty or too long).
  static const invalidMessageCode = 'invalid_message';

  final String message;
  final String? code;

  /// Quota values the server sent along with the error, if any.
  final int? remaining;
  final int? dailyLimit;

  bool get premiumRequired => code == premiumRequiredCode;
  bool get dailyLimitReached => code == dailyLimitCode;

  @override
  String toString() => message;
}

/// Sends one request to the `ai-coach` Edge Function. Replaceable in tests.
typedef AiCoachInvoker =
    Future<FunctionResponse> Function(
      Map<String, Object?> body, {
      Duration? timeout,
    });

AiCoachException? _premiumRequired(FunctionException error) {
  final details = error.details;
  final code = details is Map ? details['code'] : null;
  if (error.status != 402 && code != AiCoachException.premiumRequiredCode) {
    return null;
  }
  return const AiCoachException(
    'Diese KI-Funktion ist Teil von Lookin Premium.',
    code: AiCoachException.premiumRequiredCode,
  );
}

/// Talks to the `ai-coach` Edge Function. All AI requests go through the
/// backend; the app never holds a provider key.
class AiCoachService {
  AiCoachService({SupabaseClient? client, AiCoachInvoker? invoker})
    : _providedClient = client,
      _providedInvoker = invoker;

  /// How long the app waits for a coach answer before offering a retry. The
  /// Edge Function itself stops waiting for the AI after 45 seconds.
  static const chatTimeout = Duration(seconds: 55);
  static const historyTimeout = Duration(seconds: 20);
  static const photoTimeout = Duration(seconds: 70);

  /// Longest question the coach accepts; the server checks the same limit.
  static const maxMessageLength = 600;

  final SupabaseClient? _providedClient;
  final AiCoachInvoker? _providedInvoker;
  SupabaseClient get _client => _providedClient ?? Supabase.instance.client;

  Future<FunctionResponse> _invoke(
    Map<String, Object?> body, {
    Duration? timeout,
  }) {
    final invoker = _providedInvoker;
    if (invoker != null) return invoker(body, timeout: timeout);
    return _invokeFunction(body, timeout: timeout);
  }

  Future<FunctionResponse> _invokeFunction(
    Map<String, Object?> body, {
    Duration? timeout,
  }) async {
    if (timeout == null) {
      return _client.functions.invoke('ai-coach', body: body);
    }
    // Aborting frees the browser connection instead of letting it hang.
    final abort = Completer<void>();
    final timer = Timer(timeout, () {
      if (!abort.isCompleted) abort.complete();
    });
    try {
      return await _client.functions.invoke(
        'ai-coach',
        body: body,
        abortSignal: abort.future,
      );
    } on RequestAbortedException {
      throw TimeoutException('ai-coach', timeout);
    } finally {
      timer.cancel();
    }
  }

  Future<AiCoachReply> send({
    required String message,
    required Map<String, Object?> context,
  }) async {
    final cleanMessage = message.trim();
    if (cleanMessage.isEmpty) {
      throw const AiCoachException(
        'Schreib zuerst eine kurze Frage.',
        code: AiCoachException.invalidMessageCode,
      );
    }
    if (cleanMessage.length > maxMessageLength) {
      throw const AiCoachException(
        'Deine Nachricht ist zu lang. Bitte kürze sie auf höchstens '
        '$maxMessageLength Zeichen.',
        code: AiCoachException.invalidMessageCode,
      );
    }

    try {
      final response = await _invoke({
        'message': cleanMessage,
        'context': context,
      }, timeout: chatTimeout);
      return _replyFrom(
        response.data,
        emptyMessage:
            'Der Coach konnte gerade keine Antwort formulieren. Bitte '
            'versuche es noch einmal.',
      );
    } catch (error) {
      throw _chatError(
        error,
        fallback:
            'Der Coach ist gerade nicht erreichbar. Bitte versuche es gleich '
            'noch einmal.',
      );
    }
  }

  Future<AiCoachHistory> loadHistory() async {
    try {
      final response = await _invoke(const {
        'action': 'history',
      }, timeout: historyTimeout);
      final data = response.data;
      if (data is! Map) {
        throw const AiCoachException(
          'Dein Chatverlauf konnte nicht geladen werden.',
          code: AiCoachException.invalidResponseCode,
        );
      }
      final error = data['error'];
      if (error is String && error.trim().isNotEmpty) {
        throw AiCoachException(
          'Dein Chatverlauf konnte gerade nicht geladen werden.',
          code: data['code'] as String? ?? AiCoachException.unavailableCode,
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
    } catch (error) {
      throw _chatError(
        error,
        fallback: 'Dein Chatverlauf konnte gerade nicht geladen werden.',
      );
    }
  }

  /// Deletes every stored coach message of this account on the server.
  /// Returns the number of deleted messages. Throws unless the server
  /// confirms the deletion, so the app never claims a deletion that did not
  /// happen (for example with an outdated Edge Function).
  Future<int> clearHistory() async {
    const notDeleted =
        'Dein Chatverlauf konnte gerade nicht gelöscht werden. Bitte '
        'versuche es gleich noch einmal.';
    try {
      final response = await _invoke(const {
        'action': 'clear_history',
      }, timeout: historyTimeout);
      final data = response.data;
      if (data is! Map || data['cleared'] != true) {
        throw const AiCoachException(
          notDeleted,
          code: AiCoachException.invalidResponseCode,
        );
      }
      return _integer(data['deleted']);
    } catch (error) {
      throw _chatError(error, fallback: notDeleted);
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
      final response = await _invoke({
        'action': 'vision',
        'image_base64': base64Encode(bytes),
        'mime_type': mimeType,
        'context': context,
      }, timeout: photoTimeout);
      return _replyFrom(
        response.data,
        emptyMessage:
            'Auf dem Foto konnte gerade nichts sicher erkannt werden.',
      );
    } catch (error) {
      throw _chatError(
        error,
        fallback:
            'Die Bildanalyse ist gerade nicht erreichbar. Bitte versuche es '
            'erneut.',
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
      final response = await _invoke({
        'action': 'meal_photo',
        'image_base64': base64Encode(bytes),
        'mime_type': mimeType,
        'context': context,
      });
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
      if (_premiumRequired(error) case final premium?) throw premium;
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

  AiCoachReply _replyFrom(Object? data, {required String emptyMessage}) {
    if (data is! Map) {
      throw const AiCoachException(
        'Der Coach hat keine gültige Antwort geschickt. Bitte versuche es '
        'noch einmal.',
        code: AiCoachException.invalidResponseCode,
      );
    }
    final error = data['error'];
    if (error is String && error.trim().isNotEmpty) {
      throw AiCoachException(
        error.trim(),
        code: data['code'] as String?,
        remaining: _nullableInteger(data['remaining']),
        dailyLimit: _nullableInteger(data['daily_limit']),
      );
    }
    final answer = data['answer'];
    final text = answer is String ? cleanCoachText(answer) : '';
    if (text.isEmpty) {
      throw AiCoachException(
        emptyMessage,
        code: AiCoachException.invalidResponseCode,
      );
    }
    return AiCoachReply(
      text: text,
      remaining: _integer(data['remaining']),
      dailyLimit: _integer(data['daily_limit']),
    );
  }

  /// Maps every failure of a coach request to a clear German message.
  AiCoachException _chatError(Object error, {required String fallback}) {
    if (error is AiCoachException) return error;
    if (error is TimeoutException) {
      return const AiCoachException(
        'Der Coach braucht gerade zu lange. Bitte versuche es noch einmal.',
        code: AiCoachException.timeoutCode,
      );
    }
    if (error is FunctionsFetchException) {
      return const AiCoachException(
        'Keine Verbindung zum Coach. Bitte prüfe deine Internetverbindung '
        'und versuche es erneut.',
        code: AiCoachException.networkCode,
      );
    }
    if (error is FunctionException) {
      if (_premiumRequired(error) case final premium?) return premium;
      final details = error.details;
      final code = details is Map ? details['code'] : null;
      final serverMessage = details is Map ? details['error'] : null;
      final message = serverMessage is String && serverMessage.trim().isNotEmpty
          ? serverMessage.trim()
          : null;
      if (error.status == 401 || error.status == 403) {
        return const AiCoachException(
          'Deine Anmeldung ist abgelaufen. Bitte melde dich erneut an.',
          code: AiCoachException.unauthorizedCode,
        );
      }
      if (error.status == 429 && code != 'openai_unavailable') {
        return AiCoachException(
          message ??
              'Dein KI-Tageslimit ist erreicht. Morgen kannst du wieder '
                  'schreiben.',
          code: AiCoachException.dailyLimitCode,
          remaining: 0,
          dailyLimit: details is Map
              ? _nullableInteger(details['daily_limit'])
              : null,
        );
      }
      if (error.status == 400 &&
          (code == 'invalid_message' || code == 'message_too_long')) {
        return AiCoachException(
          message ?? 'Bitte formuliere deine Frage etwas anders.',
          code: AiCoachException.invalidMessageCode,
        );
      }
      if (code == 'openai_timeout' || error.status == 504) {
        return const AiCoachException(
          'Der Coach braucht gerade zu lange. Bitte versuche es noch einmal.',
          code: AiCoachException.timeoutCode,
        );
      }
      // Server messages of the ai-coach function are short German texts.
      return AiCoachException(
        message != null && message.length <= 200 ? message : fallback,
        code: AiCoachException.unavailableCode,
      );
    }
    return AiCoachException(fallback, code: AiCoachException.unavailableCode);
  }

  AiCoachMessage? _messageFromJson(Map value) {
    final role = value['role'];
    final content = value['content'];
    if (content is! String) return null;
    final text = cleanCoachText(content);
    if (text.isEmpty) return null;
    if (role == 'user') {
      return AiCoachMessage(role: AiCoachRole.user, text: text);
    }
    if (role == 'assistant') {
      return AiCoachMessage(role: AiCoachRole.assistant, text: text);
    }
    return null;
  }

  int _integer(Object? value) {
    if (value is int) return value;
    if (value is num && value.isFinite) return value.round();
    return int.tryParse('$value') ?? 0;
  }

  int? _nullableInteger(Object? value) {
    if (value is int) return value;
    if (value is num && value.isFinite) return value.round();
    return int.tryParse('$value');
  }
}

/// Removes control characters and surplus blank lines from coach text. An
/// answer without any letter or digit counts as empty (garbled output).
String cleanCoachText(String value) {
  final text = value
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll(
        RegExp('[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F�​]'),
        '',
      )
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
  if (!RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(text)) return '';
  return text;
}
