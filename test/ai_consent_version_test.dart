import 'dart:convert';
import 'dart:io';

import 'package:fitness_ai_app/features/consent/data/consent_repository.dart';
import 'package:fitness_ai_app/features/consent/domain/consent.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  SharedPreferencesAsyncPlatform? previous;
  setUp(() {
    previous = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });
  tearDown(() => SharedPreferencesAsyncPlatform.instance = previous);

  test(
    'AI notices have a separate version; existing health consent stays valid',
    () {
      expect(ConsentTexts.versionFor(ConsentKind.aiProcessing), '2026-10-29');
      expect(ConsentTexts.versionFor(ConsentKind.healthData), '2026-10-14');
      expect(ConsentTexts.isCurrentAiVersion('2026-10-14:de'), isFalse);
      expect(ConsentTexts.isCurrentAiVersion('2026-10-29:en'), isTrue);
    },
  );

  for (final (version, granted, expected) in [
    ('2026-10-14:de', true, null),
    ('2026-10-29:de', true, true),
    ('2026-10-14:de', false, false),
  ]) {
    test(
      'stored AI decision $version / $granted is interpreted as $expected',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(() => server.close(force: true));
        server.listen((request) async {
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            jsonEncode([
              {
                'kind': 'ai_processing',
                'granted': granted,
                'text_version': version,
                'created_at': '2026-10-29T10:00:00Z',
              },
            ]),
          );
          await request.response.close();
        });
        final client = SupabaseClient(
          'http://127.0.0.1:${server.port}',
          'test-key',
        );
        addTearDown(client.dispose);
        final prefs = SharedPreferencesAsync();
        // Old cached grants must not bypass the fresh notice either.
        await prefs.setBool('lookin.consent.v1.ai_processing.alice', true);
        final repo = SupabaseConsentRepository(userId: 'alice', client: client);
        final decisions = await repo.load();
        expect(decisions[ConsentKind.aiProcessing], expected);
      },
    );
  }
}
