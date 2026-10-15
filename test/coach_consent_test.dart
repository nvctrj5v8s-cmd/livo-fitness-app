import 'dart:typed_data';

import 'package:fitness_ai_app/core/data/ai_coach_service.dart';
import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The server refuses AI requests without a stored AI consent (HTTP 403 and
/// code `consent_required`). The app must not call that "please sign in
/// again", and must say where to give the consent.
void main() {
  tearDown(() => L10n.use(L10n.german));

  final jpeg = Uint8List.fromList([1, 2, 3, 4]);

  AiCoachService refusing() => AiCoachService(
    invoker: (body, {timeout}) async => throw const FunctionException(
      status: 403,
      details: {
        'code': 'consent_required',
        'error': 'Die KI-Funktionen brauchen deine Einwilligung.',
      },
    ),
  );

  for (final (language, hint) in [
    (L10n.german, 'Einwilligungen'),
    (L10n.english, 'consents'),
  ]) {
    test('Chat ohne Einwilligung (${language.languageCode})', () async {
      L10n.use(language);
      await expectLater(
        refusing().send(message: 'Hallo', context: const {}),
        throwsA(
          isA<AiCoachException>()
              .having(
                (e) => e.code,
                'code',
                AiCoachException.consentRequiredCode,
              )
              .having((e) => e.message, 'message', contains(hint)),
        ),
      );
    });

    test('Foto ohne Einwilligung (${language.languageCode})', () async {
      L10n.use(language);
      await expectLater(
        refusing().analyzeMealPhoto(bytes: jpeg, context: const {}),
        throwsA(
          isA<AiCoachException>()
              .having(
                (e) => e.code,
                'code',
                AiCoachException.consentRequiredCode,
              )
              .having((e) => e.message, 'message', contains(hint)),
        ),
      );
    });
  }

  test('403 ohne diesen Code bleibt „bitte neu anmelden“', () async {
    final service = AiCoachService(
      invoker: (body, {timeout}) async => throw const FunctionException(
        status: 403,
        details: {'code': 'unauthorized'},
      ),
    );
    await expectLater(
      service.send(message: 'Hallo', context: const {}),
      throwsA(
        isA<AiCoachException>().having(
          (e) => e.code,
          'code',
          AiCoachException.unauthorizedCode,
        ),
      ),
    );
  });
}
