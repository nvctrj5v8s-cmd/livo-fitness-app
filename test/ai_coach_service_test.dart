import 'dart:async';

import 'package:fitness_ai_app/core/data/ai_coach_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

AiCoachService _service(
  FutureOr<FunctionResponse> Function(Map<String, Object?> body) handler, {
  List<Map<String, Object?>>? calls,
}) => AiCoachService(
  invoker: (body, {timeout}) async {
    calls?.add(body);
    return handler(body);
  },
);

Future<AiCoachException> _failure(Future<Object?> future) async {
  try {
    await future;
  } on AiCoachException catch (error) {
    return error;
  }
  fail('AiCoachException erwartet');
}

void main() {
  test('Antwort, Restlimit und Kontext werden übertragen', () async {
    final calls = <Map<String, Object?>>[];
    final service = _service(
      (_) => const FunctionResponse(
        status: 200,
        data: {
          'answer': '  Iss **Skyr**.  ',
          'remaining': 7,
          'daily_limit': 50,
        },
      ),
      calls: calls,
    );
    final reply = await service.send(
      message: '  Idee?  ',
      context: const {'goal': 'Fett verlieren'},
    );
    expect(reply.text, 'Iss **Skyr**.');
    expect(reply.remaining, 7);
    expect(reply.dailyLimit, 50);
    expect(calls.single['message'], 'Idee?');
    expect(calls.single['context'], const {'goal': 'Fett verlieren'});
  });

  test('zu lange oder leere Fragen gehen nicht an den Server', () async {
    final calls = <Map<String, Object?>>[];
    final service = _service(
      (_) => const FunctionResponse(status: 200, data: {}),
      calls: calls,
    );
    final tooLong = await _failure(
      service.send(message: 'a' * 601, context: const {}),
    );
    expect(tooLong.code, AiCoachException.invalidMessageCode);
    final empty = await _failure(
      service.send(message: '  ', context: const {}),
    );
    expect(empty.code, AiCoachException.invalidMessageCode);
    expect(calls, isEmpty);
  });

  test('Fehler werden verständlich eingeordnet', () async {
    Future<AiCoachException> sendWith(Object error) => _failure(
      _service((_) => throw error).send(message: 'Hi', context: const {}),
    );

    final limit = await sendWith(
      const FunctionsHttpException(
        status: 429,
        details: {
          'error': 'Dein KI-Tageslimit ist erreicht.',
          'code': 'daily_limit',
          'daily_limit': 50,
        },
      ),
    );
    expect(limit.dailyLimitReached, isTrue);
    expect(limit.remaining, 0);
    expect(limit.dailyLimit, 50);
    expect(limit.message, 'Dein KI-Tageslimit ist erreicht.');

    final busy = await sendWith(
      const FunctionsHttpException(
        status: 429,
        details: {'error': 'Stark ausgelastet.', 'code': 'openai_unavailable'},
      ),
    );
    expect(busy.code, AiCoachException.unavailableCode);

    final premium = await sendWith(
      const FunctionsHttpException(status: 402, details: {'code': 'x'}),
    );
    expect(premium.premiumRequired, isTrue);

    final offline = await sendWith(const FunctionsFetchException());
    expect(offline.code, AiCoachException.networkCode);
    expect(offline.message, contains('Internetverbindung'));

    final slow = await sendWith(TimeoutException('ai-coach'));
    expect(slow.code, AiCoachException.timeoutCode);

    final login = await sendWith(const FunctionsHttpException(status: 401));
    expect(login.code, AiCoachException.unauthorizedCode);

    final server = await sendWith(
      const FunctionsHttpException(status: 500, details: '<html>'),
    );
    expect(server.code, AiCoachException.unavailableCode);
    expect(server.message, contains('nicht erreichbar'));
  });

  test('leere oder unlesbare KI-Antwort wird zum Fehler', () async {
    final service = _service(
      (_) => const FunctionResponse(status: 200, data: {'answer': ' ** '}),
    );
    final error = await _failure(
      service.send(message: 'Hi', context: const {}),
    );
    expect(error.code, AiCoachException.invalidResponseCode);
  });

  test(
    'Verlauf wird gelesen, ungültige Einträge werden übersprungen',
    () async {
      final service = _service(
        (_) => const FunctionResponse(
          status: 200,
          data: {
            'messages': [
              {'role': 'user', 'content': 'Frage'},
              {'role': 'system', 'content': 'geheim'},
              {'role': 'assistant', 'content': ''},
              {'role': 'assistant', 'content': 'Antwort'},
              'kaputt',
            ],
            'remaining': 49,
            'daily_limit': 50,
          },
        ),
      );
      final history = await service.loadHistory();
      expect(history.messages.map((message) => message.text), [
        'Frage',
        'Antwort',
      ]);
      expect(history.remaining, 49);
    },
  );

  test('Löschen gilt nur mit Bestätigung des Servers', () async {
    final confirmed = _service(
      (body) => FunctionResponse(
        status: 200,
        data: body['action'] == 'clear_history'
            ? {'cleared': true, 'deleted': 12}
            : {},
      ),
    );
    expect(await confirmed.clearHistory(), 12);

    // An outdated Edge Function treats the request as an empty question.
    final outdated = _service(
      (_) => const FunctionResponse(
        status: 200,
        data: {'error': 'Schreib zuerst eine kurze Frage.'},
      ),
    );
    final error = await _failure(outdated.clearHistory());
    expect(error.message, contains('nicht gelöscht'));
  });
}
