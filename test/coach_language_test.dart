import 'dart:typed_data';

import 'package:fitness_ai_app/core/data/ai_coach_service.dart';
import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The coach answers in the language of the app: every request to the
/// `ai-coach` function carries it (`locale`).
void main() {
  tearDown(() => L10n.use(L10n.german));

  final jpeg = Uint8List.fromList([1, 2, 3, 4]);

  AiCoachService serviceWith(List<Map<String, Object?>> calls) =>
      AiCoachService(
        invoker: (body, {timeout}) async {
          calls.add(body);
          return switch (body['action']) {
            'meal_photo' => const FunctionResponse(
              status: 200,
              data: {'items': [], 'summary': 'ok'},
            ),
            'history' || 'clear_history' => const FunctionResponse(
              status: 200,
              data: {'messages': [], 'deleted': 0},
            ),
            _ => const FunctionResponse(
              status: 200,
              data: {'answer': 'ok', 'remaining': 1, 'daily_limit': 100},
            ),
          };
        },
      );

  for (final (language, code) in [(L10n.english, 'en'), (L10n.german, 'de')]) {
    test('Chat, Foto und Verlauf senden die App-Sprache "$code"', () async {
      L10n.use(language);
      final calls = <Map<String, Object?>>[];
      final service = serviceWith(calls);

      await service.send(message: 'Hi', context: const {});
      await service.analyzeImage(bytes: jpeg, context: const {});
      try {
        await service.analyzeMealPhoto(bytes: jpeg, context: const {});
      } catch (_) {
        // The reply content does not matter here, only the request.
      }
      await service.loadHistory();

      expect(calls.length, greaterThanOrEqualTo(4));
      for (final call in calls) {
        expect(call['locale'], code, reason: '${call['action']}');
      }
    });
  }

  test('ein Sprachwechsel gilt schon für die nächste Frage', () async {
    final calls = <Map<String, Object?>>[];
    final service = serviceWith(calls);

    L10n.use(L10n.german);
    await service.send(message: 'Idee?', context: const {});
    L10n.use(L10n.english);
    await service.send(message: 'Idea?', context: const {});

    expect(calls.map((call) => call['locale']), ['de', 'en']);
  });
}
